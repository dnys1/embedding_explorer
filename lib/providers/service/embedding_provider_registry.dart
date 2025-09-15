import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';

import '../../configurations/model/configuration_manager.dart';
import '../model/embedding_provider.dart';
import '../model/embedding_provider_config.dart';
import 'gemini_provider.dart';
import 'openai_provider.dart';

/// Registry that manages embedding provider templates and configured instances.
///
/// This class maintains a registry of available provider templates and manages
/// configured provider instances. It listens to the ConfigurationManager and ensures
/// providers are properly connected, updated, and disposed when needed.
class EmbeddingProviderRegistry with ChangeNotifier {
  static final Logger _logger = Logger('EmbeddingProviderRegistry');

  final ConfigurationManager _configManager;
  final Map<String, ConfiguredEmbeddingProvider> _configuredProviders = {};
  final Map<String, Future<Map<String, EmbeddingModel>>> _availableModels = {};

  static const Map<EmbeddingProviderType, EmbeddingProviderTemplate>
  _providerTemplates = {
    EmbeddingProviderType.openai: OpenAIProvider(),
    EmbeddingProviderType.gemini: GeminiProvider(),
  };

  EmbeddingProviderRegistry(this._configManager) {
    _configManager.embeddingProviderConfigs.addListener(
      _onProviderConfigChanged,
    );
  }

  /// Initialize the registry by loading existing configurations
  Future<void> initialize() async {
    final configs = _configManager.embeddingProviderConfigs.all;
    await Future.wait<void>([
      for (final config in configs) _tryConnect(config),
    ]);
  }

  /// Get all configured provider instances
  Iterable<EmbeddingProvider> get all sync* {
    final availableForConfig = Map.of(_providerTemplates);
    for (final provider in _configuredProviders.values) {
      yield provider;
      availableForConfig.remove(provider.type);
    }
    yield* availableForConfig.values;
  }

  /// Get a configured provider by ID
  ConfiguredEmbeddingProvider? get(String id) => _configuredProviders[id];

  /// Get a configured provider by ID, throwing if not found
  ConfiguredEmbeddingProvider expect(String id) {
    final provider = get(id);
    if (provider == null) {
      throw StateError('Configured provider not found: $id');
    }
    return provider;
  }

  /// Connect to a provider using its configuration
  Future<ConfiguredEmbeddingProvider> configure(
    EmbeddingProviderConfig config,
  ) async {
    if (_configuredProviders[config.id] case final existing?) {
      return existing;
    }

    final template = _providerTemplates[config.type];
    if (template == null) {
      throw StateError('No template found for provider type: ${config.type}');
    }

    final provider = await template.configure(config);
    // await provider.testConnection(); // TODO: Add button for testing

    _configuredProviders[config.id] = provider;
    scheduleMicrotask(() {
      unawaited(_configManager.embeddingProviderConfigs.upsert(config));
    });

    return provider;
  }

  Future<Map<String, EmbeddingModel>> listAvailableModels(String providerId) {
    if (_availableModels[providerId] case final cache?) {
      return cache;
    }
    final provider = expect(providerId);
    final future = provider.listAvailableModels().catchError((_) {
      _availableModels.remove(providerId);
      return provider.knownModels;
    });
    _availableModels[providerId] = future;
    return future;
  }

  /// Attempt to connect to a provider, logging errors
  Future<void> _tryConnect(EmbeddingProviderConfig config) async {
    try {
      _logger.fine(
        'Connecting to provider: ${config.id} (${config.type.name})',
      );
      await configure(config);
    } catch (e, st) {
      _logger.warning('Failed to connect to provider: ${config.id}', e, st);
    }
  }

  /// Remove a configured provider
  Future<void> delete(String id) async {
    final provider = _configuredProviders.remove(id);
    _availableModels.remove(id)?.ignore();
    if (provider != null) {
      await _configManager.embeddingProviderConfigs.remove(id);
      _logger.info('Deleted configured provider: $id');
      notifyListeners();
    }
  }

  /// Clear all configured providers
  Future<void> clear() async {
    _configuredProviders.clear();
    _availableModels.clear();
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    _configManager.embeddingProviderConfigs.removeListener(
      _onProviderConfigChanged,
    );
    await clear();
    super.dispose();
  }

  /// Handle changes to provider configurations
  void _onProviderConfigChanged() {
    final currentConfigs = _configManager.embeddingProviderConfigs.all;
    final currentIds = currentConfigs.map((c) => c.id).toSet();
    final cachedIds = _configuredProviders.keys.toSet();

    final connects = <Future<void> Function()>[];
    final disconnects = <Future<void> Function()>[];

    // Remove providers that no longer exist in config
    final removedIds = cachedIds.difference(currentIds);
    for (final id in removedIds) {
      _logger.info('Provider config removed: $id');
      disconnects.add(() => _tryDisconnect(id));
    }

    // Add new providers that are in config but not yet cached
    final newIds = currentIds.difference(cachedIds);
    for (final id in newIds) {
      _logger.info('Provider config added: $id');
      final config = currentConfigs.firstWhere((c) => c.id == id);
      connects.add(() => _tryConnect(config));
    }

    // Update existing providers if their config changed
    for (final config in currentConfigs) {
      if (_configuredProviders.containsKey(config.id)) {
        final existing = _configuredProviders[config.id]!;
        if (existing.config != config) {
          _logger.info('Configuration changed for provider: ${config.id}');
          // Disconnect and recreate the provider with new config
          disconnects.add(() => _tryDisconnect(config.id));
          connects.add(() => _tryConnect(config));
        }
      }
    }

    Future.wait(
      disconnects.map((f) => f()),
    ).then((_) => Future.wait(connects.map((f) => f()))).whenComplete(() {
      _logger.fine('Provider configurations synchronized');
      notifyListeners();
    });
  }

  /// Remove a provider from cache and disconnect it
  Future<void> _tryDisconnect(String id) async {
    final provider = _configuredProviders.remove(id);
    _availableModels.remove(id)?.ignore();
    if (provider != null) {
      _logger.info('Removing provider from cache: $id');
    }
  }
}

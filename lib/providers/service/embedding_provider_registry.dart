import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';

import '../../configurations/model/configuration_manager.dart';
import '../model/embedding_provider.dart';
import '../model/embedding_provider_config.dart';
import '../model/provider_factory.dart';
import 'builtin_providers/gemini_provider.dart';
import 'builtin_providers/ollama_provider.dart';
import 'builtin_providers/openai_provider.dart';

/// Registry that manages embedding provider instances.
///
/// This class maintains a registry of available provider factories and manages
/// provider instances. It listens to the ConfigurationManager and ensures
/// providers are properly connected, updated, and disposed when needed.
class EmbeddingProviderRegistry with ChangeNotifier {
  static final Logger _logger = Logger('EmbeddingProviderRegistry');

  final ConfigurationManager _configManager;
  final Map<String, EmbeddingProvider> _providers = {};
  final Map<String, Future<Map<String, EmbeddingModel>>> _availableModels = {};

  static final Map<EmbeddingProviderType, ProviderFactory> _factories = {
    EmbeddingProviderType.openai: const OpenAIFactory(),
    EmbeddingProviderType.gemini: const GeminiFactory(),
    EmbeddingProviderType.ollama: const OllamaFactory(),
  };

  EmbeddingProviderRegistry(this._configManager) {
    _configManager.embeddingProviderConfigs.addListener(_onConfigChanged);
  }

  /// Initialize the registry by loading existing configurations
  Future<void> initialize() async {
    final configs = _configManager.embeddingProviderConfigs.all;
    await Future.wait(configs.map(_tryLoadProvider));
  }

  /// Get all provider instances (configured and unconfigured)
  List<EmbeddingProvider> get all {
    final all = _collectAll().toList(growable: false);
    all.sort((a, b) {
      // Sort built-in providers first, then custom by name
      final aIsBuiltin = a.type != EmbeddingProviderType.custom;
      final bIsBuiltin = b.type != EmbeddingProviderType.custom;
      if (aIsBuiltin && !bIsBuiltin) return -1;
      if (!aIsBuiltin && bIsBuiltin) return 1;
      if (aIsBuiltin && bIsBuiltin) {
        return a.type.index.compareTo(b.type.index);
      }
      return a.displayName.compareTo(b.displayName);
    });
    return all;
  }

  Iterable<EmbeddingProvider> _collectAll() sync* {
    // First yield all configured providers
    yield* _providers.values;

    // Then yield unconfigured providers for types that aren't configured
    final configuredTypes = _providers.values.map((p) => p.type).toSet();
    for (final factory in _factories.values) {
      if (!configuredTypes.contains(factory.definition.type)) {
        yield factory.createUnconfigured();
      }
    }
  }

  /// Get a provider by ID (returns null if not found)
  EmbeddingProvider? get(String id) => _providers[id];

  /// Get a provider by ID (throws if not found)
  EmbeddingProvider expect(String id) {
    final provider = _providers[id];
    if (provider == null) {
      throw StateError('No provider found with ID: $id');
    }
    return provider;
  }

  /// Get connected providers only
  Iterable<EmbeddingProvider> get connected =>
      _providers.values.where((p) => p.isConnected);

  /// Configure a provider
  Future<EmbeddingProvider> configure(
    EmbeddingProviderConfig config, {
    bool saveConfig = true,
  }) async {
    final factory = _factories[config.type];
    if (factory == null) {
      throw StateError('No factory found for provider type: ${config.type}');
    }

    try {
      final provider = await factory.createFromConfig(config);
      _providers[config.id] = provider;

      // Save configuration if successfully connected and saveConfig is true
      if (saveConfig && provider.isConnected) {
        await _configManager.embeddingProviderConfigs.upsert(config);
      }

      notifyListeners();
      return provider;
    } catch (e, st) {
      _logger.warning('Failed to configure provider ${config.id}', e, st);

      // Create an error state provider
      final errorProvider = factory.createUnconfigured().copyWith(
        connectionState: ProviderConnectionState.error(
          config: config,
          error: e.toString(),
        ),
      );
      _providers[config.id] = errorProvider;
      notifyListeners();
      rethrow;
    }
  }

  /// Remove a provider
  Future<void> remove(String id) async {
    _providers.remove(id);
    _availableModels.remove(id)?.ignore();
    await _configManager.embeddingProviderConfigs.remove(id);
    notifyListeners();
  }

  /// Get available models for a provider
  Future<Map<String, EmbeddingModel>> getAvailableModels(String providerId) {
    if (_availableModels[providerId] case final cached?) {
      return cached;
    }

    final provider = _providers[providerId];
    if (provider?.operationsOrNull case final ops?) {
      final future = ops.listAvailableModels().catchError((_) {
        _availableModels.remove(providerId);
        return provider?.knownModels ?? {};
      });
      _availableModels[providerId] = future;
      return future;
    }

    return Future.value(provider?.knownModels ?? {});
  }

  Future<void> _tryLoadProvider(EmbeddingProviderConfig config) async {
    try {
      // Don't save config when loading from config changes to avoid infinite loop
      await configure(config, saveConfig: false);
    } catch (e) {
      _logger.fine('Provider ${config.id} loaded with error: $e');
    }
  }

  @override
  void dispose() {
    _configManager.embeddingProviderConfigs.removeListener(_onConfigChanged);
    _providers.clear();
    _availableModels.clear();
    super.dispose();
  }

  void _onConfigChanged() {
    // Handle configuration changes
    final currentConfigs = _configManager.embeddingProviderConfigs.all;
    final currentIds = currentConfigs.map((c) => c.id).toSet();
    final providerIds = _providers.keys.toSet();

    // Remove deleted providers
    for (final id in providerIds.difference(currentIds)) {
      _providers.remove(id);
      _availableModels.remove(id)?.ignore();
    }

    // Add or update providers
    for (final config in currentConfigs) {
      unawaited(_tryLoadProvider(config));
    }

    notifyListeners();
  }
}

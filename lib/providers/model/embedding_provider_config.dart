import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../configurations/model/configuration_collection.dart';
import '../../configurations/model/configuration_item.dart';
import '../../credentials/model/credential.dart';
import '../../credentials/service/credential_service.dart';

part 'embedding_provider_config.freezed.dart';

/// Types of embedding providers
enum EmbeddingProviderType { openai, gemini, custom }

/// Configuration for a model provider with metadata
@freezed
abstract class EmbeddingProviderConfig
    with _$EmbeddingProviderConfig
    implements ConfigurationItem {
  factory EmbeddingProviderConfig.create({
    required String id,
    String? name,
    String? description,
    required EmbeddingProviderType type,
    String? customTemplateId,
    Map<String, dynamic>? settings,
    Credential? credential,
    bool? persistCredentials,
    Set<String>? enabledModels,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmbeddingProviderConfig(
      id: id,
      name: name ?? type.name,
      description: description ?? '',
      type: type,
      settings: settings ?? const {},
      credential: credential,
      customTemplateId: customTemplateId,
      persistCredentials: persistCredentials ?? false,
      enabledModels: enabledModels ?? const {},
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  const factory EmbeddingProviderConfig({
    required String id,
    required String name,
    required String description,
    required EmbeddingProviderType type,
    String? customTemplateId,
    required Map<String, dynamic> settings,
    required Credential? credential,
    required bool persistCredentials,
    required Set<String> enabledModels,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _EmbeddingProviderConfig;

  /// Create from database result
  factory EmbeddingProviderConfig.fromDatabase(Map<String, Object?> row) {
    return EmbeddingProviderConfig.create(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String?,
      type: EmbeddingProviderType.values.byName(row['type'] as String),
      customTemplateId: row['custom_template_id'] as String?,
      settings: row['settings'] != null
          ? jsonDecode(row['settings'] as String) as Map<String, dynamic>
          : const {},
      credential: row['credential'] != null
          ? Credential.fromJson(
              jsonDecode(row['credential'] as String) as Map<String, dynamic>,
            )
          : null,
      persistCredentials: (row['persist_credentials'] as int? ?? 0) == 1,
      enabledModels: row['enabled_models'] != null
          ? Set<String>.from(
              jsonDecode(row['enabled_models'] as String) as List,
            )
          : const {},
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}

/// Collection for managing embedding provider configurations
class EmbeddingProviderConfigCollection
    extends ConfigurationCollection<EmbeddingProviderConfig> {
  EmbeddingProviderConfigCollection(
    super.configService,
    this._credentialService,
  );

  final CredentialService _credentialService;

  CredentialStore _credStore(EmbeddingProviderConfig config) {
    return config.persistCredentials
        ? _credentialService.persistent
        : _credentialService.memory;
  }

  @override
  String get prefix => 'ep';

  @override
  String get tableName => 'providers';

  /// Add a new model provider configuration for built-in providers
  Future<String> addConfig({
    required String name,
    required EmbeddingProviderType type,
    String? description,
    Map<String, dynamic>? settings,
    Credential? credential,
    bool? persistCredentials,
    Set<String>? enabledModels,
  }) async {
    final id = generateId();
    final config = EmbeddingProviderConfig.create(
      id: id,
      name: name,
      type: type,
      description: description,
      settings: settings,
      credential: credential,
      persistCredentials: persistCredentials,
      enabledModels: enabledModels,
    ).copyWith(id: id);

    await upsert(config);
    return id;
  }

  /// Update an existing configuration
  Future<bool> updateConfig(
    String id, {
    String? name,
    String? description,
    EmbeddingProviderType? type,
    String? customTemplateId,
    Map<String, dynamic>? settings,
    Credential? credential,
    bool? persistCredentials,
    Set<String>? enabledModels,
  }) async {
    final existing = getById(id);
    if (existing == null) return false;

    final updated = existing.copyWith(
      name: name ?? existing.name,
      description: description ?? existing.description,
      type: type ?? existing.type,
      customTemplateId: customTemplateId ?? existing.customTemplateId,
      settings: settings ?? existing.settings,
      credential: credential ?? existing.credential,
      persistCredentials: persistCredentials ?? existing.persistCredentials,
      enabledModels: enabledModels ?? existing.enabledModels,
      updatedAt: DateTime.now(),
    );

    await upsert(updated);
    return true;
  }

  /// Get configurations by custom template
  EmbeddingProviderConfig? getByCustomTemplate(String templateId) {
    return all.firstWhereOrNull(
      (config) => config.customTemplateId == templateId,
    );
  }

  /// Toggle model enabled status for a provider
  Future<bool> toggleModel(String providerId, String modelId) async {
    final existing = getById(providerId);
    if (existing == null) return false;

    final newEnabledModels = Set<String>.of(existing.enabledModels);
    if (newEnabledModels.contains(modelId)) {
      newEnabledModels.remove(modelId);
    } else {
      newEnabledModels.add(modelId);
    }

    return await updateConfig(providerId, enabledModels: newEnabledModels);
  }

  @override
  Future<void> saveItem(EmbeddingProviderConfig item) async {
    await configService.saveProviderConfig(item);
    final credStore = _credStore(item);
    final persistent = item.persistCredentials;
    logger.fine(
      'Saved model provider credential (persistent=$persistent): ${item.id}',
    );
    await credStore.setCredential(item.id, item.credential);
  }

  @override
  Future<EmbeddingProviderConfig?> loadItem(String id) async {
    final config = await configService.getProviderConfig(id);
    if (config == null) {
      return null;
    }
    final needsLookup = !config.persistCredentials && config.credential == null;
    if (!needsLookup) {
      return config;
    }
    final credStore = _credStore(config);
    final credential = await credStore.getCredential(id);
    return config.copyWith(credential: credential);
  }

  @override
  Future<List<EmbeddingProviderConfig>> loadAllItems() async {
    final configs = await configService.getAllProviderConfigs();
    return Future.wait([
      for (final config in configs)
        if (!config.persistCredentials && config.credential == null)
          Future(() async {
            final credStore = _credStore(config);
            final credential = await credStore.getCredential(config.id);
            return config.copyWith(credential: credential);
          })
        else
          Future.value(config),
    ]);
  }

  @override
  Future<void> removeItem(EmbeddingProviderConfig item) async {
    await configService.deleteProviderConfig(item.id);
    final credStore = _credStore(item);
    await credStore.deleteCredential(item.id);
  }
}

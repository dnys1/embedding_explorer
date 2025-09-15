import 'dart:convert';

import 'package:collection/collection.dart';

import '../../configurations/model/configuration_collection.dart';
import '../../configurations/model/configuration_item.dart';
import '../../credentials/model/credential.dart';
import '../../credentials/service/credential_service.dart';

/// Types of embedding providers
enum EmbeddingProviderType { openai, gemini, custom }

/// Configuration state for providers
enum ConfigurationState {
  /// No configuration exists
  notConfigured,

  /// Configuration exists but credentials not persisted
  partiallyConfigured,

  /// Configuration exists with persisted credentials
  fullyConfigured;

  bool get hasConfiguration => this != notConfigured;
  bool get isPartiallyConfigured => this == partiallyConfigured;
  bool get isFullyConfigured => this == fullyConfigured;
}

/// Configuration for a model provider with metadata
class EmbeddingProviderConfig implements ConfigurationItem {
  @override
  final String id;
  final String name;
  final String description;
  final EmbeddingProviderType type; // null for custom providers
  final String?
  customTemplateId; // Reference to CustomProviderTemplate for custom providers
  final Map<String, dynamic> settings;
  final Credential? credential;
  final bool persistCredentials; // Whether to persist credentials in storage
  final Set<String> enabledModels; // Track which models are enabled
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmbeddingProviderConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.customTemplateId,
    required this.settings,
    required this.credential,
    required this.persistCredentials,
    required this.enabledModels,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with updated fields
  EmbeddingProviderConfig copyWith({
    String? id,
    String? name,
    String? description,
    EmbeddingProviderType? type,
    String? customTemplateId,
    Map<String, dynamic>? settings,
    Credential? credential,
    bool? persistCredentials,
    Set<String>? enabledModels,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmbeddingProviderConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      customTemplateId: customTemplateId ?? this.customTemplateId,
      settings: settings ?? this.settings,
      credential: credential ?? this.credential,
      persistCredentials: persistCredentials ?? this.persistCredentials,
      enabledModels: enabledModels ?? this.enabledModels,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create from database result
  factory EmbeddingProviderConfig.fromDatabase(Map<String, Object?> row) {
    return EmbeddingProviderConfig(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String? ?? '',
      type: EmbeddingProviderType.values.byName(row['type'] as String),
      customTemplateId: row['custom_template_id'] as String?,
      settings: row['settings'] != null
          ? jsonDecode(row['settings'] as String) as Map<String, dynamic>
          : <String, dynamic>{},
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
          : <String>{},
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  /// Create a default configuration for built-in providers
  factory EmbeddingProviderConfig.createDefault({
    required String name,
    required EmbeddingProviderType type,
    String? description,
    Map<String, dynamic>? settings,
    Credential? credential,
    bool? isActive,
    bool? persistCredentials,
    Set<String>? enabledModels,
  }) {
    final now = DateTime.now();
    return EmbeddingProviderConfig(
      id: 'temp_id', // Will be replaced when added to collection
      name: name,
      description: description ?? '',
      type: type,
      customTemplateId: null,
      settings: settings ?? {},
      credential: credential,
      persistCredentials: persistCredentials ?? false,
      enabledModels: enabledModels ?? <String>{},
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a default configuration for custom providers
  factory EmbeddingProviderConfig.createDefaultCustom({
    required String name,
    required String customTemplateId,
    String? description,
    Map<String, dynamic>? settings,
    Credential? credential,
    bool? isActive,
    bool? persistCredentials,
    Set<String>? enabledModels,
  }) {
    final now = DateTime.now();
    return EmbeddingProviderConfig(
      id: 'temp_id', // Will be replaced when added to collection
      name: name,
      description: description ?? '',
      type: EmbeddingProviderType.custom,
      customTemplateId: customTemplateId,
      settings: settings ?? {},
      credential: credential,
      persistCredentials: persistCredentials ?? false,
      enabledModels: enabledModels ?? <String>{},
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Validate the configuration
  bool get isValid {
    return name.isNotEmpty && _hasRequiredCredentials();
  }

  /// Check if required credentials are present
  bool _hasRequiredCredentials() {
    // Built-in provider validation
    switch (type) {
      case EmbeddingProviderType.openai:
        return credential is ApiKeyCredential;
      case EmbeddingProviderType.gemini:
        return credential is ApiKeyCredential;
      case EmbeddingProviderType.custom:
        return true; // TODO
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmbeddingProviderConfig &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.type == type &&
        other.customTemplateId == customTemplateId &&
        const DeepCollectionEquality().equals(other.settings, settings) &&
        other.credential == credential &&
        other.persistCredentials == persistCredentials &&
        const DeepCollectionEquality().equals(
          other.enabledModels,
          enabledModels,
        ) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    type,
    customTemplateId,
    const DeepCollectionEquality().hash(settings),
    credential,
    persistCredentials,
    const DeepCollectionEquality().hash(enabledModels),
    createdAt,
    updatedAt,
  );
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
  String get prefix => 'mp';

  @override
  String get tableName => 'provider_configs';

  /// Add a new model provider configuration for built-in providers
  Future<String> addConfig({
    required String name,
    required EmbeddingProviderType type,
    String? description,
    Map<String, dynamic>? settings,
    Credential? credential,
    bool? isActive,
    bool? persistCredentials,
    Set<String>? enabledModels,
  }) async {
    final id = generateId();
    final config = EmbeddingProviderConfig.createDefault(
      name: name,
      type: type,
      description: description,
      settings: settings,
      credential: credential,
      isActive: isActive,
      persistCredentials: persistCredentials,
      enabledModels: enabledModels,
    ).copyWith(id: id);

    await upsert(config);
    return id;
  }

  /// Add a new custom provider configuration
  Future<String> addCustomConfig({
    required String name,
    required String customTemplateId,
    String? description,
    Map<String, dynamic>? settings,
    Credential? credential,
    bool? isActive,
    bool? persistCredentials,
    Set<String>? enabledModels,
  }) async {
    final id = generateId();
    final config = EmbeddingProviderConfig.createDefaultCustom(
      name: name,
      customTemplateId: customTemplateId,
      description: description,
      settings: settings,
      credential: credential,
      isActive: isActive,
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
    bool? isActive,
    bool? persistCredentials,
    Set<String>? enabledModels,
  }) async {
    final existing = getById(id);
    if (existing == null) return false;

    final updated = existing.copyWith(
      name: name,
      description: description,
      type: type,
      customTemplateId: customTemplateId,
      settings: settings,
      credential: credential,
      persistCredentials: persistCredentials,
      enabledModels: enabledModels,
      updatedAt: DateTime.now(),
    );

    await upsert(updated);
    return true;
  }

  /// Get configurations by type
  EmbeddingProviderConfig? getByType(EmbeddingProviderType type) {
    return all.firstWhereOrNull((config) => config.type == type);
  }

  /// Get configurations by custom template
  EmbeddingProviderConfig? getByCustomTemplate(String templateId) {
    return all.firstWhereOrNull(
      (config) => config.customTemplateId == templateId,
    );
  }

  /// Get all custom provider configurations
  List<EmbeddingProviderConfig> getCustomConfigs() {
    return all
        .where((config) => config.type == EmbeddingProviderType.custom)
        .toList();
  }

  /// Get all built-in provider configurations
  List<EmbeddingProviderConfig> getBuiltInConfigs() {
    return all
        .where((config) => config.type != EmbeddingProviderType.custom)
        .toList();
  }

  /// Get only valid configurations
  List<EmbeddingProviderConfig> getValidConfigs() {
    return all.where((config) => config.isValid).toList();
  }

  /// Search configurations by name
  List<EmbeddingProviderConfig> searchByName(String query) {
    final lowerQuery = query.toLowerCase();
    return all
        .where(
          (config) =>
              config.name.toLowerCase().contains(lowerQuery) ||
              config.description.toLowerCase().contains(lowerQuery),
        )
        .toList();
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

  /// Check if a specific model is enabled for a provider
  bool isModelEnabled(String providerId, String modelId) {
    final config = getById(providerId);
    return config?.enabledModels.contains(modelId) ?? false;
  }

  @override
  Future<void> saveItem(EmbeddingProviderConfig item) async {
    await configService.saveModelProviderConfig(item);
    final credStore = _credStore(item);
    final persistent = item.persistCredentials;
    logger.fine(
      'Saved model provider credential (persistent=$persistent): ${item.id}',
    );
    await credStore.setCredential(item.id, item.credential);
  }

  @override
  Future<EmbeddingProviderConfig?> loadItem(String id) async {
    final config = await configService.getModelProviderConfig(id);
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
    final configs = await configService.getAllModelProviderConfigs();
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
    await configService.deleteModelProviderConfig(item.id);
    final credStore = _credStore(item);
    await credStore.deleteCredential(item.id);
  }
}

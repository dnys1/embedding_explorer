import 'dart:convert';

import 'package:collection/collection.dart';

import '../../configurations/model/configuration_collection.dart';
import '../../configurations/model/configuration_item.dart';

/// Types of embedding providers
enum ProviderType { openai, gemini, custom }

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
class ModelProviderConfig implements ConfigurationItem {
  @override
  final String id;
  final String name;
  final String description;
  final ProviderType type; // null for custom providers
  final String?
  customTemplateId; // Reference to CustomProviderTemplate for custom providers
  final Map<String, dynamic> settings;
  final Map<String, String> credentials;
  final bool persistCredentials; // Whether to persist credentials in storage
  final Set<String> enabledModels; // Track which models are enabled
  final DateTime createdAt;
  final DateTime updatedAt;

  const ModelProviderConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.customTemplateId,
    required this.settings,
    required this.credentials,
    required this.persistCredentials,
    required this.enabledModels,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with updated fields
  ModelProviderConfig copyWith({
    String? id,
    String? name,
    String? description,
    ProviderType? type,
    String? customTemplateId,
    Map<String, dynamic>? settings,
    Map<String, String>? credentials,
    bool? persistCredentials,
    Set<String>? enabledModels,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ModelProviderConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      customTemplateId: customTemplateId ?? this.customTemplateId,
      settings: settings ?? this.settings,
      credentials: (persistCredentials ?? this.persistCredentials)
          ? (credentials ?? this.credentials)
          : const {},
      persistCredentials: persistCredentials ?? this.persistCredentials,
      enabledModels: enabledModels ?? this.enabledModels,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create from database result
  static ModelProviderConfig? fromDatabase(Map<String, Object?> row) {
    try {
      return ModelProviderConfig(
        id: row['id'] as String,
        name: row['name'] as String,
        description: row['description'] as String? ?? '',
        type: ProviderType.values.byName(row['type'] as String),
        customTemplateId: row['custom_template_id'] as String?,
        settings: row['settings'] != null
            ? jsonDecode(row['settings'] as String) as Map<String, dynamic>
            : <String, dynamic>{},
        credentials: row['credentials'] != null
            ? _decodeCredentials(jsonDecode(row['credentials'] as String))
            : <String, String>{},
        persistCredentials: (row['persist_credentials'] as int? ?? 0) == 1,
        enabledModels: row['enabled_models'] != null
            ? Set<String>.from(
                jsonDecode(row['enabled_models'] as String) as List,
              )
            : <String>{},
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );
    } catch (e) {
      print('Error parsing ModelProviderConfig from database: $e');
      return null;
    }
  }

  /// Create a default configuration for built-in providers
  static ModelProviderConfig createDefault({
    required String name,
    required ProviderType type,
    String? description,
    Map<String, dynamic>? settings,
    Map<String, String>? credentials,
    bool? isActive,
    bool? persistCredentials,
    Set<String>? enabledModels,
  }) {
    final now = DateTime.now();
    return ModelProviderConfig(
      id: 'temp_id', // Will be replaced when added to collection
      name: name,
      description: description ?? '',
      type: type,
      customTemplateId: null,
      settings: settings ?? {},
      credentials: credentials ?? {},
      persistCredentials: persistCredentials ?? false,
      enabledModels: enabledModels ?? <String>{},
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a default configuration for custom providers
  static ModelProviderConfig createDefaultCustom({
    required String name,
    required String customTemplateId,
    String? description,
    Map<String, dynamic>? settings,
    Map<String, String>? credentials,
    bool? isActive,
    bool? persistCredentials,
    Set<String>? enabledModels,
  }) {
    final now = DateTime.now();
    return ModelProviderConfig(
      id: 'temp_id', // Will be replaced when added to collection
      name: name,
      description: description ?? '',
      type: ProviderType.custom,
      customTemplateId: customTemplateId,
      settings: settings ?? {},
      credentials: credentials ?? {},
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
      case ProviderType.openai:
        return credentials.containsKey('apiKey') &&
            credentials['apiKey']!.isNotEmpty;
      case ProviderType.gemini:
        return credentials.containsKey('apiKey') &&
            credentials['apiKey']!.isNotEmpty;
      case ProviderType.custom:
        return true; // TODO
    }
  }

  /// Simple decoding for credentials
  static Map<String, String> _decodeCredentials(dynamic credentialsData) {
    // TODO: Implement proper decryption for credentials
    if (credentialsData is Map) {
      return Map<String, String>.from(credentialsData);
    }
    return {};
  }
}

/// Collection for managing model provider configurations
class ModelProviderConfigCollection
    extends ConfigurationCollection<ModelProviderConfig> {
  ModelProviderConfigCollection(super.configService);

  @override
  String get prefix => 'mp';

  @override
  String get tableName => 'model_provider_configs';

  /// Add a new model provider configuration for built-in providers
  Future<String> addConfig({
    required String name,
    required ProviderType type,
    String? description,
    Map<String, dynamic>? settings,
    Map<String, String>? credentials,
    bool? isActive,
    bool? persistCredentials,
    Set<String>? enabledModels,
  }) async {
    final id = generateId();
    final config = ModelProviderConfig.createDefault(
      name: name,
      type: type,
      description: description,
      settings: settings,
      credentials: credentials,
      isActive: isActive,
      persistCredentials: persistCredentials,
      enabledModels: enabledModels,
    ).copyWith(id: id);

    await set(id, config);
    return id;
  }

  /// Add a new custom provider configuration
  Future<String> addCustomConfig({
    required String name,
    required String customTemplateId,
    String? description,
    Map<String, dynamic>? settings,
    Map<String, String>? credentials,
    bool? isActive,
    bool? persistCredentials,
    Set<String>? enabledModels,
  }) async {
    final id = generateId();
    final config = ModelProviderConfig.createDefaultCustom(
      name: name,
      customTemplateId: customTemplateId,
      description: description,
      settings: settings,
      credentials: credentials,
      isActive: isActive,
      persistCredentials: persistCredentials,
      enabledModels: enabledModels,
    ).copyWith(id: id);

    await set(id, config);
    return id;
  }

  /// Update an existing configuration
  Future<bool> updateConfig(
    String id, {
    String? name,
    String? description,
    ProviderType? type,
    String? customTemplateId,
    Map<String, dynamic>? settings,
    Map<String, String>? credentials,
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
      credentials: credentials,
      persistCredentials: persistCredentials,
      enabledModels: enabledModels,
      updatedAt: DateTime.now(),
    );

    await set(id, updated);
    return true;
  }

  /// Get configurations by type
  ModelProviderConfig? getByType(ProviderType type) {
    return all.firstWhereOrNull((config) => config.type == type);
  }

  /// Get configurations by custom template
  ModelProviderConfig? getByCustomTemplate(String templateId) {
    return all.firstWhereOrNull(
      (config) => config.customTemplateId == templateId,
    );
  }

  /// Get all custom provider configurations
  List<ModelProviderConfig> getCustomConfigs() {
    return all.where((config) => config.type == ProviderType.custom).toList();
  }

  /// Get all built-in provider configurations
  List<ModelProviderConfig> getBuiltInConfigs() {
    return all.where((config) => config.type != ProviderType.custom).toList();
  }

  /// Get only valid configurations
  List<ModelProviderConfig> getValidConfigs() {
    return all.where((config) => config.isValid).toList();
  }

  /// Search configurations by name
  List<ModelProviderConfig> searchByName(String query) {
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

    final newEnabledModels = Set<String>.from(existing.enabledModels);
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
  Future<void> saveItem(String id, ModelProviderConfig item) async {
    await configService.saveModelProviderConfig(
      item.copyWith(
        credentials: item.persistCredentials ? item.credentials : const {},
      ),
    );
  }

  @override
  Future<ModelProviderConfig?> loadItem(String id) async {
    return await configService.getModelProviderConfig(id);
  }

  @override
  Future<List<ModelProviderConfig>> loadAllItems() async {
    return await configService.getAllModelProviderConfigs();
  }
}

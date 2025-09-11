import 'package:collection/collection.dart';

import '../../configurations/model/configuration_collection.dart';

/// Types of embedding providers
enum ProviderType { openai, gemini, custom }

/// Configuration for a model provider with metadata
class ModelProviderConfig {
  final String id;
  final String name;
  final String description;
  final ProviderType type; // null for custom providers
  final String?
  customTemplateId; // Reference to CustomProviderTemplate for custom providers
  final Map<String, dynamic> settings;
  final Map<String, String> credentials;
  final bool isActive;
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
    required this.isActive,
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
    bool? isActive,
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
      settings: settings ?? Map.of(this.settings),
      credentials: credentials ?? Map.of(this.credentials),
      isActive: isActive ?? this.isActive,
      persistCredentials: persistCredentials ?? this.persistCredentials,
      enabledModels: enabledModels ?? Set.of(this.enabledModels),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON (without exposing credentials in storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name, // nullable for custom providers
      'customTemplateId': customTemplateId,
      'settings': settings,
      // Only store credentials if user chose to persist them
      'credentials': persistCredentials
          ? _encodeCredentials(credentials)
          : <String, dynamic>{},
      'isActive': isActive,
      'persistCredentials': persistCredentials,
      'enabledModels': enabledModels.toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  static ModelProviderConfig? fromJson(Map<String, dynamic> json) {
    try {
      return ModelProviderConfig(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        type: ProviderType.values.byName(json['type'] as String),
        customTemplateId: json['customTemplateId'] as String?,
        settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
        credentials: _decodeCredentials(json['credentials']),
        isActive: json['isActive'] as bool? ?? true,
        persistCredentials: json['persistCredentials'] as bool? ?? false,
        enabledModels: Set<String>.from(json['enabledModels'] as List? ?? []),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
    } catch (e) {
      print('Error parsing ModelProviderConfig from JSON: $e');
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
      isActive: isActive ?? true,
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
      isActive: isActive ?? true,
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

  /// Simple encoding for credentials (in a real app, use proper encryption)
  static Map<String, String> _encodeCredentials(
    Map<String, String> credentials,
  ) {
    // TODO: Implement proper encryption for credentials
    // For now, just return as-is (this is not secure for production)
    return Map.of(credentials);
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
  static final ModelProviderConfigCollection _instance =
      ModelProviderConfigCollection._internal();

  factory ModelProviderConfigCollection() {
    return _instance;
  }

  ModelProviderConfigCollection._internal();

  @override
  String get prefix => 'mp';

  @override
  String get storageKey => 'model_provider_configs';

  @override
  Map<String, dynamic> toJson(ModelProviderConfig item) => item.toJson();

  @override
  ModelProviderConfig? fromJson(Map<String, dynamic> json) =>
      ModelProviderConfig.fromJson(json);

  /// Add a new model provider configuration for built-in providers
  String addConfig({
    required String name,
    required ProviderType type,
    String? description,
    Map<String, dynamic>? settings,
    Map<String, String>? credentials,
    bool? isActive,
    bool? persistCredentials,
    Set<String>? enabledModels,
  }) {
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

    set(id, config);
    return id;
  }

  /// Add a new custom provider configuration
  String addCustomConfig({
    required String name,
    required String customTemplateId,
    String? description,
    Map<String, dynamic>? settings,
    Map<String, String>? credentials,
    bool? isActive,
    bool? persistCredentials,
    Set<String>? enabledModels,
  }) {
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

    set(id, config);
    return id;
  }

  /// Update an existing configuration
  bool updateConfig(
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
  }) {
    final existing = getById(id);
    if (existing == null) return false;

    final updated = existing.copyWith(
      name: name,
      description: description,
      type: type,
      customTemplateId: customTemplateId,
      settings: settings,
      credentials: credentials,
      isActive: isActive,
      persistCredentials: persistCredentials,
      enabledModels: enabledModels,
      updatedAt: DateTime.now(),
    );

    set(id, updated);
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

  /// Get only active configurations
  List<ModelProviderConfig> getActiveConfigs() {
    return all.where((config) => config.isActive).toList();
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

  /// Toggle active status of a configuration
  bool toggleActive(String id) {
    final existing = getById(id);
    if (existing == null) return false;

    return updateConfig(id, isActive: !existing.isActive);
  }

  /// Toggle model enabled status for a provider
  bool toggleModel(String providerId, String modelId) {
    final existing = getById(providerId);
    if (existing == null) return false;

    final newEnabledModels = Set<String>.from(existing.enabledModels);
    if (newEnabledModels.contains(modelId)) {
      newEnabledModels.remove(modelId);
    } else {
      newEnabledModels.add(modelId);
    }

    return updateConfig(providerId, enabledModels: newEnabledModels);
  }

  /// Check if a specific model is enabled for a provider
  bool isModelEnabled(String providerId, String modelId) {
    final config = getById(providerId);
    return config?.enabledModels.contains(modelId) ?? false;
  }
}

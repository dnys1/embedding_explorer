import 'dart:convert';

import '../../configurations/model/configuration_collection.dart';
import '../../configurations/model/configuration_item.dart';

/// HTTP method for API requests
enum HttpMethod { get, post, put, patch, delete }

/// Template for custom provider HTTP requests
class HttpRequestTemplate {
  final HttpMethod method;
  final String path; // Relative path to append to base URI
  final Map<String, String> headers;
  final String? bodyTemplate; // JSON template with placeholders
  final String? responseModelField; // JSON path to extract model from response
  final String? responseEmbeddingField; // JSON path to extract embeddings

  const HttpRequestTemplate({
    required this.method,
    required this.path,
    required this.headers,
    this.bodyTemplate,
    this.responseModelField,
    this.responseEmbeddingField,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method.name,
      'path': path,
      'headers': headers,
      'bodyTemplate': bodyTemplate,
      'responseModelField': responseModelField,
      'responseEmbeddingField': responseEmbeddingField,
    };
  }

  static HttpRequestTemplate? fromJson(Map<String, dynamic> json) {
    try {
      return HttpRequestTemplate(
        method: HttpMethod.values.firstWhere(
          (e) => e.name == json['method'],
          orElse: () => HttpMethod.post,
        ),
        path: json['path'] as String,
        headers: Map<String, String>.from(json['headers'] as Map? ?? {}),
        bodyTemplate: json['bodyTemplate'] as String?,
        responseModelField: json['responseModelField'] as String?,
        responseEmbeddingField: json['responseEmbeddingField'] as String?,
      );
    } catch (e) {
      print('Error parsing HttpRequestTemplate from JSON: $e');
      return null;
    }
  }
}

/// Template for a custom provider configuration
class CustomProviderTemplate implements ConfigurationItem {
  @override
  final String id;
  final String name;
  final String description;
  final String icon;
  final String baseUri;
  final List<String> requiredCredentials;
  final Map<String, dynamic> defaultSettings;
  final List<String> availableModels; // Model IDs that this provider supports
  final HttpRequestTemplate embeddingRequestTemplate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomProviderTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.baseUri,
    required this.requiredCredentials,
    required this.defaultSettings,
    required this.availableModels,
    required this.embeddingRequestTemplate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with updated fields
  CustomProviderTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? baseUri,
    List<String>? requiredCredentials,
    Map<String, dynamic>? defaultSettings,
    List<String>? availableModels,
    HttpRequestTemplate? embeddingRequestTemplate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomProviderTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      baseUri: baseUri ?? this.baseUri,
      requiredCredentials:
          requiredCredentials ?? List.from(this.requiredCredentials),
      defaultSettings: defaultSettings ?? Map.of(this.defaultSettings),
      availableModels: availableModels ?? List.from(this.availableModels),
      embeddingRequestTemplate:
          embeddingRequestTemplate ?? this.embeddingRequestTemplate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create from database result
  static CustomProviderTemplate? fromDatabase(Map<String, Object?> row) {
    try {
      final requestTemplate = HttpRequestTemplate.fromJson(
        jsonDecode(row['embedding_request_template'] as String)
            as Map<String, dynamic>,
      );
      if (requestTemplate == null) return null;

      return CustomProviderTemplate(
        id: row['id'] as String,
        name: row['name'] as String,
        description: row['description'] as String? ?? '',
        icon: row['icon'] as String? ?? '🔧',
        baseUri: row['base_uri'] as String,
        requiredCredentials: row['required_credentials'] != null
            ? List<String>.from(
                jsonDecode(row['required_credentials'] as String) as List,
              )
            : <String>[],
        defaultSettings: row['default_settings'] != null
            ? jsonDecode(row['default_settings'] as String)
                  as Map<String, dynamic>
            : <String, dynamic>{},
        availableModels: row['available_models'] != null
            ? List<String>.from(
                jsonDecode(row['available_models'] as String) as List,
              )
            : <String>[],
        embeddingRequestTemplate: requestTemplate,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );
    } catch (e) {
      print('Error parsing CustomProviderTemplate from database: $e');
      return null;
    }
  }

  /// Create a default custom provider template
  static CustomProviderTemplate createDefault({
    required String name,
    required String baseUri,
    String? description,
    String? icon,
    List<String>? requiredCredentials,
    List<String>? availableModels,
    HttpRequestTemplate? embeddingRequestTemplate,
  }) {
    final now = DateTime.now();

    return CustomProviderTemplate(
      id: 'temp_id', // Will be replaced when added to collection
      name: name,
      description: description ?? 'Custom embedding provider',
      icon: icon ?? '🔧',
      baseUri: baseUri,
      requiredCredentials: requiredCredentials ?? ['apiKey'],
      defaultSettings: {},
      availableModels: availableModels ?? ['custom-model'],
      embeddingRequestTemplate:
          embeddingRequestTemplate ??
          HttpRequestTemplate(
            method: HttpMethod.post,
            path: '/embeddings',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer {{api_key}}',
            },
            bodyTemplate: '{"input": "{{text}}", "model": "{{model}}"}',
            responseEmbeddingField: 'data.0.embedding',
          ),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Validate the template configuration
  bool get isValid {
    return name.isNotEmpty &&
        baseUri.isNotEmpty &&
        Uri.tryParse(baseUri) != null &&
        availableModels.isNotEmpty;
  }
}

/// Collection for managing custom provider templates
class CustomProviderTemplateCollection
    extends ConfigurationCollection<CustomProviderTemplate> {
  CustomProviderTemplateCollection(super.configService);

  @override
  String get prefix => 'cpt';

  @override
  String get tableName => 'custom_provider_templates';

  /// Add a new custom provider template
  Future<String> addTemplate({
    required String name,
    required String baseUri,
    String? description,
    String? icon,
    List<String>? requiredCredentials,
    List<String>? availableModels,
    HttpRequestTemplate? embeddingRequestTemplate,
  }) async {
    final id = generateId();
    final template = CustomProviderTemplate.createDefault(
      name: name,
      baseUri: baseUri,
      description: description,
      icon: icon,
      requiredCredentials: requiredCredentials,
      availableModels: availableModels,
      embeddingRequestTemplate: embeddingRequestTemplate,
    ).copyWith(id: id);

    await set(id, template);
    return id;
  }

  /// Update an existing template
  Future<bool> updateTemplate(
    String id, {
    String? name,
    String? description,
    String? icon,
    String? baseUri,
    List<String>? requiredCredentials,
    List<String>? availableModels,
    HttpRequestTemplate? embeddingRequestTemplate,
  }) async {
    final existing = getById(id);
    if (existing == null) return false;

    final updated = existing.copyWith(
      name: name,
      description: description,
      icon: icon,
      baseUri: baseUri,
      requiredCredentials: requiredCredentials,
      availableModels: availableModels,
      embeddingRequestTemplate: embeddingRequestTemplate,
      updatedAt: DateTime.now(),
    );

    await set(id, updated);
    return true;
  }

  /// Get all valid templates
  List<CustomProviderTemplate> getValidTemplates() {
    return all.where((template) => template.isValid).toList();
  }

  @override
  Future<void> saveItem(String id, CustomProviderTemplate item) async {
    await configService.saveCustomProviderTemplate(item);
  }

  @override
  Future<CustomProviderTemplate?> loadItem(String id) async {
    return await configService.getCustomProviderTemplate(id);
  }

  @override
  Future<List<CustomProviderTemplate>> loadAllItems() async {
    return await configService.getAllCustomProviderTemplates();
  }
}

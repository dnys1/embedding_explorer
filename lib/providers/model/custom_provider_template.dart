import '../../configurations/model/configuration_collection.dart';

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
class CustomProviderTemplate {
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

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'baseUri': baseUri,
      'requiredCredentials': requiredCredentials,
      'defaultSettings': defaultSettings,
      'availableModels': availableModels,
      'embeddingRequestTemplate': embeddingRequestTemplate.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  static CustomProviderTemplate? fromJson(Map<String, dynamic> json) {
    try {
      final requestTemplate = HttpRequestTemplate.fromJson(
        json['embeddingRequestTemplate'] as Map<String, dynamic>,
      );
      if (requestTemplate == null) return null;

      return CustomProviderTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        icon: json['icon'] as String? ?? '🔧',
        baseUri: json['baseUri'] as String,
        requiredCredentials: List<String>.from(
          json['requiredCredentials'] as List? ?? [],
        ),
        defaultSettings: Map<String, dynamic>.from(
          json['defaultSettings'] as Map? ?? {},
        ),
        availableModels: List<String>.from(
          json['availableModels'] as List? ?? [],
        ),
        embeddingRequestTemplate: requestTemplate,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
    } catch (e) {
      print('Error parsing CustomProviderTemplate from JSON: $e');
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
  @override
  String get prefix => 'cpt';

  @override
  String get storageKey => 'custom_provider_templates';

  @override
  Map<String, dynamic> toJson(CustomProviderTemplate item) => item.toJson();

  @override
  CustomProviderTemplate? fromJson(Map<String, dynamic> json) =>
      CustomProviderTemplate.fromJson(json);

  /// Add a new custom provider template
  String addTemplate({
    required String name,
    required String baseUri,
    String? description,
    String? icon,
    List<String>? requiredCredentials,
    List<String>? availableModels,
    HttpRequestTemplate? embeddingRequestTemplate,
  }) {
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

    set(id, template);
    return id;
  }

  /// Update an existing template
  bool updateTemplate(
    String id, {
    String? name,
    String? description,
    String? icon,
    String? baseUri,
    List<String>? requiredCredentials,
    List<String>? availableModels,
    HttpRequestTemplate? embeddingRequestTemplate,
  }) {
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

    set(id, updated);
    return true;
  }

  /// Get all valid templates
  List<CustomProviderTemplate> getValidTemplates() {
    return all.where((template) => template.isValid).toList();
  }
}

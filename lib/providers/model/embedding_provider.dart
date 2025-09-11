/// Abstract interface for embedding providers
abstract class EmbeddingProvider {
  /// Unique identifier for this provider
  String get id;

  /// Display name for the provider
  String get displayName;

  /// Description of the provider
  String get description;

  /// Whether this provider requires an API key
  bool get requiresApiKey;

  /// List of available models for this provider
  List<EmbeddingModel> get availableModels;

  /// Whether this provider supports custom configuration
  bool get supportsCustomConfig => false;

  /// Validate the provider configuration
  ValidationResult validateConfig(Map<String, dynamic> config);

  /// Test the provider connection
  Future<bool> testConnection(Map<String, dynamic> config);

  /// Generate embeddings for the given texts
  Future<List<List<double>>> generateEmbeddings(
    List<String> texts,
    Map<String, dynamic> config,
  );

  /// Get the dimension of embeddings produced by this provider
  int getEmbeddingDimension(String modelId);
}

/// Represents an embedding model offered by a provider
class EmbeddingModel {
  final String id;
  final String name;
  final String description;
  final int dimensions;
  final int maxInputTokens;
  final double costPer1kTokens;

  const EmbeddingModel({
    required this.id,
    required this.name,
    required this.description,
    required this.dimensions,
    required this.maxInputTokens,
    required this.costPer1kTokens,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'dimensions': dimensions,
    'maxInputTokens': maxInputTokens,
    'costPer1kTokens': costPer1kTokens,
  };

  factory EmbeddingModel.fromJson(Map<String, dynamic> json) => EmbeddingModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    dimensions: json['dimensions'] as int,
    maxInputTokens: json['maxInputTokens'] as int,
    costPer1kTokens: (json['costPer1kTokens'] as num).toDouble(),
  );
}

/// Result of provider configuration validation
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory ValidationResult.valid() => const ValidationResult(isValid: true);

  factory ValidationResult.invalid(List<String> errors) =>
      ValidationResult(isValid: false, errors: errors);

  factory ValidationResult.withWarnings(List<String> warnings) =>
      ValidationResult(isValid: true, warnings: warnings);
}

/// Provider configuration for UI components
class ProviderConfig {
  final String providerId;
  final String? apiKey;
  final String modelId;
  final Map<String, dynamic> customParams;

  const ProviderConfig({
    required this.providerId,
    this.apiKey,
    required this.modelId,
    this.customParams = const {},
  });

  Map<String, dynamic> toJson() => {
    'providerId': providerId,
    if (apiKey != null) 'apiKey': apiKey,
    'modelId': modelId,
    'customParams': customParams,
  };

  factory ProviderConfig.fromJson(Map<String, dynamic> json) => ProviderConfig(
    providerId: json['providerId'] as String,
    apiKey: json['apiKey'] as String?,
    modelId: json['modelId'] as String,
    customParams: json['customParams'] as Map<String, dynamic>? ?? {},
  );

  ProviderConfig copyWith({
    String? providerId,
    String? apiKey,
    String? modelId,
    Map<String, dynamic>? customParams,
  }) => ProviderConfig(
    providerId: providerId ?? this.providerId,
    apiKey: apiKey ?? this.apiKey,
    modelId: modelId ?? this.modelId,
    customParams: customParams ?? this.customParams,
  );
}

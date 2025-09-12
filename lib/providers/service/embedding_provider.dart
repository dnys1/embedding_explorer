import '../model/model_provider_config.dart';

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
  Future<Map<String, EmbeddingModel>> listAvailableModels(
    ModelProviderConfig config,
  );

  /// Whether this provider supports custom configuration
  bool get supportsCustomConfig => false;

  /// Validate the provider configuration
  ValidationResult validateConfig(ModelProviderConfig config);

  /// Test the provider connection
  Future<bool> testConnection(ModelProviderConfig config);

  /// Generate embeddings for the given texts
  Future<List<List<double>>> generateEmbeddings({
    required String modelId,
    required List<String> texts,
    required ModelProviderConfig config,
  });

  /// Get the dimension of embeddings produced by this provider
  int getEmbeddingDimension(String modelId);
}

/// Represents an embedding model offered by a provider
class EmbeddingModel {
  final String id;
  final String name;
  final String description;
  final int dimensions;
  final int? maxInputTokens;
  final double? costPer1kTokens;

  const EmbeddingModel({
    required this.id,
    required this.name,
    required this.description,
    required this.dimensions,
    this.maxInputTokens,
    this.costPer1kTokens,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'dimensions': dimensions,
    'maxInputTokens': ?maxInputTokens,
    'costPer1kTokens': ?costPer1kTokens,
  };

  factory EmbeddingModel.fromJson(Map<String, dynamic> json) => EmbeddingModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    dimensions: (json['dimensions'] as num).toInt(),
    maxInputTokens: (json['maxInputTokens'] as num?)?.toInt(),
    costPer1kTokens: (json['costPer1kTokens'] as num?)?.toDouble(),
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

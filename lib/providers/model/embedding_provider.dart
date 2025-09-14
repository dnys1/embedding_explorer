import '../../common/ui/fa_icon.dart';
import '../../credentials/model/credential.dart';
import 'embedding_provider_config.dart';

/// Base interface for embedding providers (both configured and unconfigured)
abstract interface class EmbeddingProvider {
  /// Type of this provider
  EmbeddingProviderType get type;

  /// Display name for the provider
  String get displayName;

  /// Description of the provider
  String get description;

  /// Icon for the provider in the UI
  FaIconData get icon;

  /// Known models without requiring API calls
  Map<String, EmbeddingModel> get knownModels;

  /// Default settings for this provider
  Map<String, dynamic> get defaultSettings;

  /// Type of credential required for this provider, or null if none required
  CredentialType? get requiredCredential;
}

/// An unconfigured embedding provider - represents a provider template that can be configured
abstract interface class EmbeddingProviderTemplate
    implements EmbeddingProvider {
  /// Create a configured instance of this provider with the given configuration
  Future<ConfiguredEmbeddingProvider> configure(EmbeddingProviderConfig config);
}

/// A configured embedding provider - has access to configuration and can perform operations
abstract interface class ConfiguredEmbeddingProvider
    implements EmbeddingProvider {
  /// The configuration for this provider instance
  EmbeddingProviderConfig get config;

  /// List of available models for this provider
  Future<Map<String, EmbeddingModel>> listAvailableModels();

  /// Test the provider connection
  Future<bool> testConnection();

  /// Generate embeddings for the given texts
  Future<List<List<double>>> generateEmbeddings({
    required String modelId,
    required List<String> texts,
  });
}

extension ConfiguredEmbeddingProviderImpl on ConfiguredEmbeddingProvider {
  /// Unique identifier for this provider
  String get id => config.id;
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

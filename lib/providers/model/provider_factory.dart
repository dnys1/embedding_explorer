import 'embedding_provider.dart';
import 'embedding_provider_config.dart';

/// Factory for creating provider instances
abstract interface class ProviderFactory {
  /// Get the definition for this provider type
  ProviderDefinition get definition;

  /// Create an unconfigured provider instance
  EmbeddingProvider createUnconfigured();

  /// Create a provider instance from configuration
  Future<EmbeddingProvider> createFromConfig(EmbeddingProviderConfig config);

  /// Validate a configuration without connecting
  Future<ValidationResult> validateConfig(EmbeddingProviderConfig config);
}

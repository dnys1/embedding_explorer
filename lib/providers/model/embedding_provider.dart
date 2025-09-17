import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/ui/fa_icon.dart';
import '../../configurations/model/embedding_tables.dart';
import '../../credentials/model/credential.dart';
import '../../util/cancellation_token.dart';
import 'embedding_provider_config.dart';

part 'embedding_provider.freezed.dart';
part 'embedding_provider.g.dart';

/// Represents the connection state of a provider
@freezed
sealed class ProviderConnectionState with _$ProviderConnectionState {
  const factory ProviderConnectionState.unconfigured() = _Unconfigured;
  const factory ProviderConnectionState.partiallyConfigured({
    required EmbeddingProviderConfig config,
    required List<String> missingRequirements,
  }) = _PartiallyConfigured;
  const factory ProviderConnectionState.connected({
    required EmbeddingProviderConfig config,
  }) = _Connected;
  const factory ProviderConnectionState.error({
    required EmbeddingProviderConfig config,
    required String error,
  }) = _Error;
}

/// Static information about a provider type
@freezed
abstract class ProviderDefinition with _$ProviderDefinition {
  const factory ProviderDefinition({
    required EmbeddingProviderType type,
    required String displayName,
    required String description,
    FaIconData? iconData,
    Uri? iconUri,
    required Map<String, EmbeddingModel> knownModels,
    required Map<String, dynamic> defaultSettings,
    CredentialType? requiredCredential,
    String? credentialPlaceholder,
    required List<ConfigurationField> configurationFields,
  }) = _ProviderDefinition;

  factory ProviderDefinition.fromJson(Map<String, dynamic> json) =>
      _$ProviderDefinitionFromJson(json);
}

/// Represents a configuration field for a provider
@freezed
abstract class ConfigurationField with _$ConfigurationField {
  const factory ConfigurationField({
    required String key,
    required String label,
    required ConfigurationFieldType type,
    @Default(false) bool required,
    String? description,
    String? defaultValue,
    List<String>? options, // For dropdown fields
    String? validation, // Regex pattern for validation
  }) = _ConfigurationField;

  factory ConfigurationField.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationFieldFromJson(json);
}

/// Types of configuration fields
enum ConfigurationFieldType { text, password, dropdown, number, boolean }

/// A provider instance that encapsulates all functionality
class EmbeddingProvider {
  final ProviderDefinition definition;
  final ProviderConnectionState connectionState;
  final ProviderOperations? _operations;

  const EmbeddingProvider({
    required this.definition,
    required this.connectionState,
    ProviderOperations? operations,
  }) : _operations = operations;

  // Convenience getters
  EmbeddingProviderType get type => definition.type;
  String get displayName => definition.displayName;
  String get description => definition.description;
  FaIconData? get iconData => definition.iconData;
  Uri? get iconUri => definition.iconUri;
  Map<String, EmbeddingModel> get knownModels => definition.knownModels;
  CredentialType? get requiredCredential => definition.requiredCredential;

  /// Whether this provider is ready to perform operations
  bool get isConnected => connectionState is _Connected;

  /// Whether this provider has some configuration but is missing requirements
  bool get isPartiallyConfigured => connectionState is _PartiallyConfigured;

  /// Whether this provider is unconfigured
  bool get isUnconfigured => connectionState is _Unconfigured;

  /// Whether this provider has an error
  bool get hasError => connectionState is _Error;

  /// Get the current config, if any
  EmbeddingProviderConfig? get config => connectionState.when(
    unconfigured: () => null,
    partiallyConfigured: (config, _) => config,
    connected: (config) => config,
    error: (config, _) => config,
  );

  /// Get missing requirements for partially configured providers
  List<String> get missingRequirements => connectionState.when(
    unconfigured: () => [],
    partiallyConfigured: (_, missing) => missing,
    connected: (_) => [],
    error: (_, _) => [],
  );

  /// Get the error message if in error state
  String? get errorMessage => connectionState.when(
    unconfigured: () => null,
    partiallyConfigured: (_, _) => null,
    connected: (_) => null,
    error: (_, error) => error,
  );

  /// Create a new provider with updated connection state
  EmbeddingProvider copyWith({
    ProviderConnectionState? connectionState,
    ProviderOperations? operations,
  }) => EmbeddingProvider(
    definition: definition,
    connectionState: connectionState ?? this.connectionState,
    operations: operations ?? _operations,
  );

  /// Perform operations (only available when connected)
  ProviderOperations get operations {
    if (!isConnected || _operations == null) {
      throw StateError('Provider is not connected or operations not available');
    }
    return _operations;
  }

  /// Try to get operations without throwing
  ProviderOperations? get operationsOrNull => isConnected ? _operations : null;
}

/// Interface for provider operations (only available when connected)
abstract interface class ProviderOperations {
  /// List available models (may fetch from API)
  Future<Map<String, EmbeddingModel>> listAvailableModels();

  /// Test the provider connection
  Future<ValidationResult> testConnection();

  /// Generate embeddings for the given texts
  Future<List<List<double>>> generateEmbeddings({
    required String modelId,
    required Map<String, String> texts,
    CancellationToken? cancellationToken,
  });

  /// Validate the current configuration
  Future<ValidationResult> validateConfiguration();
}

/// Embedding model with freezed
@freezed
abstract class EmbeddingModel with _$EmbeddingModel {
  const factory EmbeddingModel({
    required String id,
    required String providerId,
    required String name,
    required String description,
    required VectorType vectorType,
    required int dimensions,
    int? maxInputTokens,
    double? costPer1kTokens,
  }) = _EmbeddingModel;

  factory EmbeddingModel.fromJson(Map<String, dynamic> json) =>
      _$EmbeddingModelFromJson(json);
}

/// Validation result with freezed
@freezed
abstract class ValidationResult with _$ValidationResult {
  const factory ValidationResult({
    required bool isValid,
    @Default([]) List<String> errors,
    @Default([]) List<String> warnings,
  }) = _ValidationResult;

  factory ValidationResult.valid() => const ValidationResult(isValid: true);

  factory ValidationResult.invalid(List<String> errors) =>
      ValidationResult(isValid: false, errors: errors);

  factory ValidationResult.withWarnings(List<String> warnings) =>
      ValidationResult(isValid: true, warnings: warnings);

  factory ValidationResult.fromJson(Map<String, dynamic> json) =>
      _$ValidationResultFromJson(json);
}

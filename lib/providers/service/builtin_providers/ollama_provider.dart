import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:ollama_dart/ollama_dart.dart';

import '../../../configurations/model/embedding_tables.dart';
import '../../../util/cancellation_token.dart';
import '../../../util/retryable_exception.dart';
import '../../model/embedding_provider.dart';
import '../../model/embedding_provider_config.dart';
import '../../model/provider_factory.dart';

/// Ollama provider factory
class OllamaFactory implements ProviderFactory {
  const OllamaFactory();

  @override
  ProviderDefinition get definition => ProviderDefinition(
    type: EmbeddingProviderType.ollama,
    displayName: 'Ollama',
    description:
        'Locally hosted Ollama embedding models including nomic-embed-text and all-minilm',
    iconUri: Uri.parse('/images/ollama.png'),
    knownModels: const {},
    defaultSettings: const {
      'base_url': 'http://localhost:11434/api',
      'truncate': true,
    },
    requiredCredential: null, // Ollama doesn't require credentials
    credentialPlaceholder: null,
    configurationFields: const [
      ConfigurationField(
        key: 'base_url',
        label: 'Base URL',
        type: ConfigurationFieldType.text,
        required: true,
        defaultValue: 'http://localhost:11434/api',
        description: 'The base URL of your Ollama server',
      ),
      ConfigurationField(
        key: 'truncate',
        label: 'Truncate Input',
        type: ConfigurationFieldType.boolean,
        description:
            'Truncate input text that exceeds the context length (recommended)',
        defaultValue: 'true',
      ),
    ],
  );

  @override
  EmbeddingProvider createUnconfigured() => EmbeddingProvider(
    definition: definition,
    connectionState: const ProviderConnectionState.unconfigured(),
  );

  @override
  Future<EmbeddingProvider> createFromConfig(
    EmbeddingProviderConfig config,
  ) async {
    try {
      final operations = OllamaOperations(config: config);

      // Test the connection
      final validationResult = await operations.testConnection();
      if (!validationResult.isValid) {
        return EmbeddingProvider(
          definition: definition,
          connectionState: ProviderConnectionState.error(
            config: config,
            error: validationResult.errors.join(', '),
          ),
        );
      }

      return EmbeddingProvider(
        definition: definition,
        connectionState: ProviderConnectionState.connected(config: config),
        operations: operations,
      );
    } catch (e) {
      return EmbeddingProvider(
        definition: definition,
        connectionState: ProviderConnectionState.error(
          config: config,
          error: e.toString(),
        ),
      );
    }
  }

  @override
  Future<ValidationResult> validateConfig(
    EmbeddingProviderConfig config,
  ) async {
    try {
      final operations = OllamaOperations(config: config);
      return await operations.testConnection();
    } catch (e) {
      return ValidationResult.invalid([e.toString()]);
    }
  }
}

class OllamaOperations implements ProviderOperations {
  OllamaOperations({
    required EmbeddingProviderConfig config,
    http.Client? client,
  }) : _config = config,
       _httpClient = client ?? http.Client() {
    final baseUrl = config.settings['base_url'] as String;
    _ollama = OllamaClient(baseUrl: baseUrl, client: _httpClient);
  }

  late final OllamaClient _ollama;
  final http.Client _httpClient;
  final EmbeddingProviderConfig _config;

  @override
  Future<Map<String, EmbeddingModel>> listAvailableModels() async {
    final response = await _ollama.listModels();
    final models = <String, EmbeddingModel>{};

    for (final model in response.models ?? <Model>[]) {
      final modelName = model.model;
      if (modelName != null && modelName.isNotEmpty) {
        if (_isEmbeddingModel(modelName)) {
          models[modelName] = EmbeddingModel(
            id: modelName,
            providerId: _config.id,
            name: _formatModelName(modelName),
            description: 'Ollama embedding model: $modelName',
            vectorType: VectorType.float32,
            dimensions: _estimateDimensions(modelName),
          );
        }
      }
    }

    return models;
  }

  @override
  Future<ValidationResult> testConnection() async {
    try {
      // Try to get the Ollama version to test connectivity
      await _ollama.getVersion();
      return ValidationResult.valid();
    } on RetryableException catch (e) {
      return ValidationResult.invalid(['Connection failed: ${e.message}']);
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.toLowerCase().contains('connection refused') ||
          errorMessage.toLowerCase().contains('failed to connect')) {
        return ValidationResult.invalid([
          'Cannot connect to Ollama server. Please ensure Ollama is running and accessible at the configured URL.',
        ]);
      }
      return ValidationResult.invalid(['Unexpected error: $e']);
    }
  }

  @override
  Future<List<List<double>>> generateEmbeddings({
    required String modelId,
    required Map<String, String> texts,
    CancellationToken? cancellationToken,
  }) async {
    if (texts.isEmpty) return [];

    final model = modelId;
    final embeddings = <List<double>>[];

    try {
      // Process each text individually as Ollama's current API handles single inputs
      for (final text in texts.values) {
        final response = await _ollama.generateEmbedding(
          request: GenerateEmbeddingRequest(model: model, prompt: text),
        );

        if (response.embedding != null) {
          embeddings.add(response.embedding!);
        }
      }

      return embeddings;
    } catch (e) {
      final errorMessage = e.toString();

      // Handle model not found error
      if (errorMessage.toLowerCase().contains('model') &&
          (errorMessage.toLowerCase().contains('not found') ||
              errorMessage.toLowerCase().contains('not available'))) {
        throw Exception(
          'Model "$model" not found. Please pull the model using: ollama pull $model',
        );
      }

      // Handle server errors
      if (errorMessage.toLowerCase().contains('server error') ||
          errorMessage.toLowerCase().contains('internal error')) {
        throw RetryableException.serviceUnavailable(
          message: 'Ollama server error',
          originalException: Exception(errorMessage),
        );
      }

      // Handle timeout
      if (errorMessage.toLowerCase().contains('timeout')) {
        throw RetryableException.timeout(
          message: 'Ollama request timeout',
          originalException: Exception(errorMessage),
        );
      }

      // All other errors are non-retryable
      throw Exception('Ollama embedding generation failed: $errorMessage');
    }
  }

  @override
  Future<ValidationResult> validateConfiguration() async {
    return await testConnection();
  }

  /// Check if a model name suggests it's an embedding model
  bool _isEmbeddingModel(String modelName) {
    final lowerName = modelName.toLowerCase();
    return lowerName.contains('embed') ||
        lowerName.contains('minilm') ||
        lowerName.contains('e5') ||
        lowerName.contains('bge') ||
        lowerName.contains('gte') ||
        lowerName.contains('nomic');
  }

  /// Format model name for display
  String _formatModelName(String modelName) {
    // Remove tag if present (e.g., "nomic-embed-text:latest" -> "nomic-embed-text")
    final baseName = modelName.split(':').first;

    // Convert kebab-case to title case
    return baseName
        .split('-')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  /// Estimate dimensions based on model name patterns
  int _estimateDimensions(String modelName) {
    final lowerName = modelName.toLowerCase();

    // Common dimension patterns
    if (lowerName.contains('large') || lowerName.contains('1024')) return 1024;
    if (lowerName.contains('base') || lowerName.contains('768')) return 768;
    if (lowerName.contains('small') || lowerName.contains('384')) return 384;
    if (lowerName.contains('mini')) return 384;

    // Model-specific patterns
    if (lowerName.contains('nomic')) return 768;
    if (lowerName.contains('e5')) return 1024;
    if (lowerName.contains('bge-large')) return 1024;
    if (lowerName.contains('bge-base')) return 768;
    if (lowerName.contains('bge-small')) return 384;

    // Default fallback
    return 768;
  }
}

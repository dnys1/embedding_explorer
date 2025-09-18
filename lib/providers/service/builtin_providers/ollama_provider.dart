import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
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
    defaultSettings: const {'base_url': 'http://localhost:11434/api'},
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

  static final Logger _logger = Logger('OllamaOperations');

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
        // Generate embedding to see if it can generate embeddings and
        // try to infer dimensions
        try {
          final embeddingResponse = await _ollama.generateEmbedding(
            request: GenerateEmbeddingRequest(model: modelName, prompt: 'test'),
          );
          if (embeddingResponse.embedding case final embedding?) {
            models[modelName] = EmbeddingModel(
              id: modelName,
              providerId: _config.id,
              name: _formatModelName(modelName),
              description: 'Ollama embedding model: $modelName',
              vectorType: _getVectorType(model.details ?? ModelDetails()),
              dimensions: embedding.length,
            );
          }
        } catch (_) {
          _logger.warning(
            'Failed to generate embedding for model $modelName, skipping.',
          );
          continue; // Not an embedding model or failed to generate
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

    // Process each text individually as Ollama's current API handles single inputs
    for (final text in texts.values) {
      final response = await _ollama.generateEmbedding(
        request: GenerateEmbeddingRequest(model: model, prompt: text),
      );
      embeddings.add(response.embedding!);
    }

    return embeddings;
  }

  @override
  Future<ValidationResult> validateConfiguration() async {
    return await testConnection();
  }

  VectorType _getVectorType(ModelDetails details) {
    return switch (details.quantizationLevel) {
      'F16' => VectorType.float16,
      'F32' => VectorType.float32,
      'F64' => VectorType.float64,
      'BF16' => VectorType.bfloat16,
      'F8' => VectorType.float8,
      _ => VectorType.float32, // Default to float32 if unknown
    };
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
}

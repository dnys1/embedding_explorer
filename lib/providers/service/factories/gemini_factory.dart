import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../../../common/ui/fa_icon.dart';
import '../../../configurations/model/embedding_tables.dart';
import '../../../credentials/model/credential.dart';
import '../../../util/cancellation_token.dart';
import '../../../util/retryable_exception.dart';
import '../../model/embedding_provider.dart';
import '../../model/embedding_provider_config.dart';
import '../../model/provider_factory.dart';

/// Google Gemini provider factory
class GeminiFactory implements ProviderFactory {
  const GeminiFactory();

  @override
  ProviderDefinition get definition => ProviderDefinition(
    type: EmbeddingProviderType.gemini,
    displayName: 'Google Gemini',
    description: 'Google Gemini embedding models for text understanding',
    icon: FaIcons.brands.google,
    knownModels: const {
      'text-embedding-004': EmbeddingModel(
        id: 'text-embedding-004',
        providerId: 'gemini',
        name: 'Text Embedding 004',
        description: 'Latest Gemini embedding model with high performance',
        vectorType: VectorType.float32,
        dimensions: 768,
        maxInputTokens: 2048,
        costPer1kTokens: 0.0000125,
      ),
      'embedding-001': EmbeddingModel(
        id: 'embedding-001',
        providerId: 'gemini',
        name: 'Embedding 001',
        description: 'Previous generation Gemini embedding model',
        vectorType: VectorType.float32,
        dimensions: 768,
        maxInputTokens: 2048,
        costPer1kTokens: 0.0000125,
      ),
    },
    defaultSettings: const {
      'model': 'text-embedding-004',
      'task_type': 'RETRIEVAL_DOCUMENT',
    },
    requiredCredential: CredentialType.apiKey,
    credentialPlaceholder: 'AIza...',
    configurationFields: const [
      ConfigurationField(
        key: 'model',
        label: 'Model',
        type: ConfigurationFieldType.dropdown,
        required: true,
        options: ['text-embedding-004', 'embedding-001'],
        defaultValue: 'text-embedding-004',
      ),
      ConfigurationField(
        key: 'task_type',
        label: 'Task Type',
        type: ConfigurationFieldType.dropdown,
        description: 'The intended use case for the embeddings',
        options: [
          'RETRIEVAL_QUERY',
          'RETRIEVAL_DOCUMENT',
          'SEMANTIC_SIMILARITY',
          'CLASSIFICATION',
          'CLUSTERING',
        ],
        defaultValue: 'RETRIEVAL_DOCUMENT',
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
      final credential = config.credential;
      if (credential is! ApiKeyCredential || credential.apiKey.isEmpty) {
        return EmbeddingProvider(
          definition: definition,
          connectionState: ProviderConnectionState.partiallyConfigured(
            config: config,
            missingRequirements: ['Valid API key required'],
          ),
        );
      }

      final operations = GeminiOperations(
        config: config,
        credential: credential,
      );

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
    final credential = config.credential;
    if (credential is! ApiKeyCredential || credential.apiKey.isEmpty) {
      return ValidationResult.invalid(['Valid API key required']);
    }

    try {
      final operations = GeminiOperations(
        config: config,
        credential: credential,
      );
      return await operations.testConnection();
    } catch (e) {
      return ValidationResult.invalid([e.toString()]);
    }
  }
}

class GeminiOperations implements ProviderOperations {
  GeminiOperations({
    required EmbeddingProviderConfig config,
    required ApiKeyCredential credential,
    http.Client? client,
  }) : _config = config,
       _credential = credential,
       _httpClient = client ?? http.Client();

  static final Uri _baseUrl = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/',
  );
  static final Logger _logger = Logger('GeminiOperations');

  final EmbeddingProviderConfig _config;
  final ApiKeyCredential _credential;
  final http.Client _httpClient;

  @override
  Future<Map<String, EmbeddingModel>> listAvailableModels() async {
    try {
      final response = await _makeRequest(endpoint: './models', method: 'GET');

      if (response['models'] is! List) {
        throw StateError('Invalid response format from Gemini models API');
      }

      final models = <String, EmbeddingModel>{};
      for (final model in response['models'] as List) {
        if (model is! Map<String, dynamic>) continue;

        final name = model['name'] as String?;
        if (name == null) continue;

        // Extract model ID from full name (e.g., "models/text-embedding-004" -> "text-embedding-004")
        final id = name.split('/').last;
        if (!id.contains('embedding')) continue;

        models[id] = EmbeddingModel(
          id: id,
          providerId: _config.id,
          vectorType: VectorType.float32,
          name: model['displayName'] as String? ?? id,
          description:
              model['description'] as String? ?? 'Gemini embedding model',
          dimensions: 768, // Gemini models typically use 768 dimensions
        );
      }

      return models.isNotEmpty
          ? models
          : const GeminiFactory().definition.knownModels;
    } catch (e) {
      _logger.warning('Failed to list Gemini models, using known models', e);
      return const GeminiFactory().definition.knownModels;
    }
  }

  @override
  Future<ValidationResult> testConnection() async {
    try {
      await _makeRequest(endpoint: './models', method: 'GET');
      return ValidationResult.valid();
    } on RetryableException catch (e) {
      return ValidationResult.invalid(['Connection failed: ${e.message}']);
    } catch (e) {
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

    // Gemini API requires individual requests for each text
    final response = await _makeRequest(
      endpoint: './models/$modelId:batchEmbedContents',
      method: 'POST',
      body: {
        'requests': [
          for (final text in texts.values)
            {
              'model': 'models/$modelId',
              'content': {
                'parts': [
                  {'text': text},
                ],
              },
              'taskType': _config.settings['task_type'] ?? 'RETRIEVAL_DOCUMENT',
              // 'outputDimensionality': 768, TODO: custom dims
            },
        ],
      },
      cancellationToken: cancellationToken,
    );

    if (response case {'embeddings': final List<Object?> embeddingsContent}) {
      return embeddingsContent
          .cast<Map<Object?, Object?>>()
          .map((it) => (it['values'] as List).cast<double>())
          .toList(growable: false);
    }
    throw StateError('Invalid response format from Gemini embeddings API');
  }

  @override
  Future<ValidationResult> validateConfiguration() async {
    return await testConnection();
  }

  /// Parses retry-after information from Gemini error response headers or body
  Duration _parseRetryAfterFromResponse(
    http.BaseResponse response,
    String errorText,
  ) {
    // Default to 60 seconds if parsing fails
    const defaultRetry = Duration(seconds: 60);

    // First check for Retry-After header
    final retryAfterHeader = response.headers['Retry-After'];
    if (retryAfterHeader != null) {
      final seconds = int.tryParse(retryAfterHeader);
      if (seconds != null) {
        return Duration(seconds: seconds);
      }
    }

    // Check for quota information in response body
    try {
      final errorData = jsonDecode(errorText) as Map<String, dynamic>;
      final error = errorData['error'];
      if (error is Map<String, dynamic>) {
        // Check for quota reset time or similar fields
        final status = error['status'] as String?;
        if (status == 'RESOURCE_EXHAUSTED') {
          // Return a longer delay for quota exhaustion
          return const Duration(minutes: 1);
        }
      }
    } catch (e) {
      _logger.warning('Failed to parse retry-after from response body', e);
    }

    return defaultRetry;
  }

  Future<Map<String, dynamic>> _makeRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    CancellationToken? cancellationToken,
  }) async {
    final url = _baseUrl.resolve(endpoint);

    final request = http.AbortableRequest(
      method,
      url,
      abortTrigger: cancellationToken?.asFuture,
    );
    request.headers['x-goog-api-key'] = _credential.apiKey;

    if (method != 'GET') {
      assert(body != null);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.StreamedResponse response;
    try {
      response = await _httpClient.send(request);
    } on http.RequestAbortedException {
      if (cancellationToken != null) {
        cancellationToken.throwIfCancelled();
      }
      rethrow;
    }
    final responseText = await response.stream.bytesToString();

    final statusCode = response.statusCode;
    if (statusCode < 200 || statusCode >= 300) {
      final errorText = responseText;

      // Handle rate limiting (429) as retryable
      if (statusCode == 429) {
        // Parse retry information from response headers or body
        final retryAfter = _parseRetryAfterFromResponse(response, errorText);

        throw RetryableException.rateLimited(
          message: 'Gemini API rate limited',
          retryAfterSeconds: retryAfter.inSeconds,
          originalException: Exception(
            'Gemini API request failed ($statusCode): $errorText',
          ),
        );
      }

      // Handle temporary server errors (5xx) as retryable
      if (statusCode >= 500 && statusCode < 600) {
        throw RetryableException.serviceUnavailable(
          message: 'Gemini API server error ($statusCode)',
          originalException: Exception(
            'Gemini API request failed ($statusCode): $errorText',
          ),
        );
      }

      // Handle timeout errors as retryable
      if (errorText.toLowerCase().contains('timeout')) {
        throw RetryableException.timeout(
          message: 'Gemini API timeout',
          originalException: Exception(
            'Gemini API request failed ($statusCode): $errorText',
          ),
        );
      }

      // All other errors are non-retryable
      throw Exception('Gemini API request failed ($statusCode): $errorText');
    }

    return jsonDecode(responseText) as Map<String, dynamic>;
  }
}

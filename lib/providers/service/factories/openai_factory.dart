import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../../../common/ui/fa_icon.dart';
import '../../../credentials/model/credential.dart';
import '../../../util/retryable_exception.dart';
import '../../model/embedding_provider.dart';
import '../../model/embedding_provider_config.dart';
import '../../model/provider_factory.dart';

/// OpenAI provider factory
class OpenAIFactory implements ProviderFactory {
  const OpenAIFactory();

  @override
  ProviderDefinition get definition => ProviderDefinition(
    type: EmbeddingProviderType.openai,
    displayName: 'OpenAI',
    description:
        'OpenAI embedding models including text-embedding-3-small and text-embedding-3-large',
    icon: FaIcons.brands.openai,
    knownModels: const {
      'text-embedding-3-small': EmbeddingModel(
        id: 'text-embedding-3-small',
        name: 'Text Embedding 3 Small',
        description: 'Most affordable embedding model with good performance',
        dimensions: 1536,
        maxInputTokens: 8192,
        costPer1kTokens: 0.00002,
      ),
      'text-embedding-3-large': EmbeddingModel(
        id: 'text-embedding-3-large',
        name: 'Text Embedding 3 Large',
        description: 'Highest performance embedding model',
        dimensions: 3072,
        maxInputTokens: 8192,
        costPer1kTokens: 0.00013,
      ),
      'text-embedding-ada-002': EmbeddingModel(
        id: 'text-embedding-ada-002',
        name: 'Text Embedding Ada 002',
        description: 'Previous generation embedding model (legacy)',
        dimensions: 1536,
        maxInputTokens: 8192,
        costPer1kTokens: 0.0001,
      ),
    },
    defaultSettings: const {
      'model': 'text-embedding-3-small',
      'dimensions': 1536,
      'encoding_format': 'float',
    },
    requiredCredential: CredentialType.apiKey,
    credentialPlaceholder: 'sk-...',
    configurationFields: const [
      ConfigurationField(
        key: 'model',
        label: 'Model',
        type: ConfigurationFieldType.dropdown,
        required: true,
        options: [
          'text-embedding-3-small',
          'text-embedding-3-large',
          'text-embedding-ada-002',
        ],
        defaultValue: 'text-embedding-3-small',
      ),
      ConfigurationField(
        key: 'dimensions',
        label: 'Dimensions',
        type: ConfigurationFieldType.number,
        description: 'The number of dimensions for the output embeddings',
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

      final operations = OpenAIOperations(
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
      final operations = OpenAIOperations(
        config: config,
        credential: credential,
      );
      return await operations.testConnection();
    } catch (e) {
      return ValidationResult.invalid([e.toString()]);
    }
  }
}

class OpenAIOperations implements ProviderOperations {
  OpenAIOperations({
    required this.config,
    required this.credential,
    http.Client? client,
  }) : client = client ?? http.Client();

  static final Uri _baseUrl = Uri.parse('https://api.openai.com/v1/');
  static final Logger _logger = Logger('OpenAIOperations');

  final http.Client client;
  final EmbeddingProviderConfig config;
  final ApiKeyCredential credential;

  @override
  Future<Map<String, EmbeddingModel>> listAvailableModels() async {
    final response = await _makeRequest(
      apiKey: credential.apiKey,
      endpoint: './models',
      method: 'GET',
    );

    if (response['data'] is! List) {
      throw StateError('Invalid response format from OpenAI models API');
    }

    final models = <String, EmbeddingModel>{};
    for (final model in response['data'] as List) {
      if (model is! Map<String, dynamic>) continue;

      final id = model['id'] as String?;
      if (id == null || !id.startsWith('text-embedding')) continue;

      models[id] = EmbeddingModel(
        id: id,
        name: id,
        description: 'OpenAI embedding model',
        dimensions: _getDefaultDimensions(id),
      );
    }

    return models.isNotEmpty
        ? models
        : const OpenAIFactory().definition.knownModels;
  }

  int _getDefaultDimensions(String modelId) {
    switch (modelId) {
      case 'text-embedding-3-large':
        return 3072;
      case 'text-embedding-3-small':
      case 'text-embedding-ada-002':
      default:
        return 1536;
    }
  }

  @override
  Future<ValidationResult> testConnection() async {
    try {
      await _makeRequest(
        apiKey: credential.apiKey,
        endpoint: './models',
        method: 'GET',
      );
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
    required List<String> texts,
  }) async {
    if (texts.isEmpty) return [];

    final response = await _makeRequest(
      apiKey: credential.apiKey,
      endpoint: './embeddings',
      method: 'POST',
      body: {'model': modelId, 'input': texts, 'encoding_format': 'float'},
    );

    if (response['data'] is! List) {
      throw StateError('Invalid response format from OpenAI embeddings API');
    }

    final embeddings = <List<double>>[];
    for (final item in response['data'] as List) {
      if (item is! Map<String, dynamic>) continue;

      final embedding = item['embedding'];
      if (embedding is List) {
        embeddings.add(embedding.cast<double>());
      }
    }

    return embeddings;
  }

  @override
  Future<ValidationResult> validateConfiguration() async {
    return await testConnection();
  }

  /// Parses retry-after information from OpenAI error response body
  Duration _parseRetryAfterFromBody(String errorText) {
    // Default to 60 seconds if parsing fails
    const defaultRetry = Duration(seconds: 60);

    try {
      final errorData = jsonDecode(errorText) as Map<String, dynamic>;
      final error = errorData['error'];
      if (error is! Map<String, dynamic>) {
        return defaultRetry;
      }

      // Check for resets_in_seconds field
      final resetsInSeconds = (error['resets_in_seconds'] as num?)?.toInt();
      if (resetsInSeconds != null) {
        return Duration(seconds: resetsInSeconds);
      }

      final message = error['message'] as String?;
      if (message == null) {
        return defaultRetry;
      }

      // Parse from message using regex like "Please try again in 1.898s"
      final retryMatch = RegExp(
        r'Please try again in (\d+(?:\.\d+)?)(s|ms)',
      ).firstMatch(message);
      if (retryMatch != null) {
        final value = double.parse(retryMatch.group(1)!);
        final unit = retryMatch.group(2)!;

        if (unit == 's') {
          return Duration(milliseconds: (value * 1000).round());
        } else if (unit == 'ms') {
          return Duration(milliseconds: value.round());
        }
      }
    } catch (e) {
      _logger.warning('Failed to parse retry-after from response body', e);
    }

    return defaultRetry;
  }

  Future<Map<String, dynamic>> _makeRequest({
    required String apiKey,
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    final url = _baseUrl.resolve(endpoint);

    try {
      final request = http.Request(method, url);
      request.headers['Authorization'] = 'Bearer $apiKey';

      if (method != 'GET') {
        assert(body != null);
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(body);
      }

      final response = await client.send(request);
      final responseText = await response.stream.bytesToString();

      final statusCode = response.statusCode;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorText = responseText;

        // Handle rate limiting (429) as retryable
        if (statusCode == 429) {
          // Parse retry information from response body
          final retryAfter = _parseRetryAfterFromBody(errorText);

          throw RetryableException.rateLimited(
            message: 'OpenAI API rate limited',
            retryAfterSeconds: retryAfter.inSeconds,
            originalException: Exception(
              'OpenAI API request failed ($statusCode): $errorText',
            ),
          );
        }

        // Handle temporary server errors (5xx) as retryable
        if (statusCode >= 500 && statusCode < 600) {
          throw RetryableException.serviceUnavailable(
            message: 'OpenAI API server error ($statusCode)',
            originalException: Exception(
              'OpenAI API request failed ($statusCode): $errorText',
            ),
          );
        }

        // Handle timeout errors as retryable
        if (errorText.toLowerCase().contains('timeout')) {
          throw RetryableException.timeout(
            message: 'OpenAI API timeout',
            originalException: Exception(
              'OpenAI API request failed ($statusCode): $errorText',
            ),
          );
        }

        // All other errors are non-retryable
        throw Exception('OpenAI API request failed ($statusCode): $errorText');
      }

      return jsonDecode(responseText) as Map<String, dynamic>;
    } catch (e) {
      _logger.warning('OpenAI API request failed', e);
      rethrow;
    }
  }
}

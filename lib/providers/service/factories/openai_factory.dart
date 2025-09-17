import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart' as openai show EmbeddingModel;
import 'package:openai_dart/openai_dart.dart' hide EmbeddingModel, Error;

import '../../../common/ui/fa_icon.dart';
import '../../../configurations/model/embedding_tables.dart';
import '../../../credentials/model/credential.dart';
import '../../../util/cancellation_token.dart';
import '../../../util/retryable_exception.dart';
import '../../model/embedding_provider.dart';
import '../../model/embedding_provider_config.dart';
import '../../model/provider_factory.dart';

/// OpenAI provider factory
class OpenAIFactory implements ProviderFactory {
  const OpenAIFactory();

  static double _calculateCost({required double pagesPerDollar}) {
    const tokensPerPage = 800;
    return 1 / (pagesPerDollar * tokensPerPage) * 1000;
  }

  static final Map<String, EmbeddingModel> knownModels = {
    'text-embedding-3-small': EmbeddingModel(
      id: 'text-embedding-3-small',
      providerId: 'openai',
      name: 'Text Embedding 3 Small',
      description: 'Most affordable embedding model with good performance',
      vectorType: VectorType.float32,
      dimensions: 1536,
      maxInputTokens: 8192,
      costPer1kTokens: _calculateCost(pagesPerDollar: 62_500),
    ),
    'text-embedding-3-large': EmbeddingModel(
      id: 'text-embedding-3-large',
      providerId: 'openai',
      name: 'Text Embedding 3 Large',
      description: 'Highest performance embedding model',
      vectorType: VectorType.float32,
      dimensions: 3072,
      maxInputTokens: 8192,
      costPer1kTokens: _calculateCost(pagesPerDollar: 9_615),
    ),
  };

  @override
  ProviderDefinition get definition => ProviderDefinition(
    type: EmbeddingProviderType.openai,
    displayName: 'OpenAI',
    description:
        'OpenAI embedding models including text-embedding-3-small and text-embedding-3-large',
    icon: FaIcons.brands.openai,
    knownModels: knownModels,
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
    required EmbeddingProviderConfig config,
    required ApiKeyCredential credential,
    http.Client? client,
  }) : _config = config,
       _httpClient = client ?? http.Client(),
       _credential = credential {
    _openai = OpenAIClient(apiKey: credential.apiKey, client: _httpClient);
  }

  static final Logger _logger = Logger('OpenAIOperations');
  static final Uri _baseUri = Uri.parse('https://api.openai.com/v1/');

  late final OpenAIClient _openai;
  final http.Client _httpClient;
  final ApiKeyCredential _credential;
  final EmbeddingProviderConfig _config;

  @override
  Future<Map<String, EmbeddingModel>> listAvailableModels() async {
    return {
      for (final entry in OpenAIFactory.knownModels.entries)
        entry.key: entry.value.copyWith(providerId: _config.id),
    };
  }

  @override
  Future<ValidationResult> testConnection() async {
    try {
      await _openai.listModels();
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
    assert(texts.isNotEmpty, 'No texts provided for embedding generation');

    final response = await _makeRequest(
      method: 'POST',
      path: './embeddings',
      body: CreateEmbeddingRequest(
        model: openai.EmbeddingModel.modelId(modelId),
        input: EmbeddingInput.listString(texts.values.toList(growable: false)),
        encodingFormat: EmbeddingEncodingFormat.float,
        // dimensions:  // TODO: custom dims
      ).toJson(),
      fromJson: CreateEmbeddingResponse.fromJson,
      cancellationToken: cancellationToken,
    );
    return response.data
        .map((it) => it.embeddingVector)
        .toList(growable: false);
  }

  @override
  Future<ValidationResult> validateConfiguration() async {
    return await testConnection();
  }

  Future<T> _makeRequest<T>({
    required String method,
    required String path,
    required Map<String, Object?> body,
    required T Function(Map<String, Object?> json) fromJson,
    required CancellationToken? cancellationToken,
  }) async {
    final request = http.AbortableRequest(
      method,
      _baseUri.resolve(path),
      abortTrigger: cancellationToken?.asFuture,
    );
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_credential.apiKey}',
    });
    request.body = jsonEncode(body);

    final http.StreamedResponse response;
    try {
      response = await _httpClient.send(request);
    } on http.RequestAbortedException {
      if (cancellationToken != null) {
        cancellationToken.throwIfCancelled();
      }
      rethrow;
    }
    final responseBody = await response.stream.bytesToString();

    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      return fromJson(jsonDecode(responseBody) as Map<String, dynamic>);
    }

    final errorText = responseBody;

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
}

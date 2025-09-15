import 'dart:convert';
import 'dart:js_interop';

import 'package:aws_common/aws_common.dart';
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

import '../../common/ui/fa_icon.dart';
import '../../credentials/model/credential.dart';
import '../../util/retryable_exception.dart';
import '../model/embedding_provider.dart';
import '../model/embedding_provider_config.dart';

/// Google Gemini embedding provider implementation
class GeminiProvider implements EmbeddingProviderTemplate {
  const GeminiProvider();

  @override
  EmbeddingProviderType get type => EmbeddingProviderType.gemini;

  @override
  String get displayName => 'Google Gemini';

  @override
  String get description =>
      'Google Gemini embedding models for text understanding';

  @override
  FaIconData get icon => FaIcons.brands.google;

  @override
  Map<String, dynamic> get defaultSettings => const {
    'model': 'text-embedding-004',
    'task_type': 'RETRIEVAL_DOCUMENT',
  };

  @override
  CredentialType? get requiredCredential => CredentialType.apiKey;

  @override
  Map<String, EmbeddingModel> get knownModels => const {
    'text-embedding-004': EmbeddingModel(
      id: 'text-embedding-004',
      name: 'Text Embedding 004',
      description: 'Latest Gemini embedding model with high performance',
      dimensions: 768,
      maxInputTokens: 2048,
      costPer1kTokens: 0.0000125, // Free tier available
    ),
    'embedding-001': EmbeddingModel(
      id: 'embedding-001',
      name: 'Embedding 001',
      description: 'First generation Gemini embedding model',
      dimensions: 768,
      maxInputTokens: 2048,
      costPer1kTokens: 0.0000125,
    ),
  };

  @override
  Future<ConfiguredEmbeddingProvider> configure(
    EmbeddingProviderConfig config,
  ) async {
    final credential = config.credential;
    if (credential is! ApiKeyCredential || credential.apiKey.isEmpty) {
      throw ArgumentError('GeminiProvider requires an API key credential');
    }
    return _ConfiguredGeminiProvider(config, credential: credential);
  }
}

final class _ConfiguredGeminiProvider extends GeminiProvider
    implements ConfiguredEmbeddingProvider {
  _ConfiguredGeminiProvider(this.config, {required this.credential});

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  static final Logger _logger = Logger('GeminiProvider');

  @override
  final EmbeddingProviderConfig config;

  final ApiKeyCredential credential;

  @override
  Future<Map<String, EmbeddingModel>> listAvailableModels() async {
    final response = await _makeRequest(
      apiKey: credential.apiKey,
      endpoint: '/models',
      method: 'GET',
    );

    final models = (response['models'] as List)
        .cast<Map<String, dynamic>>()
        .where(
          (model) =>
              (model['name'] as String).contains('embedding') ||
              (model['supportedGenerationMethods'] as List).contains(
                'embedContent',
              ),
        )
        .map(
          (model) => MapEntry(
            (model['name'] as String).split('/').last,
            _mapGeminiModelToEmbeddingModel(model),
          ),
        );
    return Map.fromEntries(models);
  }

  @override
  Future<bool> testConnection() async {
    try {
      await listAvailableModels();
      return true;
    } catch (e, st) {
      _logger.warning('Gemini connection test failed', e, st);
      return false;
    }
  }

  @override
  Future<List<List<double>>> generateEmbeddings({
    required String modelId,
    required List<String> texts,
  }) async {
    // Gemini has a batch limit, so we may need to split large requests
    const batchSize = 100;
    final results = <List<double>>[];

    for (int i = 0; i < texts.length; i += batchSize) {
      final batch = texts.skip(i).take(batchSize).toList();

      final body = {
        'requests': batch
            .map(
              (text) => {
                'model': 'models/$modelId',
                'content': {
                  'parts': [
                    {'text': text},
                  ],
                },
              },
            )
            .toList(),
      };

      final response = await _makeRequest(
        apiKey: credential.apiKey,
        endpoint: '/models/$modelId:batchEmbedContents',
        body: body,
      );

      final embeddings = response['embeddings'] as List;
      for (final embedding in embeddings) {
        final values = (embedding['values'] as List).cast<double>();
        results.add(values);
      }
    }

    return results;
  }

  EmbeddingModel _mapGeminiModelToEmbeddingModel(
    Map<String, dynamic> apiModel,
  ) {
    final modelName = apiModel['name'] as String;
    // Extract model ID from full name
    final modelId = modelName.split('/').last;

    if (knownModels[modelId] case final knownModel?) {
      return knownModel;
    }

    // For unknown models, provide reasonable defaults
    return EmbeddingModel(
      id: modelId,
      name: modelId
          .replaceAll('-', ' ')
          .split(' ')
          .map((w) => w.capitalized)
          .join(' '),
      description:
          apiModel['description'] as String? ?? 'Gemini embedding model',
      dimensions: 768, // Default dimension for Gemini
      maxInputTokens: 2048,
    );
  }

  /// Parses retry-after information from Gemini error response headers or body
  Duration _parseRetryAfterFromResponse(
    web.Response response,
    String errorText,
  ) {
    // Default to 60 seconds if parsing fails
    const defaultRetry = Duration(seconds: 60);

    // First check for Retry-After header
    final retryAfterHeader = response.headers.get('Retry-After');
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
    required String apiKey,
    required String endpoint,
    Map<String, dynamic>? body,
    String method = 'POST',
  }) async {
    final url = '$_baseUrl$endpoint';

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-goog-api-key': apiKey,
    };

    final requestInit = web.RequestInit(
      method: method,
      headers: headers.jsify()! as JSObject,
    );

    // Only add body for non-GET requests
    if (method != 'GET') {
      assert(body != null);
      requestInit.body = jsonEncode(body).toJS;
    }

    final response = await web.window.fetch(url.toJS, requestInit).toDart;

    if (!response.ok) {
      final errorText = await response.text().toDart.then((e) => e.toDart);
      final statusCode = response.status;

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

    final responseText = await response.text().toDart;
    final responseData =
        jsonDecode(responseText.toDart) as Map<String, dynamic>;

    return responseData;
  }
}

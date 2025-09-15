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

/// OpenAI embedding provider implementation
class OpenAIProvider implements EmbeddingProviderTemplate {
  const OpenAIProvider();

  @override
  EmbeddingProviderType get type => EmbeddingProviderType.openai;

  @override
  String get displayName => 'OpenAI';

  @override
  String get description =>
      'OpenAI embedding models including text-embedding-3-small and text-embedding-3-large';

  @override
  FaIconData get icon => FaIcons.brands.openai;

  @override
  Map<String, dynamic> get defaultSettings => const {
    'model': 'text-embedding-3-small',
    'dimensions': 1536,
    'encoding_format': 'float',
  };

  @override
  CredentialType? get requiredCredential => CredentialType.apiKey;

  @override
  Map<String, EmbeddingModel> get knownModels => const {
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
  };

  @override
  Future<ConfiguredEmbeddingProvider> configure(
    EmbeddingProviderConfig config,
  ) async {
    final credential = config.credential;
    if (credential is! ApiKeyCredential || credential.apiKey.isEmpty) {
      throw ArgumentError(
        'OpenAIProvider requires an ApiKeyCredential for configuration',
      );
    }
    return _ConfiguredOpenAIProvider(config, credential: credential);
  }
}

final class _ConfiguredOpenAIProvider extends OpenAIProvider
    implements ConfiguredEmbeddingProvider {
  _ConfiguredOpenAIProvider(this.config, {required this.credential});

  static const String _baseUrl = 'https://api.openai.com/v1';

  static final Logger _logger = Logger('OpenAIProvider');

  @override
  final EmbeddingProviderConfig config;

  final ApiKeyCredential credential;

  @override
  Future<Map<String, EmbeddingModel>> listAvailableModels() async {
    final response = await _makeRequest(
      apiKey: credential.apiKey,
      endpoint: '/models',
      body: {},
      method: 'GET',
    );

    final models = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .where((model) => (model['id'] as String).contains('embedding'))
        .map(
          (json) => MapEntry(
            json['id'] as String,
            _mapOpenAIModelToEmbeddingModel(json),
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
      _logger.warning('OpenAI connection test failed', e, st);
      return false;
    }
  }

  @override
  Future<List<List<double>>> generateEmbeddings({
    required String modelId,
    required List<String> texts,
  }) async {
    // OpenAI has a batch limit, so we may need to split large requests
    const batchSize = 100;
    final results = <List<double>>[];

    for (int i = 0; i < texts.length; i += batchSize) {
      final batch = texts.skip(i).take(batchSize).toList();

      final response = await _makeRequest(
        apiKey: credential.apiKey,
        endpoint: '/embeddings',
        body: {'model': modelId, 'input': batch, 'encoding_format': 'float'},
      );

      final data = response['data'] as List;
      for (final item in data) {
        final embedding = (item['embedding'] as List).cast<double>();
        results.add(embedding);
      }
    }

    return results;
  }

  EmbeddingModel _mapOpenAIModelToEmbeddingModel(
    Map<String, dynamic> apiModel,
  ) {
    final modelId = apiModel['id'] as String;
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
      description: 'OpenAI embedding model',
      dimensions: 1536, // Default dimension
    );
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
    required Map<String, dynamic> body,
    String method = 'POST',
  }) async {
    final url = '$_baseUrl$endpoint';

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final requestInit = web.RequestInit(
      method: method,
      headers: headers.jsify()! as JSObject,
    );

    // Only add body for non-GET requests
    if (method != 'GET' && body.isNotEmpty) {
      requestInit.body = jsonEncode(body).toJS;
    }

    final response = await web.window.fetch(url.toJS, requestInit).toDart;

    if (!response.ok) {
      final errorText = await response.text().toDart.then((e) => e.toDart);
      final statusCode = response.status;

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

    final responseText = await response.text().toDart;
    final responseData =
        jsonDecode(responseText.toDart) as Map<String, dynamic>;

    return responseData;
  }
}

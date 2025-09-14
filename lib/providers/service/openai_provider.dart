import 'dart:convert';
import 'dart:js_interop';

import 'package:aws_common/aws_common.dart';
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

import '../../common/ui/fa_icon.dart';
import '../../credentials/model/credential.dart';
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
      final errorText = await response.text().toDart;
      throw Exception(
        'OpenAI API request failed (${response.status}): ${errorText.toDart}',
      );
    }

    final responseText = await response.text().toDart;
    final responseData =
        jsonDecode(responseText.toDart) as Map<String, dynamic>;

    return responseData;
  }
}

import 'dart:convert';
import 'dart:js_interop';

import 'package:aws_common/aws_common.dart';
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

import '../../common/ui/fa_icon.dart';
import '../../credentials/model/credential.dart';
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
    final url = '$_baseUrl/models';

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-goog-api-key': credential.apiKey,
    };

    final response = await web.window
        .fetch(
          url.toJS,
          web.RequestInit(method: 'GET', headers: headers.jsify()! as JSObject),
        )
        .toDart;

    if (!response.ok) {
      final errorText = await response.text().toDart;
      throw Exception(
        'OpenAI API request failed (${response.status}): ${errorText.toDart}',
      );
    }

    final responseText = await response.text().toDart;
    final responseData =
        jsonDecode(responseText.toDart) as Map<String, dynamic>;

    final models = (responseData['models'] as List)
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

      final response = await _makeRequest(
        apiKey: credential.apiKey,
        modelId: modelId,
        texts: batch,
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

  Future<Map<String, dynamic>> _makeRequest({
    required String apiKey,
    required String modelId,
    required List<String> texts,
  }) async {
    final url = '$_baseUrl/models/$modelId:batchEmbedContents';

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-goog-api-key': apiKey,
    };

    final body = {
      'requests': texts
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

    final response = await web.window
        .fetch(
          url.toJS,
          web.RequestInit(
            method: 'POST',
            headers: headers.jsify()! as JSObject,
            body: jsonEncode(body).toJS,
          ),
        )
        .toDart;

    if (!response.ok) {
      final errorText = await response.text().toDart;
      throw Exception(
        'Gemini API request failed (${response.status}): ${errorText.toDart}',
      );
    }

    final responseText = await response.text().toDart;
    final responseData =
        jsonDecode(responseText.toDart) as Map<String, dynamic>;

    return responseData;
  }
}

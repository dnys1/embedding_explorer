import 'dart:convert';
import 'dart:js_interop';

import 'package:aws_common/aws_common.dart';
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

import '../model/model_provider_config.dart';
import 'embedding_provider.dart';

/// Google Gemini embedding provider implementation
class GeminiProvider implements EmbeddingProvider {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  static final Logger _logger = Logger('GeminiProvider');

  static const Map<String, EmbeddingModel> _knownModels = {
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
  String get id => 'gemini';

  @override
  String get displayName => 'Google Gemini';

  @override
  String get description =>
      'Google Gemini embedding models for text understanding';

  @override
  bool get requiresApiKey => true;

  @override
  bool get supportsCustomConfig => false;

  Map<String, EmbeddingModel>? _modelCache;

  @override
  Future<Map<String, EmbeddingModel>> listAvailableModels(
    ModelProviderConfig config,
  ) async {
    if (_modelCache case final cache?) {
      return cache;
    }
    try {
      return _modelCache = await _fetchAvailableModels(config);
    } catch (e) {
      _logger.warning('Failed to fetch Gemini models', e);
      return _knownModels;
    }
  }

  @override
  ValidationResult validateConfig(ModelProviderConfig config) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check API key
    final apiKey = config.credentials['apiKey'];
    if (apiKey == null || apiKey.isEmpty) {
      errors.add('Gemini API key is required');
    } else if (!apiKey.startsWith('AIza')) {
      warnings.add('Gemini API key should start with "AIza"');
    }

    if (errors.isNotEmpty) {
      return ValidationResult.invalid(errors);
    } else if (warnings.isNotEmpty) {
      return ValidationResult.withWarnings(warnings);
    } else {
      return ValidationResult.valid();
    }
  }

  @override
  Future<bool> testConnection(ModelProviderConfig config) async {
    try {
      _modelCache ??= await _fetchAvailableModels(config);
      return true;
    } catch (e) {
      _logger.warning('Gemini connection test failed', e);
      return false;
    }
  }

  @override
  Future<List<List<double>>> generateEmbeddings({
    required String modelId,
    required List<String> texts,
    required ModelProviderConfig config,
  }) async {
    final apiKey = config.credentials['apiKey'];
    if (apiKey == null || apiKey.isEmpty) {
      throw ArgumentError('API key is required to generate embeddings');
    }

    // Gemini has a batch limit, so we may need to split large requests
    const batchSize = 100;
    final results = <List<double>>[];

    for (int i = 0; i < texts.length; i += batchSize) {
      final batch = texts.skip(i).take(batchSize).toList();

      final response = await _makeRequest(
        apiKey: apiKey,
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

  @override
  int getEmbeddingDimension(String modelId) {
    final models = _modelCache ?? _knownModels;
    return models[modelId]!.dimensions;
  }

  Future<Map<String, EmbeddingModel>> _fetchAvailableModels(
    ModelProviderConfig config,
  ) async {
    final apiKey = config.credentials['apiKey']!;
    final url = '$_baseUrl/models';

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-goog-api-key': apiKey,
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

    final responseJson = await response.json().toDart;
    final responseData = (responseJson.dartify() as Map)
        .cast<String, dynamic>();

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

  EmbeddingModel _mapGeminiModelToEmbeddingModel(
    Map<String, dynamic> apiModel,
  ) {
    final modelName = apiModel['name'] as String;
    // Extract model ID from full name
    final modelId = modelName.split('/').last;

    if (_knownModels[modelId] case final knownModel?) {
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

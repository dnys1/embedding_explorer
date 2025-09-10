import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../../models/embedding_provider.dart';

/// Google Gemini embedding provider implementation
class GeminiProvider implements EmbeddingProvider {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

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

  @override
  List<EmbeddingModel> get availableModels => [
    const EmbeddingModel(
      id: 'text-embedding-004',
      name: 'Text Embedding 004',
      description: 'Latest Gemini embedding model with high performance',
      dimensions: 768,
      maxInputTokens: 2048,
      costPer1kTokens: 0.0000125, // Free tier available
    ),
    const EmbeddingModel(
      id: 'embedding-001',
      name: 'Embedding 001',
      description: 'First generation Gemini embedding model',
      dimensions: 768,
      maxInputTokens: 2048,
      costPer1kTokens: 0.0000125,
    ),
  ];

  @override
  ValidationResult validateConfig(Map<String, dynamic> config) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check API key
    final apiKey = config['apiKey'] as String?;
    if (apiKey == null || apiKey.isEmpty) {
      errors.add('Gemini API key is required');
    } else if (!apiKey.startsWith('AIza')) {
      warnings.add('Gemini API key should start with "AIza"');
    }

    // Check model ID
    final modelId = config['modelId'] as String?;
    if (modelId == null || modelId.isEmpty) {
      errors.add('Model selection is required');
    } else if (!availableModels.any((m) => m.id == modelId)) {
      errors.add('Selected model "$modelId" is not available');
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
  Future<bool> testConnection(Map<String, dynamic> config) async {
    try {
      final apiKey = config['apiKey'] as String;
      final modelId = config['modelId'] as String;

      // Test with a simple embedding request
      final response = await _makeRequest(
        apiKey: apiKey,
        modelId: modelId,
        texts: ['test connection'],
      );

      final embeddings = response['embeddings'] as List?;
      return embeddings != null && embeddings.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<List<double>>> generateEmbeddings(
    List<String> texts,
    Map<String, dynamic> config,
  ) async {
    final apiKey = config['apiKey'] as String;
    final modelId = config['modelId'] as String;

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
    final model = availableModels.firstWhere(
      (m) => m.id == modelId,
      orElse: () => availableModels.first,
    );
    return model.dimensions;
  }

  Future<Map<String, dynamic>> _makeRequest({
    required String apiKey,
    required String modelId,
    required List<String> texts,
  }) async {
    final url = '$_baseUrl/models/$modelId:batchEmbedContents?key=$apiKey';

    final headers = <String, String>{'Content-Type': 'application/json'};

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

    try {
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
    } catch (e) {
      throw Exception('Gemini API request failed: $e');
    }
  }
}

import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../../models/embedding_provider.dart';

/// OpenAI embedding provider implementation
class OpenAIProvider implements EmbeddingProvider {
  static const String _baseUrl = 'https://api.openai.com/v1';

  @override
  String get id => 'openai';

  @override
  String get displayName => 'OpenAI';

  @override
  String get description =>
      'OpenAI embedding models including text-embedding-3-small and text-embedding-3-large';

  @override
  bool get requiresApiKey => true;

  @override
  bool get supportsCustomConfig => false;

  @override
  List<EmbeddingModel> get availableModels => [
    const EmbeddingModel(
      id: 'text-embedding-3-small',
      name: 'Text Embedding 3 Small',
      description: 'Most affordable embedding model with good performance',
      dimensions: 1536,
      maxInputTokens: 8192,
      costPer1kTokens: 0.00002,
    ),
    const EmbeddingModel(
      id: 'text-embedding-3-large',
      name: 'Text Embedding 3 Large',
      description: 'Highest performance embedding model',
      dimensions: 3072,
      maxInputTokens: 8192,
      costPer1kTokens: 0.00013,
    ),
    const EmbeddingModel(
      id: 'text-embedding-ada-002',
      name: 'Text Embedding Ada 002',
      description: 'Previous generation embedding model (legacy)',
      dimensions: 1536,
      maxInputTokens: 8192,
      costPer1kTokens: 0.0001,
    ),
  ];

  @override
  ValidationResult validateConfig(Map<String, dynamic> config) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check API key
    final apiKey = config['apiKey'] as String?;
    if (apiKey == null || apiKey.isEmpty) {
      errors.add('OpenAI API key is required');
    } else if (!apiKey.startsWith('sk-')) {
      warnings.add('OpenAI API key should start with "sk-"');
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
        endpoint: '/embeddings',
        body: {
          'model': modelId,
          'input': 'test connection',
          'encoding_format': 'float',
        },
      );

      final data = response['data'] as List?;
      return data != null && data.isNotEmpty;
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

    // OpenAI has a batch limit, so we may need to split large requests
    const batchSize = 100;
    final results = <List<double>>[];

    for (int i = 0; i < texts.length; i += batchSize) {
      final batch = texts.skip(i).take(batchSize).toList();

      final response = await _makeRequest(
        apiKey: apiKey,
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
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final url = '$_baseUrl$endpoint';

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
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
          'OpenAI API request failed (${response.status}): $errorText',
        );
      }

      final responseText = await response.text().toDart;
      final responseData =
          jsonDecode(responseText.toDart) as Map<String, dynamic>;

      return responseData;
    } catch (e) {
      throw Exception('OpenAI API request failed: $e');
    }
  }
}

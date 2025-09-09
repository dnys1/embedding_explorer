import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../../models/embedding_provider.dart';

/// Custom HTTP endpoint embedding provider
class CustomHttpProvider implements EmbeddingProvider {
  @override
  String get id => 'custom-http';

  @override
  String get displayName => 'Custom HTTP Endpoint';

  @override
  String get description =>
      'Configure a custom HTTP endpoint for embedding generation';

  @override
  bool get requiresApiKey => false;

  @override
  bool get supportsCustomConfig => true;

  @override
  List<EmbeddingModel> get availableModels => [
    const EmbeddingModel(
      id: 'custom',
      name: 'Custom Model',
      description: 'Custom embedding model via HTTP endpoint',
      dimensions: 0, // Will be determined at runtime
      maxInputTokens: 0, // User-configured
      costPer1kTokens: 0.0, // User-configured
    ),
  ];

  @override
  ValidationResult validateConfig(Map<String, dynamic> config) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check endpoint URL
    final endpoint = config['endpoint'] as String?;
    if (endpoint == null || endpoint.isEmpty) {
      errors.add('HTTP endpoint URL is required');
    } else {
      try {
        final uri = Uri.parse(endpoint);
        if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
          errors.add('Endpoint must be a valid HTTP/HTTPS URL');
        }
      } catch (e) {
        errors.add('Invalid endpoint URL format');
      }
    }

    // Check request template
    final requestTemplate = config['requestTemplate'] as String?;
    if (requestTemplate == null || requestTemplate.isEmpty) {
      errors.add('Request template is required');
    } else {
      // Check if template contains required placeholder
      if (!requestTemplate.contains('{{texts}}')) {
        warnings.add(
          'Request template should contain {{texts}} placeholder for input texts',
        );
      }
    }

    // Check response path
    final responsePath = config['responsePath'] as String?;
    if (responsePath == null || responsePath.isEmpty) {
      warnings.add(
        'Response path not specified. Will attempt to find embeddings automatically.',
      );
    }

    // Check headers
    final headers = config['headers'] as Map<String, dynamic>?;
    if (headers != null) {
      for (final entry in headers.entries) {
        if (entry.key.isEmpty) {
          warnings.add('Empty header name found');
        }
      }
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
      final result = await generateEmbeddings(['test connection'], config);
      return result.isNotEmpty && result.first.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<List<double>>> generateEmbeddings(
    List<String> texts,
    Map<String, dynamic> config,
  ) async {
    final endpoint = config['endpoint'] as String;
    final requestTemplate = config['requestTemplate'] as String;
    final responsePath = config['responsePath'] as String? ?? 'embeddings';
    final headers = (config['headers'] as Map<String, dynamic>?) ?? {};
    final method = config['method'] as String? ?? 'POST';

    // Process request template
    final requestBody = _processRequestTemplate(requestTemplate, texts, config);

    // Convert headers to the right format
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...headers.map((k, v) => MapEntry(k.toString(), v.toString())),
    };

    try {
      final response = await web.window
          .fetch(
            endpoint.toJS,
            web.RequestInit(
              method: method,
              headers: requestHeaders.jsify()! as JSObject,
              body: jsonEncode(requestBody).toJS,
            ),
          )
          .toDart;

      if (!response.ok) {
        final errorText = await response.text().toDart;
        throw Exception(
          'Custom endpoint request failed (${response.status}): ${errorText.toDart}',
        );
      }

      final responseText = await response.text().toDart;
      final responseData =
          jsonDecode(responseText.toDart) as Map<String, dynamic>;

      // Extract embeddings using response path
      final embeddings = _extractEmbeddings(responseData, responsePath);

      return embeddings;
    } catch (e) {
      throw Exception('Custom endpoint request failed: $e');
    }
  }

  @override
  int getEmbeddingDimension(String modelId) {
    // For custom providers, dimension needs to be determined at runtime
    // or configured by the user
    return 0;
  }

  Map<String, dynamic> _processRequestTemplate(
    String template,
    List<String> texts,
    Map<String, dynamic> config,
  ) {
    var processedTemplate = template;

    // Replace common placeholders
    processedTemplate = processedTemplate.replaceAll(
      '{{texts}}',
      jsonEncode(texts),
    );

    // Replace other config values
    for (final entry in config.entries) {
      if (entry.key != 'requestTemplate' && entry.key != 'responsePath') {
        final placeholder = '{{${entry.key}}}';
        if (processedTemplate.contains(placeholder)) {
          processedTemplate = processedTemplate.replaceAll(
            placeholder,
            jsonEncode(entry.value),
          );
        }
      }
    }

    try {
      return jsonDecode(processedTemplate) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Invalid request template JSON: $e');
    }
  }

  List<List<double>> _extractEmbeddings(
    Map<String, dynamic> response,
    String responsePath,
  ) {
    try {
      // Split path by dots to support nested access
      final pathParts = responsePath.split('.');
      dynamic current = response;

      for (final part in pathParts) {
        if (current is Map<String, dynamic>) {
          current = current[part];
        } else if (current is List && int.tryParse(part) != null) {
          current = current[int.parse(part)];
        } else {
          throw Exception('Invalid response path: $responsePath');
        }
      }

      if (current is List) {
        return current.map((embedding) {
          if (embedding is List) {
            return embedding.cast<double>();
          } else if (embedding is Map<String, dynamic>) {
            // Try common embedding field names
            for (final fieldName in ['embedding', 'vector', 'values', 'data']) {
              if (embedding.containsKey(fieldName)) {
                final values = embedding[fieldName];
                if (values is List) {
                  return values.cast<double>();
                }
              }
            }
          }
          throw Exception('Unexpected embedding format');
        }).toList();
      } else {
        throw Exception('Response path does not point to a list');
      }
    } catch (e) {
      throw Exception('Failed to extract embeddings from response: $e');
    }
  }
}

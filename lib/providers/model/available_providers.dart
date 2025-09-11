import 'model_provider_config.dart';

/// Information about an available model for a provider
class AvailableModel {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> defaultSettings;
  final bool isRecommended;

  const AvailableModel({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultSettings,
    this.isRecommended = false,
  });
}

/// Information about an available model provider
class AvailableProvider {
  final ProviderType type;
  final String name;
  final String description;
  final String icon;
  final List<String> requiredCredentials;
  final Map<String, dynamic> defaultSettings;
  final List<AvailableModel> availableModels;

  const AvailableProvider({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredCredentials,
    required this.defaultSettings,
    required this.availableModels,
  });
}

/// All available model providers that can be configured
class AvailableProviders {
  static const List<AvailableProvider> all = [
    AvailableProvider(
      type: ProviderType.openai,
      name: 'OpenAI',
      description:
          'OpenAI embeddings including text-embedding-ada-002 and text-embedding-3-small/large',
      icon: '🤖',
      requiredCredentials: ['apiKey'],
      defaultSettings: {
        'model': 'text-embedding-3-small',
        'dimensions': 1536,
        'encoding_format': 'float',
      },
      availableModels: [
        AvailableModel(
          id: 'text-embedding-3-small',
          name: 'Text Embedding 3 Small',
          description: 'Latest small embedding model with improved performance',
          defaultSettings: {'dimensions': 1536},
          isRecommended: true,
        ),
        AvailableModel(
          id: 'text-embedding-3-large',
          name: 'Text Embedding 3 Large',
          description: 'Latest large embedding model with highest accuracy',
          defaultSettings: {'dimensions': 3072},
        ),
        AvailableModel(
          id: 'text-embedding-ada-002',
          name: 'Text Embedding Ada 002',
          description: 'Legacy embedding model, still widely used',
          defaultSettings: {'dimensions': 1536},
        ),
      ],
    ),
    AvailableProvider(
      type: ProviderType.gemini,
      name: 'Google Gemini',
      description:
          'Google Gemini embeddings with text-embedding-004 and embedding-001 models',
      icon: '💎',
      requiredCredentials: ['apiKey'],
      defaultSettings: {
        'model': 'text-embedding-004',
        'task_type': 'RETRIEVAL_DOCUMENT',
      },
      availableModels: [
        AvailableModel(
          id: 'text-embedding-004',
          name: 'Text Embedding 004',
          description: 'Latest Gemini embedding model',
          defaultSettings: {'task_type': 'RETRIEVAL_DOCUMENT'},
          isRecommended: true,
        ),
        AvailableModel(
          id: 'embedding-001',
          name: 'Embedding 001',
          description: 'Legacy Gemini embedding model',
          defaultSettings: {'task_type': 'RETRIEVAL_DOCUMENT'},
        ),
      ],
    ),
  ];

  /// Get an available provider by type
  static AvailableProvider? getByType(ProviderType type) {
    try {
      return all.firstWhere((provider) => provider.type == type);
    } catch (e) {
      return null;
    }
  }

  /// Get all provider types
  static List<ProviderType> get allTypes => all.map((p) => p.type).toList();
}

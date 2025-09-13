import '../../common/ui/fa_icon.dart';
import '../../credentials/model/credential.dart';
import '../service/embedding_provider.dart';
import '../service/gemini_provider.dart';
import '../service/openai_provider.dart';
import 'model_provider_config.dart';

/// Information about an available model provider
class AvailableProvider {
  final ProviderType type;
  final String name;
  final String description;
  final FaIconData icon;
  final CredentialType? requiredCredential;
  final Map<String, dynamic> defaultSettings;
  final EmbeddingProvider _provider;

  const AvailableProvider({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredCredential,
    required this.defaultSettings,
    required EmbeddingProvider provider,
  }) : _provider = provider;

  /// Get available models from the provider service
  Future<Map<String, EmbeddingModel>> listAvailableModels(
    ModelProviderConfig config,
  ) async {
    return _provider.listAvailableModels(config);
  }

  /// Get the embedding provider service
  EmbeddingProvider get provider => _provider;
}

/// All available model providers that can be configured
class AvailableProviders {
  static final _openaiProvider = OpenAIProvider();
  static final _geminiProvider = GeminiProvider();

  static final List<AvailableProvider> all = [
    AvailableProvider(
      type: ProviderType.openai,
      name: 'OpenAI',
      description:
          'OpenAI embeddings including text-embedding-ada-002 and text-embedding-3-small/large',
      icon: FaIcons.brands.openai,
      requiredCredential: CredentialType.apiKey,
      defaultSettings: {
        'model': 'text-embedding-3-small',
        'dimensions': 1536,
        'encoding_format': 'float',
      },
      provider: _openaiProvider,
    ),
    AvailableProvider(
      type: ProviderType.gemini,
      name: 'Google Gemini',
      description:
          'Google Gemini embeddings with text-embedding-004 and embedding-001 models',
      icon: FaIcons.brands.google,
      requiredCredential: CredentialType.apiKey,
      defaultSettings: {
        'model': 'text-embedding-004',
        'task_type': 'RETRIEVAL_DOCUMENT',
      },
      provider: _geminiProvider,
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

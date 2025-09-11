import '../../jobs/model/embedding_job.dart';
import 'package:jaspr/jaspr.dart';

import '../../data_sources/model/data_source_config.dart';
import '../../data_sources/model/data_source_settings.dart';
import '../../jobs/model/embedding_job_collection.dart';
import '../../providers/model/custom_provider_template.dart';
import '../../providers/model/model_provider_config.dart';
import '../../templates/model/embedding_template_config.dart';
import '../../util/indexed_db.dart';

/// Global state manager for all configuration collections
class ConfigurationManager with ChangeNotifier {
  static final ConfigurationManager _instance =
      ConfigurationManager._internal();

  factory ConfigurationManager() {
    return _instance;
  }

  ConfigurationManager._internal();

  // Configuration collections
  final DataSourceConfigCollection dataSources = DataSourceConfigCollection();
  final EmbeddingTemplateConfigCollection embeddingTemplates =
      EmbeddingTemplateConfigCollection();
  final ModelProviderConfigCollection modelProviders =
      ModelProviderConfigCollection();
  final CustomProviderTemplateCollection customProviderTemplates =
      CustomProviderTemplateCollection();
  final EmbeddingJobCollection embeddingJobs = EmbeddingJobCollection();

  /// Initialize all collections and load from storage
  Future<void> initialize() async {
    // Initialize IndexedDB first
    await indexedDB.initialize();

    await Future.wait([
      dataSources.loadFromStorage(),
      embeddingTemplates.loadFromStorage(),
      modelProviders.loadFromStorage(),
      customProviderTemplates.loadFromStorage(),
      embeddingJobs.loadFromStorage(),
    ]);

    // Set up change listeners to notify global listeners
    dataSources.addListener(notifyListeners);
    embeddingTemplates.addListener(notifyListeners);
    modelProviders.addListener(notifyListeners);
    customProviderTemplates.addListener(notifyListeners);
    embeddingJobs.addListener(notifyListeners);

    notifyListeners();
  }

  /// Clear all configurations (useful for testing or reset)
  void clearAll() {
    dataSources.clear();
    embeddingTemplates.clear();
    modelProviders.clear();
    customProviderTemplates.clear();
    embeddingJobs.clear();
  }

  /// Get summary statistics
  ConfigurationSummary getSummary() {
    return ConfigurationSummary(
      dataSourceCount: dataSources.length,
      embeddingTemplateCount: embeddingTemplates.length,
      modelProviderCount: modelProviders.length,
      customProviderTemplateCount: customProviderTemplates.length,
      embeddingJobCount: embeddingJobs.length,
      activeJobsCount: embeddingJobs.activeJobs.length,
      activeProvidersCount: modelProviders.getActiveConfigs().length,
      validTemplatesCount: embeddingTemplates.getValidTemplates().length,
    );
  }

  /// Export all configurations to a single JSON structure
  Map<String, dynamic> exportAll() {
    return {
      'dataSources': dataSources.items.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'embeddingTemplates': embeddingTemplates.items.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'modelProviders': modelProviders.items.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'embeddingJobs': embeddingJobs.items.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'customProviderTemplates': customProviderTemplates.items.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import configurations from a JSON structure
  Future<ImportResult> importAll(Map<String, dynamic> data) async {
    final result = ImportResult();

    try {
      // Import data sources
      if (data['dataSources'] is Map) {
        final dsData = data['dataSources'] as Map<String, dynamic>;
        for (final entry in dsData.entries) {
          final config = DataSourceConfig.fromJson(
            entry.value as Map<String, dynamic>,
          );
          if (config != null) {
            dataSources.set(entry.key, config);
            result.dataSourcesImported++;
          } else {
            result.errors.add('Failed to import data source: ${entry.key}');
          }
        }
      }

      // Import embedding templates
      if (data['embeddingTemplates'] is Map) {
        final etData = data['embeddingTemplates'] as Map<String, dynamic>;
        for (final entry in etData.entries) {
          final config = EmbeddingTemplateConfig.fromJson(
            entry.value as Map<String, dynamic>,
          );
          if (config != null) {
            embeddingTemplates.set(entry.key, config);
            result.embeddingTemplatesImported++;
          } else {
            result.errors.add(
              'Failed to import embedding template: ${entry.key}',
            );
          }
        }
      }

      // Import model providers
      if (data['modelProviders'] is Map) {
        final mpData = data['modelProviders'] as Map<String, dynamic>;
        for (final entry in mpData.entries) {
          final config = ModelProviderConfig.fromJson(
            entry.value as Map<String, dynamic>,
          );
          if (config != null) {
            modelProviders.set(entry.key, config);
            result.modelProvidersImported++;
          } else {
            result.errors.add('Failed to import model provider: ${entry.key}');
          }
        }
      }

      if (data['embeddingJobs'] is Map) {
        final ejData = data['embeddingJobs'] as Map<String, dynamic>;
        for (final entry in ejData.entries) {
          final job = EmbeddingJob.fromJson(
            entry.value as Map<String, dynamic>,
          );
          embeddingJobs.set(entry.key, job);
          result.embeddingJobsImported++;
        }
      }

      if (data['customProviderTemplates'] is Map) {
        final cptData = data['customProviderTemplates'] as Map<String, dynamic>;
        for (final entry in cptData.entries) {
          final template = CustomProviderTemplate.fromJson(
            entry.value as Map<String, dynamic>,
          );
          if (template != null) {
            customProviderTemplates.set(entry.key, template);
          } else {
            result.errors.add(
              'Failed to import custom provider template: ${entry.key}',
            );
          }
        }
      }

      result.success = true;
    } catch (e) {
      result.success = false;
      result.errors.add('Import failed: $e');
    }

    return result;
  }

  /// Create sample configurations for demo purposes
  void createSampleConfigurations() {
    // Sample data source
    final dataSourceId = dataSources.addConfig(
      name: 'Sample CSV Data',
      type: DataSourceType.csv,
      description: 'A sample CSV file for testing',
      settings: CsvDataSourceSettings(
        hasHeader: true,
        delimiter: ',',
        source: 'sample',
      ),
    );

    // Sample embedding template
    embeddingTemplates.addConfig(
      name: 'Basic Text Template',
      dataSourceId: dataSourceId,
      description: 'Simple template combining title and content',
      template: '{{title}}: {{content}}',
      availableFields: ['title', 'content', 'id'],
    );

    // Sample model provider
    modelProviders.addConfig(
      name: 'OpenAI Demo',
      type: ProviderType.openai,
      description: 'OpenAI text-embedding-3-small model',
      settings: {'model': 'text-embedding-3-small', 'dimensions': 1536},
      credentials: {'apiKey': 'sk-...your-key-here'},
    );

    // Sample embedding jobs
    embeddingJobs.createSampleJobs();
  }
}

mixin ConfigurationManagerListener<T extends StatefulComponent> on State<T> {
  final ConfigurationManager configManager = ConfigurationManager();

  @override
  void initState() {
    super.initState();
    configManager.addListener(_onConfigChanged);
  }

  @override
  void dispose() {
    configManager.removeListener(_onConfigChanged);
    super.dispose();
  }

  void _onConfigChanged() {
    setState(() {});
  }
}

/// Summary of all configurations
class ConfigurationSummary {
  final int dataSourceCount;
  final int embeddingTemplateCount;
  final int modelProviderCount;
  final int customProviderTemplateCount;
  final int embeddingJobCount;
  final int activeJobsCount;
  final int activeProvidersCount;
  final int validTemplatesCount;

  const ConfigurationSummary({
    required this.dataSourceCount,
    required this.embeddingTemplateCount,
    required this.modelProviderCount,
    required this.customProviderTemplateCount,
    required this.embeddingJobCount,
    required this.activeJobsCount,
    required this.activeProvidersCount,
    required this.validTemplatesCount,
  });
}

/// Result of an import operation
class ImportResult {
  bool success = false;
  int dataSourcesImported = 0;
  int embeddingTemplatesImported = 0;
  int modelProvidersImported = 0;
  int embeddingJobsImported = 0;
  int customProviderTemplatesImported = 0;
  List<String> errors = [];

  int get totalImported =>
      dataSourcesImported +
      embeddingTemplatesImported +
      modelProvidersImported +
      embeddingJobsImported +
      customProviderTemplatesImported;
}

import 'package:jaspr/jaspr.dart';

import '../../credentials/service/credential_service.dart';
import '../../data_sources/model/data_source_config.dart';
import '../../data_sources/service/data_source_repository.dart';
import '../../database/database_pool.dart';
import '../../jobs/model/embedding_job_collection.dart';
import '../../providers/model/custom_provider_template.dart';
import '../../providers/model/model_provider_config.dart';
import '../../templates/model/embedding_template_config.dart';
import '../service/configuration_service.dart';

/// Global state manager for all configuration collections
class ConfigurationManager with ChangeNotifier {
  static final ConfigurationManager _instance = ConfigurationManager._();
  static ConfigurationManager get instance => _instance;

  ConfigurationManager._() : _configService = ConfigurationService();

  final ConfigurationService _configService;

  // Configuration collections

  late final dataSourceConfigs = DataSourceConfigCollection(_configService);
  late final embeddingTemplates = EmbeddingTemplateConfigCollection(
    _configService,
  );
  late final modelProviders = ModelProviderConfigCollection(
    _configService,
    CredentialService(_configService.database),
  );
  late final customProviderTemplates = CustomProviderTemplateCollection(
    _configService,
  );
  late final embeddingJobs = EmbeddingJobCollection(_configService);

  // Data source repository for managing connections
  late final DatabasePool _databasePool;
  late final DataSourceRepository dataSources;

  /// Initialize all collections and load from storage
  Future<void> initialize({
    Uri? libsqlUri,
    bool? clearOnInit,
    String? poolName,
  }) async {
    _databasePool = await DatabasePool.create(
      libsqlUri: libsqlUri,
      clearOnInit: clearOnInit,
      name: poolName,
    );
    final configurationDb = await _databasePool.open('configurations.db');

    // Initialize the configuration service first
    await _configService.initialize(database: configurationDb);

    // Load data from storage for all collections
    await Future.wait([
      dataSourceConfigs.loadFromStorage(),
      embeddingTemplates.loadFromStorage(),
      modelProviders.loadFromStorage(),
      customProviderTemplates.loadFromStorage(),
      embeddingJobs.loadFromStorage(),
    ]);

    dataSources = DataSourceRepository(this, _databasePool);
    await dataSources.initialize();

    // Set up change listeners to notify global listeners
    dataSourceConfigs.addListener(notifyListeners);
    embeddingTemplates.addListener(notifyListeners);
    modelProviders.addListener(notifyListeners);
    customProviderTemplates.addListener(notifyListeners);
    embeddingJobs.addListener(notifyListeners);

    notifyListeners();
  }

  /// Clear all configurations (useful for testing or reset)
  Future<void> clearAll() async {
    await Future.wait([
      dataSourceConfigs.clear(),
      dataSources.clear(),
      embeddingTemplates.clear(),
      modelProviders.clear(),
      customProviderTemplates.clear(),
      embeddingJobs.clear(),
    ]);

    notifyListeners();
  }

  /// Get summary statistics
  ConfigurationSummary getSummary() {
    return ConfigurationSummary(
      dataSourceCount: dataSourceConfigs.length,
      embeddingTemplateCount: embeddingTemplates.length,
      modelProviderCount: modelProviders.length,
      customProviderTemplateCount: customProviderTemplates.length,
      embeddingJobCount: embeddingJobs.length,
      activeJobsCount: embeddingJobs.activeJobs.length,
      validTemplatesCount: embeddingTemplates.getValidTemplates().length,
    );
  }
}

mixin ConfigurationManagerListener<T extends StatefulComponent> on State<T> {
  final ConfigurationManager configManager = ConfigurationManager.instance;

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
  final int validTemplatesCount;

  const ConfigurationSummary({
    required this.dataSourceCount,
    required this.embeddingTemplateCount,
    required this.modelProviderCount,
    required this.customProviderTemplateCount,
    required this.embeddingJobCount,
    required this.activeJobsCount,
    required this.validTemplatesCount,
  });
}

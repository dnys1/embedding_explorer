import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

import '../../credentials/service/credential_service.dart';
import '../../data_sources/model/data_source_config.dart';
import '../../data_sources/service/data_source_repository.dart';
import '../../database/database_pool.dart';
import '../../embeddings/service/embedding_processor.dart';
import '../../jobs/model/embedding_job.dart';
import '../../jobs/model/embedding_job_collection.dart';
import '../../jobs/service/error_recovery_service.dart';
import '../../jobs/service/job_orchestrator.dart';
import '../../jobs/service/job_progress_tracker.dart';
import '../../jobs/service/job_resume_service.dart';
import '../../providers/model/custom_provider_template.dart';
import '../../providers/model/embedding_provider_config.dart';
import '../../providers/service/embedding_provider_registry.dart';
import '../../storage/service/storage_service.dart';
import '../../templates/model/embedding_template.dart';
import '../service/configuration_service.dart';

/// Global state manager for all configuration collections
class ConfigurationManager with ChangeNotifier {
  static final Logger _logger = Logger('ConfigurationManager');
  static final ConfigurationManager _instance = ConfigurationManager._();
  static ConfigurationManager get instance => _instance;

  ConfigurationManager._() : configService = ConfigurationService();

  @visibleForTesting
  ConfigurationManager.test() : this._();

  final ConfigurationService configService;
  late final StorageService _opfsStorage;

  // Configuration collections

  late final dataSourceConfigs = DataSourceConfigCollection(configService);
  late final embeddingTemplates = EmbeddingTemplateCollection(configService);
  late final embeddingProviders = EmbeddingProviderRegistry(this);
  late final embeddingProviderConfigs = EmbeddingProviderConfigCollection(
    configService,
    CredentialService(configService.database),
  );
  late final customProviderTemplates = CustomProviderTemplateCollection(
    configService,
  );
  late final embeddingJobs = EmbeddingJobCollection(configService);

  // Job orchestration services
  late final JobOrchestrator jobOrchestrator;

  // Data source repository for managing connections
  late final DatabasePool _databasePool;
  late final DataSourceRepository dataSources;

  /// Initialize all collections and load from storage
  Future<void> initialize({
    Uri? libsqlUri,
    bool? clearOnInit,
    String? poolName,
  }) async {
    // For easier debugging
    clearOnInit ??= Uri.parse(
      web.window.location.href,
    ).queryParameters.containsKey('clear');

    _databasePool = await DatabasePool.create(
      libsqlUri: libsqlUri,
      clearOnInit: clearOnInit,
      name: poolName,
    );
    final configurationDb = await _databasePool.open('configurations.db');

    // Initialize the configuration service first
    await configService.initialize(database: configurationDb);

    // Load data from storage for all collections
    await Future.wait([
      dataSourceConfigs.loadFromStorage(),
      embeddingTemplates.loadFromStorage(),
      embeddingProviderConfigs.loadFromStorage(),
      customProviderTemplates.loadFromStorage(),
      embeddingJobs.loadFromStorage(),
    ]);

    _opfsStorage = await StorageService.opfs();
    dataSources = DataSourceRepository(this, _databasePool, _opfsStorage);
    await dataSources.initialize();
    await embeddingProviders.initialize();

    // Initialize job orchestrator
    final errorRecoveryService = ErrorRecoveryService();
    final embeddingProcessor = EmbeddingProcessor(
      providerRegistry: embeddingProviders,
      configService: configService,
      errorRecoveryService: errorRecoveryService,
    );
    final progressTracker = JobProgressTracker();
    final jobResumeService = JobResumeService(database: configurationDb);

    jobOrchestrator = JobOrchestrator(
      configService: configService,
      jobRepository: embeddingJobs,
      providerRegistry: embeddingProviders,
      dataSourceRegistry: dataSources,
      templateRegistry: embeddingTemplates,
      embeddingProcessor: embeddingProcessor,
      progressTracker: progressTracker,
      errorRecoveryService: errorRecoveryService,
      jobResumeService: jobResumeService,
    );
    await jobOrchestrator.initialize();

    // Handle job reconciliation after page reload
    await _reconcileInterruptedJobs();

    // Set up change listeners to notify global listeners
    dataSourceConfigs.addListener(notifyListeners);
    embeddingTemplates.addListener(notifyListeners);
    embeddingProviderConfigs.addListener(notifyListeners);
    customProviderTemplates.addListener(notifyListeners);
    embeddingJobs.addListener(notifyListeners);
    dataSources.addListener(notifyListeners);
    embeddingProviders.addListener(notifyListeners);

    notifyListeners();
  }

  /// Clear all configurations (useful for testing or reset)
  Future<void> clearAll() async {
    await Future.wait([
      dataSourceConfigs.clear(),
      dataSources.clear(),
      embeddingTemplates.clear(),
      embeddingProviderConfigs.clear(),
      customProviderTemplates.clear(),
      embeddingJobs.clear(),
    ]);

    await _databasePool.wipeAll();
    await _opfsStorage.clear();

    notifyListeners();
  }

  /// Get summary statistics
  ConfigurationSummary getSummary() {
    return ConfigurationSummary(
      dataSourceCount: dataSourceConfigs.length,
      embeddingTemplateCount: embeddingTemplates.length,
      modelProviderCount: embeddingProviderConfigs.length,
      customProviderTemplateCount: customProviderTemplates.length,
      embeddingJobCount: embeddingJobs.length,
      activeJobsCount: embeddingJobs.activeJobs.length,
      validTemplatesCount: embeddingTemplates.getValidTemplates().length,
    );
  }

  /// Handle interrupted jobs after page reload
  Future<void> _reconcileInterruptedJobs() async {
    try {
      // Find jobs that can be resumed
      final resumableJobs = await jobOrchestrator.findResumableJobs();

      // Mark resumable jobs as interrupted so they can be restarted manually
      for (final resumableJob in resumableJobs) {
        final job = embeddingJobs.getById(resumableJob.job.id);
        if (job?.status case JobStatus.paused || JobStatus.running) {
          await embeddingJobs.updateJobStatus(job!.id, JobStatus.paused);
        }
      }
    } catch (e) {
      // Log error but don't fail initialization
      _logger.warning('Error during job reconciliation', e);
    }
  }

  /// Handle graceful shutdown of jobs when page is being unloaded
  Future<void> handlePageUnload() async {
    try {
      await jobOrchestrator.pauseAllRunningJobs();
    } catch (e) {
      _logger.warning('Error during page unload job cleanup', e);
    }
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

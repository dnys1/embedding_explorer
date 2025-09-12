import 'dart:convert';

import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';

import '../../data_sources/model/data_source_config.dart';
import '../../database/database.dart';
import '../../database/migrate.dart';
import '../../jobs/model/embedding_job.dart';
import '../../providers/model/custom_provider_template.dart';
import '../../providers/model/model_provider_config.dart';
import '../../templates/model/embedding_template_config.dart';
import 'migrations/migrations.dart';

/// Service for managing configuration data using SQLite database
class ConfigurationService with ChangeNotifier {
  static final Logger _logger = Logger('ConfigurationService');

  Database? _database;
  final Uri? _libsqlUri;
  final Migrate _migrator;
  bool _isInitialized = false;

  /// Path to the database file
  final String databasePath;

  ConfigurationService({
    this.databasePath = 'configurations.db',
    Uri? libsqlUri,
  }) : _libsqlUri = libsqlUri,
       _migrator = Migrate(migrations: configMigrations, logger: _logger);

  /// Initialize the database and run migrations
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.warning('ConfigurationService already initialized');
      return;
    }

    try {
      _logger.info(
        'Initializing ConfigurationService with database: $databasePath',
      );

      // Open the database
      _database = await Database.open(databasePath, moduleUri: _libsqlUri);

      // Run migrations to ensure schema is up to date
      await _migrator.up(_database!);

      _isInitialized = true;
      _logger.info('ConfigurationService initialized successfully');

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.severe(
        'Failed to initialize ConfigurationService',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Get the database instance
  Database get database {
    if (!_isInitialized || _database == null) {
      throw StateError(
        'ConfigurationService not initialized. Call initialize() first.',
      );
    }
    return _database!;
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Get the current database schema version
  Future<int> getCurrentVersion() async {
    return _migrator.getCurrentVersion(database);
  }

  /// Run database migrations up to the specified version
  Future<void> migrateUp({int? to}) async {
    await _migrator.up(database, to: to);
  }

  /// Roll back database migrations down to the specified version
  Future<void> migrateDown({int? to}) async {
    await _migrator.down(database, to: to);
  }

  // Data Source Configuration Methods

  /// Save a data source configuration to the database
  Future<void> saveDataSourceConfig(DataSourceConfig config) async {
    final now = DateTime.now().toIso8601String();

    await database.execute(
      '''
      INSERT OR REPLACE INTO data_source_configs 
      (id, name, description, type, settings, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        config.id,
        config.name,
        config.description,
        config.type.name,
        jsonEncode(config.settings.toJson()),
        config.createdAt.toIso8601String(),
        now,
      ],
    );

    _logger.info('Saved data source config: ${config.id}');
  }

  /// Get a data source configuration by ID
  Future<DataSourceConfig?> getDataSourceConfig(String id) async {
    final result = await database.select(
      'SELECT * FROM data_source_configs WHERE id = ?',
      [id],
    );

    if (result.rows.isEmpty) return null;

    final row = result.first;
    return DataSourceConfig.fromDatabase(row);
  }

  /// Get all data source configurations
  Future<List<DataSourceConfig>> getAllDataSourceConfigs() async {
    final result = await database.select(
      'SELECT * FROM data_source_configs ORDER BY created_at DESC',
    );

    return result.map(DataSourceConfig.fromDatabase).nonNulls.toList();
  }

  /// Delete a data source configuration
  Future<void> deleteDataSourceConfig(String id) async {
    await database.execute('DELETE FROM data_source_configs WHERE id = ?', [
      id,
    ]);
    _logger.info('Deleted data source config: $id');
  }

  // Embedding Template Configuration Methods

  /// Save an embedding template configuration to the database
  Future<void> saveEmbeddingTemplateConfig(
    EmbeddingTemplateConfig config,
  ) async {
    final now = DateTime.now().toIso8601String();

    await database.execute(
      '''
      INSERT OR REPLACE INTO embedding_template_configs 
      (id, name, description, template, data_source_id, available_fields, metadata, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        config.id,
        config.name,
        config.description,
        config.template,
        config.dataSourceId,
        jsonEncode(config.availableFields),
        jsonEncode(config.metadata),
        config.createdAt.toIso8601String(),
        now,
      ],
    );

    _logger.info('Saved embedding template config: ${config.id}');
  }

  /// Get an embedding template configuration by ID
  Future<EmbeddingTemplateConfig?> getEmbeddingTemplateConfig(String id) async {
    final result = await database.select(
      'SELECT * FROM embedding_template_configs WHERE id = ?',
      [id],
    );

    if (result.rows.isEmpty) return null;

    final row = result.first;
    return EmbeddingTemplateConfig.fromDatabase(row);
  }

  /// Get all embedding template configurations
  Future<List<EmbeddingTemplateConfig>> getAllEmbeddingTemplateConfigs() async {
    final result = await database.select(
      'SELECT * FROM embedding_template_configs ORDER BY created_at DESC',
    );

    return result.map(EmbeddingTemplateConfig.fromDatabase).nonNulls.toList();
  }

  /// Get embedding templates by data source ID
  Future<List<EmbeddingTemplateConfig>> getEmbeddingTemplatesByDataSource(
    String dataSourceId,
  ) async {
    final result = await database.select(
      'SELECT * FROM embedding_template_configs WHERE data_source_id = ? ORDER BY created_at DESC',
      [dataSourceId],
    );

    return result.map(EmbeddingTemplateConfig.fromDatabase).nonNulls.toList();
  }

  /// Delete an embedding template configuration
  Future<void> deleteEmbeddingTemplateConfig(String id) async {
    await database.execute(
      'DELETE FROM embedding_template_configs WHERE id = ?',
      [id],
    );
    _logger.info('Deleted embedding template config: $id');
  }

  // Model Provider Configuration Methods

  /// Save a model provider configuration to the database
  Future<void> saveModelProviderConfig(ModelProviderConfig config) async {
    final now = DateTime.now().toIso8601String();

    await database.execute(
      '''
      INSERT OR REPLACE INTO model_provider_configs 
      (id, name, description, type, custom_template_id, settings, credentials, is_active, persist_credentials, enabled_models, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        config.id,
        config.name,
        config.description,
        config.type.name,
        config.customTemplateId,
        jsonEncode(config.settings),
        jsonEncode(config.credentials),
        config.isActive ? 1 : 0,
        config.persistCredentials ? 1 : 0,
        jsonEncode(config.enabledModels.toList()),
        config.createdAt.toIso8601String(),
        now,
      ],
    );

    _logger.info('Saved model provider config: ${config.id}');
  }

  /// Get a model provider configuration by ID
  Future<ModelProviderConfig?> getModelProviderConfig(String id) async {
    final result = await database.select(
      'SELECT * FROM model_provider_configs WHERE id = ?',
      [id],
    );

    if (result.rows.isEmpty) return null;

    final row = result.first;
    return ModelProviderConfig.fromDatabase(row);
  }

  /// Get all model provider configurations
  Future<List<ModelProviderConfig>> getAllModelProviderConfigs() async {
    final result = await database.select(
      'SELECT * FROM model_provider_configs ORDER BY created_at DESC',
    );

    return result.map(ModelProviderConfig.fromDatabase).nonNulls.toList();
  }

  /// Get active model provider configurations
  Future<List<ModelProviderConfig>> getActiveModelProviderConfigs() async {
    final result = await database.select(
      'SELECT * FROM model_provider_configs WHERE is_active = 1 ORDER BY created_at DESC',
    );

    return result.map(ModelProviderConfig.fromDatabase).nonNulls.toList();
  }

  /// Delete a model provider configuration
  Future<void> deleteModelProviderConfig(String id) async {
    await database.execute('DELETE FROM model_provider_configs WHERE id = ?', [
      id,
    ]);
    _logger.info('Deleted model provider config: $id');
  }

  // Custom Provider Template Methods

  /// Save a custom provider template to the database
  Future<void> saveCustomProviderTemplate(
    CustomProviderTemplate template,
  ) async {
    final now = DateTime.now().toIso8601String();

    await database.execute(
      '''
      INSERT OR REPLACE INTO custom_provider_templates 
      (id, name, description, icon, base_uri, required_credentials, default_settings, available_models, embedding_request_template, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        template.id,
        template.name,
        template.description,
        template.icon,
        template.baseUri,
        jsonEncode(template.requiredCredentials),
        jsonEncode(template.defaultSettings),
        jsonEncode(template.availableModels),
        jsonEncode(template.embeddingRequestTemplate),
        template.createdAt.toIso8601String(),
        now,
      ],
    );

    _logger.info('Saved custom provider template: ${template.id}');
  }

  /// Get a custom provider template by ID
  Future<CustomProviderTemplate?> getCustomProviderTemplate(String id) async {
    final result = await database.select(
      'SELECT * FROM custom_provider_templates WHERE id = ?',
      [id],
    );

    if (result.rows.isEmpty) return null;

    final row = result.first;
    return CustomProviderTemplate.fromDatabase(row);
  }

  /// Get all custom provider templates
  Future<List<CustomProviderTemplate>> getAllCustomProviderTemplates() async {
    final result = await database.select(
      'SELECT * FROM custom_provider_templates ORDER BY created_at DESC',
    );

    return result.map(CustomProviderTemplate.fromDatabase).nonNulls.toList();
  }

  /// Delete a custom provider template
  Future<void> deleteCustomProviderTemplate(String id) async {
    await database.execute(
      'DELETE FROM custom_provider_templates WHERE id = ?',
      [id],
    );
    _logger.info('Deleted custom provider template: $id');
  }

  // Embedding Job Methods

  /// Save an embedding job to the database
  Future<void> saveEmbeddingJob(EmbeddingJob job) async {
    database.transaction((tx) {
      // Insert or update the main job record
      tx.execute(
        '''
        INSERT OR REPLACE INTO embedding_jobs 
        (id, name, description, data_source_id, embedding_template_id, model_provider_ids, status, created_at, started_at, completed_at, error_message, results, total_records, processed_records)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          job.id,
          job.name,
          job.description,
          job.dataSourceId,
          job.embeddingTemplateId,
          jsonEncode(job.modelProviderIds),
          job.status.name,
          job.createdAt.toIso8601String(),
          job.startedAt?.toIso8601String(),
          job.completedAt?.toIso8601String(),
          job.errorMessage,
          job.results != null ? jsonEncode(job.results) : null,
          job.totalRecords,
          job.processedRecords,
        ],
      );

      // Update the junction table for job-provider relationships
      tx.execute('DELETE FROM embedding_job_providers WHERE job_id = ?', [
        job.id,
      ]);

      for (final providerId in job.modelProviderIds) {
        tx.execute(
          '''
          INSERT INTO embedding_job_providers (job_id, provider_id)
          VALUES (?, ?)
        ''',
          [job.id, providerId],
        );
      }
    });

    _logger.info('Saved embedding job: ${job.id}');
  }

  /// Get an embedding job by ID
  Future<EmbeddingJob?> getEmbeddingJob(String id) async {
    final result = await database.select(
      'SELECT * FROM embedding_jobs WHERE id = ?',
      [id],
    );

    if (result.rows.isEmpty) return null;

    final row = result.first;
    return EmbeddingJob.fromDatabase(row);
  }

  /// Get all embedding jobs
  Future<List<EmbeddingJob>> getAllEmbeddingJobs() async {
    final result = await database.select(
      'SELECT * FROM embedding_jobs ORDER BY created_at DESC',
    );

    return result.map(EmbeddingJob.fromDatabase).nonNulls.toList();
  }

  /// Get embedding jobs by status
  Future<List<EmbeddingJob>> getEmbeddingJobsByStatus(String status) async {
    final result = await database.select(
      'SELECT * FROM embedding_jobs WHERE status = ? ORDER BY created_at DESC',
      [status],
    );

    return result.map(EmbeddingJob.fromDatabase).nonNulls.toList();
  }

  /// Delete an embedding job
  Future<void> deleteEmbeddingJob(String id) async {
    await database.execute('DELETE FROM embedding_jobs WHERE id = ?', [id]);
    _logger.info('Deleted embedding job: $id');
  }

  /// Dispose of the database connection
  @override
  void dispose() {
    if (_database == null) {
      return;
    }
    _database?.dispose();
    _database = null;
    _isInitialized = false;
    super.dispose();
  }
}

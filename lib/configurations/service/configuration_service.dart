import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';

import '../../data_sources/model/data_source_config.dart';
import '../../database/database.dart';
import '../../database/migrate.dart';
import '../../jobs/model/embedding_job.dart';
import '../../providers/model/custom_provider_template.dart';
import '../../providers/model/embedding_provider_config.dart';
import '../../templates/model/embedding_template.dart';
import '../../util/type_id.dart';
import '../model/embedding_tables.dart';
import '../model/vector_search_result.dart';
import 'migrations/migrations.dart';

/// Service for managing configuration data using SQLite database
class ConfigurationService with ChangeNotifier {
  static final Logger _logger = Logger('ConfigurationService');

  late DatabaseHandle _database;
  final Migrate _migrator;
  bool _isInitialized = false;

  ConfigurationService()
    : _migrator = Migrate(migrations: configMigrations, logger: _logger);

  /// Initialize the database and run migrations
  Future<void> initialize({required DatabaseHandle database}) async {
    if (_isInitialized) {
      _logger.warning('ConfigurationService already initialized');
      return;
    }

    _database = database;

    try {
      _logger.config('Initializing ConfigurationService');

      // Run migrations to ensure schema is up to date
      await _migrator.up(_database);

      _isInitialized = true;
      _logger.config('ConfigurationService initialized successfully');

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
  DatabaseHandle get database {
    if (!_isInitialized) {
      throw StateError(
        'ConfigurationService not initialized. Call initialize() first.',
      );
    }
    return _database;
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
      INSERT OR REPLACE INTO data_sources 
      (id, name, description, type, filename, settings, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        config.id,
        config.name,
        config.description,
        config.type.name,
        config.filename,
        jsonEncode(config.settings.toJson()),
        config.createdAt.toIso8601String(),
        now,
      ],
    );

    _logger.fine('Saved data source config: ${config.id}');
  }

  /// Get a data source configuration by ID
  Future<DataSourceConfig?> getDataSourceConfig(String id) async {
    final result = await database.select(
      'SELECT * FROM data_sources WHERE id = ?',
      [id],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return DataSourceConfig.fromDatabase(row);
  }

  /// Get all data source configurations
  Future<List<DataSourceConfig>> getAllDataSourceConfigs() async {
    final result = await database.select(
      'SELECT * FROM data_sources ORDER BY created_at DESC',
    );

    return result.map(DataSourceConfig.fromDatabase).toList();
  }

  /// Delete a data source configuration
  Future<void> deleteDataSourceConfig(String id) async {
    await database.execute('DELETE FROM data_sources WHERE id = ?', [id]);
    _logger.fine('Deleted data source config: $id');
  }

  // Embedding Template Configuration Methods

  /// Save an embedding template configuration to the database
  Future<void> saveEmbeddingTemplateConfig(EmbeddingTemplate config) async {
    final now = DateTime.now().toIso8601String();

    await database.execute(
      '''
      INSERT OR REPLACE INTO templates 
      (id, name, description, id_template, template, data_source_id, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        config.id,
        config.name,
        config.description,
        config.idTemplate,
        config.template,
        config.dataSourceId,
        config.createdAt.toIso8601String(),
        now,
      ],
    );

    _logger.fine('Saved embedding template config: ${config.id}');
  }

  /// Get an embedding template configuration by ID
  Future<EmbeddingTemplate?> getEmbeddingTemplate(String id) async {
    final result = await database.select(
      'SELECT * FROM templates WHERE id = ?',
      [id],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return EmbeddingTemplate.fromDatabase(row);
  }

  /// Get all embedding template configurations
  Future<List<EmbeddingTemplate>> getAllEmbeddingTemplateConfigs() async {
    final result = await database.select(
      'SELECT * FROM templates ORDER BY created_at DESC',
    );

    return result.map(EmbeddingTemplate.fromDatabase).toList();
  }

  /// Get embedding templates by data source ID
  Future<List<EmbeddingTemplate>> getEmbeddingTemplatesByDataSource(
    String dataSourceId,
  ) async {
    final result = await database.select(
      'SELECT * FROM templates WHERE data_source_id = ? ORDER BY created_at DESC',
      [dataSourceId],
    );

    return result.map(EmbeddingTemplate.fromDatabase).toList();
  }

  /// Delete an embedding template configuration
  Future<void> deleteEmbeddingTemplateConfig(String id) async {
    await database.execute('DELETE FROM templates WHERE id = ?', [id]);
    _logger.fine('Deleted embedding template config: $id');
  }

  // Model Provider Configuration Methods

  /// Save a model provider configuration to the database
  Future<void> saveProviderConfig(EmbeddingProviderConfig config) async {
    final now = DateTime.now().toIso8601String();

    await database.transaction((tx) {
      tx.execute(
        '''
      INSERT OR REPLACE INTO providers 
      (id, name, description, type, custom_template_id, settings, enabled_models, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
        [
          config.id,
          config.name,
          config.description,
          config.type.name,
          config.customTemplateId,
          jsonEncode(config.settings),
          jsonEncode(config.enabledModels.toList()),
          config.createdAt.toIso8601String(),
          now,
        ],
      );

      if (config.persistCredentials) {
        if (config.credential case final credential?) {
          tx.execute(
            '''
      INSERT OR REPLACE INTO provider_credentials
      (provider_id, credential)
      VALUES (?, ?)
    ''',
            [config.id, jsonEncode(credential.toJson())],
          );
        } else {
          // Remove existing credentials if credential is null
          tx.execute('DELETE FROM provider_credentials WHERE provider_id = ?', [
            config.id,
          ]);
        }
      }
    });

    _logger.fine('Saved model provider config: ${config.id}');
  }

  /// Get a model provider configuration by ID
  Future<EmbeddingProviderConfig?> getProviderConfig(String id) async {
    final result = await database.select(
      '''
SELECT *
FROM providers
LEFT JOIN provider_credentials
  ON providers.id = provider_credentials.provider_id
WHERE id = ?
''',
      [id],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return EmbeddingProviderConfig.fromDatabase(row);
  }

  /// Get all model provider configurations
  Future<List<EmbeddingProviderConfig>> getAllProviderConfigs() async {
    final result = await database.select('''
SELECT *
FROM providers
LEFT JOIN provider_credentials
  ON providers.id = provider_credentials.provider_id
ORDER BY created_at DESC
''');

    return result.map(EmbeddingProviderConfig.fromDatabase).toList();
  }

  /// Delete a model provider configuration
  Future<void> deleteProviderConfig(String id) async {
    await database.transaction((tx) {
      // Delete associated credentials first
      tx.execute('DELETE FROM provider_credentials WHERE provider_id = ?', [
        id,
      ]);

      // Delete the provider config
      tx.execute('DELETE FROM providers WHERE id = ?', [id]);
    });

    _logger.fine('Deleted model provider config and credentials: $id');
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

    _logger.fine('Saved custom provider template: ${template.id}');
  }

  /// Get a custom provider template by ID
  Future<CustomProviderTemplate?> getCustomProviderTemplate(String id) async {
    final result = await database.select(
      'SELECT * FROM custom_provider_templates WHERE id = ?',
      [id],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return CustomProviderTemplate.fromDatabase(row);
  }

  /// Get all custom provider templates
  Future<List<CustomProviderTemplate>> getAllCustomProviderTemplates() async {
    final result = await database.select(
      'SELECT * FROM custom_provider_templates ORDER BY created_at DESC',
    );

    return result.map(CustomProviderTemplate.fromDatabase).toList();
  }

  /// Delete a custom provider template
  Future<void> deleteCustomProviderTemplate(String id) async {
    await database.execute(
      'DELETE FROM custom_provider_templates WHERE id = ?',
      [id],
    );
    _logger.fine('Deleted custom provider template: $id');
  }

  // Embedding Job Methods

  /// Save an embedding job to the database
  Future<void> saveEmbeddingJob(EmbeddingJob job) async {
    await database.transaction((tx) {
      // Insert or update the main job record
      tx.execute(
        '''
        INSERT OR REPLACE INTO jobs 
        (id, name, description, data_source_id, template_id, provider_ids, model_ids, status, created_at, started_at, completed_at, error_message, results, total_records, processed_records)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          job.id,
          job.name,
          job.description,
          job.dataSourceId,
          job.embeddingTemplateId,
          jsonEncode(job.providerIds),
          jsonEncode(job.modelIds),
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
      tx.execute('DELETE FROM job_providers WHERE job_id = ?', [job.id]);

      for (final providerId in job.providerIds) {
        tx.execute(
          '''
          INSERT INTO job_providers (job_id, provider_id)
          VALUES (?, ?)
        ''',
          [job.id, providerId],
        );
      }
    });

    _logger.fine('Saved embedding job: ${job.id}');
  }

  /// Get an embedding job by ID
  Future<EmbeddingJob?> getEmbeddingJob(String id) async {
    final result = await database.select('SELECT * FROM jobs WHERE id = ?', [
      id,
    ]);

    if (result.isEmpty) return null;

    final row = result.first;
    return EmbeddingJob.fromDatabase(row);
  }

  /// Get all embedding jobs
  Future<List<EmbeddingJob>> getAllEmbeddingJobs() async {
    final result = await database.select(
      'SELECT * FROM jobs ORDER BY created_at DESC',
    );

    return result.map(EmbeddingJob.fromDatabase).toList();
  }

  /// Get embedding jobs by status
  Future<List<EmbeddingJob>> getEmbeddingJobsByStatus(String status) async {
    final result = await database.select(
      'SELECT * FROM jobs WHERE status = ? ORDER BY created_at DESC',
      [status],
    );

    return result.map(EmbeddingJob.fromDatabase).toList();
  }

  /// Delete an embedding job
  Future<void> deleteEmbeddingJob(String id) async {
    await database.execute('DELETE FROM jobs WHERE id = ?', [id]);
    _logger.fine('Deleted embedding job: $id');
  }

  // Embedding Table Management Methods

  /// Create a new embedding table with base columns (id, source_data)
  Future<String> createEmbeddingTable({
    required String jobId,
    required String dataSourceId,
    required String embeddingTemplateId,
  }) async {
    final tableId = 'embeddings_$jobId';
    final tableName = tableId;
    final now = DateTime.now().toIso8601String();

    await database.transaction((tx) {
      // Create the embedding table with base columns
      tx.execute('''
        CREATE TABLE IF NOT EXISTS $tableName (
          id TEXT PRIMARY KEY NOT NULL,
          source_data TEXT NOT NULL, -- JSON representation of original data
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Register the table
      tx.execute(
        '''
        INSERT INTO embedding_table_registry 
        (id, table_name, job_id, data_source_id, template_id, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO NOTHING
      ''',
        [
          tableId,
          tableName,
          jobId,
          dataSourceId,
          embeddingTemplateId,
          now,
          now,
        ],
      );
    });

    _logger.fine('Created embedding table: $tableName');
    return tableId;
  }

  /// Add a vector column to an existing embedding table
  Future<void> addVectorColumn({
    required String tableId,
    required String modelProviderId,
    required String modelName,
    required VectorType vectorType,
    required int dimensions,
  }) async {
    final columnId = typeId('col');
    final columnName =
        '${modelName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')}_embedding';
    final now = DateTime.now().toIso8601String();

    // Get the table name
    final tableResult = await database.select(
      'SELECT table_name FROM embedding_table_registry WHERE id = ?',
      [tableId],
    );

    if (tableResult.isEmpty) {
      throw StateError('Embedding table not found: $tableId');
    }

    final tableName = tableResult.first['table_name'] as String;

    final existingColumns = await getEmbeddingColumns(tableId);
    final existingColumn = existingColumns.firstWhereOrNull(
      (col) => col.modelProviderId == modelProviderId,
    );
    if (existingColumn != null) {
      if (existingColumn.columnName != columnName ||
          existingColumn.dimensions != dimensions ||
          existingColumn.vectorType != vectorType) {
        throw StateError(
          'A different vector column already exists for provider $modelProviderId in table $tableId. '
          'Existing column: (name: ${existingColumn.columnName}, type: ${existingColumn.vectorType}, dimensions: ${existingColumn.dimensions}), '
          'Requested: (name: $columnName, type: ${vectorType.name}, dimensions: $dimensions)',
        );
      } else {
        // Column already exists with same configuration - no action needed
        _logger.fine(
          'Vector column already exists for provider $modelProviderId in table $tableId - no action taken',
        );
        return;
      }
    }

    await database.transaction((tx) {
      // Add the vector column to the table
      tx.execute('''
        ALTER TABLE $tableName 
        ADD COLUMN $columnName ${vectorType.sqlType}($dimensions)
      ''');

      // Register the column
      tx.execute(
        '''
        INSERT INTO embedding_column_registry 
        (id, table_id, column_name, provider_id, model_name, vector_type, dimensions, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          columnId,
          tableId,
          columnName,
          modelProviderId,
          modelName,
          vectorType.name,
          dimensions,
          now,
        ],
      );
    });

    _logger.fine(
      'Added vector column $columnName to table $tableName (${vectorType.sqlType}($dimensions))',
    );
  }

  /// Create a vector index for a specific column in an embedding table
  Future<void> createVectorIndex({
    required String tableId,
    required String columnName,
    String metric = 'cosine',
    int? maxNeighbors,
    VectorType? compressNeighbors,
  }) async {
    // Get the table name
    final tableResult = await database.select(
      'SELECT table_name FROM embedding_table_registry WHERE id = ?',
      [tableId],
    );

    if (tableResult.isEmpty) {
      throw StateError('Embedding table not found: $tableId');
    }

    final tableName = tableResult.first['table_name'] as String;
    final indexName = '${tableName}_${columnName}_idx';

    // Build index settings
    final settings = <String>[];
    settings.add("'metric=$metric'");
    if (maxNeighbors != null) settings.add("'max_neighbors=$maxNeighbors'");
    if (compressNeighbors != null) {
      settings.add("'compress_neighbors=${compressNeighbors.name}'");
    }

    final settingsStr = settings.isNotEmpty ? ', ${settings.join(', ')}' : '';

    await database.execute('''
      CREATE INDEX $indexName ON $tableName (libsql_vector_idx($columnName$settingsStr))
    ''');

    _logger.fine('Created vector index $indexName for column $columnName');
  }

  /// Insert embedding data into a table
  Future<void> insertEmbeddingData({
    required String tableId,
    required String recordId,
    required Map<String, dynamic> sourceData,
    Map<String, List<double>>? embeddings,
  }) async {
    // Get table info
    final tableResult = await database.select(
      'SELECT table_name FROM embedding_table_registry WHERE id = ?',
      [tableId],
    );

    if (tableResult.isEmpty) {
      throw StateError('Embedding table not found: $tableId');
    }

    final tableName = tableResult.first['table_name'] as String;

    // Get column info for embeddings
    final columnResult = await database.select(
      '''
      SELECT column_name, vector_type 
      FROM embedding_column_registry 
      WHERE table_id = ?
    ''',
      [tableId],
    );

    final columns = ['id', 'source_data'];
    final sqlPlaceholders = ['?', '?'];
    final updateClauses = <String>[];
    final values = <Object?>[recordId, jsonEncode(sourceData)];

    // Always update source_data
    updateClauses.add('source_data = excluded.source_data');

    // Add embedding columns and values
    for (final row in columnResult) {
      final columnName = row['column_name'] as String;
      final vectorTypeName = row['vector_type'] as String;
      final vectorType = VectorType.values.byName(vectorTypeName);

      columns.add(columnName);

      // Get embedding for this column
      final embedding = embeddings?[columnName];
      if (embedding != null) {
        // Use the LibSQL vector conversion function directly in SQL
        sqlPlaceholders.add('${vectorType.conversionFunction}(?)');
        values.add(jsonEncode(embedding));
        // Only update if new value is not null (CASCADE behavior)
        updateClauses.add('$columnName = excluded.$columnName');
      } else {
        sqlPlaceholders.add('?');
        values.add(null);
        // Don't add to updateClauses - preserve existing value if new value is null
      }
    }

    // Use INSERT OR REPLACE with ON CONFLICT clause for upsert behavior
    await database.execute('''
      INSERT INTO $tableName (${columns.join(', ')}) 
      VALUES (${sqlPlaceholders.join(', ')})
      ON CONFLICT(id) DO UPDATE SET
      ${updateClauses.join(', ')}
      ''', values);
  }

  /// Get embedding table registry entries
  Future<List<EmbeddingTable>> getEmbeddingTables({
    String? jobId,
    String? dataSourceId,
  }) async {
    final sqlBuffer = StringBuffer('SELECT * FROM embedding_table_registry');
    final params = <String>[];

    if (jobId != null || dataSourceId != null) {
      sqlBuffer.write(' WHERE ');
      final conditions = <String>[];
      if (jobId != null) {
        conditions.add('job_id = ?');
        params.add(jobId);
      }
      if (dataSourceId != null) {
        conditions.add('data_source_id = ?');
        params.add(dataSourceId);
      }
      sqlBuffer.write(conditions.join(' AND '));
    }

    sqlBuffer.write(' ORDER BY created_at DESC');

    final result = await database.select(sqlBuffer.toString(), params);
    return result.map((row) => EmbeddingTable.fromDatabase(row)).toList();
  }

  /// Get embedding column registry entries for a table
  Future<List<EmbeddingColumn>> getEmbeddingColumns([String? tableId]) async {
    final sqlBuffer = StringBuffer('SELECT * FROM embedding_column_registry');
    final params = <String>[];

    if (tableId != null) {
      sqlBuffer.write(' WHERE table_id = ?');
      params.add(tableId);
    }

    sqlBuffer.write(' ORDER BY created_at');

    final result = await database.select(sqlBuffer.toString(), params);
    return result.map(EmbeddingColumn.fromDatabase).toList();
  }

  /// Search for similar vectors in an embedding table
  Future<List<VectorSearchResult>> searchSimilarVectors({
    required String tableId,
    required String columnName,
    required List<double> queryVector,
    required VectorType vectorType,
    int limit = 10,
  }) async {
    // Get table info
    final tableResult = await database.select(
      'SELECT table_name FROM embedding_table_registry WHERE id = ?',
      [tableId],
    );

    if (tableResult.isEmpty) {
      throw StateError('Embedding table not found: $tableId');
    }

    final tableName = tableResult.first['table_name'] as String;
    final indexName = '${tableName}_${columnName}_idx';

    // Check if vector index exists
    final indexResult = await database.select(
      '''
      SELECT name FROM sqlite_master 
      WHERE type = 'index' AND name = ?
    ''',
      [indexName],
    );

    if (indexResult.isNotEmpty) {
      // Use vector index for efficient search
      final result = await database.select(
        '''
        SELECT t.id, t.source_data, t.created_at,
               vector_distance_cos(t.$columnName, ${vectorType.conversionFunction}(?)) as distance
        FROM vector_top_k(?, ${vectorType.conversionFunction}(?), ?) v
        JOIN $tableName t ON t.rowid = v.id
        ORDER BY distance ASC
      ''',
        [jsonEncode(queryVector), indexName, jsonEncode(queryVector), limit],
      );

      return result.map(VectorSearchResult.fromDatabase).toList();
    } else {
      // Fall back to linear search without index
      _logger.fine('Vector index $indexName not found, using linear search');

      final result = await database.select(
        '''
        SELECT id, source_data, created_at,
               vector_distance_cos($columnName, ${vectorType.conversionFunction}(?)) as distance
        FROM $tableName
        WHERE $columnName IS NOT NULL
        ORDER BY distance ASC
        LIMIT ?
      ''',
        [jsonEncode(queryVector), limit],
      );

      return result.map(VectorSearchResult.fromDatabase).toList();
    }
  }

  /// Delete an embedding table and all its data
  Future<void> deleteEmbeddingTable(String tableId) async {
    // Get table name
    final tableResult = await database.select(
      'SELECT table_name FROM embedding_table_registry WHERE id = ?',
      [tableId],
    );

    if (tableResult.isEmpty) {
      _logger.warning('Embedding table not found: $tableId');
      return;
    }

    final tableName = tableResult.first['table_name'] as String;

    await database.transaction((tx) {
      // Drop the actual table
      tx.execute('DROP TABLE IF EXISTS $tableName');

      // Remove from registry (cascade will handle column registry)
      tx.execute('DELETE FROM embedding_table_registry WHERE id = ?', [
        tableId,
      ]);

      // TODO(dnys1): This shouldn't be needed since CASCADE should handle it
      tx.execute('DELETE FROM embedding_column_registry WHERE table_id = ?', [
        tableId,
      ]);
    });

    _logger.fine('Deleted embedding table: $tableName');
  }

  /// Dispose of the database connection
  @override
  Future<void> dispose() async {
    if (!_isInitialized) return;
    await _database.close();
    _isInitialized = false;
    super.dispose();
  }
}

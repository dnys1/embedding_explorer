@TestOn('browser')
library;

import 'dart:convert';

import 'package:embeddings_explorer/configurations/model/embedding_tables.dart';
import 'package:embeddings_explorer/configurations/service/configuration_service.dart';
import 'package:embeddings_explorer/configurations/service/migrations/migrations.dart';
import 'package:embeddings_explorer/credentials/model/credential.dart';
import 'package:embeddings_explorer/data_sources/model/data_source_config.dart';
import 'package:embeddings_explorer/data_sources/model/data_source_settings.dart';
import 'package:embeddings_explorer/database/database.dart';
import 'package:embeddings_explorer/jobs/model/embedding_job.dart';
import 'package:embeddings_explorer/providers/model/custom_provider_template.dart';
import 'package:embeddings_explorer/providers/model/embedding_provider_config.dart';
import 'package:embeddings_explorer/templates/model/embedding_template.dart';
import 'package:test/test.dart';

import '../../common.dart';

// Test helper functions to reduce code duplication
class TestHelpers {
  static DataSourceConfig createDataSourceConfig({
    String id = 'ds_1',
    String name = 'Data Source 1',
    String description = 'Test data source',
    DataSourceType type = DataSourceType.csv,
    String filename = 'test.csv',
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.now();
    return DataSourceConfig(
      id: id,
      name: name,
      description: description,
      type: type,
      filename: filename,
      settings: type == DataSourceType.csv
          ? CsvDataSourceSettings(delimiter: ',')
          : SqliteDataSourceSettings(),
      createdAt: now,
      updatedAt: now,
    );
  }

  static EmbeddingTemplate createTemplateConfig({
    String id = 'template_1',
    String name = 'Template 1',
    String description = 'Test template',
    String template = '{{content}}',
    String dataSourceId = 'ds_1',
    List<String> availableFields = const ['content'],
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.now();
    return EmbeddingTemplate(
      id: id,
      name: name,
      description: description,
      template: template,
      dataSourceId: dataSourceId,
      availableFields: availableFields,
      metadata: <String, dynamic>{},
      createdAt: now,
      updatedAt: now,
    );
  }

  static EmbeddingProviderConfig createProviderConfig({
    String id = 'provider_1',
    String name = 'Test Provider 1',
    String description = 'Test provider',
    EmbeddingProviderType type = EmbeddingProviderType.openai,
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.now();
    return EmbeddingProviderConfig(
      id: id,
      name: name,
      description: description,
      type: type,
      customTemplateId: null,
      settings: <String, dynamic>{},
      credential: null,
      persistCredentials: false,
      enabledModels: <String>{},
      createdAt: now,
      updatedAt: now,
    );
  }

  static EmbeddingJob createJob({
    String id = 'job_1',
    String name = 'Test Job',
    String description = 'Test job',
    String dataSourceId = 'ds_1',
    String embeddingTemplateId = 'template_1',
    List<String> modelProviderIds = const [],
    JobStatus status = JobStatus.pending,
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.now();
    return EmbeddingJob(
      id: id,
      name: name,
      description: description,
      dataSourceId: dataSourceId,
      embeddingTemplateId: embeddingTemplateId,
      providerIds: modelProviderIds,
      status: status,
      totalRecords: 0,
      processedRecords: 0,
      createdAt: now,
      startedAt: null,
      completedAt: null,
      errorMessage: null,
      results: null,
    );
  }

  /// Creates a full test setup by creating data source, template, provider, and job
  static Future<void> createFullTestSetup(
    ConfigurationService service, {
    String dataSourceId = 'ds_1',
    String templateId = 'template_1',
    String providerId = 'provider_1',
    String jobId = 'job_1',
    DateTime? createdAt,
  }) async {
    final now = createdAt ?? DateTime.now();

    // Create data source
    final dsConfig = createDataSourceConfig(id: dataSourceId, createdAt: now);
    await service.saveDataSourceConfig(dsConfig);

    // Create template
    final templateConfig = createTemplateConfig(
      id: templateId,
      dataSourceId: dataSourceId,
      createdAt: now,
    );
    await service.saveEmbeddingTemplateConfig(templateConfig);

    // Create provider (if specified)
    if (providerId.isNotEmpty) {
      final providerConfig = createProviderConfig(
        id: providerId,
        createdAt: now,
      );
      await service.saveModelProviderConfig(providerConfig);
    }

    // Create job (if specified)
    if (jobId.isNotEmpty) {
      final job = createJob(
        id: jobId,
        dataSourceId: dataSourceId,
        embeddingTemplateId: templateId,
        modelProviderIds: providerId.isNotEmpty ? [providerId] : [],
        createdAt: now,
      );
      await service.saveEmbeddingJob(job);
    }
  }
}

void main() {
  setupTests();

  final expectedVersion = configMigrations.length;

  group('ConfigurationService', () {
    late ConfigurationService service;
    late Database database;

    setUpAll(loadLibsql);

    setUp(() async {
      service = ConfigurationService();
      database = Database.memory();
      await service.initialize(database: database);
    });

    tearDown(() async {
      await service.dispose();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        expect(service.isInitialized, isTrue);
        expect(
          service.getCurrentVersion(),
          completion(configMigrations.length),
        );
      });

      test('should not re-initialize if already initialized', () async {
        expect(service.isInitialized, isTrue);

        // Should not throw on re-initialization
        await service.initialize(database: database);
        expect(service.isInitialized, isTrue);
      });
    });

    group('Data Source Configuration', () {
      test('should save and retrieve data source config', () async {
        final now = DateTime.now();
        final settings = CsvDataSourceSettings(delimiter: ',', hasHeader: true);

        final config = DataSourceConfig(
          id: 'test_ds_1',
          name: 'Test Data Source',
          description: 'A test data source configuration',
          type: DataSourceType.csv,
          filename: 'test_data.csv',
          settings: settings,
          createdAt: now,
          updatedAt: now,
        );

        await service.saveDataSourceConfig(config);

        final retrieved = await service.getDataSourceConfig('test_ds_1');
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('test_ds_1'));
        expect(retrieved.name, equals('Test Data Source'));
        expect(retrieved.type, equals(DataSourceType.csv));
        expect(retrieved.filename, equals('test_data.csv'));
        expect(
          retrieved.description,
          equals('A test data source configuration'),
        );

        // Check CSV-specific settings
        final csvSettings = retrieved.settings as CsvDataSourceSettings;
        expect(csvSettings.delimiter, equals(','));
        expect(csvSettings.hasHeader, isTrue);
      });

      test('should return null for non-existent data source config', () async {
        final result = await service.getDataSourceConfig('non_existent');
        expect(result, isNull);
      });

      test('should get all data source configs', () async {
        final now = DateTime.now();
        final settings1 = CsvDataSourceSettings(delimiter: ',');
        final settings2 = SqliteDataSourceSettings();

        final config1 = DataSourceConfig(
          id: 'ds_1',
          name: 'Data Source 1',
          description: 'First data source',
          type: DataSourceType.csv,
          filename: 'data_source_1.csv',
          settings: settings1,
          createdAt: now,
          updatedAt: now,
        );

        final config2 = DataSourceConfig(
          id: 'ds_2',
          name: 'Data Source 2',
          description: 'Second data source',
          type: DataSourceType.sqlite,
          filename: 'data_source_2.db',
          settings: settings2,
          createdAt: now.add(Duration(minutes: 1)),
          updatedAt: now.add(Duration(minutes: 1)),
        );

        await service.saveDataSourceConfig(config1);
        await service.saveDataSourceConfig(config2);

        final allConfigs = await service.getAllDataSourceConfigs();
        expect(allConfigs, hasLength(2));

        expect(
          allConfigs.map((it) => it.id),
          unorderedEquals(['ds_1', 'ds_2']),
        );
      });

      test('should delete data source config', () async {
        final now = DateTime.now();
        final settings = CsvDataSourceSettings();

        final config = DataSourceConfig(
          id: 'to_delete',
          name: 'To Delete',
          description: 'Config to delete',
          type: DataSourceType.csv,
          filename: 'to_delete.csv',
          settings: settings,
          createdAt: now,
          updatedAt: now,
        );

        await service.saveDataSourceConfig(config);

        // Verify it exists
        final before = await service.getDataSourceConfig('to_delete');
        expect(before, isNotNull);

        // Delete it
        await service.deleteDataSourceConfig('to_delete');

        // Verify it's gone
        final after = await service.getDataSourceConfig('to_delete');
        expect(after, isNull);
      });
    });

    group('Embedding Template Configuration', () {
      test('should save and retrieve embedding template config', () async {
        final dsConfig = DataSourceConfig.create(
          id: 'ds_1',
          name: 'Data Source 1',
          description: 'First data source',
          type: DataSourceType.csv,
          filename: 'data_source_1.csv',
          settings: CsvDataSourceSettings(delimiter: ','),
        );
        await service.saveDataSourceConfig(dsConfig);

        final now = DateTime.now();
        final config = EmbeddingTemplate(
          id: 'template_1',
          name: 'Test Template',
          description: 'A test embedding template',
          template: 'Embed this content: {{content}}',
          dataSourceId: dsConfig.id,
          availableFields: ['content', 'title', 'metadata'],
          metadata: <String, dynamic>{'category': 'test', 'priority': 'high'},
          createdAt: now,
          updatedAt: now,
        );

        await service.saveEmbeddingTemplateConfig(config);

        final retrieved = await service.getEmbeddingTemplateConfig(
          'template_1',
        );
        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Test Template'));
        expect(retrieved.template, equals('Embed this content: {{content}}'));
        expect(retrieved.dataSourceId, equals('ds_1'));
        expect(
          retrieved.availableFields,
          equals(['content', 'title', 'metadata']),
        );
        expect(retrieved.metadata['category'], equals('test'));
        expect(retrieved.metadata['priority'], equals('high'));
      });

      test('should get templates by data source ID', () async {
        final now = DateTime.now();

        // Create data source configs first to satisfy foreign key constraints
        final dsConfig1 = DataSourceConfig(
          id: 'ds_1',
          name: 'Data Source 1',
          description: 'First data source',
          type: DataSourceType.csv,
          filename: 'data_source_1.csv',
          settings: CsvDataSourceSettings(delimiter: ','),
          createdAt: now,
          updatedAt: now,
        );

        final dsConfig2 = DataSourceConfig(
          id: 'ds_2',
          name: 'Data Source 2',
          description: 'Second data source',
          type: DataSourceType.sqlite,
          filename: 'data_source_2.db',
          settings: SqliteDataSourceSettings(),
          createdAt: now,
          updatedAt: now,
        );

        await service.saveDataSourceConfig(dsConfig1);
        await service.saveDataSourceConfig(dsConfig2);

        final template1 = EmbeddingTemplate(
          id: 'template_1',
          name: 'Template 1',
          description: 'First template',
          template: '{{content}}',
          dataSourceId: 'ds_1',
          availableFields: ['content'],
          metadata: <String, dynamic>{},
          createdAt: now,
          updatedAt: now,
        );

        final template2 = EmbeddingTemplate(
          id: 'template_2',
          name: 'Template 2',
          description: 'Second template',
          template: '{{title}}: {{content}}',
          dataSourceId: 'ds_1',
          availableFields: ['title', 'content'],
          metadata: <String, dynamic>{},
          createdAt: now.add(Duration(minutes: 1)),
          updatedAt: now.add(Duration(minutes: 1)),
        );

        final template3 = EmbeddingTemplate(
          id: 'template_3',
          name: 'Template 3',
          description: 'Third template for different DS',
          template: '{{data}}',
          dataSourceId: 'ds_2',
          availableFields: ['data'],
          metadata: <String, dynamic>{},
          createdAt: now,
          updatedAt: now,
        );

        await service.saveEmbeddingTemplateConfig(template1);
        await service.saveEmbeddingTemplateConfig(template2);
        await service.saveEmbeddingTemplateConfig(template3);

        final ds1Templates = await service.getEmbeddingTemplatesByDataSource(
          'ds_1',
        );
        expect(ds1Templates, hasLength(2));
        expect(
          ds1Templates.map((t) => t.id),
          containsAll(['template_1', 'template_2']),
        );

        final ds2Templates = await service.getEmbeddingTemplatesByDataSource(
          'ds_2',
        );
        expect(ds2Templates, hasLength(1));
        expect(ds2Templates[0].id, equals('template_3'));
      });

      test('should delete embedding template config', () async {
        final now = DateTime.now();

        // Create data source config first to satisfy foreign key constraint
        final dsConfig = DataSourceConfig(
          id: 'ds_1',
          name: 'Data Source 1',
          description: 'First data source',
          type: DataSourceType.csv,
          filename: 'data_source_1.csv',
          settings: CsvDataSourceSettings(delimiter: ','),
          createdAt: now,
          updatedAt: now,
        );

        await service.saveDataSourceConfig(dsConfig);

        final config = EmbeddingTemplate(
          id: 'to_delete',
          name: 'To Delete',
          description: 'Template to delete',
          template: '{{content}}',
          dataSourceId: 'ds_1',
          availableFields: ['content'],
          metadata: <String, dynamic>{},
          createdAt: now,
          updatedAt: now,
        );

        await service.saveEmbeddingTemplateConfig(config);

        // Verify it exists
        final before = await service.getEmbeddingTemplateConfig('to_delete');
        expect(before, isNotNull);

        // Delete it
        await service.deleteEmbeddingTemplateConfig('to_delete');

        // Verify it's gone
        final after = await service.getEmbeddingTemplateConfig('to_delete');
        expect(after, isNull);
      });
    });

    group('Model Provider Configuration', () {
      test(
        'should save and retrieve model provider config (no persist creds)',
        () async {
          final now = DateTime.now();
          final config = EmbeddingProviderConfig(
            id: 'provider_1',
            name: 'Test OpenAI Provider',
            description: 'OpenAI embedding provider',
            type: EmbeddingProviderType.openai,
            customTemplateId: null,
            settings: <String, dynamic>{
              'apiUrl': 'https://api.openai.com/v1',
              'model': 'text-embedding-3-small',
              'dimensions': 1536,
            },
            credential: ApiKeyCredential('sk-test-key-123'),
            persistCredentials: false,
            enabledModels: {'text-embedding-3-small', 'text-embedding-3-large'},
            createdAt: now,
            updatedAt: now,
          );

          await service.saveModelProviderConfig(config);

          final retrieved = await service.getModelProviderConfig('provider_1');
          expect(retrieved, isNotNull);
          expect(retrieved!.name, equals('Test OpenAI Provider'));
          expect(retrieved.type, equals(EmbeddingProviderType.openai));
          expect(retrieved.persistCredentials, isFalse);
          expect(retrieved.settings['model'], equals('text-embedding-3-small'));
          expect(retrieved.credential, isNull);
          expect(
            retrieved.enabledModels,
            containsAll(['text-embedding-3-small', 'text-embedding-3-large']),
          );
        },
      );

      test(
        'should save and retrieve model provider config (persist creds)',
        () async {
          final now = DateTime.now();
          final config = EmbeddingProviderConfig(
            id: 'provider_1',
            name: 'Test OpenAI Provider',
            description: 'OpenAI embedding provider',
            type: EmbeddingProviderType.openai,
            customTemplateId: null,
            settings: <String, dynamic>{
              'apiUrl': 'https://api.openai.com/v1',
              'model': 'text-embedding-3-small',
              'dimensions': 1536,
            },
            credential: ApiKeyCredential('sk-test-key-123'),
            persistCredentials: true,
            enabledModels: {'text-embedding-3-small', 'text-embedding-3-large'},
            createdAt: now,
            updatedAt: now,
          );

          await service.saveModelProviderConfig(config);

          final retrieved = await service.getModelProviderConfig('provider_1');
          expect(retrieved, isNotNull);
          expect(retrieved!.name, equals('Test OpenAI Provider'));
          expect(retrieved.type, equals(EmbeddingProviderType.openai));
          expect(retrieved.persistCredentials, isFalse);
          expect(retrieved.settings['model'], equals('text-embedding-3-small'));
          expect(
            retrieved.credential,
            isA<ApiKeyCredential>().having(
              (k) => k.apiKey,
              'apiKey',
              equals('sk-test-key-123'),
            ),
          );
          expect(
            retrieved.enabledModels,
            containsAll(['text-embedding-3-small', 'text-embedding-3-large']),
          );
        },
      );

      test('should get active model provider configs only', () async {
        final now = DateTime.now();

        final activeProvider = EmbeddingProviderConfig(
          id: 'active_1',
          name: 'Active Provider',
          description: 'Active provider',
          type: EmbeddingProviderType.openai,
          customTemplateId: null,
          settings: <String, dynamic>{},
          credential: null,
          persistCredentials: false,
          enabledModels: <String>{},
          createdAt: now,
          updatedAt: now,
        );

        final inactiveProvider = EmbeddingProviderConfig(
          id: 'inactive_1',
          name: 'Inactive Provider',
          description: 'Inactive provider',
          type: EmbeddingProviderType.gemini,
          customTemplateId: null,
          settings: <String, dynamic>{},
          credential: null,
          persistCredentials: false,
          enabledModels: <String>{},
          createdAt: now,
          updatedAt: now,
        );

        await service.saveModelProviderConfig(activeProvider);
        await service.saveModelProviderConfig(inactiveProvider);

        final allProviders = await service.getAllModelProviderConfigs();
        expect(allProviders, hasLength(2));
      });

      test('should delete model provider config', () async {
        final now = DateTime.now();
        final config = EmbeddingProviderConfig(
          id: 'to_delete',
          name: 'To Delete',
          description: 'Provider to delete',
          type: EmbeddingProviderType.custom,
          customTemplateId: null,
          settings: <String, dynamic>{},
          credential: null,
          persistCredentials: false,
          enabledModels: <String>{},
          createdAt: now,
          updatedAt: now,
        );

        await service.saveModelProviderConfig(config);

        // Verify it exists
        final before = await service.getModelProviderConfig('to_delete');
        expect(before, isNotNull);

        // Delete it
        await service.deleteModelProviderConfig('to_delete');

        // Verify it's gone
        final after = await service.getModelProviderConfig('to_delete');
        expect(after, isNull);
      });
    });

    group('Custom Provider Template', () {
      test('should save and retrieve custom provider template', () async {
        final now = DateTime.now();
        final template = CustomProviderTemplate(
          id: 'custom_1',
          name: 'Custom API Template',
          description: 'Custom embedding API template',
          icon: 'api-icon',
          baseUri: 'https://api.example.com',
          requiredCredentials: ['apiKey', 'secretKey'],
          defaultSettings: <String, dynamic>{'timeout': 30000, 'retries': 3},
          availableModels: ['model-a', 'model-b'],
          embeddingRequestTemplate: HttpRequestTemplate(
            method: HttpMethod.post,
            path: '/embed',
            headers: {'Content-Type': 'application/json'},
            bodyTemplate: '{"text": "{{text}}", "model": "{{model}}"}',
          ),
          createdAt: now,
          updatedAt: now,
        );

        await service.saveCustomProviderTemplate(template);

        final retrieved = await service.getCustomProviderTemplate('custom_1');
        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Custom API Template'));
        expect(retrieved.baseUri, equals('https://api.example.com'));
        expect(retrieved.requiredCredentials, equals(['apiKey', 'secretKey']));
        expect(retrieved.defaultSettings['timeout'], equals(30000));
        expect(retrieved.availableModels, equals(['model-a', 'model-b']));
        expect(
          retrieved.embeddingRequestTemplate.method,
          equals(HttpMethod.post),
        );
      });

      test('should delete custom provider template', () async {
        final now = DateTime.now();
        final template = CustomProviderTemplate(
          id: 'to_delete',
          name: 'To Delete',
          description: 'Template to delete',
          icon: 'delete-icon',
          baseUri: 'https://delete.com',
          requiredCredentials: [],
          defaultSettings: <String, dynamic>{},
          availableModels: [],
          embeddingRequestTemplate: HttpRequestTemplate(
            method: HttpMethod.post,
            path: '/embed',
            headers: {},
          ),
          createdAt: now,
          updatedAt: now,
        );

        await service.saveCustomProviderTemplate(template);

        // Verify it exists
        final before = await service.getCustomProviderTemplate('to_delete');
        expect(before, isNotNull);

        // Delete it
        await service.deleteCustomProviderTemplate('to_delete');

        // Verify it's gone
        final after = await service.getCustomProviderTemplate('to_delete');
        expect(after, isNull);
      });
    });

    group('Embedding Job', () {
      test('should save and retrieve embedding job', () async {
        final now = DateTime.now();

        // Create prerequisite data source config
        final dsConfig = DataSourceConfig(
          id: 'ds_1',
          name: 'Data Source 1',
          description: 'First data source',
          type: DataSourceType.csv,
          filename: 'data_source_1.csv',
          settings: CsvDataSourceSettings(delimiter: ','),
          createdAt: now,
          updatedAt: now,
        );
        await service.saveDataSourceConfig(dsConfig);

        // Create prerequisite embedding template config
        final templateConfig = EmbeddingTemplate(
          id: 'template_1',
          name: 'Template 1',
          description: 'First template',
          template: '{{content}}',
          dataSourceId: 'ds_1',
          availableFields: ['content'],
          metadata: <String, dynamic>{},
          createdAt: now,
          updatedAt: now,
        );
        await service.saveEmbeddingTemplateConfig(templateConfig);

        // Create prerequisite provider configs
        final provider1Config = EmbeddingProviderConfig(
          id: 'provider_1',
          name: 'Test Provider 1',
          description: 'Test provider 1',
          type: EmbeddingProviderType.openai,
          customTemplateId: null,
          settings: <String, dynamic>{},
          credential: null,
          persistCredentials: false,
          enabledModels: <String>{},
          createdAt: now,
          updatedAt: now,
        );
        await service.saveModelProviderConfig(provider1Config);

        final provider2Config = EmbeddingProviderConfig(
          id: 'provider_2',
          name: 'Test Provider 2',
          description: 'Test provider 2',
          type: EmbeddingProviderType.gemini,
          customTemplateId: null,
          settings: <String, dynamic>{},
          credential: null,
          persistCredentials: false,
          enabledModels: <String>{},
          createdAt: now,
          updatedAt: now,
        );
        await service.saveModelProviderConfig(provider2Config);

        final job = EmbeddingJob(
          id: 'job_1',
          name: 'Test Embedding Job',
          description: 'A test embedding job',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
          providerIds: ['provider_1', 'provider_2'],
          status: JobStatus.pending,
          totalRecords: 1000,
          processedRecords: 0,
          createdAt: now,
          startedAt: null,
          completedAt: null,
          errorMessage: null,
          results: null,
        );

        await service.saveEmbeddingJob(job);

        final retrieved = await service.getEmbeddingJob('job_1');
        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Test Embedding Job'));
        expect(retrieved.status, equals(JobStatus.pending));
        expect(retrieved.dataSourceId, equals('ds_1'));
        expect(retrieved.embeddingTemplateId, equals('template_1'));
        expect(retrieved.providerIds, equals(['provider_1', 'provider_2']));
        expect(retrieved.totalRecords, equals(1000));
        expect(retrieved.processedRecords, equals(0));
        expect(retrieved.startedAt, isNull);
        expect(retrieved.completedAt, isNull);
        expect(retrieved.errorMessage, isNull);
        expect(retrieved.results, isNull);
      });

      test('should get jobs by status', () async {
        final now = DateTime.now();

        // Create prerequisite data source config
        final dsConfig = DataSourceConfig(
          id: 'ds_1',
          name: 'Data Source 1',
          description: 'First data source',
          type: DataSourceType.csv,
          filename: 'data_source_1.csv',
          settings: CsvDataSourceSettings(delimiter: ','),
          createdAt: now,
          updatedAt: now,
        );
        await service.saveDataSourceConfig(dsConfig);

        // Create prerequisite embedding template config
        final templateConfig = EmbeddingTemplate(
          id: 'template_1',
          name: 'Template 1',
          description: 'First template',
          template: '{{content}}',
          dataSourceId: 'ds_1',
          availableFields: ['content'],
          metadata: <String, dynamic>{},
          createdAt: now,
          updatedAt: now,
        );
        await service.saveEmbeddingTemplateConfig(templateConfig);

        // Create prerequisite provider config
        final providerConfig = EmbeddingProviderConfig(
          id: 'provider_1',
          name: 'Test Provider 1',
          description: 'Test provider 1',
          type: EmbeddingProviderType.openai,
          customTemplateId: null,
          settings: <String, dynamic>{},
          credential: null,
          persistCredentials: false,
          enabledModels: <String>{},
          createdAt: now,
          updatedAt: now,
        );
        await service.saveModelProviderConfig(providerConfig);

        final pendingJob = EmbeddingJob(
          id: 'pending_job',
          name: 'Pending Job',
          description: 'A pending job',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
          providerIds: ['provider_1'],
          status: JobStatus.pending,
          totalRecords: 100,
          processedRecords: 0,
          createdAt: now,
          startedAt: null,
          completedAt: null,
          errorMessage: null,
          results: null,
        );

        final runningJob = EmbeddingJob(
          id: 'running_job',
          name: 'Running Job',
          description: 'A running job',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
          providerIds: ['provider_1'],
          status: JobStatus.running,
          totalRecords: 200,
          processedRecords: 50,
          createdAt: now,
          startedAt: now.add(Duration(minutes: 1)),
          completedAt: null,
          errorMessage: null,
          results: null,
        );

        final completedJob = EmbeddingJob(
          id: 'completed_job',
          name: 'Completed Job',
          description: 'A completed job',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
          providerIds: ['provider_1'],
          status: JobStatus.completed,
          totalRecords: 150,
          processedRecords: 150,
          createdAt: now,
          startedAt: now.add(Duration(minutes: 1)),
          completedAt: now.add(Duration(minutes: 5)),
          errorMessage: null,
          results: <String, dynamic>{'embeddings_generated': 150},
        );

        await service.saveEmbeddingJob(pendingJob);
        await service.saveEmbeddingJob(runningJob);
        await service.saveEmbeddingJob(completedJob);

        final pendingJobs = await service.getEmbeddingJobsByStatus('pending');
        expect(pendingJobs, hasLength(1));
        expect(pendingJobs[0].id, equals('pending_job'));

        final runningJobs = await service.getEmbeddingJobsByStatus('running');
        expect(runningJobs, hasLength(1));
        expect(runningJobs[0].id, equals('running_job'));

        final completedJobs = await service.getEmbeddingJobsByStatus(
          'completed',
        );
        expect(completedJobs, hasLength(1));
        expect(completedJobs[0].id, equals('completed_job'));

        final allJobs = await service.getAllEmbeddingJobs();
        expect(allJobs, hasLength(3));
      });

      test('should delete embedding job', () async {
        final now = DateTime.now();

        // Create prerequisite data source config
        final dsConfig = DataSourceConfig(
          id: 'ds_1',
          name: 'Data Source 1',
          description: 'First data source',
          type: DataSourceType.csv,
          filename: 'data_source_1.csv',
          settings: CsvDataSourceSettings(delimiter: ','),
          createdAt: now,
          updatedAt: now,
        );
        await service.saveDataSourceConfig(dsConfig);

        // Create prerequisite embedding template config
        final templateConfig = EmbeddingTemplate(
          id: 'template_1',
          name: 'Template 1',
          description: 'First template',
          template: '{{content}}',
          dataSourceId: 'ds_1',
          availableFields: ['content'],
          metadata: <String, dynamic>{},
          createdAt: now,
          updatedAt: now,
        );
        await service.saveEmbeddingTemplateConfig(templateConfig);

        // Create prerequisite provider config
        final providerConfig = EmbeddingProviderConfig(
          id: 'provider_1',
          name: 'Test Provider 1',
          description: 'Test provider 1',
          type: EmbeddingProviderType.openai,
          customTemplateId: null,
          settings: <String, dynamic>{},
          credential: null,
          persistCredentials: false,
          enabledModels: <String>{},
          createdAt: now,
          updatedAt: now,
        );
        await service.saveModelProviderConfig(providerConfig);

        final job = EmbeddingJob(
          id: 'to_delete',
          name: 'Job to Delete',
          description: 'Job that will be deleted',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
          providerIds: ['provider_1'],
          status: JobStatus.failed,
          totalRecords: 10,
          processedRecords: 5,
          createdAt: now,
          startedAt: now,
          completedAt: null,
          errorMessage: 'Test error',
          results: null,
        );

        await service.saveEmbeddingJob(job);

        // Verify it exists
        final before = await service.getEmbeddingJob('to_delete');
        expect(before, isNotNull);

        // Delete it
        await service.deleteEmbeddingJob('to_delete');

        // Verify it's gone
        final after = await service.getEmbeddingJob('to_delete');
        expect(after, isNull);
      });
    });

    group('Database Operations', () {
      test('should execute raw SQL queries', () async {
        // Insert test data
        await service.database.execute(
          '''
          INSERT INTO data_sources 
          (id, name, description, type, filename, settings, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            'raw_test',
            'Raw SQL Test',
            'Test description',
            'csv',
            'test.csv',
            '{"delimiter": ","}',
            DateTime.now().toIso8601String(),
            DateTime.now().toIso8601String(),
          ],
        );

        // Query the data
        final result = await service.database.select(
          'SELECT * FROM data_sources WHERE id = ?',
          ['raw_test'],
        );

        expect(result, hasLength(1));
        expect(result.first['name'], equals('Raw SQL Test'));
      });

      test('should handle transactions correctly', () async {
        // Insert data in a transaction
        await service.database.transaction((tx) {
          final emptySettings = jsonEncode(SqliteDataSourceSettings().toJson());
          tx.execute(
            '''
            INSERT INTO data_sources 
            (id, name, description, type, filename, settings, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          ''',
            [
              'tx_test_1',
              'Transaction Test 1',
              'First test',
              'csv',
              'test.csv',
              emptySettings,
              DateTime.now().toIso8601String(),
              DateTime.now().toIso8601String(),
            ],
          );

          tx.execute(
            '''
            INSERT INTO data_sources 
            (id, name, description, type, filename, settings, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          ''',
            [
              'tx_test_2',
              'Transaction Test 2',
              'Second test',
              'sqlite',
              'test.db',
              emptySettings,
              DateTime.now().toIso8601String(),
              DateTime.now().toIso8601String(),
            ],
          );
        });

        // Verify both records were inserted
        final result1 = await service.getDataSourceConfig('tx_test_1');
        final result2 = await service.getDataSourceConfig('tx_test_2');

        expect(result1, isNotNull);
        expect(result1!.name, equals('Transaction Test 1'));
        expect(result2, isNotNull);
        expect(result2!.name, equals('Transaction Test 2'));
      });

      test('should handle migration operations', () async {
        final currentVersion = await service.getCurrentVersion();
        expect(currentVersion, equals(expectedVersion));

        // Migration operations should work without error
        await service.migrateUp();
        await service.migrateDown(to: 0);
        await service.migrateUp(to: 1);

        final finalVersion = await service.getCurrentVersion();
        expect(finalVersion, equals(1));
      });
    });

    group('Embedding Table Management', () {
      test('should create embedding table', () async {
        final now = DateTime.now();

        // Create prerequisite data source config
        final dsConfig = DataSourceConfig(
          id: 'ds_1',
          name: 'Data Source 1',
          description: 'First data source',
          type: DataSourceType.csv,
          filename: 'data_source_1.csv',
          settings: CsvDataSourceSettings(delimiter: ','),
          createdAt: now,
          updatedAt: now,
        );
        await service.saveDataSourceConfig(dsConfig);

        // Create prerequisite embedding template config
        final templateConfig = EmbeddingTemplate(
          id: 'template_1',
          name: 'Template 1',
          description: 'First template',
          template: '{{content}}',
          dataSourceId: 'ds_1',
          availableFields: ['content'],
          metadata: <String, dynamic>{},
          createdAt: now,
          updatedAt: now,
        );
        await service.saveEmbeddingTemplateConfig(templateConfig);

        // Create prerequisite job
        final job = EmbeddingJob(
          id: 'job_1',
          name: 'Test Job',
          description: 'Test job',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
          providerIds: [],
          status: JobStatus.pending,
          totalRecords: 0,
          processedRecords: 0,
          createdAt: now,
          startedAt: null,
          completedAt: null,
          errorMessage: null,
          results: null,
        );
        await service.saveEmbeddingJob(job);

        final tableId = await service.createEmbeddingTable(
          jobId: 'job_1',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
          description: 'Test embedding table',
        );

        expect(tableId, isNotNull);
        expect(tableId, startsWith('et_'));

        // Verify table was registered
        final tables = await service.getEmbeddingTables(jobId: 'job_1');
        expect(tables, hasLength(1));
        expect(tables[0].id, equals(tableId));
        expect(tables[0].jobId, equals('job_1'));
        expect(tables[0].dataSourceId, equals('ds_1'));
        expect(tables[0].embeddingTemplateId, equals('template_1'));
        expect(tables[0].description, equals('Test embedding table'));
      });

      test('should add vector column to embedding table', () async {
        final now = DateTime.now();

        // Create prerequisite data source config
        final dsConfig = DataSourceConfig(
          id: 'ds_1',
          name: 'Data Source 1',
          description: 'First data source',
          type: DataSourceType.csv,
          filename: 'data_source_1.csv',
          settings: CsvDataSourceSettings(delimiter: ','),
          createdAt: now,
          updatedAt: now,
        );
        await service.saveDataSourceConfig(dsConfig);

        // Create prerequisite embedding template config
        final templateConfig = EmbeddingTemplate(
          id: 'template_1',
          name: 'Template 1',
          description: 'First template',
          template: '{{content}}',
          dataSourceId: 'ds_1',
          availableFields: ['content'],
          metadata: <String, dynamic>{},
          createdAt: now,
          updatedAt: now,
        );
        await service.saveEmbeddingTemplateConfig(templateConfig);

        // Create prerequisite job
        final job = EmbeddingJob(
          id: 'job_1',
          name: 'Test Job',
          description: 'Test job',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
          providerIds: [],
          status: JobStatus.pending,
          totalRecords: 0,
          processedRecords: 0,
          createdAt: now,
          startedAt: null,
          completedAt: null,
          errorMessage: null,
          results: null,
        );
        await service.saveEmbeddingJob(job);

        // Create prerequisite provider config
        final providerConfig = EmbeddingProviderConfig(
          id: 'provider_1',
          name: 'Test Provider 1',
          description: 'Test provider 1',
          type: EmbeddingProviderType.openai,
          customTemplateId: null,
          settings: <String, dynamic>{},
          credential: null,
          persistCredentials: false,
          enabledModels: <String>{},
          createdAt: now,
          updatedAt: now,
        );
        await service.saveModelProviderConfig(providerConfig);

        // Create a table first
        final tableId = await service.createEmbeddingTable(
          jobId: 'job_1',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
        );

        // Add a vector column
        await service.addVectorColumn(
          tableId: tableId,
          modelProviderId: 'provider_1',
          modelName: 'text-embedding-3-small',
          vectorType: VectorType.float32,
          dimensions: 1536,
        );

        // Verify column was registered
        final columns = await service.getEmbeddingColumns(tableId);
        expect(columns, hasLength(1));
        expect(columns[0].tableId, equals(tableId));
        expect(columns[0].modelProviderId, equals('provider_1'));
        expect(columns[0].modelName, equals('text-embedding-3-small'));
        expect(columns[0].vectorType, equals(VectorType.float32));
        expect(columns[0].dimensions, equals(1536));
        expect(columns[0].columnName, contains('text_embedding_3_small'));
      });

      test('should insert embedding data', () async {
        // Create full test setup
        await TestHelpers.createFullTestSetup(service);

        // Create table and add vector column
        final tableId = await service.createEmbeddingTable(
          jobId: 'job_1',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
        );

        await service.addVectorColumn(
          tableId: tableId,
          modelProviderId: 'provider_1',
          modelName: 'test-model',
          vectorType: VectorType.float32,
          dimensions: 3,
        );

        // Get column info for embedding data
        final columns = await service.getEmbeddingColumns(tableId);
        final columnName = columns[0].columnName;

        // Insert test data
        final sourceData = {'content': 'Hello world', 'title': 'Test Document'};
        final embeddings = {
          columnName: [0.1, 0.2, 0.3],
        };

        await expectLater(
          service.insertEmbeddingData(
            tableId: tableId,
            recordId: 'record_1',
            sourceData: sourceData,
            embeddings: embeddings,
          ),
          completes,
        );

        // Verify data was inserted by querying the actual table
        // The table name is the same as the tableId
        final tableName = tableId;
        final result = await service.database.select(
          'SELECT * FROM $tableName WHERE id = ?',
          ['record_1'],
        );

        expect(result, hasLength(1));
        final row = result.first;
        expect(row['id'], equals('record_1'));

        // Verify source data was stored as JSON
        final storedSourceData = jsonDecode(row['source_data'] as String);
        expect(storedSourceData['content'], equals('Hello world'));
        expect(storedSourceData['title'], equals('Test Document'));

        // Verify the vector column exists and has data
        expect(row[columnName], isNotNull);
        expect(row['created_at'], isNotNull);
      });

      test('should create vector index', () async {
        // Create full test setup
        await TestHelpers.createFullTestSetup(service);

        // Create table and add vector column
        final tableId = await service.createEmbeddingTable(
          jobId: 'job_1',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
        );

        await service.addVectorColumn(
          tableId: tableId,
          modelProviderId: 'provider_1',
          modelName: 'test-model',
          vectorType: VectorType.float32,
          dimensions: 3,
        );

        final columns = await service.getEmbeddingColumns(tableId);
        final columnName = columns[0].columnName;

        // Create vector index
        await expectLater(
          service.createVectorIndex(
            tableId: tableId,
            columnName: columnName,
            metric: 'cosine',
            maxNeighbors: 100,
          ),
          completes,
        );
      });

      test('should search similar vectors', () async {
        // Create full test setup
        await TestHelpers.createFullTestSetup(service);

        // Create table and add vector column
        final tableId = await service.createEmbeddingTable(
          jobId: 'job_1',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
        );

        await service.addVectorColumn(
          tableId: tableId,
          modelProviderId: 'provider_1',
          modelName: 'test-model',
          vectorType: VectorType.float32,
          dimensions: 3,
        );

        final columns = await service.getEmbeddingColumns(tableId);
        final columnName = columns[0].columnName;

        // Insert some test data
        await service.insertEmbeddingData(
          tableId: tableId,
          recordId: 'record_1',
          sourceData: {'content': 'Hello world'},
          embeddings: {
            columnName: [0.1, 0.2, 0.3],
          },
        );

        await service.insertEmbeddingData(
          tableId: tableId,
          recordId: 'record_2',
          sourceData: {'content': 'Goodbye world'},
          embeddings: {
            columnName: [0.4, 0.5, 0.6],
          },
        );

        // Search for similar vectors
        final results = await service.searchSimilarVectors(
          tableId: tableId,
          columnName: columnName,
          queryVector: [0.1, 0.2, 0.3],
          vectorType: VectorType.float32,
          limit: 5,
        );

        expect(results, isNotEmpty);
        expect(
          results[0].id,
          equals('record_1'),
        ); // Should match closest vector
        expect(results[0].sourceData['content'], equals('Hello world'));
        expect(results[0].distance, isA<double>());
      });

      test('should get embedding tables with filters', () async {
        // Create test setups for different combinations
        await TestHelpers.createFullTestSetup(
          service,
          dataSourceId: 'ds_1',
          templateId: 'template_1',
          jobId: 'job_1',
        );

        await TestHelpers.createFullTestSetup(
          service,
          dataSourceId: 'ds_2',
          templateId: 'template_2',
          jobId: 'job_2',
        );

        // Create tables for different jobs and data sources
        final table1 = await service.createEmbeddingTable(
          jobId: 'job_1',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
          description: 'Table 1',
        );

        final table2 = await service.createEmbeddingTable(
          jobId: 'job_2',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
          description: 'Table 2',
        );

        final table3 = await service.createEmbeddingTable(
          jobId: 'job_1',
          dataSourceId: 'ds_2',
          embeddingTemplateId: 'template_1',
          description: 'Table 3',
        );

        // Test filtering by job ID
        final job1Tables = await service.getEmbeddingTables(jobId: 'job_1');
        expect(job1Tables, hasLength(2));
        expect(job1Tables.map((t) => t.id), containsAll([table1, table3]));

        // Test filtering by data source ID
        final ds1Tables = await service.getEmbeddingTables(
          dataSourceId: 'ds_1',
        );
        expect(ds1Tables, hasLength(2));
        expect(ds1Tables.map((t) => t.id), containsAll([table1, table2]));

        // Test filtering by both
        final filteredTables = await service.getEmbeddingTables(
          jobId: 'job_1',
          dataSourceId: 'ds_1',
        );
        expect(filteredTables, hasLength(1));
        expect(filteredTables[0].id, equals(table1));

        // Test getting all tables
        final allTables = await service.getEmbeddingTables();
        expect(allTables, hasLength(3));
      });

      test('should delete embedding table', () async {
        // Create full test setup
        await TestHelpers.createFullTestSetup(service);

        // Create a table
        final tableId = await service.createEmbeddingTable(
          jobId: 'job_1',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
        );

        // Add a vector column
        await service.addVectorColumn(
          tableId: tableId,
          modelProviderId: 'provider_1',
          modelName: 'test-model',
          vectorType: VectorType.float32,
          dimensions: 3,
        );

        // Verify table and column exist
        final tablesBefore = await service.getEmbeddingTables();
        final columnsBefore = await service.getEmbeddingColumns(tableId);
        expect(tablesBefore, hasLength(1));
        expect(columnsBefore, hasLength(1));

        // Delete the table
        await service.deleteEmbeddingTable(tableId);

        // Verify table and columns are gone from registry
        final tablesAfter = await service.getEmbeddingTables();
        final columnsAfter = await service.getEmbeddingColumns(tableId);
        expect(tablesAfter, hasLength(0));
        expect(columnsAfter, hasLength(0));
      });

      test('should handle errors gracefully', () async {
        // Test operations on non-existent table
        await expectLater(
          service.addVectorColumn(
            tableId: 'non_existent',
            modelProviderId: 'provider_1',
            modelName: 'test-model',
            vectorType: VectorType.float32,
            dimensions: 3,
          ),
          throwsStateError,
        );

        await expectLater(
          service.insertEmbeddingData(
            tableId: 'non_existent',
            recordId: 'record_1',
            sourceData: {'content': 'test'},
          ),
          throwsStateError,
        );

        await expectLater(
          service.searchSimilarVectors(
            tableId: 'non_existent',
            columnName: 'test_column',
            queryVector: [0.1, 0.2, 0.3],
            vectorType: VectorType.float32,
          ),
          throwsStateError,
        );

        await expectLater(
          service.createVectorIndex(
            tableId: 'non_existent',
            columnName: 'test_column',
          ),
          throwsStateError,
        );
      });

      test('should handle multiple vector columns', () async {
        // Create full test setup with provider_1
        await TestHelpers.createFullTestSetup(service);

        // Create additional provider_2
        final provider2Config = TestHelpers.createProviderConfig(
          id: 'provider_2',
          name: 'Test Provider 2',
          type: EmbeddingProviderType.gemini,
        );
        await service.saveModelProviderConfig(provider2Config);

        // Create table
        final tableId = await service.createEmbeddingTable(
          jobId: 'job_1',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
        );

        // Add multiple vector columns
        await service.addVectorColumn(
          tableId: tableId,
          modelProviderId: 'provider_1',
          modelName: 'model-a',
          vectorType: VectorType.float32,
          dimensions: 3,
        );

        await service.addVectorColumn(
          tableId: tableId,
          modelProviderId: 'provider_2',
          modelName: 'model-b',
          vectorType: VectorType.float16,
          dimensions: 5,
        );

        // Verify both columns were registered
        final columns = await service.getEmbeddingColumns(tableId);
        expect(columns, hasLength(2));

        final columnA = columns.firstWhere((c) => c.modelName == 'model-a');
        final columnB = columns.firstWhere((c) => c.modelName == 'model-b');

        expect(columnA.vectorType, equals(VectorType.float32));
        expect(columnA.dimensions, equals(3));
        expect(columnB.vectorType, equals(VectorType.float16));
        expect(columnB.dimensions, equals(5));

        // Insert data with embeddings for both columns
        final embeddings = {
          columnA.columnName: [0.1, 0.2, 0.3],
          columnB.columnName: [0.1, 0.2, 0.3, 0.4, 0.5],
        };

        await expectLater(
          service.insertEmbeddingData(
            tableId: tableId,
            recordId: 'record_1',
            sourceData: {'content': 'test'},
            embeddings: embeddings,
          ),
          completes,
        );
      });
    });

    group('Disposal', () {
      test('should dispose resources properly', () async {
        expect(service.isInitialized, isTrue);

        await service.dispose();
        expect(service.isInitialized, isFalse);

        // Should throw after disposal
        expect(() => service.database, throwsStateError);
      });
    });
  });
}

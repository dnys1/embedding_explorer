@TestOn('browser')
library;

import 'dart:convert';

import 'package:embeddings_explorer/configurations/service/configuration_service.dart';
import 'package:embeddings_explorer/data_sources/model/data_source_config.dart';
import 'package:embeddings_explorer/data_sources/model/data_source_settings.dart';
import 'package:embeddings_explorer/jobs/model/embedding_job.dart';
import 'package:embeddings_explorer/providers/model/custom_provider_template.dart';
import 'package:embeddings_explorer/providers/model/model_provider_config.dart';
import 'package:embeddings_explorer/templates/model/embedding_template_config.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  setupTests();

  group('ConfigurationService', () {
    late ConfigurationService service;

    setUp(() {
      service = ConfigurationService(
        databasePath: ':memory:',
        libsqlUri: testLibsqlUri,
      );
    });

    tearDown(() async {
      service.dispose();
    });

    group('Initialization', () {
      test('should initialize successfully with default settings', () async {
        expect(service.isInitialized, isFalse);

        await service.initialize();

        expect(service.isInitialized, isTrue);
        expect(service.getCurrentVersion(), completion(equals(1)));
      });

      test('should throw when accessing database before initialization', () {
        expect(() => service.database, throwsStateError);
      });

      test('should not re-initialize if already initialized', () async {
        await service.initialize();
        expect(service.isInitialized, isTrue);

        // Should not throw on re-initialization
        await service.initialize();
        expect(service.isInitialized, isTrue);
      });
    });

    group('Data Source Configuration', () {
      setUp(() async {
        await service.initialize();
      });

      test('should save and retrieve data source config', () async {
        final now = DateTime.now();
        final settings = CsvDataSourceSettings(
          delimiter: ',',
          hasHeader: true,
          content: 'name,age\nJohn,30\nJane,25',
          source: 'text',
        );

        final config = DataSourceConfig(
          id: 'test_ds_1',
          name: 'Test Data Source',
          description: 'A test data source configuration',
          type: DataSourceType.csv,
          settings: settings,
          createdAt: now,
          updatedAt: now,
        );

        await service.saveDataSourceConfig(config);

        final retrieved = await service.getDataSourceConfig('test_ds_1');
        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Test Data Source'));
        expect(retrieved.type, equals(DataSourceType.csv));
        expect(
          retrieved.description,
          equals('A test data source configuration'),
        );

        // Check CSV-specific settings
        final csvSettings = retrieved.settings as CsvDataSourceSettings;
        expect(csvSettings.delimiter, equals(','));
        expect(csvSettings.hasHeader, isTrue);
        expect(csvSettings.source, equals('text'));
      });

      test('should return null for non-existent data source config', () async {
        final result = await service.getDataSourceConfig('non_existent');
        expect(result, isNull);
      });

      test('should get all data source configs', () async {
        final now = DateTime.now();
        final settings1 = CsvDataSourceSettings(delimiter: ',', source: 'file');
        final settings2 = SqliteDataSourceSettings();

        final config1 = DataSourceConfig(
          id: 'ds_1',
          name: 'Data Source 1',
          description: 'First data source',
          type: DataSourceType.csv,
          settings: settings1,
          createdAt: now,
          updatedAt: now,
        );

        final config2 = DataSourceConfig(
          id: 'ds_2',
          name: 'Data Source 2',
          description: 'Second data source',
          type: DataSourceType.sqlite,
          settings: settings2,
          createdAt: now.add(Duration(minutes: 1)),
          updatedAt: now.add(Duration(minutes: 1)),
        );

        await service.saveDataSourceConfig(config1);
        await service.saveDataSourceConfig(config2);

        final allConfigs = await service.getAllDataSourceConfigs();
        expect(allConfigs, hasLength(2));

        // Should be ordered by created_at DESC (most recent first)
        expect(allConfigs[0].id, equals('ds_2'));
        expect(allConfigs[1].id, equals('ds_1'));
      });

      test('should delete data source config', () async {
        final now = DateTime.now();
        final settings = CsvDataSourceSettings(source: 'file');

        final config = DataSourceConfig(
          id: 'to_delete',
          name: 'To Delete',
          description: 'Config to delete',
          type: DataSourceType.csv,
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
      setUp(() async {
        await service.initialize();
      });

      test('should save and retrieve embedding template config', () async {
        final now = DateTime.now();
        final config = EmbeddingTemplateConfig(
          id: 'template_1',
          name: 'Test Template',
          description: 'A test embedding template',
          template: 'Embed this content: {{content}}',
          dataSourceId: 'ds_1',
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

        final template1 = EmbeddingTemplateConfig(
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

        final template2 = EmbeddingTemplateConfig(
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

        final template3 = EmbeddingTemplateConfig(
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
        final config = EmbeddingTemplateConfig(
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
      setUp(() async {
        await service.initialize();
      });

      test('should save and retrieve model provider config', () async {
        final now = DateTime.now();
        final config = ModelProviderConfig(
          id: 'provider_1',
          name: 'Test OpenAI Provider',
          description: 'OpenAI embedding provider',
          type: ProviderType.openai,
          customTemplateId: null,
          settings: <String, dynamic>{
            'apiUrl': 'https://api.openai.com/v1',
            'model': 'text-embedding-3-small',
            'dimensions': 1536,
          },
          credentials: <String, String>{'apiKey': 'sk-test-key-123'},
          isActive: true,
          persistCredentials: false,
          enabledModels: {'text-embedding-3-small', 'text-embedding-3-large'},
          createdAt: now,
          updatedAt: now,
        );

        await service.saveModelProviderConfig(config);

        final retrieved = await service.getModelProviderConfig('provider_1');
        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Test OpenAI Provider'));
        expect(retrieved.type, equals(ProviderType.openai));
        expect(retrieved.isActive, isTrue);
        expect(retrieved.persistCredentials, isFalse);
        expect(retrieved.settings['model'], equals('text-embedding-3-small'));
        expect(retrieved.credentials['apiKey'], equals('sk-test-key-123'));
        expect(
          retrieved.enabledModels,
          containsAll(['text-embedding-3-small', 'text-embedding-3-large']),
        );
      });

      test('should get active model provider configs only', () async {
        final now = DateTime.now();

        final activeProvider = ModelProviderConfig(
          id: 'active_1',
          name: 'Active Provider',
          description: 'Active provider',
          type: ProviderType.openai,
          customTemplateId: null,
          settings: <String, dynamic>{},
          credentials: <String, String>{},
          isActive: true,
          persistCredentials: false,
          enabledModels: <String>{},
          createdAt: now,
          updatedAt: now,
        );

        final inactiveProvider = ModelProviderConfig(
          id: 'inactive_1',
          name: 'Inactive Provider',
          description: 'Inactive provider',
          type: ProviderType.gemini,
          customTemplateId: null,
          settings: <String, dynamic>{},
          credentials: <String, String>{},
          isActive: false,
          persistCredentials: false,
          enabledModels: <String>{},
          createdAt: now,
          updatedAt: now,
        );

        await service.saveModelProviderConfig(activeProvider);
        await service.saveModelProviderConfig(inactiveProvider);

        final activeProviders = await service.getActiveModelProviderConfigs();
        expect(activeProviders, hasLength(1));
        expect(activeProviders[0].id, equals('active_1'));
        expect(activeProviders[0].isActive, isTrue);

        final allProviders = await service.getAllModelProviderConfigs();
        expect(allProviders, hasLength(2));
      });

      test('should delete model provider config', () async {
        final now = DateTime.now();
        final config = ModelProviderConfig(
          id: 'to_delete',
          name: 'To Delete',
          description: 'Provider to delete',
          type: ProviderType.custom,
          customTemplateId: null,
          settings: <String, dynamic>{},
          credentials: <String, String>{},
          isActive: false,
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
      setUp(() async {
        await service.initialize();
      });

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
      setUp(() async {
        await service.initialize();
      });

      test('should save and retrieve embedding job', () async {
        final now = DateTime.now();
        final job = EmbeddingJob(
          id: 'job_1',
          name: 'Test Embedding Job',
          description: 'A test embedding job',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
          modelProviderIds: ['provider_1', 'provider_2'],
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
        expect(
          retrieved.modelProviderIds,
          equals(['provider_1', 'provider_2']),
        );
        expect(retrieved.totalRecords, equals(1000));
        expect(retrieved.processedRecords, equals(0));
        expect(retrieved.startedAt, isNull);
        expect(retrieved.completedAt, isNull);
        expect(retrieved.errorMessage, isNull);
        expect(retrieved.results, isNull);
      });

      test('should get jobs by status', () async {
        final now = DateTime.now();

        final pendingJob = EmbeddingJob(
          id: 'pending_job',
          name: 'Pending Job',
          description: 'A pending job',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
          modelProviderIds: ['provider_1'],
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
          modelProviderIds: ['provider_1'],
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
          modelProviderIds: ['provider_1'],
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
        final job = EmbeddingJob(
          id: 'to_delete',
          name: 'Job to Delete',
          description: 'Job that will be deleted',
          dataSourceId: 'ds_1',
          embeddingTemplateId: 'template_1',
          modelProviderIds: ['provider_1'],
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
      setUp(() async {
        await service.initialize();
      });

      test('should execute raw SQL queries', () async {
        // Insert test data
        await service.database.execute(
          '''
          INSERT INTO data_source_configs 
          (id, name, description, type, settings, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            'raw_test',
            'Raw SQL Test',
            'Test description',
            'csv',
            '{"delimiter": ","}',
            DateTime.now().toIso8601String(),
            DateTime.now().toIso8601String(),
          ],
        );

        // Query the data
        final result = await service.database.select(
          'SELECT * FROM data_source_configs WHERE id = ?',
          ['raw_test'],
        );

        expect(result.rows, hasLength(1));
        expect(result.rows.first[1], equals('Raw SQL Test')); // name column
      });

      test('should handle transactions correctly', () async {
        // Insert data in a transaction
        await service.database.transaction((tx) {
          final emptySettings = jsonEncode(SqliteDataSourceSettings().toJson());
          tx.execute(
            '''
            INSERT INTO data_source_configs 
            (id, name, description, type, settings, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
          ''',
            [
              'tx_test_1',
              'Transaction Test 1',
              'First test',
              'csv',
              emptySettings,
              DateTime.now().toIso8601String(),
              DateTime.now().toIso8601String(),
            ],
          );

          tx.execute(
            '''
            INSERT INTO data_source_configs 
            (id, name, description, type, settings, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
          ''',
            [
              'tx_test_2',
              'Transaction Test 2',
              'Second test',
              'sqlite',
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
        expect(currentVersion, equals(1));

        // Migration operations should work without error
        await service.migrateUp();
        await service.migrateDown(to: 0);
        await service.migrateUp(to: 1);

        final finalVersion = await service.getCurrentVersion();
        expect(finalVersion, equals(1));
      });
    });

    group('Disposal', () {
      test('should dispose resources properly', () async {
        await service.initialize();
        expect(service.isInitialized, isTrue);

        service.dispose();
        expect(service.isInitialized, isFalse);

        // Should throw after disposal
        expect(() => service.database, throwsStateError);
      });
    });
  });
}

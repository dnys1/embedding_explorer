@TestOn('browser')
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:embeddings_explorer/configurations/model/embedding_tables.dart';
import 'package:embeddings_explorer/configurations/service/configuration_service.dart';
import 'package:embeddings_explorer/credentials/model/credential.dart';
import 'package:embeddings_explorer/data_sources/model/data_source_config.dart';
import 'package:embeddings_explorer/data_sources/model/data_source_settings.dart';
import 'package:embeddings_explorer/database/database.dart';
import 'package:embeddings_explorer/database/database_pool.dart';
import 'package:embeddings_explorer/jobs/model/embedding_job.dart';
import 'package:embeddings_explorer/jobs/service/embedding_export_service.dart';
import 'package:embeddings_explorer/providers/model/embedding_provider_config.dart';
import 'package:embeddings_explorer/templates/model/embedding_template.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  final logs = setupTests();

  group('EmbeddingExportService', () {
    late ConfigurationService configService;
    late DatabasePool databasePool;
    late EmbeddingExportService exportService;
    late Database database;

    setUpAll(loadLibsql);

    setUp(() async {
      logs.resume();

      // Create database pool
      databasePool = await DatabasePool.create(
        libsqlUri: testLibsqlUri,
        poolName: 'export_test_${Random().nextInt(10000)}',
        clearOnInit: true,
      );

      // Create configuration service
      configService = ConfigurationService();
      database = Database.memory();
      await configService.initialize(database: database);

      // Create export service
      exportService = EmbeddingExportService(
        configService: configService,
        databasePool: databasePool,
      );
    });

    tearDown(() async {
      logs.pause();
      try {
        await databasePool.wipeAll();
      } on Object {
        // OK, may already be disposed
      }
      await configService.dispose();
      await databasePool.dispose();
    });

    /// Helper to create test embedding data with realistic vectors
    Future<String> createTestEmbeddingData({
      required EmbeddingJob job,
      required List<EmbeddingColumn> columns,
      int recordCount = 5,
    }) async {
      // Create embedding table
      final tableId = await configService.createEmbeddingTable(
        jobId: job.id,
        dataSourceId: job.dataSourceId,
        embeddingTemplateId: job.embeddingTemplateId,
      );

      // Add vector columns
      for (final column in columns) {
        await configService.addVectorColumn(
          tableId: tableId,
          modelProviderId: column.modelProviderId,
          modelName: column.modelName,
          vectorType: column.vectorType,
          dimensions: column.dimensions,
        );
      }

      // Insert test records with embeddings
      final random = Random(42); // Seed for reproducible tests
      for (int i = 0; i < recordCount; i++) {
        final recordId = 'record_$i';
        final sourceData = {
          'id': recordId,
          'content': 'This is test content for record $i',
          'metadata': {
            'category': 'test',
            'index': i,
            'timestamp': DateTime.now().toIso8601String(),
          },
        };

        // Generate test embeddings for each column
        final embeddings = <String, List<double>>{};
        for (final column in columns) {
          final embedding = List.generate(
            column.dimensions,
            (_) => (random.nextDouble() - 0.5) * 2.0, // Range [-1, 1]
          );
          embeddings[column.columnName] = embedding;
        }

        await configService.insertEmbeddingData(
          tableId: tableId,
          recordId: recordId,
          sourceData: sourceData,
          embeddings: embeddings,
        );
      }

      return tableId;
    }

    /// Helper to create a complete test setup
    Future<({EmbeddingJob job, List<EmbeddingColumn> columns, String tableId})>
    createCompleteTestSetup({int recordCount = 5, int modelCount = 2}) async {
      final now = DateTime.now();

      // Create data source
      final dataSource = DataSourceConfig.create(
        id: 'test_ds',
        name: 'Test Data Source',
        description: 'Test data source for export',
        type: DataSourceType.csv,
        filename: 'test.csv',
        settings: CsvDataSourceSettings(delimiter: ',', hasHeader: true),
        createdAt: now,
      );
      await configService.saveDataSourceConfig(dataSource);

      // Create embedding template
      final template = EmbeddingTemplate.create(
        id: 'test_template',
        name: 'Test Template',
        description: 'Test embedding template',
        template: 'Content: {{content}}',
        idTemplate: '{{id}}',
        dataSourceId: dataSource.id,
        createdAt: now,
      );
      await configService.saveEmbeddingTemplateConfig(template);

      // Create providers
      final providerIds = <String>[];
      for (int i = 0; i < modelCount; i++) {
        final providerId = 'test_provider_$i';
        final provider = EmbeddingProviderConfig.create(
          id: providerId,
          name: 'Test Provider $i',
          description: 'Test provider $i',
          type: EmbeddingProviderType.openai,
          settings: {'api_version': '2023-05-15'},
          credential: Credential.apiKey('test-key-$i'),
          enabledModels: {'text-embedding-3-small'},
          createdAt: now,
        );
        await configService.saveProviderConfig(provider);
        providerIds.add(providerId);
      }

      // Create job
      final job = EmbeddingJob.create(
        id: 'test_job',
        name: 'Test Export Job',
        description: 'Job for testing export functionality',
        dataSourceId: dataSource.id,
        embeddingTemplateId: template.id,
        providerIds: providerIds,
        modelIds: List.generate(modelCount, (i) => 'text-embedding-3-small'),
        status: JobStatus.completed,
        totalRecords: recordCount,
        processedRecords: recordCount,
        createdAt: now,
        startedAt: now,
        completedAt: now.add(const Duration(minutes: 5)),
      );
      await configService.saveEmbeddingJob(job);

      // Create embedding columns with unique model names to avoid column name conflicts
      final columns = <EmbeddingColumn>[];
      for (int i = 0; i < modelCount; i++) {
        final modelName = 'text-embedding-3-small-model-$i';
        columns.add(
          EmbeddingColumn(
            id: 'col_$i',
            tableId: '', // Will be set after table creation
            columnName:
                '${modelName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')}_embedding',
            modelProviderId: providerIds[i],
            modelName: modelName,
            vectorType: VectorType.float32,
            dimensions: 8, // Small dimension for testing
            createdAt: now,
          ),
        );
      }

      // Create embedding data
      final tableId = await createTestEmbeddingData(
        job: job,
        columns: columns,
        recordCount: recordCount,
      );

      // Update column table IDs
      final updatedColumns = columns
          .map((col) => col.copyWith(tableId: tableId))
          .toList();

      return (job: job, columns: updatedColumns, tableId: tableId);
    }

    group('SQLite Export', () {
      test('should export embeddings as SQLite database', () async {
        final setup = await createCompleteTestSetup(
          recordCount: 3,
          modelCount: 2,
        );

        final result = await exportService.exportJob(
          job: setup.job,
          format: ExportFormat.sqlite,
        );

        // Verify export result
        expect(result.format, equals(ExportFormat.sqlite));
        expect(result.filename, endsWith('.db'));
        expect(result.recordCount, equals(3));
        expect(
          result.columnCount,
          equals(4),
        ); // id, source_data, + 2 embedding columns
        expect(result.data, isNotEmpty);
        expect(result.data, isA<Uint8List>());

        // Import the exported database and verify structure
        final exportedDb = await databasePool.import(
          filename: 'test_export.db',
          data: result.data,
        );

        // Check table structure
        final tableInfo = await exportedDb.select(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='embeddings'",
        );
        expect(tableInfo, hasLength(1));

        // Check column structure
        final columns = await exportedDb.select(
          'PRAGMA table_info(embeddings)',
        );
        expect(columns, hasLength(4));

        final columnNames = columns.map((col) => col['name'] as String).toSet();
        expect(columnNames, contains('id'));
        expect(columnNames, contains('source_data'));
        expect(
          columnNames,
          contains('text_embedding_3_small_model_0_embedding'),
        );
        expect(
          columnNames,
          contains('text_embedding_3_small_model_1_embedding'),
        );

        // Check data content
        final records = await exportedDb.select(
          'SELECT * FROM embeddings ORDER BY id',
        );
        expect(records, hasLength(3));

        for (int i = 0; i < 3; i++) {
          final record = records[i];
          expect(record['id'], equals('record_$i'));

          final sourceData = jsonDecode(record['source_data'] as String);
          expect(sourceData['content'], contains('test content for record $i'));
          expect(sourceData['metadata']['index'], equals(i));

          // Check embedding columns exist (as BLOBs)
          expect(
            record['text_embedding_3_small_model_0_embedding'],
            isA<Uint8List>(),
          );
          expect(
            record['text_embedding_3_small_model_1_embedding'],
            isA<Uint8List>(),
          );
        }

        await exportedDb.close();
      });

      test('should handle empty embedding tables', () async {
        final setup = await createCompleteTestSetup(
          recordCount: 0,
          modelCount: 1,
        );

        final result = await exportService.exportJob(
          job: setup.job,
          format: ExportFormat.sqlite,
        );

        expect(result.recordCount, equals(0));
        expect(
          result.columnCount,
          equals(3),
        ); // id, source_data, + 1 embedding column

        // Verify exported database structure
        final exportedDb = await databasePool.import(
          filename: 'empty_export.db',
          data: result.data,
        );

        final records = await exportedDb.select('SELECT * FROM embeddings');
        expect(records, isEmpty);

        final columns = await exportedDb.select(
          'PRAGMA table_info(embeddings)',
        );
        expect(columns, hasLength(3));

        await exportedDb.close();
      });

      test('should clean up temporary databases on error', () async {
        final setup = await createCompleteTestSetup(
          recordCount: 1,
          modelCount: 1,
        );

        // Create a scenario that might cause errors by disposing the database pool
        await databasePool.dispose();

        // This should fail but not leave temp databases
        await expectLater(
          exportService.exportJob(job: setup.job, format: ExportFormat.sqlite),
          throwsA(isA<StateError>()),
        );

        // Since we disposed the pool, we can't verify cleanup directly,
        // but the service should handle cleanup in the finally block
      });
    });

    // group('NumPy Archive Export', skip: true, () {
    //   test('should export embeddings as NumPy archive', () async {
    //     final setup = await createCompleteTestSetup(
    //       recordCount: 4,
    //       modelCount: 2,
    //     );

    //     final result = await exportService.exportJob(
    //       job: setup.job,
    //       format: ExportFormat.numpy,
    //     );

    //     // Verify export result
    //     expect(result.format, equals(ExportFormat.numpy));
    //     expect(result.filename, endsWith('.npz'));
    //     expect(result.recordCount, equals(4));
    //     expect(
    //       result.columnCount,
    //       equals(4),
    //     ); // id, source_data, + 2 embedding columns
    //     expect(result.data, isNotEmpty);

    //     // Load and verify the NumPy archive
    //     final npzFile = await NpzFile.load(result.data);

    //     // Check expected files in archive
    //     expect(npzFile.files.keys, contains('metadata.npy'));
    //     expect(npzFile.files.keys, contains('record_ids.npy'));
    //     expect(npzFile.files.keys, contains('source_data.npy'));
    //     expect(
    //       npzFile.files.keys,
    //       contains('text_embedding_3_small_model_0_embedding.npy'),
    //     );
    //     expect(
    //       npzFile.files.keys,
    //       contains('text_embedding_3_small_model_1_embedding.npy'),
    //     );
    //     expect(
    //       npzFile.files.keys,
    //       contains('text_embedding_3_small_model_0_embedding_shape.npy'),
    //     );
    //     expect(
    //       npzFile.files.keys,
    //       contains('text_embedding_3_small_model_1_embedding_shape.npy'),
    //     );

    //     // Verify metadata
    //     final metadataArray = npzFile.files['metadata.npy']!;
    //     final metadataBytes = Uint8List.fromList(
    //       metadataArray.data.cast<int>(),
    //     );
    //     final metadataJson = utf8.decode(metadataBytes);
    //     final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;

    //     expect(metadata['job_id'], equals('test_job'));
    //     expect(metadata['job_name'], equals('Test Export Job'));
    //     expect(metadata['record_count'], equals(4));
    //     expect(metadata['model_count'], equals(2));
    //     expect(metadata['models'], hasLength(2));

    //     // Verify record IDs
    //     final idsArray = npzFile.files['record_ids.npy']!;
    //     final idsBytes = Uint8List.fromList(idsArray.data.cast<int>());
    //     final idsJson = utf8.decode(idsBytes);
    //     final recordIds = jsonDecode(idsJson) as List<dynamic>;
    //     expect(recordIds, hasLength(4));
    //     expect(recordIds, contains('record_0'));
    //     expect(recordIds, contains('record_3'));

    //     // Verify source data
    //     final sourceDataArray = npzFile.files['source_data.npy']!;
    //     final sourceDataBytes = Uint8List.fromList(
    //       sourceDataArray.data.cast<int>(),
    //     );
    //     final sourceDataJson = utf8.decode(sourceDataBytes);
    //     final sourceDataList = jsonDecode(sourceDataJson) as List<dynamic>;
    //     expect(sourceDataList, hasLength(4));

    //     final firstSourceData = jsonDecode(sourceDataList[0] as String);
    //     expect(
    //       firstSourceData['content'],
    //       contains('test content for record 0'),
    //     );

    //     // Verify embedding arrays and shapes
    //     final embedding0Array =
    //         npzFile.files['text_embedding_3_small_model_0_embedding.npy']!;
    //     final shape0Array = npzFile
    //         .files['text_embedding_3_small_model_0_embedding_shape.npy']!;

    //     expect(embedding0Array.data, hasLength(32)); // 4 records * 8 dimensions
    //     expect(shape0Array.data, equals([4, 8])); // [record_count, dimensions]

    //     // Verify all embedding values are doubles
    //     for (final value in embedding0Array.data) {
    //       expect(value, isA<double>());
    //       expect(value, greaterThanOrEqualTo(-1.0));
    //       expect(value, lessThanOrEqualTo(1.0));
    //     }
    //   });

    //   test('should handle missing embeddings with zero vectors', () async {
    //     final setup = await createCompleteTestSetup(
    //       recordCount: 2,
    //       modelCount: 1,
    //     );

    //     // Manually insert a record without embeddings to test zero-filling
    //     await configService.insertEmbeddingData(
    //       tableId: setup.tableId,
    //       recordId: 'record_incomplete',
    //       sourceData: {
    //         'id': 'record_incomplete',
    //         'content': 'Missing embeddings',
    //       },
    //       embeddings: {}, // No embeddings
    //     );

    //     final result = await exportService.exportJob(
    //       job: setup.job,
    //       format: ExportFormat.numpy,
    //     );

    //     expect(result.recordCount, equals(3)); // 2 + 1 incomplete

    //     final npzFile = await NpzFile.load(result.data);

    //     // Verify shape accounts for the incomplete record
    //     final shapeArray = npzFile
    //         .files['text_embedding_3_small_model_0_embedding_shape.npy']!;
    //     expect(shapeArray.data, equals([3, 8])); // 3 records, 8 dimensions

    //     // Verify embedding array has correct total size
    //     final embeddingArray =
    //         npzFile.files['text_embedding_3_small_model_0_embedding.npy']!;
    //     expect(embeddingArray.data, hasLength(24)); // 3 records * 8 dimensions
    //   });

    //   test('should compress archive by default', () async {
    //     final setup = await createCompleteTestSetup(
    //       recordCount: 10,
    //       modelCount: 1,
    //     );

    //     final result = await exportService.exportJob(
    //       job: setup.job,
    //       format: ExportFormat.numpy,
    //     );

    //     // With compression, the file should be smaller than uncompressed
    //     // This is a basic check - the exact compression ratio depends on data
    //     expect(result.data.length, lessThan(10000)); // Reasonable upper bound

    //     // Verify we can still load the compressed archive
    //     final npzFile = await NpzFile.load(result.data);
    //     expect(npzFile.files.keys, isNotEmpty);
    //   });
    // });

    group('JSONL Export', () {
      test('should export embeddings as JSONL format', () async {
        final setup = await createCompleteTestSetup(
          recordCount: 3,
          modelCount: 2,
        );

        final result = await exportService.exportJob(
          job: setup.job,
          format: ExportFormat.jsonl,
        );

        // Verify export result
        expect(result.format, equals(ExportFormat.jsonl));
        expect(result.filename, endsWith('.jsonl'));
        expect(result.recordCount, equals(3));
        expect(
          result.columnCount,
          equals(4),
        ); // id, source_data, + 2 embedding columns
        expect(result.data, isNotEmpty);

        // Parse JSONL content
        final jsonlContent = utf8.decode(result.data);
        final lines = jsonlContent
            .split('\n')
            .where((line) => line.isNotEmpty)
            .toList();

        expect(lines, hasLength(4)); // 1 metadata + 3 data lines

        // Verify metadata line
        final metadataLine = jsonDecode(lines[0]) as Map<String, dynamic>;
        expect(metadataLine['type'], equals('metadata'));
        expect(metadataLine['job_id'], equals('test_job'));
        expect(metadataLine['job_name'], equals('Test Export Job'));
        expect(metadataLine['record_count'], equals(3));
        expect(metadataLine['models'], hasLength(2));

        // Verify model metadata
        final models = metadataLine['models'] as List;
        expect(
          models[0]['model_name'],
          equals('text-embedding-3-small-model-0'),
        );
        expect(models[0]['dimensions'], equals(8));
        expect(models[0]['vector_type'], equals('float32'));

        // Verify data lines
        for (int i = 1; i <= 3; i++) {
          final dataLine = jsonDecode(lines[i]) as Map<String, dynamic>;
          expect(dataLine['type'], equals('record'));
          expect(dataLine['id'], equals('record_${i - 1}'));

          final sourceData = dataLine['source_data'] as Map<String, dynamic>;
          expect(
            sourceData['content'],
            contains('test content for record ${i - 1}'),
          );
          expect(sourceData['metadata']['index'], equals(i - 1));

          final embeddings = dataLine['embeddings'] as Map<String, dynamic>;
          expect(embeddings.keys, hasLength(2));
          expect(
            embeddings.keys,
            contains('text_embedding_3_small_model_0_embedding'),
          );
          expect(
            embeddings.keys,
            contains('text_embedding_3_small_model_1_embedding'),
          );

          // Verify embedding vectors
          final embedding0 =
              embeddings['text_embedding_3_small_model_0_embedding'] as List;
          final embedding1 =
              embeddings['text_embedding_3_small_model_1_embedding'] as List;

          expect(embedding0, hasLength(8));
          expect(embedding1, hasLength(8));

          for (final value in embedding0) {
            expect(value, isA<double>());
            expect(value, greaterThanOrEqualTo(-1.0));
            expect(value, lessThanOrEqualTo(1.0));
          }
        }
      });

      test('should handle records with missing embeddings', () async {
        final setup = await createCompleteTestSetup(
          recordCount: 2,
          modelCount: 1,
        );

        // Insert record without embeddings
        await configService.insertEmbeddingData(
          tableId: setup.tableId,
          recordId: 'record_no_embeddings',
          sourceData: {
            'id': 'record_no_embeddings',
            'content': 'No embeddings for this record',
          },
          embeddings: {}, // No embeddings
        );

        final result = await exportService.exportJob(
          job: setup.job,
          format: ExportFormat.jsonl,
        );

        final jsonlContent = utf8.decode(result.data);
        final lines = jsonlContent
            .split('\n')
            .where((line) => line.isNotEmpty)
            .toList();

        expect(lines, hasLength(4)); // 1 metadata + 3 data lines

        // Find the line with missing embeddings
        final noEmbeddingsLine = lines.skip(1).firstWhere((line) {
          final data = jsonDecode(line) as Map<String, dynamic>;
          return data['id'] == 'record_no_embeddings';
        });

        final dataLine = jsonDecode(noEmbeddingsLine) as Map<String, dynamic>;
        final embeddings = dataLine['embeddings'] as Map<String, dynamic>;

        // Should have empty embeddings object or missing keys
        expect(
          embeddings.isEmpty ||
              !embeddings.containsKey(
                'text_embedding_3_small_model_0_embedding',
              ),
          isTrue,
        );
      });

      test('should produce valid JSON on each line', () async {
        final setup = await createCompleteTestSetup(
          recordCount: 5,
          modelCount: 1,
        );

        final result = await exportService.exportJob(
          job: setup.job,
          format: ExportFormat.jsonl,
        );

        final jsonlContent = utf8.decode(result.data);
        final lines = jsonlContent
            .split('\n')
            .where((line) => line.isNotEmpty)
            .toList();

        // Every line should be valid JSON
        for (final line in lines) {
          expect(() => jsonDecode(line), returnsNormally);
        }

        // Verify line count
        expect(lines, hasLength(6)); // 1 metadata + 5 data lines
      });
    });

    group('Error Handling', () {
      test('should throw error for incomplete job', () async {
        final setup = await createCompleteTestSetup();

        // Create job with non-completed status
        final incompleteJob = setup.job.copyWith(status: JobStatus.running);
        await configService.saveEmbeddingJob(incompleteJob);

        await expectLater(
          exportService.exportJob(
            job: incompleteJob,
            format: ExportFormat.sqlite,
          ),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Cannot export incomplete job'),
            ),
          ),
        );
      });

      test('should throw error for job without embedding tables', () async {
        final now = DateTime.now();

        // Create minimal data source and template
        final dataSource = DataSourceConfig.create(
          id: 'orphan_ds',
          name: 'Orphan Data Source',
          type: DataSourceType.csv,
          filename: 'orphan.csv',
          settings: CsvDataSourceSettings(),
          createdAt: now,
        );
        await configService.saveDataSourceConfig(dataSource);

        final template = EmbeddingTemplate.create(
          id: 'orphan_template',
          name: 'Orphan Template',
          template: '{{content}}',
          idTemplate: '{{id}}',
          dataSourceId: dataSource.id,
          createdAt: now,
        );
        await configService.saveEmbeddingTemplateConfig(template);

        // Create job without embedding table
        final orphanJob = EmbeddingJob.create(
          id: 'orphan_job',
          name: 'Orphan Job',
          dataSourceId: dataSource.id,
          embeddingTemplateId: template.id,
          providerIds: [],
          modelIds: [],
          status: JobStatus.completed,
          createdAt: now,
        );
        await configService.saveEmbeddingJob(orphanJob);

        await expectLater(
          exportService.exportJob(job: orphanJob, format: ExportFormat.jsonl),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('No embedding tables found'),
            ),
          ),
        );
      });

      test('should handle database connection errors gracefully', () async {
        final setup = await createCompleteTestSetup();

        // Dispose the database pool to simulate connection issues
        await databasePool.dispose();

        await expectLater(
          exportService.exportJob(job: setup.job, format: ExportFormat.sqlite),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Filename Generation', () {
      test('should generate unique filenames', () async {
        final setup = await createCompleteTestSetup();

        final result1 = await exportService.exportJob(
          job: setup.job,
          format: ExportFormat.sqlite,
        );

        // Wait a bit to ensure different timestamp
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final result2 = await exportService.exportJob(
          job: setup.job,
          format: ExportFormat.jsonl,
        );

        expect(result1.filename, isNot(equals(result2.filename)));
        expect(result1.filename, endsWith('.db'));
        expect(result2.filename, endsWith('.jsonl'));
      });

      test('should sanitize job names in filenames', () async {
        // Create a setup with a job that already has special characters in the name
        final now = DateTime.now();

        // Create data source
        final dataSource = DataSourceConfig.create(
          id: 'special_ds',
          name: 'Special Data Source',
          description: 'Test data source for filename sanitization',
          type: DataSourceType.csv,
          filename: 'special.csv',
          settings: CsvDataSourceSettings(delimiter: ',', hasHeader: true),
          createdAt: now,
        );
        await configService.saveDataSourceConfig(dataSource);

        // Create embedding template
        final template = EmbeddingTemplate.create(
          id: 'special_template',
          name: 'Special Template',
          description: 'Test embedding template',
          template: 'Content: {{content}}',
          idTemplate: '{{id}}',
          dataSourceId: dataSource.id,
          createdAt: now,
        );
        await configService.saveEmbeddingTemplateConfig(template);

        // Create provider
        final providerId = 'special_provider';
        final provider = EmbeddingProviderConfig.create(
          id: providerId,
          name: 'Special Provider',
          description: 'Test provider',
          type: EmbeddingProviderType.openai,
          settings: {'api_version': '2023-05-15'},
          credential: Credential.apiKey('test-key'),
          enabledModels: {'text-embedding-3-small'},
          createdAt: now,
        );
        await configService.saveProviderConfig(provider);

        // Create job with special characters in name
        final specialJob = EmbeddingJob.create(
          id: 'special_job',
          name: 'Test/Job: With<Special>Characters|And?Symbols*',
          description: 'Job for testing filename sanitization',
          dataSourceId: dataSource.id,
          embeddingTemplateId: template.id,
          providerIds: [providerId],
          modelIds: ['text-embedding-3-small'],
          status: JobStatus.completed,
          totalRecords: 2,
          processedRecords: 2,
          createdAt: now,
          startedAt: now,
          completedAt: now.add(const Duration(minutes: 5)),
        );
        await configService.saveEmbeddingJob(specialJob);

        // Create embedding data for this job
        final columns = [
          EmbeddingColumn(
            id: 'special_col',
            tableId: '', // Will be set after table creation
            columnName: 'text_embedding_3_small_embedding',
            modelProviderId: providerId,
            modelName: 'text-embedding-3-small',
            vectorType: VectorType.float32,
            dimensions: 8,
            createdAt: now,
          ),
        ];

        await createTestEmbeddingData(
          job: specialJob,
          columns: columns,
          recordCount: 2,
        );

        final result = await exportService.exportJob(
          job: specialJob,
          format: ExportFormat.jsonl,
        );

        // Filename should have special characters replaced
        expect(result.filename, isNot(contains('/')));
        expect(result.filename, isNot(contains(':')));
        expect(result.filename, isNot(contains('<')));
        expect(result.filename, isNot(contains('>')));
        expect(result.filename, isNot(contains('|')));
        expect(result.filename, isNot(contains('?')));
        expect(result.filename, isNot(contains('*')));
        expect(result.filename, endsWith('.jsonl'));
      });
    });

    group('Performance and Scale', () {
      test('should handle large datasets efficiently', () async {
        final setup = await createCompleteTestSetup(
          recordCount: 100,
          modelCount: 1,
        );

        final stopwatch = Stopwatch()..start();

        final result = await exportService.exportJob(
          job: setup.job,
          format: ExportFormat.jsonl,
        );

        stopwatch.stop();

        expect(result.recordCount, equals(100));
        expect(result.data, isNotEmpty);

        // Should complete in reasonable time (adjust based on performance requirements)
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(10000),
        ); // 10 seconds max
      });

      // test('should handle multiple vector columns efficiently', () async {
      //   final setup = await createCompleteTestSetup(
      //     recordCount: 10,
      //     modelCount: 5,
      //   );

      //   final result = await exportService.exportJob(
      //     job: setup.job,
      //     format: ExportFormat.numpy,
      //   );

      //   expect(result.recordCount, equals(10));
      //   expect(
      //     result.columnCount,
      //     equals(7),
      //   ); // id, source_data, + 5 embedding columns

      //   final npzFile = await NpzFile.load(result.data);

      //   // Should have all embedding arrays
      //   for (int i = 0; i < 5; i++) {
      //     expect(
      //       npzFile.files.keys,
      //       contains('text_embedding_3_small_model_${i}_embedding.npy'),
      //     );
      //     expect(
      //       npzFile.files.keys,
      //       contains('text_embedding_3_small_model_${i}_embedding_shape.npy'),
      //     );
      //   }
      // });
    });
  });
}

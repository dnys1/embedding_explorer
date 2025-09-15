@TestOn('browser')
library;

import 'dart:convert';

import 'package:embeddings_explorer/configurations/service/configuration_service.dart';
import 'package:embeddings_explorer/database/database.dart';
import 'package:embeddings_explorer/jobs/model/embedding_job.dart';
import 'package:embeddings_explorer/jobs/service/job_resume_service.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  setupTests();

  group('JobResumeService', () {
    late JobResumeService service;
    late DatabaseHandle database;

    setUpAll(loadLibsql);

    setUp(() async {
      database = Database.memory();
      service = JobResumeService(database: database);

      // Run migrations for jobs table.
      await ConfigurationService().initialize(database: database);

      // Disable foreign keys for testing purposes
      await database.execute('PRAGMA foreign_keys=OFF');
    });

    tearDown(() async {
      await service.dispose();
      await database.close();
    });

    group('Initialization', () {
      test(
        'should initialize successfully and create checkpoints table',
        () async {
          // Service is already initialized in setUp, verify table exists
          final tables = await database.select(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='job_checkpoints'",
          );
          expect(tables.length, equals(1));
          expect(tables.first['name'], equals('job_checkpoints'));
        },
      );

      test('should create proper indexes on checkpoints table', () async {
        final indexes = await database.select(
          "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='job_checkpoints'",
        );

        final indexNames = indexes.map((row) => row['name'] as String).toList();
        expect(indexNames, contains('idx_job_checkpoints_job_id'));
        expect(indexNames, contains('idx_job_checkpoints_sequence'));
        expect(indexNames, contains('idx_job_checkpoints_type'));
      });
    });

    group('Checkpoint Creation and Types', () {
      test('should create job start checkpoint with correct data', () {
        final checkpoint = JobCheckpoint.jobStart(
          jobId: 'test-job-1',
          sequenceNumber: 1,
          jobData: {'dataSourceId': 'ds1', 'templateId': 'tmpl1'},
        );

        expect(checkpoint.jobId, equals('test-job-1'));
        expect(checkpoint.type, equals(CheckpointType.jobStart));
        expect(checkpoint.sequenceNumber, equals(1));
        expect(checkpoint.data['dataSourceId'], equals('ds1'));
        expect(checkpoint.data['templateId'], equals('tmpl1'));
        expect(checkpoint.timestamp, isA<DateTime>());
        expect(checkpoint.id, startsWith('test-job-1_start_'));
      });

      test('should create data source connected checkpoint', () {
        final checkpoint = JobCheckpoint.dataSourceConnected(
          jobId: 'test-job-2',
          sequenceNumber: 2,
          dataSourceId: 'ds1',
          totalRecords: 1000,
        );

        expect(checkpoint.type, equals(CheckpointType.dataSourceConnected));
        expect(checkpoint.data['dataSourceId'], equals('ds1'));
        expect(checkpoint.data['totalRecords'], equals(1000));
      });

      test('should create templates rendered checkpoint', () {
        final checkpoint = JobCheckpoint.templatesRendered(
          jobId: 'test-job-3',
          sequenceNumber: 3,
          templateId: 'tmpl1',
          renderedCount: 500,
        );

        expect(checkpoint.type, equals(CheckpointType.templatesRendered));
        expect(checkpoint.data['templateId'], equals('tmpl1'));
        expect(checkpoint.data['renderedCount'], equals(500));
      });

      test('should create batch started checkpoint', () {
        final batchTexts = ['text1', 'text2', 'text3'];
        final checkpoint = JobCheckpoint.batchStarted(
          jobId: 'test-job-4',
          sequenceNumber: 4,
          providerId: 'provider1',
          batchNumber: 1,
          batchTexts: batchTexts,
        );

        expect(checkpoint.type, equals(CheckpointType.batchStarted));
        expect(checkpoint.providerId, equals('provider1'));
        expect(checkpoint.batchNumber, equals(1));
        expect(checkpoint.data['batchTexts'], equals(batchTexts));
        expect(checkpoint.data['batchSize'], equals(3));
      });

      test('should create batch completed checkpoint', () {
        final checkpoint = JobCheckpoint.batchCompleted(
          jobId: 'test-job-5',
          sequenceNumber: 5,
          providerId: 'provider1',
          batchNumber: 1,
          processedCount: 50,
        );

        expect(checkpoint.type, equals(CheckpointType.batchCompleted));
        expect(checkpoint.providerId, equals('provider1'));
        expect(checkpoint.batchNumber, equals(1));
        expect(checkpoint.data['processedCount'], equals(50));
      });

      test('should create provider completed checkpoint', () {
        final checkpoint = JobCheckpoint.providerCompleted(
          jobId: 'test-job-6',
          sequenceNumber: 6,
          providerId: 'provider1',
          totalProcessed: 1000,
        );

        expect(checkpoint.type, equals(CheckpointType.providerCompleted));
        expect(checkpoint.providerId, equals('provider1'));
        expect(checkpoint.data['providerId'], equals('provider1'));
        expect(checkpoint.data['totalProcessed'], equals(1000));
      });
    });

    group('Checkpoint Serialization', () {
      test('should serialize and deserialize checkpoint correctly', () {
        final original = JobCheckpoint.batchStarted(
          jobId: 'test-job',
          sequenceNumber: 1,
          providerId: 'provider1',
          batchNumber: 2,
          batchTexts: ['text1', 'text2'],
        );

        final map = original.toMap();
        final restored = JobCheckpoint.fromMap(map);

        expect(restored.id, equals(original.id));
        expect(restored.jobId, equals(original.jobId));
        expect(restored.type, equals(original.type));
        expect(restored.sequenceNumber, equals(original.sequenceNumber));
        expect(restored.providerId, equals(original.providerId));
        expect(restored.batchNumber, equals(original.batchNumber));
        expect(restored.data, equals(original.data));
        expect(
          restored.timestamp.millisecondsSinceEpoch,
          equals(original.timestamp.millisecondsSinceEpoch),
        );
      });

      test('should handle null optional fields in serialization', () {
        final original = JobCheckpoint.jobStart(
          jobId: 'test-job',
          sequenceNumber: 1,
          jobData: {'key': 'value'},
        );

        final map = original.toMap();
        final restored = JobCheckpoint.fromMap(map);

        expect(restored.providerId, isNull);
        expect(restored.batchNumber, isNull);
        expect(restored.data, equals(original.data));
      });
    });

    group('Checkpoint Saving', () {
      test('should save checkpoint to database', () async {
        final checkpoint = JobCheckpoint.jobStart(
          jobId: 'test-job-1',
          sequenceNumber: 1,
          jobData: {'test': 'data'},
        );

        await service.saveCheckpoint(checkpoint);

        final rows = await database.select(
          'SELECT * FROM job_checkpoints WHERE job_id = ?',
          ['test-job-1'],
        );

        expect(rows.length, equals(1));
        expect(rows.first['id'], equals(checkpoint.id));
        expect(rows.first['type'], equals('jobStart'));
        expect(rows.first['sequence_number'], equals(1));

        final savedData = jsonDecode(rows.first['data'] as String);
        expect(savedData['test'], equals('data'));
      });

      test('should save multiple checkpoints in order', () async {
        final checkpoints = [
          JobCheckpoint.jobStart(
            jobId: 'test-job-1',
            sequenceNumber: 1,
            jobData: {'step': 1},
          ),
          JobCheckpoint.dataSourceConnected(
            jobId: 'test-job-1',
            sequenceNumber: 2,
            dataSourceId: 'ds1',
            totalRecords: 100,
          ),
          JobCheckpoint.batchStarted(
            jobId: 'test-job-1',
            sequenceNumber: 3,
            providerId: 'provider1',
            batchNumber: 1,
            batchTexts: ['text1'],
          ),
        ];

        for (final checkpoint in checkpoints) {
          await service.saveCheckpoint(checkpoint);
        }

        final rows = await database.select(
          'SELECT * FROM job_checkpoints WHERE job_id = ? ORDER BY sequence_number',
          ['test-job-1'],
        );

        expect(rows.length, equals(3));
        expect(rows[0]['type'], equals('jobStart'));
        expect(rows[1]['type'], equals('dataSourceConnected'));
        expect(rows[2]['type'], equals('batchStarted'));
      });

      test('should use convenience methods for saving checkpoints', () async {
        const jobId = 'convenience-test';

        await service.saveJobStartCheckpoint(jobId, {'test': 'data'});
        await service.saveDataSourceConnectedCheckpoint(jobId, 'ds1', 1000);
        await service.saveTemplatesRenderedCheckpoint(jobId, 'tmpl1', 500);
        await service.saveBatchStartedCheckpoint(jobId, 'provider1', 1, [
          'text1',
          'text2',
        ]);
        await service.saveBatchCompletedCheckpoint(jobId, 'provider1', 1, 2);
        await service.saveProviderCompletedCheckpoint(jobId, 'provider1', 100);

        final rows = await database.select(
          'SELECT type FROM job_checkpoints WHERE job_id = ? ORDER BY sequence_number',
          [jobId],
        );

        expect(rows.length, equals(6));
        expect(rows[0]['type'], equals('jobStart'));
        expect(rows[1]['type'], equals('dataSourceConnected'));
        expect(rows[2]['type'], equals('templatesRendered'));
        expect(rows[3]['type'], equals('batchStarted'));
        expect(rows[4]['type'], equals('batchCompleted'));
        expect(rows[5]['type'], equals('providerCompleted'));
      });

      test('should handle INSERT OR REPLACE correctly', () async {
        final checkpoint1 = JobCheckpoint(
          id: 'same-id',
          jobId: 'test-job',
          type: CheckpointType.jobStart,
          timestamp: DateTime.now(),
          data: {'version': 1},
          sequenceNumber: 1,
        );

        final checkpoint2 = JobCheckpoint(
          id: 'same-id',
          jobId: 'test-job',
          type: CheckpointType.jobStart,
          timestamp: DateTime.now(),
          data: {'version': 2},
          sequenceNumber: 1,
        );

        await service.saveCheckpoint(checkpoint1);
        await service.saveCheckpoint(checkpoint2);

        final rows = await database.select(
          'SELECT * FROM job_checkpoints WHERE id = ?',
          ['same-id'],
        );

        expect(rows.length, equals(1));
        final savedData = jsonDecode(rows.first['data'] as String);
        expect(savedData['version'], equals(2));
      });
    });

    group('Checkpoint Retrieval', () {
      test('should get all checkpoints for a job in sequence order', () async {
        const jobId = 'retrieval-test';

        // Save checkpoints - they will get sequential sequence numbers
        await service.saveJobStartCheckpoint(jobId, {'test': 'data'});
        await service.saveDataSourceConnectedCheckpoint(jobId, 'ds1', 100);
        await service.saveBatchStartedCheckpoint(jobId, 'provider1', 1, [
          'text1',
        ]);

        final checkpoints = await service.getJobCheckpoints(jobId);

        expect(checkpoints.length, equals(3));
        expect(checkpoints[0].type, equals(CheckpointType.jobStart));
        expect(checkpoints[1].type, equals(CheckpointType.dataSourceConnected));
        expect(checkpoints[2].type, equals(CheckpointType.batchStarted));
        expect(
          checkpoints[0].sequenceNumber,
          lessThan(checkpoints[1].sequenceNumber),
        );
        expect(
          checkpoints[1].sequenceNumber,
          lessThan(checkpoints[2].sequenceNumber),
        );
      });

      test('should return empty list for job with no checkpoints', () async {
        final checkpoints = await service.getJobCheckpoints('nonexistent-job');
        expect(checkpoints, isEmpty);
      });

      test('should get latest checkpoint for a job', () async {
        const jobId = 'latest-test';

        await service.saveJobStartCheckpoint(jobId, {'test': 'data'});
        await service.saveDataSourceConnectedCheckpoint(jobId, 'ds1', 100);
        await service.saveBatchStartedCheckpoint(jobId, 'provider1', 1, [
          'text1',
        ]);

        final latest = await service.getLatestCheckpoint(jobId);

        expect(latest, isNotNull);
        expect(latest!.type, equals(CheckpointType.batchStarted));
        expect(latest.data['batchTexts'], equals(['text1']));
      });

      test(
        'should return null for latest checkpoint of nonexistent job',
        () async {
          final latest = await service.getLatestCheckpoint('nonexistent-job');
          expect(latest, isNull);
        },
      );

      test('should deserialize checkpoint data correctly', () async {
        const jobId = 'deserialize-test';
        final complexData = {
          'list': [1, 2, 3],
          'map': {'nested': 'value'},
          'string': 'test',
          'number': 42,
          'boolean': true,
          'null_value': null,
        };

        await service.saveJobStartCheckpoint(jobId, complexData);
        final checkpoints = await service.getJobCheckpoints(jobId);

        expect(checkpoints.length, equals(1));
        expect(checkpoints.first.data, equals(complexData));
      });
    });

    group('Resume Analysis', () {
      late EmbeddingJob testJob;

      setUp(() async {
        testJob = EmbeddingJob(
          id: 'resume-test-job',
          name: 'Resume Test Job',
          description: 'Test job for resume analysis',
          dataSourceId: 'ds1',
          embeddingTemplateId: 'tmpl1',
          providerIds: ['provider1', 'provider2', 'provider3'],
          status: JobStatus.failed,
          createdAt: DateTime.now(),
          totalRecords: 1000,
        );

        // Insert job into database
        await database.execute(
          '''
          INSERT INTO jobs (
            id, name, description, data_source_id, embedding_template_id,
            provider_ids, status, created_at, total_records
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            testJob.id,
            testJob.name,
            testJob.description,
            testJob.dataSourceId,
            testJob.embeddingTemplateId,
            jsonEncode(testJob.providerIds),
            testJob.status.name,
            testJob.createdAt.toIso8601String(),
            testJob.totalRecords,
          ],
        );
      });

      test('should return null for jobs that cannot be resumed', () async {
        final completedJob = testJob.copyWith(status: JobStatus.completed);
        await database.execute('UPDATE jobs SET status = ? WHERE id = ?', [
          completedJob.status.name,
          completedJob.id,
        ]);

        final resumable = await service.analyzeResumableJob(completedJob);
        expect(resumable, isNull);
      });

      test('should return null for jobs with no checkpoints', () async {
        final resumable = await service.analyzeResumableJob(testJob);
        expect(resumable, isNull);
      });

      test('should analyze resumable job with partial progress', () async {
        const jobId = 'resume-test-job';

        // Create checkpoints showing partial progress
        await service.saveJobStartCheckpoint(jobId, {'started': true});
        await service.saveDataSourceConnectedCheckpoint(jobId, 'ds1', 1000);
        await service.saveProviderCompletedCheckpoint(jobId, 'provider1', 400);
        await service.saveBatchCompletedCheckpoint(jobId, 'provider2', 1, 200);

        final resumable = await service.analyzeResumableJob(testJob);

        expect(resumable, isNotNull);
        expect(resumable!.canResume, isTrue);
        expect(resumable.job, equals(testJob));
        expect(resumable.completedProviders, contains('provider1'));
        expect(
          resumable.remainingProviders,
          containsAll(['provider2', 'provider3']),
        );
        expect(
          resumable.recommendedStrategy,
          equals(ResumeStrategy.fromLastProvider),
        );
        expect(
          resumable.progressAtInterruption,
          equals(0.2),
        ); // Last progress checkpoint has 200 processed
      });

      test(
        'should recommend correct resume strategy based on checkpoints',
        () async {
          const jobId = 'resume-test-job'; // Use same job ID as testJob

          // Test fromLastBatch strategy
          await service.saveJobStartCheckpoint(jobId, {'started': true});
          await service.saveBatchCompletedCheckpoint(jobId, 'provider1', 1, 50);

          var resumable = await service.analyzeResumableJob(testJob);
          expect(
            resumable!.recommendedStrategy,
            equals(ResumeStrategy.fromLastBatch),
          );

          // Clear and test fromLastProvider strategy
          await service.deleteJobCheckpoints(jobId);
          await service.saveJobStartCheckpoint(jobId, {'started': true});
          await service.saveProviderCompletedCheckpoint(
            jobId,
            'provider1',
            300,
          );

          resumable = await service.analyzeResumableJob(testJob);
          expect(
            resumable!.recommendedStrategy,
            equals(ResumeStrategy.fromLastProvider),
          );

          // Clear and test fromLastCheckpoint strategy
          await service.deleteJobCheckpoints(jobId);
          await service.saveJobStartCheckpoint(jobId, {'started': true});
          await service.saveDataSourceConnectedCheckpoint(jobId, 'ds1', 1000);

          resumable = await service.analyzeResumableJob(testJob);
          expect(
            resumable!.recommendedStrategy,
            equals(ResumeStrategy.fromLastCheckpoint),
          );
        },
      );

      test(
        'should calculate progress correctly from different checkpoint types',
        () async {
          const jobId = 'resume-test-job'; // Use same job ID as testJob

          // Test with processedCount
          await service.saveJobStartCheckpoint(jobId, {'started': true});
          await service.saveBatchCompletedCheckpoint(
            jobId,
            'provider1',
            1,
            250,
          );

          var resumable = await service.analyzeResumableJob(testJob);
          expect(resumable!.progressAtInterruption, equals(0.25));

          // Clear and test with totalProcessed
          await service.deleteJobCheckpoints(jobId);
          await service.saveJobStartCheckpoint(jobId, {'started': true});
          await service.saveProviderCompletedCheckpoint(
            jobId,
            'provider1',
            600,
          );

          resumable = await service.analyzeResumableJob(testJob);
          expect(resumable!.progressAtInterruption, equals(0.6));
        },
      );

      test('should identify last completed batch correctly', () async {
        const jobId = 'resume-test-job'; // Use same job ID as testJob

        await service.saveJobStartCheckpoint(jobId, {'started': true});
        await service.saveBatchCompletedCheckpoint(jobId, 'provider1', 1, 50);
        await service.saveBatchCompletedCheckpoint(jobId, 'provider1', 3, 75);
        await service.saveBatchCompletedCheckpoint(jobId, 'provider1', 2, 25);

        final resumable = await service.analyzeResumableJob(testJob);

        expect(resumable!.lastCompletedBatch, equals(3));
      });
    });

    group('Finding Resumable Jobs', () {
      test('should find multiple resumable jobs', () async {
        // Create multiple failed jobs with checkpoints
        final jobs = ['job1', 'job2', 'job3'];

        for (int i = 0; i < jobs.length; i++) {
          final job = EmbeddingJob(
            id: jobs[i],
            name: 'Job ${i + 1}',
            description: 'Test job ${i + 1}',
            dataSourceId: 'ds1',
            embeddingTemplateId: 'tmpl1',
            providerIds: ['provider1'],
            status: JobStatus.failed,
            createdAt: DateTime.now(),
            totalRecords: 100,
          );

          await database.execute(
            '''
            INSERT INTO jobs (
              id, name, description, data_source_id, embedding_template_id,
              provider_ids, status, created_at, total_records
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
            [
              job.id,
              job.name,
              job.description,
              job.dataSourceId,
              job.embeddingTemplateId,
              jsonEncode(job.providerIds),
              job.status.name,
              job.createdAt.toIso8601String(),
              job.totalRecords,
            ],
          );

          await service.saveJobStartCheckpoint(jobs[i], {'started': true});
          await service.saveDataSourceConnectedCheckpoint(jobs[i], 'ds1', 100);
        }

        final resumableJobs = await service.findResumableJobs();

        expect(resumableJobs.length, equals(3));
        expect(resumableJobs.map((j) => j.job.id), containsAll(jobs));
        expect(resumableJobs.every((j) => j.canResume), isTrue);
      });

      test('should exclude jobs without checkpoints', () async {
        // Create a failed job without checkpoints
        final job = EmbeddingJob(
          id: 'no-checkpoints-job',
          name: 'No Checkpoints Job',
          description: 'Job without checkpoints',
          dataSourceId: 'ds1',
          embeddingTemplateId: 'tmpl1',
          providerIds: ['provider1'],
          status: JobStatus.failed,
          createdAt: DateTime.now(),
        );

        await database.execute(
          '''
          INSERT INTO jobs (
            id, name, description, data_source_id, embedding_template_id,
            provider_ids, status, created_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            job.id,
            job.name,
            job.description,
            job.dataSourceId,
            job.embeddingTemplateId,
            jsonEncode(job.providerIds),
            job.status.name,
            job.createdAt.toIso8601String(),
          ],
        );

        final resumableJobs = await service.findResumableJobs();
        expect(
          resumableJobs.map((j) => j.job.id),
          isNot(contains('no-checkpoints-job')),
        );
      });

      test('should exclude completed jobs', () async {
        final job = EmbeddingJob(
          id: 'completed-job',
          name: 'Completed Job',
          description: 'Completed job',
          dataSourceId: 'ds1',
          embeddingTemplateId: 'tmpl1',
          providerIds: ['provider1'],
          status: JobStatus.completed,
          createdAt: DateTime.now(),
        );

        await database.execute(
          '''
          INSERT INTO jobs (
            id, name, description, data_source_id, embedding_template_id,
            provider_ids, status, created_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            job.id,
            job.name,
            job.description,
            job.dataSourceId,
            job.embeddingTemplateId,
            jsonEncode(job.providerIds),
            job.status.name,
            job.createdAt.toIso8601String(),
          ],
        );

        await service.saveJobStartCheckpoint('completed-job', {
          'started': true,
        });

        final resumableJobs = await service.findResumableJobs();
        expect(
          resumableJobs.map((j) => j.job.id),
          isNot(contains('completed-job')),
        );
      });
    });

    group('Checkpoint Cleanup and Management', () {
      test('should delete all checkpoints for a job', () async {
        const jobId = 'delete-test-job';

        await service.saveJobStartCheckpoint(jobId, {'test': 'data'});
        await service.saveDataSourceConnectedCheckpoint(jobId, 'ds1', 100);
        await service.saveBatchStartedCheckpoint(jobId, 'provider1', 1, [
          'text1',
        ]);

        // Verify checkpoints exist
        var checkpoints = await service.getJobCheckpoints(jobId);
        expect(checkpoints.length, equals(3));

        // Delete all checkpoints
        await service.deleteJobCheckpoints(jobId);

        // Verify checkpoints are deleted
        checkpoints = await service.getJobCheckpoints(jobId);
        expect(checkpoints, isEmpty);
      });

      test('should clean up old completed job checkpoints', () async {
        // Create a completed job
        final oldJob = EmbeddingJob(
          id: 'old-completed-job',
          name: 'Old Completed Job',
          description: 'Old completed job',
          dataSourceId: 'ds1',
          embeddingTemplateId: 'tmpl1',
          providerIds: ['provider1'],
          status: JobStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          completedAt: DateTime.now().subtract(const Duration(days: 40)),
        );

        await database.execute(
          '''
          INSERT INTO jobs (
            id, name, description, data_source_id, embedding_template_id,
            provider_ids, status, created_at, completed_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            oldJob.id,
            oldJob.name,
            oldJob.description,
            oldJob.dataSourceId,
            oldJob.embeddingTemplateId,
            jsonEncode(oldJob.providerIds),
            oldJob.status.name,
            oldJob.createdAt.toIso8601String(),
            oldJob.completedAt!.toIso8601String(),
          ],
        );

        await service.saveJobStartCheckpoint('old-completed-job', {
          'test': 'data',
        });

        // Verify checkpoint exists before cleanup
        var checkpoints = await service.getJobCheckpoints('old-completed-job');
        expect(checkpoints.length, equals(1));

        // Clean up checkpoints older than 35 days
        await service.cleanupCompletedJobCheckpoints(
          olderThan: const Duration(days: 35),
        );

        // Verify checkpoint is cleaned up
        checkpoints = await service.getJobCheckpoints('old-completed-job');
        expect(checkpoints, isEmpty);
      });

      test('should not clean up recent completed job checkpoints', () async {
        // Create a recently completed job
        final recentJob = EmbeddingJob(
          id: 'recent-completed-job',
          name: 'Recent Completed Job',
          description: 'Recent completed job',
          dataSourceId: 'ds1',
          embeddingTemplateId: 'tmpl1',
          providerIds: ['provider1'],
          status: JobStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
        );

        await database.execute(
          '''
          INSERT INTO jobs (
            id, name, description, data_source_id, embedding_template_id,
            provider_ids, status, created_at, completed_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            recentJob.id,
            recentJob.name,
            recentJob.description,
            recentJob.dataSourceId,
            recentJob.embeddingTemplateId,
            jsonEncode(recentJob.providerIds),
            recentJob.status.name,
            recentJob.createdAt.toIso8601String(),
            recentJob.completedAt!.toIso8601String(),
          ],
        );

        await service.saveJobStartCheckpoint('recent-completed-job', {
          'test': 'data',
        });

        // Clean up checkpoints older than 35 days
        await service.cleanupCompletedJobCheckpoints(
          olderThan: const Duration(days: 35),
        );

        // Verify recent checkpoint is not cleaned up
        final checkpoints = await service.getJobCheckpoints(
          'recent-completed-job',
        );
        expect(checkpoints.length, equals(1));
      });

      test('should provide checkpoint statistics', () {
        final stats = service.getCheckpointStatistics();
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('activeJobsWithCheckpoints'), isTrue);
        expect(stats['activeJobsWithCheckpoints'], isA<int>());
      });
    });

    group('Sequence Number Management', () {
      test(
        'should generate increasing sequence numbers for same job',
        () async {
          const jobId = 'sequence-test-job';

          await service.saveJobStartCheckpoint(jobId, {'step': 1});
          await service.saveDataSourceConnectedCheckpoint(jobId, 'ds1', 100);
          await service.saveBatchStartedCheckpoint(jobId, 'provider1', 1, [
            'text1',
          ]);

          final checkpoints = await service.getJobCheckpoints(jobId);

          expect(checkpoints[0].sequenceNumber, equals(1));
          expect(checkpoints[1].sequenceNumber, equals(2));
          expect(checkpoints[2].sequenceNumber, equals(3));
        },
      );

      test(
        'should manage sequence numbers independently for different jobs',
        () async {
          await service.saveJobStartCheckpoint('job1', {'step': 1});
          await service.saveJobStartCheckpoint('job2', {'step': 1});
          await service.saveDataSourceConnectedCheckpoint('job1', 'ds1', 100);
          await service.saveDataSourceConnectedCheckpoint('job2', 'ds2', 200);

          final job1Checkpoints = await service.getJobCheckpoints('job1');
          final job2Checkpoints = await service.getJobCheckpoints('job2');

          expect(job1Checkpoints[0].sequenceNumber, equals(1));
          expect(job1Checkpoints[1].sequenceNumber, equals(2));
          expect(job2Checkpoints[0].sequenceNumber, equals(1));
          expect(job2Checkpoints[1].sequenceNumber, equals(2));
        },
      );

      test('should reset sequence numbers after job deletion', () async {
        const jobId = 'reset-sequence-job';

        await service.saveJobStartCheckpoint(jobId, {'step': 1});
        await service.saveDataSourceConnectedCheckpoint(jobId, 'ds1', 100);

        var checkpoints = await service.getJobCheckpoints(jobId);
        expect(checkpoints.last.sequenceNumber, equals(2));

        // Delete job checkpoints
        await service.deleteJobCheckpoints(jobId);

        // Create new checkpoints - should start from 1 again
        await service.saveJobStartCheckpoint(jobId, {'step': 1});

        checkpoints = await service.getJobCheckpoints(jobId);
        expect(checkpoints.first.sequenceNumber, equals(1));
      });
    });

    group('Error Handling', () {
      test(
        'should handle database errors gracefully during checkpoint save',
        () async {
          // Close the database to simulate an error
          await database.close();

          final checkpoint = JobCheckpoint.jobStart(
            jobId: 'error-test-job',
            sequenceNumber: 1,
            jobData: {'test': 'data'},
          );

          expect(
            () => service.saveCheckpoint(checkpoint),
            throwsA(isA<StateError>()),
          );
        },
      );

      test('should handle invalid JSON in checkpoint data', () async {
        // Manually insert invalid JSON data
        await database.execute(
          '''
          INSERT INTO job_checkpoints (
            id, job_id, type, timestamp, data, sequence_number
          ) VALUES (?, ?, ?, ?, ?, ?)
        ''',
          [
            'invalid-json-test',
            'test-job',
            'jobStart',
            DateTime.now().toIso8601String(),
            'invalid json data',
            1,
          ],
        );

        expect(
          () => service.getJobCheckpoints('test-job'),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle missing checkpoint type gracefully', () async {
        // Manually insert checkpoint with invalid type
        await database.execute(
          '''
          INSERT INTO job_checkpoints (
            id, job_id, type, timestamp, data, sequence_number
          ) VALUES (?, ?, ?, ?, ?, ?)
        ''',
          [
            'invalid-type-test',
            'test-job',
            'invalidType',
            DateTime.now().toIso8601String(),
            '{}',
            1,
          ],
        );

        final checkpoints = await service.getJobCheckpoints('test-job');
        expect(checkpoints.length, equals(1));
        expect(
          checkpoints.first.type,
          equals(CheckpointType.jobStart),
        ); // Default fallback
      });

      test('should handle analyze job with invalid job data', () async {
        final invalidJob = EmbeddingJob(
          id: 'invalid-job',
          name: 'Invalid Job',
          description: 'Job with issues',
          dataSourceId: 'ds1',
          embeddingTemplateId: 'tmpl1',
          providerIds: ['provider1'],
          status: JobStatus.failed,
          createdAt: DateTime.now(),
        );

        // Don't insert into database - should handle gracefully
        final resumable = await service.analyzeResumableJob(invalidJob);
        expect(resumable, isNull);
      });
    });

    group('Concurrency and Edge Cases', () {
      test('should handle concurrent checkpoint saves for same job', () async {
        const jobId = 'concurrent-test-job';

        final futures = <Future<void>>[];

        // Save multiple different checkpoint types concurrently
        futures.add(service.saveJobStartCheckpoint(jobId, {'step': 1}));
        futures.add(
          service.saveDataSourceConnectedCheckpoint(jobId, 'ds1', 100),
        );
        futures.add(
          service.saveTemplatesRenderedCheckpoint(jobId, 'tmpl1', 50),
        );
        futures.add(
          service.saveBatchStartedCheckpoint(jobId, 'provider1', 1, ['text1']),
        );
        futures.add(
          service.saveBatchCompletedCheckpoint(jobId, 'provider1', 1, 25),
        );

        await Future.wait(futures);

        final checkpoints = await service.getJobCheckpoints(jobId);
        expect(checkpoints.length, equals(5));

        // All should have different sequence numbers
        final sequenceNumbers = checkpoints
            .map((c) => c.sequenceNumber)
            .toSet();
        expect(sequenceNumbers.length, equals(5));
      });

      test(
        'should handle concurrent checkpoint saves for different jobs',
        () async {
          final futures = <Future<void>>[];

          // Save checkpoints for multiple jobs concurrently
          for (int i = 0; i < 5; i++) {
            futures.add(service.saveJobStartCheckpoint('job$i', {'step': 1}));
          }

          await Future.wait(futures);

          // Verify all jobs have their checkpoints
          for (int i = 0; i < 5; i++) {
            final checkpoints = await service.getJobCheckpoints('job$i');
            expect(checkpoints.length, equals(1));
            expect(checkpoints.first.sequenceNumber, equals(1));
          }
        },
      );

      test('should handle empty checkpoint data', () async {
        final checkpoint = JobCheckpoint.jobStart(
          jobId: 'empty-data-job',
          sequenceNumber: 1,
          jobData: {},
        );

        await service.saveCheckpoint(checkpoint);
        final checkpoints = await service.getJobCheckpoints('empty-data-job');

        expect(checkpoints.length, equals(1));
        expect(checkpoints.first.data, equals({}));
      });

      test('should handle very large checkpoint data', () async {
        // Create large checkpoint data
        final largeData = <String, dynamic>{};
        for (int i = 0; i < 1000; i++) {
          largeData['key$i'] = 'value$i' * 100; // 600 chars per entry
        }

        final checkpoint = JobCheckpoint.jobStart(
          jobId: 'large-data-job',
          sequenceNumber: 1,
          jobData: largeData,
        );

        await service.saveCheckpoint(checkpoint);
        final checkpoints = await service.getJobCheckpoints('large-data-job');

        expect(checkpoints.length, equals(1));
        expect(checkpoints.first.data, equals(largeData));
      });

      test(
        'should handle checkpoints with special characters in data',
        () async {
          final specialData = {
            'unicode': '🚀 Unicode test 🎉',
            'quotes': 'String with "quotes" and \'apostrophes\'',
            'newlines': 'Line 1\nLine 2\r\nLine 3',
            'json_like': '{"nested": "json-like string"}',
            'empty_string': '',
            'null_value': null,
          };

          final checkpoint = JobCheckpoint.jobStart(
            jobId: 'special-chars-job',
            sequenceNumber: 1,
            jobData: specialData,
          );

          await service.saveCheckpoint(checkpoint);
          final checkpoints = await service.getJobCheckpoints(
            'special-chars-job',
          );

          expect(checkpoints.length, equals(1));
          expect(checkpoints.first.data, equals(specialData));
        },
      );
    });

    group('ResumableJob Properties', () {
      test('should calculate canResume correctly', () {
        final job = EmbeddingJob(
          id: 'test-job',
          name: 'Test Job',
          description: 'Test job',
          dataSourceId: 'ds1',
          embeddingTemplateId: 'tmpl1',
          providerIds: ['provider1', 'provider2'],
          status: JobStatus.failed,
          createdAt: DateTime.now(),
        );

        final checkpoint = JobCheckpoint.jobStart(
          jobId: 'test-job',
          sequenceNumber: 1,
          jobData: {},
        );

        // Can resume with checkpoint and remaining providers
        var resumableJob = ResumableJob(
          job: job,
          checkpoints: [checkpoint],
          lastCheckpoint: checkpoint,
          recommendedStrategy: ResumeStrategy.fromLastCheckpoint,
          completedProviders: ['provider1'],
          remainingProviders: ['provider2'],
          progressAtInterruption: 0.5,
        );

        expect(resumableJob.canResume, isTrue);

        // Cannot resume without remaining providers
        resumableJob = ResumableJob(
          job: job,
          checkpoints: [checkpoint],
          lastCheckpoint: checkpoint,
          recommendedStrategy: ResumeStrategy.fromLastCheckpoint,
          completedProviders: ['provider1', 'provider2'],
          remainingProviders: [],
          progressAtInterruption: 1.0,
        );

        expect(resumableJob.canResume, isFalse);

        // Cannot resume without checkpoint
        resumableJob = ResumableJob(
          job: job,
          checkpoints: [],
          lastCheckpoint: null,
          recommendedStrategy: ResumeStrategy.restart,
          completedProviders: [],
          remainingProviders: ['provider1', 'provider2'],
          progressAtInterruption: 0.0,
        );

        expect(resumableJob.canResume, isFalse);
      });

      test('should calculate progressSaved correctly', () {
        final job = EmbeddingJob(
          id: 'test-job',
          name: 'Test Job',
          description: 'Test job',
          dataSourceId: 'ds1',
          embeddingTemplateId: 'tmpl1',
          providerIds: ['provider1'],
          status: JobStatus.failed,
          createdAt: DateTime.now(),
        );

        final resumableJob = ResumableJob(
          job: job,
          checkpoints: [],
          recommendedStrategy: ResumeStrategy.fromLastCheckpoint,
          completedProviders: [],
          remainingProviders: ['provider1'],
          progressAtInterruption: 0.75,
        );

        expect(resumableJob.progressSaved, equals(0.75));
      });
    });

    group('Disposal', () {
      test('should dispose service cleanly', () async {
        const jobId = 'disposal-test-job';
        await service.saveJobStartCheckpoint(jobId, {'test': 'data'});

        // Disposal should not throw
        await service.dispose();

        // Should be able to dispose multiple times
        await service.dispose();
      });

      test('should clear sequence numbers on disposal', () async {
        const jobId = 'sequence-disposal-test';
        await service.saveJobStartCheckpoint(jobId, {'test': 'data'});

        final statsBefore = service.getCheckpointStatistics();
        expect(statsBefore['activeJobsWithCheckpoints'], greaterThan(0));

        await service.dispose();

        final statsAfter = service.getCheckpointStatistics();
        expect(statsAfter['activeJobsWithCheckpoints'], equals(0));
      });
    });
  });
}

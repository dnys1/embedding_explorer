@TestOn('browser')
library;

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:embeddings_explorer/configurations/service/configuration_service.dart';
import 'package:embeddings_explorer/database/database.dart';
import 'package:embeddings_explorer/jobs/service/job_progress_tracker.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  setupTests();

  group('JobProgressTracker', () {
    late JobProgressTracker tracker;
    late DatabaseHandle database;

    setUpAll(loadLibsql);

    setUp(() async {
      database = Database.memory();
      tracker = JobProgressTracker(
        database: database,
        persistenceInterval: const Duration(
          milliseconds: 100,
        ), // Faster for tests
        maxHistoryEntries: 10,
      );

      // Run migrations to create required tables
      await ConfigurationService().initialize(database: database);

      // Disable foreign keys for testing purposes
      await database.execute('PRAGMA foreign_keys=OFF');
    });

    tearDown(() async {
      await tracker.dispose();
      await database.close();
    });

    group('ProgressSnapshot', () {
      test('should calculate progress percentage correctly', () {
        final snapshot = ProgressSnapshot(
          jobId: 'test-job',
          timestamp: clock.now(),
          totalRecords: 1000,
          processedRecords: 250,
        );

        expect(snapshot.progress, equals(0.25));
        expect(snapshot.progressPercent, equals(25.0));
      });

      test('should handle zero total records', () {
        final snapshot = ProgressSnapshot(
          jobId: 'test-job',
          timestamp: clock.now(),
          totalRecords: 0,
          processedRecords: 0,
        );

        expect(snapshot.progress, equals(0.0));
        expect(snapshot.progressPercent, equals(0.0));
      });

      test('should estimate time remaining correctly', () {
        final snapshot = ProgressSnapshot(
          jobId: 'test-job',
          timestamp: clock.now(),
          totalRecords: 1000,
          processedRecords: 250,
        );

        final elapsed = const Duration(seconds: 10);
        final remaining = snapshot.estimateTimeRemaining(elapsed);

        expect(remaining, isNotNull);
        expect(remaining!.inSeconds, equals(30)); // 750 records at same rate
      });

      test('should return null for time remaining when no progress', () {
        final snapshot = ProgressSnapshot(
          jobId: 'test-job',
          timestamp: clock.now(),
          totalRecords: 1000,
          processedRecords: 0,
        );

        final remaining = snapshot.estimateTimeRemaining(
          const Duration(seconds: 10),
        );
        expect(remaining, isNull);
      });

      test('should return null for time remaining when complete', () {
        final snapshot = ProgressSnapshot(
          jobId: 'test-job',
          timestamp: clock.now(),
          totalRecords: 1000,
          processedRecords: 1000,
        );

        final remaining = snapshot.estimateTimeRemaining(
          const Duration(seconds: 10),
        );
        expect(remaining, isNull);
      });

      test('should serialize and deserialize correctly', () {
        final original = ProgressSnapshot(
          jobId: 'test-job',
          timestamp: clock.now(),
          totalRecords: 1000,
          processedRecords: 250,
          providerProgress: {'provider1': 100, 'provider2': 150},
          metadata: {'key': 'value', 'number': 42},
          currentPhase: 'processing',
          currentProvider: 'provider1',
          currentBatch: 5,
        );

        final json = original.toJson();
        final restored = ProgressSnapshot.fromJson(json);

        expect(restored.jobId, equals(original.jobId));
        expect(restored.totalRecords, equals(original.totalRecords));
        expect(restored.processedRecords, equals(original.processedRecords));
        expect(restored.providerProgress, equals(original.providerProgress));
        expect(restored.metadata, equals(original.metadata));
        expect(restored.currentPhase, equals(original.currentPhase));
        expect(restored.currentProvider, equals(original.currentProvider));
        expect(restored.currentBatch, equals(original.currentBatch));
        expect(
          restored.timestamp.millisecondsSinceEpoch,
          equals(original.timestamp.millisecondsSinceEpoch),
        );
      });

      test('should handle null fields in serialization', () {
        final original = ProgressSnapshot(
          jobId: 'test-job',
          timestamp: clock.now(),
          totalRecords: 1000,
          processedRecords: 250,
        );

        final json = original.toJson();
        final restored = ProgressSnapshot.fromJson(json);

        expect(restored.currentPhase, isNull);
        expect(restored.currentProvider, isNull);
        expect(restored.currentBatch, isNull);
        expect(restored.providerProgress, isEmpty);
        expect(restored.metadata, isEmpty);
      });
    });

    group('Progress Events', () {
      test('should create correct event types', () {
        final snapshot = ProgressSnapshot(
          jobId: 'test-job',
          timestamp: clock.now(),
          totalRecords: 1000,
          processedRecords: 250,
        );

        final progressEvent = ProgressEvent.updated('test-job', snapshot);
        expect(progressEvent, isA<ProgressUpdatedEvent>());
        expect(
          (progressEvent as ProgressUpdatedEvent).jobId,
          equals('test-job'),
        );
        expect(progressEvent.snapshot, equals(snapshot));

        final phaseEvent = ProgressEvent.phaseChanged('test-job', 'processing');
        expect(phaseEvent, isA<PhaseChangedEvent>());
        expect((phaseEvent as PhaseChangedEvent).jobId, equals('test-job'));
        expect(phaseEvent.phase, equals('processing'));

        final providerStartedEvent = ProgressEvent.providerStarted(
          'test-job',
          'provider1',
        );
        expect(providerStartedEvent, isA<ProviderStartedEvent>());
        expect(
          (providerStartedEvent as ProviderStartedEvent).jobId,
          equals('test-job'),
        );
        expect(providerStartedEvent.providerId, equals('provider1'));

        final providerCompletedEvent = ProgressEvent.providerCompleted(
          'test-job',
          'provider1',
        );
        expect(providerCompletedEvent, isA<ProviderCompletedEvent>());
        expect(
          (providerCompletedEvent as ProviderCompletedEvent).jobId,
          equals('test-job'),
        );
        expect(providerCompletedEvent.providerId, equals('provider1'));

        final batchEvent = ProgressEvent.batchCompleted('test-job', 5);
        expect(batchEvent, isA<BatchCompletedEvent>());
        expect((batchEvent as BatchCompletedEvent).jobId, equals('test-job'));
        expect(batchEvent.batchNumber, equals(5));
      });
    });

    group('Job Initialization', () {
      test('should initialize job progress tracking', () async {
        const jobId = 'init-test-job';
        const totalRecords = 1000;
        final metadata = {'source': 'test'};

        await tracker.initializeJob(
          jobId: jobId,
          totalRecords: totalRecords,
          metadata: metadata,
        );

        final progress = tracker.getCurrentProgress(jobId);
        expect(progress, isNotNull);
        expect(progress!.jobId, equals(jobId));
        expect(progress.totalRecords, equals(totalRecords));
        expect(progress.processedRecords, equals(0));
        expect(progress.metadata, equals(metadata));
        expect(progress.currentPhase, equals('initializing'));
      });

      test('should emit initialization event', () async {
        const jobId = 'event-test-job';

        final eventFuture = tracker.events.first;
        await tracker.initializeJob(jobId: jobId, totalRecords: 1000);

        final event = await eventFuture;

        expect(event, isA<ProgressUpdatedEvent>());
        final progressEvent = event as ProgressUpdatedEvent;
        expect(progressEvent.jobId, equals(jobId));
        expect(progressEvent.snapshot.currentPhase, equals('initializing'));
      });

      test('should persist initial snapshot to database', () async {
        const jobId = 'persist-test-job';

        await tracker.initializeJob(
          jobId: jobId,
          totalRecords: 1000,
          metadata: {'test': 'data'},
        );

        // Initial snapshot should be persisted immediately, no need to wait
        final rows = await database.select(
          'SELECT * FROM job_progress_snapshots WHERE job_id = ?',
          [jobId],
        );

        expect(rows.length, greaterThan(0));
        expect(rows.first['job_id'], equals(jobId));
        expect(rows.first['total_records'], equals(1000));
        expect(rows.first['processed_records'], equals(0));
        expect(rows.first['current_phase'], equals('initializing'));
      });
    });

    group('Progress Updates', () {
      const jobId = 'update-test-job';

      setUp(() async {
        await tracker.initializeJob(jobId: jobId, totalRecords: 1000);
      });

      test('should update processed records', () async {
        await tracker.updateProgress(jobId: jobId, processedRecords: 250);

        final progress = tracker.getCurrentProgress(jobId);
        expect(progress!.processedRecords, equals(250));
        expect(progress.progress, equals(0.25));
      });

      test('should update current phase', () async {
        await tracker.updateProgress(jobId: jobId, currentPhase: 'processing');

        final progress = tracker.getCurrentProgress(jobId);
        expect(progress!.currentPhase, equals('processing'));
      });

      test('should update provider information', () async {
        await tracker.updateProgress(
          jobId: jobId,
          currentProvider: 'provider1',
          providerProgress: {'provider1': 100},
        );

        final progress = tracker.getCurrentProgress(jobId);
        expect(progress!.currentProvider, equals('provider1'));
        expect(progress.providerProgress['provider1'], equals(100));
      });

      test('should update batch information', () async {
        await tracker.updateProgress(jobId: jobId, currentBatch: 5);

        final progress = tracker.getCurrentProgress(jobId);
        expect(progress!.currentBatch, equals(5));
      });

      test('should emit phase change event', () async {
        final eventFuture = tracker.events.whereType<PhaseChangedEvent>().first;

        await tracker.updateProgress(jobId: jobId, currentPhase: 'processing');

        final event = await eventFuture;

        expect(event.jobId, equals(jobId));
        expect(event.phase, equals('processing'));
      });

      test('should emit provider started event', () async {
        final eventFuture = tracker.events
            .whereType<ProviderStartedEvent>()
            .first;

        await tracker.updateProgress(
          jobId: jobId,
          currentProvider: 'provider1',
        );

        final event = await eventFuture;

        expect(event.jobId, equals(jobId));
        expect(event.providerId, equals('provider1'));
      });

      test('should emit batch completed event', () async {
        final eventFuture = tracker.events
            .whereType<BatchCompletedEvent>()
            .first;

        await tracker.updateProgress(jobId: jobId, currentBatch: 3);

        final event = await eventFuture;

        expect(event.jobId, equals(jobId));
        expect(event.batchNumber, equals(3));
      });

      test('should warn for uninitialized job', () async {
        await tracker.updateProgress(
          jobId: 'nonexistent-job',
          processedRecords: 100,
        );

        final progress = tracker.getCurrentProgress('nonexistent-job');
        expect(progress, isNull);
      });
    });

    group('Provider Completion', () {
      const jobId = 'provider-test-job';

      setUp(() async {
        await tracker.initializeJob(jobId: jobId, totalRecords: 1000);
        await tracker.updateProgress(
          jobId: jobId,
          currentProvider: 'provider1',
        );
      });

      test('should complete provider and clear current provider', () async {
        await tracker.completeProvider(jobId, 'provider1');

        final progress = tracker.getCurrentProgress(jobId);
        expect(progress!.currentProvider, isNull);
      });

      test('should emit provider completed event', () async {
        final eventFuture = tracker.events
            .whereType<ProviderCompletedEvent>()
            .first;

        await tracker.completeProvider(jobId, 'provider1');

        final event = await eventFuture;

        expect(event.jobId, equals(jobId));
        expect(event.providerId, equals('provider1'));
      });
    });

    group('Job Completion', () {
      const jobId = 'completion-test-job';

      setUp(() async {
        await tracker.initializeJob(jobId: jobId, totalRecords: 1000);
        await tracker.updateProgress(jobId: jobId, processedRecords: 500);
      });

      test('should complete job and mark as fully processed', () async {
        await tracker.completeJob(jobId);

        final progress = tracker.getCurrentProgress(jobId);
        expect(progress, isNull); // Should be cleaned up
      });

      test('should emit completion event', () async {
        final eventFuture = tracker.events
            .whereType<ProgressUpdatedEvent>()
            .firstWhere((event) => event.snapshot.currentPhase == 'completed');

        await tracker.completeJob(jobId);

        final event = await eventFuture;

        expect(event.jobId, equals(jobId));
        expect(event.snapshot.processedRecords, equals(1000));
        expect(event.snapshot.currentPhase, equals('completed'));
      });

      test('should persist final snapshot', () async {
        await tracker.completeJob(jobId);

        // Final snapshot should be persisted immediately, no need to wait
        final rows = await database.select(
          '''
          SELECT * FROM job_progress_snapshots 
          WHERE job_id = ? AND current_phase = 'completed'
          ORDER BY timestamp DESC
          LIMIT 1
          ''',
          [jobId],
        );

        expect(rows.length, equals(1));
        expect(rows.first['processed_records'], equals(1000));
        expect(rows.first['current_phase'], equals('completed'));
      });
    });

    group('Detailed Progress', () {
      const jobId = 'detailed-test-job';

      setUp(() async {
        await tracker.initializeJob(jobId: jobId, totalRecords: 1000);

        // Add some progress updates
        await tracker.updateProgress(
          jobId: jobId,
          processedRecords: 250,
          currentPhase: 'processing',
        );

        await tracker.updateProgress(
          jobId: jobId,
          processedRecords: 500,
          currentProvider: 'provider1',
        );
      });

      test('should get detailed progress with current data', () async {
        final detailed = await tracker.getDetailedProgress(jobId);
        expect(detailed, isNotNull);
        expect(detailed!.current.processedRecords, equals(500));
        expect(detailed.elapsed.inMilliseconds, greaterThanOrEqualTo(0));
        expect(detailed.averageRate, greaterThanOrEqualTo(0));
      });

      test('should return null for nonexistent job', () async {
        final detailed = await tracker.getDetailedProgress('nonexistent-job');
        expect(detailed, isNull);
      });

      test('should estimate time remaining with controlled time', () async {
        final startTime = DateTime(2025, 1, 1, 12, 0, 0);

        final snapshot = ProgressSnapshot(
          jobId: 'test-job',
          timestamp: startTime.add(const Duration(seconds: 10)),
          totalRecords: 1000,
          processedRecords: 250,
        );

        // Test estimation with 10 seconds elapsed
        final elapsed = const Duration(seconds: 10);
        final estimated = snapshot.estimateTimeRemaining(elapsed);

        expect(estimated, isNotNull);
        expect(
          estimated!.inSeconds,
          equals(30),
        ); // 750 records / 25 per second = 30 seconds

        // Test with different scenarios
        final halfDoneSnapshot = ProgressSnapshot(
          jobId: 'test-job',
          timestamp: startTime.add(const Duration(minutes: 1)),
          totalRecords: 1000,
          processedRecords: 500,
        );

        final halfEstimate = halfDoneSnapshot.estimateTimeRemaining(
          const Duration(minutes: 1),
        );
        expect(halfEstimate, isNotNull);
        expect(
          halfEstimate!.inMinutes,
          equals(1),
        ); // Same rate, same remaining time

        // Test completed job
        final completedSnapshot = ProgressSnapshot(
          jobId: 'test-job',
          timestamp: startTime.add(const Duration(minutes: 2)),
          totalRecords: 1000,
          processedRecords: 1000,
        );

        final completedEstimate = completedSnapshot.estimateTimeRemaining(
          const Duration(minutes: 2),
        );
        expect(
          completedEstimate,
          isNull,
        ); // No time remaining for completed job
      });

      test('should calculate progress percentages correctly', () {
        final snapshot1 = ProgressSnapshot(
          jobId: 'test-job',
          timestamp: DateTime.now(),
          totalRecords: 1000,
          processedRecords: 250,
        );

        expect(snapshot1.progress, equals(0.25));
        expect(snapshot1.progressPercent, equals(25.0));

        final snapshot2 = ProgressSnapshot(
          jobId: 'test-job',
          timestamp: DateTime.now(),
          totalRecords: 100,
          processedRecords: 0,
        );

        expect(snapshot2.progress, equals(0.0));
        expect(snapshot2.progressPercent, equals(0.0));

        final snapshot3 = ProgressSnapshot(
          jobId: 'test-job',
          timestamp: DateTime.now(),
          totalRecords: 500,
          processedRecords: 500,
        );

        expect(snapshot3.progress, equals(1.0));
        expect(snapshot3.progressPercent, equals(100.0));
      });
    });

    group('Active Jobs Statistics', () {
      test('should get statistics for active jobs', () async {
        await tracker.initializeJob(jobId: 'stats-job-1', totalRecords: 1000);
        await tracker.updateProgress(
          jobId: 'stats-job-1',
          processedRecords: 250,
          currentPhase: 'processing',
        );

        await tracker.initializeJob(jobId: 'stats-job-2', totalRecords: 500);
        await tracker.updateProgress(
          jobId: 'stats-job-2',
          processedRecords: 100,
          currentPhase: 'connecting',
        );

        final stats = tracker.getActiveJobsStats();
        expect(stats.length, equals(2));

        expect(stats['stats-job-1']!['progress'], equals(0.25));
        expect(stats['stats-job-1']!['processedRecords'], equals(250));
        expect(stats['stats-job-1']!['totalRecords'], equals(1000));
        expect(stats['stats-job-1']!['currentPhase'], equals('processing'));

        expect(stats['stats-job-2']!['progress'], equals(0.2));
        expect(stats['stats-job-2']!['processedRecords'], equals(100));
        expect(stats['stats-job-2']!['totalRecords'], equals(500));
        expect(stats['stats-job-2']!['currentPhase'], equals('connecting'));
      });

      test('should exclude completed jobs from stats', () async {
        await tracker.initializeJob(jobId: 'active-job', totalRecords: 1000);

        await tracker.initializeJob(jobId: 'completed-job', totalRecords: 500);
        await tracker.completeJob('completed-job');

        final stats = tracker.getActiveJobsStats();
        expect(stats.length, equals(1));
        expect(stats.containsKey('active-job'), isTrue);
        expect(stats.containsKey('completed-job'), isFalse);
      });
    });

    group('Persistence and Cleanup', () {
      test('should persist snapshots periodically', () async {
        const jobId = 'persistence-test-job';

        await tracker.initializeJob(jobId: jobId, totalRecords: 1000);
        await withClock(
          Clock.fixed(clock.now().add(const Duration(seconds: 1))),
          () => tracker.updateProgress(jobId: jobId, processedRecords: 250),
        );

        // Wait for periodic persistence (tracker has 100ms interval)
        await Future<void>.delayed(const Duration(milliseconds: 250));

        // Initial snapshot should be persisted immediately
        final initialRows = await database.select(
          'SELECT * FROM job_progress_snapshots WHERE job_id = ?',
          [jobId],
        );

        // Should have at least the initial snapshot
        expect(initialRows, hasLength(2));

        await withClock(
          Clock.fixed(clock.now().add(const Duration(seconds: 2))),
          () => tracker.updateProgress(jobId: jobId, processedRecords: 400),
        );

        // Wait for periodic persistence (tracker has 100ms interval)
        await Future<void>.delayed(const Duration(milliseconds: 250));

        final rows = await database.select(
          'SELECT * FROM job_progress_snapshots WHERE job_id = ? ORDER BY timestamp',
          [jobId],
        );

        // Should now have additional snapshots due to periodic persistence
        expect(rows, hasLength(3));
        expect(
          rows.map((r) => r['processed_records']),
          orderedEquals([0, 250, 400]),
        );
      });

      test('should cleanup old snapshots', () async {
        // Create tracker with very small history limit
        final smallTracker = JobProgressTracker(
          database: database,
          persistenceInterval: const Duration(milliseconds: 50),
          maxHistoryEntries: 2,
        );

        const jobId = 'cleanup-test-job';

        await smallTracker.initializeJob(jobId: jobId, totalRecords: 1000);

        // Create multiple updates to exceed history limit
        for (int i = 1; i <= 5; i++) {
          await smallTracker.updateProgress(
            jobId: jobId,
            processedRecords: i * 100,
          );
          await Future<void>.delayed(const Duration(milliseconds: 60));
        }

        // Wait for cleanup to occur during periodic persistence
        await Future<void>.delayed(const Duration(milliseconds: 200));

        final rows = await database.select(
          'SELECT * FROM job_progress_snapshots WHERE job_id = ?',
          [jobId],
        );

        // Should not exceed max history entries
        expect(rows.length, lessThanOrEqualTo(2));

        await smallTracker.dispose();
      });

      test(
        'should cleanup completed jobs older than specified duration',
        () async {
          const oldJobId = 'old-completed-job';
          const recentJobId = 'recent-completed-job';

          // Create old completed job snapshot
          await database.execute(
            '''
          INSERT INTO job_progress_snapshots (
            job_id, timestamp, total_records, processed_records,
            provider_progress, metadata, current_phase
          ) VALUES (?, ?, ?, ?, ?, ?, ?)
          ''',
            [
              oldJobId,
              clock.now().subtract(const Duration(days: 10)).toIso8601String(),
              1000,
              1000,
              '{}',
              '{}',
              'completed',
            ],
          );

          // Create recent completed job snapshot
          await database.execute(
            '''
          INSERT INTO job_progress_snapshots (
            job_id, timestamp, total_records, processed_records,
            provider_progress, metadata, current_phase
          ) VALUES (?, ?, ?, ?, ?, ?, ?)
          ''',
            [
              recentJobId,
              clock.now().toIso8601String(),
              500,
              500,
              '{}',
              '{}',
              'completed',
            ],
          );

          // Cleanup jobs older than 5 days
          final deletedCount = await tracker.cleanupCompletedJobs(
            olderThan: const Duration(days: 5),
          );

          expect(deletedCount, equals(1));

          // Verify old job was deleted
          final oldRows = await database.select(
            'SELECT * FROM job_progress_snapshots WHERE job_id = ?',
            [oldJobId],
          );
          expect(oldRows, isEmpty);

          // Verify recent job was kept
          final recentRows = await database.select(
            'SELECT * FROM job_progress_snapshots WHERE job_id = ?',
            [recentJobId],
          );
          expect(recentRows.length, equals(1));
        },
      );
    });

    group('Error Handling', () {
      test(
        'should handle database errors gracefully during persistence',
        () async {
          const jobId = 'error-test-job';

          // Initialize first before closing database
          await tracker.initializeJob(jobId: jobId, totalRecords: 1000);

          // Close database to simulate error
          await database.close();

          // Should not throw, even if persistence fails
          await tracker.updateProgress(jobId: jobId, processedRecords: 100);

          // Progress should still be tracked in memory
          final progress = tracker.getCurrentProgress(jobId);
          expect(progress, isNotNull);
          expect(progress!.processedRecords, equals(100));
        },
      );

      test('should handle invalid JSON in database', () async {
        const jobId = 'invalid-json-job';

        // Insert invalid JSON data
        await database.execute(
          '''
          INSERT INTO job_progress_snapshots (
            job_id, timestamp, total_records, processed_records,
            provider_progress, metadata, current_phase
          ) VALUES (?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            jobId,
            clock.now().toIso8601String(),
            1000,
            250,
            'invalid json',
            'also invalid',
            'processing',
          ],
        );

        // Should handle gracefully when retrieving history
        await tracker.initializeJob(jobId: jobId, totalRecords: 1000);

        final detailed = await tracker.getDetailedProgress(jobId);
        expect(detailed, isNotNull);
        // History might be empty due to JSON parsing errors, but current should work
        expect(detailed!.current, isNotNull);
      });
    });

    group('Concurrent Operations', () {
      test('should handle concurrent progress updates', () async {
        const jobId = 'concurrent-test-job';

        await tracker.initializeJob(jobId: jobId, totalRecords: 1000);

        final futures = <Future<void>>[];

        // Start multiple concurrent updates
        for (int i = 1; i <= 5; i++) {
          futures.add(
            tracker.updateProgress(
              jobId: jobId,
              processedRecords: i * 100,
              currentBatch: i,
            ),
          );
        }

        await Future.wait(futures);

        final progress = tracker.getCurrentProgress(jobId);
        expect(progress, isNotNull);
        expect(progress!.processedRecords, greaterThan(0));
        expect(progress.currentBatch, greaterThan(0));
      });

      test('should handle concurrent job initializations', () async {
        final futures = <Future<void>>[];

        for (int i = 1; i <= 3; i++) {
          futures.add(
            tracker.initializeJob(
              jobId: 'concurrent-job-$i',
              totalRecords: 1000 * i,
            ),
          );
        }

        await Future.wait(futures);

        final stats = tracker.getActiveJobsStats();
        expect(stats.length, equals(3));
        expect(stats.containsKey('concurrent-job-1'), isTrue);
        expect(stats.containsKey('concurrent-job-2'), isTrue);
        expect(stats.containsKey('concurrent-job-3'), isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle empty metadata and provider progress', () async {
        const jobId = 'empty-data-job';

        await tracker.initializeJob(
          jobId: jobId,
          totalRecords: 1000,
          metadata: {},
        );

        await tracker.updateProgress(
          jobId: jobId,
          providerProgress: {},
          metadata: {},
        );

        final progress = tracker.getCurrentProgress(jobId);
        expect(progress, isNotNull);
        expect(progress!.metadata, isEmpty);
        expect(progress.providerProgress, isEmpty);
      });

      test('should handle very large metadata', () async {
        const jobId = 'large-metadata-job';

        final largeMetadata = <String, dynamic>{};
        for (int i = 0; i < 100; i++) {
          largeMetadata['key_$i'] = 'value_$i' * 100; // Large strings
        }

        await tracker.initializeJob(
          jobId: jobId,
          totalRecords: 1000,
          metadata: largeMetadata,
        );

        final progress = tracker.getCurrentProgress(jobId);
        expect(progress, isNotNull);
        expect(progress!.metadata.length, equals(100));
      });

      test('should handle special characters in job data', () async {
        const jobId = 'special-chars-job-🚀';

        final specialMetadata = {
          'unicode': '测试数据 🎉',
          'json_chars': '{"key": "value", "array": [1,2,3]}',
          'quotes': 'He said "Hello" and she said \'Hi\'',
          'newlines': 'Line 1\nLine 2\rLine 3\r\n',
        };

        await tracker.initializeJob(
          jobId: jobId,
          totalRecords: 1000,
          metadata: specialMetadata,
        );

        final progress = tracker.getCurrentProgress(jobId);
        expect(progress, isNotNull);
        expect(progress!.metadata, equals(specialMetadata));
      });
    });

    group('Disposal', () {
      test('should dispose cleanly', () async {
        const jobId = 'disposal-test-job';

        await tracker.initializeJob(jobId: jobId, totalRecords: 1000);

        await tracker.updateProgress(jobId: jobId, processedRecords: 250);

        // Should not throw
        await tracker.dispose();

        // Should be able to dispose multiple times
        await tracker.dispose();
      });

      test('should persist final snapshots on disposal', () async {
        const jobId = 'final-snapshot-job';

        await tracker.initializeJob(jobId: jobId, totalRecords: 1000);

        await tracker.updateProgress(
          jobId: jobId,
          processedRecords: 750,
          currentPhase: 'finalizing',
        );

        await tracker.dispose();

        // Check that final state was persisted
        final rows = await database.select(
          '''
          SELECT * FROM job_progress_snapshots 
          WHERE job_id = ? 
          ORDER BY timestamp DESC 
          LIMIT 1
          ''',
          [jobId],
        );

        expect(rows.length, equals(1));
        expect(rows.first['processed_records'], equals(750));
        expect(rows.first['current_phase'], equals('finalizing'));
      });

      test('should clear in-memory state on disposal', () async {
        const jobId = 'memory-cleanup-job';

        await tracker.initializeJob(jobId: jobId, totalRecords: 1000);

        final statsBefore = tracker.getActiveJobsStats();
        expect(statsBefore.length, equals(1));

        await tracker.dispose();

        final statsAfter = tracker.getActiveJobsStats();
        expect(statsAfter.length, equals(0));
      });

      test('should close event stream on disposal', () async {
        bool streamClosed = false;

        final subscription = tracker.events.listen(
          (_) {},
          onDone: () => streamClosed = true,
        );

        await tracker.dispose();

        // Wait a bit for stream to close
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(streamClosed, isTrue);
        subscription.cancel();
      });
    });
  });
}

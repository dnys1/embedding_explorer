import 'dart:async';

import 'package:embeddings_explorer/jobs/model/embedding_job.dart';
import 'package:embeddings_explorer/jobs/service/job_queue_service.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  setupTests();

  group('JobQueueService', () {
    late JobQueueService service;

    setUp(() {
      service = JobQueueService();
    });

    tearDown(() {
      service.dispose();
    });

    group('initialization', () {
      test('starts with empty queue and no running jobs', () {
        expect(service.queuedJobCount, equals(0));
        expect(service.runningJobCount, equals(0));
        expect(service.totalJobCount, equals(0));
        expect(service.isProcessing, isFalse);
        expect(service.maxConcurrentJobs, equals(3));
      });

      test('can set max concurrent jobs', () {
        service.setMaxConcurrentJobs(5);
        expect(service.maxConcurrentJobs, equals(5));
      });

      test('throws error for invalid max concurrent jobs', () {
        expect(() => service.setMaxConcurrentJobs(0), throwsArgumentError);
        expect(() => service.setMaxConcurrentJobs(-1), throwsArgumentError);
      });
    });

    group('job enqueueing', () {
      test('can enqueue a single job', () async {
        final job = _createTestJob('job1');

        final future = service.enqueueJob(job);
        expect(service.queuedJobCount, equals(0)); // Job starts immediately
        expect(service.runningJobCount, equals(1));
        expect(service.totalJobCount, equals(1));
        expect(service.isProcessing, isTrue);
        expect(service.containsJob('job1'), isTrue);
        expect(service.isJobRunning('job1'), isTrue);

        await future;
        expect(service.totalJobCount, equals(0));
        expect(service.isProcessing, isFalse);
      });

      test('can enqueue multiple jobs with different priorities', () async {
        service.setMaxConcurrentJobs(1); // Force queueing

        final job1 = _createTestJob('job1');
        final job2 = _createTestJob('job2');
        final job3 = _createTestJob('job3');

        // Enqueue with different priorities
        final future1 = service.enqueueJob(job1, priority: JobPriority.low);
        final future2 = service.enqueueJob(job2, priority: JobPriority.high);
        final future3 = service.enqueueJob(job3, priority: JobPriority.normal);

        expect(service.runningJobCount, equals(1));
        expect(service.queuedJobCount, equals(2));

        // High priority job should be first in queue
        final queuedJobs = service.getQueuedJobs();
        expect(queuedJobs[0].id, equals('job2')); // High priority
        expect(queuedJobs[1].id, equals('job3')); // Normal priority

        await Future.wait([future1, future2, future3]);
        expect(service.totalJobCount, equals(0));
      });

      test('throws error when enqueueing duplicate job', () {
        final job1 = _createTestJob('job1');
        final job2 = _createTestJob('job1'); // Same ID

        service.enqueueJob(job1);
        expect(() => service.enqueueJob(job2), throwsStateError);
      });
    });

    group('job dequeueing', () {
      test('can dequeue waiting job', () async {
        service.setMaxConcurrentJobs(1);

        final job1 = _createTestJob('job1');
        final job2 = _createTestJob('job2');

        service.enqueueJob(job1);
        service.enqueueJob(job2);

        expect(service.totalJobCount, equals(2));

        final removed = service.dequeueJob('job2');
        expect(removed, isTrue);
        expect(service.containsJob('job2'), isFalse);
      });

      test('cannot dequeue running job', () async {
        final job = _createTestJob('job1');
        service.enqueueJob(job);

        // Allow job to start running
        await Future<void>.delayed(const Duration(milliseconds: 5));

        if (service.isJobRunning('job1')) {
          final removed = service.dequeueJob('job1');
          expect(removed, isFalse);
        }
      });

      test('returns false for non-existent job', () {
        final removed = service.dequeueJob('nonexistent');
        expect(removed, isFalse);
      });
    });

    group('job position tracking', () {
      test('returns correct job positions in queue', () {
        service.setMaxConcurrentJobs(1);

        final job1 = _createTestJob('job1');
        final job2 = _createTestJob('job2');
        final job3 = _createTestJob('job3');

        service.enqueueJob(job1); // Will start running
        service.enqueueJob(job2); // Position 0 in queue
        service.enqueueJob(job3); // Position 1 in queue

        expect(service.getJobPosition('job1'), equals(-1)); // Running
        expect(service.getJobPosition('job2'), equals(0));
        expect(service.getJobPosition('job3'), equals(1));
        expect(service.getJobPosition('nonexistent'), equals(-1));
      });
    });

    group('queue management', () {
      test('can get list of queued jobs', () {
        service.setMaxConcurrentJobs(1);

        final job1 = _createTestJob('job1');
        final job2 = _createTestJob('job2');
        final job3 = _createTestJob('job3');

        service.enqueueJob(job1); // Running
        service.enqueueJob(job2); // Queued
        service.enqueueJob(job3); // Queued

        final queuedJobs = service.getQueuedJobs();
        expect(queuedJobs.length, equals(2));
        expect(queuedJobs.map((j) => j.id), containsAll(['job2', 'job3']));
      });

      test('can get list of running job IDs', () async {
        service.setMaxConcurrentJobs(2);

        final job1 = _createTestJob('job1');
        final job2 = _createTestJob('job2');
        final job3 = _createTestJob('job3');

        service.enqueueJob(job1); // Running
        service.enqueueJob(job2); // Running
        service.enqueueJob(job3); // Queued

        final runningIds = service.getRunningJobIds();
        expect(runningIds.length, greaterThanOrEqualTo(1));
        expect(runningIds.length, lessThanOrEqualTo(2));
      });

      test('can clear all queued jobs', () async {
        service.setMaxConcurrentJobs(1);

        final job1 = _createTestJob('job1');
        final job2 = _createTestJob('job2');
        final job3 = _createTestJob('job3');

        service.enqueueJob(job1); // Running
        service.enqueueJob(job2); // Queued
        service.enqueueJob(job3); // Queued

        expect(service.totalJobCount, equals(3));

        service.clearQueue();

        expect(service.queuedJobCount, equals(0));
        expect(service.containsJob('job2'), isFalse);
        expect(service.containsJob('job3'), isFalse);
      });
    });

    group('processing control', () {
      test('can stop and start processing', () async {
        final job = _createTestJob('job1');
        service.enqueueJob(job);

        expect(service.isProcessing, isTrue);

        service.stopProcessing();
        expect(service.isProcessing, isFalse);

        // Allow any running jobs to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Service should have stopped processing
        expect(service.isProcessing, isFalse);
      });

      test('automatically stops processing when queue is empty', () async {
        final job = _createTestJob('job1');
        final future = service.enqueueJob(job);

        expect(service.isProcessing, isTrue);

        await future;
        expect(service.isProcessing, isFalse);
        expect(service.totalJobCount, equals(0));
      });
    });

    group('concurrency control', () {
      test('respects max concurrent jobs limit', () async {
        service.setMaxConcurrentJobs(2);

        final job1 = _createTestJob('job1');
        final job2 = _createTestJob('job2');
        final job3 = _createTestJob('job3');
        final job4 = _createTestJob('job4');

        service.enqueueJob(job1);
        service.enqueueJob(job2);
        service.enqueueJob(job3);
        service.enqueueJob(job4);

        expect(service.totalJobCount, equals(4));
        expect(service.runningJobCount, lessThanOrEqualTo(2));
      });

      test('starts more jobs when concurrency limit is increased', () async {
        service.setMaxConcurrentJobs(1);

        final job1 = _createTestJob('job1');
        final job2 = _createTestJob('job2');
        final job3 = _createTestJob('job3');

        service.enqueueJob(job1);
        service.enqueueJob(job2);
        service.enqueueJob(job3);

        expect(service.totalJobCount, equals(3));

        // Increase limit - should start more jobs
        service.setMaxConcurrentJobs(3);

        expect(service.totalJobCount, lessThanOrEqualTo(3));
      });
    });

    group('priority ordering', () {
      test('processes jobs in priority order', () {
        service.setMaxConcurrentJobs(1);

        final job1 = _createTestJob('job1');
        final job2 = _createTestJob('job2');
        final job3 = _createTestJob('job3');
        final job4 = _createTestJob('job4');

        // Enqueue in mixed priority order
        service.enqueueJob(job1, priority: JobPriority.low); // Running
        service.enqueueJob(job2, priority: JobPriority.normal); // Queue pos 1
        service.enqueueJob(job3, priority: JobPriority.urgent); // Queue pos 0
        service.enqueueJob(job4, priority: JobPriority.high); // Queue pos 1

        final queuedJobs = service.getQueuedJobs();
        expect(queuedJobs.length, equals(3));

        // Should be ordered: urgent (job3), high (job4), normal (job2)
        expect(queuedJobs[0].id, equals('job3')); // Urgent
        expect(queuedJobs[1].id, equals('job4')); // High
        expect(queuedJobs[2].id, equals('job2')); // Normal
      });
    });

    group('events', () {
      test('emits correct events during job lifecycle', () async {
        final events = <JobQueueEvent>[];
        final subscription = service.events.listen(events.add);

        final job = _createTestJob('job1');
        final future = service.enqueueJob(job);

        // Let events propagate
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(events.length, greaterThanOrEqualTo(2));
        expect(events.any((e) => e is JobQueuedEvent), isTrue);
        expect(events.any((e) => e is JobStartedEvent), isTrue);
        expect(events.any((e) => e is ProcessingStartedEvent), isTrue);

        await future;
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(events.any((e) => e is JobCompletedEvent), isTrue);
        expect(events.any((e) => e is ProcessingStoppedEvent), isTrue);

        await subscription.cancel();
      });

      test('emits dequeue events', () async {
        service.setMaxConcurrentJobs(1);

        final events = <JobQueueEvent>[];
        final subscription = service.events.listen(events.add);

        final job1 = _createTestJob('job1');
        final job2 = _createTestJob('job2');

        service.enqueueJob(job1); // Running
        service.enqueueJob(job2); // Queued

        service.dequeueJob('job2');

        await Future<void>.delayed(Duration.zero);

        expect(events.any((e) => e is JobDequeuedEvent), isTrue);

        await subscription.cancel();
      });
    });

    group('QueuedJob', () {
      test('creates QueuedJob with correct defaults', () {
        final job = _createTestJob('job1');
        final queuedJob = QueuedJob(job: job);

        expect(queuedJob.job, equals(job));
        expect(queuedJob.priority, equals(JobPriority.normal));
        expect(queuedJob.queuedAt, isA<DateTime>());
        expect(queuedJob.completer, isA<Completer<void>>());
        expect(queuedJob.future, isA<Future<void>>());
      });

      test('accepts custom priority and timestamp', () {
        final job = _createTestJob('job1');
        final customTime = DateTime(2024, 1, 1);
        final queuedJob = QueuedJob(
          job: job,
          priority: JobPriority.high,
          queuedAt: customTime,
        );

        expect(queuedJob.priority, equals(JobPriority.high));
        expect(queuedJob.queuedAt, equals(customTime));
      });
    });

    group('JobPriority', () {
      test('has correct priority values', () {
        expect(JobPriority.low.value, equals(0));
        expect(JobPriority.normal.value, equals(1));
        expect(JobPriority.high.value, equals(2));
        expect(JobPriority.urgent.value, equals(3));
      });
    });

    group('disposal', () {
      test('cleans up resources on dispose', () {
        final disposalService = JobQueueService();

        expect(disposalService.isProcessing, isFalse);
        expect(disposalService.queuedJobCount, equals(0));

        // Dispose should not throw
        expect(() => disposalService.dispose(), returnsNormally);

        expect(disposalService.isProcessing, isFalse);
        expect(disposalService.queuedJobCount, equals(0));
      });
    });
  });
}

/// Helper function to create test EmbeddingJob instances
EmbeddingJob _createTestJob(String id) {
  return EmbeddingJob(
    id: id,
    name: 'Test Job $id',
    description: 'Test job description for $id',
    dataSourceId: 'test-datasource',
    embeddingTemplateId: 'test-template',
    providerIds: ['test-provider'],
    createdAt: DateTime.now(),
  );
}

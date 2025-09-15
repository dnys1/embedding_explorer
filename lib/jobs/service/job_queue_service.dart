import 'dart:async';
import 'dart:collection';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../model/embedding_job.dart';

/// Priority levels for job execution
enum JobPriority {
  low(0),
  normal(1),
  high(2),
  urgent(3);

  const JobPriority(this.value);
  final int value;
}

/// Represents a queued job with priority and metadata
class QueuedJob {
  final EmbeddingJob job;
  final JobPriority priority;
  final DateTime queuedAt;
  final Completer<void> completer;

  QueuedJob({
    required this.job,
    this.priority = JobPriority.normal,
    DateTime? queuedAt,
  }) : queuedAt = queuedAt ?? DateTime.now(),
       completer = Completer<void>();

  /// Future that completes when the job finishes processing
  Future<void> get future => completer.future;
}

/// Service for managing job queue execution with priority and concurrency control
class JobQueueService {
  static final Logger _logger = Logger('JobQueueService');

  final Queue<QueuedJob> _queue = Queue<QueuedJob>();
  final Set<String> _runningJobs = <String>{};
  final Map<String, QueuedJob> _jobMap = <String, QueuedJob>{};

  int _maxConcurrentJobs = 3;
  bool _isProcessing = false;

  final StreamController<JobQueueEvent> _eventController =
      StreamController<JobQueueEvent>.broadcast();

  /// Stream of queue events (job added, started, completed, etc.)
  Stream<JobQueueEvent> get events => _eventController.stream;

  /// Current number of running jobs
  int get runningJobCount => _runningJobs.length;

  /// Current number of queued jobs
  int get queuedJobCount => _queue.length;

  /// Maximum number of concurrent jobs
  int get maxConcurrentJobs => _maxConcurrentJobs;

  /// Total number of jobs (running + queued)
  int get totalJobCount => runningJobCount + queuedJobCount;

  /// Whether the queue is currently processing jobs
  bool get isProcessing => _isProcessing;

  bool get _isDisposed => _eventController.isClosed;

  /// Set the maximum number of concurrent jobs
  void setMaxConcurrentJobs(int maxJobs) {
    if (maxJobs < 1) {
      throw ArgumentError('maxJobs must be at least 1');
    }

    _logger.info('Setting max concurrent jobs to: $maxJobs');
    _maxConcurrentJobs = maxJobs;

    // Try to start more jobs if we increased the limit
    if (_isProcessing) {
      _processQueue();
    }
  }

  /// Add a job to the queue
  @awaitNotRequired
  Future<void> enqueueJob(
    EmbeddingJob job, {
    JobPriority priority = JobPriority.normal,
  }) async {
    if (_jobMap.containsKey(job.id)) {
      throw StateError('Job already in queue: ${job.id}');
    }

    final queuedJob = QueuedJob(job: job, priority: priority);
    _jobMap[job.id] = queuedJob;

    // Insert job in priority order
    _insertJobByPriority(queuedJob);

    _logger.info('Enqueued job: ${job.id} with priority: ${priority.name}');
    _eventController.add(JobQueueEvent.jobQueued(job));

    // Start processing if not already running
    if (!_isProcessing) {
      _startProcessing();
    }

    return queuedJob.future;
  }

  /// Remove a job from the queue (if not already running)
  bool dequeueJob(String jobId) {
    final queuedJob = _jobMap[jobId];
    if (queuedJob == null) {
      return false;
    }

    if (_runningJobs.contains(jobId)) {
      _logger.warning('Cannot dequeue running job: $jobId');
      return false;
    }

    _queue.remove(queuedJob);
    _jobMap.remove(jobId);
    queuedJob.completer.complete();

    _logger.info('Dequeued job: $jobId');
    _eventController.add(JobQueueEvent.jobDequeued(queuedJob.job));

    return true;
  }

  /// Check if a job is in the queue (running or waiting)
  bool containsJob(String jobId) {
    return _jobMap.containsKey(jobId);
  }

  /// Check if a job is currently running
  bool isJobRunning(String jobId) {
    return _runningJobs.contains(jobId);
  }

  /// Get the position of a job in the queue (0-based, -1 if not found)
  int getJobPosition(String jobId) {
    final queuedJob = _jobMap[jobId];
    if (queuedJob == null || _runningJobs.contains(jobId)) {
      return -1;
    }

    return _queue.toList().indexOf(queuedJob);
  }

  /// Get all queued jobs (not including running jobs)
  List<EmbeddingJob> getQueuedJobs() {
    return _queue.map((qj) => qj.job).toList();
  }

  /// Get all running job IDs
  List<String> getRunningJobIds() {
    return _runningJobs.toList();
  }

  /// Start processing the queue
  void _startProcessing() {
    if (_isProcessing) {
      return;
    }

    _isProcessing = true;
    _logger.info('Started job queue processing');
    _eventController.add(const JobQueueEvent.processingStarted());

    _processQueue();
  }

  /// Stop processing the queue
  void stopProcessing() {
    if (!_isProcessing) {
      return;
    }

    _isProcessing = false;
    _logger.info('Stopped job queue processing');
    _eventController.add(const JobQueueEvent.processingStopped());
  }

  /// Process the next jobs in queue up to max concurrency
  void _processQueue() {
    if (!_isProcessing) {
      return;
    }

    while (_runningJobs.length < _maxConcurrentJobs && _queue.isNotEmpty) {
      final queuedJob = _queue.removeFirst();
      _runningJobs.add(queuedJob.job.id);

      _logger.info('Starting job: ${queuedJob.job.id}');
      _eventController.add(JobQueueEvent.jobStarted(queuedJob.job));
    }

    // If no more jobs are running or queued, stop processing
    if (_runningJobs.isEmpty && _queue.isEmpty) {
      stopProcessing();
    }
  }

  /// Mark a job as completed and continue processing
  void completeJob(String jobId, {String? error}) {
    if (_isDisposed) {
      _logger.warning('Attempted to complete job after disposal: $jobId');
      return;
    }

    final queuedJob = _jobMap.remove(jobId);
    if (queuedJob == null) {
      _logger.warning('Attempted to complete unknown job: $jobId');
      return;
    }

    _runningJobs.remove(jobId);

    if (queuedJob.completer.isCompleted) {
      throw StateError('Job already completed: $jobId');
    }

    final isSuccess = error == null;
    if (isSuccess) {
      _logger.info('Completed job: $jobId');
      _eventController.add(JobQueueEvent.jobCompleted(queuedJob.job));
      queuedJob.completer.complete();
    } else {
      _logger.severe('Failed job: $jobId - $error');
      _eventController.add(JobQueueEvent.jobFailed(queuedJob.job, error));
      queuedJob.completer.completeError(error);
    }

    // Continue processing remaining jobs
    _processQueue();
  }

  /// Insert a job into the queue maintaining priority order
  void _insertJobByPriority(QueuedJob queuedJob) {
    if (_queue.isEmpty) {
      _queue.add(queuedJob);
      return;
    }

    final queueList = _queue.toList();
    int insertIndex = queueList.length;

    // Find insertion point based on priority (higher priority first)
    for (int i = 0; i < queueList.length; i++) {
      if (queuedJob.priority.value > queueList[i].priority.value) {
        insertIndex = i;
        break;
      }
    }

    // Rebuild queue with new job inserted
    _queue.clear();
    for (int i = 0; i < queueList.length; i++) {
      if (i == insertIndex) {
        _queue.add(queuedJob);
      }
      _queue.add(queueList[i]);
    }

    // If we didn't insert yet, add at the end
    if (insertIndex == queueList.length) {
      _queue.add(queuedJob);
    }
  }

  /// Clear all queued jobs (does not affect running jobs)
  void clearQueue() {
    final queuedJobs = _queue.toList();
    _queue.clear();

    for (final queuedJob in queuedJobs) {
      _jobMap.remove(queuedJob.job.id);
      queuedJob.completer.complete();
      _eventController.add(JobQueueEvent.jobDequeued(queuedJob.job));
    }

    _logger.info('Cleared ${queuedJobs.length} queued jobs');
  }

  /// Dispose resources
  void dispose() {
    if (_eventController.isClosed) {
      return;
    }
    stopProcessing();
    clearQueue();
    _eventController.close();
    _logger.info('JobQueueService disposed');
  }
}

/// Events emitted by the job queue
sealed class JobQueueEvent {
  const JobQueueEvent();

  const factory JobQueueEvent.jobQueued(EmbeddingJob job) = JobQueuedEvent;
  const factory JobQueueEvent.jobDequeued(EmbeddingJob job) = JobDequeuedEvent;
  const factory JobQueueEvent.jobStarted(EmbeddingJob job) = JobStartedEvent;
  const factory JobQueueEvent.jobCompleted(EmbeddingJob job) =
      JobCompletedEvent;
  const factory JobQueueEvent.jobFailed(EmbeddingJob job, String error) =
      JobFailedEvent;
  const factory JobQueueEvent.processingStarted() = ProcessingStartedEvent;
  const factory JobQueueEvent.processingStopped() = ProcessingStoppedEvent;
}

final class JobQueuedEvent extends JobQueueEvent {
  final EmbeddingJob job;
  const JobQueuedEvent(this.job);
}

final class JobDequeuedEvent extends JobQueueEvent {
  final EmbeddingJob job;
  const JobDequeuedEvent(this.job);
}

final class JobStartedEvent extends JobQueueEvent {
  final EmbeddingJob job;
  const JobStartedEvent(this.job);
}

final class JobCompletedEvent extends JobQueueEvent {
  final EmbeddingJob job;
  const JobCompletedEvent(this.job);
}

final class JobFailedEvent extends JobQueueEvent {
  final EmbeddingJob job;
  final String error;
  const JobFailedEvent(this.job, this.error);
}

final class ProcessingStartedEvent extends JobQueueEvent {
  const ProcessingStartedEvent();
}

final class ProcessingStoppedEvent extends JobQueueEvent {
  const ProcessingStoppedEvent();
}

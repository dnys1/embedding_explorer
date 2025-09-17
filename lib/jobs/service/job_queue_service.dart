import 'dart:async';
import 'dart:collection';

import 'package:logging/logging.dart';

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

  QueuedJob({
    required this.job,
    this.priority = JobPriority.normal,
    DateTime? queuedAt,
  }) : queuedAt = queuedAt ?? DateTime.now();
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
  void enqueueJob(
    EmbeddingJob job, {
    JobPriority priority = JobPriority.normal,
  }) async {
    if (_jobMap.containsKey(job.id)) {
      throw StateError('Job already in queue: ${job.id}');
    }

    // Check if queue was empty before adding the job
    final wasQueueEmpty = _wasQueueEmpty();

    final queuedJob = QueuedJob(job: job, priority: priority);
    _jobMap[job.id] = queuedJob;

    // Insert job in priority order
    _insertJobByPriority(queuedJob);

    _logger.info('Enqueued job: ${job.id} with priority: ${priority.name}');

    // Always restart processing if the queue was previously empty,
    // or start processing if not already running
    if (wasQueueEmpty || !_isProcessing) {
      _startProcessing();
    } else {
      // If already processing, trigger queue processing to handle new job
      _processQueue();
    }
  }

  /// Remove a job from the queue (if not already running)
  bool dequeueJob(String jobId) {
    final queuedJob = _jobMap[jobId];
    if (queuedJob == null) {
      return false;
    }

    if (_runningJobs.contains(jobId)) {
      return false;
    }

    _queue.remove(queuedJob);
    _jobMap.remove(jobId);

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

    _processQueue();
  }

  /// Stop processing the queue
  void stopProcessing() {
    if (!_isProcessing) {
      return;
    }

    _isProcessing = false;
    _logger.info('Stopped job queue processing');
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

  /// Check if the queue was empty before adding a job
  bool _wasQueueEmpty() {
    return _queue.isEmpty && _runningJobs.isEmpty;
  }

  /// Mark a job as completed and continue processing
  void completeJob(String jobId) {
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

  const factory JobQueueEvent.jobDequeued(EmbeddingJob job) = JobDequeuedEvent;
  const factory JobQueueEvent.jobStarted(EmbeddingJob job) = JobStartedEvent;
}

final class JobDequeuedEvent extends JobQueueEvent {
  final EmbeddingJob job;
  const JobDequeuedEvent(this.job);
}

final class JobStartedEvent extends JobQueueEvent {
  final EmbeddingJob job;
  const JobStartedEvent(this.job);
}

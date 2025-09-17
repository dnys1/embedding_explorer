import 'dart:async';

import 'package:clock/clock.dart';
import 'package:logging/logging.dart';

import 'job_resume_service.dart';

/// Represents a progress snapshot at a point in time
class ProgressSnapshot {
  final String jobId;
  final DateTime timestamp;
  final int totalRecords;
  final int processedRecords;

  /// Batch number per provider/model
  final Map<(String, String), int> providerProgress;
  final Map<String, dynamic> metadata;
  final String? currentPhase;

  const ProgressSnapshot({
    required this.jobId,
    required this.timestamp,
    required this.totalRecords,
    required this.processedRecords,
    this.providerProgress = const {},
    this.metadata = const {},
    this.currentPhase,
  });

  /// Progress percentage (0.0 to 1.0)
  double get progress =>
      totalRecords > 0 ? processedRecords / totalRecords : 0.0;

  /// Progress percentage (0 to 100)
  double get progressPercent => progress * 100.0;

  /// Estimated time remaining based on current rate
  Duration? estimateTimeRemaining(Duration elapsed) {
    if (processedRecords == 0 || progress >= 1.0) return null;

    final rate = processedRecords / elapsed.inMilliseconds;
    final remaining = totalRecords - processedRecords;
    final estimatedMs = (remaining / rate).round();

    return Duration(milliseconds: estimatedMs);
  }
}

/// Service for tracking and persisting job progress with real-time updates
class JobProgressTracker {
  static final Logger _logger = Logger('ProgressTracker');

  final Map<String, ProgressSnapshot> _currentProgress = {};
  final Map<String, DateTime> _jobStartTimes = {};

  final StreamController<ProgressSnapshot> _eventController =
      StreamController<ProgressSnapshot>.broadcast();

  JobProgressTracker();

  /// Stream of progress events
  Stream<ProgressSnapshot> get events => _eventController.stream;

  Future<void> restoreJobProgress(ResumableJob resumableJob) async {
    final job = resumableJob.job;
    _logger.info('Restoring progress tracking for job: ${job.id}');

    final latest = ProgressSnapshot(
      jobId: job.id,
      timestamp: DateTime.now(),
      totalRecords: job.totalRecords!,
      processedRecords: resumableJob.processedRecords,
      providerProgress: resumableJob.lastCompletedBatchByProvider,
    );
    _currentProgress[job.id] = latest;
    _jobStartTimes[job.id] =
        resumableJob.checkpoints.firstOrNull?.timestamp ?? DateTime.now();

    _eventController.add(latest);

    _logger.info('Restored progress tracking for job: ${job.id}');
  }

  /// Initialize progress tracking for a job
  Future<void> initializeJob({
    required String jobId,
    required int totalRecords,
    Map<String, dynamic>? metadata,
  }) async {
    _logger.info('Initializing progress tracking for job: $jobId');

    final now = clock.now();
    _jobStartTimes[jobId] = now;

    final initialSnapshot = ProgressSnapshot(
      jobId: jobId,
      timestamp: now,
      totalRecords: totalRecords,
      processedRecords: 0,
      metadata: metadata ?? {},
      currentPhase: 'initializing',
    );

    _currentProgress[jobId] = initialSnapshot;

    _eventController.add(initialSnapshot);
  }

  /// Update progress for a job
  Future<void> updateProgress({
    required String jobId,
    int? processedRecords,
    String? currentPhase,
    Map<(String, String), int>? providerProgress,
    Map<String, dynamic>? metadata,
  }) async {
    final currentSnapshot = _currentProgress[jobId]!;
    final updatedSnapshot = ProgressSnapshot(
      jobId: jobId,
      timestamp: clock.now(),
      totalRecords: currentSnapshot.totalRecords,
      processedRecords:
          currentSnapshot.processedRecords + (processedRecords ?? 0),
      providerProgress: {
        ...currentSnapshot.providerProgress,
        ...?providerProgress,
      },
      metadata: metadata ?? currentSnapshot.metadata,
      currentPhase: currentPhase ?? currentSnapshot.currentPhase,
    );

    _currentProgress[jobId] = updatedSnapshot;
    _eventController.add(updatedSnapshot);
  }

  /// Complete progress tracking for a job
  Future<void> completeJob(String jobId) async {
    _logger.info('Completing progress tracking for job: $jobId');

    final currentSnapshot = _currentProgress[jobId];
    if (currentSnapshot != null) {
      final completedSnapshot = ProgressSnapshot(
        jobId: jobId,
        timestamp: clock.now(),
        totalRecords: currentSnapshot.totalRecords,
        processedRecords: currentSnapshot.processedRecords,
        providerProgress: currentSnapshot.providerProgress,
        metadata: currentSnapshot.metadata,
        currentPhase: 'completed',
      );

      _currentProgress[jobId] = completedSnapshot;
      _eventController.add(completedSnapshot);
    }

    // Clean up
    _currentProgress.remove(jobId);
    _jobStartTimes.remove(jobId);
  }

  Future<void> deleteJobProgress(String jobId) async {
    // Clean up in-memory state
    _currentProgress.remove(jobId);
    _jobStartTimes.remove(jobId);
  }

  /// Get current progress for a job
  ProgressSnapshot? getCurrentProgress(String jobId) {
    return _currentProgress[jobId];
  }

  /// Dispose resources
  Future<void> dispose() async {
    _logger.info('Disposing ProgressTracker');

    await _eventController.close();

    _currentProgress.clear();
    _jobStartTimes.clear();

    _logger.info('ProgressTracker disposed');
  }
}

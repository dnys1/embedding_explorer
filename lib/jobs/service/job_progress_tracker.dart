import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:logging/logging.dart';

import '../../database/database.dart';

/// Represents a progress snapshot at a point in time
class ProgressSnapshot {
  final String jobId;
  final DateTime timestamp;
  final int totalRecords;
  final int processedRecords;
  final Map<String, int> providerProgress; // Progress per provider
  final Map<String, dynamic> metadata;
  final String? currentPhase;
  final String? currentProvider;
  final int? currentBatch;

  const ProgressSnapshot({
    required this.jobId,
    required this.timestamp,
    required this.totalRecords,
    required this.processedRecords,
    this.providerProgress = const {},
    this.metadata = const {},
    this.currentPhase,
    this.currentProvider,
    this.currentBatch,
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

  /// Create a snapshot from JSON
  factory ProgressSnapshot.fromJson(Map<String, dynamic> json) {
    return ProgressSnapshot(
      jobId: json['jobId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      totalRecords: json['totalRecords'] as int,
      processedRecords: json['processedRecords'] as int,
      providerProgress: Map<String, int>.from(
        json['providerProgress'] as Map? ?? {},
      ),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      currentPhase: json['currentPhase'] as String?,
      currentProvider: json['currentProvider'] as String?,
      currentBatch: json['currentBatch'] as int?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'timestamp': timestamp.toIso8601String(),
      'totalRecords': totalRecords,
      'processedRecords': processedRecords,
      'providerProgress': providerProgress,
      'metadata': metadata,
      'currentPhase': currentPhase,
      'currentProvider': currentProvider,
      'currentBatch': currentBatch,
    };
  }

  /// Create from database row
  factory ProgressSnapshot.fromDatabase(Map<String, Object?> row) {
    final metadataJson = row['metadata'] as String?;
    final providerProgressJson = row['provider_progress'] as String?;

    return ProgressSnapshot(
      jobId: row['job_id'] as String,
      timestamp: DateTime.parse(row['timestamp'] as String),
      totalRecords: row['total_records'] as int,
      processedRecords: row['processed_records'] as int,
      providerProgress: providerProgressJson != null
          ? Map<String, int>.from(jsonDecode(providerProgressJson) as Map)
          : {},
      metadata: metadataJson != null
          ? jsonDecode(metadataJson) as Map<String, dynamic>
          : {},
      currentPhase: row['current_phase'] as String?,
      currentProvider: row['current_provider'] as String?,
      currentBatch: row['current_batch'] as int?,
    );
  }
}

/// Detailed progress information with historical data
class DetailedProgress {
  final ProgressSnapshot current;
  final List<ProgressSnapshot> history;
  final DateTime startedAt;
  final Duration elapsed;
  final double averageRate; // Records per second
  final Duration? estimatedTimeRemaining;

  const DetailedProgress({
    required this.current,
    required this.history,
    required this.startedAt,
    required this.elapsed,
    required this.averageRate,
    this.estimatedTimeRemaining,
  });
}

/// Events emitted by the progress tracker
sealed class ProgressEvent {
  const ProgressEvent();

  const factory ProgressEvent.updated(String jobId, ProgressSnapshot snapshot) =
      ProgressUpdatedEvent;
  const factory ProgressEvent.phaseChanged(String jobId, String phase) =
      PhaseChangedEvent;
  const factory ProgressEvent.providerStarted(String jobId, String providerId) =
      ProviderStartedEvent;
  const factory ProgressEvent.providerCompleted(
    String jobId,
    String providerId,
  ) = ProviderCompletedEvent;
  const factory ProgressEvent.batchCompleted(String jobId, int batchNumber) =
      BatchCompletedEvent;
}

final class ProgressUpdatedEvent extends ProgressEvent {
  final String jobId;
  final ProgressSnapshot snapshot;
  const ProgressUpdatedEvent(this.jobId, this.snapshot);
}

final class PhaseChangedEvent extends ProgressEvent {
  final String jobId;
  final String phase;
  const PhaseChangedEvent(this.jobId, this.phase);
}

final class ProviderStartedEvent extends ProgressEvent {
  final String jobId;
  final String providerId;
  const ProviderStartedEvent(this.jobId, this.providerId);
}

final class ProviderCompletedEvent extends ProgressEvent {
  final String jobId;
  final String providerId;
  const ProviderCompletedEvent(this.jobId, this.providerId);
}

final class BatchCompletedEvent extends ProgressEvent {
  final String jobId;
  final int batchNumber;
  const BatchCompletedEvent(this.jobId, this.batchNumber);
}

/// Service for tracking and persisting job progress with real-time updates
class JobProgressTracker {
  static final Logger _logger = Logger('ProgressTracker');

  final DatabaseHandle _database;
  final Map<String, ProgressSnapshot> _currentProgress = {};
  final Map<String, DateTime> _jobStartTimes = {};
  final Map<String, Timer> _persistenceTimers = {};

  final StreamController<ProgressEvent> _eventController =
      StreamController<ProgressEvent>.broadcast();

  final Duration _persistenceInterval;
  final int _maxHistoryEntries;

  JobProgressTracker({
    required DatabaseHandle database,
    Duration? persistenceInterval,
    int maxHistoryEntries = 100,
  }) : _database = database,
       _persistenceInterval = persistenceInterval ?? const Duration(seconds: 5),
       _maxHistoryEntries = maxHistoryEntries;

  /// Stream of progress events
  Stream<ProgressEvent> get events => _eventController.stream;

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

    // Persist initial snapshot
    await _persistSnapshot(initialSnapshot);

    // Start periodic persistence
    _startPeriodicPersistence(jobId);

    _eventController.add(ProgressEvent.updated(jobId, initialSnapshot));
  }

  /// Update progress for a job
  Future<void> updateProgress({
    required String jobId,
    int? processedRecords,
    String? currentPhase,
    String? currentProvider,
    int? currentBatch,
    Map<String, int>? providerProgress,
    Map<String, dynamic>? metadata,
  }) async {
    final currentSnapshot = _currentProgress[jobId];
    if (currentSnapshot == null) {
      _logger.warning('No progress tracking initialized for job: $jobId');
      return;
    }

    final updatedSnapshot = ProgressSnapshot(
      jobId: jobId,
      timestamp: clock.now(),
      totalRecords: currentSnapshot.totalRecords,
      processedRecords: processedRecords ?? currentSnapshot.processedRecords,
      providerProgress: providerProgress ?? currentSnapshot.providerProgress,
      metadata: metadata ?? currentSnapshot.metadata,
      currentPhase: currentPhase ?? currentSnapshot.currentPhase,
      currentProvider: currentProvider == ''
          ? null
          : (currentProvider ?? currentSnapshot.currentProvider),
      currentBatch: currentBatch ?? currentSnapshot.currentBatch,
    );

    _currentProgress[jobId] = updatedSnapshot;

    // Emit phase change event if phase changed
    if (currentPhase != null && currentPhase != currentSnapshot.currentPhase) {
      _eventController.add(ProgressEvent.phaseChanged(jobId, currentPhase));
    }

    // Emit provider events
    if (currentProvider != null &&
        currentProvider != currentSnapshot.currentProvider) {
      _eventController.add(
        ProgressEvent.providerStarted(jobId, currentProvider),
      );
    }

    // Emit batch completion event
    if (currentBatch != null && currentBatch != currentSnapshot.currentBatch) {
      _eventController.add(ProgressEvent.batchCompleted(jobId, currentBatch));
    }

    _eventController.add(ProgressEvent.updated(jobId, updatedSnapshot));
  }

  /// Mark a provider as completed
  Future<void> completeProvider(String jobId, String providerId) async {
    await updateProgress(
      jobId: jobId,
      currentProvider: '', // Clear current provider
    );

    _eventController.add(ProgressEvent.providerCompleted(jobId, providerId));
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
        processedRecords:
            currentSnapshot.totalRecords, // Mark as fully processed
        providerProgress: currentSnapshot.providerProgress,
        metadata: currentSnapshot.metadata,
        currentPhase: 'completed',
      );

      _currentProgress[jobId] = completedSnapshot;
      await _persistSnapshot(completedSnapshot);
      _eventController.add(ProgressEvent.updated(jobId, completedSnapshot));
    }

    // Stop periodic persistence
    _stopPeriodicPersistence(jobId);

    // Clean up
    _currentProgress.remove(jobId);
    _jobStartTimes.remove(jobId);
  }

  /// Get current progress for a job
  ProgressSnapshot? getCurrentProgress(String jobId) {
    return _currentProgress[jobId];
  }

  /// Get detailed progress with history
  Future<DetailedProgress?> getDetailedProgress(String jobId) async {
    final current = _currentProgress[jobId];
    if (current == null) return null;

    final startTime = _jobStartTimes[jobId];
    if (startTime == null) return null;

    final elapsed = clock.now().difference(startTime);
    final history = await _getProgressHistory(jobId);

    // Calculate average rate
    double averageRate = 0.0;
    if (elapsed.inSeconds > 0 && current.processedRecords > 0) {
      averageRate = current.processedRecords / elapsed.inSeconds;
    }

    final estimatedTimeRemaining = current.estimateTimeRemaining(elapsed);

    return DetailedProgress(
      current: current,
      history: history,
      startedAt: startTime,
      elapsed: elapsed,
      averageRate: averageRate,
      estimatedTimeRemaining: estimatedTimeRemaining,
    );
  }

  /// Get progress history for a job
  Future<List<ProgressSnapshot>> _getProgressHistory(String jobId) async {
    try {
      final result = await _database.select(
        '''
        SELECT * FROM job_progress_snapshots 
        WHERE job_id = ? 
        ORDER BY timestamp ASC
        ''',
        [jobId],
      );

      return result.map((row) => ProgressSnapshot.fromDatabase(row)).toList();
    } catch (e) {
      _logger.severe('Failed to get progress history for job: $jobId', e);
      return [];
    }
  }

  /// Start periodic persistence for a job
  void _startPeriodicPersistence(String jobId) {
    _persistenceTimers[jobId]?.cancel();

    _persistenceTimers[jobId] = Timer.periodic(_persistenceInterval, (
      timer,
    ) async {
      _logger.finest('Persisting progress snapshot for job: $jobId');
      final snapshot = _currentProgress[jobId];
      if (snapshot != null) {
        try {
          await _persistSnapshot(snapshot);
        } catch (e) {
          _logger.severe(
            'Failed to persist progress snapshot for job: $jobId',
            e,
          );
        }
      } else {
        timer.cancel();
        _persistenceTimers.remove(jobId);
      }
    });
  }

  /// Stop periodic persistence for a job
  void _stopPeriodicPersistence(String jobId) {
    _persistenceTimers[jobId]?.cancel();
    _persistenceTimers.remove(jobId);
  }

  /// Persist a progress snapshot to database
  Future<void> _persistSnapshot(ProgressSnapshot snapshot) async {
    try {
      await _database.execute(
        '''
        INSERT OR REPLACE INTO job_progress_snapshots (
          job_id, timestamp, total_records, processed_records,
          provider_progress, metadata, current_phase, current_provider, current_batch
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          snapshot.jobId,
          snapshot.timestamp.toIso8601String(),
          snapshot.totalRecords,
          snapshot.processedRecords,
          jsonEncode(snapshot.providerProgress),
          jsonEncode(snapshot.metadata),
          snapshot.currentPhase,
          snapshot.currentProvider,
          snapshot.currentBatch,
        ],
      );

      // Clean up old snapshots to maintain history limit
      await _cleanupOldSnapshots(snapshot.jobId);
    } catch (e) {
      _logger.severe('Failed to persist progress snapshot', e);
      rethrow;
    }
  }

  /// Clean up old progress snapshots to maintain history limit
  Future<void> _cleanupOldSnapshots(String jobId) async {
    try {
      await _database.execute(
        '''
        DELETE FROM job_progress_snapshots 
        WHERE job_id = ? AND timestamp NOT IN (
          SELECT timestamp FROM job_progress_snapshots 
          WHERE job_id = ? 
          ORDER BY timestamp DESC 
          LIMIT ?
        )
        ''',
        [jobId, jobId, _maxHistoryEntries],
      );
    } catch (e) {
      _logger.warning('Failed to cleanup old snapshots for job: $jobId', e);
    }
  }

  /// Get progress statistics for all active jobs
  Map<String, Map<String, dynamic>> getActiveJobsStats() {
    final stats = <String, Map<String, dynamic>>{};

    for (final entry in _currentProgress.entries) {
      final jobId = entry.key;
      final snapshot = entry.value;
      final startTime = _jobStartTimes[jobId];

      if (startTime != null) {
        final elapsed = clock.now().difference(startTime);
        final rate = elapsed.inSeconds > 0
            ? snapshot.processedRecords / elapsed.inSeconds
            : 0.0;

        stats[jobId] = {
          'progress': snapshot.progress,
          'processedRecords': snapshot.processedRecords,
          'totalRecords': snapshot.totalRecords,
          'currentPhase': snapshot.currentPhase,
          'elapsed': elapsed.inSeconds,
          'rate': rate,
          'estimatedTimeRemaining': snapshot
              .estimateTimeRemaining(elapsed)
              ?.inSeconds,
        };
      }
    }

    return stats;
  }

  /// Clean up completed jobs older than specified duration
  Future<int> cleanupCompletedJobs({Duration? olderThan}) async {
    final cutoffTime = olderThan != null
        ? clock.now().subtract(olderThan)
        : clock.now().subtract(const Duration(days: 7)); // Default 7 days

    _logger.info('Cleaning up progress snapshots older than: $cutoffTime');

    try {
      final result = await _database.select(
        '''
        SELECT COUNT(*) as count FROM job_progress_snapshots 
        WHERE timestamp < ?
        ''',
        [cutoffTime.toIso8601String()],
      );

      final deleteCount = result.first['count'] as int;

      await _database.execute(
        '''
        DELETE FROM job_progress_snapshots 
        WHERE timestamp < ?
        ''',
        [cutoffTime.toIso8601String()],
      );

      _logger.info('Cleaned up $deleteCount progress snapshots');
      return deleteCount;
    } catch (e) {
      _logger.severe('Failed to cleanup progress snapshots', e);
      return 0;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    _logger.info('Disposing ProgressTracker');

    // Stop all periodic timers
    for (final timer in _persistenceTimers.values) {
      timer.cancel();
    }
    _persistenceTimers.clear();

    // Persist final snapshots
    for (final snapshot in _currentProgress.values) {
      try {
        await _persistSnapshot(snapshot);
      } catch (e) {
        _logger.severe(
          'Failed to persist final snapshot for job: ${snapshot.jobId}',
          e,
        );
      }
    }

    await _eventController.close();

    _currentProgress.clear();
    _jobStartTimes.clear();

    _logger.info('ProgressTracker disposed');
  }
}

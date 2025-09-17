import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';

import '../../database/database.dart';
import '../model/embedding_job.dart';

/// Types of checkpoints that can be saved during job execution
enum CheckpointType {
  jobStart, // Job initialization completed
  batchCompleted, // Processing batch completed
  providerCompleted, // Provider processing completed
  jobCompleted, // Job fully completed
}

/// A checkpoint represents a recoverable state during job execution
class JobCheckpoint {
  final String id;
  final String jobId;
  final CheckpointType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final int sequenceNumber;
  final String? providerId;
  final String? modelId;
  final int? batchNumber;

  const JobCheckpoint({
    required this.id,
    required this.jobId,
    required this.type,
    required this.timestamp,
    required this.data,
    required this.sequenceNumber,
    this.providerId,
    this.modelId,
    this.batchNumber,
  });

  factory JobCheckpoint.fromMap(Map<String, dynamic> map) {
    return JobCheckpoint(
      id: map['id'] as String,
      jobId: map['job_id'] as String,
      type: CheckpointType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CheckpointType.jobStart,
      ),
      timestamp: DateTime.parse(map['timestamp'] as String),
      data: jsonDecode(map['data'] as String) as Map<String, dynamic>,
      sequenceNumber: map['sequence_number'] as int,
      providerId: map['provider_id'] as String?,
      modelId: map['model_id'] as String?,
      batchNumber: map['batch_number'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'job_id': jobId,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'data': jsonEncode(data),
      'sequence_number': sequenceNumber,
      'provider_id': providerId,
      'model_id': modelId,
      'batch_number': batchNumber,
    };
  }

  /// Create a checkpoint for job start
  factory JobCheckpoint.jobStart({
    required String jobId,
    required int sequenceNumber,
    required Map<String, dynamic> jobData,
  }) {
    return JobCheckpoint(
      id: '${jobId}_start_${DateTime.now().millisecondsSinceEpoch}',
      jobId: jobId,
      type: CheckpointType.jobStart,
      timestamp: DateTime.now(),
      data: jobData,
      sequenceNumber: sequenceNumber,
    );
  }

  /// Create a checkpoint for batch completed
  factory JobCheckpoint.batchCompleted({
    required String jobId,
    required int sequenceNumber,
    required String providerId,
    required String modelId,
    required int batchNumber,
    required int processedCount,
  }) {
    return JobCheckpoint(
      id: '${jobId}_batch_complete_${batchNumber}_${DateTime.now().millisecondsSinceEpoch}',
      jobId: jobId,
      type: CheckpointType.batchCompleted,
      timestamp: DateTime.now(),
      data: {'processedCount': processedCount},
      sequenceNumber: sequenceNumber,
      providerId: providerId,
      modelId: modelId,
      batchNumber: batchNumber,
    );
  }

  /// Create a checkpoint for provider completed
  factory JobCheckpoint.providerCompleted({
    required String jobId,
    required int sequenceNumber,
    required String providerId,
    required int totalProcessed,
  }) {
    return JobCheckpoint(
      id: '${jobId}_provider_${providerId}_${DateTime.now().millisecondsSinceEpoch}',
      jobId: jobId,
      type: CheckpointType.providerCompleted,
      timestamp: DateTime.now(),
      data: {'providerId': providerId, 'totalProcessed': totalProcessed},
      sequenceNumber: sequenceNumber,
      providerId: providerId,
    );
  }
}

/// Resume strategy determines how to handle interrupted jobs
enum ResumeStrategy {
  fromLastCheckpoint, // Resume from the most recent checkpoint
  fromLastProvider, // Resume from the last incomplete provider
  fromLastBatch, // Resume from the last incomplete batch
  restart, // Restart the entire job
}

/// Information about a job that can be resumed
class ResumableJob {
  final EmbeddingJob job;
  final List<JobCheckpoint> checkpoints;
  final ResumeStrategy recommendedStrategy;
  final List<String> completedProviders;
  final Map<(String, String), int> lastCompletedBatchByProvider;
  final int processedRecords;
  final double progressAtInterruption;

  ResumableJob({
    required this.job,
    required this.checkpoints,
    required this.recommendedStrategy,
    required this.completedProviders,
    required this.lastCompletedBatchByProvider,
    required this.processedRecords,
    required this.progressAtInterruption,
  });

  late final List<String> remainingProviders = job.providerIds
      .where((id) => !completedProviders.contains(id))
      .toList(growable: false);

  /// Whether this job can be safely resumed
  bool get canResume => checkpoints.isNotEmpty && remainingProviders.isNotEmpty;
}

/// Service for managing job checkpoints and resume functionality
class JobResumeService {
  static final Logger _logger = Logger('JobResumeService');

  final DatabaseHandle _database;
  final Map<String, int> _jobSequenceNumbers = {};

  JobResumeService({required DatabaseHandle database}) : _database = database;

  /// Initialize the service by loading existing sequence numbers from checkpoints
  Future<void> initialize() async {
    _logger.info('Initializing JobResumeService');

    try {
      const sql = '''
        SELECT job_id, MAX(sequence_number) as max_sequence
        FROM job_checkpoints
        GROUP BY job_id
      ''';

      final rows = await _database.select(sql);

      for (final row in rows) {
        final jobId = row['job_id'] as String;
        final maxSequence = row['max_sequence'] as int;
        _jobSequenceNumbers[jobId] = maxSequence;
      }

      _logger.info(
        'Initialized sequence numbers for ${_jobSequenceNumbers.length} jobs',
      );
    } catch (e) {
      _logger.severe('Failed to initialize JobResumeService', e);
      rethrow;
    }
  }

  /// Save a checkpoint for a job
  Future<void> saveCheckpoint(JobCheckpoint checkpoint) async {
    _logger.fine(
      'Saving checkpoint: ${checkpoint.type.name} for job ${checkpoint.jobId}',
    );

    try {
      const sql = '''
        INSERT OR REPLACE INTO job_checkpoints (
          id, job_id, type, timestamp, data, sequence_number, provider_id, model_id, batch_number
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''';

      await _database.execute(sql, [
        checkpoint.id,
        checkpoint.jobId,
        checkpoint.type.name,
        checkpoint.timestamp.toIso8601String(),
        jsonEncode(checkpoint.data),
        checkpoint.sequenceNumber,
        checkpoint.providerId,
        checkpoint.modelId,
        checkpoint.batchNumber,
      ]);

      _logger.fine('Checkpoint saved successfully: ${checkpoint.id}');
    } catch (e) {
      _logger.severe('Failed to save checkpoint: ${checkpoint.id}', e);
      rethrow;
    }
  }

  /// Get the next sequence number for a job
  int _getNextSequenceNumber(String jobId) {
    final current = _jobSequenceNumbers[jobId] ?? 0;
    _jobSequenceNumbers[jobId] = current + 1;
    return current + 1;
  }

  /// Convenience method to save a job start checkpoint
  Future<void> saveJobStartCheckpoint({
    required String jobId,
    required Map<String, dynamic> jobData,
  }) async {
    final checkpoint = JobCheckpoint.jobStart(
      jobId: jobId,
      sequenceNumber: _getNextSequenceNumber(jobId),
      jobData: jobData,
    );
    await saveCheckpoint(checkpoint);
  }

  /// Convenience method to save a batch completed checkpoint
  Future<void> saveBatchCompletedCheckpoint({
    required String jobId,
    required String providerId,
    required String modelId,
    required int batchNumber,
    required int processedCount,
  }) async {
    final checkpoint = JobCheckpoint.batchCompleted(
      jobId: jobId,
      sequenceNumber: _getNextSequenceNumber(jobId),
      providerId: providerId,
      modelId: modelId,
      batchNumber: batchNumber,
      processedCount: processedCount,
    );
    await saveCheckpoint(checkpoint);
  }

  /// Convenience method to save a provider completed checkpoint
  Future<void> saveProviderCompletedCheckpoint({
    required String jobId,
    required String providerId,
    required int totalProcessed,
  }) async {
    final checkpoint = JobCheckpoint.providerCompleted(
      jobId: jobId,
      sequenceNumber: _getNextSequenceNumber(jobId),
      providerId: providerId,
      totalProcessed: totalProcessed,
    );
    await saveCheckpoint(checkpoint);
  }

  /// Get all checkpoints for a job
  Future<List<JobCheckpoint>> getJobCheckpoints(String jobId) async {
    _logger.fine('Loading checkpoints for job: $jobId');

    try {
      const sql = '''
        SELECT * FROM job_checkpoints 
        WHERE job_id = ? 
        ORDER BY sequence_number ASC
      ''';

      final rows = await _database.select(sql, [jobId]);
      final checkpoints = rows.map(JobCheckpoint.fromMap).toList();

      _logger.fine('Loaded ${checkpoints.length} checkpoints for job: $jobId');
      return checkpoints;
    } catch (e) {
      _logger.severe('Failed to load checkpoints for job: $jobId', e);
      rethrow;
    }
  }

  /// Get the latest checkpoint for a job
  Future<JobCheckpoint?> getLatestCheckpoint(String jobId) async {
    try {
      const sql = '''
        SELECT * FROM job_checkpoints 
        WHERE job_id = ? 
        ORDER BY sequence_number DESC 
        LIMIT 1
      ''';

      final rows = await _database.select(sql, [jobId]);
      if (rows.isEmpty) return null;

      return JobCheckpoint.fromMap(rows.first.cast<String, dynamic>());
    } catch (e) {
      _logger.severe('Failed to get latest checkpoint for job: $jobId', e);
      rethrow;
    }
  }

  /// Check if a job can be resumed
  Future<ResumableJob?> analyzeResumableJob(EmbeddingJob job) async {
    _logger.info('Analyzing resume options for job: ${job.id}');

    try {
      final checkpoints = await getJobCheckpoints(job.id);
      if (checkpoints.isEmpty) {
        _logger.info('No checkpoints found for job: ${job.id}');
        return null;
      }

      final lastCheckpoint = checkpoints.last;

      // Analyze what providers have been completed
      final completedProviders = checkpoints
          .where((c) => c.type == CheckpointType.providerCompleted)
          .map((c) => c.providerId!)
          .toList();

      // Find the last completed batch
      final lastCompletedBatchByProvider = <(String, String), int>{};
      for (final checkpoint in checkpoints) {
        if (checkpoint case JobCheckpoint(
          type: CheckpointType.batchCompleted,
          providerId: final providerId!,
          modelId: final modelId!,
          batchNumber: final batchNumber!,
        )) {
          final currentMax =
              lastCompletedBatchByProvider[(providerId, modelId)] ?? 0;
          if (batchNumber > currentMax) {
            lastCompletedBatchByProvider[(providerId, modelId)] = batchNumber;
          }
        }
      }

      // Calculate progress at interruption
      final processedRecords = lastCompletedBatchByProvider.values.fold<int>(
        0,
        (sum, batch) => sum + batch * 50,
      );
      final totalRecords = job.totalRecords!;
      final progressAtInterruption = (processedRecords / totalRecords).clamp(
        0.0,
        1.0,
      );

      // Determine recommended resume strategy
      final strategy = _determineResumeStrategy(checkpoints, lastCheckpoint);

      final resumableJob = ResumableJob(
        job: job,
        checkpoints: checkpoints,
        recommendedStrategy: strategy,
        completedProviders: completedProviders,
        processedRecords: processedRecords,
        lastCompletedBatchByProvider: lastCompletedBatchByProvider,
        progressAtInterruption: progressAtInterruption,
      );

      _logger.info(
        'Job ${job.id} can be resumed: ${resumableJob.canResume}, '
        'progress saved: ${(resumableJob.progressAtInterruption * 100).toStringAsFixed(1)}%, '
        'strategy: ${resumableJob.recommendedStrategy.name}, '
        'completed providers: ${resumableJob.completedProviders.length}/${job.providerIds.length}, '
        'last completed batch: ${resumableJob.lastCompletedBatchByProvider}',
      );

      return resumableJob;
    } catch (e) {
      _logger.severe('Failed to analyze resumable job: ${job.id}', e);
      return null;
    }
  }

  /// Determine the best resume strategy based on checkpoints
  ResumeStrategy _determineResumeStrategy(
    List<JobCheckpoint> checkpoints,
    JobCheckpoint lastCheckpoint,
  ) {
    // If the last checkpoint is job completion, no need to resume
    if (lastCheckpoint.type == CheckpointType.jobCompleted) {
      return ResumeStrategy.restart;
    }

    // If we have provider completion checkpoints, resume from next provider
    if (checkpoints.any((c) => c.type == CheckpointType.providerCompleted)) {
      return ResumeStrategy.fromLastProvider;
    }

    // If we have batch completion checkpoints, resume from next batch
    if (checkpoints.any((c) => c.type == CheckpointType.batchCompleted)) {
      return ResumeStrategy.fromLastBatch;
    }

    // Otherwise, resume from the last checkpoint
    return ResumeStrategy.fromLastCheckpoint;
  }

  /// Find all jobs that can be resumed
  Future<List<ResumableJob>> findResumableJobs() async {
    _logger.info('Searching for resumable jobs');

    try {
      // Find jobs that are in failed or cancelled state and have checkpoints
      const sql = '''
        SELECT DISTINCT j.* FROM jobs j
        INNER JOIN job_checkpoints jc ON j.id = jc.job_id
        WHERE j.status != 'completed'
        ORDER BY j.created_at DESC
      ''';

      final rows = await _database.select(sql);
      _logger.finest('Found ${rows.length} jobs with checkpoints');

      final resumableJobs = <ResumableJob>[];

      for (final row in rows) {
        try {
          final job = EmbeddingJob.fromDatabase(row);
          final resumableJob = await analyzeResumableJob(job);
          if (resumableJob != null && resumableJob.canResume) {
            resumableJobs.add(resumableJob);
          }
        } catch (e) {
          _logger.warning('Failed to analyze job for resume: ${row['id']}', e);
        }
      }

      _logger.info('Found ${resumableJobs.length} resumable jobs');
      return resumableJobs;
    } catch (e) {
      _logger.severe('Failed to find resumable jobs', e);
      return [];
    }
  }

  /// Clean up checkpoints for completed jobs
  Future<void> cleanupCompletedJobCheckpoints({Duration? olderThan}) async {
    final cutoff = olderThan != null
        ? DateTime.now().subtract(olderThan)
        : DateTime.now().subtract(const Duration(days: 30));

    _logger.info(
      'Cleaning up checkpoints older than ${cutoff.toIso8601String()}',
    );

    try {
      const sql = '''
        DELETE FROM job_checkpoints 
        WHERE job_id IN (
          SELECT j.id FROM jobs j 
          WHERE j.status = 'completed' 
          AND j.completed_at < ?
        )
      ''';

      await _database.execute(sql, [cutoff.toIso8601String()]);
      _logger.info('Cleaned up old checkpoints');
    } catch (e) {
      _logger.severe('Failed to cleanup completed job checkpoints', e);
    }
  }

  /// Delete all checkpoints for a specific job
  Future<void> deleteJobCheckpoints(String jobId) async {
    _logger.info('Deleting all checkpoints for job: $jobId');

    try {
      const sql = 'DELETE FROM job_checkpoints WHERE job_id = ?';
      await _database.execute(sql, [jobId]);

      // Remove from sequence tracking
      _jobSequenceNumbers.remove(jobId);

      _logger.info('Deleted all checkpoints for job: $jobId');
    } catch (e) {
      _logger.severe('Failed to delete checkpoints for job: $jobId', e);
      rethrow;
    }
  }

  /// Get checkpoint statistics
  Map<String, dynamic> getCheckpointStatistics() {
    return {'activeJobsWithCheckpoints': _jobSequenceNumbers.length};
  }

  /// Dispose resources
  Future<void> dispose() async {
    _jobSequenceNumbers.clear();
    _logger.info('JobResumeService disposed');
  }
}

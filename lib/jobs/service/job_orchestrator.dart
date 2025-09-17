import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../../configurations/service/configuration_service.dart';
import '../../data_sources/service/data_source_repository.dart';
import '../../embeddings/service/embedding_processor.dart';
import '../../providers/service/embedding_provider_registry.dart';
import '../../templates/model/embedding_template.dart';
import '../../templates/service/template_renderer.dart';
import '../../util/cancellation_token.dart';
import '../model/embedding_job.dart';
import '../model/embedding_job_collection.dart';
import 'error_recovery_service.dart';
import 'job_progress_tracker.dart';
import 'job_resume_service.dart';

/// Main orchestrator for managing embedding job lifecycle
class JobOrchestrator {
  static final Logger _logger = Logger('JobOrchestrator');

  final ConfigurationService _configService;
  final EmbeddingJobCollection _jobRepository;
  final EmbeddingProviderRegistry _providerRegistry;
  final EmbeddingTemplateCollection _templateRegistry;
  final DataSourceRepository _dataSourceRegistry;
  final EmbeddingProcessor _embeddingProcessor;
  final JobProgressTracker _progressTracker;
  final ErrorRecoveryService _errorRecoveryService;
  final JobResumeService _jobResumeService;

  final StreamController<EmbeddingJob> _jobUpdateController =
      StreamController<EmbeddingJob>.broadcast();

  /// Map to track cancellation tokens for active jobs
  final Map<String, CancellationToken> _activeCancellationTokens = {};

  /// Subscription to progress tracker events
  StreamSubscription<ProgressSnapshot>? _progressSubscription;

  bool _isInitialized = false;

  JobOrchestrator({
    required ConfigurationService configService,
    required EmbeddingJobCollection jobRepository,
    required EmbeddingProviderRegistry providerRegistry,
    required DataSourceRepository dataSourceRegistry,
    required EmbeddingTemplateCollection templateRegistry,
    required EmbeddingProcessor embeddingProcessor,
    required JobProgressTracker progressTracker,
    required ErrorRecoveryService errorRecoveryService,
    required JobResumeService jobResumeService,
  }) : _configService = configService,
       _jobRepository = jobRepository,
       _providerRegistry = providerRegistry,
       _dataSourceRegistry = dataSourceRegistry,
       _templateRegistry = templateRegistry,
       _embeddingProcessor = embeddingProcessor,
       _progressTracker = progressTracker,
       _errorRecoveryService = errorRecoveryService,
       _jobResumeService = jobResumeService;

  /// Stream of job updates
  Stream<EmbeddingJob> get jobUpdates => _jobUpdateController.stream;

  /// Whether the orchestrator is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the orchestrator
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.warning('JobOrchestrator already initialized');
      return;
    }

    _logger.info('Initializing JobOrchestrator');

    // Initialize the job resume service
    await _jobResumeService.initialize();

    // Set up progress tracker event listeners
    _progressSubscription = _progressTracker.events.listen(
      _handleProgressEvent,
    );

    _isInitialized = true;
    _logger.info('JobOrchestrator initialized successfully');
  }

  /// Handle progress tracker events and update job progress accordingly
  Future<void> _handleProgressEvent(ProgressSnapshot snapshot) async {
    await _jobRepository.updateJobProgress(
      snapshot.jobId,
      processedRecords: snapshot.processedRecords,
    );

    // Get updated job and notify listeners
    final updatedJob = _jobRepository.getById(snapshot.jobId);
    if (updatedJob != null) {
      _jobUpdateController.add(updatedJob);
    }
  }

  /// Update job status in database and notify listeners
  Future<void> _updateJobStatus(
    String jobId,
    JobStatus status, {
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
  }) async {
    _logger.info('Updating job status: $jobId to $status');

    await _jobRepository.updateJobStatus(
      jobId,
      status,
      startedAt: startedAt,
      completedAt: completedAt,
      errorMessage: errorMessage,
    );

    // Get updated job and notify listeners
    final updatedJob = _jobRepository.getById(jobId);
    if (updatedJob != null) {
      _jobUpdateController.add(updatedJob);
    }
  }

  // =============================================================================
  // Job Management Methods
  // =============================================================================

  /// Create and queue a new job
  Future<String> createJob(EmbeddingJob job) async {
    _ensureInitialized();

    _logger.info('Creating job: ${job.name}');

    try {
      // Validate job configuration
      job = await _validateJobConfiguration(job);

      // Create job in database
      final jobId = await _jobRepository.upsert(job);

      // Queue job for execution
      unawaited(_executeJob(job));

      _logger.info('Successfully created and queued job: $jobId');
      return jobId;
    } catch (e) {
      _logger.severe('Failed to create job: ${job.name}', e);
      rethrow;
    }
  }

  /// Start processing a pending job
  Future<void> startJob(String jobId) async {
    _ensureInitialized();

    final job = _jobRepository.getById(jobId);
    if (job == null) {
      throw StateError('Job not found: $jobId');
    }

    if (job.status != JobStatus.running) {
      throw StateError('Job is not in pending status: $jobId');
    }

    _logger.info('Starting job: $jobId');

    // Enqueue the job for processing
    unawaited(_executeJob(job));
  }

  /// Cancel a running or pending job
  Future<void> cancelJob(String jobId) async {
    _ensureInitialized();

    _logger.info('Cancelling job: $jobId');

    try {
      // Remove from queue if not yet running
      final job = _jobRepository.getById(jobId);
      if (job == null) {
        throw StateError('Job not found: $jobId');
      }

      // Job is currently running - signal cancellation to the processor
      final cancellationToken = _activeCancellationTokens[jobId];
      if (cancellationToken != null) {
        cancellationToken.cancel();
        _logger.info('Signaled cancellation for running job: $jobId');
      } else {
        // Fallback for jobs without cancellation tokens
        await _updateJobStatus(
          jobId,
          JobStatus.cancelled,
          completedAt: DateTime.now(),
        );
        _logger.info('Cancelled running job (no token): $jobId');
      }
    } catch (e) {
      _logger.severe('Failed to cancel job: $jobId', e);
      rethrow;
    }
  }

  /// Retry a failed or canceled job.
  Future<void> retryJob(String jobId) async {
    _ensureInitialized();

    final job = _jobRepository.getById(jobId);
    if (job == null) {
      throw StateError('Job not found: $jobId');
    }

    _logger.info('Retrying job: $jobId');

    try {
      // Reset job status and clear error
      final retryJob = job.copyWith(
        status: JobStatus.running,
        startedAt: null,
        completedAt: null,
        errorMessage: null,
        processedRecords: 0,
      );

      await _jobRepository.upsert(retryJob);
      unawaited(_executeJob(retryJob));

      _logger.info('Successfully queued job for retry: $jobId');
    } catch (e) {
      _logger.severe('Failed to retry job: $jobId', e);
      rethrow;
    }
  }

  /// Delete a job and cleanup resources
  Future<void> deleteJob(String jobId) async {
    _ensureInitialized();

    _logger.info('Deleting job: $jobId');

    try {
      // Cancel job if it's running or queued
      if (_activeCancellationTokens.containsKey(jobId)) {
        await cancelJob(jobId);
      }

      // Delete from database
      await _jobResumeService.deleteJobCheckpoints(jobId);
      await _jobRepository.remove(jobId);

      _logger.info('Successfully deleted job: $jobId');
    } catch (e) {
      _logger.severe('Failed to delete job: $jobId', e);
      rethrow;
    }
  }

  // =============================================================================
  // Job Monitoring Methods
  // =============================================================================

  /// Get current job status
  Future<EmbeddingJob?> getJob(String jobId) async {
    _ensureInitialized();
    return _jobRepository.getById(jobId);
  }

  /// Watch job updates in real-time
  Stream<EmbeddingJob> watchJob(String jobId) {
    _ensureInitialized();
    return _jobUpdateController.stream.where((job) => job.id == jobId);
  }

  // =============================================================================
  // Batch Operations
  // =============================================================================

  /// Start processing all pending jobs
  Future<void> startAllPendingJobs() async {
    _ensureInitialized();

    _logger.info('Starting all pending jobs');

    final pendingJobs = _jobRepository.getByStatus(JobStatus.running);
    _logger.info('Found ${pendingJobs.length} pending jobs');

    for (final job in pendingJobs) {
      if (!_activeCancellationTokens.containsKey(job.id)) {
        unawaited(_executeJob(job));
      }
    }
  }

  // =============================================================================
  // Private Helper Methods
  // =============================================================================

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('JobOrchestrator not initialized');
    }
  }

  /// Validate job configuration before execution
  Future<EmbeddingJob> _validateJobConfiguration(EmbeddingJob job) async {
    // Validate data source exists and is accessible
    final dataSource = _dataSourceRegistry.get(job.dataSourceId);
    if (dataSource == null) {
      throw StateError('Data source not found: ${job.dataSourceId}');
    }
    final dataSourceRows = await dataSource.getRowCount();
    final totalRecords = dataSourceRows * job.modelIds.length;

    job = job.copyWith(totalRecords: totalRecords);

    // Validate embedding template exists
    if (_templateRegistry.getById(job.embeddingTemplateId) == null) {
      throw StateError(
        'Embedding template not found: ${job.embeddingTemplateId}',
      );
    }

    // Validate model providers exist and are configured
    final foundModels = <String>{};
    for (final providerId in job.providerIds) {
      final provider = _providerRegistry.get(providerId);
      if (provider == null) {
        throw StateError('Provider not found: $providerId');
      }
      final config = provider.config;
      if (config == null) {
        throw StateError('Provider not configured: $providerId');
      }
      foundModels.addAll(config.enabledModels);
    }
    final missingModels = job.modelIds.toSet().difference(foundModels);
    if (missingModels.isNotEmpty) {
      throw StateError(
        'Missing models for job: ${job.id}, models: $missingModels',
      );
    }

    _logger.info('Job configuration validation passed: ${job.id}');

    return job;
  }

  /// Execute a job by processing its embeddings
  Future<void> _executeJob(EmbeddingJob job) async {
    if (_activeCancellationTokens.containsKey(job.id)) {
      _logger.warning('Job is already running: ${job.id}');
      return;
    }

    _logger.info('Executing job: ${job.id}');

    // Create a cancellation token for this job
    final cancellationToken = CancellationToken(job.id);
    _activeCancellationTokens[job.id] = cancellationToken;

    try {
      // Check if this is a resume operation
      final resumableJob = await _jobResumeService.analyzeResumableJob(job);
      final canResume = resumableJob != null && resumableJob.canResume;

      if (canResume) {
        _logger.info(
          'Resuming job ${job.id} from ${resumableJob.recommendedStrategy.name}',
        );
        return await _resumeJobExecution(
          resumableJob: resumableJob,
          cancellationToken: cancellationToken,
        );
      }

      _logger.info('Starting fresh job execution: ${job.id}');
      return await _startFreshJobExecution(
        job: job,
        cancellationToken: cancellationToken,
      );
    } on Object catch (e, stackTrace) {
      if (!cancellationToken.isCancelled) {
        _logger.severe('Job execution failed: ${job.id}', e, stackTrace);

        // Update job status to failed
        return _jobRepository.updateJobStatus(
          job.id,
          JobStatus.failed,
          completedAt: DateTime.now(),
          errorMessage: e.toString(),
        );
      }

      final ex = switch (e) {
        CancellationException() => e,
        http.RequestAbortedException() => CancellationException(
          message: 'HTTP request aborted (job=${job.id})',
        ),
        _ => throw StateError('Unexpected exception type: ${e.runtimeType}'),
      };
      _logger.info('Job ${job.id} was cancelled: $ex');

      // Update job status to cancelled
      return _jobRepository.updateJobStatus(
        job.id,
        ex.reason == 'page_reload' ? JobStatus.paused : JobStatus.cancelled,
        completedAt: DateTime.now(),
        errorMessage: 'Job was cancelled',
      );
    } finally {
      // Clean up the cancellation token
      _activeCancellationTokens.remove(job.id);
    }
  }

  /// Start a fresh job execution from the beginning
  Future<void> _startFreshJobExecution({
    required EmbeddingJob job,
    required CancellationToken cancellationToken,
  }) async {
    await _progressTracker.deleteJobProgress(job.id);
    await _jobResumeService.deleteJobCheckpoints(job.id);

    // Save job start checkpoint
    await _jobResumeService.saveJobStartCheckpoint(
      jobId: job.id,
      jobData: {
        'jobName': job.name,
        'dataSourceId': job.dataSourceId,
        'templateId': job.embeddingTemplateId,
        'providerIds': job.providerIds,
      },
    );

    await _progressTracker.initializeJob(
      jobId: job.id,
      totalRecords: job.totalRecords!,
      metadata: {
        'job_name': job.name,
        'data_source': job.dataSourceId,
        'providers': job.providerIds,
      },
    );

    return _executeFromEmbeddingProcessing(
      job: job,
      cancellationToken: cancellationToken,
    );
  }

  /// Resume job execution from the appropriate checkpoint
  Future<void> _resumeJobExecution({
    required ResumableJob resumableJob,
    required CancellationToken cancellationToken,
  }) async {
    if (resumableJob.recommendedStrategy == ResumeStrategy.restart) {
      _logger.info('Resume strategy is restart - starting fresh execution');
      return _startFreshJobExecution(
        job: resumableJob.job,
        cancellationToken: cancellationToken,
      );
    }

    // Initialize progress tracker with existing progress
    await _progressTracker.restoreJobProgress(resumableJob);

    switch (resumableJob.recommendedStrategy) {
      case ResumeStrategy.fromLastCheckpoint:
        return _resumeFromLastCheckpoint(
          job: resumableJob.job,
          resumableJob: resumableJob,
          cancellationToken: cancellationToken,
        );
      case ResumeStrategy.fromLastProvider:
      case ResumeStrategy.fromLastBatch:
        _logger.info(
          'Resuming job ${resumableJob.job.id} from last incomplete batch. '
          'Last completed batches: ${resumableJob.lastCompletedBatchByProvider}',
        );
        return _executeFromEmbeddingProcessing(
          job: resumableJob.job,
          completedProviders: resumableJob.completedProviders,
          lastCompletedBatchByProvider:
              resumableJob.lastCompletedBatchByProvider,
          cancellationToken: cancellationToken,
        );
      case ResumeStrategy.restart:
        throw StateError('Unreachable');
    }
  }

  /// Resume from the last checkpoint (most conservative approach)
  Future<void> _resumeFromLastCheckpoint({
    required EmbeddingJob job,
    required ResumableJob resumableJob,
    required CancellationToken cancellationToken,
  }) async {
    final lastCheckpoint = resumableJob.checkpoints.last;

    _logger.info(
      'Resuming job ${job.id} from ${lastCheckpoint.type.name} checkpoint '
      '(sequence ${lastCheckpoint.sequenceNumber})',
    );

    switch (lastCheckpoint.type) {
      case CheckpointType.jobStart:
        return _startFreshJobExecution(
          job: job,
          cancellationToken: cancellationToken,
        );
      case CheckpointType.batchCompleted:
      case CheckpointType.providerCompleted:
        return _executeFromEmbeddingProcessing(
          job: job,
          lastCompletedBatchByProvider:
              resumableJob.lastCompletedBatchByProvider,
          completedProviders: resumableJob.completedProviders,
          cancellationToken: cancellationToken,
        );
      case CheckpointType.jobCompleted:
        return _finalizeJob(job: job, cancellationToken: cancellationToken);
    }
  }

  Future<void> _onBatchProgress(BatchProgress progress) {
    return Future.wait([
      // Update progress tracker
      _progressTracker.updateProgress(
        jobId: progress.jobId,
        providerProgress: {
          (progress.providerId, progress.modelId): progress.completedBatch,
        },
        processedRecords: progress.processedRecords,
      ),

      // Save batch completed checkpoint
      _jobResumeService.saveBatchCompletedCheckpoint(
        jobId: progress.jobId,
        providerId: progress.providerId,
        modelId: progress.modelId,
        batchNumber: progress.completedBatch,
        processedCount: progress.processedRecords,
      ),
    ]);
  }

  /// Execute job from embedding processing phase with batch filtering capability
  Future<void> _executeFromEmbeddingProcessing({
    required EmbeddingJob job,
    List<String> completedProviders = const [],
    Map<(String, String), int> lastCompletedBatchByProvider = const {},
    required CancellationToken cancellationToken,
  }) async {
    cancellationToken.throwIfCancelled();

    await _progressTracker.updateProgress(
      jobId: job.id,
      currentPhase: 'processing_embeddings',
    );

    final dataSource = _dataSourceRegistry.expect(job.dataSourceId);

    // Get template configuration and render if needed
    final templateConfig = await _configService.getEmbeddingTemplate(
      job.embeddingTemplateId,
    );
    if (templateConfig == null) {
      throw StateError(
        'Template configuration not found: ${job.embeddingTemplateId}',
      );
    }

    final templateRenderer = TemplateRenderer(
      dataSource: dataSource,
      template: templateConfig,
    );

    final templateRenderResult = await templateRenderer.renderTemplate();
    if (templateRenderResult.hasErrors) {
      throw StateError('Template rendering failed with errors');
    }

    final renderedTexts = templateRenderResult.renderedDocuments;

    // Process providers that need batch-level resume (from specific batch)

    job = job.copyWith(
      providerIds: [
        for (final id in job.providerIds)
          if (!completedProviders.contains(id)) id,
      ],
    );
    final result = await _errorRecoveryService
        .executeWithRetry<JobProcessingResult>(
          () => _embeddingProcessor.processJob(
            job: job,
            dataSource: dataSource,
            renderedTexts: renderedTexts,
            startFromBatch: lastCompletedBatchByProvider.map(
              (k, v) => MapEntry(k, v + 1),
            ),
            cancellationToken: cancellationToken,
            onProgress: _onBatchProgress,
          ),
          context:
              'embedding_processing for job ${job.id} '
              '(${renderedTexts.length} texts × ${job.providerIds.length} providers)',
        );
    final embedding = result.unwrap();

    // Mark providers as completed
    for (final providerId in job.providerIds) {
      await _jobResumeService.saveProviderCompletedCheckpoint(
        jobId: job.id,
        providerId: providerId,
        totalProcessed: embedding.processedRecords,
      );
    }

    _logger.info(
      'Completed embeddings processing: ${job.providerIds.length} providers processed',
    );

    // Continue to finalization
    await _finalizeJob(job: job, cancellationToken: cancellationToken);
  }

  /// Finalize job execution
  Future<void> _finalizeJob({
    required EmbeddingJob job,
    required CancellationToken cancellationToken,
  }) async {
    // Phase 3: Finalization
    await _progressTracker.updateProgress(
      jobId: job.id,
      currentPhase: 'finalizing',
      processedRecords: job.totalRecords!,
    );

    _logger.info('Finalizing job: ${job.id}');

    // Update job status to completed
    await _jobRepository.updateJobStatus(
      job.id,
      JobStatus.completed,
      completedAt: DateTime.now(),
    );

    // Complete progress tracking
    await _progressTracker.completeJob(job.id);

    _logger.info('Job execution completed successfully: ${job.id}');
  }

  /// Find all jobs that can be resumed
  Future<List<ResumableJob>> findResumableJobs() async {
    return _jobResumeService.findResumableJobs();
  }

  /// Analyze a specific job for resume capabilities
  Future<ResumableJob?> analyzeResumableJob(EmbeddingJob job) async {
    return _jobResumeService.analyzeResumableJob(job);
  }

  /// Get all checkpoints for a specific job
  Future<List<JobCheckpoint>> getJobCheckpoints(String jobId) async {
    return _jobResumeService.getJobCheckpoints(jobId);
  }

  /// Resume a job from its last checkpoint
  Future<void> resumeJob(String jobId) async {
    _ensureInitialized();

    final job = _jobRepository.getById(jobId);
    if (job == null) {
      throw StateError('Job not found: $jobId');
    }

    final resumableJob = await _jobResumeService.analyzeResumableJob(job);
    if (resumableJob == null || !resumableJob.canResume) {
      throw StateError('Job cannot be resumed: $jobId');
    }

    _logger.info(
      'Resuming job $jobId from ${resumableJob.recommendedStrategy.name} '
      '(${(resumableJob.progressAtInterruption * 100).toStringAsFixed(1)}% progress saved)',
    );

    // Update job status to running and re-queue for execution
    await _jobRepository.updateJobStatus(jobId, JobStatus.running);
    unawaited(_executeJob(job));

    _logger.info('Job $jobId queued for resume');
  }

  /// Clean up old checkpoints for completed jobs
  Future<void> cleanupCompletedJobCheckpoints({Duration? olderThan}) async {
    await _jobResumeService.cleanupCompletedJobCheckpoints(
      olderThan: olderThan,
    );
  }

  /// Mark all running jobs as paused (e.g. on app shutdown)
  Future<void> pauseAllRunningJobs() async {
    _ensureInitialized();

    final activeTokens = Map.of(_activeCancellationTokens);
    _activeCancellationTokens.clear();
    for (final token in activeTokens.values) {
      token.cancel('page_reload');
    }

    final runningJobIds = _jobRepository.all
        .where((job) => job.status == JobStatus.running)
        .map((job) => job.id)
        .toList();

    await Future.wait([
      for (final jobId in runningJobIds)
        _jobRepository.updateJobStatus(jobId, JobStatus.paused),
    ]);

    _logger.info('All running jobs marked as paused');
  }

  /// Check if a job is currently running and can be cancelled
  bool canCancelJob(String jobId) {
    final job = _jobRepository.getById(jobId);
    return switch (job?.status) {
      JobStatus.running || JobStatus.paused => true,
      _ => false,
    };
  }

  /// Get a list of currently active (running) job IDs
  List<String> getActiveJobIds() {
    return _activeCancellationTokens.keys.toList();
  }

  /// Dispose resources
  Future<void> dispose() async {
    _logger.info('Disposing JobOrchestrator');

    await _progressSubscription?.cancel();
    await _jobUpdateController.close();
    await _jobResumeService.dispose();

    _isInitialized = false;
    _logger.info('JobOrchestrator disposed');
  }
}

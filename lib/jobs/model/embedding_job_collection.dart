import '../../configurations/model/configuration_collection.dart';
import 'embedding_job.dart';

/// Collection for managing embedding jobs
class EmbeddingJobCollection extends ConfigurationCollection<EmbeddingJob> {
  EmbeddingJobCollection(super.configService);

  @override
  String get prefix => 'job';

  @override
  String get tableName => 'embedding_jobs';

  /// Get jobs by status
  List<EmbeddingJob> getByStatus(JobStatus status) {
    return all.where((job) => job.status == status).toList();
  }

  /// Get pending jobs
  List<EmbeddingJob> get pendingJobs => getByStatus(JobStatus.pending);

  /// Get running jobs
  List<EmbeddingJob> get runningJobs => getByStatus(JobStatus.running);

  /// Get completed jobs
  List<EmbeddingJob> get completedJobs => getByStatus(JobStatus.completed);

  /// Get failed jobs
  List<EmbeddingJob> get failedJobs => getByStatus(JobStatus.failed);

  /// Get jobs that are not completed
  List<EmbeddingJob> get activeJobs {
    return all.where((job) => !job.isCompleted).toList();
  }

  /// Get recent jobs (last 10)
  List<EmbeddingJob> get recentJobs {
    final sortedJobs = all.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedJobs.take(10).toList();
  }

  /// Update job status
  Future<void> updateJobStatus(
    String jobId,
    JobStatus status, {
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
  }) async {
    final job = getById(jobId);
    if (job != null) {
      final updatedJob = job.copyWith(
        status: status,
        startedAt: startedAt ?? job.startedAt,
        completedAt: completedAt ?? job.completedAt,
        errorMessage: errorMessage ?? job.errorMessage,
      );
      await set(jobId, updatedJob);
    }
  }

  /// Update job progress
  Future<void> updateJobProgress(
    String jobId, {
    int? totalRecords,
    int? processedRecords,
  }) async {
    final job = getById(jobId);
    if (job != null) {
      final updatedJob = job.copyWith(
        totalRecords: totalRecords ?? job.totalRecords,
        processedRecords: processedRecords ?? job.processedRecords,
      );
      await set(jobId, updatedJob);
    }
  }

  /// Complete a job with results
  Future<void> completeJob(String jobId, Map<String, dynamic> results) async {
    await updateJobStatus(
      jobId,
      JobStatus.completed,
      completedAt: DateTime.now(),
    );

    final job = getById(jobId);
    if (job != null) {
      final updatedJob = job.copyWith(results: results);
      await set(jobId, updatedJob);
    }
  }

  /// Fail a job with error message
  Future<void> failJob(String jobId, String errorMessage) async {
    await updateJobStatus(
      jobId,
      JobStatus.failed,
      completedAt: DateTime.now(),
      errorMessage: errorMessage,
    );
  }

  /// Cancel a job
  Future<void> cancelJob(String jobId) async {
    final job = getById(jobId);
    if (job != null && job.canCancel) {
      await updateJobStatus(
        jobId,
        JobStatus.cancelled,
        completedAt: DateTime.now(),
      );
    }
  }

  /// Start a job
  Future<void> startJob(String jobId) async {
    await updateJobStatus(jobId, JobStatus.running, startedAt: DateTime.now());
  }

  /// Get jobs using a specific data source
  List<EmbeddingJob> getJobsByDataSource(String dataSourceId) {
    return all.where((job) => job.dataSourceId == dataSourceId).toList();
  }

  /// Get jobs using a specific embedding template
  List<EmbeddingJob> getJobsByEmbeddingTemplate(String templateId) {
    return all.where((job) => job.embeddingTemplateId == templateId).toList();
  }

  /// Get jobs using a specific model provider
  List<EmbeddingJob> getJobsByModelProvider(String providerId) {
    return all
        .where((job) => job.modelProviderIds.contains(providerId))
        .toList();
  }

  @override
  Future<void> saveItem(String id, EmbeddingJob item) async {
    await configService.saveEmbeddingJob(item);
  }

  @override
  Future<EmbeddingJob?> loadItem(String id) async {
    return await configService.getEmbeddingJob(id);
  }

  @override
  Future<List<EmbeddingJob>> loadAllItems() async {
    return await configService.getAllEmbeddingJobs();
  }

  @override
  Future<void> removeItem(EmbeddingJob item) async {
    await configService.deleteEmbeddingJob(item.id);
  }
}

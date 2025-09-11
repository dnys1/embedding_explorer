import 'package:logging/logging.dart';

import '../../configurations/model/configuration_collection.dart';
import 'embedding_job.dart';

/// Collection for managing embedding jobs
class EmbeddingJobCollection extends ConfigurationCollection<EmbeddingJob> {
  static final Logger _logger = Logger('EmbeddingJobCollection');

  @override
  String get prefix => 'job';

  @override
  String get storageKey => 'embedding_jobs';

  @override
  Map<String, dynamic> toJson(EmbeddingJob item) => item.toJson();

  @override
  EmbeddingJob? fromJson(Map<String, dynamic> json) {
    try {
      return EmbeddingJob.fromJson(json);
    } catch (e) {
      _logger.severe('Error parsing embedding job from JSON: $e');
      return null;
    }
  }

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
  void updateJobStatus(
    String jobId,
    JobStatus status, {
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
  }) {
    final job = getById(jobId);
    if (job != null) {
      final updatedJob = job.copyWith(
        status: status,
        startedAt: startedAt ?? job.startedAt,
        completedAt: completedAt ?? job.completedAt,
        errorMessage: errorMessage ?? job.errorMessage,
      );
      set(jobId, updatedJob);
    }
  }

  /// Update job progress
  void updateJobProgress(
    String jobId, {
    int? totalRecords,
    int? processedRecords,
  }) {
    final job = getById(jobId);
    if (job != null) {
      final updatedJob = job.copyWith(
        totalRecords: totalRecords ?? job.totalRecords,
        processedRecords: processedRecords ?? job.processedRecords,
      );
      set(jobId, updatedJob);
    }
  }

  /// Complete a job with results
  void completeJob(String jobId, Map<String, dynamic> results) {
    updateJobStatus(jobId, JobStatus.completed, completedAt: DateTime.now());

    final job = getById(jobId);
    if (job != null) {
      final updatedJob = job.copyWith(results: results);
      set(jobId, updatedJob);
    }
  }

  /// Fail a job with error message
  void failJob(String jobId, String errorMessage) {
    updateJobStatus(
      jobId,
      JobStatus.failed,
      completedAt: DateTime.now(),
      errorMessage: errorMessage,
    );
  }

  /// Cancel a job
  void cancelJob(String jobId) {
    final job = getById(jobId);
    if (job != null && job.canCancel) {
      updateJobStatus(jobId, JobStatus.cancelled, completedAt: DateTime.now());
    }
  }

  /// Start a job
  void startJob(String jobId) {
    updateJobStatus(jobId, JobStatus.running, startedAt: DateTime.now());
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

  /// Create a sample job for testing
  EmbeddingJob createSampleJob() {
    final id = generateId();
    return EmbeddingJob(
      id: id,
      name: 'Sample Embedding Job',
      description: 'A sample job for testing the job management system',
      dataSourceId: 'sample_data_source',
      embeddingTemplateId: 'sample_template',
      modelProviderIds: ['openai_provider'],
      createdAt: DateTime.now(),
    );
  }

  /// Create multiple sample jobs
  void createSampleJobs() {
    if (length > 0) return; // Don't create samples if jobs already exist

    final jobs = [
      EmbeddingJob(
        id: generateId(),
        name: 'Customer Support Analysis',
        description:
            'Analyze customer support tickets for sentiment and categorization',
        dataSourceId: 'support_tickets_csv',
        embeddingTemplateId: 'text_analysis_template',
        modelProviderIds: ['openai_provider', 'gemini_provider'],
        status: JobStatus.completed,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        startedAt: DateTime.now().subtract(Duration(days: 2, hours: 1)),
        completedAt: DateTime.now().subtract(Duration(days: 2, hours: 2)),
        totalRecords: 1500,
        processedRecords: 1500,
      ),
      EmbeddingJob(
        id: generateId(),
        name: 'Product Review Embeddings',
        description:
            'Generate embeddings for product reviews to enable similarity search',
        dataSourceId: 'product_reviews_db',
        embeddingTemplateId: 'review_template',
        modelProviderIds: ['custom_provider'],
        status: JobStatus.running,
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
        startedAt: DateTime.now().subtract(Duration(hours: 2)),
        totalRecords: 5000,
        processedRecords: 3200,
      ),
      EmbeddingJob(
        id: generateId(),
        name: 'Document Classification',
        description:
            'Classify legal documents using embedding-based similarity',
        dataSourceId: 'legal_docs_db',
        embeddingTemplateId: 'document_template',
        modelProviderIds: ['openai_provider'],
        status: JobStatus.pending,
        createdAt: DateTime.now().subtract(Duration(minutes: 30)),
        totalRecords: 800,
        processedRecords: 0,
      ),
      EmbeddingJob(
        id: generateId(),
        name: 'FAQ Similarity Search',
        description: 'Build FAQ search system using semantic embeddings',
        dataSourceId: 'faq_csv',
        embeddingTemplateId: 'qa_template',
        modelProviderIds: ['gemini_provider'],
        status: JobStatus.failed,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        startedAt: DateTime.now().subtract(Duration(days: 1, hours: 1)),
        completedAt: DateTime.now().subtract(Duration(days: 1, hours: 2)),
        errorMessage: 'API rate limit exceeded',
        totalRecords: 200,
        processedRecords: 45,
      ),
    ];

    for (final job in jobs) {
      set(job.id, job);
    }
  }
}

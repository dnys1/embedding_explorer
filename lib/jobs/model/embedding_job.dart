import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../configurations/model/configuration_item.dart';

part 'embedding_job.freezed.dart';

/// Represents a job status
enum JobStatus {
  running,
  completed,
  paused,
  failed,
  cancelled;

  String get displayName {
    switch (this) {
      case JobStatus.running:
        return 'Running';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.paused:
        return 'Paused';
      case JobStatus.failed:
        return 'Failed';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get colorClass {
    switch (this) {
      case JobStatus.paused:
        return 'text-yellow-600 bg-yellow-50';
      case JobStatus.running:
        return 'text-primary-600 bg-primary-50';
      case JobStatus.completed:
        return 'text-green-600 bg-green-50';
      case JobStatus.failed:
        return 'text-red-600 bg-red-50';
      case JobStatus.cancelled:
        return 'text-neutral-600 bg-neutral-50';
    }
  }
}

/// Represents an embedding job configuration
@freezed
abstract class EmbeddingJob with _$EmbeddingJob implements ConfigurationItem {
  factory EmbeddingJob.create({
    required String id,
    required String name,
    String? description,
    required String dataSourceId,
    required String embeddingTemplateId,
    required List<String> providerIds,
    required List<String> modelIds,
    JobStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    Map<String, dynamic>? results,
    int? totalRecords,
    int? processedRecords,
  }) {
    return EmbeddingJob(
      id: id,
      name: name,
      description: description ?? '',
      dataSourceId: dataSourceId,
      embeddingTemplateId: embeddingTemplateId,
      providerIds: providerIds,
      modelIds: modelIds,
      status: status ?? JobStatus.running,
      createdAt: createdAt ?? DateTime.now(),
      startedAt: startedAt,
      completedAt: completedAt,
      errorMessage: errorMessage,
      results: results,
      totalRecords: totalRecords,
      processedRecords: processedRecords,
    );
  }

  const factory EmbeddingJob({
    required String id,
    required String name,
    required String description,
    required String dataSourceId,
    required String embeddingTemplateId,
    required List<String> providerIds,
    required List<String> modelIds,
    @Default(JobStatus.running) JobStatus status,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    Map<String, dynamic>? results,
    int? totalRecords,
    int? processedRecords,
  }) = _EmbeddingJob;

  const EmbeddingJob._();

  /// Create from database result
  factory EmbeddingJob.fromDatabase(Map<String, Object?> row) {
    return EmbeddingJob(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String,
      dataSourceId: row['data_source_id'] as String,
      embeddingTemplateId: row['template_id'] as String,
      providerIds: row['provider_ids'] != null
          ? (jsonDecode(row['provider_ids'] as String) as List).cast()
          : const [],
      modelIds: row['model_ids'] != null
          ? (jsonDecode(row['model_ids'] as String) as List).cast()
          : const [],
      status: JobStatus.values.byName(row['status'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
      startedAt: row['started_at'] != null
          ? DateTime.parse(row['started_at'] as String)
          : null,
      completedAt: row['completed_at'] != null
          ? DateTime.parse(row['completed_at'] as String)
          : null,
      errorMessage: row['error_message'] as String?,
      results: row['results'] != null
          ? jsonDecode(row['results'] as String) as Map<String, dynamic>
          : null,
      totalRecords: row['total_records'] as int?,
      processedRecords: row['processed_records'] as int?,
    );
  }

  /// Get progress percentage (0-100)
  double get progress {
    if (totalRecords == null || totalRecords == 0) return 0.0;
    if (processedRecords == null) return 0.0;
    return (processedRecords! / totalRecords!) * 100.0;
  }

  /// Get duration if job has started
  Duration? get duration {
    if (startedAt == null) return null;
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }

  /// Check if job is in a terminal state
  bool get isCompleted =>
      status == JobStatus.completed ||
      status == JobStatus.failed ||
      status == JobStatus.cancelled;

  /// Check if job can be cancelled
  bool get canCancel =>
      status == JobStatus.running || status == JobStatus.paused;
}

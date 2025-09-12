import 'dart:convert';

import '../../configurations/model/configuration_item.dart';

/// Represents a job status
enum JobStatus {
  pending,
  running,
  completed,
  failed,
  cancelled;

  String get displayName {
    switch (this) {
      case JobStatus.pending:
        return 'Pending';
      case JobStatus.running:
        return 'Running';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.failed:
        return 'Failed';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get colorClass {
    switch (this) {
      case JobStatus.pending:
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
class EmbeddingJob implements ConfigurationItem {
  @override
  final String id;
  final String name;
  final String description;
  final String dataSourceId;
  final String embeddingTemplateId;
  final List<String> modelProviderIds;
  final JobStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final Map<String, dynamic>? results;
  final int? totalRecords;
  final int? processedRecords;

  const EmbeddingJob({
    required this.id,
    required this.name,
    required this.description,
    required this.dataSourceId,
    required this.embeddingTemplateId,
    required this.modelProviderIds,
    this.status = JobStatus.pending,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.results,
    this.totalRecords,
    this.processedRecords,
  });

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
      status == JobStatus.pending || status == JobStatus.running;

  /// Create a copy with updated properties
  EmbeddingJob copyWith({
    String? id,
    String? name,
    String? description,
    String? dataSourceId,
    String? embeddingTemplateId,
    List<String>? modelProviderIds,
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
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dataSourceId: dataSourceId ?? this.dataSourceId,
      embeddingTemplateId: embeddingTemplateId ?? this.embeddingTemplateId,
      modelProviderIds: modelProviderIds ?? this.modelProviderIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      results: results ?? this.results,
      totalRecords: totalRecords ?? this.totalRecords,
      processedRecords: processedRecords ?? this.processedRecords,
    );
  }

  /// Create from database result
  static EmbeddingJob? fromDatabase(Map<String, Object?> row) {
    try {
      return EmbeddingJob(
        id: row['id'] as String,
        name: row['name'] as String,
        description: row['description'] as String,
        dataSourceId: row['data_source_id'] as String,
        embeddingTemplateId: row['embedding_template_id'] as String,
        modelProviderIds: row['model_provider_ids'] != null
            ? List<String>.from(
                jsonDecode(row['model_provider_ids'] as String) as List,
              )
            : <String>[],
        status: JobStatus.values.firstWhere(
          (e) => e.name == row['status'],
          orElse: () => JobStatus.pending,
        ),
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
    } catch (e) {
      print('Error parsing EmbeddingJob from database: $e');
      return null;
    }
  }

  @override
  String toString() {
    return 'EmbeddingJob(id: $id, name: $name, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmbeddingJob && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

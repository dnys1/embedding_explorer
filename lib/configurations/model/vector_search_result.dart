import 'dart:convert';

/// Represents a result from a vector similarity search
class VectorSearchResult {
  /// Unique identifier of the result record
  final String id;

  /// Original source data as a dynamic object
  final Map<String, dynamic> sourceData;

  /// Timestamp when the record was created
  final DateTime createdAt;

  /// Distance/similarity score (lower values indicate higher similarity for cosine distance)
  final double distance;

  const VectorSearchResult({
    required this.id,
    required this.sourceData,
    required this.createdAt,
    required this.distance,
  });

  /// Create from database row
  static VectorSearchResult? fromDatabase(Map<String, Object?> row) {
    try {
      return VectorSearchResult(
        id: row['id'] as String,
        sourceData:
            jsonDecode(row['source_data'] as String) as Map<String, dynamic>,
        createdAt: DateTime.parse(row['created_at'] as String),
        distance: row['distance'] as double,
      );
    } catch (e) {
      return null;
    }
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source_data': sourceData,
      'created_at': createdAt.toIso8601String(),
      'distance': distance,
    };
  }

  @override
  String toString() {
    return 'VectorSearchResult(id: $id, distance: $distance, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VectorSearchResult &&
        other.id == id &&
        other.distance == distance &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, distance, createdAt);
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'embedding_tables.freezed.dart';

/// Represents a registry entry for a dynamically created embedding table
@freezed
abstract class EmbeddingTable with _$EmbeddingTable {
  const factory EmbeddingTable({
    required String id,
    required String tableName,
    required String jobId,
    required String dataSourceId,
    required String embeddingTemplateId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _EmbeddingTable;

  /// Create from database row
  factory EmbeddingTable.fromDatabase(Map<String, Object?> row) {
    return EmbeddingTable(
      id: row['id'] as String,
      tableName: row['table_name'] as String,
      jobId: row['job_id'] as String,
      dataSourceId: row['data_source_id'] as String,
      embeddingTemplateId: row['template_id'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}

/// Represents a registry entry for a vector column in an embedding table
@freezed
abstract class EmbeddingColumn with _$EmbeddingColumn {
  const factory EmbeddingColumn({
    required String id,
    required String tableId,
    required String columnName,
    required String modelProviderId,
    required String modelName,
    required VectorType vectorType,
    required int dimensions,
    required DateTime createdAt,
  }) = _EmbeddingColumn;

  /// Create from database row
  factory EmbeddingColumn.fromDatabase(Map<String, Object?> row) {
    return EmbeddingColumn(
      id: row['id'] as String,
      tableId: row['table_id'] as String,
      columnName: row['column_name'] as String,
      modelProviderId: row['provider_id'] as String,
      modelName: row['model_name'] as String,
      vectorType: VectorType.values.byName(row['vector_type'] as String),
      dimensions: row['dimensions'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

/// Supported vector types for LibSQL vector columns
///
/// See: https://docs.turso.tech/features/ai-and-embeddings#types
enum VectorType {
  /// Implementation of IEEE 754 double precision format for 64-bit floating
  /// point numbers.
  float64('F64_BLOB'),

  /// Implementation of IEEE 754 single precision format for 32-bit floating
  /// point numbers.
  float32('F32_BLOB'),

  /// Implementation of IEEE 754-2008 half precision format for 16-bit floating
  /// point numbers.
  float16('F16_BLOB'),

  /// Implementation of bfloat16 format for 16-bit floating point numbers.
  bfloat16('FB16_BLOB'),

  /// LibSQL specific implementation which compresses each vector component to
  /// single u8 byte b and reconstruct value from it using simple transformation:
  ///
  ///   shift + alpha ⋅ b
  float8('F8_BLOB'),

  /// LibSQL-specific implementation which compresses each vector component
  /// down to 1-bit and packs multiple components into a single machine word,
  /// achieving a very compact representation.
  float1bit('F1BIT_BLOB');

  const VectorType(this.sqlType);

  final String sqlType;

  /// Get the appropriate vector conversion function name
  String get conversionFunction {
    return switch (this) {
      VectorType.float64 => 'vector64',
      VectorType.float32 => 'vector32',
      VectorType.float16 => 'vector16',
      VectorType.bfloat16 => 'vectorb16',
      VectorType.float8 => 'vector8',
      VectorType.float1bit => 'vector1bit',
    };
  }
}

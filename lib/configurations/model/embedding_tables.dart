/// Represents a registry entry for a dynamically created embedding table
class EmbeddingTable {
  final String id;
  final String tableName;
  final String jobId;
  final String dataSourceId;
  final String embeddingTemplateId;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmbeddingTable({
    required this.id,
    required this.tableName,
    required this.jobId,
    required this.dataSourceId,
    required this.embeddingTemplateId,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from database row
  static EmbeddingTable? fromDatabase(Map<String, Object?> row) {
    try {
      return EmbeddingTable(
        id: row['id'] as String,
        tableName: row['table_name'] as String,
        jobId: row['job_id'] as String,
        dataSourceId: row['data_source_id'] as String,
        embeddingTemplateId: row['embedding_template_id'] as String,
        description: row['description'] as String? ?? '',
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'EmbeddingTableRegistry('
        'id: $id, '
        'tableName: $tableName, '
        'jobId: $jobId, '
        'dataSourceId: $dataSourceId, '
        'embeddingTemplateId: $embeddingTemplateId, '
        'description: $description, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}

/// Represents a registry entry for a vector column in an embedding table
class EmbeddingColumn {
  final String id;
  final String tableId;
  final String columnName;
  final String modelProviderId;
  final String modelName;
  final VectorType vectorType;
  final int dimensions;
  final DateTime createdAt;

  const EmbeddingColumn({
    required this.id,
    required this.tableId,
    required this.columnName,
    required this.modelProviderId,
    required this.modelName,
    required this.vectorType,
    required this.dimensions,
    required this.createdAt,
  });

  /// Create from database row
  static EmbeddingColumn? fromDatabase(Map<String, Object?> row) {
    try {
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
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'EmbeddingColumnRegistry('
        'id: $id, '
        'tableId: $tableId, '
        'columnName: $columnName, '
        'modelProviderId: $modelProviderId, '
        'modelName: $modelName, '
        'vectorType: $vectorType, '
        'dimensions: $dimensions, '
        'createdAt: $createdAt'
        ')';
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

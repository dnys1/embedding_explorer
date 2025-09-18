import 'dart:convert';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:logging/logging.dart';

import '../../configurations/model/embedding_tables.dart';
import '../../configurations/service/configuration_service.dart';
import '../../database/database.dart';
import '../../database/database_pool.dart';
import '../../util/type_id.dart';
import '../model/embedding_job.dart';

/// Supported export formats for embedding data
enum ExportFormat {
  sqlite('SQLite Database', 'db'),
  // numpy('NumPy Archive', 'npz'),
  jsonl('JSON Lines', 'jsonl');

  const ExportFormat(this.displayName, this.fileExtension);

  final String displayName;
  final String fileExtension;
}

/// Result of an export operation
class ExportResult {
  const ExportResult({
    required this.data,
    required this.filename,
    required this.format,
    required this.recordCount,
    required this.columnCount,
  });

  final Uint8List data;
  final String filename;
  final ExportFormat format;
  final int recordCount;
  final int columnCount;
}

/// Service for exporting embedding data in various formats
class EmbeddingExportService {
  static final Logger _logger = Logger('EmbeddingExportService');

  final ConfigurationService _configService;
  final DatabasePool _databasePool;

  EmbeddingExportService({
    required ConfigurationService configService,
    required DatabasePool databasePool,
  }) : _configService = configService,
       _databasePool = databasePool;

  /// Export embeddings from a completed job in the specified format
  Future<ExportResult> exportJob({
    required EmbeddingJob job,
    required ExportFormat format,
  }) async {
    if (job.status != JobStatus.completed) {
      throw StateError('Cannot export incomplete job: ${job.status}');
    }

    _logger.info('Starting export of job ${job.id} in ${format.displayName}');

    // Get embedding table and columns
    final tables = await _configService.getEmbeddingTables(jobId: job.id);
    if (tables.isEmpty) {
      throw StateError('No embedding tables found for job ${job.id}');
    }

    final table = tables.first;
    final columns = await _configService.getEmbeddingColumns(table.id);

    final filename = _generateFilename(job, format);

    final result = switch (format) {
      ExportFormat.sqlite => await _exportSqlite(job, table, columns, filename),
      // ExportFormat.numpy => await _exportNumpy(job, table, columns, filename),
      ExportFormat.jsonl => await _exportJsonl(job, table, columns, filename),
    };

    _logger.info(
      'Export completed: ${result.recordCount} records, ${result.columnCount} columns',
    );

    return result;
  }

  /// Export as SQLite database
  Future<ExportResult> _exportSqlite(
    EmbeddingJob job,
    EmbeddingTable table,
    List<EmbeddingColumn> columns,
    String filename,
  ) async {
    final tempDbName = 'export_${typeId('tmp')}.db';

    try {
      // Create temporary database
      final tempDb = await _databasePool.open(tempDbName);

      // Create unified embeddings table
      final createSql = _buildCreateTableSql(columns);
      await tempDb.execute(createSql);

      // Copy data from original table
      final copyResult = await _copyEmbeddingData(tempDb, table, columns);
      await tempDb.close();

      // Export the database
      final data = await _databasePool.export(tempDbName);

      return ExportResult(
        data: data,
        filename: filename,
        format: ExportFormat.sqlite,
        recordCount: copyResult.recordCount,
        columnCount: copyResult.columnCount,
      );
    } finally {
      // Clean up temporary database
      await _databasePool.delete(tempDbName);
    }
  }

  /// Export as NumPy archive using streaming
  // TODO
  // ignore: unused_element
  // Future<ExportResult> _exportNumpy(
  //   EmbeddingJob job,
  //   EmbeddingTable table,
  //   List<EmbeddingColumn> columns,
  //   String filename,
  // ) async {
  //   final npzFile = NpzFile();

  //   // Collect data using streaming to avoid loading everything into memory at once
  //   final recordIds = <String>[];
  //   final sourceDataList = <String>[];
  //   final columnEmbeddings = <String, List<List<double>>>{};

  //   // Initialize embedding collections for each column
  //   for (final column in columns) {
  //     columnEmbeddings[column.columnName] = <List<double>>[];
  //   }

  //   int recordCount = 0;
  //   await for (final record in _getEmbeddingDataStream(table, columns)) {
  //     recordIds.add(record['id'] as String);
  //     sourceDataList.add(
  //       jsonEncode(record['source_data'] as Map<String, dynamic>),
  //     );

  //     // Process embeddings for each column
  //     for (final column in columns) {
  //       final embeddingBlob = record[column.columnName] as Uint8List?;
  //       if (embeddingBlob != null) {
  //         final embedding = _parseEmbeddingBlob(
  //           embeddingBlob,
  //           column.vectorType,
  //         );
  //         columnEmbeddings[column.columnName]!.add(embedding);
  //       } else {
  //         // Add zero vector for missing embeddings
  //         columnEmbeddings[column.columnName]!.add(
  //           List.filled(column.dimensions, 0.0),
  //         );
  //       }
  //     }

  //     recordCount++;
  //   }

  //   // Add metadata array
  //   final metadata = {
  //     'job_id': job.id,
  //     'job_name': job.name,
  //     'data_source_id': job.dataSourceId,
  //     'template_id': job.embeddingTemplateId,
  //     'created_at': job.createdAt.toIso8601String(),
  //     'record_count': recordCount,
  //     'model_count': columns.length,
  //     'models': columns
  //         .map(
  //           (c) => {
  //             'column_name': c.columnName,
  //             'provider_id': c.modelProviderId,
  //             'model_name': c.modelName,
  //             'dimensions': c.dimensions,
  //             'vector_type': c.vectorType.name,
  //           },
  //         )
  //         .toList(),
  //   };

  //   // Add metadata as UTF-8 encoded bytes (using uint8 for browser compatibility)
  //   final metadataJson = jsonEncode(metadata);
  //   final metadataBytes = Uint8List.fromList(utf8.encode(metadataJson));
  //   final metadataArray = NdArray<int>.fromList(
  //     metadataBytes,
  //     dtype: NpyDType.uint8(),
  //   );
  //   npzFile.add(metadataArray, name: 'metadata.npy');

  //   // Add record IDs as UTF-8 encoded bytes (chunked encoding)
  //   final idsJsonBytes = Uint8List.fromList(utf8.encode(jsonEncode(recordIds)));
  //   final idsArray = NdArray<int>.fromList(
  //     idsJsonBytes,
  //     dtype: NpyDType.uint8(),
  //   );
  //   npzFile.add(idsArray, name: 'record_ids.npy');

  //   // Add source data as UTF-8 encoded bytes (chunked encoding)
  //   final sourceDataJsonBytes = Uint8List.fromList(
  //     utf8.encode(jsonEncode(sourceDataList)),
  //   );
  //   final sourceDataArray = NdArray<int>.fromList(
  //     sourceDataJsonBytes,
  //     dtype: NpyDType.uint8(),
  //   );
  //   npzFile.add(sourceDataArray, name: 'source_data.npy');

  //   // Add embedding vectors for each model
  //   for (final column in columns) {
  //     final embeddings = columnEmbeddings[column.columnName]!;

  //     if (embeddings.isNotEmpty) {
  //       // Flatten 2D list to 1D for NumPy storage and track shape
  //       final flatEmbeddings = embeddings.expand((e) => e).toList();
  //       final embeddingArray = NdArray<double>.fromList(
  //         flatEmbeddings,
  //         dtype: NpyDType.float32(),
  //       );
  //       npzFile.add(embeddingArray, name: '${column.columnName}.npy');

  //       // Also save shape information (using int32 for browser compatibility)
  //       final shapeList = [embeddings.length, column.dimensions];
  //       final shapeArray = NdArray<int>.fromList(
  //         shapeList,
  //         dtype: NpyDType.int32(),
  //       );
  //       npzFile.add(shapeArray, name: '${column.columnName}_shape.npy');
  //     }
  //   }

  //   final data = await npzFile.save(isCompressed: true);

  //   return ExportResult(
  //     data: data,
  //     filename: filename,
  //     format: ExportFormat.numpy,
  //     recordCount: recordCount,
  //     columnCount: columns.length + 2, // +2 for id and source_data
  //   );
  // }

  /// Export as JSONL format using streaming and chunked JSON encoding
  Future<ExportResult> _exportJsonl(
    EmbeddingJob job,
    EmbeddingTable table,
    List<EmbeddingColumn> columns,
    String filename,
  ) async {
    // Use chunked encoding to handle large datasets efficiently
    final buffer = BytesBuilder(copy: false);
    final encoder = JsonUtf8Encoder();
    final newLine = '\n'.codeUnits.first;

    // First, count total records for metadata (streaming once to get count)
    final recordCount = await _getRecordCount(table);

    // Add header line with metadata
    final metadata = {
      'type': 'metadata',
      'job_id': job.id,
      'job_name': job.name,
      'data_source_id': job.dataSourceId,
      'template_id': job.embeddingTemplateId,
      'created_at': job.createdAt.toIso8601String(),
      'record_count': recordCount,
      'models': columns
          .map(
            (c) => {
              'column_name': c.columnName,
              'provider_id': c.modelProviderId,
              'model_name': c.modelName,
              'dimensions': c.dimensions,
              'vector_type': c.vectorType.name,
            },
          )
          .toList(),
    };

    // Add metadata line as first chunk
    buffer.add(encoder.convert(metadata));

    // Process data in chunks to avoid memory issues
    int processedCount = 0;

    await for (final record in _getEmbeddingDataStream(table, columns)) {
      final dataLine = <String, dynamic>{
        'type': 'record',
        'id': record['id'],
        'source_data': record['source_data'],
        'embeddings': <String, dynamic>{},
      };

      // Add embeddings for each model
      for (final column in columns) {
        final embeddingBlob = record[column.columnName] as Uint8List?;
        if (embeddingBlob != null) {
          final embedding = _parseEmbeddingBlob(
            embeddingBlob,
            column.vectorType,
          );
          dataLine['embeddings'][column.columnName] = embedding;
        }
      }

      buffer.addByte(newLine);
      buffer.add(encoder.convert(dataLine));
      processedCount++;
      if (processedCount % 100 == 0) {
        _logger.info('Processed $processedCount records');
      }
    }

    // Combine all chunks into final data
    final data = buffer.takeBytes();

    return ExportResult(
      data: data,
      filename: filename,
      format: ExportFormat.jsonl,
      recordCount: recordCount,
      columnCount: columns.length + 2, // +2 for id and source_data
    );
  }

  /// Build CREATE TABLE SQL for unified embeddings table
  String _buildCreateTableSql(List<EmbeddingColumn> columns) {
    final columnDefs = <String>[
      'id TEXT PRIMARY KEY',
      'source_data TEXT NOT NULL',
    ];

    for (final column in columns) {
      columnDefs.add('${column.columnName} BLOB');
    }

    return '''
      CREATE TABLE embeddings (
        ${columnDefs.join(',\n        ')}
      )
    ''';
  }

  /// Copy embedding data from original table to temporary database using streaming
  Future<({int recordCount, int columnCount})> _copyEmbeddingData(
    DatabaseHandle tempDb,
    EmbeddingTable table,
    List<EmbeddingColumn> columns,
  ) async {
    // Prepare INSERT statement
    final columnNames = [
      'id',
      'source_data',
      ...columns.map((c) => c.columnName),
    ];
    final placeholders = List.filled(columnNames.length, '?').join(', ');
    final insertSql =
        '''
      INSERT INTO embeddings (${columnNames.join(', ')})
      VALUES ($placeholders)
    ''';

    int recordCount = 0;
    const batchSize = 100;

    final batchStream = _getEmbeddingDataStream(
      table,
      columns,
    ).slices(batchSize);

    await for (final batch in batchStream) {
      final batchValues = [
        for (final record in batch)
          <Object?>[
            record['id'],
            jsonEncode(record['source_data']),
            ...columns.map((c) => record[c.columnName]),
          ],
      ];

      recordCount += batch.length;

      // Process batch when it reaches the batch size
      await tempDb.transaction((tx) {
        for (final batchValue in batchValues) {
          tx.execute(insertSql, batchValue);
        }
      });
    }

    return (recordCount: recordCount, columnCount: columnNames.length);
  }

  Future<int> _getRecordCount(EmbeddingTable table) async {
    final sql = 'SELECT COUNT(*) as count FROM ${table.tableName}';
    final result = await _configService.database.select(sql);
    return result.first['count'] as int;
  }

  /// Get all embedding data from the table as a stream
  Stream<Map<String, dynamic>> _getEmbeddingDataStream(
    EmbeddingTable table,
    List<EmbeddingColumn> columns, {
    int batchSize = 1000,
  }) async* {
    final columnNames = [
      'id',
      'source_data',
      ...columns.map((c) => c.columnName),
    ];

    int offset = 0;
    bool hasMore = true;

    while (hasMore) {
      final sql =
          '''
        SELECT ${columnNames.join(', ')}
        FROM ${table.tableName}
        ORDER BY id
        LIMIT $batchSize OFFSET $offset
      ''';

      final result = await _configService.database.select(sql);

      if (result.isEmpty) {
        hasMore = false;
        break;
      }

      for (final row in result) {
        final record = <String, dynamic>{};
        for (final entry in row.entries) {
          if (entry.key == 'source_data') {
            record[entry.key] = jsonDecode(entry.value as String);
          } else {
            record[entry.key] = entry.value;
          }
        }
        yield record;
      }

      offset += batchSize;
      if (result.length < batchSize) {
        hasMore = false;
      }
    }
  }

  /// Parse embedding blob based on vector type
  List<double> _parseEmbeddingBlob(Uint8List blob, VectorType vectorType) {
    switch (vectorType) {
      case VectorType.float64:
        final view = ByteData.sublistView(blob);
        final result = <double>[];
        for (var i = 0; i < blob.length; i += 8) {
          result.add(view.getFloat64(i, Endian.little));
        }
        return result;

      case VectorType.float32:
        final view = ByteData.sublistView(blob);
        final result = <double>[];
        for (var i = 0; i < blob.length; i += 4) {
          result.add(view.getFloat32(i, Endian.little));
        }
        return result;

      case VectorType.float16:
      case VectorType.bfloat16:
      case VectorType.float8:
      case VectorType.float1bit:
        // For compressed formats, we'll need to implement the specific
        // decompression logic. For now, return empty list.
        _logger.warning('Parsing of ${vectorType.name} not implemented');
        return [];
    }
  }

  /// Generate filename for export
  String _generateFilename(EmbeddingJob job, ExportFormat format) {
    final sanitizedName = job.name.replaceAll(RegExp(r'[^\w\-_.]'), '_');
    final timestamp = DateTime.now()
        .toIso8601String()
        .substring(0, 19)
        .replaceAll(':', '-');
    return '${sanitizedName}_$timestamp.${format.fileExtension}';
  }
}

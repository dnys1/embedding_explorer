import 'dart:async';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/common.dart' show ResultSet, SqliteException;
import 'package:worker_bee/worker_bee.dart';

import '../database/database.dart';
import '../database/transaction.dart';
import '../interop/libsql.dart' as libsql;
import 'database_worker.dart';

part 'database_pool_worker.g.dart';

class DatabasePoolRequestType extends EnumClass {
  static const DatabasePoolRequestType init = _$init;
  static const DatabasePoolRequestType exportDatabase = _$exportDatabase;
  static const DatabasePoolRequestType importDatabase = _$importDatabase;
  static const DatabasePoolRequestType deleteDatabase = _$deleteDatabase;
  static const DatabasePoolRequestType openDatabase = _$openDatabase;
  static const DatabasePoolRequestType closeDatabase = _$closeDatabase;
  static const DatabasePoolRequestType wipeAll = _$wipeAll;

  // Database-specific operations
  static const DatabasePoolRequestType execute = _$execute;
  static const DatabasePoolRequestType query = _$query;
  static const DatabasePoolRequestType transaction = _$transaction;

  const DatabasePoolRequestType._(super.name);

  static BuiltSet<DatabasePoolRequestType> get values => _$values;
  static DatabasePoolRequestType valueOf(String name) => _$valueOf(name);

  static Serializer<DatabasePoolRequestType> get serializer =>
      _$databasePoolRequestTypeSerializer;
}

abstract class DatabasePoolRequest
    implements Built<DatabasePoolRequest, DatabasePoolRequestBuilder> {
  int get requestId;
  DatabasePoolRequestType get type;

  // For init operations
  Uri? get libsqlUri;
  String? get name;
  bool? get clearOnInit;

  // For database-specific operations
  String? get databaseName;
  Transaction? get transaction;

  // For import operations
  Uint8List? get importData;

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DatabasePoolRequest')
          ..add('requestId', requestId)
          ..add('type', type)
          ..add('libsqlUri', libsqlUri)
          ..add('name', name)
          ..add('clearOnInit', clearOnInit)
          ..add('databaseName', databaseName)
          ..add('transaction', transaction)
          ..add(
            'importData',
            importData != null ? '[${importData!.length} bytes]' : null,
          ))
        .toString();
  }

  factory DatabasePoolRequest.init({
    required int requestId,
    Uri? libsqlUri,
    String? name,
    bool? clearOnInit,
  }) {
    return _$DatabasePoolRequest._(
      requestId: requestId,
      type: DatabasePoolRequestType.init,
      libsqlUri: libsqlUri,
      name: name,
      clearOnInit: clearOnInit,
    );
  }

  factory DatabasePoolRequest.exportDatabase({
    required int requestId,
    required String databaseName,
  }) {
    return _$DatabasePoolRequest._(
      requestId: requestId,
      type: DatabasePoolRequestType.exportDatabase,
      databaseName: databaseName,
    );
  }

  factory DatabasePoolRequest.importDatabase({
    required int requestId,
    required String databaseName,
    required Uint8List importData,
  }) {
    return _$DatabasePoolRequest._(
      requestId: requestId,
      type: DatabasePoolRequestType.importDatabase,
      databaseName: databaseName,
      importData: importData,
    );
  }

  factory DatabasePoolRequest.deleteDatabase({
    required int requestId,
    required String databaseName,
  }) {
    return _$DatabasePoolRequest._(
      requestId: requestId,
      type: DatabasePoolRequestType.deleteDatabase,
      databaseName: databaseName,
    );
  }

  factory DatabasePoolRequest.openDatabase({
    required int requestId,
    required String databaseName,
    bool verbose = false,
  }) {
    return _$DatabasePoolRequest._(
      requestId: requestId,
      type: DatabasePoolRequestType.openDatabase,
      databaseName: databaseName,
    );
  }

  factory DatabasePoolRequest.closeDatabase({
    required int requestId,
    required String databaseName,
  }) {
    return _$DatabasePoolRequest._(
      requestId: requestId,
      type: DatabasePoolRequestType.closeDatabase,
      databaseName: databaseName,
    );
  }

  factory DatabasePoolRequest.wipeAll({required int requestId}) {
    return _$DatabasePoolRequest._(
      requestId: requestId,
      type: DatabasePoolRequestType.wipeAll,
    );
  }

  factory DatabasePoolRequest.databaseOperation({
    required int requestId,
    required DatabasePoolRequestType type,
    required String databaseName,
    required Transaction transaction,
  }) {
    if (type != DatabasePoolRequestType.execute &&
        type != DatabasePoolRequestType.query &&
        type != DatabasePoolRequestType.transaction) {
      throw ArgumentError.value(
        type,
        'type',
        'Must be one of execute, query, or transaction',
      );
    }
    return _$DatabasePoolRequest._(
      requestId: requestId,
      type: type,
      databaseName: databaseName,
      transaction: transaction,
    );
  }

  DatabasePoolRequest._();

  factory DatabasePoolRequest.build([
    void Function(DatabasePoolRequestBuilder) updates,
  ]) = _$DatabasePoolRequest;

  static Serializer<DatabasePoolRequest> get serializer =>
      _$databasePoolRequestSerializer;
}

abstract class DatabasePoolResponse
    implements Built<DatabasePoolResponse, DatabasePoolResponseBuilder> {
  int get requestId;
  DatabasePoolStats get stats;
  DatabasePoolResultSet? get resultSet;
  DatabaseError? get error;

  factory DatabasePoolResponse.success({
    required int requestId,
    required DatabasePoolStats stats,
    required DatabasePoolResultSet resultSet,
  }) {
    return _$DatabasePoolResponse._(
      requestId: requestId,
      resultSet: resultSet,
      stats: stats,
    );
  }

  factory DatabasePoolResponse.failure({
    required int requestId,
    required Object error,
    int? errorCode,
    required StackTrace stackTrace,
    required DatabasePoolStats stats,
  }) {
    return _$DatabasePoolResponse._(
      requestId: requestId,
      error: DatabaseError(
        message: error.toString(),
        code: errorCode,
        stackTrace: stackTrace,
      ),
      stats: stats,
    );
  }

  DatabasePoolResultSet unwrap() {
    if (error case final error?) {
      Error.throwWithStackTrace(
        SqliteException(error.code ?? -1, error.error),
        error.stackTrace,
      );
    }
    return resultSet!;
  }

  DatabasePoolResponse._();

  factory DatabasePoolResponse.build([
    void Function(DatabasePoolResponseBuilder) updates,
  ]) = _$DatabasePoolResponse;

  static Serializer<DatabasePoolResponse> get serializer =>
      _$databasePoolResponseSerializer;
}

abstract class DatabasePoolStats
    implements Built<DatabasePoolStats, DatabasePoolStatsBuilder> {
  BuiltList<String> get databaseNames;
  int get reservedCapacity;
  int get fileCount;
  String get vfsName;

  factory DatabasePoolStats({
    required List<String> databaseNames,
    required int reservedCapacity,
    required int fileCount,
    required String vfsName,
  }) {
    return _$DatabasePoolStats._(
      databaseNames: databaseNames.build(),
      reservedCapacity: reservedCapacity,
      fileCount: fileCount,
      vfsName: vfsName,
    );
  }

  DatabasePoolStats._();

  factory DatabasePoolStats.build([
    void Function(DatabasePoolStatsBuilder) updates,
  ]) = _$DatabasePoolStats;

  static Serializer<DatabasePoolStats> get serializer =>
      _$databasePoolStatsSerializer;
}

abstract class DatabasePoolResultSet
    implements Built<DatabasePoolResultSet, DatabasePoolResultSetBuilder> {
  // For export operations
  Uint8List? get exportData;

  // For database operations
  DatabaseResultSet? get resultSet;

  // For import/delete operations (success indicator)
  bool? get success;

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DatabasePoolResultSet')
          ..add(
            'exportData',
            exportData != null ? '[${exportData!.length} bytes]' : null,
          )
          ..add('resultSet', resultSet)
          ..add('success', success))
        .toString();
  }

  factory DatabasePoolResultSet({
    Uint8List? exportData,
    DatabaseResultSet? resultSet,
    bool? success,
  }) {
    return _$DatabasePoolResultSet._(
      exportData: exportData,
      resultSet: resultSet,
      success: success,
    );
  }

  DatabasePoolResultSet._();

  factory DatabasePoolResultSet.build([
    void Function(DatabasePoolResultSetBuilder) updates,
  ]) = _$DatabasePoolResultSet;

  static Serializer<DatabasePoolResultSet> get serializer =>
      _$databasePoolResultSetSerializer;
}

@WorkerBee('lib/workers/workers.dart')
abstract class DatabasePoolWorker
    extends WorkerBeeBase<DatabasePoolRequest, DatabasePoolResponse> {
  DatabasePoolWorker() : super(serializers: _serializers);

  factory DatabasePoolWorker.create() = _$DatabasePoolWorker;

  @override
  Future<DatabasePoolResponse?> run(
    Stream<DatabasePoolRequest> listen,
    StreamSink<DatabasePoolResponse> respond,
  ) async {
    Logger.root.level = Level.ALL;
    final loggerSubscription = Logger.root.onRecord.listen(
      (r) => logSink.sink.add(WorkerLogRecord.from(r, local: false)),
    );

    late final libsql.SAHPoolUtil sahPool;
    final Map<String, Database> openDatabases = {};

    /// Ensures there's enough capacity in the pool for new files.
    /// Based on libsql implementation: each file needs exactly 1 SAH slot.
    /// Pool fails when fileCount >= capacity, so we ensure some buffer.
    Future<void> ensureCapacity({int requiredSlots = 1}) async {
      final availableSlots = sahPool.capacity - sahPool.fileCount;
      if (availableSlots < requiredSlots) {
        final additionalCapacity =
            requiredSlots - availableSlots + 2; // Add buffer
        await sahPool.addCapacity(additionalCapacity);
      }
    }

    Future<void> runWithErrorHandling(
      int requestId,
      Future<DatabasePoolResultSet> Function() action, {
      String? statement,
    }) async {
      try {
        final result = await action();
        respond.add(
          DatabasePoolResponse.success(
            requestId: requestId,
            resultSet: result,
            stats: sahPool.stats,
          ),
        );
      } catch (e, st) {
        respond.add(
          DatabasePoolResponse.failure(
            requestId: requestId,
            error:
                '${statement != null ? 'Error executing statement "$statement": ' : ''}$e',
            errorCode: e is SqliteException ? e.extendedResultCode : null,
            stackTrace: st,
            stats: sahPool.stats,
          ),
        );
      }
    }

    try {
      final context = p.Context(style: p.Style.posix, current: '/');
      await for (final request in listen) {
        // Clean filenames because SAH wants absolute POSIX paths.
        var filename = request.databaseName;
        if (filename != null) {
          filename = context.absolute(filename);
        }

        switch (request.type) {
          case DatabasePoolRequestType.init:
            await libsql.loadModule(
              // In debug mode, we need to pass the absolute path to the LibSQL
              // module since the worker's cwd is different.
              moduleUri: request.libsqlUri ?? Uri.parse('/js/libsql.js'),
            );
            sahPool = await libsql.getSAHPoolUtil(
              name: request.name,
              clearOnInit: request.clearOnInit,
            );
            respond.add(
              DatabasePoolResponse.success(
                requestId: request.requestId,
                resultSet: DatabasePoolResultSet(success: true),
                stats: sahPool.stats,
              ),
            );

          case DatabasePoolRequestType.exportDatabase:
            await runWithErrorHandling(request.requestId, () async {
              final data = sahPool.exportFile(filename!);
              return DatabasePoolResultSet(exportData: data);
            });

          case DatabasePoolRequestType.importDatabase:
            await runWithErrorHandling(request.requestId, () async {
              // Ensure capacity before importing
              await ensureCapacity();

              final bytesImported = sahPool.importDb(
                filename!,
                request.importData!,
              );
              openDatabases[filename] = Database(
                sahPool.openDatabase(filename),
              );
              return DatabasePoolResultSet(
                success: bytesImported == request.importData!.length,
              );
            });

          case DatabasePoolRequestType.deleteDatabase:
            await runWithErrorHandling(request.requestId, () async {
              final db = openDatabases.remove(filename!);
              if (db != null) {
                db.close();
              }
              final deleted = sahPool.unlink(filename);
              return DatabasePoolResultSet(success: deleted);
            });

          case DatabasePoolRequestType.openDatabase:
            await runWithErrorHandling(request.requestId, () async {
              var db = openDatabases[filename!];
              if (db == null) {
                // Ensure capacity before opening new database
                await ensureCapacity();

                // Create database using SAH Pool VFS
                db = openDatabases[filename] = Database(
                  sahPool.openDatabase(filename),
                );
              }
              return DatabasePoolResultSet(success: true);
            });
          case DatabasePoolRequestType.closeDatabase:
            await runWithErrorHandling(request.requestId, () async {
              final db = openDatabases.remove(filename!);
              if (db != null) {
                db.close();
              }
              return DatabasePoolResultSet(success: true);
            });
          case DatabasePoolRequestType.wipeAll:
            await runWithErrorHandling(request.requestId, () async {
              await sahPool.wipeFiles();
              return DatabasePoolResultSet(success: true);
            });
          case DatabasePoolRequestType.execute:
            final query = request.transaction!.statements.single;
            await runWithErrorHandling(
              request.requestId,
              statement: query.sql.trim(),
              () async {
                final db = openDatabases[filename!];
                if (db == null) {
                  throw StateError('Database not open: $filename');
                }
                final result = db.execute(query.sql, query.parameters.toList());
                return DatabasePoolResultSet(
                  resultSet: DatabaseResultSet(
                    columnNames: const [],
                    rows: const [],
                    lastInsertRowId: result.lastInsertRowId,
                    updatedRows: result.updatedRows,
                  ),
                );
              },
            );
          case DatabasePoolRequestType.query:
            final query = request.transaction!.statements.single;
            await runWithErrorHandling(
              request.requestId,
              statement: query.sql.trim(),
              () async {
                final db = openDatabases[filename!];
                if (db == null) {
                  throw StateError('Database not open: $filename');
                }
                final result =
                    db.select(query.sql, query.parameters.toList())
                        as ResultSet;
                return DatabasePoolResultSet(
                  resultSet: DatabaseResultSet(
                    columnNames: result.columnNames,
                    rows: result.rows,
                    lastInsertRowId: -1,
                    updatedRows: -1,
                  ),
                );
              },
            );
          case DatabasePoolRequestType.transaction:
            final statements = request.transaction!.statements;
            await runWithErrorHandling(
              request.requestId,
              statement: statements.map((it) => it.sql.trim()).join(';\n'),
              () async {
                final db = openDatabases[filename!];
                if (db == null) {
                  throw StateError('Database not open: $filename');
                }
                final changesBefore = db.totalChanges;
                db.transaction((tx) {
                  for (final statement in statements) {
                    tx.execute(statement.sql, statement.parameters.toList());
                  }
                });
                return DatabasePoolResultSet(
                  resultSet: DatabaseResultSet(
                    columnNames: const [],
                    rows: const [],
                    lastInsertRowId: db.lastInsertRowId,
                    updatedRows: db.totalChanges - changesBefore,
                  ),
                );
              },
            );
        }
      }
    } finally {
      await loggerSubscription.cancel();
    }
    return null;
  }
}

@SerializersFor([
  DatabasePoolRequest,
  DatabasePoolResponse,
  DatabasePoolRequestType,
  DatabasePoolResultSet,
])
final Serializers _serializers = _$_serializers;

extension on libsql.SAHPoolUtil {
  DatabasePoolStats get stats => DatabasePoolStats(
    databaseNames: fileNames,
    reservedCapacity: capacity,
    fileCount: fileCount,
    vfsName: vfsName,
  );
}

import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:logging/logging.dart';
import 'package:sqlite3/wasm.dart';
import 'package:worker_bee/worker_bee.dart';

import '../database/database.dart';
import '../database/transaction.dart';
import '../interop/libsql.dart' as libsql;

part 'database_worker.g.dart';

class DatabaseRequestType extends EnumClass {
  static const DatabaseRequestType init = _$init;
  static const DatabaseRequestType execute = _$execute;
  static const DatabaseRequestType query = _$query;
  static const DatabaseRequestType transaction = _$transaction;

  const DatabaseRequestType._(super.name);

  static BuiltSet<DatabaseRequestType> get values => _$values;
  static DatabaseRequestType valueOf(String name) => _$valueOf(name);

  static Serializer<DatabaseRequestType> get serializer =>
      _$databaseRequestTypeSerializer;
}

abstract class DatabaseRequest
    implements Built<DatabaseRequest, DatabaseRequestBuilder> {
  factory DatabaseRequest({
    required int requestId,
    required DatabaseRequestType type,
    required String sql,
    required List<Object?> parameters,
  }) {
    return _$DatabaseRequest._(
      requestId: requestId,
      type: type,
      transaction: Transaction([SqlStatement(sql, parameters)]),
    );
  }
  factory DatabaseRequest.transaction({
    required int requestId,
    required DatabaseRequestType type,
    required Transaction transaction,
  }) {
    return _$DatabaseRequest._(
      requestId: requestId,
      type: type,
      transaction: transaction,
    );
  }

  factory DatabaseRequest.init({
    required int requestId,
    required String filename,
    String? vfs,
    Uri? libsqlUri,
  }) {
    return _$DatabaseRequest._(
      requestId: requestId,
      type: DatabaseRequestType.init,
      transaction: Transaction.empty,
      filename: filename,
      libsqlUri: libsqlUri,
      vfsName: vfs,
    );
  }

  int get requestId;
  DatabaseRequestType get type;
  Transaction get transaction;

  // Init
  Uri? get libsqlUri;
  String? get filename;
  String? get vfsName;

  DatabaseRequest._();
  factory DatabaseRequest.build([
    void Function(DatabaseRequestBuilder) updates,
  ]) = _$DatabaseRequest;

  static Serializer<DatabaseRequest> get serializer =>
      _$databaseRequestSerializer;
}

abstract class DatabaseResponse
    implements Built<DatabaseResponse, DatabaseResponseBuilder> {
  factory DatabaseResponse.success({
    required int requestId,
    required DatabaseResultSet resultSet,
  }) {
    return _$DatabaseResponse._(requestId: requestId, resultSet: resultSet);
  }

  factory DatabaseResponse.failure({
    required int requestId,
    required Object error,
    int? errorCode,
    required StackTrace stackTrace,
  }) {
    return _$DatabaseResponse._(
      requestId: requestId,
      error: DatabaseError(
        message: error.toString(),
        code: errorCode,
        stackTrace: stackTrace,
      ),
    );
  }

  int get requestId;
  DatabaseResultSet? get resultSet;
  DatabaseError? get error;

  DatabaseResultSet unwrap() {
    if (error case final error?) {
      Error.throwWithStackTrace(
        SqliteException(error.code ?? -1, error.error),
        error.stackTrace,
      );
    }
    return resultSet!;
  }

  DatabaseResponse._();

  factory DatabaseResponse.build([
    void Function(DatabaseResponseBuilder) updates,
  ]) = _$DatabaseResponse;

  static Serializer<DatabaseResponse> get serializer =>
      _$databaseResponseSerializer;
}

abstract class DatabaseResultSet
    implements Built<DatabaseResultSet, DatabaseResultSetBuilder> {
  factory DatabaseResultSet({
    required List<String> columnNames,
    required List<List<Object?>> rows,
    required int lastInsertRowId,
    required int updatedRows,
  }) {
    return _$DatabaseResultSet._(
      columnNames: columnNames.build(),
      lastInsertRowId: lastInsertRowId,
      updatedRows: updatedRows,
      rows: rows.map((e) => e.build()).toBuiltList(),
    );
  }

  static final DatabaseResultSet empty = DatabaseResultSet(
    columnNames: const [],
    rows: const [],
    lastInsertRowId: 0,
    updatedRows: 0,
  );

  BuiltList<String> get columnNames;
  int get lastInsertRowId;
  int get updatedRows;
  BuiltList<BuiltList<Object?>> get rows;

  DatabaseResultSet._();

  factory DatabaseResultSet.build([
    void Function(DatabaseResultSetBuilder) updates,
  ]) = _$DatabaseResultSet;

  static Serializer<DatabaseResultSet> get serializer =>
      _$databaseResultSetSerializer;
}

abstract class DatabaseError
    implements Built<DatabaseError, DatabaseErrorBuilder> {
  factory DatabaseError({
    required String message,
    int? code,
    required StackTrace stackTrace,
  }) {
    return _$DatabaseError._(
      error: message,
      code: code,
      stackTrace: stackTrace,
    );
  }

  String get error;
  int? get code;
  StackTrace get stackTrace;

  DatabaseError._();

  factory DatabaseError.build([void Function(DatabaseErrorBuilder) updates]) =
      _$DatabaseError;

  static Serializer<DatabaseError> get serializer => _$databaseErrorSerializer;
}

@WorkerBee('lib/workers/workers.dart')
abstract class DatabaseWorker
    extends WorkerBeeBase<DatabaseRequest, DatabaseResponse> {
  DatabaseWorker() : super(serializers: _serializers);

  factory DatabaseWorker.create() = _$DatabaseWorker;

  @override
  Future<DatabaseResponse?> run(
    Stream<DatabaseRequest> listen,
    StreamSink<DatabaseResponse> respond,
  ) async {
    Logger.root.level = Level.ALL;
    final loggerSubscription = Logger.root.onRecord.listen(
      (r) => logSink.sink.add(WorkerLogRecord.from(r, local: false)),
    );

    Future<void> runWithErrorHandling(
      int requestId,
      Future<DatabaseResultSet> Function() action,
    ) async {
      try {
        final result = await action();
        respond.add(
          DatabaseResponse.success(requestId: requestId, resultSet: result),
        );
      } catch (e, st) {
        respond.add(
          DatabaseResponse.failure(
            requestId: requestId,
            error: e,
            errorCode: e is SqliteException ? e.extendedResultCode : null,
            stackTrace: st,
          ),
        );
      }
    }

    try {
      late final Database db;
      await for (final request in listen) {
        switch (request.type) {
          case DatabaseRequestType.init:
            await libsql.loadModule(
              // In debug mode, we need to pass the absolute path to the LibSQL
              // module since the worker's cwd is different.
              moduleUri: request.libsqlUri ?? Uri.parse('/js/libsql.js'),
            );
            db = Database(
              libsql.Database(
                filename: request.filename!,
                vfs: request.vfsName,
                flags: 'c',
              ),
            );
            respond.add(
              DatabaseResponse.success(
                requestId: request.requestId,
                resultSet: DatabaseResultSet.empty,
              ),
            );
          case DatabaseRequestType.execute:
            await runWithErrorHandling(request.requestId, () async {
              final query = request.transaction.statements.single;
              final result = db.execute(query.sql, query.parameters.toList());
              return DatabaseResultSet(
                columnNames: const [],
                rows: const [],
                lastInsertRowId: result.lastInsertRowId,
                updatedRows: result.updatedRows,
              );
            });
          case DatabaseRequestType.query:
            await runWithErrorHandling(request.requestId, () async {
              final query = request.transaction.statements.single;
              final result =
                  db.select(query.sql, query.parameters.toList()) as ResultSet;
              return DatabaseResultSet(
                columnNames: result.columnNames,
                rows: result.rows,
                lastInsertRowId: -1,
                updatedRows: -1,
              );
            });
          case DatabaseRequestType.transaction:
            await runWithErrorHandling(request.requestId, () async {
              final changesBefore = db.totalChanges;
              db.transaction((tx) {
                for (final statement in request.transaction.statements) {
                  tx.execute(statement.sql, statement.parameters.toList());
                }
              });
              return DatabaseResultSet(
                columnNames: const [],
                rows: const [],
                lastInsertRowId: db.lastInsertRowId,
                updatedRows: db.totalChanges - changesBefore,
              );
            });
        }
      }
    } finally {
      await loggerSubscription.cancel();
    }
    return null;
  }
}

@SerializersFor([DatabaseRequest, DatabaseResponse, DatabaseRequestType])
final Serializers _serializers = _$_serializers;

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

part 'libsql_worker.g.dart';

class LibsqlRequestType extends EnumClass {
  static const LibsqlRequestType init = _$init;
  static const LibsqlRequestType execute = _$execute;
  static const LibsqlRequestType query = _$query;
  static const LibsqlRequestType transaction = _$transaction;

  const LibsqlRequestType._(super.name);

  static BuiltSet<LibsqlRequestType> get values => _$values;
  static LibsqlRequestType valueOf(String name) => _$valueOf(name);

  static Serializer<LibsqlRequestType> get serializer =>
      _$libsqlRequestTypeSerializer;
}

abstract class LibsqlRequest
    implements Built<LibsqlRequest, LibsqlRequestBuilder> {
  factory LibsqlRequest({
    required int requestId,
    required LibsqlRequestType type,
    required String sql,
    required List<Object?> parameters,
  }) {
    return _$LibsqlRequest._(
      requestId: requestId,
      type: type,
      transaction: Transaction([SqlStatement(sql, parameters)]),
    );
  }
  factory LibsqlRequest.transaction({
    required int requestId,
    required LibsqlRequestType type,
    required Transaction transaction,
  }) {
    return _$LibsqlRequest._(
      requestId: requestId,
      type: type,
      transaction: transaction,
    );
  }

  factory LibsqlRequest.init({
    required int requestId,
    required String filename,
    required String vfs,
    Uri? moduleUri,
  }) {
    return _$LibsqlRequest._(
      requestId: requestId,
      type: LibsqlRequestType.init,
      transaction: Transaction.empty,
      filename: filename,
      moduleUri: moduleUri,
      vfsName: vfs,
    );
  }

  int get requestId;
  LibsqlRequestType get type;
  Transaction get transaction;

  // Init
  Uri? get moduleUri;
  String? get filename;
  String? get vfsName;

  LibsqlRequest._();
  factory LibsqlRequest.build([void Function(LibsqlRequestBuilder) updates]) =
      _$LibsqlRequest;

  static Serializer<LibsqlRequest> get serializer => _$libsqlRequestSerializer;
}

abstract class LibsqlResponse
    implements Built<LibsqlResponse, LibsqlResponseBuilder> {
  factory LibsqlResponse.success({
    required int requestId,
    required LibsqlResultSet resultSet,
  }) {
    return _$LibsqlResponse._(requestId: requestId, resultSet: resultSet);
  }

  factory LibsqlResponse.failure({
    required int requestId,
    required Object error,
    int? errorCode,
    required StackTrace stackTrace,
  }) {
    return _$LibsqlResponse._(
      requestId: requestId,
      error: LibsqlError(
        message: error.toString(),
        code: errorCode,
        stackTrace: stackTrace,
      ),
    );
  }

  int get requestId;
  LibsqlResultSet? get resultSet;
  LibsqlError? get error;

  LibsqlResultSet unwrap() {
    if (error case final error?) {
      Error.throwWithStackTrace(
        SqliteException(error.code ?? -1, error.error),
        error.stackTrace,
      );
    }
    return resultSet!;
  }

  LibsqlResponse._();

  factory LibsqlResponse.build([void Function(LibsqlResponseBuilder) updates]) =
      _$LibsqlResponse;

  static Serializer<LibsqlResponse> get serializer =>
      _$libsqlResponseSerializer;
}

abstract class LibsqlResultSet
    implements Built<LibsqlResultSet, LibsqlResultSetBuilder> {
  factory LibsqlResultSet({
    required List<String> columnNames,
    required List<List<Object?>> rows,
    required int lastInsertRowId,
    required int updatedRows,
  }) {
    return _$LibsqlResultSet._(
      columnNames: columnNames.build(),
      lastInsertRowId: lastInsertRowId,
      updatedRows: updatedRows,
      rows: rows.map((e) => e.build()).toBuiltList(),
    );
  }

  static final LibsqlResultSet empty = LibsqlResultSet(
    columnNames: const [],
    rows: const [],
    lastInsertRowId: 0,
    updatedRows: 0,
  );

  BuiltList<String> get columnNames;
  int get lastInsertRowId;
  int get updatedRows;
  BuiltList<BuiltList<Object?>> get rows;

  LibsqlResultSet._();

  factory LibsqlResultSet.build([
    void Function(LibsqlResultSetBuilder) updates,
  ]) = _$LibsqlResultSet;

  static Serializer<LibsqlResultSet> get serializer =>
      _$libsqlResultSetSerializer;
}

abstract class LibsqlError implements Built<LibsqlError, LibsqlErrorBuilder> {
  factory LibsqlError({
    required String message,
    int? code,
    required StackTrace stackTrace,
  }) {
    return _$LibsqlError._(error: message, code: code, stackTrace: stackTrace);
  }

  String get error;
  int? get code;
  StackTrace get stackTrace;

  LibsqlError._();

  factory LibsqlError.build([void Function(LibsqlErrorBuilder) updates]) =
      _$LibsqlError;

  static Serializer<LibsqlError> get serializer => _$libsqlErrorSerializer;
}

@WorkerBee('lib/workers/workers.dart')
abstract class LibsqlWorker
    extends WorkerBeeBase<LibsqlRequest, LibsqlResponse> {
  LibsqlWorker() : super(serializers: _serializers);

  factory LibsqlWorker.create() = _$LibsqlWorker;

  @override
  Future<LibsqlResponse?> run(
    Stream<LibsqlRequest> listen,
    StreamSink<LibsqlResponse> respond,
  ) async {
    Logger.root.level = Level.ALL;
    final loggerSubscription = Logger.root.onRecord.listen(
      (r) => logSink.sink.add(WorkerLogRecord.from(r, local: false)),
    );

    Future<void> runWithErrorHandling(
      int requestId,
      Future<LibsqlResultSet> Function() action,
    ) async {
      try {
        final result = await action();
        respond.add(
          LibsqlResponse.success(requestId: requestId, resultSet: result),
        );
      } catch (e, st) {
        respond.add(
          LibsqlResponse.failure(
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
          case LibsqlRequestType.init:
            await libsql.loadModule(
              // In debug mode, we need to pass the absolute path to the LibSQL
              // module since the worker's cwd is different.
              moduleUri: request.moduleUri ?? Uri.parse('/js/libsql.js'),
            );
            db = Database(
              libsql.Database(
                filename: request.filename!,
                vfs: request.vfsName,
                flags: 'c',
              ),
            );
            respond.add(
              LibsqlResponse.success(
                requestId: request.requestId,
                resultSet: LibsqlResultSet.empty,
              ),
            );
          case LibsqlRequestType.execute:
            await runWithErrorHandling(request.requestId, () async {
              final query = request.transaction.statements.single;
              final result = db.execute(query.sql, query.parameters.toList());
              return LibsqlResultSet(
                columnNames: const [],
                rows: const [],
                lastInsertRowId: result.lastInsertRowId,
                updatedRows: result.updatedRows,
              );
            });
          case LibsqlRequestType.query:
            await runWithErrorHandling(request.requestId, () async {
              final query = request.transaction.statements.single;
              final result =
                  db.select(query.sql, query.parameters.toList()) as ResultSet;
              return LibsqlResultSet(
                columnNames: result.columnNames,
                rows: result.rows,
                lastInsertRowId: -1,
                updatedRows: -1,
              );
            });
          case LibsqlRequestType.transaction:
            await runWithErrorHandling(request.requestId, () async {
              final changesBefore = db.totalChanges;
              db.transaction((tx) {
                for (final statement in request.transaction.statements) {
                  tx.execute(statement.sql, statement.parameters.toList());
                }
              });
              return LibsqlResultSet(
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

@SerializersFor([LibsqlRequest, LibsqlResponse, LibsqlRequestType])
final Serializers _serializers = _$_serializers;

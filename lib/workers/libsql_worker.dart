import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:logging/logging.dart';
import 'package:sqlite3/common.dart';
import 'package:worker_bee/worker_bee.dart';

import '../database/database.dart';
import '../database/transaction.dart';

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
    String? flags,
    String? vfs,
    Uri? moduleUri,
  }) {
    return _$LibsqlRequest._(
      requestId: requestId,
      type: LibsqlRequestType.init,
      transaction: Transaction.empty,
      filename: filename,
      flags: flags,
      vfs: vfs,
      moduleUri: moduleUri,
    );
  }

  int get requestId;
  LibsqlRequestType get type;
  Transaction get transaction;

  // Init
  Uri? get moduleUri;
  String? get filename;
  String? get flags;
  String? get vfs;

  LibsqlRequest._();
  factory LibsqlRequest.build([void Function(LibsqlRequestBuilder) updates]) =
      _$LibsqlRequest;

  static Serializer<LibsqlRequest> get serializer => _$libsqlRequestSerializer;
}

abstract class LibsqlResponse
    implements Built<LibsqlResponse, LibsqlResponseBuilder> {
  factory LibsqlResponse({
    required int requestId,
    required List<String> columnNames,
    required List<List<Object?>> rows,
  }) {
    return _$LibsqlResponse._(
      requestId: requestId,
      columnNames: columnNames.build(),
      rows: rows.map((e) => e.build()).toBuiltList(),
    );
  }

  int get requestId;
  BuiltList<String> get columnNames;
  BuiltList<BuiltList<Object?>> get rows;

  LibsqlResponse._();

  factory LibsqlResponse.build([void Function(LibsqlResponseBuilder) updates]) =
      _$LibsqlResponse;

  static Serializer<LibsqlResponse> get serializer =>
      _$libsqlResponseSerializer;
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
    try {
      late final Database db;
      await for (final request in listen) {
        switch (request.type) {
          case LibsqlRequestType.init:
            db = await Database.open(
              request.filename!,
              // In debug mode, we need to pass the absolute path to the LibSQL
              // module since the worker's cwd is different.
              moduleUri: request.moduleUri ?? Uri.parse('/js/libsql.js'),
              isWorker: true,
              verbose: request.flags?.contains('t') ?? false,
            );
            respond.add(
              LibsqlResponse(
                requestId: request.requestId,
                rows: const [],
                columnNames: const [],
              ),
            );
          case LibsqlRequestType.execute:
            final query = request.transaction.statements.single;
            await db.execute(query.sql, query.parameters.toList());
            respond.add(
              LibsqlResponse(
                requestId: request.requestId,
                rows: const [],
                columnNames: const [],
              ),
            );
          case LibsqlRequestType.query:
            final query = request.transaction.statements.single;
            final result =
                await db.select(query.sql, query.parameters.toList())
                    as ResultSet;
            respond.add(
              LibsqlResponse(
                requestId: request.requestId,
                rows: result.rows,
                columnNames: result.columnNames,
              ),
            );
          case LibsqlRequestType.transaction:
            await db.transaction((tx) {
              for (final statement in request.transaction.statements) {
                tx.execute(statement.sql, statement.parameters.toList());
              }
            });
            respond.add(
              LibsqlResponse(
                requestId: request.requestId,
                rows: const [],
                columnNames: const [],
              ),
            );
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

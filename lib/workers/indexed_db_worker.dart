import 'dart:async';
import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:logging/logging.dart';
import 'package:worker_bee/worker_bee.dart';

import '../util/indexed_db.dart';

part 'indexed_db_worker.g.dart';

class IndexedDbRequestType extends EnumClass {
  static const IndexedDbRequestType get = _$get;
  static const IndexedDbRequestType getAllKeys = _$getAllKeys;
  static const IndexedDbRequestType getStorageSize = _$getStorageSize;
  static const IndexedDbRequestType set = _$set;
  static const IndexedDbRequestType delete = _$delete;
  static const IndexedDbRequestType clear = _$clear;
  static const IndexedDbRequestType exists = _$exists;

  const IndexedDbRequestType._(super.name);

  static BuiltSet<IndexedDbRequestType> get values => _$values;
  static IndexedDbRequestType valueOf(String name) => _$valueOf(name);

  static Serializer<IndexedDbRequestType> get serializer =>
      _$indexedDbRequestTypeSerializer;
}

abstract class IndexedDbRequest
    implements Built<IndexedDbRequest, IndexedDbRequestBuilder> {
  factory IndexedDbRequest({
    required int requestId,
    required IndexedDbRequestType type,
    String? key,
    String? value,
  }) {
    return _$IndexedDbRequest._(
      requestId: requestId,
      type: type,
      key: key,
      value: value,
    );
  }

  int get requestId;
  IndexedDbRequestType get type;
  String? get key;
  String? get value;

  IndexedDbRequest._();
  factory IndexedDbRequest.build([
    void Function(IndexedDbRequestBuilder) updates,
  ]) = _$IndexedDbRequest;

  static Serializer<IndexedDbRequest> get serializer =>
      _$indexedDbRequestSerializer;
}

abstract class IndexedDbResponse
    implements Built<IndexedDbResponse, IndexedDbResponseBuilder> {
  factory IndexedDbResponse({required int requestId, String? value}) {
    return _$IndexedDbResponse._(requestId: requestId, value: value);
  }

  int get requestId;
  String? get value;

  IndexedDbResponse._();

  factory IndexedDbResponse.build([
    void Function(IndexedDbResponseBuilder) updates,
  ]) = _$IndexedDbResponse;

  static Serializer<IndexedDbResponse> get serializer =>
      _$indexedDbResponseSerializer;
}

@WorkerBee('lib/workers/workers.dart')
abstract class IndexedDbWorker
    extends WorkerBeeBase<IndexedDbRequest, IndexedDbResponse> {
  IndexedDbWorker() : super(serializers: _serializers);

  factory IndexedDbWorker.create() = _$IndexedDbWorker;

  @override
  Future<IndexedDbResponse?> run(
    Stream<IndexedDbRequest> listen,
    StreamSink<IndexedDbResponse> respond,
  ) async {
    Logger.root.level = Level.ALL;
    final loggerSubscription = Logger.root.onRecord.listen(
      (r) => logSink.sink.add(WorkerLogRecord.from(r, local: false)),
    );
    try {
      await indexedDB.initialize();
      await for (final request in listen) {
        final IndexedDbRequest(:requestId, :type, :key, :value) = request;
        switch (type) {
          case IndexedDbRequestType.get:
            final result = await indexedDB.getValue(key!);
            respond.add(IndexedDbResponse(requestId: requestId, value: result));
          case IndexedDbRequestType.set:
            await indexedDB.setValue(key!, value!);
            respond.add(IndexedDbResponse(requestId: requestId));
          case IndexedDbRequestType.delete:
            await indexedDB.removeValue(key!);
            respond.add(IndexedDbResponse(requestId: requestId));
          case IndexedDbRequestType.clear:
            await indexedDB.clearAll();
            respond.add(IndexedDbResponse(requestId: requestId));
          case IndexedDbRequestType.exists:
            final exists = await indexedDB.hasKey(key!);
            respond.add(
              IndexedDbResponse(
                requestId: requestId,
                value: exists ? 'true' : 'false',
              ),
            );
          case IndexedDbRequestType.getAllKeys:
            final keys = await indexedDB.getAllKeys();
            respond.add(
              IndexedDbResponse(requestId: requestId, value: jsonEncode(keys)),
            );
          case IndexedDbRequestType.getStorageSize:
            final size = await indexedDB.getStorageSize();
            respond.add(
              IndexedDbResponse(requestId: requestId, value: size.toString()),
            );
          default:
            throw UnimplementedError('Unknown request type: $type');
        }
      }
    } finally {
      await loggerSubscription.cancel();
    }
    return null;
  }
}

@SerializersFor([IndexedDbRequest, IndexedDbResponse, IndexedDbRequestType])
final Serializers _serializers = _$_serializers;

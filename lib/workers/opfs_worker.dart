import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;
import 'package:worker_bee/worker_bee.dart';

import '../interop/common.dart';

part 'opfs_worker.g.dart';

class OpfsWorkerRequestType extends EnumClass {
  static const OpfsWorkerRequestType readAsBytes = _$readAsBytes;
  static const OpfsWorkerRequestType readAsString = _$readAsString;
  static const OpfsWorkerRequestType writeAsBytes = _$writeAsBytes;
  static const OpfsWorkerRequestType writeAsString = _$writeAsString;
  static const OpfsWorkerRequestType delete = _$delete;
  static const OpfsWorkerRequestType clear = _$clear;

  const OpfsWorkerRequestType._(super.name);

  static BuiltSet<OpfsWorkerRequestType> get values => _$values;
  static OpfsWorkerRequestType valueOf(String name) => _$valueOf(name);

  static Serializer<OpfsWorkerRequestType> get serializer =>
      _$opfsWorkerRequestTypeSerializer;
}

abstract class OpfsWorkerRequest
    implements Built<OpfsWorkerRequest, OpfsWorkerRequestBuilder> {
  int get requestId;
  OpfsWorkerRequestType get type;
  String? get path;
  Uint8List? get data;
  String? get stringData;

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpfsWorkerRequest')
          ..add('requestId', requestId)
          ..add('type', type)
          ..add('path', path)
          ..add('data', data != null ? '[${data!.length} bytes]' : null)
          ..add(
            'stringData',
            stringData != null ? '[${stringData!.length} chars]' : null,
          ))
        .toString();
  }

  factory OpfsWorkerRequest.readAsBytes({
    required int requestId,
    required String path,
  }) {
    return _$OpfsWorkerRequest._(
      requestId: requestId,
      type: OpfsWorkerRequestType.readAsBytes,
      path: path,
    );
  }

  factory OpfsWorkerRequest.readAsString({
    required int requestId,
    required String path,
  }) {
    return _$OpfsWorkerRequest._(
      requestId: requestId,
      type: OpfsWorkerRequestType.readAsString,
      path: path,
    );
  }

  factory OpfsWorkerRequest.writeAsBytes({
    required int requestId,
    required String path,
    required Uint8List data,
  }) {
    return _$OpfsWorkerRequest._(
      requestId: requestId,
      type: OpfsWorkerRequestType.writeAsBytes,
      path: path,
      data: data,
    );
  }

  factory OpfsWorkerRequest.writeAsString({
    required int requestId,
    required String path,
    required String stringData,
  }) {
    return _$OpfsWorkerRequest._(
      requestId: requestId,
      type: OpfsWorkerRequestType.writeAsString,
      path: path,
      stringData: stringData,
    );
  }

  factory OpfsWorkerRequest.delete({
    required int requestId,
    required String path,
  }) {
    return _$OpfsWorkerRequest._(
      requestId: requestId,
      type: OpfsWorkerRequestType.delete,
      path: path,
    );
  }

  factory OpfsWorkerRequest.clear({required int requestId}) {
    return _$OpfsWorkerRequest._(
      requestId: requestId,
      type: OpfsWorkerRequestType.clear,
    );
  }

  OpfsWorkerRequest._();

  factory OpfsWorkerRequest.build([
    void Function(OpfsWorkerRequestBuilder) updates,
  ]) = _$OpfsWorkerRequest;

  static Serializer<OpfsWorkerRequest> get serializer =>
      _$opfsWorkerRequestSerializer;
}

abstract class OpfsWorkerResponse
    implements Built<OpfsWorkerResponse, OpfsWorkerResponseBuilder> {
  int get requestId;
  Uint8List? get data;
  String? get stringData;
  bool? get success;
  OpfsWorkerError? get error;

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpfsWorkerResponse')
          ..add('requestId', requestId)
          ..add('data', data != null ? '[${data!.length} bytes]' : null)
          ..add(
            'stringData',
            stringData != null ? '[${stringData!.length} chars]' : null,
          )
          ..add('success', success)
          ..add('error', error))
        .toString();
  }

  factory OpfsWorkerResponse.success({
    required int requestId,
    Uint8List? data,
    String? stringData,
    bool? success,
  }) {
    return _$OpfsWorkerResponse._(
      requestId: requestId,
      data: data,
      stringData: stringData,
      success: success,
    );
  }

  factory OpfsWorkerResponse.failure({
    required int requestId,
    required Object error,
    required StackTrace stackTrace,
  }) {
    return _$OpfsWorkerResponse._(
      requestId: requestId,
      error: OpfsWorkerError(message: error.toString(), stackTrace: stackTrace),
    );
  }

  void unwrap() {
    if (error case final error?) {
      Error.throwWithStackTrace(StateError(error.error), error.stackTrace);
    }
  }

  OpfsWorkerResponse._();

  factory OpfsWorkerResponse.build([
    void Function(OpfsWorkerResponseBuilder) updates,
  ]) = _$OpfsWorkerResponse;

  static Serializer<OpfsWorkerResponse> get serializer =>
      _$opfsWorkerResponseSerializer;
}

abstract class OpfsWorkerError
    implements Built<OpfsWorkerError, OpfsWorkerErrorBuilder> {
  factory OpfsWorkerError({
    required String message,
    required StackTrace stackTrace,
  }) {
    return _$OpfsWorkerError._(error: message, stackTrace: stackTrace);
  }

  String get error;
  StackTrace get stackTrace;

  OpfsWorkerError._();

  factory OpfsWorkerError.build([
    void Function(OpfsWorkerErrorBuilder) updates,
  ]) = _$OpfsWorkerError;

  static Serializer<OpfsWorkerError> get serializer =>
      _$opfsWorkerErrorSerializer;
}

@WorkerBee('lib/workers/workers.dart')
abstract class OpfsWorker
    extends WorkerBeeBase<OpfsWorkerRequest, OpfsWorkerResponse> {
  OpfsWorker() : super(serializers: _serializers);

  factory OpfsWorker.create() = _$OpfsWorker;

  @override
  Future<OpfsWorkerResponse?> run(
    Stream<OpfsWorkerRequest> listen,
    StreamSink<OpfsWorkerResponse> respond,
  ) async {
    Logger.root.level = Level.ALL;
    final loggerSubscription = Logger.root.onRecord.listen(
      (r) => logSink.sink.add(WorkerLogRecord.from(r, local: false)),
    );

    Future<void> runWithErrorHandling(
      int requestId,
      Future<OpfsWorkerResponse> Function() action,
    ) async {
      try {
        final result = await action();
        respond.add(result);
      } catch (e, st) {
        logger.severe('Error processing request $requestId', e, st);
        respond.add(
          OpfsWorkerResponse.failure(
            requestId: requestId,
            error: e,
            stackTrace: st,
          ),
        );
      }
    }

    final self = globalContext as web.DedicatedWorkerGlobalScope;

    bool isNotFoundError(Object e) {
      final jsEx = e as JSAny?;
      return jsEx.isA<web.DOMException>() &&
          (jsEx as web.DOMException).name == 'NotFoundError';
    }

    Future<web.FileSystemSyncAccessHandle> getFileHandle(
      String path, {
      bool create = true,
    }) async {
      final root = await self.navigator.storage.getDirectory().toDart;
      final fileHandle = await root
          .getFileHandle(path, web.FileSystemGetFileOptions(create: create))
          .toDart;
      return fileHandle.createSyncAccessHandle().toDart;
    }

    try {
      await for (final request in listen) {
        switch (request.type) {
          case OpfsWorkerRequestType.readAsBytes:
            await runWithErrorHandling(request.requestId, () async {
              final handle = await getFileHandle(request.path!, create: false);
              try {
                final size = handle.getSize();
                if (size == 0) {
                  return OpfsWorkerResponse.success(
                    requestId: request.requestId,
                    data: Uint8List(0),
                  );
                }

                // Create buffer and read data
                final buffer = JSArrayBuffer(size);
                final dataView = JSDataView(buffer);
                handle.read(dataView, web.FileSystemReadWriteOptions());

                final data = buffer.toDart.asUint8List();
                return OpfsWorkerResponse.success(
                  requestId: request.requestId,
                  data: data,
                );
              } finally {
                handle.close();
              }
            });

          case OpfsWorkerRequestType.readAsString:
            await runWithErrorHandling(request.requestId, () async {
              final handle = await getFileHandle(request.path!, create: false);
              try {
                final size = handle.getSize();
                if (size == 0) {
                  return OpfsWorkerResponse.success(
                    requestId: request.requestId,
                    stringData: '',
                  );
                }

                // Create buffer and read data
                final buffer = JSArrayBuffer(size);
                final dataView = JSDataView(buffer);
                handle.read(dataView, web.FileSystemReadWriteOptions());

                final data = buffer.toDart.asUint8List();
                final decoder = web.TextDecoder();
                final stringData = decoder.decode(data.toJS);

                return OpfsWorkerResponse.success(
                  requestId: request.requestId,
                  stringData: stringData,
                );
              } finally {
                handle.close();
              }
            });

          case OpfsWorkerRequestType.writeAsBytes:
            await runWithErrorHandling(request.requestId, () async {
              final handle = await getFileHandle(request.path!);
              try {
                // Truncate file first to clear existing content
                handle.truncate(0);

                // Write the data - use JSUint8Array directly
                final jsData = request.data!.toJS;
                handle.write(jsData, web.FileSystemReadWriteOptions(at: 0));
                handle.flush();

                return OpfsWorkerResponse.success(
                  requestId: request.requestId,
                  success: true,
                );
              } finally {
                handle.close();
              }
            });

          case OpfsWorkerRequestType.writeAsString:
            await runWithErrorHandling(request.requestId, () async {
              final handle = await getFileHandle(request.path!);
              try {
                // Truncate file first to clear existing content
                handle.truncate(0);

                // Encode string to bytes
                final encoder = web.TextEncoder();
                final encodedData = encoder.encode(request.stringData!);

                handle.write(
                  encodedData,
                  web.FileSystemReadWriteOptions(at: 0),
                );
                handle.flush();

                return OpfsWorkerResponse.success(
                  requestId: request.requestId,
                  success: true,
                );
              } finally {
                handle.close();
              }
            });

          case OpfsWorkerRequestType.delete:
            await runWithErrorHandling(request.requestId, () async {
              final root = await self.navigator.storage.getDirectory().toDart;
              try {
                await root.removeEntry(request.path!).toDart;
                return OpfsWorkerResponse.success(
                  requestId: request.requestId,
                  success: true,
                );
              } catch (e) {
                if (isNotFoundError(e)) {
                  // File might not exist, which is fine for delete
                  logger.fine('File ${request.path} not found for deletion', e);
                  return OpfsWorkerResponse.success(
                    requestId: request.requestId,
                    success: true,
                  );
                }
                rethrow;
              }
            });

          case OpfsWorkerRequestType.clear:
            await runWithErrorHandling(request.requestId, () async {
              final root = await self.navigator.storage.getDirectory().toDart;

              // Try the native remove() first for efficiency
              try {
                await root
                    .remove(web.FileSystemRemoveOptions(recursive: true))
                    .toDart;
                return OpfsWorkerResponse.success(
                  requestId: request.requestId,
                  success: true,
                );
              } catch (e) {
                logger.finest('OPFS remove() not supported', e);
              }

              // Try to iterate over entries using the same pattern as storage_service.dart
              try {
                final keysIterator = root.callMethod<JSAsyncIterator<JSString>>(
                  'keys'.toJS,
                );
                final keysStream = keysIterator.stream;
                await for (final path in keysStream.map((e) => e.toDart)) {
                  logger.finest('Removing OPFS entry: $path');
                  await root
                      .removeEntry(
                        path,
                        web.FileSystemRemoveOptions(recursive: true),
                      )
                      .toDart;
                }
                return OpfsWorkerResponse.success(
                  requestId: request.requestId,
                  success: true,
                );
              } catch (e) {
                logger.finest('OPFS entries() not supported', e);
              }

              logger.warning('Failed to clear OPFS storage');
              return OpfsWorkerResponse.success(
                requestId: request.requestId,
                success: false,
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

@SerializersFor([OpfsWorkerRequest, OpfsWorkerResponse, OpfsWorkerRequestType])
final Serializers _serializers = _$_serializers;

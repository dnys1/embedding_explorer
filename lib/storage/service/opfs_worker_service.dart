import 'dart:async';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:worker_bee/worker_bee.dart';

import '../../workers/opfs_worker.dart';
import 'storage_service.dart';

/// A service that manages OPFS file operations using a dedicated worker.
///
/// This service provides a clean interface for file operations
/// that work across all browsers, including Safari where createWritable
/// is not available but createSyncAccessHandle is available in workers.
class OpfsWorkerService implements StorageService {
  static final Logger _localLogger = Logger('OpfsService');
  static final Logger _remoteLogger = Logger('OpfsService.Worker');

  final OpfsWorker _worker;
  StreamSubscription<LogRecord>? _logSubscription;
  var _nextRequestId = 1;
  var _disposed = false;

  @override
  String get name => 'OPFS (Worker)';

  /// Creates a new OPFS service instance.
  OpfsWorkerService._(this._worker);

  static Future<OpfsWorkerService> create() async {
    final worker = OpfsWorker.create();
    final service = OpfsWorkerService._(worker);
    await service._init();
    return service;
  }

  Future<void> _init() async {
    try {
      await _worker.spawn().timeout(const Duration(seconds: 10));
    } on Object {
      _worker.close(force: true).ignore();
      rethrow;
    }

    _logSubscription = _worker.logs.listen((record) {
      final logger = record is WorkerLogRecord && record.local == false
          ? _remoteLogger
          : _localLogger;
      logger.log(record.level, record.message, record.error, record.stackTrace);
    });

    _localLogger.fine('OPFS service initialized');
  }

  /// Reads a file as bytes.
  ///
  /// Throws [StateError] if the file doesn't exist or read fails.
  @override
  Future<Uint8List> readAsBytes(String path) async {
    final requestId = _nextRequestId++;
    _worker.add(
      OpfsWorkerRequest.readAsBytes(requestId: requestId, path: path),
    );

    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );

    response.unwrap();
    final data = response.data;
    if (data == null) {
      throw StateError('Failed to read file as bytes: $path');
    }

    _localLogger.fine('Read file $path as bytes (${data.length} bytes)');
    return data;
  }

  /// Reads a file as a string.
  ///
  /// Throws [StateError] if the file doesn't exist or read fails.
  @override
  Future<String> readAsString(String path) async {
    final requestId = _nextRequestId++;
    _worker.add(
      OpfsWorkerRequest.readAsString(requestId: requestId, path: path),
    );

    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );

    response.unwrap();
    final stringData = response.stringData;
    if (stringData == null) {
      throw StateError('Failed to read file as string: $path');
    }

    _localLogger.fine('Read file $path as string (${stringData.length} chars)');
    return stringData;
  }

  /// Writes data to a file as bytes.
  ///
  /// Throws [StateError] if the write fails.
  @override
  Future<void> writeAsBytes(String path, Uint8List data) async {
    final requestId = _nextRequestId++;
    _worker.add(
      OpfsWorkerRequest.writeAsBytes(
        requestId: requestId,
        path: path,
        data: data,
      ),
    );

    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );

    response.unwrap();
    if (response.success != true) {
      throw StateError('Failed to write file as bytes: $path');
    }

    _localLogger.fine('Wrote file $path as bytes (${data.length} bytes)');
  }

  /// Writes data to a file as a string.
  ///
  /// Throws [StateError] if the write fails.
  @override
  Future<void> writeAsString(String path, String data) async {
    final requestId = _nextRequestId++;
    _worker.add(
      OpfsWorkerRequest.writeAsString(
        requestId: requestId,
        path: path,
        stringData: data,
      ),
    );

    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );

    response.unwrap();
    if (response.success != true) {
      throw StateError('Failed to write file as string: $path');
    }

    _localLogger.fine('Wrote file $path as string (${data.length} chars)');
  }

  /// Deletes a file.
  ///
  /// Throws [StateError] if the delete fails.
  @override
  Future<void> delete(String path) async {
    final requestId = _nextRequestId++;
    _worker.add(OpfsWorkerRequest.delete(requestId: requestId, path: path));

    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );

    response.unwrap();
    if (response.success != true) {
      throw StateError('Failed to delete file: $path');
    }

    _localLogger.fine('Deleted file $path');
  }

  /// Clears all files in OPFS storage.
  ///
  /// Throws [StateError] if the clear operation fails.
  @override
  Future<void> clear() async {
    final requestId = _nextRequestId++;
    _worker.add(OpfsWorkerRequest.clear(requestId: requestId));

    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );

    response.unwrap();
    if (response.success != true) {
      throw StateError('Failed to clear OPFS storage');
    }

    _localLogger.fine('Cleared all OPFS files');
  }

  /// Disposes the OPFS service and closes the worker.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    unawaited(_logSubscription?.cancel());
    _logSubscription = null;
    await _worker.close();
  }
}

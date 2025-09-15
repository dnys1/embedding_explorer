import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

import '../../interop/common.dart';
import '../../util/file.dart';
import 'opfs_worker_service.dart';

abstract interface class StorageService {
  static Future<StorageService> opfs({bool? useWorker}) async {
    useWorker ??= await OpfsStorageService.shouldUseWorker;
    OpfsStorageService._logger.config(
      'Using ${useWorker ? 'worker-based' : 'direct'} OPFS implementation',
    );
    if (useWorker) {
      return OpfsWorkerService.create();
    }
    return OpfsStorageService._();
  }

  String get name;

  Future<Uint8List> readAsBytes(String path);
  Future<String> readAsString(String path);

  Future<void> writeAsBytes(String path, Uint8List data);
  Future<void> writeAsString(String path, String data);

  Future<void> delete(String path);
  Future<void> clear();
}

final class OpfsStorageService implements StorageService {
  static final Logger _logger = Logger('OpfsStorageService');

  OpfsStorageService._();

  @override
  String get name => 'OPFS';

  /// Detects if we need to use the worker-based approach (Safari)
  /// or can use the direct API (Chrome/Firefox).
  static Future<bool> get shouldUseWorker async {
    // Detect Safari by checking if createWritable is available
    final root = await web.window.navigator.storage.getDirectory().toDart;
    final testFileHandle = await root
        .getFileHandle(
          'test_${Random().nextInt(1000)}.txt',
          web.FileSystemGetFileOptions(create: true),
        )
        .toDart;
    try {
      final createWritable = testFileHandle.getProperty('createWritable'.toJS);
      return !createWritable.typeofEquals('function');
    } catch (e) {
      return true;
    } finally {
      try {
        await root.removeEntry(testFileHandle.name).toDart;
      } catch (e) {
        // Ignore
      }
    }
  }

  Future<web.FileSystemFileHandle> _getFileHandle(
    String path, [
    web.FileSystemGetFileOptions? options,
  ]) async {
    final root = await web.window.navigator.storage.getDirectory().toDart;
    return root
        .getFileHandle(path, options ?? web.FileSystemGetFileOptions())
        .toDart;
  }

  Future<web.File> _getFile(
    String path, [
    web.FileSystemGetFileOptions? options,
  ]) async {
    final fileHandle = await _getFileHandle(path, options);
    return fileHandle.getFile().toDart;
  }

  @override
  Future<Uint8List> readAsBytes(String path) async {
    final file = await _getFile(path);
    return file.readAsBytes();
  }

  @override
  Future<String> readAsString(String path) async {
    final file = await _getFile(path);
    return file.readAsString();
  }

  @override
  Future<void> writeAsBytes(String path, Uint8List data) async {
    final file = await _getFileHandle(
      path,
      web.FileSystemGetFileOptions(create: true),
    );
    final writable = await file.createWritable().toDart;
    await writable.write(data.toJS).toDart;
    await writable.close().toDart;
  }

  @override
  Future<void> writeAsString(String path, String data) async {
    final file = await _getFileHandle(
      path,
      web.FileSystemGetFileOptions(create: true),
    );
    final writable = await file.createWritable().toDart;
    await writable.write(data.toJS).toDart;
    await writable.close().toDart;
  }

  @override
  Future<void> delete(String path) async {
    try {
      final root = await web.window.navigator.storage.getDirectory().toDart;
      await root.removeEntry(path).toDart;
    } catch (e) {
      final jsEx = e as JSAny?;
      if (jsEx.isA<web.DOMException>() &&
          (jsEx as web.DOMException).name == 'NotFoundError') {
        // File might not exist, which is fine for delete
        _logger.fine('File $path not found for deletion', e);
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    final root = await web.window.navigator.storage.getDirectory().toDart;

    // Try the native remove() first for efficiency
    // https://developer.mozilla.org/en-US/docs/Web/API/FileSystemHandle/remove
    try {
      await root.remove(web.FileSystemRemoveOptions(recursive: true)).toDart;
      return;
    } catch (e) {
      _logger.finest('OPFS remove() not supported', e);
    }

    // Try to iterate over entries
    // https://developer.mozilla.org/en-US/docs/Web/API/FileSystemDirectoryHandle/entries
    try {
      final keysIterator =
          root.callMethod('keys'.toJS) as JSAsyncIterator<JSString>;
      await for (final path in keysIterator.stream.map((e) => e.toDart)) {
        _logger.finest('Removing OPFS entry: $path');
        await root
            .removeEntry(path, web.FileSystemRemoveOptions(recursive: true))
            .toDart;
      }
      return;
    } catch (e) {
      // entries() not supported
      _logger.finest('OPFS entries() not supported', e);
    }

    _logger.warning('Failed to clear OPFS storage');
  }
}

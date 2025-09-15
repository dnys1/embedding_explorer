import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

import '../../interop/common.dart';
import '../../util/file.dart';

abstract interface class StorageService {
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

  @override
  String get name => 'OPFS';

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
    final root = await web.window.navigator.storage.getDirectory().toDart;
    await root.removeEntry(path).toDart;
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
      _logger.warning(
        'OPFS remove() not supported, falling back to manual clear',
        e,
      );
    }

    // Try to iterate over entries
    // https://developer.mozilla.org/en-US/docs/Web/API/FileSystemDirectoryHandle/entries
    try {
      final keysIterator =
          root.callMethod('keys'.toJS) as JSAsyncIterator<JSString>;
      final keys = await keysIterator.collect();
      await Future.wait([
        for (final path in keys) root.removeEntry(path.toDart).toDart,
      ]);
    } catch (e) {
      // entries() not supported
      _logger.warning('OPFS entries() not supported, cannot clear storage', e);
    }
  }
}

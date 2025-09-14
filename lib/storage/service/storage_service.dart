import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../../util/file.dart';

abstract interface class StorageService {
  String get name;

  Future<Uint8List> read(String path);
  Future<void> write(String path, Uint8List data);
  Future<void> delete(String path);
  Future<void> clear();
}

final class OpfsStorageService implements StorageService {
  @override
  String get name => 'OPFS';

  @override
  Future<Uint8List> read(String path) async {
    final root = await web.window.navigator.storage.getDirectory().toDart;
    final file = await root.getFileHandle(path).toDart;
    final fileData = await file.getFile().toDart;
    return fileData.readAsBytes();
  }

  @override
  Future<void> write(String path, Uint8List data) async {
    final root = await web.window.navigator.storage.getDirectory().toDart;
    final file = await root
        .getFileHandle(path, web.FileSystemGetFileOptions(create: true))
        .toDart;
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
    final removeAll = root.getProperty<JSFunction?>('remove'.toJS);
    if (removeAll != null) {
      final promise =
          removeAll.callAsFunction(root, {'recursive': true}.jsify())
              as JSPromise<JSAny?>;
      await promise.toDart;
    } else {
      throw UnsupportedError('OPFS remove method is not supported');
    }
  }
}

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';
import 'package:web/web.dart' as web;

/// The JS `undefined` value.
@JS()
external Null get undefined;

extension type JSErrorOptions._(JSObject _) implements JSObject {
  external factory JSErrorOptions({JSAny? cause});

  external JSAny? cause;
}

@JS('Error')
extension type JSError._(JSObject _) implements JSObject {
  external JSError([String message, JSErrorOptions? options]);
  external JSError.at([String message, String? fileName, int? lineNumber]);

  external String get name;
  external String get message;
  external String? get stack;
}

extension JSBigIntExtensions on JSBigInt {
  int toInt() {
    return Int64.parseInt(toString()).toInt();
  }
}

extension RemoveFileSystemDirectoryHandle on web.FileSystemDirectoryHandle {
  @experimental
  external JSPromise<JSAny?> remove([web.FileSystemRemoveOptions options]);
}

extension type JSIteratorResult<T extends JSAny?>._(JSObject _)
    implements JSObject {
  external factory JSIteratorResult({bool done, T? value});

  external bool get done;
  external T? get value;
}

extension type JSAsyncIterator<T extends JSAny?>._(JSObject _)
    implements JSObject {
  external JSPromise<JSIteratorResult<T>> next();

  /// Collects all values from the async iterator into a list.
  Future<List<T>> collect() async {
    try {
      final result = await _arrayFromAsync<T>(this).toDart;
      return result.toDart;
    } catch (e) {
      final results = <T>[];
      for (;;) {
        final result = await next().toDart;
        if (result.done) {
          break;
        }
        results.add(result.value as T);
      }
      return results;
    }
  }
}

@experimental
@JS('Array.fromAsync')
external JSPromise<JSArray<T>> _arrayFromAsync<T extends JSAny?>(
  JSObject asyncIterator,
);

/// Checks if the current context is a web worker.
bool get kIsWorker {
  bool hasGlobal(String name) => globalContext[name].isDefinedAndNotNull;

  // In a worker context, DedicatedWorkerGlobalScope or SharedWorkerGlobalScope
  // should be available instead of Window
  return hasGlobal('DedicatedWorkerGlobalScope') ||
      hasGlobal('SharedWorkerGlobalScope') ||
      (hasGlobal('self') && !hasGlobal('window'));
}

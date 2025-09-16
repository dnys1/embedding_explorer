import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';
import 'package:web/web.dart' as web;

/// The JS `undefined` value.
@JS()
external Null get undefined;

@JS('Object.getOwnPropertyNames')
external JSArray<JSString> getOwnPropertyNames(JSObject obj);

extension JSObjectExtensions<T extends JSObject> on T {
  /// Returns a list of the object's own property names.
  List<String> get ownPropertyNames {
    return getOwnPropertyNames(this).toDart.map((e) => e.toDart).toList();
  }

  /// Merges this object with another, returning a new object with properties
  /// from both.
  ///
  /// Properties from [other] will overwrite those in this object if they share
  /// the same key
  T merge(T other) {
    final merged = web.window.structuredClone(this) as JSObject;
    for (final key in getOwnPropertyNames(other).toDart) {
      merged.setProperty(key, other.getProperty(key));
    }
    return merged as T;
  }
}

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

/// JavaScript TypeError - thrown when a value is not of the expected type
@JS('TypeError')
extension type JSTypeError._(JSObject _) implements JSError {
  external JSTypeError([String message]);
}

/// JavaScript fetch-related network error - not a standard constructor but occurs in fetch rejections
/// We'll create this for testing purposes but it's typically a DOMException
extension type JSNetworkError._(JSObject _) implements JSError {
  factory JSNetworkError([String? message]) =>
      JSDOMException(message ?? 'Network error', 'NetworkError')
          as JSNetworkError;
}

/// JavaScript AbortError - typically a DOMException with name 'AbortError'
extension type JSAbortError._(JSObject _) implements JSError {
  factory JSAbortError([String? message]) =>
      JSDOMException(message ?? 'Request aborted', 'AbortError')
          as JSAbortError;
}

/// JavaScript TimeoutError - typically a DOMException with name 'TimeoutError'
extension type JSTimeoutError._(JSObject _) implements JSError {
  factory JSTimeoutError([String? message]) =>
      JSDOMException(message ?? 'Operation timed out', 'TimeoutError')
          as JSTimeoutError;
}

/// JavaScript DOMException - base class for DOM-related exceptions
@JS('DOMException')
extension type JSDOMException._(JSObject _) implements JSError {
  external JSDOMException([String message, String? name]);
  external String get code;
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
  external T get value;
}

extension type JSAsyncIterator<T extends JSAny?>._(JSObject _)
    implements JSObject {
  external JSPromise<JSIteratorResult<T>> next();

  /// Convert the async iterator to a Dart Stream.
  Stream<T> get stream async* {
    for (;;) {
      final result = await next().toDart;
      if (result.done) {
        break;
      }
      yield result.value;
    }
  }
}

/// Checks if the current context is a web worker.
bool get kIsWorker {
  bool hasGlobal(String name) => globalContext[name].isDefinedAndNotNull;

  // In a worker context, DedicatedWorkerGlobalScope or SharedWorkerGlobalScope
  // should be available instead of Window
  return hasGlobal('DedicatedWorkerGlobalScope') ||
      hasGlobal('SharedWorkerGlobalScope') ||
      (hasGlobal('self') && !hasGlobal('window'));
}

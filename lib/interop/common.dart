import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:fixnum/fixnum.dart';

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

/// Checks if the current context is a web worker.
bool get kIsWorker {
  try {
    // In a worker context, DedicatedWorkerGlobalScope or SharedWorkerGlobalScope
    // should be available instead of Window
    return globalContext['DedicatedWorkerGlobalScope'].isDefinedAndNotNull ||
        globalContext['SharedWorkerGlobalScope'].isDefinedAndNotNull ||
        (globalContext['self'].isDefinedAndNotNull &&
            globalContext['window'].isUndefinedOrNull);
  } catch (e) {
    return false;
  }
}

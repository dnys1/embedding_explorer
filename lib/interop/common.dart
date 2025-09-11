import 'dart:js_interop';

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
}

extension JSBigIntExtensions on JSBigInt {
  int toInt() {
    return Int64.parseInt(toString()).toInt();
  }
}

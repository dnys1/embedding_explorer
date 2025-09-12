import 'dart:js_interop';

import 'package:meta/meta.dart';

@internal
extension JSBoxOrCastObject on Object {
  JSAny? get serialized {
    return jsify()!;
  }
}

@internal
extension JSBoxOrCastList on List<Object> {
  JSArray<JSAny> get serialized {
    return map((e) => e.serialized).nonNulls.toList().toJS;
  }
}

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

extension FileFutures on File {
  Future<Uint8List> readAsBytes() {
    final reader = FileReader();
    final completer = Completer<Uint8List>();
    reader.onload = (Event event) {
      final data = reader.result;
      if (data.isA<JSArrayBuffer>()) {
        completer.complete((data as JSArrayBuffer).toDart.asUint8List());
      } else {
        completer.completeError(
          StateError('Expected result to be JSArrayBuffer, got $data'),
        );
      }
    }.toJS;
    reader.onerror = (Event event) {
      completer.completeError(
        StateError('Failed to read file: ${reader.error?.message}'),
      );
    }.toJS;
    reader.readAsArrayBuffer(this);
    return completer.future;
  }

  Future<String> readAsString() {
    final completer = Completer<String>();
    final reader = FileReader();
    reader.onload = (Event event) {
      final data = reader.result;
      if (data.isA<JSString>()) {
        completer.complete((data as JSString).toDart);
      } else {
        completer.completeError(
          StateError('Expected result to be String, got $data'),
        );
      }
    }.toJS;
    reader.onerror = (Event event) {
      completer.completeError(
        StateError('Failed to read file: ${reader.error?.message}'),
      );
    }.toJS;
    reader.readAsText(this);
    return completer.future;
  }
}

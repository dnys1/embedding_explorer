import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:built_value/serializer.dart';

class BytesSerializer implements PrimitiveSerializer<Uint8List> {
  const BytesSerializer();

  @override
  String get wireName => 'Bytes';

  @override
  Iterable<Type> get types => [Uint8List, Uint8List(0).runtimeType];

  @override
  Uint8List deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    if ((serialized as JSAny?).isA<JSUint8Array>()) {
      return (serialized as JSUint8Array).toDart;
    }
    return switch (serialized) {
      final Uint8List value => value,
      final List<int> value => Uint8List.fromList(value),
      _ => throw ArgumentError(
        'Cannot deserialize to Uint8List from type ${serialized.runtimeType}',
      ),
    };
  }

  @override
  Object serialize(
    Serializers serializers,
    Uint8List object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final transfer = Zone.current[#transfer] as List<Object>;
    final serialized = object.toJS;
    transfer.add(serialized.getProperty('buffer'.toJS)!);
    return serialized;
  }
}

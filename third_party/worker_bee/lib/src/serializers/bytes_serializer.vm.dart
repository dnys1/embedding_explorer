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
    return object;
  }
}

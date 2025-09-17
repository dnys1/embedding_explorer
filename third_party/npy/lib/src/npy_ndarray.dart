import 'dart:typed_data';

import 'package:npy/src/npy_bytetransformer.dart';
import 'package:npy/src/npy_exception.dart';
import 'package:npy/src/npy_header.dart';
import 'package:npy/src/npy_parser.dart';

class NdArray<T> {
  const NdArray({required this.headerSection, required this.data});

  final NpyHeaderSection headerSection;
  final List data;

  factory NdArray.fromList(
    List list, {
    NpyDType? dtype,
    NpyEndian? endian,
    bool? fortranOrder,
  }) => NdArray<T>(
    headerSection: NpyHeaderSection.fromList(
      list,
      dtype: dtype,
      endian: endian,
      fortranOrder: fortranOrder,
    ),
    data: list,
  );

  static Future<NdArray<T>> load<T>(
    Uint8List bytes, {
    required String path,
    int? bufferSize,
  }) async {
    if (T != dynamic && T != double && T != int && T != bool) {
      throw NpyInvalidNpyTypeException('Unsupported NdArray type: $T');
    }

    final stream = Stream.value(
      bytes,
    ).transform(ByteTransformer(bufferSize: bufferSize));

    final List<int> buffer = [];
    final parser = NpyParser();

    try {
      await for (final chunk in stream) {
        buffer.addAll(chunk);

        parser
          ..checkMagicString(buffer)
          ..getVersion(buffer)
          ..getHeaderSize(buffer)
          ..getHeader(buffer)
          ..buildHeaderSection()
          ..getData(buffer);

        if (parser.isCompleted) {
          return NdArray(
            headerSection: parser.headerSection!,
            data: parser.data,
          );
        }
      }
    } on NpyParseException {
      rethrow;
    }
    throw NpyParseException("Error parsing '$path' as an NPY file.");
  }

  Uint8List get asBytes {
    final buffer = BytesBuilder();
    buffer.add(headerSection.asBytes);
    buffer.add(dataBytes);
    return buffer.takeBytes();
  }

  List<int> get dataBytes {
    final List<int> bytes = [];
    final dtype = headerSection.header.dtype;
    late final Endian endian;

    switch (dtype.endian) {
      case NpyEndian.little:
        endian = Endian.little;
      case NpyEndian.big:
        endian = Endian.big;
      case NpyEndian.native:
        endian = Endian.host;
      default:
        if (dtype.itemSize != 1) {
          throw const NpyInvalidEndianException(
            'Endian must be specified for item size > 1.',
          );
        }
    }

    final flattenedData = headerSection.header.fortranOrder
        ? flattenFortranOrder<T>(data, shape: headerSection.header.shape)
        : flattenCOrder<T>(data);

    for (final element in flattenedData) {
      final byteData = ByteData(dtype.itemSize);
      if (element is int) {
        switch (dtype.type) {
          case NpyType.int:
            switch (dtype.itemSize) {
              case 8:
                byteData.setInt64(0, element, endian);
              case 4:
                byteData.setInt32(0, element, endian);
              case 2:
                byteData.setInt16(0, element, endian);
              case 1:
                byteData.setInt8(0, element);
              default:
                throw NpyInvalidDTypeException(
                  'Unsupported item size: ${dtype.itemSize}',
                );
            }
          case NpyType.uint:
            switch (dtype.itemSize) {
              case 8:
                byteData.setUint64(0, element, endian);
              case 4:
                byteData.setUint32(0, element, endian);
              case 2:
                byteData.setUint16(0, element, endian);
              case 1:
                byteData.setUint8(0, element);
              default:
                throw NpyInvalidDTypeException(
                  'Unsupported item size: ${dtype.itemSize}',
                );
            }
          default:
            throw NpyInvalidNpyTypeException(
              'Unsupported NpyType: ${dtype.type}',
            );
        }
      } else if (element is double) {
        switch (dtype.itemSize) {
          case 8:
            byteData.setFloat64(0, element, endian);
          case 4:
            byteData.setFloat32(0, element, endian);
          default:
            throw NpyInvalidDTypeException(
              'Unsupported NpyType: ${dtype.type}',
            );
        }
      } else if (element is bool) {
        byteData.setUint8(0, element ? 1 : 0);
      } else {
        throw NpyInvalidNpyTypeException(
          'Unsupported NdArray type: ${element.runtimeType}',
        );
      }
      bytes.addAll(Uint8List.fromList(byteData.buffer.asUint8List()));
    }

    return bytes;
  }
}

List<T> flattenCOrder<T>(List list) {
  final result = <T>[];
  for (final element in list) {
    element is List
        ? result.addAll(flattenCOrder<T>(element))
        : result.add(element as T);
  }
  return result;
}

List<T> flattenFortranOrder<T>(List list, {required List<int> shape}) {
  final result = <T>[];
  if (shape.isNotEmpty) {
    _flattenFortranOrderRecursive<T>(
      list,
      shape,
      List.filled(shape.length, 0),
      shape.length - 1,
      (item) => result.add(item),
    );
  }
  return result;
}

void _flattenFortranOrderRecursive<T>(
  List list,
  List<int> shape,
  List<int> indices,
  int depth,
  void Function(T) addItem,
) {
  T getNestedItemRecursive(List list, List<int> indices, int depth) =>
      depth == indices.length - 1
      ? list[indices[depth]] as T
      : getNestedItemRecursive(
          list[indices[depth]] as List,
          indices,
          depth + 1,
        );

  T getNestedItem(List list, List<int> indices) =>
      getNestedItemRecursive(list, indices, 0);

  if (depth == 0) {
    for (int i = 0; i < shape[depth]; i++) {
      indices[depth] = i;
      addItem(getNestedItem(list, indices));
    }
  } else {
    for (int i = 0; i < shape[depth]; i++) {
      indices[depth] = i;
      _flattenFortranOrderRecursive<T>(
        list,
        shape,
        indices,
        depth - 1,
        addItem,
      );
    }
  }
}

/// Convenience function to save a [List] to the given [path] in NPY format.
/// Alternatively use [NdArray.save].
Future<Uint8List> save(
  List list, {
  NpyDType? dtype,
  NpyEndian? endian,
  bool? fortranOrder,
}) async => NdArray.fromList(
  list,
  dtype: dtype,
  endian: endian,
  fortranOrder: fortranOrder,
).asBytes;

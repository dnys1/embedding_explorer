import 'dart:math';
import 'dart:typed_data';

import 'package:npy/src/npy_exception.dart';
import 'package:npy/src/npy_header.dart';

class NpyParser<T> {
  NpyParser({
    bool hasPassedMagicStringCheck = false,
    NpyVersion? version,
    int? headerSize,
    NpyHeader? header,
  })  : _hasPassedMagicStringCheck = hasPassedMagicStringCheck,
        _version = version,
        _headerSize = headerSize,
        _header = header;

  bool _hasPassedMagicStringCheck;
  NpyVersion? _version;
  int? _headerSize;
  NpyHeader? _header;

  bool get hasPassedMagicStringCheck => _hasPassedMagicStringCheck;
  NpyVersion? get version => _version;
  int? get headerSize => _headerSize;
  NpyHeader? get header => _header;

  NpyHeaderSection? _headerSection;
  final List<T> _rawData = [];
  List _data = const [];
  bool _isCompleted = false;
  int _dataOffset = 0;
  int _elementsRead = 0;

  NpyHeaderSection? get headerSection => _headerSection;
  List get rawData => _rawData;
  List get data => _data;
  bool get isCompleted => _isCompleted;

  void checkMagicString(List<int> buffer) {
    if (_hasPassedMagicStringCheck || buffer.length < magicString.length) {
      return;
    }
    for (int i = 0; i < magicString.length; i++) {
      if (magicString.codeUnitAt(i) != buffer[i]) {
        throw const NpyParseException('Invalid magic string.');
      }
    }
    _hasPassedMagicStringCheck = true;
  }

  void getVersion(List<int> buffer) {
    if (_version != null ||
        buffer.length < magicString.length + NpyVersion.numberOfReservedBytes) {
      return;
    }
    _version = NpyVersion.fromBytes(
      buffer.skip(magicString.length).take(NpyVersion.numberOfReservedBytes),
    );
  }

  void getHeaderSize(List<int> buffer) {
    const bytesTaken = magicString.length + NpyVersion.numberOfReservedBytes;
    if (_headerSize != null ||
        _version == null ||
        buffer.length < bytesTaken + _version!.numberOfHeaderBytes) return;
    final relevantBytes =
        buffer.skip(bytesTaken).take(_version!.numberOfHeaderBytes).toList();
    _headerSize = _version!.major == 1
        ? littleEndian16ToInt(relevantBytes)
        : littleEndian32ToInt(relevantBytes);
  }

  void getHeader(List<int> buffer) {
    if (_header != null || _version == null || _headerSize == null) return;
    final bytesTaken = magicString.length +
        NpyVersion.numberOfReservedBytes +
        _version!.numberOfHeaderBytes;
    if (buffer.length < bytesTaken + _headerSize!) return;
    _header = NpyHeader.fromBytes(
      buffer.skip(bytesTaken).take(_headerSize!).toList(),
    );
  }

  void buildHeaderSection() {
    if (_headerSection != null ||
        _header == null ||
        _headerSize == null ||
        _version == null) return;
    _headerSection = NpyHeaderSection(
      version: _version!,
      headerSize: _headerSize!,
      header: _header!,
    );
  }

  void getData(List<int> buffer) {
    if (_isCompleted ||
        _headerSection == null ||
        _header == null ||
        _headerSize == null ||
        _version == null ||
        !_hasPassedMagicStringCheck) {
      return;
    }

    if (_header!.shape.isEmpty) {
      _isCompleted = true;
      return;
    }

    final itemSize = _header!.dtype.itemSize;
    _dataOffset = _headerSection!.size + _elementsRead * itemSize;
    final totalElements = _header!.shape.reduce((a, b) => a * b);
    final remainingElements = totalElements - _elementsRead;
    final elementsInBuffer = (buffer.length - _dataOffset) ~/ itemSize;
    final elementsToProcess = min(remainingElements, elementsInBuffer);

    _rawData.addAll(
      parseByteData<T>(
        buffer.sublist(
          _dataOffset,
          _dataOffset + elementsToProcess * itemSize,
        ),
        header!.dtype,
      ),
    );
    _elementsRead += elementsToProcess;

    if (_elementsRead != totalElements) return;
    _data = reshape<T>(
      _rawData,
      _header!.shape,
      fortranOrder: _header!.fortranOrder,
    );
    _isCompleted = true;
  }
}

/// Parse byte data according to the [dtype] and return a one-dimensional,
/// flattened [List] of values.
List<T> parseByteData<T>(List<int> bytes, NpyDType dtype) {
  final numberOfElements = bytes.length ~/ dtype.itemSize;

  late final List<T> result;
  switch (dtype.type) {
    case NpyType.float:
      result = List.filled(numberOfElements, .0 as T);
    case NpyType.int:
    case NpyType.uint:
      result = List.filled(numberOfElements, 0 as T);
    case NpyType.boolean:
      result = List.filled(numberOfElements, false as T);
    default:
      throw NpyInvalidDTypeException('Unsupported dtype: $dtype');
  }

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

  final byteData = ByteData.view(Uint8List.fromList(bytes).buffer);

  for (int i = 0; i < numberOfElements; i++) {
    switch (dtype.type) {
      case NpyType.float:
        switch (dtype.itemSize) {
          case 8:
            result[i] = byteData.getFloat64(i * 8, endian) as T;
          case 4:
            result[i] = byteData.getFloat32(i * 4, endian) as T;
          default:
            throw NpyInvalidDTypeException(
              'Unsupported item size: ${dtype.itemSize}',
            );
        }
      case NpyType.int:
        switch (dtype.itemSize) {
          case 8:
            result[i] = byteData.getInt64(i * 8, endian) as T;
          case 4:
            result[i] = byteData.getInt32(i * 4, endian) as T;
          case 2:
            result[i] = byteData.getInt16(i * 2, endian) as T;
          case 1:
            result[i] = byteData.getInt8(i) as T;
          default:
            throw NpyInvalidDTypeException(
              'Unsupported item size: ${dtype.itemSize}',
            );
        }
      case NpyType.uint:
        switch (dtype.itemSize) {
          case 8:
            result[i] = byteData.getUint64(i * 8, endian) as T;
          case 4:
            result[i] = byteData.getUint32(i * 4, endian) as T;
          case 2:
            result[i] = byteData.getUint16(i * 2, endian) as T;
          case 1:
            result[i] = byteData.getUint8(i) as T;
          default:
            throw NpyInvalidDTypeException(
              'Unsupported item size: ${dtype.itemSize}',
            );
        }
      case NpyType.boolean:
        result[i] = (byteData.getUint8(i) == 1) as T;
      default:
        throw NpyInvalidDTypeException('Unsupported dtype: $dtype');
    }
  }

  return result;
}

/// Reshape a one-dimensional [List] according to the given [shape] and order
/// (C or Fortran).
List reshape<T>(
  List<T> oneDimensionalList,
  List<int> shape, {
  bool fortranOrder = false,
}) {
  if (oneDimensionalList.isEmpty) return const [];
  if (shape.isEmpty) throw const NpyParseException('Shape must not be empty.');
  if (oneDimensionalList.length != shape.reduce((a, b) => a * b)) {
    throw const NpyParseException(
      'The total number of elements does not equal the product of the shape dimensions.',
    );
  }

  if (shape.length == 1) return oneDimensionalList;

  int getIndex(List<int> indices) {
    int index = 0;
    int stride = 1;
    if (fortranOrder) {
      for (int i = 0; i < shape.length; i++) {
        index += indices[i] * stride;
        stride *= shape[i];
      }
    } else {
      for (int i = shape.length - 1; i >= 0; i--) {
        index += indices[i] * stride;
        stride *= shape[i];
      }
    }
    return index;
  }

  List result = oneDimensionalList;
  final indices = List.filled(shape.length, 0);

  void reshapeRecursive(int dimension) {
    if (dimension == shape.length - 1) {
      result = List.generate(shape[dimension], (i) {
        indices[dimension] = i;
        return oneDimensionalList[getIndex(indices)];
      });
    } else {
      result = List.generate(shape[dimension], (i) {
        indices[dimension] = i;
        reshapeRecursive(dimension + 1);
        return result;
      });
    }
  }

  reshapeRecursive(0);
  return result;
}

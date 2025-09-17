import 'dart:convert';
import 'dart:typed_data';

import 'package:npy/src/npy_exception.dart';

class NpyHeaderSection {
  const NpyHeaderSection({
    required this.version,
    required this.header,
    required this.headerSize,
  });

  final NpyVersion version;
  final int headerSize;
  final NpyHeader header;

  factory NpyHeaderSection.fromList(
    List list, {
    NpyDType? dtype,
    NpyEndian? endian,
    bool? fortranOrder,
  }) =>
      NpyHeaderSection.fromHeader(
        NpyHeader.fromList(
          list,
          dtype: dtype,
          endian: endian,
          fortranOrder: fortranOrder,
        ),
      );

  factory NpyHeaderSection.fromHeader(NpyHeader header) {
    final headerSize = header.asBytes.length;
    final firstVersionSizeWithoutPadding = magicString.length +
        NpyVersion.numberOfReservedBytes +
        NpyVersion.numberOfHeaderSizeBytesV1 +
        headerSize +
        newLineOffset;
    final paddingSize = getPaddingSize(firstVersionSizeWithoutPadding);
    final version = NpyVersion.fromString(
      header.string,
      headerSize + paddingSize + _newLineInt,
    );

    return NpyHeaderSection(
      version: version,
      headerSize: headerSize,
      header: header,
    );
  }

  /// Returns the size of the entire header section.
  int get size =>
      magicString.length +
      NpyVersion.numberOfReservedBytes +
      version.numberOfHeaderBytes +
      headerSize;

  /// Returns entire header section represented by a List of bytes that includes
  /// the magic string, the version, the number of bytes describing the header
  /// length, the header length, and the header, padded with spaces and
  /// terminated with a newline character to be a multiple of 64 bytes. It takes
  /// the header as a String and leaves it unchanged.
  List<int> get asBytes => [
        ...magicString.codeUnits,
        ...version.asBytes,
        ...headerSizeAsBytes,
        ...header.asBytes,
      ];

  /// Returns a list of bytes that encodes the [headerSize]. The list length
  /// depends on the major version.
  List<int> get headerSizeAsBytes {
    if (version.major == 1) {
      assert(headerSize <= NpyVersion.maxFirstVersionSize);
      return (ByteData(NpyVersion.numberOfHeaderSizeBytesV1)
            ..setUint16(0, headerSize, Endian.little))
          .buffer
          .asUint8List();
    }

    assert(headerSize <= NpyVersion.maxHigherVersionSize);
    return (ByteData(NpyVersion.numberOfHeaderSizeBytesHigherVersions)
          ..setUint32(0, headerSize, Endian.little))
        .buffer
        .asUint8List();
  }
}

/// Returns the number of padding bytes needed to make the given [size] a
/// multiple of 64.
int getPaddingSize(int size) => (64 - (size % 64)) % 64;

/// The version of the numpy file. It is composed of a major and minor version.
/// Supported major version are currently 1, 2 and 3. Supported minor version
/// are currently 0.
class NpyVersion {
  const NpyVersion({this.major = 1, this.minor = 0});

  final int major;
  final int minor;

  /// The number of bytes reserved in the header section to describe the
  /// version.
  static const numberOfReservedBytes = 2;
  static const numberOfHeaderSizeBytesV1 = 2;
  static const numberOfHeaderSizeBytesHigherVersions = 4;
  static const maxFirstVersionSize = 65535;
  static const maxHigherVersionSize = 4294967295;
  static const lastAsciiCodeUnit = 127;
  static const _supportedMajorVersions = {1, 2, 3};
  static const _supportedMinorVersions = {0};

  factory NpyVersion.fromBytes(Iterable<int> bytes) {
    assert(bytes.length == NpyVersion.numberOfReservedBytes);

    if (!_supportedMajorVersions.contains(bytes.elementAt(0))) {
      throw NpyInvalidVersionException(
        'Unsupported major version: ${bytes.elementAt(0)}',
      );
    } else if (!_supportedMinorVersions.contains(bytes.elementAt(1))) {
      throw NpyInvalidVersionException(
        'Unsupported minor version: ${bytes.elementAt(1)}',
      );
    }

    return NpyVersion(major: bytes.elementAt(0), minor: bytes.elementAt(1));
  }

  /// Returns a version instance depending on the given [string] and the total
  /// header size.
  factory NpyVersion.fromString(String string, int totalHeaderSize) {
    return NpyVersion(
      major: cannotBeAsciiEncoded(string)
          ? 3
          : totalHeaderSize <= maxFirstVersionSize
              ? 1
              : 2,
    );
  }

  /// True if [string] cannot be ASCII encoded.
  static bool cannotBeAsciiEncoded(String string) =>
      string.codeUnits.any((codeUnit) => codeUnit > lastAsciiCodeUnit);

  /// Returns the version as a list of bytes.
  Uint8List get asBytes => Uint8List.fromList([major, minor]);

  /// Returns the number of bytes used to store the header length depending on
  /// the major version.
  int get numberOfHeaderBytes => major == 1
      ? NpyVersion.numberOfHeaderSizeBytesV1
      : NpyVersion.numberOfHeaderSizeBytesHigherVersions;
}

class NpyHeader<T> {
  const NpyHeader({
    required this.dtype,
    required this.fortranOrder,
    required this.shape,
    required this.string,
    required this.paddingSize,
  });

  final NpyDType dtype;
  final bool fortranOrder;
  final List<int> shape;
  final String string;
  final int paddingSize;

  factory NpyHeader.buildPadding({
    required NpyDType dtype,
    required bool fortranOrder,
    required List<int> shape,
    required String string,
  }) {
    final sizeWithoutPadding = magicString.length +
        NpyVersion.numberOfReservedBytes +
        NpyVersion.numberOfHeaderSizeBytesV1 +
        string.length +
        newLineOffset;

    return NpyHeader(
      dtype: dtype,
      fortranOrder: fortranOrder,
      shape: shape,
      string: string,
      paddingSize: getPaddingSize(sizeWithoutPadding),
    );
  }

  factory NpyHeader.buildString({
    required NpyDType dtype,
    required bool fortranOrder,
    required List<int> shape,
  }) {
    final shapeString = shape.isEmpty
        ? '()'
        : shape.length == 1
            ? '(${shape.first},)'
            : '(${shape.join(', ')})';
    final string =
        "{'descr': '$dtype', 'fortran_order': ${fortranOrder ? 'True' : 'False'}, 'shape': $shapeString, }";
    return NpyHeader.buildPadding(
      dtype: dtype,
      fortranOrder: fortranOrder,
      shape: shape,
      string: string,
    );
  }

  static String getDictString(
    String headerString,
    String key, [
    String openingDelimiter = "'",
    String closingDelimiter = "'",
  ]) {
    final keyIndex = headerString.indexOf(key);
    if (keyIndex == -1) {
      throw NpyInvalidHeaderException("Missing '$key' field.");
    }

    final firstIndex =
        headerString.indexOf(openingDelimiter, keyIndex + key.length + 1);
    if (firstIndex == -1) {
      throw NpyInvalidHeaderException(
        "Missing opening delimiter '$openingDelimiter' of '$key' field.",
      );
    }

    final lastIndex = headerString.indexOf(closingDelimiter, firstIndex + 1);
    if (lastIndex == -1) {
      throw NpyInvalidHeaderException(
        "Missing closing delimiter '$closingDelimiter' of '$key' field.",
      );
    }

    return headerString.substring(firstIndex + 1, lastIndex);
  }

  factory NpyHeader.fromBytes(List<int> headerBytes) {
    final lastCharIndex = headerBytes.lastIndexWhere(
      (byte) => byte != _blankSpaceInt && byte != _newLineInt,
    );
    final headerString =
        String.fromCharCodes(headerBytes.sublist(0, lastCharIndex + 1));

    final descr = getDictString(headerString, 'descr');
    final fortranOrderString =
        getDictString(headerString, 'fortran_order', ':', ',');
    final shapeString = getDictString(headerString, 'shape', '(', ')');

    late final bool fortranOrder;
    switch (fortranOrderString.trim()) {
      case 'True':
        fortranOrder = true;
      case 'False':
        fortranOrder = false;
      default:
        throw NpyInvalidHeaderException(
          "Invalid 'fortran_order' field: '$fortranOrderString'",
        );
    }

    late final List<int> shape;
    if (shapeString.isEmpty) {
      shape = const [];
    } else {
      shape = shapeString
          .split(',')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => int.parse(s.trim()))
          .toList();
    }

    return NpyHeader(
      dtype: NpyDType.fromString(descr),
      fortranOrder: fortranOrder,
      shape: shape,
      string: headerString,
      paddingSize: headerBytes.length - lastCharIndex - 1 - newLineOffset,
    );
  }

  factory NpyHeader.fromList(
    List list, {
    NpyDType? dtype,
    NpyEndian? endian,
    bool? fortranOrder,
    List<int> shape = const [],
  }) {
    assert(
      endian == null || dtype == null,
      'Do not specify both dtype and endian. Define endian within dtype.',
    );

    if (list.isEmpty) {
      return NpyHeader.buildString(
        dtype: dtype ?? NpyDType.fromArgs(endian: endian),
        fortranOrder: fortranOrder ?? false,
        shape: shape.isEmpty ? shape : [...shape, list.length],
      );
    }

    final updatedShape = [...shape, list.length];
    late final NpyType obtainedType;
    final firstElement = list.first;

    if (firstElement is int) {
      obtainedType = dtype?.type == NpyType.uint ? NpyType.uint : NpyType.int;
    } else if (firstElement is double) {
      obtainedType = NpyType.float;
    } else if (firstElement is bool) {
      obtainedType = NpyType.boolean;
    } else if (firstElement is List) {
      return NpyHeader.fromList(
        list.first as List,
        dtype: dtype,
        endian: endian,
        fortranOrder: fortranOrder,
        shape: updatedShape,
      );
    } else {
      throw NpyInvalidNpyTypeException(
        'Unsupported input type: ${firstElement.runtimeType}',
      );
    }

    return NpyHeader.buildString(
      dtype: NpyDType.fromArgs(
        endian: endian ??
            dtype?.endian ??
            (obtainedType == NpyType.boolean
                ? NpyEndian.none
                : NpyEndian.getNative()),
        itemSize: dtype?.itemSize ??
            (obtainedType == NpyType.boolean
                ? NpyDType.defaultBoolItemSize
                : NpyDType.defaultItemSize),
        type: obtainedType,
      ),
      fortranOrder: fortranOrder ?? false,
      shape: updatedShape,
    );
  }

  /// Returns the header string as a List<int> of bytes.
  List<int> get asBytes => [
        ...utf8.encode(string),
        ...List.filled(paddingSize, _blankSpaceInt),
        _newLineInt,
      ];
}

/// The ASCII code for a space character.
const _blankSpaceInt = 32;

/// The ASCII code for a newline character.
const _newLineInt = 10;

/// The header section is terminated with a single byte that is a newline
/// character.
const newLineOffset = 1;

/// Marks the beginning of an NPY file.
const magicString = '\x93NUMPY';

/// The supported input types for the NdArray class.
const supportedInputTypes = {int, double};

/// Converts the given [bytes] to a 16-bit unsigned integer in little-endian
/// byte order.
int littleEndian16ToInt(List<int> bytes) {
  assert(bytes.length == 2);
  return ByteData.view(Uint8List.fromList(bytes).buffer)
      .getUint16(0, Endian.little);
}

/// Converts the given [bytes] to a 32-bit unsigned integer in little-endian
/// byte order.
int littleEndian32ToInt(List<int> bytes) {
  assert(bytes.length == 4);
  return ByteData.view(Uint8List.fromList(bytes).buffer)
      .getUint32(0, Endian.little);
}

class NpyDType {
  NpyDType.float64({NpyEndian? endian})
      : endian = endian ?? NpyEndian.getNative(),
        type = NpyType.float,
        itemSize = 8;

  NpyDType.float32({NpyEndian? endian})
      : endian = endian ?? NpyEndian.getNative(),
        type = NpyType.float,
        itemSize = 4;

  NpyDType.int64({NpyEndian? endian})
      : endian = endian ?? NpyEndian.getNative(),
        type = NpyType.int,
        itemSize = 8;

  NpyDType.int32({NpyEndian? endian})
      : endian = endian ?? NpyEndian.getNative(),
        type = NpyType.int,
        itemSize = 4;

  NpyDType.int16({NpyEndian? endian})
      : endian = endian ?? NpyEndian.getNative(),
        type = NpyType.int,
        itemSize = 2;

  const NpyDType.int8()
      : endian = NpyEndian.none,
        type = NpyType.int,
        itemSize = 1;

  NpyDType.uint64({NpyEndian? endian})
      : endian = endian ?? NpyEndian.getNative(),
        type = NpyType.uint,
        itemSize = 8;

  NpyDType.uint32({NpyEndian? endian})
      : endian = endian ?? NpyEndian.getNative(),
        type = NpyType.uint,
        itemSize = 4;

  NpyDType.uint16({NpyEndian? endian})
      : endian = endian ?? NpyEndian.getNative(),
        type = NpyType.uint,
        itemSize = 2;

  const NpyDType.uint8()
      : endian = NpyEndian.none,
        type = NpyType.uint,
        itemSize = 1;

  const NpyDType.boolean()
      : endian = NpyEndian.none,
        type = NpyType.boolean,
        itemSize = 1;

  const NpyDType.string({required this.itemSize})
      : endian = NpyEndian.none,
        type = NpyType.string;

  final NpyEndian endian;
  final NpyType type;
  final int itemSize;

  /// The default item size for various types except boolean.
  static const defaultItemSize = 8;

  /// The default item size for the boolean type.
  static const defaultBoolItemSize = 1;

  factory NpyDType.fromArgs({NpyType? type, int? itemSize, NpyEndian? endian}) {
    switch (type) {
      case NpyType.float:
      case null:
        switch (itemSize) {
          case 8:
          case null:
            return NpyDType.float64(endian: endian);
          case 4:
            return NpyDType.float32(endian: endian);
          default:
            throw NpyInvalidDTypeException(
              'Unsupported float item size or none provided: $itemSize',
            );
        }
      case NpyType.int:
        switch (itemSize) {
          case 8:
          case null:
            return NpyDType.int64(endian: endian);
          case 4:
            return NpyDType.int32(endian: endian);
          case 2:
            return NpyDType.int16(endian: endian);
          case 1:
            assert(
              endian == null || endian == NpyEndian.none,
              'Int8 endian must be none',
            );
            return const NpyDType.int8();
          default:
            throw NpyInvalidDTypeException(
              'Unsupported int item size: $itemSize',
            );
        }
      case NpyType.uint:
        switch (itemSize) {
          case 8:
          case null:
            return NpyDType.uint64(endian: endian);
          case 4:
            return NpyDType.uint32(endian: endian);
          case 2:
            return NpyDType.uint16(endian: endian);
          case 1:
            assert(
              endian == null || endian == NpyEndian.none,
              'Uint8 endian must be none',
            );
            return const NpyDType.uint8();
          default:
            throw NpyInvalidDTypeException(
              'Unsupported uint item size: $itemSize',
            );
        }
      case NpyType.boolean:
        assert(
          endian == null || endian == NpyEndian.none,
          'Boolean endian must not be provided or none',
        );
        assert(
          itemSize == null || itemSize == 1,
          'Boolean item size must not be provided or 1',
        );
        return const NpyDType.boolean();
      case NpyType.string:
        if (itemSize == null) {
          throw const NpyInvalidDTypeException(
            'Item size must be specified for strings.',
          );
        }
        return NpyDType.string(itemSize: itemSize);
      default:
        throw NpyInvalidNpyTypeException('Unsupported NpyType: $type');
    }
  }

  factory NpyDType.fromString(String string) {
    if (string.length < 3) {
      throw NpyInvalidDTypeException(
        "'descr' field has insufficient length: '$string'",
      );
    }
    if (string == '|b1') return const NpyDType.boolean();

    try {
      return NpyDType.fromArgs(
        endian: NpyEndian.fromChar(string[0]),
        type: NpyType.fromChar(string[1]),
        itemSize: int.parse(string.substring(2)),
      );
    } catch (e) {
      throw NpyInvalidDTypeException("Invalid 'descr' field: '$string': $e");
    }
  }

  @override
  String toString() => type == NpyType.boolean
      ? '|b1'
      : '${endian.char}${type.chars.first}$itemSize';
}

/// The endianness of the NPY file. It is represented by a single character.
/// Single-byte data types are always [NpyEndian.none].
enum NpyEndian {
  little('<'),
  big('>'),
  native('='),
  none('|');

  const NpyEndian(this.char);

  /// The char representation of the [NpyEndian].
  final String char;

  /// Get the native endianness of the current platform.
  factory NpyEndian.getNative() =>
      ByteData.view(Uint16List.fromList([1]).buffer).getInt8(0) == 1
          ? NpyEndian.little
          : NpyEndian.big;

  /// Converts the given [char] to an [NpyEndian].
  factory NpyEndian.fromChar(String char) {
    assert(char.length == 1);
    return NpyEndian.values.firstWhere(
      (order) => order.char == char,
      orElse: () =>
          throw NpyInvalidEndianException('Unsupported endian: $char'),
    );
  }
}

/// The supported data types of the NPY file. A data type is represented by one
/// or multiple single-character representations. If more than one
/// representation exists, the first one is used for saving. This package aims
/// to gradually increase support for more data types.
enum NpyType {
  boolean(['?']),
  byte(['b']),
  uByte(['B']),
  int(['i']),
  uint(['u']),
  float(['f']),
  complex(['c']),
  timeDelta(['m']),
  dateTime(['M']),
  object(['O']),
  string(['S', 'a']),
  unicode(['U']),
  voidType(['V']);

  const NpyType(this.chars);

  /// A list of single characters that represent an [NpyType].
  final List<String> chars;

  /// Converts the given [char] to an [NpyType].
  factory NpyType.fromChar(String char) {
    assert(char.length == 1);
    return NpyType.values.firstWhere(
      (type) => type.chars.contains(char),
      orElse: () => throw NpyInvalidNpyTypeException('Unsupported type: $char'),
    );
  }
}

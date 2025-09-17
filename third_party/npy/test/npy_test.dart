import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:npy/npy.dart';
import 'package:test/test.dart';

void main() {
  const epsilon = 1e-6;
  bool almostEqual(double a, double b, [double tolerance = epsilon]) =>
      (a - b).abs() < tolerance;
  bool listAlmostEquals(List a, List<double> b, [double tolerance = epsilon]) {
    if (a.length != b.length) return false;
    final mappedList = List<double>.from(
      a.map((e) => e is double ? e : throw 'Not a double'),
    );
    for (int i = 0; i < a.length; i++) {
      if (!almostEqual(mappedList[i], b[i], tolerance)) return false;
    }
    return true;
  }

  group('ByteTransformer:', () {
    test('Empty list', () {
      final controller = StreamController<List<int>>();
      controller.add([]);
      expect(
        controller.stream.transform(const ByteTransformer()),
        emitsInOrder([[]]),
      );
      controller.close();
    });
    test('Empty list with given buffer size', () {
      final controller = StreamController<List<int>>();
      controller.add([]);
      expect(
        controller.stream.transform(const ByteTransformer(bufferSize: 1)),
        emitsInOrder([[]]),
      );
      controller.close();
    });
    test('Single entry', () {
      final controller = StreamController<List<int>>();
      controller.add([1]);
      expect(
        controller.stream.transform(const ByteTransformer()),
        emitsInOrder([
          [1],
        ]),
      );
      controller.close();
    });
    test('Two entries, untransformed', () {
      final controller = StreamController<List<int>>();
      controller.add([1, 2]);
      expect(
        controller.stream.transform(const ByteTransformer()),
        emitsInOrder([
          [1, 2],
        ]),
      );
      controller.close();
    });
    test('Two entries, transformed to single bytes', () {
      final controller = StreamController<List<int>>();
      controller.add([1, 2]);
      expect(
        controller.stream.transform(const ByteTransformer(bufferSize: 1)),
        emitsInOrder([
          [1],
          [2],
        ]),
      );
      controller.close();
    });
    test('Two entries, buffersize equals list length', () {
      final controller = StreamController<List<int>>();
      controller.add([1, 2]);
      expect(
        controller.stream.transform(const ByteTransformer(bufferSize: 2)),
        emitsInOrder([
          [1, 2],
        ]),
      );
      controller.close();
    });
    test('Two entries, buffersize exceeds list length', () {
      final controller = StreamController<List<int>>();
      controller.add([1, 2]);
      expect(
        controller.stream.transform(const ByteTransformer(bufferSize: 3)),
        emitsInOrder([
          [1, 2],
        ]),
      );
      controller.close();
    });
    test('Transform with remaining entries', () {
      final controller = StreamController<List<int>>();
      controller.add([1, 2, 3]);
      expect(
        controller.stream.transform(const ByteTransformer(bufferSize: 2)),
        emitsInOrder([
          [1, 2],
          [3],
        ]),
      );
      controller.close();
    });
    test('Transform without remaining entries', () {
      final controller = StreamController<List<int>>();
      controller.add([1, 2, 3, 4]);
      expect(
        controller.stream.transform(const ByteTransformer(bufferSize: 2)),
        emitsInOrder([
          [1, 2],
          [3, 4],
        ]),
      );
      controller.close();
    });
    test('Multiple emits, single bytes', () {
      final controller = StreamController<List<int>>();
      controller
        ..add([1])
        ..add([2]);
      expect(
        controller.stream.transform(const ByteTransformer(bufferSize: 1)),
        emitsInOrder([
          [1],
          [2],
        ]),
      );
      controller.close();
    });
    test('Random emits, bufferSize 2', () {
      final controller = StreamController<List<int>>();
      controller
        ..add([1, 2])
        ..add([])
        ..add([3])
        ..add([4, 5, 6, 7]);
      expect(
        controller.stream.transform(const ByteTransformer(bufferSize: 2)),
        emitsInOrder([
          [1, 2],
          [3, 4],
          [5, 6],
          [7],
        ]),
      );
      controller.close();
    });
  });

  group('Check magic string:', () {
    test('Valid code units', () {
      final parser = NpyParser();
      expect(parser.hasPassedMagicStringCheck, false);
      parser.checkMagicString([147, 78, 85, 77, 80, 89]);
      expect(parser.hasPassedMagicStringCheck, true);
    });
    test('Additional bytes', () {
      final parser = NpyParser();
      expect(parser.hasPassedMagicStringCheck, false);
      parser.checkMagicString([147, 78, 85, 77, 80, 89, 1, 2, 3]);
      expect(parser.hasPassedMagicStringCheck, true);
    });
    test('Insufficient bytes', () {
      final parser = NpyParser();
      expect(parser.hasPassedMagicStringCheck, false);
      parser.checkMagicString([147, 78, 85, 77, 80]);
      expect(parser.hasPassedMagicStringCheck, false);
    });
    test('Second run returns early with wrong magic string', () {
      final parser = NpyParser();
      expect(parser.hasPassedMagicStringCheck, false);
      parser.checkMagicString([147, 78, 85, 77, 80, 89]);
      expect(parser.hasPassedMagicStringCheck, true);
      parser.checkMagicString([1, 2, 3, 4, 5, 6]);
      expect(parser.hasPassedMagicStringCheck, true);
    });
    test('Invalid first byte', () {
      final parser = NpyParser();
      expect(parser.hasPassedMagicStringCheck, false);
      expect(
        () => parser.checkMagicString([146, 78, 85, 77, 80, 89]),
        throwsA(const TypeMatcher<NpyParseException>()),
      );
      expect(parser.hasPassedMagicStringCheck, false);
    });
    test('Invalid last byte', () {
      final parser = NpyParser();
      expect(parser.hasPassedMagicStringCheck, false);
      expect(
        () => parser.checkMagicString([147, 78, 85, 77, 80, 87]),
        throwsA(const TypeMatcher<NpyParseException>()),
      );
      expect(parser.hasPassedMagicStringCheck, false);
    });
  });

  group('Parse version:', () {
    test('Create instance with major: 1, minor: 0', () {
      final version = NpyVersion.fromBytes([1, 0]);
      expect(version.major, 1);
      expect(version.minor, 0);
      expect(version.numberOfHeaderBytes, 2);
    });
    test('Create instance with major: 2, minor: 0', () {
      final version = NpyVersion.fromBytes([2, 0]);
      expect(version.major, 2);
      expect(version.minor, 0);
      expect(version.numberOfHeaderBytes, 4);
    });
    test('Create instance with major: 3, minor: 0', () {
      final version = NpyVersion.fromBytes([3, 0]);
      expect(version.major, 3);
      expect(version.minor, 0);
      expect(version.numberOfHeaderBytes, 4);
    });
    test(
      'Insufficient byte length',
      () => expect(
        () => NpyVersion.fromBytes([1]),
        throwsA(isA<AssertionError>()),
      ),
    );
    test(
      'Exceeded byte length',
      () => expect(
        () => NpyVersion.fromBytes([1, 0, 0]),
        throwsA(isA<AssertionError>()),
      ),
    );
    test('Create instance: Invalid major version: 0', () {
      expect(
        () => NpyVersion.fromBytes([0, 0]),
        throwsA(const TypeMatcher<NpyInvalidVersionException>()),
      );
    });
    test('Create instance: Invalid major version: 4', () {
      expect(
        () => NpyVersion.fromBytes([4, 0]),
        throwsA(const TypeMatcher<NpyInvalidVersionException>()),
      );
    });
    test('Create instance: Invalid minor version', () {
      expect(
        () => NpyVersion.fromBytes([1, 1]),
        throwsA(const TypeMatcher<NpyInvalidVersionException>()),
      );
    });
    test('Parse major: 1, minor: 0', () {
      final parser = NpyParser();
      parser.getVersion([...magicString.codeUnits, 1, 0]);
      expect(parser.version?.major, 1);
      expect(parser.version?.minor, 0);
      expect(parser.version?.numberOfHeaderBytes, 2);
    });
    test('Parse major: 2, minor: 0', () {
      final parser = NpyParser();
      parser.getVersion([...magicString.codeUnits, 2, 0]);
      expect(parser.version?.major, 2);
      expect(parser.version?.minor, 0);
      expect(parser.version?.numberOfHeaderBytes, 4);
    });
    test('Parse major: 3, minor: 0', () {
      final parser = NpyParser();
      parser.getVersion([...magicString.codeUnits, 3, 0]);
      expect(parser.version?.major, 3);
      expect(parser.version?.minor, 0);
      expect(parser.version?.numberOfHeaderBytes, 4);
    });
    test('Invalid major version in parse: 4', () {
      expect(
        () => NpyParser().getVersion([...magicString.codeUnits, 4, 0]),
        throwsA(const TypeMatcher<NpyInvalidVersionException>()),
      );
    });
    test('Invalid major version in parse: 0', () {
      expect(
        () => NpyParser().getVersion([...magicString.codeUnits, 0, 0]),
        throwsA(const TypeMatcher<NpyInvalidVersionException>()),
      );
    });
    test('Invalid minor version in parse', () {
      expect(
        () => NpyParser().getVersion([...magicString.codeUnits, 1, 1]),
        throwsA(const TypeMatcher<NpyInvalidVersionException>()),
      );
    });
    test('Additional bytes', () {
      final parser = NpyParser();
      parser.getVersion([...magicString.codeUnits, 1, 0, 0]);
      expect(parser.version?.major, 1);
      expect(parser.version?.minor, 0);
      expect(parser.version?.numberOfHeaderBytes, 2);
    });
    test('Insufficient bytes', () {
      final parser = NpyParser();
      parser.getVersion([...magicString.codeUnits, 1]);
      expect(parser.version, null);
    });
    test('Second run gets ignored', () {
      final parser = NpyParser();
      parser.getVersion([...magicString.codeUnits, 1, 0]);
      expect(parser.version?.major, 1);
      expect(parser.version?.minor, 0);
      expect(parser.version?.numberOfHeaderBytes, 2);
      parser.getVersion([...magicString.codeUnits, 2, 0]);
      expect(parser.version?.major, 1);
      expect(parser.version?.minor, 0);
      expect(parser.version?.numberOfHeaderBytes, 2);
    });
  });

  group('Parse header length:', () {
    test('[0, 0]', () => expect(littleEndian16ToInt([0, 0]), 0));
    test('[1, 0]', () => expect(littleEndian16ToInt([1, 0]), 1));
    test('[0, 1]', () => expect(littleEndian16ToInt([0, 1]), 256));
    test('[2, 1]', () => expect(littleEndian16ToInt([2, 1]), 258));
    test('[1, 2]', () => expect(littleEndian16ToInt([1, 2]), 513));
    test(
      '[4, 3, 2, 1]',
      () => expect(littleEndian32ToInt([4, 3, 2, 1]), 16909060),
    );
    test(
      '[1, 2, 3, 4]',
      () => expect(littleEndian32ToInt([1, 2, 3, 4]), 67305985),
    );
    test(
      'Less than 2 bytes',
      () => expect(
        () => littleEndian16ToInt([1]),
        throwsA(isA<AssertionError>()),
      ),
    );
    test(
      'Exceed 2 bytes',
      () => expect(
        () => littleEndian16ToInt([1, 2, 3]),
        throwsA(isA<AssertionError>()),
      ),
    );
    test(
      'Less than 4 bytes',
      () => expect(
        () => littleEndian32ToInt([1, 2, 3]),
        throwsA(isA<AssertionError>()),
      ),
    );
    test(
      'Exceed 4 bytes',
      () => expect(
        () => littleEndian32ToInt([1, 2, 3, 3, 4]),
        throwsA(isA<AssertionError>()),
      ),
    );
    test('[2, 1] through parser', () {
      final parser = NpyParser(version: const NpyVersion());
      parser.getHeaderSize([
        ...magicString.codeUnits,
        ...parser.version!.asBytes,
        2,
        1,
      ]);
      expect(parser.headerSize, 258);
    });
    test('[1, 2] through parser', () {
      final parser = NpyParser(version: const NpyVersion());
      parser.getHeaderSize([
        ...magicString.codeUnits,
        ...parser.version!.asBytes,
        1,
        2,
      ]);
      expect(parser.headerSize, 513);
    });
    test('Ignore parsing less than 2 bytes', () {
      final parser = NpyParser(version: const NpyVersion());
      parser.getHeaderSize([
        ...magicString.codeUnits,
        ...parser.version!.asBytes,
        1,
      ]);
      expect(parser.headerSize, null);
    });
    test('Ignore additional bytes after 2', () {
      final parser = NpyParser(version: const NpyVersion());
      parser.getHeaderSize([
        ...magicString.codeUnits,
        ...parser.version!.asBytes,
        1,
        2,
        3,
      ]);
      expect(parser.headerSize, 513);
    });
    test('[4, 3, 2, 1] through parser', () {
      final parser = NpyParser(version: const NpyVersion(major: 2));
      parser.getHeaderSize([
        ...magicString.codeUnits,
        ...parser.version!.asBytes,
        4,
        3,
        2,
        1,
      ]);
      expect(parser.headerSize, 16909060);
    });
    test('[1, 2, 3, 4] through parser', () {
      final parser = NpyParser(version: const NpyVersion(major: 2));
      parser.getHeaderSize([
        ...magicString.codeUnits,
        ...parser.version!.asBytes,
        1,
        2,
        3,
        4,
      ]);
      expect(parser.headerSize, 67305985);
    });
    test('Ignore parsing less than 4 bytes', () {
      final parser = NpyParser(version: const NpyVersion(major: 2));
      parser.getHeaderSize([
        ...magicString.codeUnits,
        ...parser.version!.asBytes,
        1,
        2,
        3,
      ]);
      expect(parser.headerSize, null);
    });
    test('Ignore additional bytes after 4', () {
      final parser = NpyParser(version: const NpyVersion(major: 2));
      parser.getHeaderSize([
        ...magicString.codeUnits,
        ...parser.version!.asBytes,
        1,
        2,
        3,
        4,
        5,
      ]);
      expect(parser.headerSize, 67305985);
    });
    test('Ignore second run', () {
      final parser = NpyParser(version: const NpyVersion());
      parser.getHeaderSize([
        ...magicString.codeUnits,
        ...parser.version!.asBytes,
        1,
        2,
      ]);
      expect(parser.headerSize, 513);
      parser.getHeaderSize([
        ...magicString.codeUnits,
        ...parser.version!.asBytes,
        3,
        3,
      ]);
      expect(parser.headerSize, 513);
    });
    test('Return early if version not set', () {
      final parser = NpyParser();
      parser.getHeaderSize([
        ...magicString.codeUnits,
        147,
        78,
        85,
        77,
        80,
        89,
        1,
        0,
        1,
        2,
      ]);
      expect(parser.headerSize, null);
    });
    test('[0x56, 0x78]', () {
      final bytes = [0x56, 0x78];
      expect(littleEndian16ToInt(bytes), 0x7856);
      expect(littleEndian16ToInt(bytes), 30806);
    });
    test('[0x78, 0x56]', () {
      final bytes = [0x78, 0x56];
      expect(littleEndian16ToInt(bytes), 0x5678);
      expect(littleEndian16ToInt(bytes), 22136);
    });
    test('[0x12, 0x34, 0x56, 0x78]', () {
      final bytes = [0x12, 0x34, 0x56, 0x78];
      expect(littleEndian32ToInt(bytes), 0x78563412);
      expect(littleEndian32ToInt(bytes), 2018915346);
    });
    test('[0x78, 0x56, 0x34, 0x12]', () {
      final bytes = [0x78, 0x56, 0x34, 0x12];
      expect(littleEndian32ToInt(bytes), 0x12345678);
      expect(littleEndian32ToInt(bytes), 305419896);
    });
  });

  group('Parse NpyEndian:', () {
    test(
      'Little endian',
      () => expect(NpyEndian.fromChar('<'), NpyEndian.little),
    );
    test('Big endian', () => expect(NpyEndian.fromChar('>'), NpyEndian.big));
    test(
      'Native byte',
      () => expect(NpyEndian.fromChar('='), NpyEndian.native),
    );
    test('None', () => expect(NpyEndian.fromChar('|'), NpyEndian.none));
    test('Invalid endian', () {
      expect(
        () => NpyEndian.fromChar('!'),
        throwsA(const TypeMatcher<NpyInvalidEndianException>()),
      );
    });
    test(
      'Empty string',
      () =>
          expect(() => NpyEndian.fromChar(''), throwsA(isA<AssertionError>())),
    );
    test(
      'Two characters',
      () => expect(
        () => NpyEndian.fromChar('<>'),
        throwsA(isA<AssertionError>()),
      ),
    );
  });

  test('Get native NpyEndian', () {
    switch (Endian.host) {
      case Endian.little:
        expect(NpyEndian.getNative(), NpyEndian.little);
      case Endian.big:
        expect(NpyEndian.getNative(), NpyEndian.big);
      default:
        fail('Unknown endian');
    }
  });

  group('Parse NpyType:', () {
    test('Boolean type', () => expect(NpyType.fromChar('?'), NpyType.boolean));
    test('Byte type', () => expect(NpyType.fromChar('b'), NpyType.byte));
    test(
      'Unsigned byte type',
      () => expect(NpyType.fromChar('B'), NpyType.uByte),
    );
    test('Integer type', () => expect(NpyType.fromChar('i'), NpyType.int));
    test(
      'Unsigned integer type',
      () => expect(NpyType.fromChar('u'), NpyType.uint),
    );
    test('Float type', () => expect(NpyType.fromChar('f'), NpyType.float));
    test('Complex type', () => expect(NpyType.fromChar('c'), NpyType.complex));
    test(
      'Time delta type',
      () => expect(NpyType.fromChar('m'), NpyType.timeDelta),
    );
    test(
      'Date time type',
      () => expect(NpyType.fromChar('M'), NpyType.dateTime),
    );
    test('Object type', () => expect(NpyType.fromChar('O'), NpyType.object));
    test(
      "String type, 'S' representation",
      () => expect(NpyType.fromChar('S'), NpyType.string),
    );
    test(
      "String type, 'a' representation",
      () => expect(NpyType.fromChar('a'), NpyType.string),
    );
    test('Unicode type', () => expect(NpyType.fromChar('U'), NpyType.unicode));
    test('Void type', () => expect(NpyType.fromChar('V'), NpyType.voidType));
    test('Invalid type', () {
      expect(
        () => NpyType.fromChar('x'),
        throwsA(const TypeMatcher<NpyInvalidNpyTypeException>()),
      );
    });
    test(
      'Empty string',
      () => expect(() => NpyType.fromChar(''), throwsA(isA<AssertionError>())),
    );
    test(
      'Two characters',
      () =>
          expect(() => NpyType.fromChar('fc'), throwsA(isA<AssertionError>())),
    );
  });

  group('Parse NpyDType:', () {
    test('<f8', () {
      final dtype = NpyDType.fromString('<f8');
      expect(dtype.endian, NpyEndian.little);
      expect(dtype.type, NpyType.float);
      expect(dtype.itemSize, 8);
    });
    test('>i4', () {
      final dtype = NpyDType.fromString('>i4');
      expect(dtype.endian, NpyEndian.big);
      expect(dtype.type, NpyType.int);
      expect(dtype.itemSize, 4);
    });
    test('|S10', () {
      final dtype = NpyDType.fromString('|S10');
      expect(dtype.endian, NpyEndian.none);
      expect(dtype.type, NpyType.string);
      expect(dtype.itemSize, 10);
    });
    test('=u2', () {
      final dtype = NpyDType.fromString('=u2');
      expect(dtype.endian, NpyEndian.native);
      expect(dtype.type, NpyType.uint);
      expect(dtype.itemSize, 2);
    });
    test('|b1', () {
      final dtype = NpyDType.fromString('|b1');
      expect(dtype.endian, NpyEndian.none);
      expect(dtype.type, NpyType.boolean);
      expect(dtype.itemSize, 1);
    });
    test(
      '|b2',
      () => expect(
        () => NpyDType.fromString('|b2'),
        throwsA(const TypeMatcher<NpyInvalidDTypeException>()),
      ),
    );
    test('Empty string', () {
      expect(
        () => NpyDType.fromString(''),
        throwsA(const TypeMatcher<NpyInvalidDTypeException>()),
      );
    });
    test('Unsufficient length', () {
      expect(
        () => NpyDType.fromString('<f'),
        throwsA(const TypeMatcher<NpyInvalidDTypeException>()),
      );
    });
    test('Invalid descr', () {
      expect(
        () => NpyDType.fromString('f>8'),
        throwsA(const TypeMatcher<NpyInvalidDTypeException>()),
      );
    });
    test('Invalid endian', () {
      expect(
        () => NpyDType.fromString('!f8'),
        throwsA(const TypeMatcher<NpyInvalidDTypeException>()),
      );
    });
    test('Invalid type', () {
      expect(
        () => NpyDType.fromString('|X8'),
        throwsA(const TypeMatcher<NpyInvalidDTypeException>()),
      );
    });
    test('Invalid digit', () {
      expect(
        () => NpyDType.fromString('>ff'),
        throwsA(const TypeMatcher<NpyInvalidDTypeException>()),
      );
    });
  });

  group('NpyDType.fromArgs:', () {
    test('No type provided', () {
      final dtype = NpyDType.fromArgs();
      expect(dtype.type, NpyType.float);
      expect(dtype.itemSize, 8);
      expect(dtype.endian, NpyEndian.getNative());
    });
    test('No type but endian provided', () {
      final dtype = NpyDType.fromArgs(endian: NpyEndian.big);
      expect(dtype.type, NpyType.float);
      expect(dtype.itemSize, 8);
      expect(dtype.endian, NpyEndian.big);
    });
    test('No type but item size provided', () {
      final dtype = NpyDType.fromArgs(itemSize: 4);
      expect(dtype.type, NpyType.float);
      expect(dtype.itemSize, 4);
      expect(dtype.endian, NpyEndian.getNative());
    });
    test('No type but both endian and item size provided', () {
      final dtype = NpyDType.fromArgs(itemSize: 4, endian: NpyEndian.big);
      expect(dtype.type, NpyType.float);
      expect(dtype.itemSize, 4);
      expect(dtype.endian, NpyEndian.big);
    });
    test('No type but invalid item size provided', () {
      expect(
        () => NpyDType.fromArgs(itemSize: 2),
        throwsA(const TypeMatcher<NpyInvalidDTypeException>()),
      );
    });
    test('Invalid float itemSize', () {
      expect(
        () => NpyDType.fromArgs(type: NpyType.float, itemSize: 2),
        throwsA(const TypeMatcher<NpyInvalidDTypeException>()),
      );
    });
    test('Valid float64, little endian', () {
      final dtype = NpyDType.fromArgs(
        type: NpyType.float,
        itemSize: 8,
        endian: NpyEndian.little,
      );
      expect(dtype.type, NpyType.float);
      expect(dtype.itemSize, 8);
      expect(dtype.endian, NpyEndian.little);
    });
    test('Valid int16', () {
      final dtype = NpyDType.fromArgs(type: NpyType.int, itemSize: 2);
      expect(dtype.type, NpyType.int);
      expect(dtype.itemSize, 2);
      expect(dtype.endian, NpyEndian.getNative());
    });
    test('Valid uint32', () {
      final dtype = NpyDType.fromArgs(
        type: NpyType.uint,
        itemSize: 4,
        endian: NpyEndian.big,
      );
      expect(dtype.type, NpyType.uint);
      expect(dtype.itemSize, 4);
      expect(dtype.endian, NpyEndian.big);
    });
    test('Invalid int itemSize', () {
      expect(
        () => NpyDType.fromArgs(type: NpyType.int, itemSize: 3),
        throwsA(const TypeMatcher<NpyInvalidDTypeException>()),
      );
    });
    test('Invalid int8 endian', () {
      expect(
        () => NpyDType.fromArgs(
          type: NpyType.int,
          itemSize: 1,
          endian: NpyEndian.big,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
    test('Invalid uint itemSize', () {
      expect(
        () => NpyDType.fromArgs(type: NpyType.uint, itemSize: 0),
        throwsA(const TypeMatcher<NpyInvalidDTypeException>()),
      );
    });
    test('Invalid uint8 endian', () {
      expect(
        () => NpyDType.fromArgs(
          type: NpyType.uint,
          itemSize: 1,
          endian: NpyEndian.big,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
    test('Valid boolean', () {
      final dtype = NpyDType.fromArgs(type: NpyType.boolean);
      expect(dtype.type, NpyType.boolean);
      expect(dtype.itemSize, 1);
      expect(dtype.endian, NpyEndian.none);
    });
    test('Invalid boolean itemSize', () {
      expect(
        () => NpyDType.fromArgs(type: NpyType.boolean, itemSize: 2),
        throwsA(isA<AssertionError>()),
      );
    });
    test('Invalid boolean endian', () {
      expect(
        () => NpyDType.fromArgs(type: NpyType.boolean, endian: NpyEndian.big),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('NpyDType to String:', () {
    test('float64, native endian', () {
      switch (Endian.host) {
        case Endian.little:
          expect(NpyDType.float64().toString(), '<f8');
        case Endian.big:
          expect(NpyDType.float64().toString(), '>f8');
        default:
          fail('Unknown endian');
      }
    });
    test('float64, native endian, fromArgs', () {
      switch (Endian.host) {
        case Endian.little:
          expect(
            NpyDType.fromArgs(type: NpyType.float, itemSize: 8).toString(),
            '<f8',
          );
        case Endian.big:
          expect(
            NpyDType.fromArgs(type: NpyType.float, itemSize: 8).toString(),
            '>f8',
          );
        default:
          fail('Unknown endian');
      }
    });
    test(
      '>f4',
      () => expect(NpyDType.float32(endian: NpyEndian.big).toString(), '>f4'),
    );
    test(
      '<i8',
      () => expect(NpyDType.int64(endian: NpyEndian.little).toString(), '<i8'),
    );
    test('native i4', () {
      switch (Endian.host) {
        case Endian.little:
          expect(NpyDType.int32().toString(), '<i4');
        case Endian.big:
          expect(NpyDType.int32().toString(), '>i4');
        default:
          fail('Unknown endian');
      }
    });
    test(
      '>i2',
      () => expect(NpyDType.int16(endian: NpyEndian.big).toString(), '>i2'),
    );
    test('|i1', () => expect(const NpyDType.int8().toString(), '|i1'));
    test(
      '>u8',
      () => expect(NpyDType.uint64(endian: NpyEndian.big).toString(), '>u8'),
    );
    test(
      '<u4',
      () => expect(NpyDType.uint32(endian: NpyEndian.little).toString(), '<u4'),
    );
    test('native u2', () {
      switch (Endian.host) {
        case Endian.little:
          expect(NpyDType.uint16().toString(), '<u2');
        case Endian.big:
          expect(NpyDType.uint16().toString(), '>u2');
        default:
          fail('Unknown endian');
      }
    });
    test('|u1', () => expect(const NpyDType.uint8().toString(), '|u1'));
    test('|b1', () => expect(const NpyDType.boolean().toString(), '|b1'));
  });

  group('Get shape:', () {
    test('float64, []', () {
      final header = NpyHeader.fromList([]);
      expect(header.shape, []);
      expect(header.dtype.type, NpyType.float);
    });
    test('int64, [1]', () {
      final header = NpyHeader.fromList([42]);
      expect(header.shape, [1]);
      expect(header.dtype.type, NpyType.int);
    });
    test('int32, [2]', () {
      final header = NpyHeader.fromList([42, 35], dtype: NpyDType.int32());
      expect(header.shape, [2]);
      expect(header.dtype.type, NpyType.int);
      expect(header.dtype.itemSize, 4);
    });
    test('float32, [2], big endian', () {
      final header = NpyHeader.fromList([
        0.1,
        2.3,
      ], dtype: NpyDType.float32(endian: NpyEndian.big));
      expect(header.shape, [2]);
      expect(header.dtype.type, NpyType.float);
      expect(header.dtype.itemSize, 4);
      expect(header.dtype.endian, NpyEndian.big);
    });
    test('uint16, [2, 3]', () {
      final header = NpyHeader.fromList([
        [1, 2, 3],
        [4, 5, 6],
      ], dtype: NpyDType.uint16());
      expect(header.shape, [2, 3]);
      expect(header.dtype.type, NpyType.uint);
      expect(header.dtype.itemSize, 2);
    });
    test('float64, [3, 2, 1]', () {
      final header = NpyHeader.fromList([
        [
          [1.0],
          [2.1],
        ],
        [
          [3.2],
          [4.3],
        ],
        [
          [5.4],
          [6.5],
        ],
      ]);
      expect(header.shape, [3, 2, 1]);
      expect(header.dtype.type, NpyType.float);
      expect(header.dtype.itemSize, 8);
    });
    test('int8, [2, 0]', () {
      final header = NpyHeader.fromList([[], []], dtype: const NpyDType.int8());
      expect(header.shape, [2, 0]);
      expect(header.dtype.type, NpyType.int);
      expect(header.dtype.itemSize, 1);
    });
    test('bool, [3]', () {
      final header = NpyHeader.fromList([true, false, true]);
      expect(header.shape, [3]);
    });
    test('bool, [2, 3]', () {
      final header = NpyHeader.fromList([
        [true, false, true],
        [false, true, false],
      ]);
      expect(header.shape, [2, 3]);
    });
    test('bool, [2, 3], fortran order', () {
      final header = NpyHeader.fromList([
        [true, true, true],
        [false, false, false],
      ], fortranOrder: true);
      expect(header.shape, [2, 3]);
      expect(header.fortranOrder, true);
    });
    test('String throws error', () {
      expect(
        () => NpyHeader.fromList(['hi']),
        throwsA(const TypeMatcher<NpyInvalidNpyTypeException>()),
      );
    });
  });

  group('Parse NpyHeader:', () {
    test('Empty header', () {
      expect(
        () => NpyHeader.fromBytes(''.codeUnits),
        throwsA(const TypeMatcher<NpyInvalidHeaderException>()),
      );
    });
    test('Only curly braces', () {
      expect(
        () => NpyHeader.fromBytes('{}'.codeUnits),
        throwsA(const TypeMatcher<NpyInvalidHeaderException>()),
      );
    });
    test('Something random', () {
      expect(
        () => NpyHeader.fromBytes('xyz'.codeUnits),
        throwsA(const TypeMatcher<NpyInvalidHeaderException>()),
      );
    });
    test('<f8, False, (3,)', () {
      final header = NpyHeader.fromBytes(
        "{'descr': '<f8', 'fortran_order': False, 'shape': (3,)}".codeUnits,
      );
      expect(header.dtype.endian, NpyEndian.little);
      expect(header.dtype.type, NpyType.float);
      expect(header.dtype.itemSize, 8);
      expect(header.fortranOrder, false);
      expect(header.shape, [3]);
    });
    test('<f8, True, (3,)', () {
      final header = NpyHeader.fromBytes(
        "{'descr': '<f8', 'fortran_order': True, 'shape': (3,)}".codeUnits,
      );
      expect(header.dtype.endian, NpyEndian.little);
      expect(header.dtype.type, NpyType.float);
      expect(header.dtype.itemSize, 8);
      expect(header.fortranOrder, true);
      expect(header.shape, [3]);
    });
    test('<f8, null, (3,)', () {
      expect(
        () => NpyHeader.fromBytes(
          "{'descr': '<f8', 'fortran_order': null, 'shape': (3,)}".codeUnits,
        ),
        throwsA(const TypeMatcher<NpyInvalidHeaderException>()),
      );
    });
    test('>i4, True, (3,)', () {
      final header = NpyHeader.fromBytes(
        "{'descr': '>i4', 'fortran_order': True, 'shape': (3,)}".codeUnits,
      );
      expect(header.dtype.endian, NpyEndian.big);
      expect(header.dtype.type, NpyType.int);
      expect(header.dtype.itemSize, 4);
      expect(header.fortranOrder, true);
      expect(header.shape, [3]);
    });
    test('|S200, True, (3,)', () {
      final header = NpyHeader.fromBytes(
        "{'descr': '|S200', 'fortran_order': True, 'shape': (3,)}".codeUnits,
      );
      expect(header.dtype.endian, NpyEndian.none);
      expect(header.dtype.type, NpyType.string);
      expect(header.dtype.itemSize, 200);
      expect(header.fortranOrder, true);
      expect(header.shape, [3]);
    });
    test('<x4, True, (3,)', () {
      expect(
        () => NpyHeader.fromBytes(
          "{'descr': '<x4', 'fortran_order': True, 'shape': (3,)}".codeUnits,
        ),
        throwsA(const TypeMatcher<NpyInvalidHeaderException>()),
      );
    });
    test('Missing descr', () {
      expect(
        () => NpyHeader.fromBytes(
          "{'fortran_order': True, 'shape': (3,)}".codeUnits,
        ),
        throwsA(const TypeMatcher<NpyInvalidHeaderException>()),
      );
    });
    test('Missing fortran_order', () {
      expect(
        () => NpyHeader.fromBytes("{'descr': '<f8', 'shape': (3,)}".codeUnits),
        throwsA(const TypeMatcher<NpyInvalidHeaderException>()),
      );
    });
    test('Missing shape', () {
      expect(
        () => NpyHeader.fromBytes(
          "{'descr': '<f8', 'fortran_order': True}".codeUnits,
        ),
        throwsA(const TypeMatcher<NpyInvalidHeaderException>()),
      );
    });
    test('<f8, True, ()', () {
      final header = NpyHeader.fromBytes(
        "{'descr': '<f8', 'fortran_order': True, 'shape': ()}".codeUnits,
      );
      expect(header.dtype.endian, NpyEndian.little);
      expect(header.dtype.type, NpyType.float);
      expect(header.dtype.itemSize, 8);
      expect(header.fortranOrder, true);
      expect(header.shape, []);
    });
    test('<f8, True, (2, 3)', () {
      final header = NpyHeader.fromBytes(
        "{'descr': '<f8', 'fortran_order': True, 'shape': (2, 3)}".codeUnits,
      );
      expect(header.dtype.endian, NpyEndian.little);
      expect(header.dtype.type, NpyType.float);
      expect(header.dtype.itemSize, 8);
      expect(header.fortranOrder, true);
      expect(header.shape, [2, 3]);
    });
    test('<f8, True, (2, 3) with extra whitespace', () {
      final header = NpyHeader.fromBytes(
        "{' descr' :  '<f8 ' ,  ' fortran_order ':  True ,  ' shape' :  ( 2 , 3 ) }"
            .codeUnits,
      );
      expect(header.dtype.endian, NpyEndian.little);
      expect(header.dtype.type, NpyType.float);
      expect(header.dtype.itemSize, 8);
      expect(header.fortranOrder, true);
      expect(header.shape, [2, 3]);
    });
    test('<f8, True, (2, 3) with whitespace and trailing comma', () {
      final header = NpyHeader.fromBytes(
        "{'descr' :'<f8 ' , ' fortran_order ':  True ,  ' shape' :  ( 2 , 3 ) , }"
            .codeUnits,
      );
      expect(header.dtype.endian, NpyEndian.little);
      expect(header.dtype.type, NpyType.float);
      expect(header.dtype.itemSize, 8);
      expect(header.fortranOrder, true);
      expect(header.shape, [2, 3]);
    });
    test('<f8, True, (2, 3, 4)', () {
      final header = NpyHeader.fromBytes(
        "{'descr': '<f8', 'fortran_order': True, 'shape': (2, 3, 4)}".codeUnits,
      );
      expect(header.dtype.endian, NpyEndian.little);
      expect(header.dtype.type, NpyType.float);
      expect(header.dtype.itemSize, 8);
      expect(header.fortranOrder, true);
      expect(header.shape, [2, 3, 4]);
    });
    test('Invalid shape', () {
      expect(
        () => NpyHeader.fromBytes(
          "{'descr': '<f8', 'fortran_order': True, 'shape': [2, 3]}".codeUnits,
        ),
        throwsA(const TypeMatcher<NpyInvalidHeaderException>()),
      );
    });
  });

  group('Build header section and get data:', () {
    test('Gradually build 1d float list', () {
      final parser = NpyParser();
      List<int> buffer = const [];
      buffer = [magicString.codeUnits.first];
      parser.checkMagicString(buffer);
      expect(parser.hasPassedMagicStringCheck, false);
      buffer = [...buffer, ...magicString.codeUnits.sublist(1)];
      parser.checkMagicString(buffer);
      expect(parser.hasPassedMagicStringCheck, true);
      buffer = [...buffer, 1];
      parser.getVersion(buffer);
      expect(parser.version, null);
      buffer = [...buffer, 0];
      parser.getVersion(buffer);
      expect(parser.version?.major, 1);
      expect(parser.version?.minor, 0);
      expect(parser.version?.numberOfHeaderBytes, 2);
      expect(parser.headerSize, null);
      final headerSection = NpyHeaderSection.fromList([1.0, -1.0, 2.0]);
      buffer = [...buffer, headerSection.headerSizeAsBytes.first];
      parser.getHeaderSize(buffer);
      expect(parser.headerSize, null);
      buffer = [...buffer, ...headerSection.headerSizeAsBytes.sublist(1)];
      parser.getHeaderSize(buffer);
      expect(parser.headerSize, 118);
      buffer = [...buffer, headerSection.header.asBytes.first];
      parser.getHeader(buffer);
      expect(parser.header, null);
      buffer = [...buffer, ...headerSection.header.asBytes.sublist(1)];
      parser.getHeader(buffer);
      expect(parser.header?.shape, [3]);
      expect(parser.header?.asBytes.length, 118);
      expect(parser.headerSection, null);
      parser.buildHeaderSection();
      expect(parser.headerSection?.version.major, 1);
      expect(parser.headerSection?.version.minor, 0);
      expect(parser.headerSection?.version.numberOfHeaderBytes, 2);
      expect(parser.headerSection?.headerSize, 118);
      expect(parser.headerSection?.header.shape, [3]);
      expect(parser.headerSection?.size, 128);
      buffer = [...buffer, 0];
      parser.getData(buffer);
      expect(parser.data, []);
      expect(parser.rawData, []);
      expect(parser.isCompleted, false);
      buffer = [...buffer, 0, 0, 0, 0, 0, 240, 63];
      parser.getData(buffer);
      expect(parser.data, []);
      expect(parser.rawData, [1.0]);
      expect(parser.isCompleted, false);
      buffer = [...buffer, 0];
      parser.getData(buffer);
      expect(parser.data, []);
      expect(parser.rawData, [1.0]);
      expect(parser.isCompleted, false);
      buffer = [...buffer, 0, 0, 0, 0, 0, 240, 191];
      parser.getData(buffer);
      expect(parser.data, []);
      expect(parser.rawData, [1.0, -1.0]);
      expect(parser.isCompleted, false);
      buffer = [...buffer, 0, 0, 0, 0, 0, 0, 0, 64];
      parser.getData(buffer);
      expect(parser.data, [1.0, -1.0, 2.0]);
      expect(parser.rawData, [1.0, -1.0, 2.0]);
      expect(parser.isCompleted, true);
      buffer.removeRange(buffer.length - 2, buffer.length);
      buffer = [...buffer, 240, 63];
      expect(parser.data, [1.0, -1.0, 2.0]);
      expect(parser.rawData, [1.0, -1.0, 2.0]);
      expect(parser.isCompleted, true);
    });
    test('Empty list', () {
      final headerSection = NpyHeaderSection.fromList(const []);
      final buffer = headerSection.asBytes;
      final parser = NpyParser()
        ..checkMagicString(buffer)
        ..getVersion(buffer)
        ..getHeaderSize(buffer)
        ..getHeader(buffer);
      expect(parser.headerSection, null);
      parser.buildHeaderSection();
      expect(parser.headerSection?.header.shape, []);
      expect(parser.isCompleted, false);
      parser.getData(buffer);
      expect(parser.isCompleted, true);
      expect(parser.data, []);
    });
    test('2d bool list', () {
      final headerSection = NpyHeaderSection.fromList([
        [true, true, true],
        [false, false, false],
      ]);
      List<int> buffer = headerSection.asBytes;
      final parser = NpyParser()
        ..checkMagicString(buffer)
        ..getVersion(buffer)
        ..getHeaderSize(buffer)
        ..getHeader(buffer)
        ..buildHeaderSection();
      expect(parser.headerSection?.header.shape, [2, 3]);
      expect(parser.data, []);
      expect(parser.rawData, []);
      expect(parser.isCompleted, false);
      buffer = [...buffer, 1, 1, 1];
      parser.getData(buffer);
      expect(parser.data, []);
      expect(parser.rawData, [true, true, true]);
      expect(parser.isCompleted, false);
      buffer = [...buffer, 0, 0, 0];
      parser.getData(buffer);
      expect(parser.data, [
        [true, true, true],
        [false, false, false],
      ]);
      expect(parser.rawData, [true, true, true, false, false, false]);
      expect(parser.isCompleted, true);
    });
    test('3d uint16 list, big endian, fortran order', () {
      final headerSection = NpyHeaderSection.fromList(
        [
          [
            [1, 2, 3],
            [4, 5, 6],
          ],
          [
            [7, 8, 9],
            [10, 11, 12],
          ],
        ],
        dtype: NpyDType.uint16(endian: NpyEndian.big),
        fortranOrder: true,
      );
      List<int> buffer = headerSection.asBytes;
      final parser = NpyParser()
        ..checkMagicString(buffer)
        ..getVersion(buffer)
        ..getHeaderSize(buffer)
        ..getHeader(buffer)
        ..buildHeaderSection()
        ..getData(buffer);
      expect(parser.headerSection?.header.shape, [2, 2, 3]);
      expect(parser.data, []);
      expect(parser.rawData, []);
      expect(parser.isCompleted, false);
      buffer = [...buffer, 0, 1, 0, 7, 0, 4, 0, 10, 0, 2, 0, 8];
      parser.getData(buffer);
      expect(parser.data, []);
      expect(parser.rawData, [1, 7, 4, 10, 2, 8]);
      expect(parser.isCompleted, false);
      buffer = [...buffer, 0, 5, 0, 11, 0, 3, 0, 9, 0, 6, 0, 12];
      parser.getData(buffer);
      expect(parser.data, [
        [
          [1, 2, 3],
          [4, 5, 6],
        ],
        [
          [7, 8, 9],
          [10, 11, 12],
        ],
      ]);
      expect(parser.rawData, [1, 7, 4, 10, 2, 8, 5, 11, 3, 9, 6, 12]);
      expect(parser.isCompleted, true);
    });
  });

  group('Parse data bytes:', () {
    test(
      '1 little endian float64',
      () => expect(
        parseByteData([
          0,
          0,
          0,
          0,
          0,
          0,
          240,
          63,
        ], NpyDType.float64(endian: NpyEndian.little)),
        [1.0],
      ),
    );
    test(
      '2 big endian float32',
      () => expect(
        listAlmostEquals(
          parseByteData<double>([
            63,
            102,
            102,
            102,
            190,
            76,
            204,
            205,
          ], NpyDType.float32(endian: NpyEndian.big)),
          [0.9, -0.2],
        ),
        true,
      ),
    );
    test(
      '2 little endian int64',
      () => expect(
        parseByteData([
          214,
          255,
          255,
          255,
          255,
          255,
          255,
          255,
          2,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
        ], NpyDType.int64(endian: NpyEndian.little)),
        [-42, 2],
      ),
    );
    test(
      '1 big endian int32',
      () => expect(
        parseByteData([0, 0, 0, 1], NpyDType.int32(endian: NpyEndian.big)),
        [1],
      ),
    );
    test(
      '2 little endian int16',
      () => expect(
        parseByteData([1, 0, 2, 0], NpyDType.int16(endian: NpyEndian.little)),
        [1, 2],
      ),
    );
    test(
      '4 int8',
      () => expect(parseByteData([1, 255, 3, 4], const NpyDType.int8()), [
        1,
        -1,
        3,
        4,
      ]),
    );
    test(
      '1 big endian uint64',
      () => expect(
        parseByteData([
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          1,
        ], NpyDType.uint64(endian: NpyEndian.big)),
        [1],
      ),
    );
    test(
      '2 little endian uint32',
      () => expect(
        parseByteData([
          1,
          0,
          0,
          0,
          2,
          0,
          0,
          0,
        ], NpyDType.uint32(endian: NpyEndian.little)),
        [1, 2],
      ),
    );
    test(
      '1 big endian uint16',
      () => expect(
        parseByteData([0, 1], NpyDType.uint16(endian: NpyEndian.big)),
        [1],
      ),
    );
    test(
      '3 uint8',
      () => expect(parseByteData([1, 255, 3], const NpyDType.uint8()), [
        1,
        255,
        3,
      ]),
    );
    test(
      '3 bool',
      () => expect(parseByteData([1, 0, 1], const NpyDType.boolean()), [
        true,
        false,
        true,
      ]),
    );
  });

  group('Reshape:', () {
    test('Empty list', () => expect(reshape([], []), []));
    test(
      'Empty shape',
      () => expect(
        () => reshape([1, 2, 3, 4, 5, 6], []),
        throwsA(const TypeMatcher<NpyParseException>()),
      ),
    );
    test(
      '1D int',
      () => expect(reshape([1, 2, 3, 4, 5, 6], [6]), [1, 2, 3, 4, 5, 6]),
    );
    test('2D int', () {
      expect(reshape([1, 2, 3, 4, 5, 6], [2, 3]), [
        [1, 2, 3],
        [4, 5, 6],
      ]);
    });
    test('2D int reverse', () {
      expect(reshape([1, 2, 3, 4, 5, 6], [3, 2]), [
        [1, 2],
        [3, 4],
        [5, 6],
      ]);
    });
    test('2D int, single row', () {
      expect(reshape([1, 2, 3, 4, 5, 6], [1, 6]), [
        [1, 2, 3, 4, 5, 6],
      ]);
    });
    test('2D int, single column', () {
      expect(reshape([1, 2, 3, 4, 5, 6], [6, 1]), [
        [1],
        [2],
        [3],
        [4],
        [5],
        [6],
      ]);
    });
    test('3D int', () {
      expect(reshape([1, 2, 3, 4, 5, 6], [1, 2, 3]), [
        [
          [1, 2, 3],
          [4, 5, 6],
        ],
      ]);
    });
    test('2D float', () {
      expect(reshape([1.0, 2.1, 3.2, 4.3, 5.4, 6.5], [2, 3]), [
        [1.0, 2.1, 3.2],
        [4.3, 5.4, 6.5],
      ]);
    });
    test(
      'List length does not match shape',
      () => expect(
        () => reshape([1, 2, 3, 4], [5]),
        throwsA(const TypeMatcher<NpyParseException>()),
      ),
    );
    test(
      'Empty list, fortran oder',
      () => expect(reshape([], [], fortranOrder: true), []),
    );
    test(
      'Empty shape, fortran order',
      () => expect(
        () => reshape([1, 2, 3, 4, 5, 6], [], fortranOrder: true),
        throwsA(const TypeMatcher<NpyParseException>()),
      ),
    );
    test(
      '1D int, fortran order',
      () => expect(reshape([1, 2, 3, 4, 5, 6], [6], fortranOrder: true), [
        1,
        2,
        3,
        4,
        5,
        6,
      ]),
    );
    test('2D int, fortran order', () {
      expect(reshape([1, 4, 2, 5, 3, 6], [2, 3], fortranOrder: true), [
        [1, 2, 3],
        [4, 5, 6],
      ]);
    });
    test('2D int reverse, fortran order', () {
      expect(reshape([1, 3, 5, 2, 4, 6], fortranOrder: true, [3, 2]), [
        [1, 2],
        [3, 4],
        [5, 6],
      ]);
    });
    test('2D int, single row, fortran order', () {
      expect(reshape([1, 2, 3, 4, 5, 6], fortranOrder: true, [1, 6]), [
        [1, 2, 3, 4, 5, 6],
      ]);
    });
    test('2D int, single column, fortran order', () {
      expect(reshape([1, 2, 3, 4, 5, 6], fortranOrder: true, [6, 1]), [
        [1],
        [2],
        [3],
        [4],
        [5],
        [6],
      ]);
    });
    test('3D int, fortran order', () {
      expect(
        reshape(
          [
            1,
            13,
            5,
            17,
            9,
            21,
            2,
            14,
            6,
            18,
            10,
            22,
            3,
            15,
            7,
            19,
            11,
            23,
            4,
            16,
            8,
            20,
            12,
            24,
          ],
          [2, 3, 4],
          fortranOrder: true,
        ),
        [
          [
            [1, 2, 3, 4],
            [5, 6, 7, 8],
            [9, 10, 11, 12],
          ],
          [
            [13, 14, 15, 16],
            [17, 18, 19, 20],
            [21, 22, 23, 24],
          ],
        ],
      );
    });
    test('2D float, fortran order', () {
      expect(
        reshape([1.0, 4.3, 2.1, 5.4, 3.2, 6.5], fortranOrder: true, [2, 3]),
        [
          [1.0, 2.1, 3.2],
          [4.3, 5.4, 6.5],
        ],
      );
    });
    test(
      'List length does not match shape',
      () => expect(
        () => reshape([1, 2, 3, 4], [5]),
        throwsA(const TypeMatcher<NpyParseException>()),
      ),
    );
  });

  group('Load npy:', () {
    test('Empty file', () async {
      const filename = 'load_empty_file.tmp';
      final tmpFile = File(filename)..writeAsBytesSync([]);
      await expectLater(
        NdArray.load(tmpFile.readAsBytesSync(), path: filename),
        throwsA(const TypeMatcher<NpyParseException>()),
      );
      tmpFile.deleteSync();
    });
    test('Insufficient length', () async {
      const filename = 'load_insufficient_length.tmp';
      final tmpFile = File(filename)..writeAsBytesSync([1, 2, 3]);
      await expectLater(
        NdArray.load(tmpFile.readAsBytesSync(), path: filename),
        throwsA(const TypeMatcher<NpyParseException>()),
      );
      tmpFile.deleteSync();
    });
    test('Invalid magic string', () async {
      const filename = 'load_invalid_magic_string.tmp';
      final tmpFile = File(filename)..writeAsBytesSync([1, 2, 3, 4, 5, 6]);
      await expectLater(
        NdArray.load(tmpFile.readAsBytesSync(), path: filename),
        throwsA(const TypeMatcher<NpyParseException>()),
      );
      tmpFile.deleteSync();
    });
    test('Invalid major version', () async {
      const filename = 'load_invalid_major_version.tmp';
      final tmpFile = File(filename)
        ..writeAsBytesSync([...magicString.codeUnits, 4, 0]);
      await expectLater(
        NdArray.load(tmpFile.readAsBytesSync(), path: filename),
        throwsA(const TypeMatcher<NpyParseException>()),
      );
      tmpFile.deleteSync();
    });
    test('Invalid minor version', () async {
      const filename = 'load_invalid_minor_version.tmp';
      final tmpFile = File(filename)
        ..writeAsBytesSync([...magicString.codeUnits, 1, 1]);
      await expectLater(
        NdArray.load(tmpFile.readAsBytesSync(), path: filename),
        throwsA(const TypeMatcher<NpyParseException>()),
      );
      tmpFile.deleteSync();
    });
    test('Empty list', () async {
      const filename = 'load_empty_list.tmp';
      final headerSection = NpyHeaderSection.fromList([]);
      final tmpFile = File(filename)..writeAsBytesSync(headerSection.asBytes);
      final ndarray = await NdArray.load(
        tmpFile.readAsBytesSync(),
        path: filename,
      );
      expect(ndarray.headerSection.header.dtype.endian, NpyEndian.little);
      expect(ndarray.headerSection.header.dtype.type, NpyType.float);
      expect(ndarray.headerSection.header.dtype.itemSize, 8);
      expect(ndarray.headerSection.header.fortranOrder, false);
      expect(ndarray.headerSection.header.shape, const []);
      expect(ndarray.data, const []);
      tmpFile.deleteSync();
    });
    test('1d float list', () async {
      const filename = 'load_float_list.tmp';
      final headerSection = NpyHeaderSection.fromList([1.0, -2.1]);
      final tmpFile = File(filename)
        ..writeAsBytesSync([
          ...headerSection.asBytes,
          0,
          0,
          0,
          0,
          0,
          0,
          240,
          63,
          205,
          204,
          204,
          204,
          204,
          204,
          0,
          192,
        ]);
      final ndarray = await NdArray.load(
        tmpFile.readAsBytesSync(),
        path: filename,
      );
      expect(ndarray.headerSection.header.dtype.endian, NpyEndian.little);
      expect(ndarray.headerSection.header.dtype.type, NpyType.float);
      expect(ndarray.headerSection.header.dtype.itemSize, 8);
      expect(ndarray.headerSection.header.fortranOrder, false);
      expect(ndarray.headerSection.header.shape, [2]);
      expect(ndarray.data, [1.0, -2.1]);
      tmpFile.deleteSync();
    });
    test('1d uint list', () async {
      const filename = 'load_uint_list.tmp';
      final headerSection = NpyHeaderSection.fromList([
        4294967295,
        1,
      ], dtype: NpyDType.uint32());
      final tmpFile = File(filename)
        ..writeAsBytesSync([
          ...headerSection.asBytes,
          255,
          255,
          255,
          255,
          1,
          0,
          0,
          0,
        ]);
      final ndarray = await NdArray.load(
        tmpFile.readAsBytesSync(),
        path: filename,
      );
      expect(ndarray.headerSection.header.dtype.type, NpyType.uint);
      expect(ndarray.headerSection.header.shape, [2]);
      expect(ndarray.data, [4294967295, 1]);
      tmpFile.deleteSync();
    });
    test('2d int list', () async {
      const filename = 'load_2d_int_list.tmp';
      final headerSection = NpyHeaderSection.fromList([
        [-1, 2, 3],
        [4, 5, 6],
      ], dtype: NpyDType.int16());
      final tmpFile = File(filename)
        ..writeAsBytesSync([
          ...headerSection.asBytes,
          255,
          255,
          2,
          0,
          3,
          0,
          4,
          0,
          5,
          0,
          6,
          0,
        ]);
      final ndarray = await NdArray.load(
        tmpFile.readAsBytesSync(),
        path: filename,
      );
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      expect(ndarray.headerSection.header.dtype.itemSize, 2);
      expect(ndarray.headerSection.header.shape, [2, 3]);
      expect(ndarray.data, [
        [-1, 2, 3],
        [4, 5, 6],
      ]);
      tmpFile.deleteSync();
    });
    test('1d bool list', () async {
      const filename = 'load_bool_list.tmp';
      final headerSection = NpyHeaderSection.fromList([true, false]);
      final tmpFile = File(filename)
        ..writeAsBytesSync([...headerSection.asBytes, 1, 0]);
      final ndarray = await NdArray.load(
        tmpFile.readAsBytesSync(),
        path: filename,
      );
      expect(ndarray.headerSection.header.shape, [2]);
      expect(ndarray.data, [true, false]);
      tmpFile.deleteSync();
    });
    test('1d float list bytewise', () async {
      const filename = 'load_float_list_bytewise.tmp';
      final headerSection = NpyHeaderSection.fromList([1.0, -2.1]);
      final tmpFile = File(filename)
        ..writeAsBytesSync([
          ...headerSection.asBytes,
          0,
          0,
          0,
          0,
          0,
          0,
          240,
          63,
          205,
          204,
          204,
          204,
          204,
          204,
          0,
          192,
        ]);
      final ndarray = await NdArray.load(
        tmpFile.readAsBytesSync(),
        path: filename,
        bufferSize: 1,
      );
      expect(ndarray.headerSection.header.dtype.endian, NpyEndian.little);
      expect(ndarray.headerSection.header.dtype.type, NpyType.float);
      expect(ndarray.headerSection.header.dtype.itemSize, 8);
      expect(ndarray.headerSection.header.fortranOrder, false);
      expect(ndarray.headerSection.header.shape, [2]);
      expect(ndarray.data, [1.0, -2.1]);
      tmpFile.deleteSync();
    });
    test('3d bool list, fortran order, bytewise', () async {
      const filename = 'load_bool_list_bytewise.tmp';
      final headerSection = NpyHeaderSection.fromList([
        [
          [true, true, true],
          [true, true, true],
        ],
        [
          [false, false, false],
          [false, false, false],
        ],
      ], fortranOrder: true);
      final tmpFile = File(filename)
        ..writeAsBytesSync([
          ...headerSection.asBytes,
          1,
          0,
          1,
          0,
          1,
          0,
          1,
          0,
          1,
          0,
          1,
          0,
        ]);
      final ndarray = await NdArray.load(
        tmpFile.readAsBytesSync(),
        path: filename,
        bufferSize: 1,
      );
      expect(ndarray.headerSection.header.fortranOrder, true);
      expect(ndarray.headerSection.header.dtype.type, NpyType.boolean);
      expect(ndarray.headerSection.header.dtype.itemSize, 1);
      expect(ndarray.headerSection.header.shape, [2, 2, 3]);
      expect(ndarray.data, [
        [
          [true, true, true],
          [true, true, true],
        ],
        [
          [false, false, false],
          [false, false, false],
        ],
      ]);
      tmpFile.deleteSync();
    });
  });

  group('Get padding size:', () {
    test('0', () => expect(getPaddingSize(0), 0));
    test('1', () => expect(getPaddingSize(1), 63));
    test('63', () => expect(getPaddingSize(63), 1));
    test('64', () => expect(getPaddingSize(64), 0));
    test('65', () => expect(getPaddingSize(65), 63));
  });

  group('Cannot be ASCII endoded:', () {
    test(
      'Empty String',
      () => expect(NpyVersion.cannotBeAsciiEncoded(''), false),
    );
    test(
      'Blank space',
      () => expect(NpyVersion.cannotBeAsciiEncoded(' '), false),
    );
    test('abc', () => expect(NpyVersion.cannotBeAsciiEncoded('abc'), false));
    test('~', () => expect(NpyVersion.cannotBeAsciiEncoded('~'), false));
    test('\x79', () => expect(NpyVersion.cannotBeAsciiEncoded('\x79'), false));
    test('\x80', () => expect(NpyVersion.cannotBeAsciiEncoded('\x80'), true));
    test('€', () => expect(NpyVersion.cannotBeAsciiEncoded('€'), true));
    test(
      '42.50 €',
      () => expect(NpyVersion.cannotBeAsciiEncoded('42.50 €'), true),
    );
  });

  group('Build header string:', () {
    test('<f8, False, ()', () {
      final header = NpyHeader.buildString(
        dtype: NpyDType.float64(endian: NpyEndian.little),
        fortranOrder: false,
        shape: [],
      );
      expect(
        header.string,
        "{'descr': '<f8', 'fortran_order': False, 'shape': (), }",
      );
    });
    test('<f8, True, ()', () {
      final header = NpyHeader.buildString(
        dtype: NpyDType.float64(endian: NpyEndian.little),
        fortranOrder: true,
        shape: [],
      );
      expect(
        header.string,
        "{'descr': '<f8', 'fortran_order': True, 'shape': (), }",
      );
    });
    test('>i4, True, ()', () {
      final header = NpyHeader.buildString(
        dtype: NpyDType.int32(endian: NpyEndian.big),
        fortranOrder: true,
        shape: [],
      );
      expect(
        header.string,
        "{'descr': '>i4', 'fortran_order': True, 'shape': (), }",
      );
    });
    test('<i2, True, (3,)', () {
      final header = NpyHeader.buildString(
        dtype: NpyDType.int16(endian: NpyEndian.little),
        fortranOrder: true,
        shape: [3],
      );
      expect(
        header.string,
        "{'descr': '<i2', 'fortran_order': True, 'shape': (3,), }",
      );
    });
    test('>f4, True, (3, 4)', () {
      final header = NpyHeader.buildString(
        dtype: NpyDType.float32(endian: NpyEndian.big),
        fortranOrder: true,
        shape: [3, 4],
      );
      expect(
        header.string,
        "{'descr': '>f4', 'fortran_order': True, 'shape': (3, 4), }",
      );
    });
  });

  group('Header size to bytes:', () {
    test('Empty list', () {
      final bytes = NpyHeaderSection.fromList([]).headerSizeAsBytes;
      expect(bytes.length, 2);
      expect(bytes[0], 118);
      expect(bytes[1], 0);
    });
  });

  group('Flatten:', () {
    test('Empty list, C order', () => expect(flattenCOrder([]), []));
    test(
      '1D int, C order',
      () => expect(flattenCOrder([1, 2, 3, 4, 5, 6]), [1, 2, 3, 4, 5, 6]),
    );
    test(
      '1D int, C order, expect int',
      () => expect(flattenCOrder<int>([1, 2, 3]), [1, 2, 3]),
    );
    test(
      '1D int, C order, expect wrong type',
      () => expect(() => flattenCOrder<bool>([1]), throwsA(isA<TypeError>())),
    );
    test(
      '2D int, C order',
      () => expect(
        flattenCOrder([
          [1, 2, 3],
          [4, 5, 6],
        ]),
        [1, 2, 3, 4, 5, 6],
      ),
    );
    test(
      '3D int, C order',
      () => expect(
        flattenCOrder([
          [
            [1, 2],
            [3, 4],
          ],
          [
            [5, 6],
            [7, 8],
          ],
        ]),
        [1, 2, 3, 4, 5, 6, 7, 8],
      ),
    );
    test(
      '3D int, C order, expect int',
      () => expect(
        flattenCOrder<int>([
          [
            [1, 2],
            [3, 4],
          ],
          [
            [5, 6],
            [7, 8],
          ],
        ]),
        [1, 2, 3, 4, 5, 6, 7, 8],
      ),
    );
    test(
      'Empty list, Fortran order',
      () => expect(flattenFortranOrder([], shape: []), []),
    );
    test(
      '1D int, Fortran order',
      () => expect(flattenFortranOrder([1, 2, 3, 4, 5, 6], shape: [6]), [
        1,
        2,
        3,
        4,
        5,
        6,
      ]),
    );
    test(
      '1D int, Fortran order, expect int',
      () => expect(flattenFortranOrder<int>([1, 2, 3, 4, 5, 6], shape: [6]), [
        1,
        2,
        3,
        4,
        5,
        6,
      ]),
    );
    test(
      '1D int, Fortran order, expect wrong type',
      () => expect(
        () => flattenFortranOrder<double>([1], shape: [1]),
        throwsA(isA<TypeError>()),
      ),
    );
    test(
      '2D int, Fortran order',
      () => expect(
        flattenFortranOrder(
          [
            [1, 2, 3],
            [4, 5, 6],
          ],
          shape: [2, 3],
        ),
        [1, 4, 2, 5, 3, 6],
      ),
    );
    test(
      '2D bool, Fortran order',
      () => expect(
        flattenFortranOrder(
          [
            [false, false, false],
            [true, true, true],
          ],
          shape: [2, 3],
        ),
        [false, true, false, true, false, true],
      ),
    );
    test(
      '2D float, Fortran order',
      () => expect(
        flattenFortranOrder(
          [
            [1.1, 2.2],
            [3.3, 4.4],
            [5.5, 6.6],
          ],
          shape: [3, 2],
        ),
        [1.1, 3.3, 5.5, 2.2, 4.4, 6.6],
      ),
    );
    test('3D int, fortran order', () {
      expect(
        flattenFortranOrder(
          [
            [
              [1, 2, 3, 4],
              [5, 6, 7, 8],
              [9, 10, 11, 12],
            ],
            [
              [13, 14, 15, 16],
              [17, 18, 19, 20],
              [21, 22, 23, 24],
            ],
          ],
          shape: [2, 3, 4],
        ),
        [
          1,
          13,
          5,
          17,
          9,
          21,
          2,
          14,
          6,
          18,
          10,
          22,
          3,
          15,
          7,
          19,
          11,
          23,
          4,
          16,
          8,
          20,
          12,
          24,
        ],
      );
    });
    test('3D int, fortran order, expect int', () {
      expect(
        flattenFortranOrder<int>(
          [
            [
              [1, 2, 3, 4],
              [5, 6, 7, 8],
              [9, 10, 11, 12],
            ],
            [
              [13, 14, 15, 16],
              [17, 18, 19, 20],
              [21, 22, 23, 24],
            ],
          ],
          shape: [2, 3, 4],
        ),
        [
          1,
          13,
          5,
          17,
          9,
          21,
          2,
          14,
          6,
          18,
          10,
          22,
          3,
          15,
          7,
          19,
          11,
          23,
          4,
          16,
          8,
          20,
          12,
          24,
        ],
      );
    });
  });

  group('NdArray to bytes:', () {
    test('[]', () {
      final ndarray = NdArray.fromList(const []);
      expect(ndarray.data, const []);
      expect(ndarray.headerSection.header.dtype.type, NpyType.float);
      expect(ndarray.dataBytes.length, 0);
    });
    test('[], uint', () {
      final ndarray = NdArray.fromList(const [], dtype: NpyDType.uint64());
      expect(ndarray.data, const []);
      expect(ndarray.headerSection.header.dtype.type, NpyType.uint);
      expect(ndarray.dataBytes.length, 0);
    });
    test('[1]', () {
      final ndarray = NdArray.fromList(const [1]);
      expect(ndarray.data, const [1]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 8);
      expect(dataBytes.first, 1);
    });
    test('[-1]', () {
      final ndarray = NdArray.fromList(const [-1]);
      expect(ndarray.data, const [-1]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 8);
      expect(dataBytes.first, 255);
      expect(dataBytes.last, 255);
    });
    test('[1, 200]', () {
      final ndarray = NdArray.fromList(const [1, 200]);
      expect(ndarray.data, const [1, 200]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 16);
      expect(dataBytes.elementAt(0), 1);
      expect(dataBytes.elementAt(1), 0);
      expect(dataBytes.elementAt(8), 200);
      expect(dataBytes.elementAt(9), 0);
    });
    test('[1.0]', () {
      final ndarray = NdArray.fromList(const [1.0]);
      expect(ndarray.data, const [1.0]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.float);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 8);
      expect(dataBytes.first, 0);
      expect(dataBytes.elementAt(5), 0);
      expect(dataBytes.elementAt(6), 0xf0);
      expect(dataBytes.last, 0x3f);
    });
    test('[256], big endian', () {
      final ndarray = NdArray.fromList(const [256], endian: NpyEndian.big);
      expect(ndarray.data, const [256]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 8);
      expect(dataBytes.first, 0);
      expect(dataBytes.elementAt(6), 1);
      expect(dataBytes.last, 0);
    });
    test('[1, 200], big endian', () {
      final ndarray = NdArray.fromList(const [1, 200], endian: NpyEndian.big);
      expect(ndarray.data, const [1, 200]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 16);
      expect(dataBytes.elementAt(7), 1);
      expect(dataBytes.elementAt(6), 0);
      expect(dataBytes.elementAt(15), 200);
      expect(dataBytes.elementAt(14), 0);
    });
    test('[1.0, 1.9], big endian', () {
      final ndarray = NdArray.fromList(const [1.0, 1.9], endian: NpyEndian.big);
      expect(ndarray.data, const [1.0, 1.9]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.float);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 16);
      expect(dataBytes.first, 0x3f);
      expect(dataBytes.elementAt(1), 0xf0);
      expect(dataBytes.elementAt(2), 0);
      expect(dataBytes.elementAt(8), 0x3f);
      expect(dataBytes.elementAt(9), 0xfe);
      expect(dataBytes.last, 0x66);
    });
    test('[1, 200]', () {
      final ndarray = NdArray.fromList(const [1, 200], dtype: NpyDType.int32());
      expect(ndarray.data, const [1, 200]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 8);
      expect(dataBytes.first, 1);
      expect(dataBytes.elementAt(1), 0);
      expect(dataBytes.elementAt(4), 200);
      expect(dataBytes.elementAt(5), 0);
    });
    test('[1, 200], big endian', () {
      final ndarray = NdArray.fromList(const [
        1,
        200,
      ], dtype: NpyDType.int32(endian: NpyEndian.big));
      expect(ndarray.data, const [1, 200]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 8);
      expect(dataBytes.first, 0);
      expect(dataBytes.elementAt(2), 0);
      expect(dataBytes.elementAt(3), 1);
      expect(dataBytes.elementAt(6), 0);
      expect(dataBytes.last, 200);
    });
    test('[0.5, 2.0]', () {
      final ndarray = NdArray.fromList(const [
        0.5,
        2.0,
      ], dtype: NpyDType.float32(endian: NpyEndian.little));
      expect(ndarray.data, const [0.5, 2.0]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.float);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 8);
      expect(dataBytes.first, 0);
      expect(dataBytes.elementAt(2), 0);
      expect(dataBytes.elementAt(3), 0x3f);
      expect(dataBytes.elementAt(6), 0);
      expect(dataBytes.elementAt(7), 0x40);
    });
    test('2d, shape [2, 1], little endian, C order', () {
      final ndarray = NdArray.fromList(const [
        [1],
        [200],
      ]);
      expect(ndarray.data, const [
        [1],
        [200],
      ]);
      expect(ndarray.headerSection.header.shape, [2, 1]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 16);
      expect(dataBytes.first, 1);
      expect(dataBytes.elementAt(1), 0);
      expect(dataBytes.elementAt(8), 200);
      expect(dataBytes.elementAt(9), 0);
    });
    test('2d, shape [1, 2], little endian, C order', () {
      final ndarray = NdArray.fromList(const [
        [1, 200],
      ]);
      expect(ndarray.data, const [
        [1, 200],
      ]);
      expect(ndarray.headerSection.header.shape, [1, 2]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 16);
      expect(dataBytes.first, 1);
      expect(dataBytes.elementAt(1), 0);
      expect(dataBytes.elementAt(8), 200);
      expect(dataBytes.elementAt(9), 0);
    });
    test('2d, shape [2, 3], little endian, C order', () {
      final ndarray = NdArray.fromList(const [
        [1, 2, 3],
        [4, 5, 6],
      ]);
      expect(ndarray.data, const [
        [1, 2, 3],
        [4, 5, 6],
      ]);
      expect(ndarray.headerSection.header.shape, [2, 3]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 48);
      expect(dataBytes.first, 1);
      expect(dataBytes.elementAt(1), 0);
      expect(dataBytes.elementAt(8), 2);
      expect(dataBytes.elementAt(9), 0);
      expect(dataBytes.elementAt(16), 3);
      expect(dataBytes.elementAt(24), 4);
      expect(dataBytes.elementAt(32), 5);
      expect(dataBytes.elementAt(40), 6);
    });
    test('2d, shape [2, 3], little endian, Fortran order', () {
      final ndarray = NdArray.fromList(const [
        [1, 2, 3],
        [4, 5, 6],
      ], fortranOrder: true);
      expect(ndarray.data, const [
        [1, 2, 3],
        [4, 5, 6],
      ]);
      expect(ndarray.headerSection.header.shape, [2, 3]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 48);
      expect(dataBytes.first, 1);
      expect(dataBytes.elementAt(1), 0);
      expect(dataBytes.elementAt(8), 4);
      expect(dataBytes.elementAt(9), 0);
      expect(dataBytes.elementAt(16), 2);
      expect(dataBytes.elementAt(24), 5);
      expect(dataBytes.elementAt(32), 3);
      expect(dataBytes.elementAt(40), 6);
    });
    test('2d, shape [2, 3], big endian, Fortran order', () {
      final ndarray = NdArray.fromList(
        const [
          [1, 2, 3],
          [4, 5, 6],
        ],
        endian: NpyEndian.big,
        fortranOrder: true,
      );
      expect(ndarray.data, const [
        [1, 2, 3],
        [4, 5, 6],
      ]);
      expect(ndarray.headerSection.header.shape, [2, 3]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 48);
      expect(dataBytes.first, 0);
      expect(dataBytes.elementAt(7), 1);
      expect(dataBytes.elementAt(15), 4);
      expect(dataBytes.elementAt(16), 0);
      expect(dataBytes.elementAt(23), 2);
      expect(dataBytes.elementAt(31), 5);
      expect(dataBytes.elementAt(39), 3);
      expect(dataBytes.elementAt(47), 6);
    });
    test('3d, shape [2, 3, 4], little endian, C order', () {
      final ndarray = NdArray.fromList([
        [
          [1, 2, 3, 4],
          [5, 6, 7, 8],
          [9, 10, 11, 12],
        ],
        [
          [13, 14, 15, 16],
          [17, 18, 19, 20],
          [21, 22, 23, 24],
        ],
      ]);
      expect(ndarray.data, [
        [
          [1, 2, 3, 4],
          [5, 6, 7, 8],
          [9, 10, 11, 12],
        ],
        [
          [13, 14, 15, 16],
          [17, 18, 19, 20],
          [21, 22, 23, 24],
        ],
      ]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      expect(ndarray.headerSection.header.shape, [2, 3, 4]);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 192);
      expect(dataBytes.first, 1);
      expect(dataBytes.elementAt(1), 0);
      expect(dataBytes.elementAt(8), 2);
      expect(dataBytes.elementAt(9), 0);
      expect(dataBytes.elementAt(16), 3);
      expect(dataBytes.elementAt(24), 4);
      expect(dataBytes.elementAt(32), 5);
      expect(dataBytes.elementAt(40), 6);
      expect(dataBytes.elementAt(176), 23);
      expect(dataBytes.elementAt(184), 24);
    });
    test('3d, shape [2, 3, 4], big endian, Fortran order', () {
      final ndarray = NdArray.fromList(
        [
          [
            [1, 2, 3, 4],
            [5, 6, 7, 8],
            [9, 10, 11, 12],
          ],
          [
            [13, 14, 15, 16],
            [17, 18, 19, 20],
            [21, 22, 23, 24],
          ],
        ],
        endian: NpyEndian.big,
        fortranOrder: true,
      );
      expect(ndarray.data, [
        [
          [1, 2, 3, 4],
          [5, 6, 7, 8],
          [9, 10, 11, 12],
        ],
        [
          [13, 14, 15, 16],
          [17, 18, 19, 20],
          [21, 22, 23, 24],
        ],
      ]);
      expect(ndarray.headerSection.header.dtype.type, NpyType.int);
      expect(ndarray.headerSection.header.shape, [2, 3, 4]);
      final dataBytes = ndarray.dataBytes;
      expect(dataBytes.length, 192);
      expect(dataBytes.first, 0);
      expect(dataBytes.elementAt(1), 0);
      expect(dataBytes.elementAt(7), 1);
      expect(dataBytes.elementAt(15), 13);
      expect(dataBytes.elementAt(23), 5);
      expect(dataBytes.elementAt(31), 17);
      expect(dataBytes.elementAt(39), 9);
      expect(dataBytes.elementAt(47), 21);
      expect(dataBytes.elementAt(55), 2);
      expect(dataBytes.elementAt(183), 12);
      expect(dataBytes.elementAt(191), 24);
    });
  });

  group('Save list:', () {
    test('Empty list', () async {
      final bytes = await save(const []);
      expect(bytes.length, 128);
      final headerSection = NpyHeaderSection.fromHeader(
        NpyHeader.fromBytes(bytes),
      );
      expect(headerSection.header.fortranOrder, false);
      expect(headerSection.header.dtype.endian, NpyEndian.little);
      expect(headerSection.header.dtype.type, NpyType.float);
      expect(headerSection.header.dtype.itemSize, 8);
      expect(headerSection.header.shape, const []);
    });
    test('1d bool', () async {
      final bytes = await save([true, false]);
      final headerSection = NpyHeaderSection.fromHeader(
        NpyHeader.fromBytes(bytes.sublist(0, 128)),
      );
      expect(headerSection.header.fortranOrder, false);
      expect(headerSection.header.dtype.endian, NpyEndian.none);
      expect(headerSection.header.dtype.type, NpyType.boolean);
      expect(headerSection.header.dtype.itemSize, 1);
      expect(headerSection.header.shape, [2]);
      expect(bytes.sublist(128), [1, 0]);
    });
    test('2d float', () async {
      final bytes = await save([
        [1.0, 2.0],
        [3.0, 4.0],
        [5.0, 6.0],
      ]);
      final headerSection = NpyHeaderSection.fromHeader(
        NpyHeader.fromBytes(bytes.sublist(0, 128)),
      );
      expect(headerSection.header.fortranOrder, false);
      expect(headerSection.header.dtype.endian, NpyEndian.little);
      expect(headerSection.header.dtype.type, NpyType.float);
      expect(headerSection.header.dtype.itemSize, 8);
      expect(headerSection.header.shape, [3, 2]);
      expect(bytes.sublist(128), [
        0,
        0,
        0,
        0,
        0,
        0,
        0xf0,
        0x3f,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0x40,
        0,
        0,
        0,
        0,
        0,
        0,
        0x08,
        0x40,
        0,
        0,
        0,
        0,
        0,
        0,
        0x10,
        0x40,
        0,
        0,
        0,
        0,
        0,
        0,
        0x14,
        0x40,
        0,
        0,
        0,
        0,
        0,
        0,
        0x18,
        0x40,
      ]);
    });
    test('3d int16, big endian, Fortran order', () async {
      final bytes = await save(
        [
          [
            [1, 2, 3],
            [4, 5, 6],
          ],
          [
            [7, 8, 9],
            [10, 11, 12],
          ],
        ],
        dtype: NpyDType.int16(endian: NpyEndian.big),
        fortranOrder: true,
      );
      final headerSection = NpyHeaderSection.fromHeader(
        NpyHeader.fromBytes(bytes.sublist(0, 128)),
      );
      expect(headerSection.header.dtype.type, NpyType.int);
      expect(headerSection.header.dtype.endian, NpyEndian.big);
      expect(headerSection.header.fortranOrder, true);
      expect(headerSection.header.dtype.itemSize, 2);
      expect(headerSection.header.shape, [2, 2, 3]);
      expect(bytes.sublist(128), [
        0,
        1,
        0,
        7,
        0,
        4,
        0,
        10,
        0,
        2,
        0,
        8,
        0,
        5,
        0,
        11,
        0,
        3,
        0,
        9,
        0,
        6,
        0,
        12,
      ]);
    });
  });

  group('Save:', () {
    test('1d float', () async {
      final bytes = NdArray.fromList(const [-1.0, 2.2, -4.2]).asBytes;
      final headerSection = NpyHeaderSection.fromHeader(
        NpyHeader.fromBytes(bytes.sublist(0, 128)),
      );
      expect(headerSection.header.fortranOrder, false);
      expect(headerSection.header.dtype.endian, NpyEndian.little);
      expect(headerSection.header.dtype.type, NpyType.float);
      expect(headerSection.header.dtype.itemSize, 8);
      expect(headerSection.header.shape, [3]);
      expect(bytes.sublist(128), [
        0,
        0,
        0,
        0,
        0,
        0,
        0xf0,
        0xbf,
        0x9a,
        0x99,
        0x99,
        0x99,
        0x99,
        0x99,
        0x01,
        0x40,
        0xcd,
        0xcc,
        0xcc,
        0xcc,
        0xcc,
        0xcc,
        0x10,
        0xc0,
      ]);
    });
    test('3d uint16, big endian, Fortran order', () async {
      final bytes = NdArray.fromList(
        [
          [
            [1, 2],
            [3, 4],
            [5, 6],
          ],
          [
            [7, 8],
            [9, 10],
            [11, 12],
          ],
        ],
        dtype: NpyDType.uint16(endian: NpyEndian.big),
        fortranOrder: true,
      ).asBytes;
      final headerSection = NpyHeaderSection.fromHeader(
        NpyHeader.fromBytes(bytes.sublist(0, 128)),
      );
      expect(headerSection.header.dtype.type, NpyType.uint);
      expect(headerSection.header.dtype.endian, NpyEndian.big);
      expect(headerSection.header.fortranOrder, true);
      expect(headerSection.header.dtype.itemSize, 2);
      expect(headerSection.header.shape, [2, 3, 2]);
      expect(bytes.sublist(128), [
        0,
        1,
        0,
        7,
        0,
        3,
        0,
        9,
        0,
        5,
        0,
        11,
        0,
        2,
        0,
        8,
        0,
        4,
        0,
        10,
        0,
        6,
        0,
        12,
      ]);
    });
  });

  group('Load npz file:', () {
    test('Empty zip file (only has end of central directory record)', () async {
      const filename = 'load_empty_zip.npz';
      final file = File(filename)
        ..writeAsBytesSync([80, 75, 5, 6, 0])
        ..createSync();
      final npzFile = await NpzFile.load(file.readAsBytesSync());
      expect(npzFile.files.length, 0);
      file.deleteSync();
    });
    test('Single file that is not an npy file', () async {
      const filename = 'load_non_npy_file.npz';
      final bytes = ZipEncoder().encode(
        Archive()..addFile(ArchiveFile.string('empty_file.txt', '')),
      );
      final file = File(filename)..writeAsBytesSync(bytes);
      await expectLater(
        NpzFile.load(file.readAsBytesSync()),
        throwsA(const TypeMatcher<NpyParseException>()),
      );
      file.deleteSync();
    });
    test('Single ndarray', () async {
      const npyFilename = 'load_2d_float.npy';
      final npyBytes = await save([
        [.111, 2.22, -33.3],
      ]);
      final npzBytes = ZipEncoder().encodeBytes(
        Archive()..addFile(ArchiveFile(npyFilename, npyBytes.length, npyBytes)),
      );
      final npzFile = await NpzFile.load(npzBytes);
      expect(npzFile.files.length, 1);
      expect(npzFile.files[npyFilename]?.data, [
        [.111, 2.22, -33.3],
      ]);
      expect(
        npzFile.files[npyFilename]?.headerSection.header.dtype.type,
        NpyType.float,
      );
      expect(
        npzFile.files[npyFilename]?.headerSection.header.dtype.itemSize,
        8,
      );
      expect(npzFile.files[npyFilename]?.headerSection.header.shape, [1, 3]);
    });
    test('Two ndarrays', () async {
      const npyFilename1 = 'load_1d_float64.npy';
      const npyFilename2 = 'load_3d_uint16.npy';
      final npyBytes1 = await save([0.123, -4.567], endian: NpyEndian.little);
      final npyBytes2 = await save(
        [
          [
            [1, 2],
            [3, 4],
            [5, 6],
          ],
        ],
        dtype: NpyDType.uint16(endian: NpyEndian.big),
        fortranOrder: true,
      );
      final npzBytes = ZipEncoder().encodeBytes(
        Archive()
          ..addFile(ArchiveFile(npyFilename1, npyBytes1.length, npyBytes1))
          ..addFile(ArchiveFile(npyFilename2, npyBytes2.length, npyBytes2)),
      );
      final npzFile = await NpzFile.load(npzBytes);
      expect(npzFile.files.length, 2);
      expect(npzFile.files[npyFilename1]?.data, [0.123, -4.567]);
      expect(
        npzFile.files[npyFilename1]?.headerSection.header.dtype.type,
        NpyType.float,
      );
      expect(
        npzFile.files[npyFilename1]?.headerSection.header.dtype.itemSize,
        8,
      );
      expect(
        npzFile.files[npyFilename1]?.headerSection.header.dtype.endian,
        NpyEndian.little,
      );
      expect(
        npzFile.files[npyFilename1]?.headerSection.header.fortranOrder,
        false,
      );
      expect(npzFile.files[npyFilename1]?.headerSection.header.shape, [2]);
      expect(npzFile.files[npyFilename2]?.data, [
        [
          [1, 2],
          [3, 4],
          [5, 6],
        ],
      ]);
      expect(
        npzFile.files[npyFilename2]?.headerSection.header.dtype.type,
        NpyType.uint,
      );
      expect(
        npzFile.files[npyFilename2]?.headerSection.header.dtype.itemSize,
        2,
      );
      expect(
        npzFile.files[npyFilename2]?.headerSection.header.dtype.endian,
        NpyEndian.big,
      );
      expect(
        npzFile.files[npyFilename2]?.headerSection.header.fortranOrder,
        true,
      );
      expect(npzFile.files[npyFilename2]?.headerSection.header.shape, [
        1,
        3,
        2,
      ]);
    });
    test('Two ndarrays, compressed', () async {
      const npyFilename1 = 'load_1d_float64.npy';
      const npyFilename2 = 'load_3d_uint16.npy';
      final npyBytes1 = await save([0.123, -4.567], endian: NpyEndian.little);
      final npyBytes2 = await save(
        [
          [
            [1, 2],
            [3, 4],
            [5, 6],
          ],
        ],
        dtype: NpyDType.uint16(endian: NpyEndian.big),
        fortranOrder: true,
      );
      final npzBytes = ZipEncoder().encodeBytes(
        Archive()
          ..addFile(ArchiveFile(npyFilename1, npyBytes1.length, npyBytes1))
          ..addFile(ArchiveFile(npyFilename2, npyBytes2.length, npyBytes2)),
        level: DeflateLevel.defaultCompression,
      );
      final npzFile = await NpzFile.load(npzBytes);
      expect(npzFile.files.length, 2);
      expect(npzFile.files[npyFilename1]?.data, [0.123, -4.567]);
      expect(
        npzFile.files[npyFilename1]?.headerSection.header.dtype.type,
        NpyType.float,
      );
      expect(
        npzFile.files[npyFilename1]?.headerSection.header.dtype.itemSize,
        8,
      );
      expect(
        npzFile.files[npyFilename1]?.headerSection.header.dtype.endian,
        NpyEndian.little,
      );
      expect(
        npzFile.files[npyFilename1]?.headerSection.header.fortranOrder,
        false,
      );
      expect(npzFile.files[npyFilename1]?.headerSection.header.shape, [2]);
      expect(npzFile.files[npyFilename2]?.data, [
        [
          [1, 2],
          [3, 4],
          [5, 6],
        ],
      ]);
      expect(
        npzFile.files[npyFilename2]?.headerSection.header.dtype.type,
        NpyType.uint,
      );
      expect(
        npzFile.files[npyFilename2]?.headerSection.header.dtype.itemSize,
        2,
      );
      expect(
        npzFile.files[npyFilename2]?.headerSection.header.dtype.endian,
        NpyEndian.big,
      );
      expect(
        npzFile.files[npyFilename2]?.headerSection.header.fortranOrder,
        true,
      );
      expect(npzFile.files[npyFilename2]?.headerSection.header.shape, [
        1,
        3,
        2,
      ]);
    });
  });

  group('Save npz file:', () {
    test('Empty file', () async {
      final npzBytes = await NpzFile().save();
      final npzFile = await NpzFile.load(npzBytes);
      expect(npzFile.files.length, 0);
    });
    test('One array', () async {
      const npyFilename = 'first.npy';
      final ndarray = NdArray.fromList([
        [
          [
            [
              [true, false, true],
            ],
          ],
        ],
      ]);
      final npzBytes = await NpzFile({npyFilename: ndarray}).save();
      final npzFile = await NpzFile.load(npzBytes);
      expect(npzFile.files.length, 1);
      expect(npzFile.files[npyFilename]?.data, [
        [
          [
            [
              [true, false, true],
            ],
          ],
        ],
      ]);
    });
    test('Two ndarrays', () async {
      const npyFilename1 = 'first.npy';
      const npyFilename2 = 'second.npy';
      final ndarray1 = NdArray.fromList(
        [
          [
            [12, 123, 234],
          ],
        ],
        dtype: const NpyDType.uint8(),
        fortranOrder: true,
      );
      final ndarray2 = NdArray.fromList([
        [
          [
            [1, 2],
            [3, 4],
            [5, 6],
          ],
        ],
      ], dtype: NpyDType.int16(endian: NpyEndian.big));
      final npzBytes = await NpzFile({
        npyFilename1: ndarray1,
        npyFilename2: ndarray2,
      }).save();
      final npzFile = await NpzFile.load(npzBytes);
      expect(npzFile.files.length, 2);
      expect(npzFile.files[npyFilename1]?.data, [
        [
          [12, 123, 234],
        ],
      ]);
      expect(npzFile.files[npyFilename2]?.data, [
        [
          [
            [1, 2],
            [3, 4],
            [5, 6],
          ],
        ],
      ]);
    });
    test('Two ndarrays, compressed', () async {
      const npyFilename1 = 'first.npy';
      const npyFilename2 = 'second.npy';
      final ndarray1 = NdArray.fromList(
        [
          [
            [12, 123, 234],
          ],
        ],
        dtype: const NpyDType.uint8(),
        fortranOrder: true,
      );
      final ndarray2 = NdArray.fromList([
        [
          [
            [1, 2],
            [3, 4],
            [5, 6],
          ],
        ],
      ], dtype: NpyDType.int16(endian: NpyEndian.big));
      final npzBytes = await NpzFile({
        npyFilename1: ndarray1,
        npyFilename2: ndarray2,
      }).save(isCompressed: true);
      final npzFile = await NpzFile.load(npzBytes);
      expect(npzFile.files.length, 2);
      expect(npzFile.files[npyFilename1]?.data, [
        [
          [12, 123, 234],
        ],
      ]);
      expect(npzFile.files[npyFilename2]?.data, [
        [
          [
            [1, 2],
            [3, 4],
            [5, 6],
          ],
        ],
      ]);
    });
  });

  group('Add ndarray to NpzFile:', () {
    test('Two arrays', () async {
      final npzFile = NpzFile();
      npzFile.add(NdArray.fromList([true, true, false]));
      npzFile.add(
        NdArray.fromList([
          [-1.1, 2.2, -3.3],
        ]),
      );
      final npzBytes = await npzFile.save();
      final loadedNpzFile = await NpzFile.load(npzBytes);
      expect(loadedNpzFile.files.length, 2);
      expect(loadedNpzFile.take('arr_0.npy').data, [true, true, false]);
      expect(loadedNpzFile.take('arr_1.npy').data, [
        [-1.1, 2.2, -3.3],
      ]);
    });
    test('Two arrays of the same name with replace', () async {
      const npyFilename = 'array.npy';
      final npzFile = NpzFile();
      npzFile.add(NdArray.fromList([true, true, false]), name: npyFilename);
      npzFile.add(
        NdArray.fromList([
          [-1.1, 2.2, -3.3],
        ]),
        name: npyFilename,
        replace: true,
      );
      final npzBytes = await npzFile.save();
      final loadedNpzFile = await NpzFile.load(npzBytes);
      expect(loadedNpzFile.files.length, 1);
      expect(loadedNpzFile.files[npyFilename]?.data, [
        [-1.1, 2.2, -3.3],
      ]);
    });
    test('Two arrays with same name without replace', () {
      final npzFile = NpzFile();
      npzFile.add(NdArray.fromList([true, true, false]));
      expect(
        () =>
            npzFile.add(NdArray.fromList([-1.1, 2.2, -3.3]), name: 'arr_0.npy'),
        throwsA(isA<NpyFileExistsException>()),
      );
    });
    test('Empty name', () {
      expect(
        () => NpzFile().add(NdArray.fromList([true, true, false]), name: ''),
        throwsA(isA<NpyInvalidNameException>()),
      );
    });
    test('Empty name after trim', () {
      expect(
        () => NpzFile().add(NdArray.fromList([true, true, false]), name: ' '),
        throwsA(isA<NpyInvalidNameException>()),
      );
    });
    test('Name is .', () {
      expect(
        () => NpzFile().add(NdArray.fromList([true, true, false]), name: ' .'),
        throwsA(isA<NpyInvalidNameException>()),
      );
    });
    test('Name is ..', () {
      expect(
        () => NpzFile().add(NdArray.fromList([true, true, false]), name: '.. '),
        throwsA(isA<NpyInvalidNameException>()),
      );
    });
    test('Name contains invalid characters', () {
      expect(
        () => NpzFile().add(NdArray.fromList([true, true, false]), name: 'a*b'),
        throwsA(isA<NpyInvalidNameException>()),
      );
    });
    test('trim name', () {
      final npzFile = NpzFile();
      npzFile.add(NdArray.fromList([true, true, false]), name: '  abc   ');
      expect(npzFile.files.length, 1);
      expect(npzFile.take('abc').data, [true, true, false]);
    });
  });

  group('Take ndarray from NpzFile:', () {
    test('One file exists, one does not', () {
      final npzFile = NpzFile();
      npzFile.add(NdArray.fromList([1, 2, 3]));
      expect(npzFile.take('arr_0.npy').data, [1, 2, 3]);
      expect(
        () => npzFile.take('arr_1.npy'),
        throwsA(isA<NpyFileNotExistsException>()),
      );
    });
  });
}

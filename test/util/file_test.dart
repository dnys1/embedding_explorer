@TestOn('browser')
library;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:embeddings_explorer/util/file.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

void main() {
  group('FileFutures extension', () {
    group('readAsBytes', () {
      test('reads a text file as bytes correctly', () async {
        final testContent = 'Hello, World!';
        final blob = Blob([testContent.toJS].toJS);
        final file = File([blob].toJS, 'test.txt');

        final bytes = await file.readAsBytes();

        final result = String.fromCharCodes(bytes);
        expect(result, equals(testContent));
      });

      test('reads binary data correctly', () async {
        final binaryData = Uint8List.fromList([
          0x48,
          0x65,
          0x6C,
          0x6C,
          0x6F,
        ]); // "Hello" in bytes
        final blob = Blob([binaryData.toJS].toJS);
        final file = File([blob].toJS, 'test.bin');

        final result = await file.readAsBytes();

        expect(result, equals(binaryData));
      });

      test('reads empty file correctly', () async {
        final blob = Blob(<JSAny>[].toJS);
        final file = File([blob].toJS, 'empty.txt');

        final result = await file.readAsBytes();

        expect(result, isEmpty);
      });

      test('reads large file correctly', () async {
        const size = 1 << 20; // 1 MB
        final largeContent = 'A' * size;
        final blob = Blob([largeContent.toJS].toJS);
        final file = File([blob].toJS, 'large.txt');

        final result = await file.readAsBytes();

        expect(result.length, equals(size));
        expect(String.fromCharCodes(result), equals(largeContent));
      });

      test('handles UTF-8 encoded content correctly', () async {
        final utf8Content = 'café résumé ☕️';
        final blob = Blob([utf8Content.toJS].toJS);
        final file = File([blob].toJS, 'utf8.txt');

        final result = await file.readAsBytes();
        expect(result, equals(utf8.encode(utf8Content)));
      });
    });

    group('readAsString', () {
      test('reads a simple text file correctly', () async {
        final testContent = 'Hello, World!';
        final blob = Blob([testContent.toJS].toJS);
        final file = File([blob].toJS, 'test.txt');

        final result = await file.readAsString();

        expect(result, equals(testContent));
      });

      test('reads empty file as empty string', () async {
        final blob = Blob(<JSAny>[].toJS);
        final file = File([blob].toJS, 'empty.txt');

        final result = await file.readAsString();

        expect(result, isEmpty);
      });

      test('handles UTF-8 content correctly', () async {
        final utf8Content = 'Hello café naïve résumé ☕️';
        final blob = Blob([utf8Content.toJS].toJS);
        final file = File([blob].toJS, 'utf8.txt');

        final result = await file.readAsString();

        expect(result, equals(utf8Content));
      });

      group('reads CSV formatted text correctly', () {
        test('LF', () async {
          final csvContent = 'name,age\nAlice,30\nBob,25';
          final blob = Blob([csvContent.toJS].toJS);
          final file = File([blob].toJS, 'data.csv');

          final result = await file.readAsString();

          expect(result, equals(csvContent));
        });

        test('CRLF', () async {
          final csvContent = 'name,age\r\nAlice,30\r\nBob,25';
          final blob = Blob([csvContent.toJS].toJS);
          final file = File([blob].toJS, 'data.csv');

          final result = await file.readAsString();

          expect(result, equals(csvContent));
        });
      });
    });

    group('consistency between methods', () {
      test(
        'readAsBytes and readAsString return consistent data for text files',
        () async {
          final testContent = 'Test consistency between methods';
          final blob = Blob([testContent.toJS].toJS);
          final file = File([blob].toJS, 'test.txt');

          final bytes = await file.readAsBytes();
          final text = await file.readAsString();

          final bytesAsText = String.fromCharCodes(bytes);
          expect(bytesAsText, equals(text));
          expect(text, equals(testContent));
        },
      );

      test(
        'multiple reads of the same file return identical results',
        () async {
          final testContent = 'Multiple reads test';
          final blob = Blob([testContent.toJS].toJS);
          final file = File([blob].toJS, 'test.txt');

          final firstRead = await file.readAsString();
          final secondRead = await file.readAsString();
          final thirdRead = await file.readAsBytes();

          expect(firstRead, equals(secondRead));
          expect(String.fromCharCodes(thirdRead), equals(firstRead));
        },
      );
    });
  });
}

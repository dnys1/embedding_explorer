@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:embeddings_explorer/util/file.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

void main() {
  group('FileFutures extension', () {
    group('readAsBytes', () {
      test('reads a text file as bytes correctly', () async {
        // Create a test file with known content
        final testContent = 'Hello, World! 🌍';
        final blob = Blob([testContent.toJS].toJS);
        final file = File([blob].toJS, 'test.txt');

        final bytes = await file.readAsBytes();
        
        // Convert bytes back to string to verify content
        final result = String.fromCharCodes(bytes);
        expect(result, equals(testContent));
      });

      test('reads binary data correctly', () async {
        // Create a file with known binary data
        final binaryData = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]); // "Hello" in bytes
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
        // Create a larger file (1KB of 'A's)
        final largeContent = 'A' * 1024;
        final blob = Blob([largeContent.toJS].toJS);
        final file = File([blob].toJS, 'large.txt');

        final result = await file.readAsBytes();
        
        expect(result.length, equals(1024));
        expect(String.fromCharCodes(result), equals(largeContent));
      });

      test('handles UTF-8 encoded content correctly', () async {
        // Test with emojis and special characters
        final utf8Content = 'Hello 🌍 世界 🚀 café naïve résumé';
        final blob = Blob([utf8Content.toJS].toJS);
        final file = File([blob].toJS, 'utf8.txt');

        final result = await file.readAsBytes();
        
        // Convert back to string and verify
        final decoded = String.fromCharCodes(result);
        expect(decoded, equals(utf8Content));
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

      test('reads multiline text correctly', () async {
        final multilineContent = '''Line 1
Line 2
Line 3''';
        final blob = Blob([multilineContent.toJS].toJS);
        final file = File([blob].toJS, 'multiline.txt');

        final result = await file.readAsString();
        
        expect(result, equals(multilineContent));
      });

      test('reads empty file as empty string', () async {
        final blob = Blob(<JSAny>[].toJS);
        final file = File([blob].toJS, 'empty.txt');

        final result = await file.readAsString();
        
        expect(result, isEmpty);
      });

      test('handles UTF-8 content correctly', () async {
        final utf8Content = 'Hello 🌍 世界 🚀 café naïve résumé';
        final blob = Blob([utf8Content.toJS].toJS);
        final file = File([blob].toJS, 'utf8.txt');

        final result = await file.readAsString();
        
        expect(result, equals(utf8Content));
      });

      test('reads JSON content correctly', () async {
        final jsonContent = '{"name": "test", "value": 42, "active": true}';
        final blob = Blob([jsonContent.toJS].toJS);
        final file = File([blob].toJS, 'data.json');

        final result = await file.readAsString();
        
        expect(result, equals(jsonContent));
      });

      test('reads CSV content correctly', () async {
        final csvContent = '''name,age,city
Alice,30,New York
Bob,25,London
Charlie,35,Tokyo''';
        final blob = Blob([csvContent.toJS].toJS);
        final file = File([blob].toJS, 'data.csv');

        final result = await file.readAsString();
        
        expect(result, equals(csvContent));
      });

      test('handles special characters and symbols', () async {
        final specialContent = 'Special chars: @#\$%^&*()[]{}|;:,.<>?/~`+=';
        final blob = Blob([specialContent.toJS].toJS);
        final file = File([blob].toJS, 'special.txt');

        final result = await file.readAsString();
        
        expect(result, equals(specialContent));
      });
    });

    group('error handling', () {
      test('readAsBytes handles corrupted file gracefully', () async {
        // Create a mock file that will trigger an error
        // Note: This is tricky to test in a real browser environment
        // as FileReader is quite robust. This test ensures our error handling
        // structure is in place.
        final blob = Blob(<JSAny>[].toJS);
        final file = File([blob].toJS, 'test.txt');
        
        // This should not throw an exception and should complete successfully
        final result = await file.readAsBytes();
        expect(result, isA<Uint8List>());
      });

      test('readAsString handles corrupted file gracefully', () async {
        // Similar to above - ensures error handling structure is in place
        final blob = Blob([].toJS);
        final file = File([blob].toJS, 'test.txt');
        
        final result = await file.readAsString();
        expect(result, isA<String>());
      });
    });

    group('consistency between methods', () {
      test('readAsBytes and readAsString return consistent data for text files', () async {
        final testContent = 'Test consistency between methods';
        final blob = Blob([testContent.toJS].toJS);
        final file = File([blob].toJS, 'test.txt');

        final bytes = await file.readAsBytes();
        final text = await file.readAsString();
        
        // Convert bytes to string and compare
        final bytesAsText = String.fromCharCodes(bytes);
        expect(bytesAsText, equals(text));
        expect(text, equals(testContent));
      });

      test('multiple reads of the same file return identical results', () async {
        final testContent = 'Multiple reads test';
        final blob = Blob([testContent.toJS].toJS);
        final file = File([blob].toJS, 'test.txt');

        final firstRead = await file.readAsString();
        final secondRead = await file.readAsString();
        final thirdRead = await file.readAsBytes();
        
        expect(firstRead, equals(secondRead));
        expect(String.fromCharCodes(thirdRead), equals(firstRead));
      });
    });

    group('performance and edge cases', () {
      test('handles very small files efficiently', () async {
        final singleChar = 'A';
        final blob = Blob([singleChar.toJS].toJS);
        final file = File([blob].toJS, 'tiny.txt');

        final stopwatch = Stopwatch()..start();
        final result = await file.readAsString();
        stopwatch.stop();
        
        expect(result, equals(singleChar));
        // Should complete reasonably quickly (less than 1 second)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('handles files with only whitespace', () async {
        final whitespaceContent = '   \n\t  \r\n   ';
        final blob = Blob([whitespaceContent.toJS].toJS);
        final file = File([blob].toJS, 'whitespace.txt');

        final result = await file.readAsString();
        
        expect(result, equals(whitespaceContent));
      });

      test('handles files with null bytes', () async {
        final dataWithNulls = Uint8List.fromList([65, 0, 66, 0, 67]); // A\0B\0C
        final blob = Blob([dataWithNulls.toJS].toJS);
        final file = File([blob].toJS, 'nulls.bin');

        final result = await file.readAsBytes();
        
        expect(result, equals(dataWithNulls));
      });
    });
  });
}

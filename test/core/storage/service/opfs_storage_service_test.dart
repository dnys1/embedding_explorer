@TestOn('browser')
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:embeddings_explorer/storage/service/storage_service.dart';
import 'package:test/test.dart';

import '../../../common.dart';

void main() {
  setupTests();

  group('StorageService', () {
    group('OpfsStorageService', () {
      late OpfsStorageService storageService;

      setUp(() {
        storageService = OpfsStorageService();
      });

      tearDown(() async {
        await storageService.clear();
      });

      test('has correct name', () {
        expect(storageService.name, equals('OPFS'));
      });

      group('Basic file operations', () {
        test('should write and read a file correctly', () async {
          const testContent = 'Hello, OPFS World!';
          const testPath = 'test-file.txt';
          final testData = Uint8List.fromList(utf8.encode(testContent));

          await storageService.writeAsBytes(testPath, testData);
          final retrievedData = await storageService.readAsBytes(testPath);

          expect(retrievedData, equals(testData));
          expect(utf8.decode(retrievedData), equals(testContent));

          final retrievedString = await storageService.readAsString(testPath);
          expect(retrievedString, equals(testContent));
        });

        test('should write and read binary data correctly', () async {
          const testPath = 'binary-file.bin';
          final binaryData = Uint8List.fromList([
            0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG header
            0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
            0xFF, 0xD8, 0xFF, 0xE0, // JPEG markers
          ]);

          await storageService.writeAsBytes(testPath, binaryData);
          final retrievedData = await storageService.readAsBytes(testPath);

          expect(retrievedData, equals(binaryData));
        });

        test('should write and read empty file correctly', () async {
          const testPath = 'empty-file.txt';
          final emptyData = Uint8List(0);

          await storageService.writeAsBytes(testPath, emptyData);
          final retrievedData = await storageService.readAsBytes(testPath);

          expect(retrievedData, isEmpty);
        });

        test('should overwrite existing file', () async {
          const testPath = 'overwrite-test.txt';
          final originalData = Uint8List.fromList(
            utf8.encode('Original content'),
          );
          const newData = 'New content';

          // Write original data
          await storageService.writeAsBytes(testPath, originalData);
          final firstRead = await storageService.readAsBytes(testPath);
          expect(utf8.decode(firstRead), equals('Original content'));

          // Overwrite with new data
          await storageService.writeAsString(testPath, newData);
          final secondRead = await storageService.readAsString(testPath);
          expect(secondRead, equals('New content'));
        });
      });

      group('File deletion', () {
        test('should delete existing file', () async {
          const testPath = 'file-to-delete.txt';
          final testData = Uint8List.fromList(utf8.encode('Delete me'));

          // Create file
          await storageService.writeAsBytes(testPath, testData);

          // Verify file exists
          final beforeDelete = await storageService.readAsBytes(testPath);
          expect(beforeDelete, isNotEmpty);

          // Delete file
          await storageService.delete(testPath);

          // Verify file is deleted (OPFS throws NotFoundError which is not a Dart Exception)
          expect(() => storageService.readAsBytes(testPath), throwsA(anything));
        });

        test('should throw when deleting non-existent file', () async {
          expect(
            () => storageService.delete('non-existent-file.txt'),
            throwsA(anything),
          );
        });
      });

      group('Storage clearing', () {
        test('should clear all files', () async {
          final testFiles = {
            'file1.txt': 'Content 1',
            'file2.txt': 'Content 2',
            'file3.txt': 'Content 3',
          };

          // Create multiple files
          for (final entry in testFiles.entries) {
            await storageService.writeAsString(entry.key, entry.value);
          }

          // Verify files exist
          for (final path in testFiles.keys) {
            final data = await storageService.readAsString(path);
            expect(data, equals(testFiles[path]));
          }

          // Clear storage
          await storageService.clear();

          // Verify all files are deleted
          for (final path in testFiles.keys) {
            expect(() => storageService.readAsString(path), throwsA(anything));
            expect(() => storageService.readAsBytes(path), throwsA(anything));
          }
        });

        test('should handle clearing empty storage', () async {
          // Should not throw when clearing empty storage
          await expectLater(storageService.clear(), completes);
        });
      });

      group('Error handling', () {
        test('should throw when reading non-existent file', () async {
          expect(
            () => storageService.readAsBytes('non-existent-file.txt'),
            throwsA(anything),
          );
          expect(
            () => storageService.readAsString('non-existent-file.txt'),
            throwsA(anything),
          );
        });

        test('should handle special characters in file paths', () async {
          const specialPath = 'file with spaces & special-chars_123.txt';
          final testData = 'Special path test';

          await storageService.writeAsString(specialPath, testData);
          final retrievedData = await storageService.readAsString(specialPath);

          expect(retrievedData, equals('Special path test'));
        });

        test('should handle long file paths', () async {
          final longPath = 'very-' * 50 + 'long-filename.txt';
          final testData = 'Long path test';

          await storageService.writeAsString(longPath, testData);

          final retrievedData = await storageService.readAsString(longPath);

          expect(retrievedData, equals('Long path test'));
        });
      });

      group('Large file handling', () {
        test('should handle moderately large files', () async {
          const testPath = 'large-file.bin';
          final largeData = Uint8List(1024 * 100); // 100KB

          // Fill with pattern
          for (int i = 0; i < largeData.length; i++) {
            largeData[i] = i % 256;
          }

          await storageService.writeAsBytes(testPath, largeData);
          final retrievedData = await storageService.readAsBytes(testPath);

          expect(retrievedData.length, equals(largeData.length));
          expect(retrievedData, equals(largeData));
        });
      });

      group('Concurrent operations', () {
        test('should handle concurrent writes to different files', () async {
          final futures = <Future<void>>[];

          for (int i = 0; i < 5; i++) {
            final path = 'concurrent-file-$i.txt';
            final data = 'Content $i';
            futures.add(storageService.writeAsString(path, data));
          }

          await Future.wait(futures);

          // Verify all files written correctly
          for (int i = 0; i < 5; i++) {
            final path = 'concurrent-file-$i.txt';
            final data = await storageService.readAsString(path);
            expect(data, equals('Content $i'));
          }
        });

        test('should handle concurrent reads of same file', () async {
          const testPath = 'concurrent-read-file.txt';
          const testContent = 'Concurrent read test';
          final testData = 'Concurrent read test';

          await storageService.writeAsString(testPath, testData);

          final futures = List.generate(
            5,
            (_) => storageService.readAsString(testPath),
          );

          final results = await Future.wait(futures);

          for (final result in results) {
            expect(result, equals(testContent));
          }
        });
      });
    });
  });
}

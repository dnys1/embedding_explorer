@TestOn('browser')
library;

import 'package:embeddings_explorer/util/indexed_db.dart' as impl;
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  setupTests();

  for (final (name, indexedDB) in [
    ('local IndexedDB', impl.indexedDB),
    ('worker IndexedDB', impl.indexedDB.worker),
  ]) {
    group(name, () {
      tearDown(() async {
        await indexedDB.clearAll();
        await indexedDB.close();
      });

      group('IndexedDB Initialization', () {
        test('should initialize successfully', () async {
          expect(indexedDB.debugIsInitialized, isFalse);
          await indexedDB.initialize();
          expect(indexedDB.debugIsInitialized, isTrue);
        });
      });

      group('IndexedDB Basic Operations', () {
        setUp(() async {
          await indexedDB.initialize();
        });

        test('should store and retrieve a value', () async {
          const key = 'test_key';
          const value = 'test_value';

          await indexedDB.setValue(key, value);
          final retrievedValue = await indexedDB.getValue(key);

          expect(retrievedValue, equals(value));
        });

        test('should return null for non-existent key', () async {
          final value = await indexedDB.getValue('non_existent_key');
          expect(value, isNull);
        });

        test('should update existing value', () async {
          const key = 'test_key';
          const originalValue = 'original_value';
          const newValue = 'new_value';

          await indexedDB.setValue(key, originalValue);
          await indexedDB.setValue(key, newValue);
          final retrievedValue = await indexedDB.getValue(key);

          expect(retrievedValue, equals(newValue));
        });

        test('should remove a value', () async {
          const key = 'test_key';
          const value = 'test_value';

          await indexedDB.setValue(key, value);
          expect(await indexedDB.getValue(key), equals(value));

          await indexedDB.removeValue(key);
          expect(await indexedDB.getValue(key), isNull);
        });

        test('should check if key exists', () async {
          const key = 'test_key';
          const value = 'test_value';

          expect(await indexedDB.hasKey(key), isFalse);

          await indexedDB.setValue(key, value);
          expect(await indexedDB.hasKey(key), isTrue);

          await indexedDB.removeValue(key);
          expect(await indexedDB.hasKey(key), isFalse);
        });
      });

      group('IndexedDB Bulk Operations', () {
        setUp(() async {
          await indexedDB.initialize();
        });

        test('should store and retrieve multiple values', () async {
          final testData = {
            'key1': 'value1',
            'key2': 'value2',
            'key3': 'value3',
          };

          // Store all values
          for (final entry in testData.entries) {
            await indexedDB.setValue(entry.key, entry.value);
          }

          // Retrieve and verify all values
          for (final entry in testData.entries) {
            final retrievedValue = await indexedDB.getValue(entry.key);
            expect(retrievedValue, equals(entry.value));
          }
        });

        test('should get all keys', () async {
          final testKeys = ['key1', 'key2', 'key3'];

          // Store test data
          for (final key in testKeys) {
            await indexedDB.setValue(key, 'value_$key');
          }

          final allKeys = await indexedDB.getAllKeys();
          expect(allKeys, containsAll(testKeys));
          expect(allKeys.length, equals(testKeys.length));
        });

        test('should clear all data', () async {
          final testData = {
            'key1': 'value1',
            'key2': 'value2',
            'key3': 'value3',
          };

          // Store test data
          for (final entry in testData.entries) {
            await indexedDB.setValue(entry.key, entry.value);
          }

          // Verify data exists
          expect(await indexedDB.getAllKeys(), hasLength(testData.length));

          // Clear all data
          await indexedDB.clearAll();

          // Verify data is cleared
          expect(await indexedDB.getAllKeys(), isEmpty);
          for (final key in testData.keys) {
            expect(await indexedDB.getValue(key), isNull);
          }
        });
      });

      group('IndexedDB Storage Size Calculation', () {
        setUp(() async {
          await indexedDB.initialize();
        });

        test('should calculate storage size correctly', () async {
          const key1 = 'short';
          const value1 = 'a';
          const key2 = 'longer_key';
          const value2 = 'longer_value';

          await indexedDB.setValue(key1, value1);
          await indexedDB.setValue(key2, value2);

          final expectedSize =
              key1.length + value1.length + key2.length + value2.length;
          final actualSize = await indexedDB.getStorageSize();

          expect(actualSize, equals(expectedSize));
        });

        test('should return zero size for empty storage', () async {
          final size = await indexedDB.getStorageSize();
          expect(size, equals(0));
        });
      });

      group('IndexedDB Error Handling', () {
        setUp(() async {
          await indexedDB.initialize();
        });

        test(
          'should handle operation failures gracefully',
          skip: 'TODO',
          () async {
            // getValue should return null on failure
            final value = await indexedDB.getValue('test_key');
            expect(value, isNull);

            // setValue should throw on failure
            expect(
              () => indexedDB.setValue('test_key', 'test_value'),
              throwsA(isA<StateError>()),
            );

            // removeValue should not throw on failure
            await indexedDB.removeValue('test_key'); // Should not throw

            // getAllKeys should throw on failure
            expect(() => indexedDB.getAllKeys(), throwsA(isA<StateError>()));

            // getStorageSize should return 0 on failure
            final size = await indexedDB.getStorageSize();
            expect(size, equals(0));
          },
        );
      });

      group('IndexedDB Stress Tests', () {
        setUp(() async {
          await indexedDB.initialize();
        });

        test('should handle large number of keys', () async {
          const keyCount = 100;
          final keys = List.generate(keyCount, (i) => 'key_$i');

          // Store all keys
          for (final key in keys) {
            await indexedDB.setValue(key, 'value_$key');
          }

          // Verify all keys exist
          final allKeys = await indexedDB.getAllKeys();
          expect(allKeys, hasLength(keyCount));
          for (final key in keys) {
            expect(allKeys, contains(key));
          }

          // Verify all values can be retrieved
          for (final key in keys) {
            final value = await indexedDB.getValue(key);
            expect(value, equals('value_$key'));
          }
        });

        test('should handle large values', () async {
          const key = 'large_data';
          final largeValue = 'x' * 10000; // 10KB string

          await indexedDB.setValue(key, largeValue);
          final retrievedValue = await indexedDB.getValue(key);

          expect(retrievedValue, equals(largeValue));
          expect(retrievedValue?.length, equals(10000));
        });

        test('should handle special characters in keys and values', () async {
          final testCases = {
            'key with spaces': 'value with spaces',
            'key-with-dashes': 'value-with-dashes',
            'key_with_underscores': 'value_with_underscores',
            'key.with.dots': 'value.with.dots',
            'key/with/slashes': 'value/with/slashes',
            'key:with:colons': 'value:with:colons',
            'keyWithUnicode🚀': 'valueWithUnicode🎉',
            'key\nwith\nnewlines': 'value\nwith\nnewlines',
            'key\twith\ttabs': 'value\twith\ttabs',
          };

          for (final entry in testCases.entries) {
            await indexedDB.setValue(entry.key, entry.value);
            final retrievedValue = await indexedDB.getValue(entry.key);
            expect(
              retrievedValue,
              equals(entry.value),
              reason: 'Failed for key: ${entry.key}',
            );
          }
        });
      });

      group('IndexedDB JSON Data Tests', () {
        setUp(() async {
          await indexedDB.initialize();
        });

        test('should handle JSON data', () async {
          const key = 'json_data';
          const jsonValue =
              '{"name":"test","value":123,"nested":{"key":"value"}}';

          await indexedDB.setValue(key, jsonValue);
          final retrievedValue = await indexedDB.getValue(key);

          expect(retrievedValue, equals(jsonValue));
        });

        test('should handle complex configuration data', () async {
          const key = 'config_data';
          const configValue = '''
{
  "id": "config_123",
  "name": "Test Configuration",
  "settings": {
    "apiKey": "abc123",
    "timeout": 5000,
    "retries": 3,
    "features": ["feature1", "feature2", "feature3"]
  },
  "metadata": {
    "created": "2025-09-09T00:00:00Z",
    "updated": "2025-09-09T12:00:00Z",
    "version": "1.0.0"
  }
}''';

          await indexedDB.setValue(key, configValue);
          final retrievedValue = await indexedDB.getValue(key);

          expect(retrievedValue, equals(configValue));
        });
      });

      group('IndexedDB Concurrent Operations', () {
        setUp(() async {
          await indexedDB.initialize();
        });

        test('should handle concurrent writes', () async {
          final futures = <Future<void>>[];

          // Perform multiple concurrent writes
          for (int i = 0; i < 10; i++) {
            futures.add(indexedDB.setValue('concurrent_key_$i', 'value_$i'));
          }

          await Future.wait(futures);

          // Verify all values were written
          for (int i = 0; i < 10; i++) {
            final value = await indexedDB.getValue('concurrent_key_$i');
            expect(value, equals('value_$i'));
          }
        });

        test('should handle concurrent reads', () async {
          // First, store some test data
          for (int i = 0; i < 5; i++) {
            await indexedDB.setValue('read_key_$i', 'read_value_$i');
          }

          // Perform multiple concurrent reads
          final futures = <Future<String?>>[];
          for (int i = 0; i < 5; i++) {
            futures.add(indexedDB.getValue('read_key_$i'));
          }

          final results = await Future.wait(futures);

          // Verify all reads returned correct values
          for (int i = 0; i < 5; i++) {
            expect(results[i], equals('read_value_$i'));
          }
        });
      });
    });
  }
}

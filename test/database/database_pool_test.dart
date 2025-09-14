@TestOn('browser')
library;

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:embeddings_explorer/database/database.dart';
import 'package:embeddings_explorer/database/database_pool.dart';
import 'package:sqlite3/common.dart';
import 'package:test/test.dart';

import '../common.dart';

void main() {
  setupTests();

  group('DatabasePool', () {
    late DatabasePool pool;

    setUp(() async {
      pool = await DatabasePool.create(
        libsqlUri: testLibsqlUri,
        name: 'test_${Random().nextInt(10000)}',
        clearOnInit: true,
      );
    });

    tearDown(() async {
      try {
        await pool.wipeAll();
      } on Object {
        // OK, may already be disposed
      }
      await pool.dispose();
    });

    group('database lifecycle', () {
      test('opens and closes database', () async {
        const filename = 'test.db';

        // Open database
        final db = await pool.open(filename);
        expect(db.filename, equals(filename));
        expect(pool.databaseNames, contains(filename));

        // Close database
        await db.close();
      });

      test('opens same database returns same instance', () async {
        const filename = 'test.db';

        final db1 = await pool.open(filename);
        final db2 = await pool.open(filename);

        expect(identical(db1, db2), isTrue);

        await db1.close();
      });

      test('opens database with verbose flag', () async {
        const filename = 'verbose_test.db';

        final db = await pool.open(filename, verbose: true);
        expect(db.filename, equals(filename));

        await db.close();
      });
    });

    group('import and export', () {
      test('imports and exports database successfully', () async {
        const filename = 'imported_test.db';

        // Import test database
        final db = await pool.import(filename: filename, data: testDbData);
        expect(db.filename, equals(filename));
        expect(pool.databaseNames, contains(filename));

        // Verify imported data
        final rows = await db.select('SELECT * FROM test_table ORDER BY id');
        expect(rows, hasLength(2));
        expect(rows[0]['name'], equals('Test Item 1'));
        expect(rows[1]['name'], equals('Test Item 2'));

        await db.close();

        // Export database
        final exportedData = await pool.export(filename);
        expect(exportedData, isNotEmpty);
        expect(exportedData, isA<Uint8List>());
      });

      test('throws when importing to already open database', () async {
        const filename = 'conflict_test.db';

        // Open database first
        final db = await pool.open(filename);

        // Try to import to same filename
        expect(
          () => pool.import(filename: filename, data: testDbData),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Database already open'),
            ),
          ),
        );

        await db.close();
      });

      test('throws when exporting non-existent database', () async {
        expect(
          () => pool.export('non_existent.db'),
          throwsA(
            isA<SqliteException>().having(
              (e) => e.message,
              'message',
              contains('File not found'),
            ),
          ),
        );
      });

      test('closes database before export', () async {
        const filename = 'export_test.db';

        // Import and open database
        final originalDb = await pool.import(
          filename: filename,
          data: testDbData,
        );
        expect(pool.databaseNames, contains(filename));

        // Export should close the database automatically
        final exportedData = await pool.export(filename);
        expect(exportedData, isNotEmpty);

        // Database should be closed and removed from internal map
        final newDb = await pool.open(filename);
        addTearDown(newDb.close);
        expect(newDb, isNot(same(originalDb)));
      });
    });

    group('database operations', () {
      late DatabaseHandle db;

      setUp(() async {
        const filename = 'operations_test.db';
        db = await pool.import(filename: filename, data: testDbData);
      });

      tearDown(() async {
        await db.close();
      });

      test('executes SQL statements', () async {
        final result = await db.execute(
          'INSERT INTO test_table (name) VALUES (?)',
          ['Test Item 3'],
        );

        expect(result.lastInsertRowId, equals(3));
        expect(result.updatedRows, equals(1));
      });

      test('executes SQL with multiple parameters', () async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS multi_param_test (id INTEGER, name TEXT, value INTEGER)',
        );

        final result = await db.execute(
          'INSERT INTO multi_param_test (id, name, value) VALUES (?, ?, ?)',
          [1, 'test', 42],
        );

        expect(result.updatedRows, equals(1));
      });

      test('selects data from database', () async {
        final rows = await db.select('SELECT * FROM test_table ORDER BY id');

        expect(rows, hasLength(2));
        expect(rows[0]['id'], equals(1));
        expect(rows[0]['name'], equals('Test Item 1'));
        expect(rows[1]['id'], equals(2));
        expect(rows[1]['name'], equals('Test Item 2'));
      });

      test('selects data with parameters', () async {
        final rows = await db.select(
          'SELECT * FROM test_table WHERE name = ?',
          ['Test Item 1'],
        );

        expect(rows, hasLength(1));
        expect(rows[0]['name'], equals('Test Item 1'));
      });

      test('returns empty result for no matches', () async {
        final rows = await db.select(
          'SELECT * FROM test_table WHERE name = ?',
          ['Non-existent Item'],
        );

        expect(rows, isEmpty);
      });

      test('executes transactions', () async {
        await db.transaction((TransactionExecutor tx) {
          tx.execute('INSERT INTO test_table (name) VALUES (?)', ['Item A']);
          tx.execute('INSERT INTO test_table (name) VALUES (?)', ['Item B']);
          tx.execute('UPDATE test_table SET name = ? WHERE name = ?', [
            'Item C',
            'Item A',
          ]);
        });

        final rows = await db.select(
          'SELECT name FROM test_table WHERE id > 2 ORDER BY id',
        );
        expect(rows, hasLength(2));
        expect(rows[0]['name'], equals('Item C'));
        expect(rows[1]['name'], equals('Item B'));
      });

      test('executes empty transaction', () async {
        // Should not throw
        await db.transaction((TransactionExecutor tx) {
          // Empty transaction
        });
      });
    });

    group('database deletion', () {
      test('deletes existing database', () async {
        const filename = 'delete_test.db';

        // Import database
        final db = await pool.import(filename: filename, data: testDbData);
        expect(pool.databaseNames, contains(filename));
        await db.close();

        // Delete database
        final deleted = await pool.delete(filename);
        expect(deleted, isTrue);
        expect(pool.databaseNames, isNot(contains(filename)));
      });

      test('returns false when deleting non-existent database', () async {
        final deleted = await pool.delete('non_existent.db');
        expect(deleted, isFalse);
      });

      test('closes database before deletion', () async {
        const filename = 'delete_open_test.db';

        // Import and keep database open
        await pool.import(filename: filename, data: testDbData);
        expect(pool.databaseNames, contains(filename));

        // Delete should close the database automatically
        final deleted = await pool.delete(filename);
        expect(deleted, isTrue);
        expect(pool.databaseNames, isNot(contains(filename)));
      });
    });

    group('wipe operations', () {
      test('wipes all databases', () async {
        // Create multiple databases
        await pool.import(filename: 'test1.db', data: testDbData);
        await pool.import(filename: 'test2.db', data: testDbData);
        final db3 = await pool.open('test3.db');

        expect(pool.databaseNames, hasLength(3));
        expect(pool.fileCount, greaterThan(0));

        await db3.close();

        // Wipe all
        await pool.wipeAll();

        expect(pool.databaseNames, isEmpty);
        expect(pool.fileCount, equals(0));
      });

      test('wipes all with open databases', () async {
        // Create databases and keep some open
        await pool.import(filename: 'wipe1.db', data: testDbData);
        await pool.import(filename: 'wipe2.db', data: testDbData);

        expect(pool.databaseNames, hasLength(2));

        // Wipe should close databases automatically
        await pool.wipeAll();

        expect(pool.databaseNames, isEmpty);
        expect(pool.fileCount, equals(0));
      });
    });

    group('stats and metadata', () {
      test('provides database stats', () async {
        expect(pool.databaseNames, isA<List<String>>());
        expect(pool.reservedCapacity, isA<int>());
        expect(pool.fileCount, isA<int>());
        expect(pool.vfsName, isA<String>());
        expect(pool.vfsName, isNotEmpty);
      });

      test('filters out configurations.db from database names', () async {
        // This test assumes configurations.db might be present in some scenarios
        // and verifies it's filtered out
        final names = pool.databaseNames;
        expect(names, isNot(contains('configurations.db')));
      });

      test('updates stats after operations', () async {
        final initialCount = pool.fileCount;

        await pool.import(filename: 'stats_test.db', data: testDbData);
        expect(pool.fileCount, greaterThan(initialCount));

        await pool.delete('stats_test.db');
        expect(pool.fileCount, equals(initialCount));
      });
    });

    group('disposal', () {
      test('disposes pool properly', () async {
        // Use the pool
        await pool.import(filename: 'dispose_test.db', data: testDbData);
        expect(pool.databaseNames, hasLength(1));

        await pool.wipeAll();

        // Dispose
        await pool.dispose();

        // Multiple dispose calls should not throw
        await pool.dispose();
      });
    });

    group('error handling', () {
      test('handles malformed SQL gracefully', () async {
        const filename = 'sql_error_test.db';
        final db = await pool.import(filename: filename, data: testDbData);

        // These should throw SQL-related errors, not communication errors
        await expectLater(
          () => db.execute('INVALID SQL STATEMENT'),
          throwsA(isA<SqliteException>()),
        );

        await expectLater(
          () => db.select('INVALID SELECT STATEMENT'),
          throwsA(isA<SqliteException>()),
        );

        await expectLater(
          () => db.transaction((tx) {
            tx.execute('INSERT INTO test_table (id, name) VALUES (?, ?)', [1]);
          }),
          throwsA(isA<SqliteException>()),
        );

        await db.close();
      });
    });

    group('concurrent operations', () {
      test('handles multiple concurrent database operations', () async {
        const filename = 'concurrent_test.db';
        final db = await pool.import(filename: filename, data: testDbData);

        final (
          selectResult1,
          selectResult2,
          executeResult1,
          executeResult2,
        ) = await (
          Future.value(db.select('SELECT * FROM test_table WHERE id = 1')),
          Future.value(db.select('SELECT * FROM test_table WHERE id = 2')),
          Future.value(
            db.execute('INSERT INTO test_table (name) VALUES (?)', [
              'Concurrent 1',
            ]),
          ),
          Future.value(
            db.execute('INSERT INTO test_table (name) VALUES (?)', [
              'Concurrent 2',
            ]),
          ),
        ).wait;

        // Verify select results
        expect(selectResult1.length, equals(1));
        expect(selectResult2.length, equals(1));

        // Verify insert results
        expect(executeResult1.updatedRows, equals(1));
        expect(executeResult2.updatedRows, equals(1));

        // Verify final state
        final allRows = await db.select('SELECT * FROM test_table ORDER BY id');
        expect(allRows.length, equals(4));

        await db.close();
      });

      test('handles concurrent database creation and deletion', () async {
        final futures = [
          pool.import(filename: 'concurrent1.db', data: testDbData),
          pool.import(filename: 'concurrent2.db', data: testDbData),
          pool.import(filename: 'concurrent3.db', data: testDbData),
        ];

        final databases = await Future.wait(futures);
        expect(databases.length, equals(3));
        expect(pool.databaseNames.length, equals(3));

        // Delete concurrently
        final deleteFutures = [
          pool.delete('concurrent1.db'),
          pool.delete('concurrent2.db'),
          pool.delete('concurrent3.db'),
        ];

        final deleteResults = await Future.wait(deleteFutures);
        expect(deleteResults.every((result) => result), isTrue);
        expect(pool.databaseNames, isEmpty);
      });
    });

    group('edge cases', () {
      test('handles very large database operations', () async {
        const filename = 'large_test.db';
        final db = await pool.import(filename: filename, data: testDbData);

        // Create table with many columns
        await db.execute('''
          CREATE TABLE large_table (
            id INTEGER PRIMARY KEY,
            col1 TEXT, col2 TEXT, col3 TEXT, col4 TEXT, col5 TEXT,
            col6 TEXT, col7 TEXT, col8 TEXT, col9 TEXT, col10 TEXT
          )
        ''');

        // Insert many rows
        await db.transaction((TransactionExecutor tx) {
          for (int i = 0; i < 100; i++) {
            tx.execute(
              'INSERT INTO large_table (col1, col2, col3, col4, col5, col6, col7, col8, col9, col10) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
              [
                'val$i',
                'val$i',
                'val$i',
                'val$i',
                'val$i',
                'val$i',
                'val$i',
                'val$i',
                'val$i',
                'val$i',
              ],
            );
          }
        });

        // Query large result set
        final rows = await db.select('SELECT * FROM large_table');
        expect(rows.length, equals(100));

        await db.close();
      });

      test('handles special characters in database names', () async {
        const filename = 'test-with-dashes_and_underscores.db';

        final db = await pool.open(filename);
        expect(db.filename, equals(filename));
        expect(pool.databaseNames, contains(filename));

        await db.close();

        final deleted = await pool.delete(filename);
        expect(deleted, isTrue);
      });

      test('handles empty SQL statements gracefully', () async {
        const filename = 'empty_sql_test.db';
        final db = await pool.import(filename: filename, data: testDbData);

        // Empty SQL should not crash
        expect(() => db.execute(''), throwsA(isA<Exception>()));

        expect(() => db.select(''), throwsA(isA<Exception>()));

        await db.close();
      });
    });

    group('data integrity', () {
      test('maintains data consistency across operations', () async {
        const filename = 'integrity_test.db';
        final db = await pool.import(filename: filename, data: testDbData);

        // Verify initial data
        var rows = await db.select('SELECT COUNT(*) as count FROM test_table');
        expect(rows[0]['count'], equals(2));

        // Perform multiple operations
        await db.execute('INSERT INTO test_table (name) VALUES (?)', [
          'New Item',
        ]);
        await db.execute('UPDATE test_table SET name = ? WHERE id = 1', [
          'Updated Item',
        ]);
        await db.execute('DELETE FROM test_table WHERE id = 2');

        // Verify final state
        rows = await db.select('SELECT * FROM test_table ORDER BY id');
        expect(rows.length, equals(2));
        expect(rows[0]['name'], equals('Updated Item'));
        expect(rows[1]['name'], equals('New Item'));

        await db.close();

        // Export and re-import to verify persistence
        final exportedData = await pool.export(filename);
        await pool.delete(filename);

        final newDb = await pool.import(filename: filename, data: exportedData);
        rows = await newDb.select('SELECT * FROM test_table ORDER BY id');
        expect(rows.length, equals(2));
        expect(rows[0]['name'], equals('Updated Item'));
        expect(rows[1]['name'], equals('New Item'));

        await newDb.close();
      });

      test('handles transaction rollback scenarios', () async {
        const filename = 'rollback_test.db';
        final db = await pool.import(filename: filename, data: testDbData);

        // Verify initial count
        var rows = await db.select('SELECT COUNT(*) as count FROM test_table');
        final initialCount = rows[0]['count'] as int;

        // Transaction that should fail (assuming foreign key or constraint)
        await expectLater(
          () => db.transaction((tx) {
            tx.execute('INSERT INTO test_table (name) VALUES (?)', ['Item A']);
            tx.execute('INSERT INTO test_table (name) VALUES (?)', ['Item B']);
            // This might fail depending on database constraints
            tx.execute('INSERT INTO test_table (id, name) VALUES (?, ?)', [
              1,
              'Duplicate ID',
            ]);
          }),
          throwsA(isA<SqliteException>()),
        );

        // Verify count is unchanged or properly managed
        rows = await db.select('SELECT COUNT(*) as count FROM test_table');
        // The count might have increased if the transaction succeeded
        expect(rows[0]['count'], equals(initialCount));

        await db.close();
      });
    });
  });
}

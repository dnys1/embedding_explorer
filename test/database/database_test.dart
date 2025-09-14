@TestOn('browser')
library;

import 'package:embeddings_explorer/database/database.dart';
import 'package:sqlite3/common.dart' show SqliteException;
import 'package:test/test.dart';

import '../common.dart';

void main() {
  setupTests();

  group('Database', () {
    late IDatabase db;

    setUp(() async {
      db = await IDatabase.open(':memory:', moduleUri: testLibsqlUri);
    });

    tearDown(() {
      return db.close();
    });

    group('Basic Connection and Setup', () {
      test('can handle dispose correctly', () async {
        await db.close();

        // Should throw after disposal
        await expectLater(() async => db.execute('SELECT 1'), throwsStateError);
        await expectLater(() async => db.select('SELECT 1'), throwsStateError);
      });
    });

    group('SQL Execution', () {
      test('can execute simple SQL statements', () async {
        await db.execute(
          'CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)',
        );
      });

      test('can execute INSERT statements and track changes', () async {
        var result = await db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)',
        );

        expect(result.updatedRows, equals(0));

        result = await db.execute('INSERT INTO users (name) VALUES (?)', [
          'John Doe',
        ]);

        expect(result.updatedRows, greaterThan(0));
        expect(result.lastInsertRowId, equals(1));
      });
    });

    group('SQL Queries', () {
      test('can execute simple SELECT queries', () async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            age INTEGER
          )
        ''');

        await db.execute('INSERT INTO users (name, age) VALUES (?, ?)', [
          'Alice',
          25,
        ]);
        await db.execute('INSERT INTO users (name, age) VALUES (?, ?)', [
          'Bob',
          30,
        ]);

        final result = await db.select('SELECT * FROM users');

        expect(
          result,
          unorderedEquals([
            {'id': 1, 'name': 'Alice', 'age': 25},
            {'id': 2, 'name': 'Bob', 'age': 30},
          ]),
        );
      });
    });

    group('Parameter Binding', () {
      test('can bind different parameter types', () async {
        await db.execute(
          'CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT)',
        );

        // Test string parameter
        await db.execute('INSERT INTO test (value) VALUES (?)', [
          'Hello World',
        ]);

        // Test integer parameter
        await db.execute('INSERT INTO test (value) VALUES (?)', [42]);

        // Test null parameter
        await db.execute('INSERT INTO test (value) VALUES (?)', [null]);

        final result = await db.select('SELECT value FROM test ORDER BY id');

        expect(result, hasLength(3));
        expect(result[0]['value'], equals('Hello World'));
        expect(
          result[1]['value'],
          equals('42'),
        ); // SQLite stores numbers as text when column is TEXT
        expect(result[2]['value'], isNull);
      });
    });

    group('Error Handling', () {
      test('throws exception for SQL syntax errors', () async {
        await expectLater(
          () async => db.execute('SELCT * FROM nonexistent'),
          throwsA(isA<SqliteException>()),
        );

        db.close();
      });

      test('throws exception for table not found', () async {
        await expectLater(
          () async => db.select('SELECT * FROM nonexistent_table'),
          throwsA(isA<SqliteException>()),
        );
      });
    });

    group('Data Types', () {
      test('can handle different data types', () async {
        await db.execute('''
          CREATE TABLE data_types (
            id INTEGER PRIMARY KEY,
            int_val INTEGER,
            real_val REAL,
            text_val TEXT,
            null_val TEXT
          )
        ''');

        await db.execute(
          '''
          INSERT INTO data_types (int_val, real_val, text_val, null_val)
          VALUES (?, ?, ?, ?)
        ''',
          [42, 3.14159, 'Hello World', null],
        );

        final result = await db.select('SELECT * FROM data_types');

        expect(result[0]['int_val'], equals(42));
        expect(result[0]['real_val'], closeTo(3.14159, 0.00001));
        expect(result[0]['text_val'], equals('Hello World'));
        expect(result[0]['null_val'], isNull);
      });

      test('can handle unicode text correctly', () async {
        await db.execute(
          'CREATE TABLE unicode_test (id INTEGER PRIMARY KEY, text TEXT)',
        );

        const unicodeText = '🌍🌎🌏 Hello 世界 مرحبا العالم';
        await db.execute('INSERT INTO unicode_test (text) VALUES (?)', [
          unicodeText,
        ]);

        final result = await db.select('SELECT text FROM unicode_test');
        expect(result[0]['text'], equals(unicodeText));
      });
    });
  });
}

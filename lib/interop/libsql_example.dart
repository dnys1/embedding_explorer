import 'dart:convert';

import 'package:embeddings_explorer/interop/libsql.dart'
    as libsql
    show loadModule;
import 'package:embeddings_explorer/interop/libsql.dart';

void main() async {
  print('Loading libsql-wasm...');
  await libsql.loadModule();
  print('Loaded libsql-wasm.');
  final database = Database();
  print('Created database: ${database.dbName()}');
  database.affirmOpen();
  database.exec(
    sql: '''
    CREATE TABLE IF NOT EXISTS items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      content TEXT NOT NULL
    );
  ''',
  );
  print('Created table "items".');
  database.exec(
    sql: '''
    INSERT INTO items (content) VALUES ('Hello, world!');
    INSERT INTO items (content) VALUES ('This is a test.');
    INSERT INTO items (content) VALUES ('Goodbye, world!');
  ''',
  );
  print('Inserted 3 rows.');
  final rows = database.query(sql: 'SELECT * FROM items;');
  print('Queried rows:');
  for (final row in rows) {
    print(' - ${jsonEncode(row)}');
  }
}

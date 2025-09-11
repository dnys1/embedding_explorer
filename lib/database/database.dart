import 'package:sqlite3/common.dart';
import 'package:sqlite3/wasm.dart' as sqlite3;

import '../interop/common.dart';
import '../interop/libsql.dart' as libsql;
import 'prepared_statement.dart';

/// Platform-specific LibSQL database implementation for Web/JS.
///
/// This implementation uses WASM bindings to provide LibSQL functionality
/// in web browsers.
class LibsqlDatabase extends CommonDatabase {
  final libsql.Database _db;
  bool get _disposed => !_db.isOpen();

  LibsqlDatabase._(this._db);

  /// Creates a LibSQL database from a file path.
  ///
  /// On Web platforms, this creates an in-memory database if path is ':memory:',
  /// otherwise attempts to use the provided path (may not be supported in all environments).
  /// The WASM module is automatically initialized before creating the database.
  static Future<LibsqlDatabase> open(String path, [Uri? moduleUri]) async {
    await libsql.loadModule();
    final db = libsql.Database(filename: path);
    db.affirmOpen();
    return LibsqlDatabase._(db);
  }

  /// Creates a LibSQL database connection to a remote server.
  ///
  /// On Web platforms, this currently throws an UnimplementedError.
  /// Future implementation will use fetch API to connect to LibSQL servers.
  static Future<LibsqlDatabase> remote(
    String url, {
    String? authToken,
    Uri? moduleUri,
  }) async {
    throw UnimplementedError(
      'Remote database connections not yet implemented for Web platform',
    );
  }

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('Database has been disposed');
    }
  }

  @override
  bool get autocommit {
    _checkNotDisposed();
    // WASM SQLite is always in autocommit mode by default unless in a transaction
    return true; // Simplified assumption
  }

  @override
  void execute(String sql, [List<Object?> parameters = const []]) {
    _checkNotDisposed();
    _db.exec(sql: sql, bind: parameters);
  }

  @override
  sqlite3.ResultSet select(String sql, [List<Object?> parameters = const []]) {
    _checkNotDisposed();
    final rows = _db.query(sql: sql, bind: parameters);

    final columnNames = rows.isNotEmpty ? rows.first.keys.toList() : <String>[];

    final rowsList = rows.map((row) {
      return columnNames.map((col) => row[col]).toList();
    }).toList();

    return sqlite3.ResultSet(columnNames, null, rowsList);
  }

  @override
  void dispose() {
    if (!_disposed) {
      _db.close();
    }
  }

  @override
  int getUpdatedRows() {
    _checkNotDisposed();
    return _db.changes().toInt();
  }

  @override
  int get lastInsertRowId {
    _checkNotDisposed();
    return _db.lastInsertRowid().toInt();
  }

  @override
  sqlite3.CommonPreparedStatement prepare(
    String sql, {
    bool persistent = false,
    bool vtab = true,
    bool checkNoTail = false,
  }) {
    _checkNotDisposed();
    final stmt = _db.prepare(sql);
    return LibsqlPreparedStatement(stmt);
  }

  @override
  int get updatedRows => getUpdatedRows();

  T transaction<T>(T Function(LibsqlDatabase tx) action) {
    _checkNotDisposed();
    T? ret;
    _db.transaction((db) {
      ret = action(LibsqlDatabase._(db));
    });
    return ret as T;
  }

  // Properties that are not yet implemented in WASM or not available

  @override
  sqlite3.VoidPredicate? commitFilter;

  @override
  Stream<void> get commits => throw UnimplementedError(
    'Commit notifications not supported in Web implementation',
  );

  @override
  sqlite3.DatabaseConfig get config => throw UnimplementedError(
    'Database config not supported in Web implementation',
  );

  @override
  void createAggregateFunction<V>({
    required String functionName,
    required sqlite3.AggregateFunction<V> function,
    sqlite3.AllowedArgumentCount? argumentCount,
    bool directOnly = true,
    bool deterministic = false,
    bool subtype = false,
  }) {
    throw UnimplementedError(
      'Custom aggregate functions not supported in Web implementation',
    );
  }

  @override
  void createCollation({
    required String name,
    required int Function(String?, String?) function,
  }) {
    throw UnimplementedError(
      'Custom collations not supported in Web implementation',
    );
  }

  @override
  void createFunction({
    required String functionName,
    required Object? Function(sqlite3.SqliteArguments) function,
    sqlite3.AllowedArgumentCount? argumentCount,
    bool directOnly = true,
    bool deterministic = false,
    bool subtype = false,
  }) {
    throw UnimplementedError(
      'Custom functions not supported in Web implementation',
    );
  }

  @override
  int userVersion = 0;

  @override
  List<sqlite3.CommonPreparedStatement> prepareMultiple(
    String sql, {
    bool persistent = false,
    bool vtab = true,
  }) {
    throw UnimplementedError(
      'Multiple prepared statements not yet implemented for Web platform',
    );
  }

  @override
  Stream<void> get rollbacks => throw UnimplementedError(
    'Rollback notifications not supported in Web implementation',
  );

  @override
  Stream<sqlite3.SqliteUpdate> get updates => throw UnimplementedError(
    'Update notifications not supported in Web implementation',
  );

  @override
  Stream<sqlite3.SqliteUpdate> get updatesSync => throw UnimplementedError(
    'Update notifications not supported in Web implementation',
  );
}

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:sqlite3/wasm.dart' as sqlite3;
import 'package:worker_bee/worker_bee.dart';

import '../interop/libsql.dart' as libsql;
import '../workers/libsql_worker.dart';

abstract interface class Database {
  static final Logger _logger = Logger('LibsqlDatabase');

  /// Creates a LibSQL database from a file path.
  ///
  /// On Web platforms, this creates an in-memory database if path is ':memory:',
  /// otherwise attempts to use the provided path (may not be supported in all environments).
  /// The WASM module is automatically initialized before creating the database.
  static Future<Database> open(
    String path, {
    Uri? moduleUri,
    bool isWorker = false,
  }) async {
    await libsql.loadModule(moduleUri: moduleUri);
    if (path == ':memory:') {
      return Database.memory();
    } else if (isWorker) {
      return Database.opfs(path);
    } else {
      if (!isWorker) {
        try {
          return await Database.worker(path: path, moduleUri: moduleUri);
        } catch (e) {
          _logger.warning('Failed to spawn worker', e);
        }
      }
      return Database.local(path);
    }
  }

  /// Creates an in-memory LibSQL database.
  factory Database.memory() {
    _logger.config('Initializing in-memory LibSQL database');
    return _Database._(libsql.Database());
  }

  /// Creates a LibSQL database using the OPFS VFS at the given path.
  ///
  /// **NOTE**: This can only be used in environments that support OPFS, and
  /// requires APIs only available in workers. If OPFS is not supported, an
  /// [UnsupportedError] is thrown.
  factory Database.opfs(String path) {
    if (!libsql.supportsOpfs) {
      throw UnsupportedError('OPFS is not supported in this environment');
    }
    _logger.config('Initializing LibSQL OPFS database at $path');
    return _Database._(
      libsql.Database(filename: path, flags: 'c', vfs: 'opfs'),
    );
  }

  /// Creates a LibSQL database using the browser's local storage.
  factory Database.local(String path) {
    _logger.config('Initializing LibSQL local database at $path');
    return _Database._(libsql.Database(filename: path, flags: 'c'));
  }

  /// Creates a LibSQL database accessed via a worker.
  ///
  /// This is useful for accessing persistent databases in environments that
  /// support OPFS, as the OPFS VFS requires worker context.
  ///
  /// The [moduleUri] can be provided to specify the location of the WASM module
  /// to be used by the worker.
  static Future<Database> worker({required String path, Uri? moduleUri}) {
    _logger.config('Initializing LibSQL worker for $path');
    return DatabaseWorker.spawn(filename: path, moduleUri: moduleUri);
  }

  FutureOr<void> execute(String sql, [List<Object?> parameters = const []]);
  FutureOr<sqlite3.ResultSet> select(
    String sql, [
    List<Object?> parameters = const [],
  ]);
  Future<T> transaction<T>(FutureOr<T> Function(Database tx) action);
  FutureOr<void> dispose();
}

/// Platform-specific LibSQL database implementation for Web/JS.
///
/// This implementation uses WASM bindings to provide LibSQL functionality
/// in web browsers.
class _Database implements Database {
  final libsql.Database _db;
  bool get _disposed => !_db.isOpen();

  _Database._(this._db) {
    _db.affirmOpen();
  }

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('Database has been disposed');
    }
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
  Future<T> transaction<T>(FutureOr<T> Function(Database tx) action) async {
    _checkNotDisposed();
    T? ret;
    _db.transaction((db) {
      ret = action(_Database._(db)) as T;
    });
    return ret as T;
  }
}

class DatabaseWorker implements Database {
  DatabaseWorker._(this._worker);

  static final Logger _localLogger = Logger('Database');
  static final Logger _remoteLogger = Logger('Database.Worker');

  final LibsqlWorker _worker;
  StreamSubscription<LogRecord>? _logSubscription;
  var _nextRequestId = 1;

  static Future<DatabaseWorker> spawn({
    required String filename,
    Uri? moduleUri,
  }) async {
    final worker = DatabaseWorker._(LibsqlWorker.create());
    await worker._init(filename: filename, moduleUri: moduleUri);
    return worker;
  }

  Future<void> _init({required String filename, Uri? moduleUri}) async {
    _logSubscription = _worker.logs.listen((record) {
      final logger = record is WorkerLogRecord && record.local == false
          ? _remoteLogger
          : _localLogger;
      logger.log(record.level, record.message, record.error, record.stackTrace);
    });

    try {
      await _worker.spawn().timeout(const Duration(seconds: 10));
    } on Object {
      await _worker.close(force: true);
    }

    final requestId = _nextRequestId++;
    _worker.add(
      LibsqlRequest.init(
        requestId: requestId,
        filename: filename,
        moduleUri: moduleUri,
      ),
    );
    await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
  }

  var _disposed = false;

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('Database has been disposed');
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    unawaited(_logSubscription?.cancel());
    _logSubscription = null;
    await _worker.close();
  }

  @override
  Future<void> execute(
    String sql, [
    List<Object?> parameters = const [],
  ]) async {
    _checkNotDisposed();
    final requestId = _nextRequestId++;
    _worker.add(
      LibsqlRequest(
        requestId: requestId,
        type: LibsqlRequestType.execute,
        sql: sql,
        parameters: parameters,
      ),
    );
    await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
  }

  @override
  Future<sqlite3.ResultSet> select(
    String sql, [
    List<Object?> parameters = const [],
  ]) async {
    _checkNotDisposed();
    final requestId = _nextRequestId++;
    _worker.add(
      LibsqlRequest(
        requestId: requestId,
        type: LibsqlRequestType.query,
        sql: sql,
        parameters: parameters,
      ),
    );
    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    return sqlite3.ResultSet(
      response.columnNames.toList(),
      null,
      response.rows.map((e) => e.toList()).toList(),
    );
  }

  @override
  Future<T> transaction<T>(
    FutureOr<T> Function(DatabaseWorker tx) action,
  ) async {
    _checkNotDisposed();
    await execute('BEGIN');
    try {
      final result = await action(this);
      await execute('COMMIT');
      return result;
    } catch (e) {
      await execute('ROLLBACK');
      rethrow;
    }
  }
}

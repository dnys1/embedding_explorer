import 'dart:async';
import 'dart:js_interop';

import 'package:logging/logging.dart';
import 'package:sqlite3/wasm.dart' show ResultSet, SqliteException;
import 'package:worker_bee/worker_bee.dart';

import '../interop/common.dart';
import '../interop/libsql.dart' as libsql;
import '../workers/database_worker.dart';
import 'transaction.dart';

typedef ExecResult = ({int lastInsertRowId, int updatedRows});

abstract class DatabaseHandle implements TransactionExecutor {
  String get filename;

  @override
  FutureOr<ExecResult> execute(
    String sql, [
    List<Object?> parameters = const [],
  ]);
  FutureOr<List<Map<String, Object?>>> select(
    String sql, [
    List<Object?> parameters = const [],
  ]);
  FutureOr<void> transaction(void Function(TransactionExecutor tx) action);
  FutureOr<void> close();
}

abstract interface class TransactionExecutor {
  void execute(String sql, [List<Object?> parameters = const []]);
}

/// Platform-specific LibSQL database implementation for Web/JS.
///
/// This implementation uses WASM bindings to provide LibSQL functionality
/// in web browsers.
class Database implements DatabaseHandle {
  static final Logger _logger = Logger('Database');

  /// Creates a LibSQL database from a file path.
  ///
  /// On Web platforms, this creates an in-memory database if path is ':memory:',
  /// otherwise attempts to use the provided path (may not be supported in all environments).
  /// The WASM module is automatically initialized before creating the database.
  static Future<DatabaseHandle> open(
    String path, {
    Uri? libsqlUri,
    bool verbose = false,
  }) async {
    await libsql.loadModule(moduleUri: libsqlUri);
    if (path == ':memory:') {
      return Database.memory(verbose: verbose);
    } else if (libsql.supportsOpfs) {
      return Database.opfs(path, verbose: verbose);
    } else {
      if (!kIsWorker) {
        try {
          return await Database.worker(
            filename: path,
            libsqlUri: libsqlUri,
            verbose: verbose,
          );
        } catch (e) {
          _logger.warning('Failed to spawn worker', e);
        }
      }
      return Database.local(path, verbose: verbose);
    }
  }

  /// Creates a LibSQL database accessed via a worker.
  ///
  /// This is useful for accessing persistent databases in environments that
  /// support OPFS, as the OPFS VFS requires worker context.
  ///
  /// The [libsqlUri] can be provided to specify the location of the WASM module
  /// to be used by the worker.
  static Future<DatabaseHandle> worker({
    required String filename,
    String? vfsName,
    Uri? libsqlUri,
    bool verbose = false,
  }) {
    _logger.config('Initializing database worker for $filename');
    return DatabaseWorkerHandle._spawn(
      filename: filename,
      vfsName: vfsName,
      libsqlUri: libsqlUri,
      verbose: verbose,
    );
  }

  /// Creates an in-memory LibSQL database.
  ///
  /// Requires [libsql.loadModule] to be called beforehand.
  factory Database.memory({bool verbose = false}) {
    _logger.config('Initializing in-memory LibSQL database');
    return Database(libsql.Database(flags: verbose ? 'ct' : 'c'));
  }

  /// Creates a LibSQL database using the OPFS VFS at the given path.
  ///
  /// **NOTE**: This can only be used in environments that support OPFS, and
  /// requires APIs only available in workers. If OPFS is not supported, an
  /// [UnsupportedError] is thrown.
  ///
  /// Requires [libsql.loadModule] to be called beforehand.
  factory Database.opfs(String path, {bool verbose = false}) {
    if (!libsql.supportsOpfs) {
      throw UnsupportedError('OPFS is not supported in this environment');
    }
    _logger.config('Initializing LibSQL OPFS database at $path');
    return Database(
      libsql.Database(filename: path, flags: verbose ? 'ct' : 'c', vfs: 'opfs'),
    );
  }

  /// Creates a LibSQL database using the browser's local storage.
  ///
  /// Requires [libsql.loadModule] to be called beforehand.
  factory Database.local(String path, {bool verbose = false}) {
    _logger.config('Initializing LibSQL local database at $path');
    return Database(
      libsql.Database(filename: path, flags: verbose ? 'ct' : 'c'),
    );
  }

  final libsql.Database _db;
  bool get _disposed => !_db.isOpen();

  Database(this._db) {
    _db.affirmOpen();
  }

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('Database has been disposed');
    }
  }

  T _run<T>(T Function() action) {
    try {
      return action();
    } on Object catch (e) {
      if ((e as JSAny?).isA<libsql.SQLite3Error>()) {
        final sqlError = e as libsql.SQLite3Error;
        throw SqliteException(sqlError.resultCode, sqlError.message);
      }
      rethrow;
    }
  }

  @override
  String get filename => _db.filename;

  @override
  ExecResult execute(String sql, [List<Object?> parameters = const []]) {
    _checkNotDisposed();
    return _run(() {
      _db.exec(sql: sql, bind: parameters);
      return (lastInsertRowId: lastInsertRowId, updatedRows: updatedRows);
    });
  }

  @override
  List<Map<String, Object?>> select(
    String sql, [
    List<Object?> parameters = const [],
  ]) {
    _checkNotDisposed();
    return _run(() {
      final rows = _db.query(sql: sql, bind: parameters);
      if (rows.isNotEmpty) {
        final types = rows.first.values.map((e) => e.runtimeType).toList();
        _logger.fine('Query returned ${rows.length} rows with types: $types');
      }

      final columnNames = rows.isNotEmpty
          ? rows.first.keys.toList()
          : <String>[];

      final rowsList = rows.map((row) {
        return columnNames.map((col) => row[col]).toList();
      }).toList();

      return ResultSet(columnNames, null, rowsList);
    });
  }

  @override
  void close() {
    if (!_disposed) {
      _db.close();
    }
  }

  @override
  void transaction(void Function(TransactionExecutor tx) action) {
    _checkNotDisposed();
    _run(() {
      _db.transaction((tx) {
        action(Database(tx));
      });
    });
  }

  int get lastInsertRowId => _db.lastInsertRowid().toInt();
  int get updatedRows => _db.changes();
  int get totalChanges => _db.changes(true);
}

class DatabaseWorkerHandle implements DatabaseHandle {
  DatabaseWorkerHandle._(this._worker, this.filename);

  static final Logger _localLogger = Logger('Database');
  static final Logger _remoteLogger = Logger('Database.Worker');

  final DatabaseWorker _worker;
  @override
  final String filename;
  StreamSubscription<LogRecord>? _logSubscription;
  var _nextRequestId = 1;

  static Future<DatabaseWorkerHandle> _spawn({
    required String filename,
    String? vfsName,
    Uri? libsqlUri,
    bool verbose = false,
  }) async {
    final worker = DatabaseWorkerHandle._(DatabaseWorker.create(), filename);
    await worker._init(
      filename: filename,
      vfsName: vfsName,
      libsqlUri: libsqlUri,
      verbose: verbose,
    );
    return worker;
  }

  Future<void> _init({
    required String filename,
    String? vfsName,
    Uri? libsqlUri,
    bool verbose = false,
  }) async {
    _logSubscription = _worker.logs.listen((record) {
      final logger = record is WorkerLogRecord && record.local == false
          ? _remoteLogger
          : _localLogger;
      logger.log(record.level, record.message, record.error, record.stackTrace);
    });

    try {
      await _worker.spawn().timeout(const Duration(seconds: 10));
    } on Object {
      _worker.close(force: true).ignore();
      rethrow;
    }

    final requestId = _nextRequestId++;
    _worker.add(
      DatabaseRequest.init(
        requestId: requestId,
        filename: filename,
        libsqlUri: libsqlUri,
        vfs: vfsName,
      ),
    );
    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    response.unwrap();
  }

  var _disposed = false;

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('Database has been disposed');
    }
  }

  @override
  Future<void> close() async {
    if (_disposed) return;
    _disposed = true;
    unawaited(_logSubscription?.cancel());
    _logSubscription = null;
    await _worker.close();
  }

  @override
  Future<ExecResult> execute(
    String sql, [
    List<Object?> parameters = const [],
  ]) async {
    _checkNotDisposed();
    final requestId = _nextRequestId++;
    _worker.add(
      DatabaseRequest(
        requestId: requestId,
        type: DatabaseRequestType.execute,
        sql: sql,
        parameters: parameters,
      ),
    );
    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    final result = response.unwrap();
    return (
      lastInsertRowId: result.lastInsertRowId,
      updatedRows: result.updatedRows,
    );
  }

  @override
  Future<List<Map<String, Object?>>> select(
    String sql, [
    List<Object?> parameters = const [],
  ]) async {
    _checkNotDisposed();
    final requestId = _nextRequestId++;
    _worker.add(
      DatabaseRequest(
        requestId: requestId,
        type: DatabaseRequestType.query,
        sql: sql,
        parameters: parameters,
      ),
    );
    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    final result = response.unwrap();
    return ResultSet(
      result.columnNames.toList(),
      null,
      result.rows.map((e) => e.toList()).toList(),
    );
  }

  @override
  Future<void> transaction(void Function(TransactionExecutor tx) action) async {
    _checkNotDisposed();
    final builder = _TransactionBuilder();
    action(builder);
    final requestId = _nextRequestId++;
    _worker.add(
      DatabaseRequest.transaction(
        requestId: requestId,
        type: DatabaseRequestType.transaction,
        transaction: builder.build(),
      ),
    );
    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    response.unwrap();
  }
}

class _TransactionBuilder implements TransactionExecutor {
  final TransactionBuilder _builder = TransactionBuilder();

  @override
  void execute(String sql, [List<Object?> parameters = const []]) {
    _builder.statements.add(SqlStatement(sql, parameters));
  }

  Transaction build() => _builder.build();
}

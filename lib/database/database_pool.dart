import 'dart:async';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/common.dart' show ResultSet;
import 'package:worker_bee/worker_bee.dart';

import '../workers/database_pool_worker.dart';
import 'database.dart';
import 'transaction.dart';

/// A database pool that manages OPFS databases using a dedicated worker.
///
/// This class provides a clean interface for database management operations
/// including listing, importing, exporting, and deleting databases.
/// It uses a dedicated worker to handle all pool operations.
class DatabasePool {
  static final Logger _localLogger = Logger('DatabasePool');
  static final Logger _remoteLogger = Logger('DatabasePool.Worker');

  final DatabasePoolWorker _worker;
  StreamSubscription<LogRecord>? _logSubscription;
  var _nextRequestId = 1;
  var _disposed = false;

  late DatabasePoolStats _stats;

  List<String> get databaseNames => _stats.databaseNames
      .map((it) => p.posix.basename(it))
      .where((it) => it != 'configurations.db')
      .toList();
  int get reservedCapacity => _stats.reservedCapacity;
  int get fileCount => _stats.fileCount;
  String get vfsName => _stats.vfsName;

  final Map<String, DatabaseHandle> _databases = {};

  /// Creates a new database pool instance.
  DatabasePool._(this._worker);

  static Future<DatabasePool> create({
    String? poolName,
    Uri? libsqlUri,
    bool? clearOnInit,
  }) async {
    _localLogger.fine(
      'Creating database pool${poolName != null ? ' "$poolName"' : ''}',
    );
    final worker = DatabasePoolWorker.create();
    final pool = DatabasePool._(worker);
    await pool._init(
      libsqlUri: libsqlUri,
      clearOnInit: clearOnInit,
      poolName: poolName,
    );
    return pool;
  }

  Future<void> _init({
    Uri? libsqlUri,
    bool? clearOnInit,
    String? poolName,
  }) async {
    _logSubscription = _worker.logs.listen((record) {
      final logger = record is WorkerLogRecord && record.local == false
          ? _remoteLogger
          : _localLogger;
      logger.log(record.level, record.message, record.error, record.stackTrace);
    });

    try {
      await _worker.spawn().timeout(const Duration(seconds: 10));
    } on Object catch (e) {
      _localLogger.severe('Failed to start database pool worker', e);
      _logSubscription?.cancel().ignore();
      _worker.close(force: true).ignore();
      rethrow;
    }

    final requestId = _nextRequestId++;
    _worker.add(
      DatabasePoolRequest.init(
        requestId: requestId,
        libsqlUri: libsqlUri,
        name: poolName,
        clearOnInit: clearOnInit,
      ),
    );

    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    _stats = response.stats;

    response.unwrap();
    _localLogger.fine('Database pool initialized');
  }

  /// Exports an OPFS database to binary data.
  ///
  /// Throws [StateError] if the database doesn't exist or export fails.
  Future<Uint8List> export(String filename) async {
    // First, close any open instances of this database.
    final database = _databases.remove(filename);
    if (database != null) {
      await database.close();
    }

    final requestId = _nextRequestId++;
    _worker.add(
      DatabasePoolRequest.exportDatabase(
        requestId: requestId,
        databaseName: filename,
      ),
    );

    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    _stats = response.stats;

    final result = response.unwrap();
    final data = result.exportData;
    if (data == null) {
      throw StateError('Failed to export database $filename');
    }

    _localLogger.fine('Exported database $filename (${data.length} bytes)');
    return data;
  }

  /// Imports binary data as an OPFS database.
  ///
  /// Returns the number of bytes imported. Throws [StateError] if import fails.
  Future<DatabaseHandle> import({
    required String filename,
    required Uint8List data,
  }) async {
    if (_databases.containsKey(filename)) {
      throw StateError('Database already open: $filename');
    }

    final requestId = _nextRequestId++;
    _worker.add(
      DatabasePoolRequest.importDatabase(
        requestId: requestId,
        databaseName: filename,
        importData: data,
      ),
    );

    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    _stats = response.stats;

    final result = response.unwrap();
    if (result.success != true) {
      throw StateError('Failed to import database $filename');
    }

    _localLogger.fine('Imported database $filename (${data.length} bytes)');
    return open(filename);
  }

  /// Deletes an OPFS database.
  ///
  /// Returns true if the database was successfully deleted, false if it didn't exist.
  Future<bool> delete(String filename) async {
    // First, close any open instances of this database.
    final database = _databases.remove(filename);
    if (database != null) {
      await database.close();
    }

    final requestId = _nextRequestId++;
    _worker.add(
      DatabasePoolRequest.deleteDatabase(
        requestId: requestId,
        databaseName: filename,
      ),
    );

    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    _stats = response.stats;

    final result = response.unwrap();
    final deleted = result.success ?? false;

    _localLogger.fine(
      'Delete database $filename: ${deleted ? 'success' : 'not found'}',
    );
    return deleted;
  }

  /// Opens a database and returns an [DatabaseHandle] instance.
  Future<DatabaseHandle> open(String filename, {bool verbose = false}) async {
    if (_databases[filename] case final database?) {
      return database;
    }

    final requestId = _nextRequestId++;
    _worker.add(
      DatabasePoolRequest.openDatabase(
        requestId: requestId,
        databaseName: filename,
        verbose: verbose,
      ),
    );

    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    _stats = response.stats;
    response.unwrap();

    return _databases[filename] = _DatabasePoolDatabase(this, filename);
  }

  Future<void> wipeAll() async {
    final databases = List.of(_databases.values);
    _databases.clear();
    // First, close all open databases. Wiping file storage is undefined if any
    // databases are still open.
    for (final db in databases) {
      await db.close();
    }

    final requestId = _nextRequestId++;
    _worker.add(DatabasePoolRequest.wipeAll(requestId: requestId));

    final response = await _worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    _stats = response.stats;

    assert(_stats.databaseNames.isEmpty);
    assert(_stats.fileCount == 0);

    response.unwrap();
    _localLogger.fine('Wiped all databases');
  }

  /// Disposes the database pool and closes the worker.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    unawaited(_logSubscription?.cancel());
    _logSubscription = null;
    await _worker.close();
  }
}

class _DatabasePoolDatabase implements DatabaseHandle {
  @override
  final String filename;
  final DatabasePool pool;

  _DatabasePoolDatabase(this.pool, this.filename);

  @override
  Future<void> close() async {
    final requestId = pool._nextRequestId++;
    pool._worker.add(
      DatabasePoolRequest.closeDatabase(
        requestId: requestId,
        databaseName: filename,
      ),
    );

    final response = await pool._worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    pool._stats = response.stats;

    response.unwrap();
  }

  @override
  Future<ExecResult> execute(
    String sql, [
    List<Object?> parameters = const [],
  ]) async {
    final requestId = pool._nextRequestId++;
    pool._worker.add(
      DatabasePoolRequest.databaseOperation(
        requestId: requestId,
        type: DatabasePoolRequestType.execute,
        databaseName: filename,
        transaction: Transaction([SqlStatement(sql, parameters)]),
      ),
    );

    final response = await pool._worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    pool._stats = response.stats;

    final result = response.unwrap();
    return (
      lastInsertRowId: result.resultSet!.lastInsertRowId,
      updatedRows: result.resultSet!.updatedRows,
    );
  }

  @override
  Future<List<Map<String, Object?>>> select(
    String sql, [
    List<Object?> parameters = const [],
  ]) async {
    final requestId = pool._nextRequestId++;
    pool._worker.add(
      DatabasePoolRequest.databaseOperation(
        requestId: requestId,
        type: DatabasePoolRequestType.query,
        databaseName: filename,
        transaction: Transaction([SqlStatement(sql, parameters)]),
      ),
    );

    final response = await pool._worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    pool._stats = response.stats;

    final result = response.unwrap();
    return ResultSet(
      result.resultSet!.columnNames.toList(),
      null,
      result.resultSet!.rows.map((it) => it.toList()).toList(),
    );
  }

  @override
  Future<void> transaction(void Function(TransactionExecutor tx) action) async {
    final builder = _TransactionBuilder();
    action(builder);
    final transaction = builder.build();

    final requestId = pool._nextRequestId++;
    pool._worker.add(
      DatabasePoolRequest.databaseOperation(
        requestId: requestId,
        type: DatabasePoolRequestType.transaction,
        databaseName: filename,
        transaction: transaction,
      ),
    );

    final response = await pool._worker.stream.firstWhere(
      (response) => response.requestId == requestId,
    );
    pool._stats = response.stats;

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

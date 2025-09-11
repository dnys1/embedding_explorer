import 'package:sqlite3/common.dart' as sqlite3;

import '../interop/libsql.dart' as libsql;

/// JS implementation of PreparedStatement using WASM bindings
class LibsqlPreparedStatement extends sqlite3.CommonPreparedStatement {
  final libsql.PreparedStatement _stmt;
  bool _disposed = false;

  LibsqlPreparedStatement(this._stmt);

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('PreparedStatement has been disposed');
    }
  }

  @override
  void dispose() {
    if (!_disposed) {
      _disposed = true;
      _stmt.finalize();
    }
  }

  @override
  void execute([List<Object?> parameters = const []]) {
    _checkNotDisposed();

    _stmt.clearBindings();

    if (parameters.isNotEmpty) {
      _stmt.bind(
        libsql.BindingSpec.positional(
          parameters.map(libsql.SqlValue.fromDart).toList(),
        ),
      );
    }

    _stmt.step();
    _stmt.reset();
  }

  @override
  int get parameterCount => _stmt.parameterCount;

  @override
  sqlite3.ResultSet select([List<Object?> parameters = const []]) {
    _checkNotDisposed();

    _stmt.clearBindings();

    if (parameters.isNotEmpty) {
      _stmt.bind(
        libsql.BindingSpec.positional(
          parameters.map(libsql.SqlValue.fromDart).toList(),
        ),
      );
    }

    final rows = <Map<String, Object?>>[];
    final columnNames = <String>[];

    while (_stmt.step()) {
      if (columnNames.isEmpty) {
        final columnCount = _stmt.columnCount;
        for (int i = 0; i < columnCount; i++) {
          columnNames.add(_stmt.getColumnName(i));
        }
      }

      final row = <String, Object?>{};
      for (int i = 0; i < columnNames.length; i++) {
        row[columnNames[i]] = _stmt.get(i).toDart;
      }
      rows.add(row);
    }

    _stmt.reset();

    final rowsList = rows.map((row) {
      return columnNames.map((col) => row[col]).toList();
    }).toList();

    return sqlite3.ResultSet(columnNames, null, rowsList);
  }

  @override
  void reset() {
    _checkNotDisposed();
    _stmt.reset();
  }

  // Properties that are not yet implemented in WASM or not available

  @override
  bool get isExplain => false;

  @override
  bool get isReadOnly => false;

  @override
  String get sql => '';

  @override
  void executeMap(Map<String, Object?> parameters) {
    throw UnimplementedError('executeMap not supported in Web platform');
  }

  @override
  void executeWith(sqlite3.StatementParameters parameters) {
    throw UnimplementedError('executeWith not supported in Web platform');
  }

  @override
  sqlite3.IteratingCursor iterateWith(sqlite3.StatementParameters parameters) {
    throw UnimplementedError('iterateWith not supported in Web platform');
  }

  @override
  sqlite3.ResultSet selectMap(Map<String, Object?> parameters) {
    throw UnimplementedError('selectMap not supported in Web platform');
  }

  @override
  sqlite3.IteratingCursor selectCursor([List<Object?> parameters = const []]) {
    throw UnimplementedError('selectCursor not supported in Web platform');
  }

  @override
  sqlite3.ResultSet selectWith(sqlite3.StatementParameters parameters) {
    throw UnimplementedError('selectWith not supported in Web platform');
  }
}

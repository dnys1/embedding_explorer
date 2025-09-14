import 'package:logging/logging.dart';
import 'package:sqlparser/sqlparser.dart';
import 'package:web/web.dart' as web;

import '../../database/database.dart';
import '../../database/database_pool.dart';
import '../../util/file.dart';
import '../model/data_source.dart';
import '../model/data_source_config.dart';
import '../model/data_source_settings.dart';

part 'sample_data_source.dart';

/// Extension to add utility methods to SqlEngine
extension SqlEngineExtensions on SqlEngine {
  /// Utility function that parses a `CREATE TABLE` statement and registers the
  /// created table to the engine.
  void registerTableFromSql(String createTable) {
    final stmt = parse(createTable).rootNode as CreateTableStatement;
    registerTable(schemaReader.read(stmt));
  }

  /// Utility function that parses a `CREATE VIEW` statement and registers the
  /// created view to the engine.
  void registerViewFromSql(AnalysisContext context, String createView) {
    final stmt = parse(createView).rootNode as CreateViewStatement;
    registerView(schemaReader.readView(context, stmt));
  }
}

/// SQLite data source implementation using LibSQL WASM
///
/// This class provides access to SQLite databases using LibSQL WASM,
/// supporting both in-memory databases and file-based databases.
class SqliteDataSource extends DataSource<SqliteDataSourceSettings> {
  DatabaseHandle? _database;
  final Map<String, DataSourceFieldType> _fieldTypes = {};
  List<String> _tableNames = [];
  SqlEngine? _sqlEngine;

  /// The current SQL query (mutable, not persisted)
  String _sqlQuery = '';

  static final Logger _logger = Logger('SqliteDataSource');

  /// Create a SQLite data source from configuration (private constructor)
  SqliteDataSource._(super.config, {required DatabaseHandle database})
    : _database = database;

  /// Imports a SQLite database from a file into the database pool and creates
  /// a data source.
  static Future<SqliteDataSource> import({
    required DatabasePool dbPool,
    required web.File file,
    required DataSourceConfig config,
  }) async {
    assert(config.type == DataSourceType.sqlite);

    final filename = config.filename;
    final database = await dbPool.import(
      filename: filename,
      data: await file.readAsBytes(),
    );
    final dataSource = SqliteDataSource._(config, database: database);
    await dataSource._initialize();
    return dataSource;
  }

  /// Connect to an existing SQLite database from the database pool.
  static Future<SqliteDataSource> connect({
    required DatabasePool dbPool,
    required DataSourceConfig config,
  }) async {
    assert(config.type == DataSourceType.sqlite);

    final filename = config.filename;
    if (filename.isEmpty) {
      throw ArgumentError(
        'Filename is required to connect to a SQLite database',
      );
    }
    final db = await dbPool.open(filename);
    final dataSource = SqliteDataSource._(config, database: db);
    await dataSource._initialize();
    return dataSource;
  }

  /// Get the SQL query used for data operations
  String get sqlQuery => _sqlQuery;

  /// Get list of available tables in the database
  List<String> get tables => List.of(_tableNames);

  /// Set the SQL query to use for data operations
  Future<void> setSqlQuery(String query) async {
    if (query.trim().isEmpty) {
      _logger.warning('SQL query cannot be empty for data source: $name');
      throw DataSourceException('SQL query cannot be empty', sourceType: type);
    }

    _logger.info('Setting SQL query for data source: $name');
    _sqlQuery = query.trim();

    // Re-infer field types for the new query if we're connected
    await _inferFieldTypes(_sqlQuery);
  }

  Future<void> _initialize() async {
    // Discover tables
    _logger.finest('Discovering tables in database');
    await _discoverTables();

    // Set query if not already specified, otherwise default to first table
    if (_sqlQuery.isEmpty && _tableNames.isNotEmpty) {
      // Default to selecting all from first table if no query specified
      _sqlQuery = 'SELECT * FROM ${_tableNames.first}';
      _logger.finest('Set default query: "$_sqlQuery"');
    } else if (_sqlQuery.isNotEmpty) {
      _logger.finest('Using configured SQL query: "$_sqlQuery"');
    }

    // Infer field types for the query
    if (_sqlQuery.isNotEmpty) {
      await _inferFieldTypes(_sqlQuery);
    }
  }

  @override
  Future<void> dispose() async {
    _logger.info('Disconnecting SQLite data source: $name');
    if (_database case final database?) {
      await database.close();
      _database = null;
      _logger.finest('Database closed');
    }
    _fieldTypes.clear();
    _tableNames.clear();
    _logger.finest('SQLite data source disconnected: $name');
  }

  @override
  Future<Map<String, DataSourceFieldType>> getSchema() async {
    if (_database == null) {
      _logger.warning('Attempted to get schema when not connected: $name');
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    if (_sqlQuery.isEmpty) {
      _logger.warning('No SQL query configured for data source: $name');
      throw DataSourceException('No SQL query configured', sourceType: type);
    }

    return _fieldTypes;
  }

  @override
  Future<List<Map<String, dynamic>>> getSampleData({int limit = 10}) async {
    if (_database == null) {
      _logger.warning('Attempted to get sample data when not connected: $name');
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    if (_sqlQuery.isEmpty) {
      _logger.warning('No SQL query configured for data source: $name');
      throw DataSourceException('No SQL query configured', sourceType: type);
    }

    _logger.finest('Querying sample data');

    // Wrap the user query with LIMIT if it doesn't already have one
    String sampleQuery = _sqlQuery;
    if (!sampleQuery.toUpperCase().contains('LIMIT')) {
      sampleQuery = '$sampleQuery LIMIT ?';
      final result = await _database!.select(sampleQuery, [limit]);
      final rows = result.map(_convertRow).toList();
      _logger.finest('Retrieved ${rows.length} sample rows');
      return rows;
    } else {
      // Query already has LIMIT, execute as-is
      final result = await _database!.select(sampleQuery);
      final rows = result.map(_convertRow).toList();
      _logger.finest('Retrieved ${rows.length} sample rows');
      return rows;
    }
  }

  @override
  Future<int> getRowCount() async {
    if (_database == null) {
      _logger.warning('Attempted to get row count when not connected: $name');
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    if (_sqlQuery.isEmpty) {
      _logger.warning('No SQL query configured for data source: $name');
      throw DataSourceException('No SQL query configured', sourceType: type);
    }

    _logger.finest('Getting row count for SQL query: "$_sqlQuery"');

    // Wrap user query in COUNT() to get total row count
    final countQuery = 'SELECT COUNT(*) as count FROM ($_sqlQuery)';
    final result = await _database!.select(countQuery);

    if (result.isNotEmpty) {
      final count = (result.first['count'] as num?)?.toInt() ?? 0;
      _logger.finest('Row count: $count');
      return count;
    }

    _logger.finest('Row count: 0 (no results)');
    return 0;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllData({
    int offset = 0,
    int? limit,
  }) async {
    if (_database == null) {
      _logger.warning('Attempted to get all data when not connected: $name');
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    if (_sqlQuery.isEmpty) {
      _logger.warning('No SQL query configured for data source: $name');
      throw DataSourceException('No SQL query configured', sourceType: type);
    }

    _logger.finest(
      'Getting all data for SQL query: "$_sqlQuery" (offset: $offset, limit: $limit)',
    );

    // Wrap user query with pagination if needed
    String paginatedQuery = _sqlQuery;
    final bind = <Object?>[];

    if (limit != null || offset > 0) {
      if (limit != null) {
        paginatedQuery += ' LIMIT ? OFFSET ?';
        bind.add(limit);
        bind.add(offset);
      } else if (offset > 0) {
        paginatedQuery += ' OFFSET ?';
        bind.add(offset);
      }
    }

    final result = await _database!.select(paginatedQuery, bind);
    final rows = result.map(_convertRow).toList();
    _logger.finest('Retrieved ${rows.length} rows from SQL query');
    return rows;
  }

  /// Execute a custom SQL query (for advanced users)
  Future<List<Map<String, dynamic>>> executeQuery(
    String sql, {
    List<Object?> bind = const [],
  }) async {
    if (_database == null) {
      _logger.warning('Attempted to execute query when not connected: $name');
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    _logger.finest('Executing SQL query: $sql');
    final result = await _database!.select(sql, bind);
    final rows = result.map(_convertRow).toList();
    _logger.finest('Query returned ${rows.length} rows');
    return rows;
  }

  /// Execute a custom SQL statement (for advanced users)
  Future<void> executeStatement(
    String sql, {
    List<Object?> bind = const [],
  }) async {
    if (_database == null) {
      _logger.warning(
        'Attempted to execute statement when not connected: $name',
      );
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    _logger.finest('Executing SQL statement: $sql');
    await _database!.execute(sql, bind);
    _logger.finest('Statement executed successfully');
  }

  /// Discover tables in the database and initialize SQL engine
  Future<void> _discoverTables() async {
    _logger.finest('Discovering tables in SQLite database');
    final result = await _database!.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );

    _tableNames = result
        .map((row) => row['name'] as String?)
        .where((name) => name != null)
        .cast<String>()
        .toList();

    _logger.finest(
      'Discovered ${_tableNames.length} tables: ${_tableNames.join(', ')}',
    );

    // Initialize SQL engine with database schema
    await _initializeSqlEngine();
  }

  /// Initialize SQL engine with database schema for query analysis
  Future<void> _initializeSqlEngine() async {
    _logger.finest('Initializing SQL engine with database schema');
    _sqlEngine = SqlEngine();

    // Register all tables in the database
    for (final tableName in _tableNames) {
      // Get the CREATE TABLE statement for this table
      final result = await _database!.select(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name = ?",
        [tableName],
      );

      if (result.isNotEmpty) {
        final createTableSql = result.first['sql'] as String;
        _sqlEngine!.registerTableFromSql(createTableSql);
        _logger.finest('Registered table: $tableName');
      }
    }

    _logger.finest('SQL engine initialized with ${_tableNames.length} tables');
  }

  /// Infer field types for the configured SQL query
  Future<void> _inferFieldTypes(String query) async {
    _logger.finest('Analyzing SQL query with parser for field types');

    final result = _sqlEngine!.analyze(query);

    if (result.errors.isNotEmpty) {
      throw DataSourceException(
        'SQL parser error',
        sourceType: type,
        cause: result.errors.map((e) => e.message).join(', '),
      );
    }

    if (result.root is SelectStatement) {
      final select = result.root as SelectStatement;
      final columns = select.resolvedColumns;

      if (columns != null) {
        _fieldTypes.clear();

        for (final column in columns) {
          final type = result.typeOf(column);
          final fieldType = _mapSqlTypeToFieldType(type.type?.type);
          _fieldTypes[column.name] = fieldType;
          _logger.finest(
            'Column "${column.name}": SQL type $type -> ${fieldType.name}',
          );
        }

        _logger.finest(
          'Inferred ${_fieldTypes.length} field types from SQL parser',
        );
      }
    }
  }

  /// Map SQL parser type to our DataSourceFieldType
  DataSourceFieldType _mapSqlTypeToFieldType(BasicType? sqlType) {
    if (sqlType == null) return DataSourceFieldType.text;

    // Check the type based on BasicType enum values
    switch (sqlType) {
      case BasicType.int:
        return DataSourceFieldType.integer;
      case BasicType.real:
        return DataSourceFieldType.real;
      case BasicType.text:
        return DataSourceFieldType.text;
      case BasicType.blob:
        return DataSourceFieldType.blob;
      default:
        return DataSourceFieldType.text;
    }
  }

  /// Convert a database row to the expected format
  Map<String, dynamic> _convertRow(Map<String, Object?> row) {
    final converted = <String, dynamic>{};

    for (final entry in row.entries) {
      final fieldType = _fieldTypes[entry.key];
      converted[entry.key] = _convertValue(entry.value, fieldType);
    }

    return converted;
  }

  /// Convert a value to the appropriate Dart type
  dynamic _convertValue(Object? value, DataSourceFieldType? fieldType) {
    if (value == null) return null;

    // If we already have the right type, return as-is
    switch (fieldType) {
      case DataSourceFieldType.integer:
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value);
      case DataSourceFieldType.real:
        if (value is double) return value;
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value);
      case DataSourceFieldType.boolean:
        if (value is bool) return value;
        if (value is String) {
          final lower = value.toLowerCase();
          if (['true', '1', 'yes'].contains(lower)) return true;
          if (['false', '0', 'no'].contains(lower)) return false;
        }
      case DataSourceFieldType.date:
        if (value is String) {
          final parsed = DateTime.tryParse(value);
          return parsed?.toIso8601String().split('T').first;
        }
      case DataSourceFieldType.datetime:
        if (value is String) {
          final parsed = DateTime.tryParse(value);
          return parsed?.toIso8601String();
        }
      default:
        break;
    }

    return value;
  }
}

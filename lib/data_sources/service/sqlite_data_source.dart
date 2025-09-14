import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:sqlparser/sqlparser.dart';
import 'package:web/web.dart' as web;

import '../../database/database.dart';
import '../../database/database_pool.dart';
import '../../util/file.dart';
import '../model/data_source.dart';
import '../model/data_source_config.dart';
import '../model/data_source_settings.dart';

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
  IDatabase? _database;
  final Map<String, DataSourceFieldType> _fieldTypes = {};
  List<String> _tableNames = [];
  SqlEngine? _sqlEngine;

  /// The current SQL query (mutable, not persisted)
  String _sqlQuery = '';

  static final Logger _logger = Logger('SqliteDataSource');

  /// Create a SQLite data source from configuration (private constructor)
  SqliteDataSource._(super.config, {required IDatabase database})
    : _database = database;

  /// Imports a SQLite database from a file into the database pool and creates
  /// a data source.
  static Future<SqliteDataSource> loadFromFile({
    required DatabasePool dbPool,
    required web.File file,
    required DataSourceConfig config,
  }) async {
    assert(config.type == DataSourceType.sqlite);
    assert(config.settings is SqliteDataSourceSettings);

    final settings = config.settings as SqliteDataSourceSettings;

    final filename = settings.filename ?? file.name;
    final database = await dbPool.import(
      filename: filename,
      data: await file.readAsBytes(),
    );
    final dataSource = SqliteDataSource._(
      config.copyWith(
        settings: settings.copyWith(type: SqliteDataSourceType.persistent),
      ),
      database: database,
    );
    await dataSource._initialize();
    return dataSource;
  }

  /// Connect to an existing SQLite database from the database pool.
  static Future<SqliteDataSource> connect({
    required DatabasePool dbPool,
    required DataSourceConfig config,
  }) async {
    assert(config.type == DataSourceType.sqlite);
    assert(config.settings is SqliteDataSourceSettings);

    final settings = config.settings as SqliteDataSourceSettings;
    final filename = settings.filename;
    switch (settings.type) {
      case SqliteDataSourceType.sample:
        final db = await dbPool.open(filename ?? 'sample.db');
        final dataSource = SqliteDataSource._(config, database: db);
        await dataSource._createSampleSchema();
        await dataSource._initialize();
        return dataSource;
      case SqliteDataSourceType.import:
        throw ArgumentError(
          'Import type requires a file to load the database. '
          'Use loadFromFile() instead.',
        );
      case SqliteDataSourceType.persistent:
        assert(settings.persistent);
        if (filename == null || filename.isEmpty) {
          throw ArgumentError('Filename is required for persistent type');
        }
        final db = await dbPool.open(filename);
        final dataSource = SqliteDataSource._(config, database: db);
        await dataSource._initialize();
        return dataSource;
    }
  }

  /// Get typed SQLite settings
  SqliteDataSourceSettings get sqliteSettings =>
      settings as SqliteDataSourceSettings;

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

  @override
  List<String> validate() {
    final errors = <String>[];

    final dbType = sqliteSettings.type;
    switch (dbType) {
      case SqliteDataSourceType.import:
        final persistent = sqliteSettings.persistent;
        if (persistent &&
            (sqliteSettings.filename == null ||
                sqliteSettings.filename!.isEmpty)) {
          errors.add('Persistent name is required when persistence is enabled');
        }
      case SqliteDataSourceType.persistent:
        if (sqliteSettings.filename == null ||
            sqliteSettings.filename!.isEmpty) {
          errors.add('Filename is required for persistent type');
        }
      case SqliteDataSourceType.sample:
        // No validation needed for sample data
        break;
    }

    // Validate SQL query using proper SQL parser
    if (_sqlQuery.isEmpty) {
      errors.add('SQL query is required');
    } else {
      try {
        // Use sqlparser to validate the query
        final engine = SqlEngine();
        final result = engine.analyze(_sqlQuery);

        // Check for parsing errors
        if (result.errors.isNotEmpty) {
          errors.addAll(result.errors.map((e) => 'SQL Error: ${e.message}'));
        }

        // Ensure it's a SELECT statement
        if (result.root is! SelectStatement) {
          errors.add('Only SELECT queries are allowed for data sources');
        }
      } catch (e) {
        errors.add('Invalid SQL query: ${e.toString()}');
      }
    }

    return errors;
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
    _logger.finest(
      'Inferring field types for SQL query: ${query.length} chars',
    );

    // First try to use SQL parser for column analysis
    switch (sqliteSettings.type) {
      case SqliteDataSourceType.sample:
        await _inferFieldTypesFromSample(query);
      case SqliteDataSourceType.import:
      case SqliteDataSourceType.persistent:
        _inferFieldTypesFromParser(query);
    }
  }

  /// Infer field types using SQL parser analysis
  void _inferFieldTypesFromParser(String query) {
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

  /// Infer field types by sampling data from the configured query
  Future<void> _inferFieldTypesFromSample(String query) async {
    try {
      _logger.finest(
        'Inferring field types from sample data for query: ${query.length} chars',
      );

      // Execute the query with a small limit to get sample data
      String sampleQuery = query;
      if (!sampleQuery.toUpperCase().contains('LIMIT')) {
        sampleQuery = '$sampleQuery LIMIT 10';
      }

      final result = await _database!.select(sampleQuery);

      if (result.isNotEmpty) {
        _fieldTypes.clear();
        final firstRow = result.first;

        for (final entry in firstRow.entries) {
          final fieldName = entry.key;
          final fieldType = _inferTypeFromValue(entry.value);
          _fieldTypes[fieldName] = fieldType;
          _logger.finest(
            'Field "$fieldName": inferred type ${fieldType.name} from sample value',
          );
        }

        _logger.finest(
          'Inferred ${_fieldTypes.length} field types from sample data',
        );
      }
    } catch (e) {
      _logger.warning('Failed to infer field types from sample data: $e');
    }
  }

  /// Infer data type from a sample value
  DataSourceFieldType _inferTypeFromValue(Object? value) {
    if (value == null) return DataSourceFieldType.text;

    if (value is int) return DataSourceFieldType.integer;
    if (value is double) return DataSourceFieldType.real;
    if (value is bool) return DataSourceFieldType.boolean;
    if (value is Uint8List) return DataSourceFieldType.blob;

    if (value is String) {
      // Try to parse as different types
      if (int.tryParse(value) != null) return DataSourceFieldType.integer;
      if (double.tryParse(value) != null) return DataSourceFieldType.real;
      if (['true', 'false'].contains(value.toLowerCase())) {
        return DataSourceFieldType.boolean;
      }
      if (DateTime.tryParse(value) != null) {
        if (value.contains(' ') || value.contains('T')) {
          return DataSourceFieldType.datetime;
        }
        return DataSourceFieldType.date;
      }
    }

    return DataSourceFieldType.text;
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

  /// Create sample schema with demo data for testing purposes
  Future<void> _createSampleSchema() async {
    _logger.finest('Creating sample schema with demo data');

    try {
      // Create a sample movies table with various data types
      await _database!.execute('''
        CREATE TABLE movies (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          release_year INTEGER,
          rating REAL,
          is_favorite BOOLEAN DEFAULT FALSE,
          release_date DATE,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          description TEXT,
          revenue INTEGER
        )
        ''');

      // Insert sample data with proper parameter binding
      final sampleMovies = [
        {
          'id': 1,
          'title': 'The Shawshank Redemption',
          'release_year': 1994,
          'rating': 9.3,
          'is_favorite': 1,
          'release_date': '1994-09-23',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.',
          'revenue': 16000000,
        },
        {
          'id': 2,
          'title': 'The Godfather',
          'release_year': 1972,
          'rating': 9.2,
          'is_favorite': 1,
          'release_date': '1972-03-24',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.',
          'revenue': 246120974,
        },
        {
          'id': 3,
          'title': 'The Dark Knight',
          'release_year': 2008,
          'rating': 9.0,
          'is_favorite': 1,
          'release_date': '2008-07-18',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests.',
          'revenue': 1004558444,
        },
        {
          'id': 4,
          'title': 'Pulp Fiction',
          'release_year': 1994,
          'rating': 8.9,
          'is_favorite': 0,
          'release_date': '1994-10-14',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in four tales of violence and redemption.',
          'revenue': 214179088,
        },
        {
          'id': 5,
          'title': 'Schindler\'s List',
          'release_year': 1993,
          'rating': 8.9,
          'is_favorite': 1,
          'release_date': '1993-12-15',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'In German-occupied Poland during World War II, industrialist Oskar Schindler gradually becomes concerned for his Jewish workforce.',
          'revenue': 322161405,
        },
        {
          'id': 6,
          'title': 'Inception',
          'release_year': 2010,
          'rating': 8.8,
          'is_favorite': 0,
          'release_date': '2010-07-16',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea.',
          'revenue': 836836967,
        },
        {
          'id': 7,
          'title': 'Fight Club',
          'release_year': 1999,
          'rating': 8.8,
          'is_favorite': 0,
          'release_date': '1999-10-15',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'An insomniac office worker and a devil-may-care soap maker form an underground fight club.',
          'revenue': 100853753,
        },
        {
          'id': 8,
          'title': 'Forrest Gump',
          'release_year': 1994,
          'rating': 8.8,
          'is_favorite': 1,
          'release_date': '1994-07-06',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'The presidencies of Kennedy and Johnson, the Vietnam War, and other historical events unfold from the perspective of an Alabama man.',
          'revenue': 677387716,
        },
        {
          'id': 9,
          'title': 'The Matrix',
          'release_year': 1999,
          'rating': 8.7,
          'is_favorite': 1,
          'release_date': '1999-03-31',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'When a beautiful stranger leads computer hacker Neo to a forbidding underworld, he discovers the shocking truth.',
          'revenue': 467222824,
        },
        {
          'id': 10,
          'title': 'Goodfellas',
          'release_year': 1990,
          'rating': 8.7,
          'is_favorite': 0,
          'release_date': '1990-09-21',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'The story of Henry Hill and his life in the mob, covering his relationship with his wife Karen Hill and his mob partners.',
          'revenue': 46836394,
        },
      ];

      for (final movie in sampleMovies) {
        await _database!.execute(
          'INSERT INTO movies (id, title, release_year, rating, is_favorite, release_date, created_at, description, revenue) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            movie['id'],
            movie['title'],
            movie['release_year'],
            movie['rating'],
            movie['is_favorite'],
            movie['release_date'],
            movie['created_at'],
            movie['description'],
            movie['revenue'],
          ],
        );
      }

      _logger.info('Sample schema created with ${sampleMovies.length} movies');
    } catch (e) {
      _logger.severe('Failed to create sample schema', e);
      throw DataSourceException(
        'Failed to create sample schema: ${e.toString()}',
        sourceType: type,
        cause: e,
      );
    }
  }
}

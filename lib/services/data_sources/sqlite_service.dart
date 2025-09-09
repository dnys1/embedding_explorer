import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:logging/logging.dart';

import '../../interop/libsql.dart' as libsql show loadModule;
import '../../interop/libsql.dart';
import '../../models/data_source.dart';

/// SQLite data source implementation using LibSQL WASM
///
/// This class provides access to SQLite databases using LibSQL WASM,
/// supporting both in-memory databases and file-based databases.
class SqliteDataSource extends DataSource {
  late final String _id;
  late final String _name;
  late final Map<String, dynamic> _config;

  Database? _database;
  final Map<String, DataSourceFieldType> _fieldTypes = {};
  List<String> _tableNames = [];
  String? _selectedTable;
  bool _isConnected = false;

  static final Logger _logger = Logger('SqliteDataSource');

  /// Create a SQLite data source from configuration
  SqliteDataSource({
    required String id,
    required String name,
    required Map<String, dynamic> config,
  }) {
    _id = id;
    _name = name;
    _config = Map.from(config);
  }

  /// Create an in-memory SQLite database with sample data for testing
  factory SqliteDataSource.withSampleData({required String name}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return SqliteDataSource(id: id, name: name, config: {'type': 'sample'});
  }

  /// Create a SQLite data source from uploaded database file
  factory SqliteDataSource.fromUpload({
    required String name,
    required Uint8List databaseData,
    bool persistent = false,
    String? persistentName,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return SqliteDataSource(
      id: id,
      name: name,
      config: {
        'type': 'upload',
        'data': databaseData,
        'persistent': persistent,
        if (persistent && persistentName != null)
          'persistentName': persistentName,
      },
    );
  }

  /// Create a SQLite data source from a persistent OPFS database
  factory SqliteDataSource.fromPersistent({
    required String name,
    required String filename,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return SqliteDataSource(
      id: id,
      name: name,
      config: {'type': 'persistent', 'filename': filename},
    );
  }

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  String get type => 'sqlite';

  @override
  bool get isConnected => _isConnected;

  @override
  Map<String, dynamic> get config => Map.from(_config);

  /// Get the selected table name
  String? get selectedTable => _selectedTable;

  /// Get list of available tables in the database
  List<String> get tables => List.from(_tableNames);

  /// Set the table to use for data operations
  void selectTable(String tableName) {
    if (!_tableNames.contains(tableName)) {
      _logger.warning('Table "$tableName" not found in database: $_name');
      throw DataSourceException(
        'Table "$tableName" not found in database',
        sourceType: type,
      );
    }

    _logger.info('Selecting table: $tableName for data source: $_name');
    _selectedTable = tableName;
    _config['tableName'] = tableName;

    // Re-infer field types for the new table
    if (_isConnected) {
      _logger.finest('Re-inferring field types for new table: $tableName');
      _inferFieldTypes();
    }
  }

  @override
  Future<bool> connect() async {
    try {
      if (_isConnected) {
        _logger.finest('SQLite data source already connected');
        return true;
      }

      _logger.info('Connecting to SQLite data source: $_name');

      // Initialize LibSQL WASM if not already done
      if (globalContext['libsql'].isUndefinedOrNull) {
        _logger.finest('Initializing LibSQL WASM');
        await _initializeLibSQL();
      }

      // Create database based on configuration type
      final dbType = _config['type'] as String? ?? 'sample';
      _logger.finest('Creating SQLite database with type: $dbType');

      switch (dbType) {
        case 'sample':
          _database = Database();
          _logger.finest('Created in-memory SQLite database for sample data');
          await _createSampleSchema();
          break;

        case 'upload':
          final data = _config['data'] as Uint8List?;
          if (data == null) {
            _logger.warning('Database data is required for upload type');
            throw DataSourceException(
              'Database data is required for upload type',
              sourceType: type,
            );
          }

          final persistent = _config['persistent'] as bool? ?? false;
          if (persistent) {
            final persistentName =
                _config['persistentName'] as String? ??
                'uploaded_db_${DateTime.now().millisecondsSinceEpoch}';
            _logger.finest('Importing database to OPFS: $persistentName');

            // Import to OPFS for persistence
            await _importDatabaseData(persistentName, data);
            _database = Database(filename: persistentName);
          } else {
            // Create in-memory database and import data
            _database = Database(filename: ':memory:');
            _logger.finest(
              'Created in-memory database from upload (${data.length} bytes)',
            );
            await _importDatabaseData(':memory:', data);
          }
          break;

        case 'persistent':
          final filename = _config['filename'] as String?;
          if (filename == null) {
            _logger.warning('Filename is required for persistent type');
            throw DataSourceException(
              'Filename is required for persistent type',
              sourceType: type,
            );
          }
          // Open existing OPFS database
          _database = Database(filename: filename);
          _logger.finest('Opened persistent OPFS database: $filename');
          break;

        default:
          _logger.warning('Unsupported database type: $dbType');
          throw DataSourceException(
            'Unsupported database type: $dbType',
            sourceType: type,
          );
      }

      if (_database == null) {
        _logger.severe('Failed to create database');
        throw DataSourceException(
          'Failed to create database',
          sourceType: type,
        );
      }

      // Ensure database is open
      _database!.affirmOpen();
      _logger.finest('Database opened successfully');

      // Discover tables
      _logger.finest('Discovering tables in database');
      await _discoverTables();

      // Select table if specified in config
      final configTable = _config['tableName'] as String?;
      if (configTable != null && _tableNames.contains(configTable)) {
        _selectedTable = configTable;
        _logger.finest('Selected configured table: $configTable');
      } else if (_tableNames.isNotEmpty) {
        _selectedTable = _tableNames.first;
        _logger.finest('Selected first available table: $_selectedTable');
      }

      // Infer field types for selected table
      if (_selectedTable != null) {
        _logger.finest('Inferring field types for table: $_selectedTable');
        _inferFieldTypes();
      }

      _isConnected = true;
      _logger.info(
        'Successfully connected to SQLite data source: $_name (${_tableNames.length} tables, selected: $_selectedTable)',
      );
      return true;
    } catch (e) {
      _isConnected = false;
      _logger.severe('Failed to connect to SQLite data source: $_name', e);
      if (e is DataSourceException) rethrow;
      throw DataSourceException(
        'Failed to connect to SQLite database: ${e.toString()}',
        sourceType: type,
        cause: e,
      );
    }
  }

  @override
  Future<void> disconnect() async {
    _logger.info('Disconnecting SQLite data source: $_name');
    if (_database != null) {
      _database!.close();
      _database = null;
      _logger.finest('Database closed');
    }
    _fieldTypes.clear();
    _tableNames.clear();
    _selectedTable = null;
    _isConnected = false;
    _logger.finest('SQLite data source disconnected: $_name');
  }

  @override
  Future<Map<String, String>> getSchema() async {
    if (!_isConnected || _selectedTable == null) {
      _logger.warning(
        'Attempted to get schema when not connected or no table selected: $_name',
      );
      throw DataSourceException(
        'Data source not connected or no table selected',
        sourceType: type,
      );
    }

    _logger.finest('Getting schema for SQLite table: $_selectedTable');
    final schema = Map.fromEntries(
      _fieldTypes.entries.map((entry) => MapEntry(entry.key, entry.value.name)),
    );
    _logger.finest('Schema retrieved with ${schema.length} fields');
    return schema;
  }

  @override
  Future<List<Map<String, dynamic>>> getSampleData({int limit = 10}) async {
    if (!_isConnected || _selectedTable == null) {
      _logger.warning(
        'Attempted to get sample data when not connected or no table selected: $_name',
      );
      throw DataSourceException(
        'Data source not connected or no table selected',
        sourceType: type,
      );
    }

    _logger.finest(
      'Getting sample data for SQLite table: $_selectedTable (limit: $limit)',
    );
    final sql = 'SELECT * FROM $_selectedTable LIMIT ?';
    final result = _database!.query(sql: sql, bind: [limit]);

    final rows = result.map(_convertRow).toList();
    _logger.finest('Retrieved ${rows.length} sample rows');
    return rows;
  }

  @override
  Future<int> getRowCount() async {
    if (!_isConnected || _selectedTable == null) {
      _logger.warning(
        'Attempted to get row count when not connected or no table selected: $_name',
      );
      throw DataSourceException(
        'Data source not connected or no table selected',
        sourceType: type,
      );
    }

    _logger.finest('Getting row count for SQLite table: $_selectedTable');
    final sql = 'SELECT COUNT(*) as count FROM $_selectedTable';
    final result = _database!.query(sql: sql);

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
    if (!_isConnected || _selectedTable == null) {
      _logger.warning(
        'Attempted to get all data when not connected or no table selected: $_name',
      );
      throw DataSourceException(
        'Data source not connected or no table selected',
        sourceType: type,
      );
    }

    _logger.finest(
      'Getting all data for SQLite table: $_selectedTable (offset: $offset, limit: $limit)',
    );
    var sql = 'SELECT * FROM $_selectedTable';
    final bind = <Object?>[];

    if (limit != null) {
      sql += ' LIMIT ? OFFSET ?';
      bind.add(limit);
      bind.add(offset);
    } else if (offset > 0) {
      sql += ' OFFSET ?';
      bind.add(offset);
    }

    final result = _database!.query(sql: sql, bind: bind);
    final rows = result.map(_convertRow).toList();
    _logger.finest('Retrieved ${rows.length} rows from SQLite table');
    return rows;
  }

  @override
  List<String> validate() {
    final errors = <String>[];

    final dbType = _config['type'] as String?;
    if (dbType == null) {
      errors.add('Database type is required');
    } else {
      switch (dbType) {
        case 'upload':
          if (_config['data'] == null) {
            errors.add('Database data is required for upload type');
          }
          final persistent = _config['persistent'] as bool? ?? false;
          if (persistent &&
              (_config['persistentName'] == null ||
                  (_config['persistentName'] as String).isEmpty)) {
            errors.add(
              'Persistent name is required when persistence is enabled',
            );
          }
          break;
        case 'persistent':
          if (_config['filename'] == null ||
              (_config['filename'] as String).isEmpty) {
            errors.add('Filename is required for persistent type');
          }
          break;
        case 'sample':
          // No validation needed for sample data
          break;
        default:
          errors.add('Unsupported database type: $dbType');
      }
    }

    return errors;
  }

  @override
  DataSource copyWith(Map<String, dynamic> newConfig) {
    final updatedConfig = Map<String, dynamic>.from(_config);
    updatedConfig.addAll(newConfig);

    return SqliteDataSource(id: _id, name: _name, config: updatedConfig);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'type': type,
      'config': _config,
      'isConnected': _isConnected,
      'tables': _tableNames,
      'selectedTable': _selectedTable,
      if (_isConnected && _selectedTable != null)
        'schema': _fieldTypes.map((k, v) => MapEntry(k, v.name)),
    };
  }

  /// Execute a custom SQL query (for advanced users)
  Future<List<Map<String, dynamic>>> executeQuery(
    String sql, {
    List<Object?> bind = const [],
  }) async {
    if (!_isConnected) {
      _logger.warning('Attempted to execute query when not connected: $_name');
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    _logger.finest('Executing SQL query: $sql');
    final result = _database!.query(sql: sql, bind: bind);
    final rows = result.map(_convertRow).toList();
    _logger.finest('Query returned ${rows.length} rows');
    return rows;
  }

  /// Execute a custom SQL statement (for advanced users)
  Future<void> executeStatement(
    String sql, {
    List<Object?> bind = const [],
  }) async {
    if (!_isConnected) {
      _logger.warning(
        'Attempted to execute statement when not connected: $_name',
      );
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    _logger.finest('Executing SQL statement: $sql');
    _database!.exec(sql: sql, bind: bind);
    _logger.finest('Statement executed successfully');
  }

  /// Initialize LibSQL WASM module
  Future<void> _initializeLibSQL() async {
    try {
      _logger.finest('Initializing LibSQL WASM module');
      await libsql.loadModule();
      _logger.finest('LibSQL WASM module initialized successfully');
    } catch (e) {
      _logger.severe('Failed to initialize LibSQL WASM', e);
      throw DataSourceException(
        'Failed to initialize LibSQL WASM: ${e.toString()}',
        sourceType: type,
        cause: e,
      );
    }
  }

  /// Discover tables in the database
  Future<void> _discoverTables() async {
    try {
      _logger.finest('Discovering tables in SQLite database');
      final result = _database!.query(
        sql:
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
    } catch (e) {
      // If we can't discover tables, start with an empty list
      _logger.warning('Failed to discover tables: $e');
      _tableNames = [];
    }
  }

  /// Infer field types for the selected table
  void _inferFieldTypes() {
    if (_selectedTable == null || _database == null) return;

    try {
      _logger.finest(
        'Inferring field types for SQLite table: $_selectedTable using PRAGMA table_info',
      );
      // Get column info using PRAGMA table_info
      final result = _database!.query(
        sql: 'PRAGMA table_info($_selectedTable)',
      );

      _fieldTypes.clear();
      for (final row in result) {
        final name = row['name'] as String?;
        final type = row['type'] as String?;

        if (name != null && type != null) {
          final dataSourceType = _sqliteTypeToDataSourceType(type);
          _fieldTypes[name] = dataSourceType;
          _logger.finest(
            'Field "$name": SQLite type "$type" -> ${dataSourceType.name}',
          );
        }
      }

      _logger.finest('Inferred ${_fieldTypes.length} field types from PRAGMA');
    } catch (e) {
      // If PRAGMA fails, try to infer from sample data
      _logger.warning(
        'PRAGMA table_info failed, falling back to sample data inference: $e',
      );
      _inferFieldTypesFromSample();
    }
  }

  /// Infer field types by sampling data (fallback method)
  void _inferFieldTypesFromSample() {
    if (_selectedTable == null || _database == null) return;

    try {
      _logger.finest(
        'Inferring field types from sample data for table: $_selectedTable',
      );
      final result = _database!.query(
        sql: 'SELECT * FROM $_selectedTable LIMIT 10',
      );

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

  /// Convert SQLite type string to DataSourceFieldType
  DataSourceFieldType _sqliteTypeToDataSourceType(String sqliteType) {
    final type = sqliteType.toLowerCase();

    if (type.contains('int')) return DataSourceFieldType.integer;
    if (type.contains('real') ||
        type.contains('float') ||
        type.contains('double')) {
      return DataSourceFieldType.real;
    }
    if (type.contains('text') ||
        type.contains('char') ||
        type.contains('varchar')) {
      return DataSourceFieldType.text;
    }
    if (type.contains('blob')) return DataSourceFieldType.blob;
    if (type.contains('bool')) return DataSourceFieldType.boolean;
    if (type.contains('date')) {
      if (type.contains('time')) {
        return DataSourceFieldType.datetime;
      }
      return DataSourceFieldType.date;
    }

    return DataSourceFieldType.text; // Default to text
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
        break;
      case DataSourceFieldType.real:
        if (value is double) return value;
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value);
        break;
      case DataSourceFieldType.boolean:
        if (value is bool) return value;
        if (value is String) {
          final lower = value.toLowerCase();
          if (['true', '1', 'yes'].contains(lower)) return true;
          if (['false', '0', 'no'].contains(lower)) return false;
        }
        break;
      case DataSourceFieldType.date:
        if (value is String) {
          final parsed = DateTime.tryParse(value);
          return parsed?.toIso8601String().split('T').first;
        }
        break;
      case DataSourceFieldType.datetime:
        if (value is String) {
          final parsed = DateTime.tryParse(value);
          return parsed?.toIso8601String();
        }
        break;
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
      _database!.exec(
        sql: '''
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
        ''',
      );

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
        _database!.exec(
          sql:
              'INSERT INTO movies (id, title, release_year, rating, is_favorite, release_date, created_at, description, revenue) '
              'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          bind: [
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

  /// Import database data from binary data
  Future<void> _importDatabaseData(String filename, Uint8List data) async {
    _logger.finest(
      'Importing database from binary data (${data.length} bytes)',
    );

    try {
      final result = await OpfsDatabase.importDb(
        filename.toJS,
        data.toJS,
      ).toDart;
      if (result.toDartInt != 0) {
        _logger.severe('Failed to import database data, result code: $result');
        throw DataSourceException(
          'Failed to import database data, result code: $result',
          sourceType: type,
        );
      }
      _logger.finest('Database imported successfully to OPFS: $filename');
    } catch (e) {
      _logger.severe('Failed to import database data', e);
      if (e is DataSourceException) rethrow;
      throw DataSourceException(
        'Failed to import database: ${e.toString()}',
        sourceType: type,
        cause: e,
      );
    }
  }
}

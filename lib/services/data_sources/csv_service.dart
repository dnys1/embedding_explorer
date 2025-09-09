import 'dart:async';
import 'dart:js_interop';

import 'package:csv/csv.dart';
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

import '../../models/data_source.dart';

/// CSV data source implementation that can load and parse CSV files
/// from file uploads or URLs.
class CsvDataSource extends DataSource {
  late final String _id;
  late final String _name;
  late final Map<String, dynamic> _config;

  List<List<dynamic>> _rawData = [];
  List<String> _headers = [];
  final Map<String, DataSourceFieldType> _fieldTypes = {};
  bool _isConnected = false;

  static final Logger _logger = Logger('CsvDataSource');

  /// Create a CSV data source from a configuration
  CsvDataSource({
    required String id,
    required String name,
    required Map<String, dynamic> config,
  }) {
    _id = id;
    _name = name;
    _config = Map.from(config);
  }

  /// Create a CSV data source from file content
  factory CsvDataSource.fromFileContent({
    required String name,
    required String csvContent,
    String delimiter = ',',
    bool hasHeader = true,
    String? encoding,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return CsvDataSource(
      id: id,
      name: name,
      config: {
        'content': csvContent,
        'delimiter': delimiter,
        'hasHeader': hasHeader,
        'encoding': encoding ?? 'utf-8',
        'source': 'file',
      },
    );
  }

  /// Create a CSV data source from a File object (browser file upload)
  static Future<CsvDataSource> fromFile({
    required web.File file,
    String delimiter = ',',
    bool hasHeader = true,
  }) async {
    final reader = web.FileReader();
    reader.readAsText(file);

    final completer = Completer<String>();
    reader.onerror = (web.Event e) {
      if (completer.isCompleted) return;
      completer.completeError(
        DataSourceException(
          'Failed to read file: ${reader.error?.message}',
          sourceType: 'csv',
          cause: reader.error,
        ),
      );
    }.toJS;
    reader.onabort = (web.Event e) {
      if (completer.isCompleted) return;
      completer.completeError(
        DataSourceException('File read aborted', sourceType: 'csv'),
      );
    }.toJS;
    reader.onLoadEnd.first.then((e) {
      if (completer.isCompleted) return;

      final result = reader.result.dartify();
      if (result is! String) {
        completer.completeError(
          DataSourceException(
            'File read resulted in invalid content: ${result.runtimeType}',
            sourceType: 'csv',
          ),
        );
      } else {
        completer.complete(result);
      }
    });

    final content = await completer.future;
    return CsvDataSource.fromFileContent(
      name: file.name,
      csvContent: content,
      delimiter: delimiter,
      hasHeader: hasHeader,
    );
  }

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  String get type => 'csv';

  @override
  bool get isConnected => _isConnected;

  @override
  Map<String, dynamic> get config => Map.from(_config);

  @override
  Future<bool> connect() async {
    try {
      if (_isConnected) {
        _logger.finest('CSV data source already connected');
        return true;
      }

      _logger.info('Connecting to CSV data source: $_name');

      final content = _config['content'] as String?;
      if (content == null || content.isEmpty) {
        _logger.warning('No CSV content provided for data source: $_name');
        throw DataSourceException('No CSV content provided', sourceType: type);
      }

      final delimiter = _config['delimiter'] as String? ?? ',';
      final hasHeader = _config['hasHeader'] as bool? ?? true;

      _logger.finest(
        'Parsing CSV with delimiter: "$delimiter", hasHeader: $hasHeader',
      );

      // Parse CSV content
      final csvData = const CsvToListConverter().convert(
        content.replaceAll('\r\n', '\n').replaceAll('\r', '\n'),
        eol: '\n',
        fieldDelimiter: delimiter,
        shouldParseNumbers: false, // Keep as strings for type inference
      );

      if (csvData.isEmpty) {
        _logger.warning('CSV file is empty for data source: $_name');
        throw DataSourceException('CSV file is empty', sourceType: type);
      }

      _rawData = csvData;
      _logger.finest('Parsed ${csvData.length} rows from CSV content');
      _logger.finest('First 3 raw rows: ${csvData.take(3).toList()}');

      // Extract headers
      if (hasHeader && csvData.isNotEmpty) {
        _headers = csvData.first.map((e) => e?.toString() ?? '').toList();
        _rawData = csvData.skip(1).toList();
        _logger.finest('Extracted headers: ${_headers.join(', ')}');
      } else {
        // Generate column names if no header
        final columnCount = csvData.first.length;
        _headers = List.generate(columnCount, (i) => 'Column${i + 1}');
        _logger.finest('Generated headers: ${_headers.join(', ')}');
      }

      // Infer field types
      _logger.finest('Starting type inference for ${_headers.length} columns');
      _inferFieldTypes();

      _isConnected = true;
      _logger.info(
        'Successfully connected to CSV data source: $_name (${_rawData.length} rows, ${_headers.length} columns)',
      );
      return true;
    } catch (e) {
      _isConnected = false;
      _logger.severe('Failed to connect to CSV data source: $_name', e);
      if (e is DataSourceException) rethrow;
      throw DataSourceException(
        'Failed to parse CSV: ${e.toString()}',
        sourceType: type,
        cause: e,
      );
    }
  }

  @override
  Future<void> disconnect() async {
    _logger.info('Disconnecting CSV data source: $_name');
    _rawData.clear();
    _headers.clear();
    _fieldTypes.clear();
    _isConnected = false;
    _logger.finest('CSV data source disconnected: $_name');
  }

  @override
  Future<Map<String, String>> getSchema() async {
    if (!_isConnected) {
      _logger.warning('Attempted to get schema when not connected: $_name');
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    _logger.finest('Getting schema for CSV data source: $_name');
    final schema = Map.fromEntries(
      _headers.map(
        (header) => MapEntry(
          header,
          _fieldTypes[header]?.name ?? DataSourceFieldType.text.name,
        ),
      ),
    );
    _logger.finest('Schema retrieved with ${schema.length} fields');
    return schema;
  }

  @override
  Future<List<Map<String, dynamic>>> getSampleData({int limit = 10}) async {
    if (!_isConnected) {
      _logger.warning(
        'Attempted to get sample data when not connected: $_name',
      );
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    _logger.finest(
      'Getting sample data for CSV data source: $_name (limit: $limit)',
    );
    final sampleRows = _rawData.take(limit);
    final result = _convertRowsToMaps(sampleRows);
    _logger.finest('Retrieved ${result.length} sample rows');
    return result;
  }

  @override
  Future<int> getRowCount() async {
    if (!_isConnected) {
      _logger.warning('Attempted to get row count when not connected: $_name');
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    _logger.finest('Getting row count for CSV data source: $_name');
    return _rawData.length;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllData({
    int offset = 0,
    int? limit,
  }) async {
    if (!_isConnected) {
      _logger.warning('Attempted to get all data when not connected: $_name');
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    _logger.finest(
      'Getting all data for CSV data source: $_name (offset: $offset, limit: $limit)',
    );
    var rows = _rawData.skip(offset);
    if (limit != null) {
      rows = rows.take(limit);
    }

    final result = _convertRowsToMaps(rows);
    _logger.finest('Retrieved ${result.length} rows from CSV data source');
    return result;
  }

  @override
  List<String> validate() {
    final errors = <String>[];

    if (_config['content'] == null || (_config['content'] as String).isEmpty) {
      errors.add('CSV content is required');
    }

    final delimiter = _config['delimiter'] as String?;
    if (delimiter == null || delimiter.isEmpty) {
      errors.add('Delimiter is required');
    }

    return errors;
  }

  @override
  DataSource copyWith(Map<String, dynamic> newConfig) {
    final updatedConfig = Map<String, dynamic>.from(_config);
    updatedConfig.addAll(newConfig);

    return CsvDataSource(id: _id, name: _name, config: updatedConfig);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'type': type,
      'config': _config,
      'isConnected': _isConnected,
      if (_isConnected)
        'schema': _fieldTypes.map((k, v) => MapEntry(k, v.name)),
    };
  }

  /// Convert raw CSV rows to list of maps with proper field names
  List<Map<String, dynamic>> _convertRowsToMaps(Iterable<List<dynamic>> rows) {
    _logger.finest(
      'Converting ${rows.length} rows to maps using headers: ${_headers.join(', ')}',
    );
    final result = rows.map((row) {
      final map = <String, dynamic>{};
      for (int i = 0; i < _headers.length && i < row.length; i++) {
        map[_headers[i]] = _convertValue(row[i], _fieldTypes[_headers[i]]);
      }
      return map;
    }).toList();
    _logger.finest('Conversion complete: ${result.length} maps created');
    if (result.isNotEmpty) {
      _logger.finest('First converted map: ${result.first}');
    }
    return result;
  }

  /// Convert string value to appropriate type based on inferred field type
  dynamic _convertValue(dynamic value, DataSourceFieldType? fieldType) {
    if (value == null || value == '') return null;

    final stringValue = value.toString();

    switch (fieldType) {
      case DataSourceFieldType.integer:
        return int.tryParse(stringValue);
      case DataSourceFieldType.real:
        return double.tryParse(stringValue);
      case DataSourceFieldType.boolean:
        final lower = stringValue.toLowerCase();
        if (lower == 'true' || lower == '1' || lower == 'yes') return true;
        if (lower == 'false' || lower == '0' || lower == 'no') return false;
        return null;
      case DataSourceFieldType.date:
        return DateTime.tryParse(
          stringValue,
        )?.toIso8601String().split('T').first;
      case DataSourceFieldType.datetime:
        return DateTime.tryParse(stringValue)?.toIso8601String();
      default:
        return stringValue;
    }
  }

  /// Infer field types by sampling data values
  void _inferFieldTypes() {
    _logger.finest(
      'Starting field type inference for ${_headers.length} columns',
    );
    _fieldTypes.clear();

    for (int columnIndex = 0; columnIndex < _headers.length; columnIndex++) {
      final header = _headers[columnIndex];
      final sampleSize = 100; // Sample first 100 rows for type inference
      final sampleValues = _rawData
          .take(sampleSize)
          .where((row) => columnIndex < row.length && row[columnIndex] != null)
          .map((row) => row[columnIndex].toString())
          .where((value) => value.isNotEmpty)
          .toList();

      final inferredType = _inferFieldType(sampleValues);
      _fieldTypes[header] = inferredType;
    }

    _logger.finest(
      'Field type inference completed: ${_fieldTypes.length} fields processed',
    );
  }

  /// Infer the most likely field type from a sample of values
  DataSourceFieldType _inferFieldType(List<String> sampleValues) {
    if (sampleValues.isEmpty) return DataSourceFieldType.text;

    int integerCount = 0;
    int realCount = 0;
    int booleanCount = 0;
    int dateCount = 0;
    int datetimeCount = 0;

    for (final value in sampleValues) {
      // Check for integer
      if (int.tryParse(value) != null) {
        integerCount++;
        continue;
      }

      // Check for real number
      if (double.tryParse(value) != null) {
        realCount++;
        continue;
      }

      // Check for boolean
      final lower = value.toLowerCase();
      if (['true', 'false', '1', '0', 'yes', 'no'].contains(lower)) {
        booleanCount++;
        continue;
      }

      // Check for datetime
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        if (value.contains(' ') || value.contains('T')) {
          datetimeCount++;
        } else {
          dateCount++;
        }
        continue;
      }
    }

    final total = sampleValues.length;
    const threshold = 0.8; // 80% of values must match type

    // Return type if it matches threshold
    if (integerCount / total >= threshold) return DataSourceFieldType.integer;
    if (realCount / total >= threshold) return DataSourceFieldType.real;
    if (booleanCount / total >= threshold) return DataSourceFieldType.boolean;
    if (datetimeCount / total >= threshold) return DataSourceFieldType.datetime;
    if (dateCount / total >= threshold) return DataSourceFieldType.date;

    // Default to text
    return DataSourceFieldType.text;
  }
}

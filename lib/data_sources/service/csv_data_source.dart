import 'dart:async';

import 'package:csv/csv.dart';
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

import '../../util/file.dart';
import '../model/data_source.dart';
import '../model/data_source_config.dart';
import '../model/data_source_settings.dart';

/// CSV data source implementation that can load and parse CSV files
/// from file uploads or URLs.
class CsvDataSource extends DataSource {
  List<List<dynamic>> _rawData = [];
  List<String> _headers = [];
  final Map<String, DataSourceFieldType> _fieldTypes = {};
  bool _isConnected = false;

  static final Logger _logger = Logger('CsvDataSource');

  /// Create a CSV data source from configuration
  CsvDataSource._(super.config);

  factory CsvDataSource.fromConfig(DataSourceConfig config) {
    return CsvDataSource._(config);
  }

  /// Get typed CSV settings
  CsvDataSourceSettings get csvSettings => settings as CsvDataSourceSettings;

  /// Create a CSV data source from file content
  factory CsvDataSource.fromFileContent({
    required String name,
    required String csvContent,
    String delimiter = ',',
    bool hasHeader = true,
    String? encoding,
    bool persistent = false,
    String? persistentName,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final config = DataSourceConfig(
      id: id,
      name: name,
      description: 'CSV data source created from file content',
      type: DataSourceType.csv,
      settings: CsvDataSourceSettings(
        delimiter: delimiter,
        hasHeader: hasHeader,
        encoding: encoding ?? 'utf-8',
        content: csvContent,
        source: 'file',
        persistent: persistent,
        persistentName: persistentName,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return CsvDataSource.fromConfig(config);
  }

  /// Create a CSV data source from a File object (browser file upload)
  static Future<CsvDataSource> fromFile({
    required web.File file,
    String? name,
    String delimiter = ',',
    bool hasHeader = true,
    bool persistent = false,
    String? persistentName,
  }) async {
    final content = await file.readAsString();
    return CsvDataSource.fromFileContent(
      name: name ?? file.name,
      csvContent: content,
      delimiter: delimiter,
      hasHeader: hasHeader,
      persistent: persistent,
      persistentName: persistentName,
    );
  }

  @override
  bool get isConnected => _isConnected;

  @override
  Future<bool> connect() async {
    try {
      if (_isConnected) {
        return true;
      }

      _logger.info('Connecting to CSV data source: $name');

      final content = csvSettings.content;
      if (content == null || content.isEmpty) {
        _logger.warning('No CSV content provided for data source: $name');
        return false;
      }

      final delimiter = csvSettings.delimiter;
      final hasHeader = csvSettings.hasHeader;

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
        _logger.warning('CSV file is empty for data source: $name');
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
        'Successfully connected to CSV data source: $name (${_rawData.length} rows, ${_headers.length} columns)',
      );
      return true;
    } catch (e) {
      _isConnected = false;
      _logger.severe('Failed to connect to CSV data source: $name', e);
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
    _logger.info('Disconnecting CSV data source: $name');
    _rawData.clear();
    _headers.clear();
    _fieldTypes.clear();
    _isConnected = false;
    _logger.finest('CSV data source disconnected: $name');
  }

  @override
  Future<Map<String, String>> getSchema() async {
    if (!_isConnected) {
      _logger.warning('Attempted to get schema when not connected: $name');
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    _logger.finest('Getting schema for CSV data source: $name');
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
      _logger.warning('Attempted to get sample data when not connected: $name');
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    _logger.finest(
      'Getting sample data for CSV data source: $name (limit: $limit)',
    );
    final sampleRows = _rawData.take(limit);
    final result = _convertRowsToMaps(sampleRows);
    _logger.finest('Retrieved ${result.length} sample rows');
    return result;
  }

  @override
  Future<int> getRowCount() async {
    if (!_isConnected) {
      _logger.warning('Attempted to get row count when not connected: $name');
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    _logger.finest('Getting row count for CSV data source: $name');
    return _rawData.length;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllData({
    int offset = 0,
    int? limit,
  }) async {
    if (!_isConnected) {
      _logger.warning('Attempted to get all data when not connected: $name');
      throw DataSourceException('Data source not connected', sourceType: type);
    }

    _logger.finest(
      'Getting all data for CSV data source: $name (offset: $offset, limit: $limit)',
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

    if (csvSettings.content == null || csvSettings.content!.isEmpty) {
      errors.add('CSV content is required');
    }

    final delimiter = csvSettings.delimiter;
    if (delimiter.isEmpty) {
      errors.add('Delimiter is required');
    }

    return errors;
  }

  @override
  DataSource copyWith({
    String? id,
    String? name,
    String? description,
    DataSourceType? type,
    DataSourceSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final newConfig = config.copyWith(
      id: id,
      name: name,
      description: description,
      type: type,
      settings: settings,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
    return CsvDataSource.fromConfig(newConfig);
  }

  @override
  Map<String, dynamic> toJson() {
    return config.toJson();
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

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
  final List<List<dynamic>> _rawData;
  final List<String> _headers;
  final Map<String, DataSourceFieldType> _fieldTypes;

  static final Logger _logger = Logger('CsvDataSource');

  /// Create a CSV data source from configuration (private constructor)
  CsvDataSource._(
    super.config, {
    required List<List<dynamic>> rawData,
    required List<String> headers,
    required Map<String, DataSourceFieldType> fieldTypes,
  }) : _rawData = rawData,
       _headers = headers,
       _fieldTypes = fieldTypes;

  /// Get typed CSV settings
  CsvDataSourceSettings get csvSettings => settings as CsvDataSourceSettings;

  static Future<CsvDataSource> loadFromFile({
    required DataSourceConfig config,
    required web.File file,
  }) async {
    assert(config.type == DataSourceType.csv);
    assert(config.settings is CsvDataSourceSettings);

    final csvSettings = config.settings as CsvDataSourceSettings;
    try {
      _logger.info('Connecting to CSV data source: ${config.name}');

      final content = await file.readAsString();
      if (content.isEmpty) {
        _logger.warning(
          'No CSV content provided for data source: ${config.name}',
        );
        throw DataSourceException(
          'No CSV content provided',
          sourceType: config.type,
        );
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
        _logger.warning('CSV file is empty for data source: ${config.name}');
        throw DataSourceException('CSV file is empty', sourceType: config.type);
      }

      List<List<dynamic>> rawData = csvData;
      _logger.finest('Parsed ${csvData.length} rows from CSV content');
      _logger.finest('First 3 raw rows: ${csvData.take(3).toList()}');

      // Extract headers
      final List<String> headers;
      if (hasHeader && csvData.isNotEmpty) {
        headers = csvData.first.map((e) => e?.toString() ?? '').toList();
        rawData = csvData.skip(1).toList();
        _logger.finest('Extracted headers: ${headers.join(', ')}');
      } else {
        // Generate column names if no header
        final columnCount = csvData.first.length;
        headers = List.generate(columnCount, (i) => 'Column${i + 1}');
        _logger.finest('Generated headers: ${headers.join(', ')}');
      }

      // Infer field types
      _logger.finest('Starting type inference for ${headers.length} columns');
      final fieldTypes = _inferFieldTypes(rawData: rawData, headers: headers);

      _logger.info(
        'Successfully connected to CSV data source: ${config.name} '
        '(${rawData.length} rows, ${headers.length} columns)',
      );
      return CsvDataSource._(
        config,
        rawData: rawData,
        headers: headers,
        fieldTypes: fieldTypes,
      );
    } catch (e) {
      _logger.severe('Failed to connect to CSV data source: ${config.name}', e);
      if (e is DataSourceException) rethrow;
      throw DataSourceException(
        'Failed to parse CSV: ${e.toString()}',
        sourceType: config.type,
        cause: e,
      );
    }
  }

  static Future<CsvDataSource> connect({
    required DataSourceConfig config,
  }) async {
    throw UnimplementedError(
      'Connect method is not implemented for CSV data source',
    );
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<Map<String, DataSourceFieldType>> getSchema() async {
    return _fieldTypes;
  }

  @override
  Future<List<Map<String, dynamic>>> getSampleData({int limit = 10}) async {
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
    _logger.finest('Getting row count for CSV data source: $name');
    return _rawData.length;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllData({
    int offset = 0,
    int? limit,
  }) async {
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

    final delimiter = csvSettings.delimiter;
    if (delimiter.isEmpty) {
      errors.add('Delimiter is required');
    }

    return errors;
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
  static Map<String, DataSourceFieldType> _inferFieldTypes({
    required List<List<dynamic>> rawData,
    required List<String> headers,
  }) {
    _logger.finest(
      'Starting field type inference for ${headers.length} columns',
    );
    final fieldTypes = <String, DataSourceFieldType>{};

    for (int columnIndex = 0; columnIndex < headers.length; columnIndex++) {
      final header = headers[columnIndex];
      final sampleSize = 100; // Sample first 100 rows for type inference
      final sampleValues = rawData
          .take(sampleSize)
          .where((row) => columnIndex < row.length && row[columnIndex] != null)
          .map((row) => row[columnIndex].toString())
          .where((value) => value.isNotEmpty)
          .toList();

      final inferredType = _inferFieldType(sampleValues);
      fieldTypes[header] = inferredType;
    }

    _logger.finest(
      'Field type inference completed: ${fieldTypes.length} fields processed',
    );
    return fieldTypes;
  }

  /// Infer the most likely field type from a sample of values
  static DataSourceFieldType _inferFieldType(List<String> sampleValues) {
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

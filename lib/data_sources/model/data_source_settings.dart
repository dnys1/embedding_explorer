import 'data_source_config.dart';

/// Base class for all data source settings.
///
/// This provides type safety for data source configuration and ensures
/// that each data source type has well-defined, documented settings.
abstract class DataSourceSettings {
  const DataSourceSettings();

  /// Convert settings to JSON for persistence
  Map<String, dynamic> toJson();

  /// Create settings from JSON data
  static DataSourceSettings fromJson(
    DataSourceType type,
    Map<String, dynamic> json,
  ) {
    switch (type) {
      case DataSourceType.csv:
        return CsvDataSourceSettings.fromJson(json);
      case DataSourceType.sqlite:
        return SqliteDataSourceSettings.fromJson(json);
      case DataSourceType.sample:
        return SqliteDataSourceSettings.fromJson(json);
    }
  }
}

/// Settings for CSV data sources
class CsvDataSourceSettings extends DataSourceSettings {
  /// File delimiter character (e.g., ',', ';', '\t')
  final String delimiter;

  /// Whether the first row contains column headers
  final bool hasHeader;

  const CsvDataSourceSettings({this.delimiter = ',', this.hasHeader = true});

  @override
  Map<String, dynamic> toJson() {
    return {'delimiter': delimiter, 'hasHeader': hasHeader};
  }

  factory CsvDataSourceSettings.fromJson(Map<String, dynamic> json) {
    return CsvDataSourceSettings(
      delimiter: json['delimiter'] as String? ?? ',',
      hasHeader: json['hasHeader'] as bool? ?? true,
    );
  }

  CsvDataSourceSettings copyWith({
    String? delimiter,
    bool? hasHeader,
    String? content,
    bool? persistent,
    String? persistentName,
  }) {
    return CsvDataSourceSettings(
      delimiter: delimiter ?? this.delimiter,
      hasHeader: hasHeader ?? this.hasHeader,
    );
  }

  @override
  String toString() =>
      'CsvDataSourceSettings(delimiter: $delimiter, hasHeader: $hasHeader)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CsvDataSourceSettings &&
          runtimeType == other.runtimeType &&
          delimiter == other.delimiter &&
          hasHeader == other.hasHeader;

  @override
  int get hashCode => Object.hash(delimiter, hasHeader);
}

enum SqliteDataSourceType {
  import(
    displayName: 'Import Database File',
    description:
        'Import an existing SQLite database file with optional persistence',
  ),
  persistent(
    displayName: 'Persistent Storage',
    description: 'Load a previously persisted SQLite database',
  );

  const SqliteDataSourceType({
    required this.displayName,
    required this.description,
  });

  final String displayName;
  final String description;
}

/// Settings for SQLite data sources
class SqliteDataSourceSettings extends DataSourceSettings {
  const SqliteDataSourceSettings();

  @override
  Map<String, dynamic> toJson() {
    return const {};
  }

  factory SqliteDataSourceSettings.fromJson(Map<String, dynamic> json) {
    return const SqliteDataSourceSettings();
  }

  SqliteDataSourceSettings copyWith() {
    return const SqliteDataSourceSettings();
  }

  @override
  String toString() => 'SqliteDataSourceSettings()';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SqliteDataSourceSettings && runtimeType == other.runtimeType;

  @override
  int get hashCode => (SqliteDataSourceSettings).hashCode;
}

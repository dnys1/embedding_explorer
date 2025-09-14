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
    }
  }
}

/// Settings for CSV data sources
class CsvDataSourceSettings extends DataSourceSettings {
  /// File delimiter character (e.g., ',', ';', '\t')
  final String delimiter;

  /// Whether the first row contains column headers
  final bool hasHeader;

  /// CSV text content
  final String? content;

  /// Whether to use persistent storage
  final bool persistent;

  /// Name for persistent storage (if persistent is true)
  final String? persistentName;

  const CsvDataSourceSettings({
    this.delimiter = ',',
    this.hasHeader = true,
    this.content,
    this.persistent = false,
    this.persistentName,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'delimiter': delimiter,
      'hasHeader': hasHeader,
      'content': content,
      'persistent': persistent,
      'persistentName': ?persistentName,
    };
  }

  factory CsvDataSourceSettings.fromJson(Map<String, dynamic> json) {
    return CsvDataSourceSettings(
      delimiter: json['delimiter'] as String? ?? ',',
      hasHeader: json['hasHeader'] as bool? ?? true,
      content: json['content'] as String?,
      persistent: json['persistent'] as bool? ?? false,
      persistentName: json['persistentName'] as String?,
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
      content: content ?? this.content,
      persistent: persistent ?? this.persistent,
      persistentName: persistentName ?? this.persistentName,
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
          hasHeader == other.hasHeader &&
          persistent == other.persistent &&
          persistentName == other.persistentName &&
          content == other.content;

  @override
  int get hashCode =>
      Object.hash(delimiter, hasHeader, persistent, persistentName, content);
}

enum SqliteDataSourceType {
  sample(
    displayName: 'Sample Data',
    description: 'Use pre-loaded sample movie data for testing and exploration',
  ),
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
  /// Type of SQLite data source ('sample', 'upload', 'persistent')
  final SqliteDataSourceType type;

  /// Whether to use persistent storage
  bool get persistent => type != SqliteDataSourceType.sample;

  /// Name for persistent storage (if persistent is true)
  final String? filename;

  const SqliteDataSourceSettings({
    this.type = SqliteDataSourceType.sample,
    this.filename,
  }) : assert(
         type == SqliteDataSourceType.sample || filename != null,
         'Filename must be provided for import or persistent types',
       );

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.name, 'persistent': persistent, 'filename': ?filename};
  }

  factory SqliteDataSourceSettings.fromJson(Map<String, dynamic> json) {
    return SqliteDataSourceSettings(
      type: SqliteDataSourceType.values.byName(json['type'] as String),
      filename: json['filename'] as String?,
    );
  }

  SqliteDataSourceSettings copyWith({
    SqliteDataSourceType? type,
    bool? persistent,
    String? filename,
  }) {
    return SqliteDataSourceSettings(
      type: type ?? this.type,
      filename: filename ?? this.filename,
    );
  }

  @override
  String toString() =>
      'SqliteDataSourceSettings(type: $type, persistent: $persistent, filename: $filename)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SqliteDataSourceSettings &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          persistent == other.persistent &&
          filename == other.filename;

  @override
  int get hashCode => Object.hash(type, persistent, filename);
}

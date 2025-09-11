/// Base class for all data source settings.
///
/// This provides type safety for data source configuration and ensures
/// that each data source type has well-defined, documented settings.
abstract class DataSourceSettings {
  const DataSourceSettings();

  /// Convert settings to JSON for persistence
  Map<String, dynamic> toJson();

  /// Create settings from JSON data
  static DataSourceSettings fromJson(String type, Map<String, dynamic> json) {
    switch (type) {
      case 'csv':
        return CsvDataSourceSettings.fromJson(json);
      case 'sqlite':
        return SqliteDataSourceSettings.fromJson(json);
      default:
        throw ArgumentError('Unknown data source type: $type');
    }
  }
}

/// Settings for CSV data sources
class CsvDataSourceSettings extends DataSourceSettings {
  /// File delimiter character (e.g., ',', ';', '\t')
  final String delimiter;

  /// Whether the first row contains column headers
  final bool hasHeader;

  /// Character encoding (default: 'utf-8')
  final String encoding;

  /// Quote character for escaping values
  final String quoteChar;

  /// Escape character for special characters
  final String escapeChar;

  /// Whether to skip empty lines
  final bool skipEmptyLines;

  /// Number of lines to skip at the beginning
  final int skipRows;

  /// Maximum number of rows to read (null for all)
  final int? maxRows;

  /// The actual CSV content (for file-based sources)
  final String? content;

  /// Source type ('file', 'url', 'text')
  final String source;

  const CsvDataSourceSettings({
    this.delimiter = ',',
    this.hasHeader = true,
    this.encoding = 'utf-8',
    this.quoteChar = '"',
    this.escapeChar = '\\',
    this.skipEmptyLines = true,
    this.skipRows = 0,
    this.maxRows,
    this.content,
    this.source = 'file',
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'delimiter': delimiter,
      'hasHeader': hasHeader,
      'encoding': encoding,
      'quoteChar': quoteChar,
      'escapeChar': escapeChar,
      'skipEmptyLines': skipEmptyLines,
      'skipRows': skipRows,
      if (maxRows != null) 'maxRows': maxRows,
      if (content != null) 'content': content,
      'source': source,
    };
  }

  factory CsvDataSourceSettings.fromJson(Map<String, dynamic> json) {
    return CsvDataSourceSettings(
      delimiter: json['delimiter'] as String? ?? ',',
      hasHeader: json['hasHeader'] as bool? ?? true,
      encoding: json['encoding'] as String? ?? 'utf-8',
      quoteChar: json['quoteChar'] as String? ?? '"',
      escapeChar: json['escapeChar'] as String? ?? '\\',
      skipEmptyLines: json['skipEmptyLines'] as bool? ?? true,
      skipRows: json['skipRows'] as int? ?? 0,
      maxRows: json['maxRows'] as int?,
      content: json['content'] as String?,
      source: json['source'] as String? ?? 'file',
    );
  }

  CsvDataSourceSettings copyWith({
    String? delimiter,
    bool? hasHeader,
    String? encoding,
    String? quoteChar,
    String? escapeChar,
    bool? skipEmptyLines,
    int? skipRows,
    int? maxRows,
    String? content,
    String? source,
  }) {
    return CsvDataSourceSettings(
      delimiter: delimiter ?? this.delimiter,
      hasHeader: hasHeader ?? this.hasHeader,
      encoding: encoding ?? this.encoding,
      quoteChar: quoteChar ?? this.quoteChar,
      escapeChar: escapeChar ?? this.escapeChar,
      skipEmptyLines: skipEmptyLines ?? this.skipEmptyLines,
      skipRows: skipRows ?? this.skipRows,
      maxRows: maxRows ?? this.maxRows,
      content: content ?? this.content,
      source: source ?? this.source,
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
          encoding == other.encoding &&
          quoteChar == other.quoteChar &&
          escapeChar == other.escapeChar &&
          skipEmptyLines == other.skipEmptyLines &&
          skipRows == other.skipRows &&
          maxRows == other.maxRows &&
          content == other.content &&
          source == other.source;

  @override
  int get hashCode => Object.hash(
    delimiter,
    hasHeader,
    encoding,
    quoteChar,
    escapeChar,
    skipEmptyLines,
    skipRows,
    maxRows,
    content,
    source,
  );
}

enum SqliteDataSourceType { sample, upload, persistent }

/// Settings for SQLite data sources
class SqliteDataSourceSettings extends DataSourceSettings {
  /// Type of SQLite data source ('sample', 'upload', 'persistent')
  final SqliteDataSourceType type;

  /// SQL query to execute for data retrieval
  final String? query;

  /// Whether to use persistent storage
  final bool persistent;

  /// Name for persistent storage (if persistent is true)
  final String? persistentName;

  /// Binary database data (for uploaded files)
  final List<int>? databaseData;

  /// Connection timeout in milliseconds
  final int connectionTimeout;

  /// Whether to enable write-ahead logging (WAL) mode
  final bool enableWal;

  /// Page size for the database
  final int? pageSize;

  /// Cache size in pages
  final int? cacheSize;

  const SqliteDataSourceSettings({
    this.type = SqliteDataSourceType.sample,
    this.query,
    this.persistent = false,
    this.persistentName,
    this.databaseData,
    this.connectionTimeout = 30000,
    this.enableWal = false,
    this.pageSize,
    this.cacheSize,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      if (query != null) 'query': query,
      'persistent': persistent,
      if (persistentName != null) 'persistentName': persistentName,
      if (databaseData != null) 'databaseData': databaseData,
      'connectionTimeout': connectionTimeout,
      'enableWal': enableWal,
      if (pageSize != null) 'pageSize': pageSize,
      if (cacheSize != null) 'cacheSize': cacheSize,
    };
  }

  factory SqliteDataSourceSettings.fromJson(Map<String, dynamic> json) {
    return SqliteDataSourceSettings(
      type: SqliteDataSourceType.values.byName(json['type'] as String),
      query: json['query'] as String?,
      persistent: json['persistent'] as bool? ?? false,
      persistentName: json['persistentName'] as String?,
      databaseData: (json['databaseData'] as List<dynamic>?)?.cast<int>(),
      connectionTimeout: json['connectionTimeout'] as int? ?? 30000,
      enableWal: json['enableWal'] as bool? ?? false,
      pageSize: json['pageSize'] as int?,
      cacheSize: json['cacheSize'] as int?,
    );
  }

  SqliteDataSourceSettings copyWith({
    SqliteDataSourceType? type,
    String? query,
    bool? persistent,
    String? persistentName,
    List<int>? databaseData,
    int? connectionTimeout,
    bool? enableWal,
    int? pageSize,
    int? cacheSize,
  }) {
    return SqliteDataSourceSettings(
      type: type ?? this.type,
      query: query ?? this.query,
      persistent: persistent ?? this.persistent,
      persistentName: persistentName ?? this.persistentName,
      databaseData: databaseData ?? this.databaseData,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      enableWal: enableWal ?? this.enableWal,
      pageSize: pageSize ?? this.pageSize,
      cacheSize: cacheSize ?? this.cacheSize,
    );
  }

  @override
  String toString() => 'SqliteDataSourceSettings(type: $type, query: $query)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SqliteDataSourceSettings &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          query == other.query &&
          persistent == other.persistent &&
          persistentName == other.persistentName &&
          connectionTimeout == other.connectionTimeout &&
          enableWal == other.enableWal &&
          pageSize == other.pageSize &&
          cacheSize == other.cacheSize;

  @override
  int get hashCode => Object.hash(
    type,
    query,
    persistent,
    persistentName,
    connectionTimeout,
    enableWal,
    pageSize,
    cacheSize,
  );
}

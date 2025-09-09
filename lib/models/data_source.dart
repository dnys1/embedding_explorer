/// Abstract base class for all data sources in the embedding explorer.
///
/// This defines the common interface that all data source implementations
/// (CSV, SQLite, etc.) must implement to provide consistent data access
/// patterns throughout the application.
abstract class DataSource {
  /// Unique identifier for this data source
  String get id;

  /// Human-readable name for this data source
  String get name;

  /// Type of data source (e.g., 'csv', 'sqlite')
  String get type;

  /// Whether this data source is currently connected/loaded
  bool get isConnected;

  /// Configuration parameters specific to this data source type
  Map<String, dynamic> get config;

  /// Initialize and connect to the data source
  ///
  /// Returns true if connection was successful, false otherwise
  Future<bool> connect();

  /// Disconnect from the data source and cleanup resources
  Future<void> disconnect();

  /// Get the schema information (column names and types) for this data source
  ///
  /// Returns a map where keys are column names and values are data types
  Future<Map<String, String>> getSchema();

  /// Get sample data from the data source for preview purposes
  ///
  /// [limit] - Maximum number of rows to return (default: 10)
  /// Returns a list of maps where each map represents a row
  Future<List<Map<String, dynamic>>> getSampleData({int limit = 10});

  /// Get the total number of rows in the data source
  Future<int> getRowCount();

  /// Get all data from the data source
  ///
  /// [offset] - Number of rows to skip (for pagination)
  /// [limit] - Maximum number of rows to return (null for all)
  /// Returns a list of maps where each map represents a row
  Future<List<Map<String, dynamic>>> getAllData({int offset = 0, int? limit});

  /// Validate the data source configuration
  ///
  /// Returns a list of validation errors, empty if valid
  List<String> validate();

  /// Create a copy of this data source with updated configuration
  DataSource copyWith(Map<String, dynamic> newConfig);

  /// Serialize this data source to a JSON representation
  Map<String, dynamic> toJson();
}

/// Exception thrown when data source operations fail
class DataSourceException implements Exception {
  final String message;
  final String? sourceType;
  final dynamic cause;

  const DataSourceException(this.message, {this.sourceType, this.cause});

  @override
  String toString() {
    final type = sourceType != null ? '[$sourceType] ' : '';
    return 'DataSourceException: $type$message';
  }
}

/// Enumeration of supported data types in data sources
enum DataSourceFieldType {
  text,
  integer,
  real,
  boolean,
  date,
  datetime,
  blob,
  unknown;

  /// Convert from string representation to enum
  static DataSourceFieldType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'text':
      case 'string':
      case 'varchar':
      case 'char':
        return DataSourceFieldType.text;
      case 'int':
      case 'integer':
      case 'bigint':
        return DataSourceFieldType.integer;
      case 'real':
      case 'float':
      case 'double':
      case 'decimal':
        return DataSourceFieldType.real;
      case 'bool':
      case 'boolean':
        return DataSourceFieldType.boolean;
      case 'date':
        return DataSourceFieldType.date;
      case 'datetime':
      case 'timestamp':
        return DataSourceFieldType.datetime;
      case 'blob':
      case 'binary':
        return DataSourceFieldType.blob;
      default:
        return DataSourceFieldType.unknown;
    }
  }

  /// Convert enum to display string
  String get displayName {
    switch (this) {
      case DataSourceFieldType.text:
        return 'Text';
      case DataSourceFieldType.integer:
        return 'Integer';
      case DataSourceFieldType.real:
        return 'Number';
      case DataSourceFieldType.boolean:
        return 'Boolean';
      case DataSourceFieldType.date:
        return 'Date';
      case DataSourceFieldType.datetime:
        return 'Date/Time';
      case DataSourceFieldType.blob:
        return 'Binary';
      case DataSourceFieldType.unknown:
        return 'Unknown';
    }
  }
}

/// Metadata about a field/column in a data source
class DataSourceField {
  final String name;
  final DataSourceFieldType type;
  final bool nullable;
  final String? description;

  const DataSourceField({
    required this.name,
    required this.type,
    this.nullable = true,
    this.description,
  });

  /// Create from JSON representation
  factory DataSourceField.fromJson(Map<String, dynamic> json) {
    return DataSourceField(
      name: json['name'] as String,
      type: DataSourceFieldType.fromString(json['type'] as String),
      nullable: json['nullable'] as bool? ?? true,
      description: json['description'] as String?,
    );
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      'nullable': nullable,
      if (description != null) 'description': description,
    };
  }

  @override
  String toString() => '$name: ${type.displayName}${nullable ? '?' : ''}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataSourceField &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          nullable == other.nullable;

  @override
  int get hashCode => Object.hash(name, type, nullable);
}

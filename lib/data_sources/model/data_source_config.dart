import 'dart:convert';

import '../../configurations/model/configuration_collection.dart';
import '../../configurations/model/configuration_item.dart';
import '../../util/type_id.dart';
import 'data_source_settings.dart';

/// Configuration for a data source with metadata
class DataSourceConfig<T extends DataSourceSettings>
    implements ConfigurationItem {
  @override
  final String id;
  final String name;
  final String description;
  final DataSourceType type;
  final T settings;
  final String filename;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory DataSourceConfig({
    String? id,
    required String name,
    String description = '',
    required DataSourceType type,
    required T settings,
    required String filename,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return DataSourceConfig._(
      id: id ?? typeId('ds'),
      name: name,
      description: description,
      type: type,
      settings: settings,
      filename: filename,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  const DataSourceConfig._({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.settings,
    required this.filename,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with updated fields
  DataSourceConfig<T> copyWith({
    String? id,
    String? name,
    String? description,
    DataSourceType? type,
    T? settings,
    String? filename,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DataSourceConfig<T>._(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      settings: settings ?? this.settings,
      filename: filename ?? this.filename,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create from database result set
  static DataSourceConfig<DataSourceSettings> fromDatabase(
    Map<String, Object?> row,
  ) {
    final type = DataSourceType.values.byName(row['type'] as String);
    return DataSourceConfig<DataSourceSettings>._(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String? ?? '',
      type: type,
      filename: row['filename'] as String? ?? '',
      settings: DataSourceSettings.fromJson(
        type,
        jsonDecode(row['settings'] as String) as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  @override
  String toString() {
    return 'DataSourceConfig(id: $id, name: $name, type: ${type.name})';
  }
}

/// Data source types.
enum DataSourceType {
  csv('CSV File', 'Upload and parse comma-separated values files'),
  sqlite(
    'SQLite Database',
    'Upload SQLite database files or create in-memory databases',
  ),
  sample('Sample Data', 'Use built-in sample datasets for testing');

  const DataSourceType(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Collection for managing data source configurations
class DataSourceConfigCollection
    extends ConfigurationCollection<DataSourceConfig<DataSourceSettings>> {
  DataSourceConfigCollection(super.configService);

  @override
  String get prefix => 'ds';

  @override
  String get tableName => 'data_source_configs';

  @override
  Future<void> saveItem(DataSourceConfig<DataSourceSettings> item) async {
    await configService.saveDataSourceConfig(item);
  }

  @override
  Future<DataSourceConfig<DataSourceSettings>?> loadItem(String id) async {
    return await configService.getDataSourceConfig(id);
  }

  @override
  Future<List<DataSourceConfig<DataSourceSettings>>> loadAllItems() async {
    return await configService.getAllDataSourceConfigs();
  }

  @override
  Future<void> removeItem(DataSourceConfig<DataSourceSettings> item) async {
    await configService.deleteDataSourceConfig(item.id);
  }
}

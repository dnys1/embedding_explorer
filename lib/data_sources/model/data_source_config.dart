import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../configurations/model/configuration_collection.dart';
import '../../configurations/model/configuration_item.dart';
import '../../util/type_id.dart';
import 'data_source_settings.dart';

part 'data_source_config.freezed.dart';

/// Configuration for a data source with metadata
@freezed
abstract class DataSourceConfig<T extends DataSourceSettings>
    with _$DataSourceConfig<T>
    implements ConfigurationItem {
  factory DataSourceConfig.create({
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
    return DataSourceConfig(
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

  const factory DataSourceConfig({
    required String id,
    required String name,
    required String description,
    required DataSourceType type,
    required T settings,
    required String filename,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DataSourceConfig<T>;

  /// Create from database result set
  static DataSourceConfig<DataSourceSettings> fromDatabase(
    Map<String, Object?> row,
  ) {
    final type = DataSourceType.values.byName(row['type'] as String);
    return DataSourceConfig<DataSourceSettings>.create(
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
  String get tableName => 'data_sources';

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

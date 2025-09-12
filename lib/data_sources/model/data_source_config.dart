import 'dart:convert';

import 'package:logging/logging.dart';

import '../../configurations/model/configuration_collection.dart';
import '../../configurations/model/configuration_item.dart';
import 'data_source_settings.dart';

/// Configuration for a data source with metadata
class DataSourceConfig<T extends DataSourceSettings>
    implements ConfigurationItem {
  static final Logger _logger = Logger('DataSourceConfig');

  @override
  final String id;
  final String name;
  final String description;
  final DataSourceType type;
  final T settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DataSourceConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.settings,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DataSourceConfig<T>(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create from database result set
  static DataSourceConfig<DataSourceSettings>? fromDatabase(
    Map<String, Object?> row,
  ) {
    try {
      final type = DataSourceType.values.byName(row['type'] as String);
      return DataSourceConfig<DataSourceSettings>(
        id: row['id'] as String,
        name: row['name'] as String,
        description: row['description'] as String? ?? '',
        type: type,
        settings: DataSourceSettings.fromJson(
          type,
          jsonDecode(row['settings'] as String) as Map<String, dynamic>,
        ),
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );
    } catch (e) {
      _logger.severe('Error parsing DataSourceConfig from ResultSet: $row', e);
      return null;
    }
  }

  /// Create a default configuration
  static DataSourceConfig<T> createDefault<T extends DataSourceSettings>({
    required String name,
    required DataSourceType type,
    required T settings,
    String? description,
  }) {
    final now = DateTime.now();
    return DataSourceConfig<T>(
      id: 'temp_id', // Will be replaced when added to collection
      name: name,
      description: description ?? '',
      type: type,
      settings: settings,
      createdAt: now,
      updatedAt: now,
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
  );

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

  /// Add a new data source configuration
  Future<String> addConfig({
    required String name,
    required DataSourceType type,
    String? description,
    DataSourceSettings? settings,
  }) async {
    final id = generateId();

    // Create default settings if none provided
    final defaultSettings = settings ?? _createDefaultSettings(type);

    final config = DataSourceConfig<DataSourceSettings>(
      id: id,
      name: name,
      description: description ?? '',
      type: type,
      settings: defaultSettings,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await set(id, config);
    return id;
  }

  /// Create default settings for a data source type
  DataSourceSettings _createDefaultSettings(DataSourceType type) {
    switch (type) {
      case DataSourceType.csv:
        return const CsvDataSourceSettings();
      case DataSourceType.sqlite:
        return const SqliteDataSourceSettings();
    }
  }

  /// Update an existing configuration
  Future<bool> updateConfig(
    String id, {
    String? name,
    String? description,
    DataSourceType? type,
    DataSourceSettings? settings,
  }) async {
    final existing = getById(id);
    if (existing == null) return false;

    final updated = existing.copyWith(
      name: name,
      description: description,
      type: type,
      settings: settings,
      updatedAt: DateTime.now(),
    );

    await set(id, updated);
    return true;
  }

  /// Get configurations by type
  List<DataSourceConfig> getByType(DataSourceType type) {
    return all.where((config) => config.type == type).toList();
  }

  /// Search configurations by name
  List<DataSourceConfig> searchByName(String query) {
    final lowerQuery = query.toLowerCase();
    return all
        .where(
          (config) =>
              config.name.toLowerCase().contains(lowerQuery) ||
              config.description.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  @override
  Future<void> saveItem(
    String id,
    DataSourceConfig<DataSourceSettings> item,
  ) async {
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
}

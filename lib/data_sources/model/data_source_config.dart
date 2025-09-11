import '../../configurations/model/configuration_collection.dart';
import 'data_source_settings.dart';

/// Configuration for a data source with metadata
class DataSourceConfig<T extends DataSourceSettings> {
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

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'settings': settings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  static DataSourceConfig<DataSourceSettings>? fromJson(
    Map<String, dynamic> json,
  ) {
    try {
      final typeStr = json['type'] as String;
      final type = DataSourceType.values.byName(typeStr);
      final settingsJson = json['settings'] as Map<String, dynamic>? ?? {};
      final settings = DataSourceSettings.fromJson(typeStr, settingsJson);

      return DataSourceConfig<DataSourceSettings>(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        type: type,
        settings: settings,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
    } catch (e) {
      print('Error parsing DataSourceConfig from JSON: $e');
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
  static final DataSourceConfigCollection _instance =
      DataSourceConfigCollection._internal();

  factory DataSourceConfigCollection() {
    return _instance;
  }

  DataSourceConfigCollection._internal();

  @override
  String get prefix => 'ds';

  @override
  String get storageKey => 'data_source_configs';

  @override
  Map<String, dynamic> toJson(DataSourceConfig<DataSourceSettings> item) =>
      item.toJson();

  @override
  DataSourceConfig<DataSourceSettings>? fromJson(Map<String, dynamic> json) =>
      DataSourceConfig.fromJson(json);

  /// Add a new data source configuration
  String addConfig({
    required String name,
    required DataSourceType type,
    String? description,
    DataSourceSettings? settings,
  }) {
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

    set(id, config);
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
  bool updateConfig(
    String id, {
    String? name,
    String? description,
    DataSourceType? type,
    DataSourceSettings? settings,
  }) {
    final existing = getById(id);
    if (existing == null) return false;

    final updated = existing.copyWith(
      name: name,
      description: description,
      type: type,
      settings: settings,
      updatedAt: DateTime.now(),
    );

    set(id, updated);
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
}

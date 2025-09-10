import '../configuration_collection.dart';

/// Configuration for a data source with metadata
class DataSourceConfig {
  final String id;
  final String name;
  final String description;
  final DataSourceType type;
  final Map<String, dynamic> settings;
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
  DataSourceConfig copyWith({
    String? id,
    String? name,
    String? description,
    DataSourceType? type,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DataSourceConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      settings: settings ?? Map.of(this.settings),
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
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  static DataSourceConfig? fromJson(Map<String, dynamic> json) {
    try {
      return DataSourceConfig(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        type: DataSourceType.values.byName(json['type'] as String),
        settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
    } catch (e) {
      print('Error parsing DataSourceConfig from JSON: $e');
      return null;
    }
  }

  /// Create a default configuration
  static DataSourceConfig createDefault({
    required String name,
    required DataSourceType type,
    String? description,
    Map<String, dynamic>? settings,
  }) {
    final now = DateTime.now();
    return DataSourceConfig(
      id: 'temp_id', // Will be replaced when added to collection
      name: name,
      description: description ?? '',
      type: type,
      settings: settings ?? {},
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// Enum for data source types
enum DataSourceType { csv, sqlite }

/// Collection for managing data source configurations
class DataSourceConfigCollection
    extends ConfigurationCollection<DataSourceConfig> {
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
  Map<String, dynamic> toJson(DataSourceConfig item) => item.toJson();

  @override
  DataSourceConfig? fromJson(Map<String, dynamic> json) =>
      DataSourceConfig.fromJson(json);

  /// Add a new data source configuration
  String addConfig({
    required String name,
    required DataSourceType type,
    String? description,
    Map<String, dynamic>? settings,
  }) {
    final id = generateId();
    final config = DataSourceConfig.createDefault(
      name: name,
      type: type,
      description: description,
      settings: settings,
    ).copyWith(id: id);

    set(id, config);
    return id;
  }

  /// Update an existing configuration
  bool updateConfig(
    String id, {
    String? name,
    String? description,
    DataSourceType? type,
    Map<String, dynamic>? settings,
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

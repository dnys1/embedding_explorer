import 'dart:convert';

import '../../configurations/model/configuration_collection.dart';
import '../../configurations/model/configuration_item.dart';

/// Configuration for an embedding template with metadata
class EmbeddingTemplateConfig implements ConfigurationItem {
  @override
  final String id;
  final String name;
  final String description;
  final String template;
  final String dataSourceId;
  final List<String> availableFields;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmbeddingTemplateConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.template,
    required this.dataSourceId,
    required this.availableFields,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with updated fields
  EmbeddingTemplateConfig copyWith({
    String? id,
    String? name,
    String? description,
    String? template,
    String? dataSourceId,
    List<String>? availableFields,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmbeddingTemplateConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      template: template ?? this.template,
      dataSourceId: dataSourceId ?? this.dataSourceId,
      availableFields: availableFields ?? List.of(this.availableFields),
      metadata: metadata ?? Map.of(this.metadata),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create from database result
  static EmbeddingTemplateConfig? fromDatabase(Map<String, Object?> row) {
    try {
      return EmbeddingTemplateConfig(
        id: row['id'] as String,
        name: row['name'] as String,
        description: row['description'] as String? ?? '',
        template: row['template'] as String? ?? '',
        dataSourceId: row['data_source_id'] as String? ?? '',
        availableFields: row['available_fields'] != null
            ? List<String>.from(
                jsonDecode(row['available_fields'] as String) as List,
              )
            : <String>[],
        metadata: row['metadata'] != null
            ? jsonDecode(row['metadata'] as String) as Map<String, dynamic>
            : <String, dynamic>{},
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );
    } catch (e) {
      print('Error parsing EmbeddingTemplateConfig from database: $e');
      return null;
    }
  }

  /// Create a default configuration
  static EmbeddingTemplateConfig createDefault({
    required String name,
    required String dataSourceId,
    String? description,
    String? template,
    List<String>? availableFields,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return EmbeddingTemplateConfig(
      id: 'temp_id', // Will be replaced when added to collection
      name: name,
      description: description ?? '',
      template: template ?? '',
      dataSourceId: dataSourceId,
      availableFields: availableFields ?? [],
      metadata: metadata ?? {},
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Validate the template
  bool get isValid {
    return name.isNotEmpty && template.isNotEmpty && dataSourceId.isNotEmpty;
  }
}

/// Collection for managing embedding template configurations
class EmbeddingTemplateConfigCollection
    extends ConfigurationCollection<EmbeddingTemplateConfig> {
  EmbeddingTemplateConfigCollection(super.configService);

  @override
  String get prefix => 'et';

  @override
  String get tableName => 'embedding_template_configs';

  /// Add a new embedding template configuration
  Future<String> addConfig({
    required String name,
    required String dataSourceId,
    String? description,
    String? template,
    List<String>? availableFields,
    Map<String, dynamic>? metadata,
  }) async {
    final id = generateId();
    final config = EmbeddingTemplateConfig.createDefault(
      name: name,
      dataSourceId: dataSourceId,
      description: description,
      template: template,
      availableFields: availableFields,
      metadata: metadata,
    ).copyWith(id: id);

    await add(config);
    return id;
  }

  /// Update an existing configuration
  Future<bool> updateConfig(
    String id, {
    String? name,
    String? description,
    String? template,
    String? dataSourceId,
    List<String>? availableFields,
    Map<String, dynamic>? metadata,
  }) async {
    final existing = getById(id);
    if (existing == null) return false;

    final updated = existing.copyWith(
      name: name,
      description: description,
      template: template,
      dataSourceId: dataSourceId,
      availableFields: availableFields,
      metadata: metadata,
      updatedAt: DateTime.now(),
    );

    await add(updated);
    return true;
  }

  /// Get valid templates only
  List<EmbeddingTemplateConfig> getValidTemplates() {
    return all.where((config) => config.isValid).toList();
  }

  /// Search configurations by name or description
  List<EmbeddingTemplateConfig> searchByName(String query) {
    final lowerQuery = query.toLowerCase();
    return all
        .where(
          (config) =>
              config.name.toLowerCase().contains(lowerQuery) ||
              config.description.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Get templates that use specific fields
  List<EmbeddingTemplateConfig> getTemplatesUsingFields(List<String> fields) {
    return all
        .where(
          (config) => fields.any((field) => config.template.contains(field)),
        )
        .toList();
  }

  @override
  Future<void> saveItem(String id, EmbeddingTemplateConfig item) async {
    await configService.saveEmbeddingTemplateConfig(item);
  }

  @override
  Future<EmbeddingTemplateConfig?> loadItem(String id) async {
    return await configService.getEmbeddingTemplateConfig(id);
  }

  @override
  Future<List<EmbeddingTemplateConfig>> loadAllItems() async {
    return await configService.getAllEmbeddingTemplateConfigs();
  }

  @override
  Future<void> removeItem(EmbeddingTemplateConfig item) async {
    await configService.deleteEmbeddingTemplateConfig(item.id);
  }
}

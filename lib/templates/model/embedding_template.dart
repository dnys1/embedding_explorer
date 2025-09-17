import 'package:freezed_annotation/freezed_annotation.dart';

import '../../configurations/model/configuration_collection.dart';
import '../../configurations/model/configuration_item.dart';

part 'embedding_template.freezed.dart';

/// Configuration for an embedding template with metadata
@freezed
abstract class EmbeddingTemplate
    with _$EmbeddingTemplate
    implements ConfigurationItem {
  factory EmbeddingTemplate.create({
    required String id,
    required String name,
    String? description,
    required String template,
    required String idTemplate,
    required String dataSourceId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmbeddingTemplate(
      id: id,
      name: name,
      description: description ?? '',
      template: template,
      idTemplate: idTemplate,
      dataSourceId: dataSourceId,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  const factory EmbeddingTemplate({
    required String id,
    required String name,
    required String description,
    required String template,
    required String idTemplate,
    required String dataSourceId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _EmbeddingTemplate;

  const EmbeddingTemplate._();

  /// Create from database result
  factory EmbeddingTemplate.fromDatabase(Map<String, Object?> row) {
    return EmbeddingTemplate(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String? ?? '',
      template: row['template'] as String,
      idTemplate: row['id_template'] as String,
      dataSourceId: row['data_source_id'] as String? ?? '',
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  /// Validate the template
  bool get isValid {
    return name.isNotEmpty &&
        template.isNotEmpty &&
        idTemplate.isNotEmpty &&
        dataSourceId.isNotEmpty;
  }
}

/// Collection for managing embedding template configurations
class EmbeddingTemplateCollection
    extends ConfigurationCollection<EmbeddingTemplate> {
  EmbeddingTemplateCollection(super.configService);

  @override
  String get prefix => 'tmpl';

  @override
  String get tableName => 'templates';

  /// Get valid templates only
  List<EmbeddingTemplate> getValidTemplates() {
    return all.where((config) => config.isValid).toList();
  }

  /// Search configurations by name or description
  List<EmbeddingTemplate> searchByName(String query) {
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
  List<EmbeddingTemplate> getTemplatesUsingFields(List<String> fields) {
    return all
        .where(
          (config) => fields.any((field) => config.template.contains(field)),
        )
        .toList();
  }

  @override
  Future<void> saveItem(EmbeddingTemplate item) async {
    await configService.saveEmbeddingTemplateConfig(item);
  }

  @override
  Future<EmbeddingTemplate?> loadItem(String id) async {
    return await configService.getEmbeddingTemplate(id);
  }

  @override
  Future<List<EmbeddingTemplate>> loadAllItems() async {
    return await configService.getAllEmbeddingTemplateConfigs();
  }

  @override
  Future<void> removeItem(EmbeddingTemplate item) async {
    await configService.deleteEmbeddingTemplateConfig(item.id);
  }
}

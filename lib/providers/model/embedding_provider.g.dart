// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embedding_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProviderDefinition _$ProviderDefinitionFromJson(Map<String, dynamic> json) =>
    _ProviderDefinition(
      type: $enumDecode(_$EmbeddingProviderTypeEnumMap, json['type']),
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      iconData: json['iconData'] == null
          ? null
          : FaIconData.fromJson(json['iconData'] as Map<String, dynamic>),
      iconUri: json['iconUri'] == null
          ? null
          : Uri.parse(json['iconUri'] as String),
      knownModels: (json['knownModels'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, EmbeddingModel.fromJson(e as Map<String, dynamic>)),
      ),
      defaultSettings: json['defaultSettings'] as Map<String, dynamic>,
      requiredCredential: $enumDecodeNullable(
        _$CredentialTypeEnumMap,
        json['requiredCredential'],
      ),
      credentialPlaceholder: json['credentialPlaceholder'] as String?,
      configurationFields: (json['configurationFields'] as List<dynamic>)
          .map((e) => ConfigurationField.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProviderDefinitionToJson(
  _ProviderDefinition instance,
) => <String, dynamic>{
  'type': _$EmbeddingProviderTypeEnumMap[instance.type]!,
  'displayName': instance.displayName,
  'description': instance.description,
  'iconData': instance.iconData,
  'iconUri': instance.iconUri?.toString(),
  'knownModels': instance.knownModels,
  'defaultSettings': instance.defaultSettings,
  'requiredCredential': _$CredentialTypeEnumMap[instance.requiredCredential],
  'credentialPlaceholder': instance.credentialPlaceholder,
  'configurationFields': instance.configurationFields,
};

const _$EmbeddingProviderTypeEnumMap = {
  EmbeddingProviderType.openai: 'openai',
  EmbeddingProviderType.gemini: 'gemini',
  EmbeddingProviderType.ollama: 'ollama',
  EmbeddingProviderType.custom: 'custom',
};

const _$CredentialTypeEnumMap = {CredentialType.apiKey: 'apiKey'};

_ConfigurationField _$ConfigurationFieldFromJson(Map<String, dynamic> json) =>
    _ConfigurationField(
      key: json['key'] as String,
      label: json['label'] as String,
      type: $enumDecode(_$ConfigurationFieldTypeEnumMap, json['type']),
      required: json['required'] as bool? ?? false,
      description: json['description'] as String?,
      defaultValue: json['defaultValue'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      validation: json['validation'] as String?,
    );

Map<String, dynamic> _$ConfigurationFieldToJson(_ConfigurationField instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'type': _$ConfigurationFieldTypeEnumMap[instance.type]!,
      'required': instance.required,
      'description': instance.description,
      'defaultValue': instance.defaultValue,
      'options': instance.options,
      'validation': instance.validation,
    };

const _$ConfigurationFieldTypeEnumMap = {
  ConfigurationFieldType.text: 'text',
  ConfigurationFieldType.password: 'password',
  ConfigurationFieldType.dropdown: 'dropdown',
  ConfigurationFieldType.number: 'number',
  ConfigurationFieldType.boolean: 'boolean',
};

_EmbeddingModel _$EmbeddingModelFromJson(Map<String, dynamic> json) =>
    _EmbeddingModel(
      id: json['id'] as String,
      providerId: json['providerId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      vectorType: $enumDecode(_$VectorTypeEnumMap, json['vectorType']),
      dimensions: (json['dimensions'] as num).toInt(),
      maxInputTokens: (json['maxInputTokens'] as num?)?.toInt(),
      costPer1kTokens: (json['costPer1kTokens'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$EmbeddingModelToJson(_EmbeddingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'providerId': instance.providerId,
      'name': instance.name,
      'description': instance.description,
      'vectorType': _$VectorTypeEnumMap[instance.vectorType]!,
      'dimensions': instance.dimensions,
      'maxInputTokens': instance.maxInputTokens,
      'costPer1kTokens': instance.costPer1kTokens,
    };

const _$VectorTypeEnumMap = {
  VectorType.float64: 'float64',
  VectorType.float32: 'float32',
  VectorType.float16: 'float16',
  VectorType.bfloat16: 'bfloat16',
  VectorType.float8: 'float8',
  VectorType.float1bit: 'float1bit',
};

_ValidationResult _$ValidationResultFromJson(
  Map<String, dynamic> json,
) => _ValidationResult(
  isValid: json['isValid'] as bool,
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  warnings:
      (json['warnings'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$ValidationResultToJson(_ValidationResult instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'errors': instance.errors,
      'warnings': instance.warnings,
    };

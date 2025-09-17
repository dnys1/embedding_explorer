// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outerbase_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageWrapper _$MessageWrapperFromJson(Map<String, dynamic> json) =>
    _MessageWrapper(
      type: json['type'] as String,
      id: (json['id'] as num).toInt(),
      data: json['data'],
      error: json['error'] as String?,
    );

Map<String, dynamic> _$MessageWrapperToJson(_MessageWrapper instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'data': instance.data,
      'error': instance.error,
    };

_ResultSet _$ResultSetFromJson(Map<String, dynamic> json) => _ResultSet(
  rows: (json['rows'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  headers: (json['headers'] as List<dynamic>)
      .map((e) => DriverResultHeader.fromJson(e as Map<String, dynamic>))
      .toList(),
  stat: DriverStats.fromJson(json['stat'] as Map<String, dynamic>),
  lastInsertRowid: (json['lastInsertRowid'] as num?)?.toInt(),
);

Map<String, dynamic> _$ResultSetToJson(_ResultSet instance) =>
    <String, dynamic>{
      'rows': instance.rows,
      'headers': instance.headers.map((e) => e.toJson()).toList(),
      'stat': instance.stat.toJson(),
      'lastInsertRowid': instance.lastInsertRowid,
    };

_DriverResultHeader _$DriverResultHeaderFromJson(Map<String, dynamic> json) =>
    _DriverResultHeader(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      originalType: json['originalType'] as String?,
      type: $enumDecodeNullable(_$ColumnTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$DriverResultHeaderToJson(_DriverResultHeader instance) =>
    <String, dynamic>{
      'name': instance.name,
      'displayName': instance.displayName,
      'originalType': instance.originalType,
      'type': _$ColumnTypeEnumMap[instance.type],
    };

const _$ColumnTypeEnumMap = {
  ColumnType.text: 'text',
  ColumnType.integer: 'integer',
  ColumnType.real: 'real',
  ColumnType.blob: 'blob',
};

_DriverStats _$DriverStatsFromJson(Map<String, dynamic> json) => _DriverStats(
  rowsAffected: (json['rowsAffected'] as num).toInt(),
  rowsRead: (json['rowsRead'] as num?)?.toInt(),
  rowsWritten: (json['rowsWritten'] as num?)?.toInt(),
  queryDurationMs: json['queryDurationMs'] as num?,
);

Map<String, dynamic> _$DriverStatsToJson(_DriverStats instance) =>
    <String, dynamic>{
      'rowsAffected': instance.rowsAffected,
      'rowsRead': instance.rowsRead,
      'rowsWritten': instance.rowsWritten,
      'queryDurationMs': instance.queryDurationMs,
    };

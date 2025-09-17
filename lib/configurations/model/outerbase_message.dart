// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'outerbase_message.freezed.dart';
part 'outerbase_message.g.dart';

const _serializable = JsonSerializable(explicitToJson: true);

@freezed
abstract class MessageWrapper with _$MessageWrapper {
  @_serializable
  const factory MessageWrapper({
    required String type,
    required int id,
    Object? data,
    String? error,
  }) = _MessageWrapper;

  factory MessageWrapper.fromJson(Map<String, dynamic> json) =>
      _$MessageWrapperFromJson(json);
}

@freezed
abstract class ResultSet with _$ResultSet {
  @_serializable
  const factory ResultSet({
    required List<Map<String, Object?>> rows,
    required List<DriverResultHeader> headers,
    required DriverStats stat,
    required int? lastInsertRowid,
  }) = _ResultSet;

  factory ResultSet.fromJson(Map<String, dynamic> json) =>
      _$ResultSetFromJson(json);
}

@freezed
abstract class DriverResultHeader with _$DriverResultHeader {
  @_serializable
  const factory DriverResultHeader({
    required String name,
    required String displayName,
    required String? originalType,
    required ColumnType? type,
  }) = _DriverResultHeader;

  factory DriverResultHeader.fromJson(Map<String, dynamic> json) =>
      _$DriverResultHeaderFromJson(json);
}

@freezed
abstract class DriverStats with _$DriverStats {
  @_serializable
  const factory DriverStats({
    required int rowsAffected,
    required int? rowsRead,
    required int? rowsWritten,
    required num? queryDurationMs,
  }) = _DriverStats;

  factory DriverStats.fromJson(Map<String, dynamic> json) =>
      _$DriverStatsFromJson(json);
}

enum ColumnType {
  text(1),
  integer(2),
  real(3),
  blob(4);

  const ColumnType(this.rawValue);

  factory ColumnType.fromSql(String? type) {
    if (type == null) {
      return ColumnType.blob;
    }
    type = type.toUpperCase();

    if (type.contains('CHAR') ||
        type.contains('TEXT') ||
        type.contains('CLOB') ||
        type.contains('STRING')) {
      return ColumnType.text;
    }
    if (type.contains('INT')) {
      return ColumnType.integer;
    }
    if (type.contains('BLOB')) {
      return ColumnType.blob;
    }
    if (type.contains('REAL') ||
        type.contains('FLOAT') ||
        type.contains('DOUBLE')) {
      return ColumnType.real;
    }

    return ColumnType.text;
  }

  final int rawValue;
}

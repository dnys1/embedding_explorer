// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'embedding_tables.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmbeddingTable {

 String get id; String get tableName; String get jobId; String get dataSourceId; String get embeddingTemplateId; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of EmbeddingTable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmbeddingTableCopyWith<EmbeddingTable> get copyWith => _$EmbeddingTableCopyWithImpl<EmbeddingTable>(this as EmbeddingTable, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmbeddingTable&&(identical(other.id, id) || other.id == id)&&(identical(other.tableName, tableName) || other.tableName == tableName)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.dataSourceId, dataSourceId) || other.dataSourceId == dataSourceId)&&(identical(other.embeddingTemplateId, embeddingTemplateId) || other.embeddingTemplateId == embeddingTemplateId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,tableName,jobId,dataSourceId,embeddingTemplateId,createdAt,updatedAt);

@override
String toString() {
  return 'EmbeddingTable(id: $id, tableName: $tableName, jobId: $jobId, dataSourceId: $dataSourceId, embeddingTemplateId: $embeddingTemplateId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EmbeddingTableCopyWith<$Res>  {
  factory $EmbeddingTableCopyWith(EmbeddingTable value, $Res Function(EmbeddingTable) _then) = _$EmbeddingTableCopyWithImpl;
@useResult
$Res call({
 String id, String tableName, String jobId, String dataSourceId, String embeddingTemplateId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$EmbeddingTableCopyWithImpl<$Res>
    implements $EmbeddingTableCopyWith<$Res> {
  _$EmbeddingTableCopyWithImpl(this._self, this._then);

  final EmbeddingTable _self;
  final $Res Function(EmbeddingTable) _then;

/// Create a copy of EmbeddingTable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tableName = null,Object? jobId = null,Object? dataSourceId = null,Object? embeddingTemplateId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tableName: null == tableName ? _self.tableName : tableName // ignore: cast_nullable_to_non_nullable
as String,jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,dataSourceId: null == dataSourceId ? _self.dataSourceId : dataSourceId // ignore: cast_nullable_to_non_nullable
as String,embeddingTemplateId: null == embeddingTemplateId ? _self.embeddingTemplateId : embeddingTemplateId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [EmbeddingTable].
extension EmbeddingTablePatterns on EmbeddingTable {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmbeddingTable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmbeddingTable() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmbeddingTable value)  $default,){
final _that = this;
switch (_that) {
case _EmbeddingTable():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmbeddingTable value)?  $default,){
final _that = this;
switch (_that) {
case _EmbeddingTable() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tableName,  String jobId,  String dataSourceId,  String embeddingTemplateId,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmbeddingTable() when $default != null:
return $default(_that.id,_that.tableName,_that.jobId,_that.dataSourceId,_that.embeddingTemplateId,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tableName,  String jobId,  String dataSourceId,  String embeddingTemplateId,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _EmbeddingTable():
return $default(_that.id,_that.tableName,_that.jobId,_that.dataSourceId,_that.embeddingTemplateId,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tableName,  String jobId,  String dataSourceId,  String embeddingTemplateId,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _EmbeddingTable() when $default != null:
return $default(_that.id,_that.tableName,_that.jobId,_that.dataSourceId,_that.embeddingTemplateId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _EmbeddingTable implements EmbeddingTable {
  const _EmbeddingTable({required this.id, required this.tableName, required this.jobId, required this.dataSourceId, required this.embeddingTemplateId, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String tableName;
@override final  String jobId;
@override final  String dataSourceId;
@override final  String embeddingTemplateId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of EmbeddingTable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmbeddingTableCopyWith<_EmbeddingTable> get copyWith => __$EmbeddingTableCopyWithImpl<_EmbeddingTable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmbeddingTable&&(identical(other.id, id) || other.id == id)&&(identical(other.tableName, tableName) || other.tableName == tableName)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.dataSourceId, dataSourceId) || other.dataSourceId == dataSourceId)&&(identical(other.embeddingTemplateId, embeddingTemplateId) || other.embeddingTemplateId == embeddingTemplateId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,tableName,jobId,dataSourceId,embeddingTemplateId,createdAt,updatedAt);

@override
String toString() {
  return 'EmbeddingTable(id: $id, tableName: $tableName, jobId: $jobId, dataSourceId: $dataSourceId, embeddingTemplateId: $embeddingTemplateId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EmbeddingTableCopyWith<$Res> implements $EmbeddingTableCopyWith<$Res> {
  factory _$EmbeddingTableCopyWith(_EmbeddingTable value, $Res Function(_EmbeddingTable) _then) = __$EmbeddingTableCopyWithImpl;
@override @useResult
$Res call({
 String id, String tableName, String jobId, String dataSourceId, String embeddingTemplateId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$EmbeddingTableCopyWithImpl<$Res>
    implements _$EmbeddingTableCopyWith<$Res> {
  __$EmbeddingTableCopyWithImpl(this._self, this._then);

  final _EmbeddingTable _self;
  final $Res Function(_EmbeddingTable) _then;

/// Create a copy of EmbeddingTable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tableName = null,Object? jobId = null,Object? dataSourceId = null,Object? embeddingTemplateId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_EmbeddingTable(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tableName: null == tableName ? _self.tableName : tableName // ignore: cast_nullable_to_non_nullable
as String,jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,dataSourceId: null == dataSourceId ? _self.dataSourceId : dataSourceId // ignore: cast_nullable_to_non_nullable
as String,embeddingTemplateId: null == embeddingTemplateId ? _self.embeddingTemplateId : embeddingTemplateId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$EmbeddingColumn {

 String get id; String get tableId; String get columnName; String get modelProviderId; String get modelName; VectorType get vectorType; int get dimensions; DateTime get createdAt;
/// Create a copy of EmbeddingColumn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmbeddingColumnCopyWith<EmbeddingColumn> get copyWith => _$EmbeddingColumnCopyWithImpl<EmbeddingColumn>(this as EmbeddingColumn, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmbeddingColumn&&(identical(other.id, id) || other.id == id)&&(identical(other.tableId, tableId) || other.tableId == tableId)&&(identical(other.columnName, columnName) || other.columnName == columnName)&&(identical(other.modelProviderId, modelProviderId) || other.modelProviderId == modelProviderId)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.vectorType, vectorType) || other.vectorType == vectorType)&&(identical(other.dimensions, dimensions) || other.dimensions == dimensions)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,tableId,columnName,modelProviderId,modelName,vectorType,dimensions,createdAt);

@override
String toString() {
  return 'EmbeddingColumn(id: $id, tableId: $tableId, columnName: $columnName, modelProviderId: $modelProviderId, modelName: $modelName, vectorType: $vectorType, dimensions: $dimensions, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $EmbeddingColumnCopyWith<$Res>  {
  factory $EmbeddingColumnCopyWith(EmbeddingColumn value, $Res Function(EmbeddingColumn) _then) = _$EmbeddingColumnCopyWithImpl;
@useResult
$Res call({
 String id, String tableId, String columnName, String modelProviderId, String modelName, VectorType vectorType, int dimensions, DateTime createdAt
});




}
/// @nodoc
class _$EmbeddingColumnCopyWithImpl<$Res>
    implements $EmbeddingColumnCopyWith<$Res> {
  _$EmbeddingColumnCopyWithImpl(this._self, this._then);

  final EmbeddingColumn _self;
  final $Res Function(EmbeddingColumn) _then;

/// Create a copy of EmbeddingColumn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tableId = null,Object? columnName = null,Object? modelProviderId = null,Object? modelName = null,Object? vectorType = null,Object? dimensions = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tableId: null == tableId ? _self.tableId : tableId // ignore: cast_nullable_to_non_nullable
as String,columnName: null == columnName ? _self.columnName : columnName // ignore: cast_nullable_to_non_nullable
as String,modelProviderId: null == modelProviderId ? _self.modelProviderId : modelProviderId // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,vectorType: null == vectorType ? _self.vectorType : vectorType // ignore: cast_nullable_to_non_nullable
as VectorType,dimensions: null == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [EmbeddingColumn].
extension EmbeddingColumnPatterns on EmbeddingColumn {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmbeddingColumn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmbeddingColumn() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmbeddingColumn value)  $default,){
final _that = this;
switch (_that) {
case _EmbeddingColumn():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmbeddingColumn value)?  $default,){
final _that = this;
switch (_that) {
case _EmbeddingColumn() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tableId,  String columnName,  String modelProviderId,  String modelName,  VectorType vectorType,  int dimensions,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmbeddingColumn() when $default != null:
return $default(_that.id,_that.tableId,_that.columnName,_that.modelProviderId,_that.modelName,_that.vectorType,_that.dimensions,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tableId,  String columnName,  String modelProviderId,  String modelName,  VectorType vectorType,  int dimensions,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _EmbeddingColumn():
return $default(_that.id,_that.tableId,_that.columnName,_that.modelProviderId,_that.modelName,_that.vectorType,_that.dimensions,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tableId,  String columnName,  String modelProviderId,  String modelName,  VectorType vectorType,  int dimensions,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _EmbeddingColumn() when $default != null:
return $default(_that.id,_that.tableId,_that.columnName,_that.modelProviderId,_that.modelName,_that.vectorType,_that.dimensions,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _EmbeddingColumn implements EmbeddingColumn {
  const _EmbeddingColumn({required this.id, required this.tableId, required this.columnName, required this.modelProviderId, required this.modelName, required this.vectorType, required this.dimensions, required this.createdAt});
  

@override final  String id;
@override final  String tableId;
@override final  String columnName;
@override final  String modelProviderId;
@override final  String modelName;
@override final  VectorType vectorType;
@override final  int dimensions;
@override final  DateTime createdAt;

/// Create a copy of EmbeddingColumn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmbeddingColumnCopyWith<_EmbeddingColumn> get copyWith => __$EmbeddingColumnCopyWithImpl<_EmbeddingColumn>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmbeddingColumn&&(identical(other.id, id) || other.id == id)&&(identical(other.tableId, tableId) || other.tableId == tableId)&&(identical(other.columnName, columnName) || other.columnName == columnName)&&(identical(other.modelProviderId, modelProviderId) || other.modelProviderId == modelProviderId)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.vectorType, vectorType) || other.vectorType == vectorType)&&(identical(other.dimensions, dimensions) || other.dimensions == dimensions)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,tableId,columnName,modelProviderId,modelName,vectorType,dimensions,createdAt);

@override
String toString() {
  return 'EmbeddingColumn(id: $id, tableId: $tableId, columnName: $columnName, modelProviderId: $modelProviderId, modelName: $modelName, vectorType: $vectorType, dimensions: $dimensions, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EmbeddingColumnCopyWith<$Res> implements $EmbeddingColumnCopyWith<$Res> {
  factory _$EmbeddingColumnCopyWith(_EmbeddingColumn value, $Res Function(_EmbeddingColumn) _then) = __$EmbeddingColumnCopyWithImpl;
@override @useResult
$Res call({
 String id, String tableId, String columnName, String modelProviderId, String modelName, VectorType vectorType, int dimensions, DateTime createdAt
});




}
/// @nodoc
class __$EmbeddingColumnCopyWithImpl<$Res>
    implements _$EmbeddingColumnCopyWith<$Res> {
  __$EmbeddingColumnCopyWithImpl(this._self, this._then);

  final _EmbeddingColumn _self;
  final $Res Function(_EmbeddingColumn) _then;

/// Create a copy of EmbeddingColumn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tableId = null,Object? columnName = null,Object? modelProviderId = null,Object? modelName = null,Object? vectorType = null,Object? dimensions = null,Object? createdAt = null,}) {
  return _then(_EmbeddingColumn(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tableId: null == tableId ? _self.tableId : tableId // ignore: cast_nullable_to_non_nullable
as String,columnName: null == columnName ? _self.columnName : columnName // ignore: cast_nullable_to_non_nullable
as String,modelProviderId: null == modelProviderId ? _self.modelProviderId : modelProviderId // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,vectorType: null == vectorType ? _self.vectorType : vectorType // ignore: cast_nullable_to_non_nullable
as VectorType,dimensions: null == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

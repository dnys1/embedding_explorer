// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'embedding_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmbeddingJob {

 String get id; String get name; String get description; String get dataSourceId; String get embeddingTemplateId; List<String> get providerIds; List<String> get modelIds; JobStatus get status; DateTime get createdAt; DateTime? get startedAt; DateTime? get completedAt; String? get errorMessage; Map<String, dynamic>? get results; int? get totalRecords; int? get processedRecords;
/// Create a copy of EmbeddingJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmbeddingJobCopyWith<EmbeddingJob> get copyWith => _$EmbeddingJobCopyWithImpl<EmbeddingJob>(this as EmbeddingJob, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmbeddingJob&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.dataSourceId, dataSourceId) || other.dataSourceId == dataSourceId)&&(identical(other.embeddingTemplateId, embeddingTemplateId) || other.embeddingTemplateId == embeddingTemplateId)&&const DeepCollectionEquality().equals(other.providerIds, providerIds)&&const DeepCollectionEquality().equals(other.modelIds, modelIds)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.totalRecords, totalRecords) || other.totalRecords == totalRecords)&&(identical(other.processedRecords, processedRecords) || other.processedRecords == processedRecords));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,dataSourceId,embeddingTemplateId,const DeepCollectionEquality().hash(providerIds),const DeepCollectionEquality().hash(modelIds),status,createdAt,startedAt,completedAt,errorMessage,const DeepCollectionEquality().hash(results),totalRecords,processedRecords);

@override
String toString() {
  return 'EmbeddingJob(id: $id, name: $name, description: $description, dataSourceId: $dataSourceId, embeddingTemplateId: $embeddingTemplateId, providerIds: $providerIds, modelIds: $modelIds, status: $status, createdAt: $createdAt, startedAt: $startedAt, completedAt: $completedAt, errorMessage: $errorMessage, results: $results, totalRecords: $totalRecords, processedRecords: $processedRecords)';
}


}

/// @nodoc
abstract mixin class $EmbeddingJobCopyWith<$Res>  {
  factory $EmbeddingJobCopyWith(EmbeddingJob value, $Res Function(EmbeddingJob) _then) = _$EmbeddingJobCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String dataSourceId, String embeddingTemplateId, List<String> providerIds, List<String> modelIds, JobStatus status, DateTime createdAt, DateTime? startedAt, DateTime? completedAt, String? errorMessage, Map<String, dynamic>? results, int? totalRecords, int? processedRecords
});




}
/// @nodoc
class _$EmbeddingJobCopyWithImpl<$Res>
    implements $EmbeddingJobCopyWith<$Res> {
  _$EmbeddingJobCopyWithImpl(this._self, this._then);

  final EmbeddingJob _self;
  final $Res Function(EmbeddingJob) _then;

/// Create a copy of EmbeddingJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? dataSourceId = null,Object? embeddingTemplateId = null,Object? providerIds = null,Object? modelIds = null,Object? status = null,Object? createdAt = null,Object? startedAt = freezed,Object? completedAt = freezed,Object? errorMessage = freezed,Object? results = freezed,Object? totalRecords = freezed,Object? processedRecords = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dataSourceId: null == dataSourceId ? _self.dataSourceId : dataSourceId // ignore: cast_nullable_to_non_nullable
as String,embeddingTemplateId: null == embeddingTemplateId ? _self.embeddingTemplateId : embeddingTemplateId // ignore: cast_nullable_to_non_nullable
as String,providerIds: null == providerIds ? _self.providerIds : providerIds // ignore: cast_nullable_to_non_nullable
as List<String>,modelIds: null == modelIds ? _self.modelIds : modelIds // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,results: freezed == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,totalRecords: freezed == totalRecords ? _self.totalRecords : totalRecords // ignore: cast_nullable_to_non_nullable
as int?,processedRecords: freezed == processedRecords ? _self.processedRecords : processedRecords // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmbeddingJob].
extension EmbeddingJobPatterns on EmbeddingJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmbeddingJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmbeddingJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmbeddingJob value)  $default,){
final _that = this;
switch (_that) {
case _EmbeddingJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmbeddingJob value)?  $default,){
final _that = this;
switch (_that) {
case _EmbeddingJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String dataSourceId,  String embeddingTemplateId,  List<String> providerIds,  List<String> modelIds,  JobStatus status,  DateTime createdAt,  DateTime? startedAt,  DateTime? completedAt,  String? errorMessage,  Map<String, dynamic>? results,  int? totalRecords,  int? processedRecords)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmbeddingJob() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.dataSourceId,_that.embeddingTemplateId,_that.providerIds,_that.modelIds,_that.status,_that.createdAt,_that.startedAt,_that.completedAt,_that.errorMessage,_that.results,_that.totalRecords,_that.processedRecords);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String dataSourceId,  String embeddingTemplateId,  List<String> providerIds,  List<String> modelIds,  JobStatus status,  DateTime createdAt,  DateTime? startedAt,  DateTime? completedAt,  String? errorMessage,  Map<String, dynamic>? results,  int? totalRecords,  int? processedRecords)  $default,) {final _that = this;
switch (_that) {
case _EmbeddingJob():
return $default(_that.id,_that.name,_that.description,_that.dataSourceId,_that.embeddingTemplateId,_that.providerIds,_that.modelIds,_that.status,_that.createdAt,_that.startedAt,_that.completedAt,_that.errorMessage,_that.results,_that.totalRecords,_that.processedRecords);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String dataSourceId,  String embeddingTemplateId,  List<String> providerIds,  List<String> modelIds,  JobStatus status,  DateTime createdAt,  DateTime? startedAt,  DateTime? completedAt,  String? errorMessage,  Map<String, dynamic>? results,  int? totalRecords,  int? processedRecords)?  $default,) {final _that = this;
switch (_that) {
case _EmbeddingJob() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.dataSourceId,_that.embeddingTemplateId,_that.providerIds,_that.modelIds,_that.status,_that.createdAt,_that.startedAt,_that.completedAt,_that.errorMessage,_that.results,_that.totalRecords,_that.processedRecords);case _:
  return null;

}
}

}

/// @nodoc


class _EmbeddingJob extends EmbeddingJob {
  const _EmbeddingJob({required this.id, required this.name, required this.description, required this.dataSourceId, required this.embeddingTemplateId, required final  List<String> providerIds, required final  List<String> modelIds, this.status = JobStatus.running, required this.createdAt, this.startedAt, this.completedAt, this.errorMessage, final  Map<String, dynamic>? results, this.totalRecords, this.processedRecords}): _providerIds = providerIds,_modelIds = modelIds,_results = results,super._();
  

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String dataSourceId;
@override final  String embeddingTemplateId;
 final  List<String> _providerIds;
@override List<String> get providerIds {
  if (_providerIds is EqualUnmodifiableListView) return _providerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providerIds);
}

 final  List<String> _modelIds;
@override List<String> get modelIds {
  if (_modelIds is EqualUnmodifiableListView) return _modelIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modelIds);
}

@override@JsonKey() final  JobStatus status;
@override final  DateTime createdAt;
@override final  DateTime? startedAt;
@override final  DateTime? completedAt;
@override final  String? errorMessage;
 final  Map<String, dynamic>? _results;
@override Map<String, dynamic>? get results {
  final value = _results;
  if (value == null) return null;
  if (_results is EqualUnmodifiableMapView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  int? totalRecords;
@override final  int? processedRecords;

/// Create a copy of EmbeddingJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmbeddingJobCopyWith<_EmbeddingJob> get copyWith => __$EmbeddingJobCopyWithImpl<_EmbeddingJob>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmbeddingJob&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.dataSourceId, dataSourceId) || other.dataSourceId == dataSourceId)&&(identical(other.embeddingTemplateId, embeddingTemplateId) || other.embeddingTemplateId == embeddingTemplateId)&&const DeepCollectionEquality().equals(other._providerIds, _providerIds)&&const DeepCollectionEquality().equals(other._modelIds, _modelIds)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.totalRecords, totalRecords) || other.totalRecords == totalRecords)&&(identical(other.processedRecords, processedRecords) || other.processedRecords == processedRecords));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,dataSourceId,embeddingTemplateId,const DeepCollectionEquality().hash(_providerIds),const DeepCollectionEquality().hash(_modelIds),status,createdAt,startedAt,completedAt,errorMessage,const DeepCollectionEquality().hash(_results),totalRecords,processedRecords);

@override
String toString() {
  return 'EmbeddingJob(id: $id, name: $name, description: $description, dataSourceId: $dataSourceId, embeddingTemplateId: $embeddingTemplateId, providerIds: $providerIds, modelIds: $modelIds, status: $status, createdAt: $createdAt, startedAt: $startedAt, completedAt: $completedAt, errorMessage: $errorMessage, results: $results, totalRecords: $totalRecords, processedRecords: $processedRecords)';
}


}

/// @nodoc
abstract mixin class _$EmbeddingJobCopyWith<$Res> implements $EmbeddingJobCopyWith<$Res> {
  factory _$EmbeddingJobCopyWith(_EmbeddingJob value, $Res Function(_EmbeddingJob) _then) = __$EmbeddingJobCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String dataSourceId, String embeddingTemplateId, List<String> providerIds, List<String> modelIds, JobStatus status, DateTime createdAt, DateTime? startedAt, DateTime? completedAt, String? errorMessage, Map<String, dynamic>? results, int? totalRecords, int? processedRecords
});




}
/// @nodoc
class __$EmbeddingJobCopyWithImpl<$Res>
    implements _$EmbeddingJobCopyWith<$Res> {
  __$EmbeddingJobCopyWithImpl(this._self, this._then);

  final _EmbeddingJob _self;
  final $Res Function(_EmbeddingJob) _then;

/// Create a copy of EmbeddingJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? dataSourceId = null,Object? embeddingTemplateId = null,Object? providerIds = null,Object? modelIds = null,Object? status = null,Object? createdAt = null,Object? startedAt = freezed,Object? completedAt = freezed,Object? errorMessage = freezed,Object? results = freezed,Object? totalRecords = freezed,Object? processedRecords = freezed,}) {
  return _then(_EmbeddingJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dataSourceId: null == dataSourceId ? _self.dataSourceId : dataSourceId // ignore: cast_nullable_to_non_nullable
as String,embeddingTemplateId: null == embeddingTemplateId ? _self.embeddingTemplateId : embeddingTemplateId // ignore: cast_nullable_to_non_nullable
as String,providerIds: null == providerIds ? _self._providerIds : providerIds // ignore: cast_nullable_to_non_nullable
as List<String>,modelIds: null == modelIds ? _self._modelIds : modelIds // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,results: freezed == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,totalRecords: freezed == totalRecords ? _self.totalRecords : totalRecords // ignore: cast_nullable_to_non_nullable
as int?,processedRecords: freezed == processedRecords ? _self.processedRecords : processedRecords // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

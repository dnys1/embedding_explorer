// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'embedding_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmbeddingTemplate {

 String get id; String get name; String get description; String get template; String get idTemplate; String get dataSourceId; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of EmbeddingTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmbeddingTemplateCopyWith<EmbeddingTemplate> get copyWith => _$EmbeddingTemplateCopyWithImpl<EmbeddingTemplate>(this as EmbeddingTemplate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmbeddingTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.template, template) || other.template == template)&&(identical(other.idTemplate, idTemplate) || other.idTemplate == idTemplate)&&(identical(other.dataSourceId, dataSourceId) || other.dataSourceId == dataSourceId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,template,idTemplate,dataSourceId,createdAt,updatedAt);

@override
String toString() {
  return 'EmbeddingTemplate(id: $id, name: $name, description: $description, template: $template, idTemplate: $idTemplate, dataSourceId: $dataSourceId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EmbeddingTemplateCopyWith<$Res>  {
  factory $EmbeddingTemplateCopyWith(EmbeddingTemplate value, $Res Function(EmbeddingTemplate) _then) = _$EmbeddingTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String template, String idTemplate, String dataSourceId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$EmbeddingTemplateCopyWithImpl<$Res>
    implements $EmbeddingTemplateCopyWith<$Res> {
  _$EmbeddingTemplateCopyWithImpl(this._self, this._then);

  final EmbeddingTemplate _self;
  final $Res Function(EmbeddingTemplate) _then;

/// Create a copy of EmbeddingTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? template = null,Object? idTemplate = null,Object? dataSourceId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,template: null == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as String,idTemplate: null == idTemplate ? _self.idTemplate : idTemplate // ignore: cast_nullable_to_non_nullable
as String,dataSourceId: null == dataSourceId ? _self.dataSourceId : dataSourceId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [EmbeddingTemplate].
extension EmbeddingTemplatePatterns on EmbeddingTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmbeddingTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmbeddingTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmbeddingTemplate value)  $default,){
final _that = this;
switch (_that) {
case _EmbeddingTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmbeddingTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _EmbeddingTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String template,  String idTemplate,  String dataSourceId,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmbeddingTemplate() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.template,_that.idTemplate,_that.dataSourceId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String template,  String idTemplate,  String dataSourceId,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _EmbeddingTemplate():
return $default(_that.id,_that.name,_that.description,_that.template,_that.idTemplate,_that.dataSourceId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String template,  String idTemplate,  String dataSourceId,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _EmbeddingTemplate() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.template,_that.idTemplate,_that.dataSourceId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _EmbeddingTemplate extends EmbeddingTemplate {
  const _EmbeddingTemplate({required this.id, required this.name, required this.description, required this.template, required this.idTemplate, required this.dataSourceId, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String template;
@override final  String idTemplate;
@override final  String dataSourceId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of EmbeddingTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmbeddingTemplateCopyWith<_EmbeddingTemplate> get copyWith => __$EmbeddingTemplateCopyWithImpl<_EmbeddingTemplate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmbeddingTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.template, template) || other.template == template)&&(identical(other.idTemplate, idTemplate) || other.idTemplate == idTemplate)&&(identical(other.dataSourceId, dataSourceId) || other.dataSourceId == dataSourceId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,template,idTemplate,dataSourceId,createdAt,updatedAt);

@override
String toString() {
  return 'EmbeddingTemplate(id: $id, name: $name, description: $description, template: $template, idTemplate: $idTemplate, dataSourceId: $dataSourceId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EmbeddingTemplateCopyWith<$Res> implements $EmbeddingTemplateCopyWith<$Res> {
  factory _$EmbeddingTemplateCopyWith(_EmbeddingTemplate value, $Res Function(_EmbeddingTemplate) _then) = __$EmbeddingTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String template, String idTemplate, String dataSourceId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$EmbeddingTemplateCopyWithImpl<$Res>
    implements _$EmbeddingTemplateCopyWith<$Res> {
  __$EmbeddingTemplateCopyWithImpl(this._self, this._then);

  final _EmbeddingTemplate _self;
  final $Res Function(_EmbeddingTemplate) _then;

/// Create a copy of EmbeddingTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? template = null,Object? idTemplate = null,Object? dataSourceId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_EmbeddingTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,template: null == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as String,idTemplate: null == idTemplate ? _self.idTemplate : idTemplate // ignore: cast_nullable_to_non_nullable
as String,dataSourceId: null == dataSourceId ? _self.dataSourceId : dataSourceId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

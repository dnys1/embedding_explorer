// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'data_source_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DataSourceConfig<T extends DataSourceSettings> {

 String get id; String get name; String get description; DataSourceType get type; T get settings; String get filename; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of DataSourceConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DataSourceConfigCopyWith<T, DataSourceConfig<T>> get copyWith => _$DataSourceConfigCopyWithImpl<T, DataSourceConfig<T>>(this as DataSourceConfig<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DataSourceConfig<T>&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.settings, settings)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,const DeepCollectionEquality().hash(settings),filename,createdAt,updatedAt);

@override
String toString() {
  return 'DataSourceConfig<$T>(id: $id, name: $name, description: $description, type: $type, settings: $settings, filename: $filename, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DataSourceConfigCopyWith<T extends DataSourceSettings,$Res>  {
  factory $DataSourceConfigCopyWith(DataSourceConfig<T> value, $Res Function(DataSourceConfig<T>) _then) = _$DataSourceConfigCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, DataSourceType type, T settings, String filename, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$DataSourceConfigCopyWithImpl<T extends DataSourceSettings,$Res>
    implements $DataSourceConfigCopyWith<T, $Res> {
  _$DataSourceConfigCopyWithImpl(this._self, this._then);

  final DataSourceConfig<T> _self;
  final $Res Function(DataSourceConfig<T>) _then;

/// Create a copy of DataSourceConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? type = null,Object? settings = null,Object? filename = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DataSourceType,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as T,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DataSourceConfig].
extension DataSourceConfigPatterns<T extends DataSourceSettings> on DataSourceConfig<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DataSourceConfig<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DataSourceConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DataSourceConfig<T> value)  $default,){
final _that = this;
switch (_that) {
case _DataSourceConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DataSourceConfig<T> value)?  $default,){
final _that = this;
switch (_that) {
case _DataSourceConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  DataSourceType type,  T settings,  String filename,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DataSourceConfig() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.settings,_that.filename,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  DataSourceType type,  T settings,  String filename,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DataSourceConfig():
return $default(_that.id,_that.name,_that.description,_that.type,_that.settings,_that.filename,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  DataSourceType type,  T settings,  String filename,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DataSourceConfig() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.settings,_that.filename,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _DataSourceConfig<T extends DataSourceSettings> implements DataSourceConfig<T> {
  const _DataSourceConfig({required this.id, required this.name, required this.description, required this.type, required this.settings, required this.filename, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String name;
@override final  String description;
@override final  DataSourceType type;
@override final  T settings;
@override final  String filename;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of DataSourceConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DataSourceConfigCopyWith<T, _DataSourceConfig<T>> get copyWith => __$DataSourceConfigCopyWithImpl<T, _DataSourceConfig<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DataSourceConfig<T>&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.settings, settings)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,const DeepCollectionEquality().hash(settings),filename,createdAt,updatedAt);

@override
String toString() {
  return 'DataSourceConfig<$T>(id: $id, name: $name, description: $description, type: $type, settings: $settings, filename: $filename, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DataSourceConfigCopyWith<T extends DataSourceSettings,$Res> implements $DataSourceConfigCopyWith<T, $Res> {
  factory _$DataSourceConfigCopyWith(_DataSourceConfig<T> value, $Res Function(_DataSourceConfig<T>) _then) = __$DataSourceConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, DataSourceType type, T settings, String filename, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$DataSourceConfigCopyWithImpl<T extends DataSourceSettings,$Res>
    implements _$DataSourceConfigCopyWith<T, $Res> {
  __$DataSourceConfigCopyWithImpl(this._self, this._then);

  final _DataSourceConfig<T> _self;
  final $Res Function(_DataSourceConfig<T>) _then;

/// Create a copy of DataSourceConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? type = null,Object? settings = null,Object? filename = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_DataSourceConfig<T>(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DataSourceType,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as T,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

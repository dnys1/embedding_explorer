// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'embedding_provider_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmbeddingProviderConfig {

 String get id; String get name; String get description; EmbeddingProviderType get type; String? get customTemplateId; Map<String, dynamic> get settings; Credential? get credential; bool get persistCredentials; Set<String> get enabledModels; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of EmbeddingProviderConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmbeddingProviderConfigCopyWith<EmbeddingProviderConfig> get copyWith => _$EmbeddingProviderConfigCopyWithImpl<EmbeddingProviderConfig>(this as EmbeddingProviderConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmbeddingProviderConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.customTemplateId, customTemplateId) || other.customTemplateId == customTemplateId)&&const DeepCollectionEquality().equals(other.settings, settings)&&(identical(other.credential, credential) || other.credential == credential)&&(identical(other.persistCredentials, persistCredentials) || other.persistCredentials == persistCredentials)&&const DeepCollectionEquality().equals(other.enabledModels, enabledModels)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,customTemplateId,const DeepCollectionEquality().hash(settings),credential,persistCredentials,const DeepCollectionEquality().hash(enabledModels),createdAt,updatedAt);

@override
String toString() {
  return 'EmbeddingProviderConfig(id: $id, name: $name, description: $description, type: $type, customTemplateId: $customTemplateId, settings: $settings, credential: $credential, persistCredentials: $persistCredentials, enabledModels: $enabledModels, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EmbeddingProviderConfigCopyWith<$Res>  {
  factory $EmbeddingProviderConfigCopyWith(EmbeddingProviderConfig value, $Res Function(EmbeddingProviderConfig) _then) = _$EmbeddingProviderConfigCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, EmbeddingProviderType type, String? customTemplateId, Map<String, dynamic> settings, Credential? credential, bool persistCredentials, Set<String> enabledModels, DateTime createdAt, DateTime updatedAt
});


$CredentialCopyWith<$Res>? get credential;

}
/// @nodoc
class _$EmbeddingProviderConfigCopyWithImpl<$Res>
    implements $EmbeddingProviderConfigCopyWith<$Res> {
  _$EmbeddingProviderConfigCopyWithImpl(this._self, this._then);

  final EmbeddingProviderConfig _self;
  final $Res Function(EmbeddingProviderConfig) _then;

/// Create a copy of EmbeddingProviderConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? type = null,Object? customTemplateId = freezed,Object? settings = null,Object? credential = freezed,Object? persistCredentials = null,Object? enabledModels = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EmbeddingProviderType,customTemplateId: freezed == customTemplateId ? _self.customTemplateId : customTemplateId // ignore: cast_nullable_to_non_nullable
as String?,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,credential: freezed == credential ? _self.credential : credential // ignore: cast_nullable_to_non_nullable
as Credential?,persistCredentials: null == persistCredentials ? _self.persistCredentials : persistCredentials // ignore: cast_nullable_to_non_nullable
as bool,enabledModels: null == enabledModels ? _self.enabledModels : enabledModels // ignore: cast_nullable_to_non_nullable
as Set<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of EmbeddingProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CredentialCopyWith<$Res>? get credential {
    if (_self.credential == null) {
    return null;
  }

  return $CredentialCopyWith<$Res>(_self.credential!, (value) {
    return _then(_self.copyWith(credential: value));
  });
}
}


/// Adds pattern-matching-related methods to [EmbeddingProviderConfig].
extension EmbeddingProviderConfigPatterns on EmbeddingProviderConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmbeddingProviderConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmbeddingProviderConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmbeddingProviderConfig value)  $default,){
final _that = this;
switch (_that) {
case _EmbeddingProviderConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmbeddingProviderConfig value)?  $default,){
final _that = this;
switch (_that) {
case _EmbeddingProviderConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  EmbeddingProviderType type,  String? customTemplateId,  Map<String, dynamic> settings,  Credential? credential,  bool persistCredentials,  Set<String> enabledModels,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmbeddingProviderConfig() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.customTemplateId,_that.settings,_that.credential,_that.persistCredentials,_that.enabledModels,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  EmbeddingProviderType type,  String? customTemplateId,  Map<String, dynamic> settings,  Credential? credential,  bool persistCredentials,  Set<String> enabledModels,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _EmbeddingProviderConfig():
return $default(_that.id,_that.name,_that.description,_that.type,_that.customTemplateId,_that.settings,_that.credential,_that.persistCredentials,_that.enabledModels,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  EmbeddingProviderType type,  String? customTemplateId,  Map<String, dynamic> settings,  Credential? credential,  bool persistCredentials,  Set<String> enabledModels,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _EmbeddingProviderConfig() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.customTemplateId,_that.settings,_that.credential,_that.persistCredentials,_that.enabledModels,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _EmbeddingProviderConfig implements EmbeddingProviderConfig {
  const _EmbeddingProviderConfig({required this.id, required this.name, required this.description, required this.type, this.customTemplateId, required final  Map<String, dynamic> settings, required this.credential, required this.persistCredentials, required final  Set<String> enabledModels, required this.createdAt, required this.updatedAt}): _settings = settings,_enabledModels = enabledModels;
  

@override final  String id;
@override final  String name;
@override final  String description;
@override final  EmbeddingProviderType type;
@override final  String? customTemplateId;
 final  Map<String, dynamic> _settings;
@override Map<String, dynamic> get settings {
  if (_settings is EqualUnmodifiableMapView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_settings);
}

@override final  Credential? credential;
@override final  bool persistCredentials;
 final  Set<String> _enabledModels;
@override Set<String> get enabledModels {
  if (_enabledModels is EqualUnmodifiableSetView) return _enabledModels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_enabledModels);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of EmbeddingProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmbeddingProviderConfigCopyWith<_EmbeddingProviderConfig> get copyWith => __$EmbeddingProviderConfigCopyWithImpl<_EmbeddingProviderConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmbeddingProviderConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.customTemplateId, customTemplateId) || other.customTemplateId == customTemplateId)&&const DeepCollectionEquality().equals(other._settings, _settings)&&(identical(other.credential, credential) || other.credential == credential)&&(identical(other.persistCredentials, persistCredentials) || other.persistCredentials == persistCredentials)&&const DeepCollectionEquality().equals(other._enabledModels, _enabledModels)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,customTemplateId,const DeepCollectionEquality().hash(_settings),credential,persistCredentials,const DeepCollectionEquality().hash(_enabledModels),createdAt,updatedAt);

@override
String toString() {
  return 'EmbeddingProviderConfig(id: $id, name: $name, description: $description, type: $type, customTemplateId: $customTemplateId, settings: $settings, credential: $credential, persistCredentials: $persistCredentials, enabledModels: $enabledModels, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EmbeddingProviderConfigCopyWith<$Res> implements $EmbeddingProviderConfigCopyWith<$Res> {
  factory _$EmbeddingProviderConfigCopyWith(_EmbeddingProviderConfig value, $Res Function(_EmbeddingProviderConfig) _then) = __$EmbeddingProviderConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, EmbeddingProviderType type, String? customTemplateId, Map<String, dynamic> settings, Credential? credential, bool persistCredentials, Set<String> enabledModels, DateTime createdAt, DateTime updatedAt
});


@override $CredentialCopyWith<$Res>? get credential;

}
/// @nodoc
class __$EmbeddingProviderConfigCopyWithImpl<$Res>
    implements _$EmbeddingProviderConfigCopyWith<$Res> {
  __$EmbeddingProviderConfigCopyWithImpl(this._self, this._then);

  final _EmbeddingProviderConfig _self;
  final $Res Function(_EmbeddingProviderConfig) _then;

/// Create a copy of EmbeddingProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? type = null,Object? customTemplateId = freezed,Object? settings = null,Object? credential = freezed,Object? persistCredentials = null,Object? enabledModels = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_EmbeddingProviderConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EmbeddingProviderType,customTemplateId: freezed == customTemplateId ? _self.customTemplateId : customTemplateId // ignore: cast_nullable_to_non_nullable
as String?,settings: null == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,credential: freezed == credential ? _self.credential : credential // ignore: cast_nullable_to_non_nullable
as Credential?,persistCredentials: null == persistCredentials ? _self.persistCredentials : persistCredentials // ignore: cast_nullable_to_non_nullable
as bool,enabledModels: null == enabledModels ? _self._enabledModels : enabledModels // ignore: cast_nullable_to_non_nullable
as Set<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of EmbeddingProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CredentialCopyWith<$Res>? get credential {
    if (_self.credential == null) {
    return null;
  }

  return $CredentialCopyWith<$Res>(_self.credential!, (value) {
    return _then(_self.copyWith(credential: value));
  });
}
}

// dart format on

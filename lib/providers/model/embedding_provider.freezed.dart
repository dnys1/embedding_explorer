// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'embedding_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProviderConnectionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderConnectionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProviderConnectionState()';
}


}

/// @nodoc
class $ProviderConnectionStateCopyWith<$Res>  {
$ProviderConnectionStateCopyWith(ProviderConnectionState _, $Res Function(ProviderConnectionState) __);
}


/// Adds pattern-matching-related methods to [ProviderConnectionState].
extension ProviderConnectionStatePatterns on ProviderConnectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Unconfigured value)?  unconfigured,TResult Function( _PartiallyConfigured value)?  partiallyConfigured,TResult Function( _Connected value)?  connected,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Unconfigured() when unconfigured != null:
return unconfigured(_that);case _PartiallyConfigured() when partiallyConfigured != null:
return partiallyConfigured(_that);case _Connected() when connected != null:
return connected(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Unconfigured value)  unconfigured,required TResult Function( _PartiallyConfigured value)  partiallyConfigured,required TResult Function( _Connected value)  connected,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Unconfigured():
return unconfigured(_that);case _PartiallyConfigured():
return partiallyConfigured(_that);case _Connected():
return connected(_that);case _Error():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Unconfigured value)?  unconfigured,TResult? Function( _PartiallyConfigured value)?  partiallyConfigured,TResult? Function( _Connected value)?  connected,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Unconfigured() when unconfigured != null:
return unconfigured(_that);case _PartiallyConfigured() when partiallyConfigured != null:
return partiallyConfigured(_that);case _Connected() when connected != null:
return connected(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  unconfigured,TResult Function( EmbeddingProviderConfig config,  List<String> missingRequirements)?  partiallyConfigured,TResult Function( EmbeddingProviderConfig config)?  connected,TResult Function( EmbeddingProviderConfig config,  String error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Unconfigured() when unconfigured != null:
return unconfigured();case _PartiallyConfigured() when partiallyConfigured != null:
return partiallyConfigured(_that.config,_that.missingRequirements);case _Connected() when connected != null:
return connected(_that.config);case _Error() when error != null:
return error(_that.config,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  unconfigured,required TResult Function( EmbeddingProviderConfig config,  List<String> missingRequirements)  partiallyConfigured,required TResult Function( EmbeddingProviderConfig config)  connected,required TResult Function( EmbeddingProviderConfig config,  String error)  error,}) {final _that = this;
switch (_that) {
case _Unconfigured():
return unconfigured();case _PartiallyConfigured():
return partiallyConfigured(_that.config,_that.missingRequirements);case _Connected():
return connected(_that.config);case _Error():
return error(_that.config,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  unconfigured,TResult? Function( EmbeddingProviderConfig config,  List<String> missingRequirements)?  partiallyConfigured,TResult? Function( EmbeddingProviderConfig config)?  connected,TResult? Function( EmbeddingProviderConfig config,  String error)?  error,}) {final _that = this;
switch (_that) {
case _Unconfigured() when unconfigured != null:
return unconfigured();case _PartiallyConfigured() when partiallyConfigured != null:
return partiallyConfigured(_that.config,_that.missingRequirements);case _Connected() when connected != null:
return connected(_that.config);case _Error() when error != null:
return error(_that.config,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _Unconfigured implements ProviderConnectionState {
  const _Unconfigured();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unconfigured);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProviderConnectionState.unconfigured()';
}


}




/// @nodoc


class _PartiallyConfigured implements ProviderConnectionState {
  const _PartiallyConfigured({required this.config, required final  List<String> missingRequirements}): _missingRequirements = missingRequirements;
  

 final  EmbeddingProviderConfig config;
 final  List<String> _missingRequirements;
 List<String> get missingRequirements {
  if (_missingRequirements is EqualUnmodifiableListView) return _missingRequirements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missingRequirements);
}


/// Create a copy of ProviderConnectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartiallyConfiguredCopyWith<_PartiallyConfigured> get copyWith => __$PartiallyConfiguredCopyWithImpl<_PartiallyConfigured>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartiallyConfigured&&(identical(other.config, config) || other.config == config)&&const DeepCollectionEquality().equals(other._missingRequirements, _missingRequirements));
}


@override
int get hashCode => Object.hash(runtimeType,config,const DeepCollectionEquality().hash(_missingRequirements));

@override
String toString() {
  return 'ProviderConnectionState.partiallyConfigured(config: $config, missingRequirements: $missingRequirements)';
}


}

/// @nodoc
abstract mixin class _$PartiallyConfiguredCopyWith<$Res> implements $ProviderConnectionStateCopyWith<$Res> {
  factory _$PartiallyConfiguredCopyWith(_PartiallyConfigured value, $Res Function(_PartiallyConfigured) _then) = __$PartiallyConfiguredCopyWithImpl;
@useResult
$Res call({
 EmbeddingProviderConfig config, List<String> missingRequirements
});




}
/// @nodoc
class __$PartiallyConfiguredCopyWithImpl<$Res>
    implements _$PartiallyConfiguredCopyWith<$Res> {
  __$PartiallyConfiguredCopyWithImpl(this._self, this._then);

  final _PartiallyConfigured _self;
  final $Res Function(_PartiallyConfigured) _then;

/// Create a copy of ProviderConnectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? config = null,Object? missingRequirements = null,}) {
  return _then(_PartiallyConfigured(
config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as EmbeddingProviderConfig,missingRequirements: null == missingRequirements ? _self._missingRequirements : missingRequirements // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class _Connected implements ProviderConnectionState {
  const _Connected({required this.config});
  

 final  EmbeddingProviderConfig config;

/// Create a copy of ProviderConnectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectedCopyWith<_Connected> get copyWith => __$ConnectedCopyWithImpl<_Connected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Connected&&(identical(other.config, config) || other.config == config));
}


@override
int get hashCode => Object.hash(runtimeType,config);

@override
String toString() {
  return 'ProviderConnectionState.connected(config: $config)';
}


}

/// @nodoc
abstract mixin class _$ConnectedCopyWith<$Res> implements $ProviderConnectionStateCopyWith<$Res> {
  factory _$ConnectedCopyWith(_Connected value, $Res Function(_Connected) _then) = __$ConnectedCopyWithImpl;
@useResult
$Res call({
 EmbeddingProviderConfig config
});




}
/// @nodoc
class __$ConnectedCopyWithImpl<$Res>
    implements _$ConnectedCopyWith<$Res> {
  __$ConnectedCopyWithImpl(this._self, this._then);

  final _Connected _self;
  final $Res Function(_Connected) _then;

/// Create a copy of ProviderConnectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? config = null,}) {
  return _then(_Connected(
config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as EmbeddingProviderConfig,
  ));
}


}

/// @nodoc


class _Error implements ProviderConnectionState {
  const _Error({required this.config, required this.error});
  

 final  EmbeddingProviderConfig config;
 final  String error;

/// Create a copy of ProviderConnectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.config, config) || other.config == config)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,config,error);

@override
String toString() {
  return 'ProviderConnectionState.error(config: $config, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $ProviderConnectionStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 EmbeddingProviderConfig config, String error
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of ProviderConnectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? config = null,Object? error = null,}) {
  return _then(_Error(
config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as EmbeddingProviderConfig,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ProviderDefinition {

 EmbeddingProviderType get type; String get displayName; String get description; FaIconData get icon; Map<String, EmbeddingModel> get knownModels; Map<String, dynamic> get defaultSettings; CredentialType? get requiredCredential; String? get credentialPlaceholder; List<ConfigurationField> get configurationFields;
/// Create a copy of ProviderDefinition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderDefinitionCopyWith<ProviderDefinition> get copyWith => _$ProviderDefinitionCopyWithImpl<ProviderDefinition>(this as ProviderDefinition, _$identity);

  /// Serializes this ProviderDefinition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderDefinition&&(identical(other.type, type) || other.type == type)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other.knownModels, knownModels)&&const DeepCollectionEquality().equals(other.defaultSettings, defaultSettings)&&(identical(other.requiredCredential, requiredCredential) || other.requiredCredential == requiredCredential)&&(identical(other.credentialPlaceholder, credentialPlaceholder) || other.credentialPlaceholder == credentialPlaceholder)&&const DeepCollectionEquality().equals(other.configurationFields, configurationFields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,displayName,description,icon,const DeepCollectionEquality().hash(knownModels),const DeepCollectionEquality().hash(defaultSettings),requiredCredential,credentialPlaceholder,const DeepCollectionEquality().hash(configurationFields));

@override
String toString() {
  return 'ProviderDefinition(type: $type, displayName: $displayName, description: $description, icon: $icon, knownModels: $knownModels, defaultSettings: $defaultSettings, requiredCredential: $requiredCredential, credentialPlaceholder: $credentialPlaceholder, configurationFields: $configurationFields)';
}


}

/// @nodoc
abstract mixin class $ProviderDefinitionCopyWith<$Res>  {
  factory $ProviderDefinitionCopyWith(ProviderDefinition value, $Res Function(ProviderDefinition) _then) = _$ProviderDefinitionCopyWithImpl;
@useResult
$Res call({
 EmbeddingProviderType type, String displayName, String description, FaIconData icon, Map<String, EmbeddingModel> knownModels, Map<String, dynamic> defaultSettings, CredentialType? requiredCredential, String? credentialPlaceholder, List<ConfigurationField> configurationFields
});




}
/// @nodoc
class _$ProviderDefinitionCopyWithImpl<$Res>
    implements $ProviderDefinitionCopyWith<$Res> {
  _$ProviderDefinitionCopyWithImpl(this._self, this._then);

  final ProviderDefinition _self;
  final $Res Function(ProviderDefinition) _then;

/// Create a copy of ProviderDefinition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? displayName = null,Object? description = null,Object? icon = null,Object? knownModels = null,Object? defaultSettings = null,Object? requiredCredential = freezed,Object? credentialPlaceholder = freezed,Object? configurationFields = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EmbeddingProviderType,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as FaIconData,knownModels: null == knownModels ? _self.knownModels : knownModels // ignore: cast_nullable_to_non_nullable
as Map<String, EmbeddingModel>,defaultSettings: null == defaultSettings ? _self.defaultSettings : defaultSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,requiredCredential: freezed == requiredCredential ? _self.requiredCredential : requiredCredential // ignore: cast_nullable_to_non_nullable
as CredentialType?,credentialPlaceholder: freezed == credentialPlaceholder ? _self.credentialPlaceholder : credentialPlaceholder // ignore: cast_nullable_to_non_nullable
as String?,configurationFields: null == configurationFields ? _self.configurationFields : configurationFields // ignore: cast_nullable_to_non_nullable
as List<ConfigurationField>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderDefinition].
extension ProviderDefinitionPatterns on ProviderDefinition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderDefinition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderDefinition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderDefinition value)  $default,){
final _that = this;
switch (_that) {
case _ProviderDefinition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderDefinition value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderDefinition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EmbeddingProviderType type,  String displayName,  String description,  FaIconData icon,  Map<String, EmbeddingModel> knownModels,  Map<String, dynamic> defaultSettings,  CredentialType? requiredCredential,  String? credentialPlaceholder,  List<ConfigurationField> configurationFields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderDefinition() when $default != null:
return $default(_that.type,_that.displayName,_that.description,_that.icon,_that.knownModels,_that.defaultSettings,_that.requiredCredential,_that.credentialPlaceholder,_that.configurationFields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EmbeddingProviderType type,  String displayName,  String description,  FaIconData icon,  Map<String, EmbeddingModel> knownModels,  Map<String, dynamic> defaultSettings,  CredentialType? requiredCredential,  String? credentialPlaceholder,  List<ConfigurationField> configurationFields)  $default,) {final _that = this;
switch (_that) {
case _ProviderDefinition():
return $default(_that.type,_that.displayName,_that.description,_that.icon,_that.knownModels,_that.defaultSettings,_that.requiredCredential,_that.credentialPlaceholder,_that.configurationFields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EmbeddingProviderType type,  String displayName,  String description,  FaIconData icon,  Map<String, EmbeddingModel> knownModels,  Map<String, dynamic> defaultSettings,  CredentialType? requiredCredential,  String? credentialPlaceholder,  List<ConfigurationField> configurationFields)?  $default,) {final _that = this;
switch (_that) {
case _ProviderDefinition() when $default != null:
return $default(_that.type,_that.displayName,_that.description,_that.icon,_that.knownModels,_that.defaultSettings,_that.requiredCredential,_that.credentialPlaceholder,_that.configurationFields);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderDefinition implements ProviderDefinition {
  const _ProviderDefinition({required this.type, required this.displayName, required this.description, required this.icon, required final  Map<String, EmbeddingModel> knownModels, required final  Map<String, dynamic> defaultSettings, this.requiredCredential, this.credentialPlaceholder, required final  List<ConfigurationField> configurationFields}): _knownModels = knownModels,_defaultSettings = defaultSettings,_configurationFields = configurationFields;
  factory _ProviderDefinition.fromJson(Map<String, dynamic> json) => _$ProviderDefinitionFromJson(json);

@override final  EmbeddingProviderType type;
@override final  String displayName;
@override final  String description;
@override final  FaIconData icon;
 final  Map<String, EmbeddingModel> _knownModels;
@override Map<String, EmbeddingModel> get knownModels {
  if (_knownModels is EqualUnmodifiableMapView) return _knownModels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_knownModels);
}

 final  Map<String, dynamic> _defaultSettings;
@override Map<String, dynamic> get defaultSettings {
  if (_defaultSettings is EqualUnmodifiableMapView) return _defaultSettings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_defaultSettings);
}

@override final  CredentialType? requiredCredential;
@override final  String? credentialPlaceholder;
 final  List<ConfigurationField> _configurationFields;
@override List<ConfigurationField> get configurationFields {
  if (_configurationFields is EqualUnmodifiableListView) return _configurationFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_configurationFields);
}


/// Create a copy of ProviderDefinition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderDefinitionCopyWith<_ProviderDefinition> get copyWith => __$ProviderDefinitionCopyWithImpl<_ProviderDefinition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderDefinitionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderDefinition&&(identical(other.type, type) || other.type == type)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other._knownModels, _knownModels)&&const DeepCollectionEquality().equals(other._defaultSettings, _defaultSettings)&&(identical(other.requiredCredential, requiredCredential) || other.requiredCredential == requiredCredential)&&(identical(other.credentialPlaceholder, credentialPlaceholder) || other.credentialPlaceholder == credentialPlaceholder)&&const DeepCollectionEquality().equals(other._configurationFields, _configurationFields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,displayName,description,icon,const DeepCollectionEquality().hash(_knownModels),const DeepCollectionEquality().hash(_defaultSettings),requiredCredential,credentialPlaceholder,const DeepCollectionEquality().hash(_configurationFields));

@override
String toString() {
  return 'ProviderDefinition(type: $type, displayName: $displayName, description: $description, icon: $icon, knownModels: $knownModels, defaultSettings: $defaultSettings, requiredCredential: $requiredCredential, credentialPlaceholder: $credentialPlaceholder, configurationFields: $configurationFields)';
}


}

/// @nodoc
abstract mixin class _$ProviderDefinitionCopyWith<$Res> implements $ProviderDefinitionCopyWith<$Res> {
  factory _$ProviderDefinitionCopyWith(_ProviderDefinition value, $Res Function(_ProviderDefinition) _then) = __$ProviderDefinitionCopyWithImpl;
@override @useResult
$Res call({
 EmbeddingProviderType type, String displayName, String description, FaIconData icon, Map<String, EmbeddingModel> knownModels, Map<String, dynamic> defaultSettings, CredentialType? requiredCredential, String? credentialPlaceholder, List<ConfigurationField> configurationFields
});




}
/// @nodoc
class __$ProviderDefinitionCopyWithImpl<$Res>
    implements _$ProviderDefinitionCopyWith<$Res> {
  __$ProviderDefinitionCopyWithImpl(this._self, this._then);

  final _ProviderDefinition _self;
  final $Res Function(_ProviderDefinition) _then;

/// Create a copy of ProviderDefinition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? displayName = null,Object? description = null,Object? icon = null,Object? knownModels = null,Object? defaultSettings = null,Object? requiredCredential = freezed,Object? credentialPlaceholder = freezed,Object? configurationFields = null,}) {
  return _then(_ProviderDefinition(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EmbeddingProviderType,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as FaIconData,knownModels: null == knownModels ? _self._knownModels : knownModels // ignore: cast_nullable_to_non_nullable
as Map<String, EmbeddingModel>,defaultSettings: null == defaultSettings ? _self._defaultSettings : defaultSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,requiredCredential: freezed == requiredCredential ? _self.requiredCredential : requiredCredential // ignore: cast_nullable_to_non_nullable
as CredentialType?,credentialPlaceholder: freezed == credentialPlaceholder ? _self.credentialPlaceholder : credentialPlaceholder // ignore: cast_nullable_to_non_nullable
as String?,configurationFields: null == configurationFields ? _self._configurationFields : configurationFields // ignore: cast_nullable_to_non_nullable
as List<ConfigurationField>,
  ));
}


}


/// @nodoc
mixin _$ConfigurationField {

 String get key; String get label; ConfigurationFieldType get type; bool get required; String? get description; String? get defaultValue; List<String>? get options;// For dropdown fields
 String? get validation;
/// Create a copy of ConfigurationField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfigurationFieldCopyWith<ConfigurationField> get copyWith => _$ConfigurationFieldCopyWithImpl<ConfigurationField>(this as ConfigurationField, _$identity);

  /// Serializes this ConfigurationField to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfigurationField&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.type, type) || other.type == type)&&(identical(other.required, required) || other.required == required)&&(identical(other.description, description) || other.description == description)&&(identical(other.defaultValue, defaultValue) || other.defaultValue == defaultValue)&&const DeepCollectionEquality().equals(other.options, options)&&(identical(other.validation, validation) || other.validation == validation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,type,required,description,defaultValue,const DeepCollectionEquality().hash(options),validation);

@override
String toString() {
  return 'ConfigurationField(key: $key, label: $label, type: $type, required: $required, description: $description, defaultValue: $defaultValue, options: $options, validation: $validation)';
}


}

/// @nodoc
abstract mixin class $ConfigurationFieldCopyWith<$Res>  {
  factory $ConfigurationFieldCopyWith(ConfigurationField value, $Res Function(ConfigurationField) _then) = _$ConfigurationFieldCopyWithImpl;
@useResult
$Res call({
 String key, String label, ConfigurationFieldType type, bool required, String? description, String? defaultValue, List<String>? options, String? validation
});




}
/// @nodoc
class _$ConfigurationFieldCopyWithImpl<$Res>
    implements $ConfigurationFieldCopyWith<$Res> {
  _$ConfigurationFieldCopyWithImpl(this._self, this._then);

  final ConfigurationField _self;
  final $Res Function(ConfigurationField) _then;

/// Create a copy of ConfigurationField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? type = null,Object? required = null,Object? description = freezed,Object? defaultValue = freezed,Object? options = freezed,Object? validation = freezed,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConfigurationFieldType,required: null == required ? _self.required : required // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,defaultValue: freezed == defaultValue ? _self.defaultValue : defaultValue // ignore: cast_nullable_to_non_nullable
as String?,options: freezed == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<String>?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfigurationField].
extension ConfigurationFieldPatterns on ConfigurationField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfigurationField value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfigurationField() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfigurationField value)  $default,){
final _that = this;
switch (_that) {
case _ConfigurationField():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfigurationField value)?  $default,){
final _that = this;
switch (_that) {
case _ConfigurationField() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  ConfigurationFieldType type,  bool required,  String? description,  String? defaultValue,  List<String>? options,  String? validation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfigurationField() when $default != null:
return $default(_that.key,_that.label,_that.type,_that.required,_that.description,_that.defaultValue,_that.options,_that.validation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  ConfigurationFieldType type,  bool required,  String? description,  String? defaultValue,  List<String>? options,  String? validation)  $default,) {final _that = this;
switch (_that) {
case _ConfigurationField():
return $default(_that.key,_that.label,_that.type,_that.required,_that.description,_that.defaultValue,_that.options,_that.validation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  ConfigurationFieldType type,  bool required,  String? description,  String? defaultValue,  List<String>? options,  String? validation)?  $default,) {final _that = this;
switch (_that) {
case _ConfigurationField() when $default != null:
return $default(_that.key,_that.label,_that.type,_that.required,_that.description,_that.defaultValue,_that.options,_that.validation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfigurationField implements ConfigurationField {
  const _ConfigurationField({required this.key, required this.label, required this.type, this.required = false, this.description, this.defaultValue, final  List<String>? options, this.validation}): _options = options;
  factory _ConfigurationField.fromJson(Map<String, dynamic> json) => _$ConfigurationFieldFromJson(json);

@override final  String key;
@override final  String label;
@override final  ConfigurationFieldType type;
@override@JsonKey() final  bool required;
@override final  String? description;
@override final  String? defaultValue;
 final  List<String>? _options;
@override List<String>? get options {
  final value = _options;
  if (value == null) return null;
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// For dropdown fields
@override final  String? validation;

/// Create a copy of ConfigurationField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfigurationFieldCopyWith<_ConfigurationField> get copyWith => __$ConfigurationFieldCopyWithImpl<_ConfigurationField>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfigurationFieldToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfigurationField&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.type, type) || other.type == type)&&(identical(other.required, required) || other.required == required)&&(identical(other.description, description) || other.description == description)&&(identical(other.defaultValue, defaultValue) || other.defaultValue == defaultValue)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.validation, validation) || other.validation == validation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,type,required,description,defaultValue,const DeepCollectionEquality().hash(_options),validation);

@override
String toString() {
  return 'ConfigurationField(key: $key, label: $label, type: $type, required: $required, description: $description, defaultValue: $defaultValue, options: $options, validation: $validation)';
}


}

/// @nodoc
abstract mixin class _$ConfigurationFieldCopyWith<$Res> implements $ConfigurationFieldCopyWith<$Res> {
  factory _$ConfigurationFieldCopyWith(_ConfigurationField value, $Res Function(_ConfigurationField) _then) = __$ConfigurationFieldCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, ConfigurationFieldType type, bool required, String? description, String? defaultValue, List<String>? options, String? validation
});




}
/// @nodoc
class __$ConfigurationFieldCopyWithImpl<$Res>
    implements _$ConfigurationFieldCopyWith<$Res> {
  __$ConfigurationFieldCopyWithImpl(this._self, this._then);

  final _ConfigurationField _self;
  final $Res Function(_ConfigurationField) _then;

/// Create a copy of ConfigurationField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? type = null,Object? required = null,Object? description = freezed,Object? defaultValue = freezed,Object? options = freezed,Object? validation = freezed,}) {
  return _then(_ConfigurationField(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConfigurationFieldType,required: null == required ? _self.required : required // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,defaultValue: freezed == defaultValue ? _self.defaultValue : defaultValue // ignore: cast_nullable_to_non_nullable
as String?,options: freezed == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<String>?,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EmbeddingModel {

 String get id; String get name; String get description; int get dimensions; int? get maxInputTokens; double? get costPer1kTokens;
/// Create a copy of EmbeddingModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmbeddingModelCopyWith<EmbeddingModel> get copyWith => _$EmbeddingModelCopyWithImpl<EmbeddingModel>(this as EmbeddingModel, _$identity);

  /// Serializes this EmbeddingModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmbeddingModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.dimensions, dimensions) || other.dimensions == dimensions)&&(identical(other.maxInputTokens, maxInputTokens) || other.maxInputTokens == maxInputTokens)&&(identical(other.costPer1kTokens, costPer1kTokens) || other.costPer1kTokens == costPer1kTokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,dimensions,maxInputTokens,costPer1kTokens);

@override
String toString() {
  return 'EmbeddingModel(id: $id, name: $name, description: $description, dimensions: $dimensions, maxInputTokens: $maxInputTokens, costPer1kTokens: $costPer1kTokens)';
}


}

/// @nodoc
abstract mixin class $EmbeddingModelCopyWith<$Res>  {
  factory $EmbeddingModelCopyWith(EmbeddingModel value, $Res Function(EmbeddingModel) _then) = _$EmbeddingModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, int dimensions, int? maxInputTokens, double? costPer1kTokens
});




}
/// @nodoc
class _$EmbeddingModelCopyWithImpl<$Res>
    implements $EmbeddingModelCopyWith<$Res> {
  _$EmbeddingModelCopyWithImpl(this._self, this._then);

  final EmbeddingModel _self;
  final $Res Function(EmbeddingModel) _then;

/// Create a copy of EmbeddingModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? dimensions = null,Object? maxInputTokens = freezed,Object? costPer1kTokens = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dimensions: null == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as int,maxInputTokens: freezed == maxInputTokens ? _self.maxInputTokens : maxInputTokens // ignore: cast_nullable_to_non_nullable
as int?,costPer1kTokens: freezed == costPer1kTokens ? _self.costPer1kTokens : costPer1kTokens // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmbeddingModel].
extension EmbeddingModelPatterns on EmbeddingModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmbeddingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmbeddingModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmbeddingModel value)  $default,){
final _that = this;
switch (_that) {
case _EmbeddingModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmbeddingModel value)?  $default,){
final _that = this;
switch (_that) {
case _EmbeddingModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  int dimensions,  int? maxInputTokens,  double? costPer1kTokens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmbeddingModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.dimensions,_that.maxInputTokens,_that.costPer1kTokens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  int dimensions,  int? maxInputTokens,  double? costPer1kTokens)  $default,) {final _that = this;
switch (_that) {
case _EmbeddingModel():
return $default(_that.id,_that.name,_that.description,_that.dimensions,_that.maxInputTokens,_that.costPer1kTokens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  int dimensions,  int? maxInputTokens,  double? costPer1kTokens)?  $default,) {final _that = this;
switch (_that) {
case _EmbeddingModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.dimensions,_that.maxInputTokens,_that.costPer1kTokens);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmbeddingModel implements EmbeddingModel {
  const _EmbeddingModel({required this.id, required this.name, required this.description, required this.dimensions, this.maxInputTokens, this.costPer1kTokens});
  factory _EmbeddingModel.fromJson(Map<String, dynamic> json) => _$EmbeddingModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  int dimensions;
@override final  int? maxInputTokens;
@override final  double? costPer1kTokens;

/// Create a copy of EmbeddingModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmbeddingModelCopyWith<_EmbeddingModel> get copyWith => __$EmbeddingModelCopyWithImpl<_EmbeddingModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmbeddingModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmbeddingModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.dimensions, dimensions) || other.dimensions == dimensions)&&(identical(other.maxInputTokens, maxInputTokens) || other.maxInputTokens == maxInputTokens)&&(identical(other.costPer1kTokens, costPer1kTokens) || other.costPer1kTokens == costPer1kTokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,dimensions,maxInputTokens,costPer1kTokens);

@override
String toString() {
  return 'EmbeddingModel(id: $id, name: $name, description: $description, dimensions: $dimensions, maxInputTokens: $maxInputTokens, costPer1kTokens: $costPer1kTokens)';
}


}

/// @nodoc
abstract mixin class _$EmbeddingModelCopyWith<$Res> implements $EmbeddingModelCopyWith<$Res> {
  factory _$EmbeddingModelCopyWith(_EmbeddingModel value, $Res Function(_EmbeddingModel) _then) = __$EmbeddingModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, int dimensions, int? maxInputTokens, double? costPer1kTokens
});




}
/// @nodoc
class __$EmbeddingModelCopyWithImpl<$Res>
    implements _$EmbeddingModelCopyWith<$Res> {
  __$EmbeddingModelCopyWithImpl(this._self, this._then);

  final _EmbeddingModel _self;
  final $Res Function(_EmbeddingModel) _then;

/// Create a copy of EmbeddingModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? dimensions = null,Object? maxInputTokens = freezed,Object? costPer1kTokens = freezed,}) {
  return _then(_EmbeddingModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dimensions: null == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as int,maxInputTokens: freezed == maxInputTokens ? _self.maxInputTokens : maxInputTokens // ignore: cast_nullable_to_non_nullable
as int?,costPer1kTokens: freezed == costPer1kTokens ? _self.costPer1kTokens : costPer1kTokens // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$ValidationResult {

 bool get isValid; List<String> get errors; List<String> get warnings;
/// Create a copy of ValidationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationResultCopyWith<ValidationResult> get copyWith => _$ValidationResultCopyWithImpl<ValidationResult>(this as ValidationResult, _$identity);

  /// Serializes this ValidationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationResult&&(identical(other.isValid, isValid) || other.isValid == isValid)&&const DeepCollectionEquality().equals(other.errors, errors)&&const DeepCollectionEquality().equals(other.warnings, warnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isValid,const DeepCollectionEquality().hash(errors),const DeepCollectionEquality().hash(warnings));

@override
String toString() {
  return 'ValidationResult(isValid: $isValid, errors: $errors, warnings: $warnings)';
}


}

/// @nodoc
abstract mixin class $ValidationResultCopyWith<$Res>  {
  factory $ValidationResultCopyWith(ValidationResult value, $Res Function(ValidationResult) _then) = _$ValidationResultCopyWithImpl;
@useResult
$Res call({
 bool isValid, List<String> errors, List<String> warnings
});




}
/// @nodoc
class _$ValidationResultCopyWithImpl<$Res>
    implements $ValidationResultCopyWith<$Res> {
  _$ValidationResultCopyWithImpl(this._self, this._then);

  final ValidationResult _self;
  final $Res Function(ValidationResult) _then;

/// Create a copy of ValidationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isValid = null,Object? errors = null,Object? warnings = null,}) {
  return _then(_self.copyWith(
isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>,warnings: null == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ValidationResult].
extension ValidationResultPatterns on ValidationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ValidationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ValidationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ValidationResult value)  $default,){
final _that = this;
switch (_that) {
case _ValidationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ValidationResult value)?  $default,){
final _that = this;
switch (_that) {
case _ValidationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isValid,  List<String> errors,  List<String> warnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ValidationResult() when $default != null:
return $default(_that.isValid,_that.errors,_that.warnings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isValid,  List<String> errors,  List<String> warnings)  $default,) {final _that = this;
switch (_that) {
case _ValidationResult():
return $default(_that.isValid,_that.errors,_that.warnings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isValid,  List<String> errors,  List<String> warnings)?  $default,) {final _that = this;
switch (_that) {
case _ValidationResult() when $default != null:
return $default(_that.isValid,_that.errors,_that.warnings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ValidationResult implements ValidationResult {
  const _ValidationResult({required this.isValid, final  List<String> errors = const [], final  List<String> warnings = const []}): _errors = errors,_warnings = warnings;
  factory _ValidationResult.fromJson(Map<String, dynamic> json) => _$ValidationResultFromJson(json);

@override final  bool isValid;
 final  List<String> _errors;
@override@JsonKey() List<String> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}

 final  List<String> _warnings;
@override@JsonKey() List<String> get warnings {
  if (_warnings is EqualUnmodifiableListView) return _warnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warnings);
}


/// Create a copy of ValidationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidationResultCopyWith<_ValidationResult> get copyWith => __$ValidationResultCopyWithImpl<_ValidationResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ValidationResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ValidationResult&&(identical(other.isValid, isValid) || other.isValid == isValid)&&const DeepCollectionEquality().equals(other._errors, _errors)&&const DeepCollectionEquality().equals(other._warnings, _warnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isValid,const DeepCollectionEquality().hash(_errors),const DeepCollectionEquality().hash(_warnings));

@override
String toString() {
  return 'ValidationResult(isValid: $isValid, errors: $errors, warnings: $warnings)';
}


}

/// @nodoc
abstract mixin class _$ValidationResultCopyWith<$Res> implements $ValidationResultCopyWith<$Res> {
  factory _$ValidationResultCopyWith(_ValidationResult value, $Res Function(_ValidationResult) _then) = __$ValidationResultCopyWithImpl;
@override @useResult
$Res call({
 bool isValid, List<String> errors, List<String> warnings
});




}
/// @nodoc
class __$ValidationResultCopyWithImpl<$Res>
    implements _$ValidationResultCopyWith<$Res> {
  __$ValidationResultCopyWithImpl(this._self, this._then);

  final _ValidationResult _self;
  final $Res Function(_ValidationResult) _then;

/// Create a copy of ValidationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isValid = null,Object? errors = null,Object? warnings = null,}) {
  return _then(_ValidationResult(
isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>,warnings: null == warnings ? _self._warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on

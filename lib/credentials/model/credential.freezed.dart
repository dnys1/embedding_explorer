// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
Credential _$CredentialFromJson(
  Map<String, dynamic> json
) {
    return ApiKeyCredential.fromJson(
      json
    );
}

/// @nodoc
mixin _$Credential {

 String get apiKey;
/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialCopyWith<Credential> get copyWith => _$CredentialCopyWithImpl<Credential>(this as Credential, _$identity);

  /// Serializes this Credential to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Credential&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,apiKey);

@override
String toString() {
  return 'Credential(apiKey: $apiKey)';
}


}

/// @nodoc
abstract mixin class $CredentialCopyWith<$Res>  {
  factory $CredentialCopyWith(Credential value, $Res Function(Credential) _then) = _$CredentialCopyWithImpl;
@useResult
$Res call({
 String apiKey
});




}
/// @nodoc
class _$CredentialCopyWithImpl<$Res>
    implements $CredentialCopyWith<$Res> {
  _$CredentialCopyWithImpl(this._self, this._then);

  final Credential _self;
  final $Res Function(Credential) _then;

/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? apiKey = null,}) {
  return _then(_self.copyWith(
apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Credential].
extension CredentialPatterns on Credential {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ApiKeyCredential value)?  apiKey,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ApiKeyCredential() when apiKey != null:
return apiKey(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ApiKeyCredential value)  apiKey,}){
final _that = this;
switch (_that) {
case ApiKeyCredential():
return apiKey(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ApiKeyCredential value)?  apiKey,}){
final _that = this;
switch (_that) {
case ApiKeyCredential() when apiKey != null:
return apiKey(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String apiKey)?  apiKey,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ApiKeyCredential() when apiKey != null:
return apiKey(_that.apiKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String apiKey)  apiKey,}) {final _that = this;
switch (_that) {
case ApiKeyCredential():
return apiKey(_that.apiKey);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String apiKey)?  apiKey,}) {final _that = this;
switch (_that) {
case ApiKeyCredential() when apiKey != null:
return apiKey(_that.apiKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class ApiKeyCredential extends Credential {
  const ApiKeyCredential(this.apiKey): super._();
  factory ApiKeyCredential.fromJson(Map<String, dynamic> json) => _$ApiKeyCredentialFromJson(json);

@override final  String apiKey;

/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiKeyCredentialCopyWith<ApiKeyCredential> get copyWith => _$ApiKeyCredentialCopyWithImpl<ApiKeyCredential>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiKeyCredentialToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiKeyCredential&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,apiKey);

@override
String toString() {
  return 'Credential.apiKey(apiKey: $apiKey)';
}


}

/// @nodoc
abstract mixin class $ApiKeyCredentialCopyWith<$Res> implements $CredentialCopyWith<$Res> {
  factory $ApiKeyCredentialCopyWith(ApiKeyCredential value, $Res Function(ApiKeyCredential) _then) = _$ApiKeyCredentialCopyWithImpl;
@override @useResult
$Res call({
 String apiKey
});




}
/// @nodoc
class _$ApiKeyCredentialCopyWithImpl<$Res>
    implements $ApiKeyCredentialCopyWith<$Res> {
  _$ApiKeyCredentialCopyWithImpl(this._self, this._then);

  final ApiKeyCredential _self;
  final $Res Function(ApiKeyCredential) _then;

/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? apiKey = null,}) {
  return _then(ApiKeyCredential(
null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

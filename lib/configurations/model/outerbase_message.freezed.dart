// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outerbase_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageWrapper {

 String get type; int get id; Object? get data; String? get error;
/// Create a copy of MessageWrapper
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageWrapperCopyWith<MessageWrapper> get copyWith => _$MessageWrapperCopyWithImpl<MessageWrapper>(this as MessageWrapper, _$identity);

  /// Serializes this MessageWrapper to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageWrapper&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,id,const DeepCollectionEquality().hash(data),error);

@override
String toString() {
  return 'MessageWrapper(type: $type, id: $id, data: $data, error: $error)';
}


}

/// @nodoc
abstract mixin class $MessageWrapperCopyWith<$Res>  {
  factory $MessageWrapperCopyWith(MessageWrapper value, $Res Function(MessageWrapper) _then) = _$MessageWrapperCopyWithImpl;
@useResult
$Res call({
 String type, int id, Object? data, String? error
});




}
/// @nodoc
class _$MessageWrapperCopyWithImpl<$Res>
    implements $MessageWrapperCopyWith<$Res> {
  _$MessageWrapperCopyWithImpl(this._self, this._then);

  final MessageWrapper _self;
  final $Res Function(MessageWrapper) _then;

/// Create a copy of MessageWrapper
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? id = null,Object? data = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,data: freezed == data ? _self.data : data ,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageWrapper].
extension MessageWrapperPatterns on MessageWrapper {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageWrapper value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageWrapper() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageWrapper value)  $default,){
final _that = this;
switch (_that) {
case _MessageWrapper():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageWrapper value)?  $default,){
final _that = this;
switch (_that) {
case _MessageWrapper() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  int id,  Object? data,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageWrapper() when $default != null:
return $default(_that.type,_that.id,_that.data,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  int id,  Object? data,  String? error)  $default,) {final _that = this;
switch (_that) {
case _MessageWrapper():
return $default(_that.type,_that.id,_that.data,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  int id,  Object? data,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _MessageWrapper() when $default != null:
return $default(_that.type,_that.id,_that.data,_that.error);case _:
  return null;

}
}

}

/// @nodoc

@_serializable
class _MessageWrapper implements MessageWrapper {
  const _MessageWrapper({required this.type, required this.id, this.data, this.error});
  factory _MessageWrapper.fromJson(Map<String, dynamic> json) => _$MessageWrapperFromJson(json);

@override final  String type;
@override final  int id;
@override final  Object? data;
@override final  String? error;

/// Create a copy of MessageWrapper
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageWrapperCopyWith<_MessageWrapper> get copyWith => __$MessageWrapperCopyWithImpl<_MessageWrapper>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageWrapperToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageWrapper&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,id,const DeepCollectionEquality().hash(data),error);

@override
String toString() {
  return 'MessageWrapper(type: $type, id: $id, data: $data, error: $error)';
}


}

/// @nodoc
abstract mixin class _$MessageWrapperCopyWith<$Res> implements $MessageWrapperCopyWith<$Res> {
  factory _$MessageWrapperCopyWith(_MessageWrapper value, $Res Function(_MessageWrapper) _then) = __$MessageWrapperCopyWithImpl;
@override @useResult
$Res call({
 String type, int id, Object? data, String? error
});




}
/// @nodoc
class __$MessageWrapperCopyWithImpl<$Res>
    implements _$MessageWrapperCopyWith<$Res> {
  __$MessageWrapperCopyWithImpl(this._self, this._then);

  final _MessageWrapper _self;
  final $Res Function(_MessageWrapper) _then;

/// Create a copy of MessageWrapper
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? id = null,Object? data = freezed,Object? error = freezed,}) {
  return _then(_MessageWrapper(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,data: freezed == data ? _self.data : data ,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ResultSet {

 List<Map<String, Object?>> get rows; List<DriverResultHeader> get headers; DriverStats get stat; int? get lastInsertRowid;
/// Create a copy of ResultSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultSetCopyWith<ResultSet> get copyWith => _$ResultSetCopyWithImpl<ResultSet>(this as ResultSet, _$identity);

  /// Serializes this ResultSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultSet&&const DeepCollectionEquality().equals(other.rows, rows)&&const DeepCollectionEquality().equals(other.headers, headers)&&(identical(other.stat, stat) || other.stat == stat)&&(identical(other.lastInsertRowid, lastInsertRowid) || other.lastInsertRowid == lastInsertRowid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rows),const DeepCollectionEquality().hash(headers),stat,lastInsertRowid);

@override
String toString() {
  return 'ResultSet(rows: $rows, headers: $headers, stat: $stat, lastInsertRowid: $lastInsertRowid)';
}


}

/// @nodoc
abstract mixin class $ResultSetCopyWith<$Res>  {
  factory $ResultSetCopyWith(ResultSet value, $Res Function(ResultSet) _then) = _$ResultSetCopyWithImpl;
@useResult
$Res call({
 List<Map<String, Object?>> rows, List<DriverResultHeader> headers, DriverStats stat, int? lastInsertRowid
});


$DriverStatsCopyWith<$Res> get stat;

}
/// @nodoc
class _$ResultSetCopyWithImpl<$Res>
    implements $ResultSetCopyWith<$Res> {
  _$ResultSetCopyWithImpl(this._self, this._then);

  final ResultSet _self;
  final $Res Function(ResultSet) _then;

/// Create a copy of ResultSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rows = null,Object? headers = null,Object? stat = null,Object? lastInsertRowid = freezed,}) {
  return _then(_self.copyWith(
rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<Map<String, Object?>>,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as List<DriverResultHeader>,stat: null == stat ? _self.stat : stat // ignore: cast_nullable_to_non_nullable
as DriverStats,lastInsertRowid: freezed == lastInsertRowid ? _self.lastInsertRowid : lastInsertRowid // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of ResultSet
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverStatsCopyWith<$Res> get stat {
  
  return $DriverStatsCopyWith<$Res>(_self.stat, (value) {
    return _then(_self.copyWith(stat: value));
  });
}
}


/// Adds pattern-matching-related methods to [ResultSet].
extension ResultSetPatterns on ResultSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResultSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResultSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResultSet value)  $default,){
final _that = this;
switch (_that) {
case _ResultSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResultSet value)?  $default,){
final _that = this;
switch (_that) {
case _ResultSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Map<String, Object?>> rows,  List<DriverResultHeader> headers,  DriverStats stat,  int? lastInsertRowid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResultSet() when $default != null:
return $default(_that.rows,_that.headers,_that.stat,_that.lastInsertRowid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Map<String, Object?>> rows,  List<DriverResultHeader> headers,  DriverStats stat,  int? lastInsertRowid)  $default,) {final _that = this;
switch (_that) {
case _ResultSet():
return $default(_that.rows,_that.headers,_that.stat,_that.lastInsertRowid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Map<String, Object?>> rows,  List<DriverResultHeader> headers,  DriverStats stat,  int? lastInsertRowid)?  $default,) {final _that = this;
switch (_that) {
case _ResultSet() when $default != null:
return $default(_that.rows,_that.headers,_that.stat,_that.lastInsertRowid);case _:
  return null;

}
}

}

/// @nodoc

@_serializable
class _ResultSet implements ResultSet {
  const _ResultSet({required final  List<Map<String, Object?>> rows, required final  List<DriverResultHeader> headers, required this.stat, required this.lastInsertRowid}): _rows = rows,_headers = headers;
  factory _ResultSet.fromJson(Map<String, dynamic> json) => _$ResultSetFromJson(json);

 final  List<Map<String, Object?>> _rows;
@override List<Map<String, Object?>> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}

 final  List<DriverResultHeader> _headers;
@override List<DriverResultHeader> get headers {
  if (_headers is EqualUnmodifiableListView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_headers);
}

@override final  DriverStats stat;
@override final  int? lastInsertRowid;

/// Create a copy of ResultSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultSetCopyWith<_ResultSet> get copyWith => __$ResultSetCopyWithImpl<_ResultSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResultSetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResultSet&&const DeepCollectionEquality().equals(other._rows, _rows)&&const DeepCollectionEquality().equals(other._headers, _headers)&&(identical(other.stat, stat) || other.stat == stat)&&(identical(other.lastInsertRowid, lastInsertRowid) || other.lastInsertRowid == lastInsertRowid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rows),const DeepCollectionEquality().hash(_headers),stat,lastInsertRowid);

@override
String toString() {
  return 'ResultSet(rows: $rows, headers: $headers, stat: $stat, lastInsertRowid: $lastInsertRowid)';
}


}

/// @nodoc
abstract mixin class _$ResultSetCopyWith<$Res> implements $ResultSetCopyWith<$Res> {
  factory _$ResultSetCopyWith(_ResultSet value, $Res Function(_ResultSet) _then) = __$ResultSetCopyWithImpl;
@override @useResult
$Res call({
 List<Map<String, Object?>> rows, List<DriverResultHeader> headers, DriverStats stat, int? lastInsertRowid
});


@override $DriverStatsCopyWith<$Res> get stat;

}
/// @nodoc
class __$ResultSetCopyWithImpl<$Res>
    implements _$ResultSetCopyWith<$Res> {
  __$ResultSetCopyWithImpl(this._self, this._then);

  final _ResultSet _self;
  final $Res Function(_ResultSet) _then;

/// Create a copy of ResultSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rows = null,Object? headers = null,Object? stat = null,Object? lastInsertRowid = freezed,}) {
  return _then(_ResultSet(
rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<Map<String, Object?>>,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as List<DriverResultHeader>,stat: null == stat ? _self.stat : stat // ignore: cast_nullable_to_non_nullable
as DriverStats,lastInsertRowid: freezed == lastInsertRowid ? _self.lastInsertRowid : lastInsertRowid // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of ResultSet
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverStatsCopyWith<$Res> get stat {
  
  return $DriverStatsCopyWith<$Res>(_self.stat, (value) {
    return _then(_self.copyWith(stat: value));
  });
}
}


/// @nodoc
mixin _$DriverResultHeader {

 String get name; String get displayName; String? get originalType; ColumnType? get type;
/// Create a copy of DriverResultHeader
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverResultHeaderCopyWith<DriverResultHeader> get copyWith => _$DriverResultHeaderCopyWithImpl<DriverResultHeader>(this as DriverResultHeader, _$identity);

  /// Serializes this DriverResultHeader to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverResultHeader&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.originalType, originalType) || other.originalType == originalType)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,displayName,originalType,type);

@override
String toString() {
  return 'DriverResultHeader(name: $name, displayName: $displayName, originalType: $originalType, type: $type)';
}


}

/// @nodoc
abstract mixin class $DriverResultHeaderCopyWith<$Res>  {
  factory $DriverResultHeaderCopyWith(DriverResultHeader value, $Res Function(DriverResultHeader) _then) = _$DriverResultHeaderCopyWithImpl;
@useResult
$Res call({
 String name, String displayName, String? originalType, ColumnType? type
});




}
/// @nodoc
class _$DriverResultHeaderCopyWithImpl<$Res>
    implements $DriverResultHeaderCopyWith<$Res> {
  _$DriverResultHeaderCopyWithImpl(this._self, this._then);

  final DriverResultHeader _self;
  final $Res Function(DriverResultHeader) _then;

/// Create a copy of DriverResultHeader
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? displayName = null,Object? originalType = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,originalType: freezed == originalType ? _self.originalType : originalType // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ColumnType?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverResultHeader].
extension DriverResultHeaderPatterns on DriverResultHeader {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverResultHeader value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverResultHeader() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverResultHeader value)  $default,){
final _that = this;
switch (_that) {
case _DriverResultHeader():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverResultHeader value)?  $default,){
final _that = this;
switch (_that) {
case _DriverResultHeader() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String displayName,  String? originalType,  ColumnType? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverResultHeader() when $default != null:
return $default(_that.name,_that.displayName,_that.originalType,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String displayName,  String? originalType,  ColumnType? type)  $default,) {final _that = this;
switch (_that) {
case _DriverResultHeader():
return $default(_that.name,_that.displayName,_that.originalType,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String displayName,  String? originalType,  ColumnType? type)?  $default,) {final _that = this;
switch (_that) {
case _DriverResultHeader() when $default != null:
return $default(_that.name,_that.displayName,_that.originalType,_that.type);case _:
  return null;

}
}

}

/// @nodoc

@_serializable
class _DriverResultHeader implements DriverResultHeader {
  const _DriverResultHeader({required this.name, required this.displayName, required this.originalType, required this.type});
  factory _DriverResultHeader.fromJson(Map<String, dynamic> json) => _$DriverResultHeaderFromJson(json);

@override final  String name;
@override final  String displayName;
@override final  String? originalType;
@override final  ColumnType? type;

/// Create a copy of DriverResultHeader
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverResultHeaderCopyWith<_DriverResultHeader> get copyWith => __$DriverResultHeaderCopyWithImpl<_DriverResultHeader>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverResultHeaderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverResultHeader&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.originalType, originalType) || other.originalType == originalType)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,displayName,originalType,type);

@override
String toString() {
  return 'DriverResultHeader(name: $name, displayName: $displayName, originalType: $originalType, type: $type)';
}


}

/// @nodoc
abstract mixin class _$DriverResultHeaderCopyWith<$Res> implements $DriverResultHeaderCopyWith<$Res> {
  factory _$DriverResultHeaderCopyWith(_DriverResultHeader value, $Res Function(_DriverResultHeader) _then) = __$DriverResultHeaderCopyWithImpl;
@override @useResult
$Res call({
 String name, String displayName, String? originalType, ColumnType? type
});




}
/// @nodoc
class __$DriverResultHeaderCopyWithImpl<$Res>
    implements _$DriverResultHeaderCopyWith<$Res> {
  __$DriverResultHeaderCopyWithImpl(this._self, this._then);

  final _DriverResultHeader _self;
  final $Res Function(_DriverResultHeader) _then;

/// Create a copy of DriverResultHeader
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? displayName = null,Object? originalType = freezed,Object? type = freezed,}) {
  return _then(_DriverResultHeader(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,originalType: freezed == originalType ? _self.originalType : originalType // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ColumnType?,
  ));
}


}


/// @nodoc
mixin _$DriverStats {

 int get rowsAffected; int? get rowsRead; int? get rowsWritten; num? get queryDurationMs;
/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverStatsCopyWith<DriverStats> get copyWith => _$DriverStatsCopyWithImpl<DriverStats>(this as DriverStats, _$identity);

  /// Serializes this DriverStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverStats&&(identical(other.rowsAffected, rowsAffected) || other.rowsAffected == rowsAffected)&&(identical(other.rowsRead, rowsRead) || other.rowsRead == rowsRead)&&(identical(other.rowsWritten, rowsWritten) || other.rowsWritten == rowsWritten)&&(identical(other.queryDurationMs, queryDurationMs) || other.queryDurationMs == queryDurationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rowsAffected,rowsRead,rowsWritten,queryDurationMs);

@override
String toString() {
  return 'DriverStats(rowsAffected: $rowsAffected, rowsRead: $rowsRead, rowsWritten: $rowsWritten, queryDurationMs: $queryDurationMs)';
}


}

/// @nodoc
abstract mixin class $DriverStatsCopyWith<$Res>  {
  factory $DriverStatsCopyWith(DriverStats value, $Res Function(DriverStats) _then) = _$DriverStatsCopyWithImpl;
@useResult
$Res call({
 int rowsAffected, int? rowsRead, int? rowsWritten, num? queryDurationMs
});




}
/// @nodoc
class _$DriverStatsCopyWithImpl<$Res>
    implements $DriverStatsCopyWith<$Res> {
  _$DriverStatsCopyWithImpl(this._self, this._then);

  final DriverStats _self;
  final $Res Function(DriverStats) _then;

/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rowsAffected = null,Object? rowsRead = freezed,Object? rowsWritten = freezed,Object? queryDurationMs = freezed,}) {
  return _then(_self.copyWith(
rowsAffected: null == rowsAffected ? _self.rowsAffected : rowsAffected // ignore: cast_nullable_to_non_nullable
as int,rowsRead: freezed == rowsRead ? _self.rowsRead : rowsRead // ignore: cast_nullable_to_non_nullable
as int?,rowsWritten: freezed == rowsWritten ? _self.rowsWritten : rowsWritten // ignore: cast_nullable_to_non_nullable
as int?,queryDurationMs: freezed == queryDurationMs ? _self.queryDurationMs : queryDurationMs // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverStats].
extension DriverStatsPatterns on DriverStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverStats value)  $default,){
final _that = this;
switch (_that) {
case _DriverStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverStats value)?  $default,){
final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rowsAffected,  int? rowsRead,  int? rowsWritten,  num? queryDurationMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
return $default(_that.rowsAffected,_that.rowsRead,_that.rowsWritten,_that.queryDurationMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rowsAffected,  int? rowsRead,  int? rowsWritten,  num? queryDurationMs)  $default,) {final _that = this;
switch (_that) {
case _DriverStats():
return $default(_that.rowsAffected,_that.rowsRead,_that.rowsWritten,_that.queryDurationMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rowsAffected,  int? rowsRead,  int? rowsWritten,  num? queryDurationMs)?  $default,) {final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
return $default(_that.rowsAffected,_that.rowsRead,_that.rowsWritten,_that.queryDurationMs);case _:
  return null;

}
}

}

/// @nodoc

@_serializable
class _DriverStats implements DriverStats {
  const _DriverStats({required this.rowsAffected, required this.rowsRead, required this.rowsWritten, required this.queryDurationMs});
  factory _DriverStats.fromJson(Map<String, dynamic> json) => _$DriverStatsFromJson(json);

@override final  int rowsAffected;
@override final  int? rowsRead;
@override final  int? rowsWritten;
@override final  num? queryDurationMs;

/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverStatsCopyWith<_DriverStats> get copyWith => __$DriverStatsCopyWithImpl<_DriverStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverStats&&(identical(other.rowsAffected, rowsAffected) || other.rowsAffected == rowsAffected)&&(identical(other.rowsRead, rowsRead) || other.rowsRead == rowsRead)&&(identical(other.rowsWritten, rowsWritten) || other.rowsWritten == rowsWritten)&&(identical(other.queryDurationMs, queryDurationMs) || other.queryDurationMs == queryDurationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rowsAffected,rowsRead,rowsWritten,queryDurationMs);

@override
String toString() {
  return 'DriverStats(rowsAffected: $rowsAffected, rowsRead: $rowsRead, rowsWritten: $rowsWritten, queryDurationMs: $queryDurationMs)';
}


}

/// @nodoc
abstract mixin class _$DriverStatsCopyWith<$Res> implements $DriverStatsCopyWith<$Res> {
  factory _$DriverStatsCopyWith(_DriverStats value, $Res Function(_DriverStats) _then) = __$DriverStatsCopyWithImpl;
@override @useResult
$Res call({
 int rowsAffected, int? rowsRead, int? rowsWritten, num? queryDurationMs
});




}
/// @nodoc
class __$DriverStatsCopyWithImpl<$Res>
    implements _$DriverStatsCopyWith<$Res> {
  __$DriverStatsCopyWithImpl(this._self, this._then);

  final _DriverStats _self;
  final $Res Function(_DriverStats) _then;

/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rowsAffected = null,Object? rowsRead = freezed,Object? rowsWritten = freezed,Object? queryDurationMs = freezed,}) {
  return _then(_DriverStats(
rowsAffected: null == rowsAffected ? _self.rowsAffected : rowsAffected // ignore: cast_nullable_to_non_nullable
as int,rowsRead: freezed == rowsRead ? _self.rowsRead : rowsRead // ignore: cast_nullable_to_non_nullable
as int?,rowsWritten: freezed == rowsWritten ? _self.rowsWritten : rowsWritten // ignore: cast_nullable_to_non_nullable
as int?,queryDurationMs: freezed == queryDurationMs ? _self.queryDurationMs : queryDurationMs // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opfs_worker.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpfsWorkerRequestType _$readAsBytes = const OpfsWorkerRequestType._(
  'readAsBytes',
);
const OpfsWorkerRequestType _$readAsString = const OpfsWorkerRequestType._(
  'readAsString',
);
const OpfsWorkerRequestType _$writeAsBytes = const OpfsWorkerRequestType._(
  'writeAsBytes',
);
const OpfsWorkerRequestType _$writeAsString = const OpfsWorkerRequestType._(
  'writeAsString',
);
const OpfsWorkerRequestType _$delete = const OpfsWorkerRequestType._('delete');
const OpfsWorkerRequestType _$clear = const OpfsWorkerRequestType._('clear');

OpfsWorkerRequestType _$valueOf(String name) {
  switch (name) {
    case 'readAsBytes':
      return _$readAsBytes;
    case 'readAsString':
      return _$readAsString;
    case 'writeAsBytes':
      return _$writeAsBytes;
    case 'writeAsString':
      return _$writeAsString;
    case 'delete':
      return _$delete;
    case 'clear':
      return _$clear;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpfsWorkerRequestType> _$values =
    BuiltSet<OpfsWorkerRequestType>(const <OpfsWorkerRequestType>[
      _$readAsBytes,
      _$readAsString,
      _$writeAsBytes,
      _$writeAsString,
      _$delete,
      _$clear,
    ]);

Serializers _$_serializers =
    (Serializers().toBuilder()
          ..add(OpfsWorkerError.serializer)
          ..add(OpfsWorkerRequest.serializer)
          ..add(OpfsWorkerRequestType.serializer)
          ..add(OpfsWorkerResponse.serializer))
        .build();
Serializer<OpfsWorkerRequestType> _$opfsWorkerRequestTypeSerializer =
    _$OpfsWorkerRequestTypeSerializer();
Serializer<OpfsWorkerRequest> _$opfsWorkerRequestSerializer =
    _$OpfsWorkerRequestSerializer();
Serializer<OpfsWorkerResponse> _$opfsWorkerResponseSerializer =
    _$OpfsWorkerResponseSerializer();
Serializer<OpfsWorkerError> _$opfsWorkerErrorSerializer =
    _$OpfsWorkerErrorSerializer();

class _$OpfsWorkerRequestTypeSerializer
    implements PrimitiveSerializer<OpfsWorkerRequestType> {
  @override
  final Iterable<Type> types = const <Type>[OpfsWorkerRequestType];
  @override
  final String wireName = 'OpfsWorkerRequestType';

  @override
  Object serialize(
    Serializers serializers,
    OpfsWorkerRequestType object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  OpfsWorkerRequestType deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => OpfsWorkerRequestType.valueOf(serialized as String);
}

class _$OpfsWorkerRequestSerializer
    implements StructuredSerializer<OpfsWorkerRequest> {
  @override
  final Iterable<Type> types = const [OpfsWorkerRequest, _$OpfsWorkerRequest];
  @override
  final String wireName = 'OpfsWorkerRequest';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    OpfsWorkerRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'requestId',
      serializers.serialize(
        object.requestId,
        specifiedType: const FullType(int),
      ),
      'type',
      serializers.serialize(
        object.type,
        specifiedType: const FullType(OpfsWorkerRequestType),
      ),
    ];
    Object? value;
    value = object.path;
    if (value != null) {
      result
        ..add('path')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.data;
    if (value != null) {
      result
        ..add('data')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(Uint8List),
          ),
        );
    }
    value = object.stringData;
    if (value != null) {
      result
        ..add('stringData')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    return result;
  }

  @override
  OpfsWorkerRequest deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpfsWorkerRequestBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'requestId':
          result.requestId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'type':
          result.type =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(OpfsWorkerRequestType),
                  )!
                  as OpfsWorkerRequestType;
          break;
        case 'path':
          result.path =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'data':
          result.data =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Uint8List),
                  )
                  as Uint8List?;
          break;
        case 'stringData':
          result.stringData =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$OpfsWorkerResponseSerializer
    implements StructuredSerializer<OpfsWorkerResponse> {
  @override
  final Iterable<Type> types = const [OpfsWorkerResponse, _$OpfsWorkerResponse];
  @override
  final String wireName = 'OpfsWorkerResponse';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    OpfsWorkerResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'requestId',
      serializers.serialize(
        object.requestId,
        specifiedType: const FullType(int),
      ),
    ];
    Object? value;
    value = object.data;
    if (value != null) {
      result
        ..add('data')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(Uint8List),
          ),
        );
    }
    value = object.stringData;
    if (value != null) {
      result
        ..add('stringData')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.success;
    if (value != null) {
      result
        ..add('success')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(bool)),
        );
    }
    value = object.error;
    if (value != null) {
      result
        ..add('error')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(OpfsWorkerError),
          ),
        );
    }
    return result;
  }

  @override
  OpfsWorkerResponse deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpfsWorkerResponseBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'requestId':
          result.requestId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'data':
          result.data =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Uint8List),
                  )
                  as Uint8List?;
          break;
        case 'stringData':
          result.stringData =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'success':
          result.success =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool?;
          break;
        case 'error':
          result.error.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(OpfsWorkerError),
                )!
                as OpfsWorkerError,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$OpfsWorkerErrorSerializer
    implements StructuredSerializer<OpfsWorkerError> {
  @override
  final Iterable<Type> types = const [OpfsWorkerError, _$OpfsWorkerError];
  @override
  final String wireName = 'OpfsWorkerError';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    OpfsWorkerError object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'error',
      serializers.serialize(
        object.error,
        specifiedType: const FullType(String),
      ),
      'stackTrace',
      serializers.serialize(
        object.stackTrace,
        specifiedType: const FullType(StackTrace),
      ),
    ];

    return result;
  }

  @override
  OpfsWorkerError deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpfsWorkerErrorBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'error':
          result.error =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'stackTrace':
          result.stackTrace =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(StackTrace),
                  )!
                  as StackTrace;
          break;
      }
    }

    return result.build();
  }
}

class _$OpfsWorkerRequest extends OpfsWorkerRequest {
  @override
  final int requestId;
  @override
  final OpfsWorkerRequestType type;
  @override
  final String? path;
  @override
  final Uint8List? data;
  @override
  final String? stringData;

  factory _$OpfsWorkerRequest([
    void Function(OpfsWorkerRequestBuilder)? updates,
  ]) => (OpfsWorkerRequestBuilder()..update(updates))._build();

  _$OpfsWorkerRequest._({
    required this.requestId,
    required this.type,
    this.path,
    this.data,
    this.stringData,
  }) : super._();
  @override
  OpfsWorkerRequest rebuild(void Function(OpfsWorkerRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpfsWorkerRequestBuilder toBuilder() =>
      OpfsWorkerRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpfsWorkerRequest &&
        requestId == other.requestId &&
        type == other.type &&
        path == other.path &&
        data == other.data &&
        stringData == other.stringData;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, path.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, stringData.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }
}

class OpfsWorkerRequestBuilder
    implements Builder<OpfsWorkerRequest, OpfsWorkerRequestBuilder> {
  _$OpfsWorkerRequest? _$v;

  int? _requestId;
  int? get requestId => _$this._requestId;
  set requestId(int? requestId) => _$this._requestId = requestId;

  OpfsWorkerRequestType? _type;
  OpfsWorkerRequestType? get type => _$this._type;
  set type(OpfsWorkerRequestType? type) => _$this._type = type;

  String? _path;
  String? get path => _$this._path;
  set path(String? path) => _$this._path = path;

  Uint8List? _data;
  Uint8List? get data => _$this._data;
  set data(Uint8List? data) => _$this._data = data;

  String? _stringData;
  String? get stringData => _$this._stringData;
  set stringData(String? stringData) => _$this._stringData = stringData;

  OpfsWorkerRequestBuilder();

  OpfsWorkerRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _type = $v.type;
      _path = $v.path;
      _data = $v.data;
      _stringData = $v.stringData;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpfsWorkerRequest other) {
    _$v = other as _$OpfsWorkerRequest;
  }

  @override
  void update(void Function(OpfsWorkerRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpfsWorkerRequest build() => _build();

  _$OpfsWorkerRequest _build() {
    final _$result =
        _$v ??
        _$OpfsWorkerRequest._(
          requestId: BuiltValueNullFieldError.checkNotNull(
            requestId,
            r'OpfsWorkerRequest',
            'requestId',
          ),
          type: BuiltValueNullFieldError.checkNotNull(
            type,
            r'OpfsWorkerRequest',
            'type',
          ),
          path: path,
          data: data,
          stringData: stringData,
        );
    replace(_$result);
    return _$result;
  }
}

class _$OpfsWorkerResponse extends OpfsWorkerResponse {
  @override
  final int requestId;
  @override
  final Uint8List? data;
  @override
  final String? stringData;
  @override
  final bool? success;
  @override
  final OpfsWorkerError? error;

  factory _$OpfsWorkerResponse([
    void Function(OpfsWorkerResponseBuilder)? updates,
  ]) => (OpfsWorkerResponseBuilder()..update(updates))._build();

  _$OpfsWorkerResponse._({
    required this.requestId,
    this.data,
    this.stringData,
    this.success,
    this.error,
  }) : super._();
  @override
  OpfsWorkerResponse rebuild(
    void Function(OpfsWorkerResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  OpfsWorkerResponseBuilder toBuilder() =>
      OpfsWorkerResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpfsWorkerResponse &&
        requestId == other.requestId &&
        data == other.data &&
        stringData == other.stringData &&
        success == other.success &&
        error == other.error;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, stringData.hashCode);
    _$hash = $jc(_$hash, success.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }
}

class OpfsWorkerResponseBuilder
    implements Builder<OpfsWorkerResponse, OpfsWorkerResponseBuilder> {
  _$OpfsWorkerResponse? _$v;

  int? _requestId;
  int? get requestId => _$this._requestId;
  set requestId(int? requestId) => _$this._requestId = requestId;

  Uint8List? _data;
  Uint8List? get data => _$this._data;
  set data(Uint8List? data) => _$this._data = data;

  String? _stringData;
  String? get stringData => _$this._stringData;
  set stringData(String? stringData) => _$this._stringData = stringData;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  OpfsWorkerErrorBuilder? _error;
  OpfsWorkerErrorBuilder get error =>
      _$this._error ??= OpfsWorkerErrorBuilder();
  set error(OpfsWorkerErrorBuilder? error) => _$this._error = error;

  OpfsWorkerResponseBuilder();

  OpfsWorkerResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _data = $v.data;
      _stringData = $v.stringData;
      _success = $v.success;
      _error = $v.error?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpfsWorkerResponse other) {
    _$v = other as _$OpfsWorkerResponse;
  }

  @override
  void update(void Function(OpfsWorkerResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpfsWorkerResponse build() => _build();

  _$OpfsWorkerResponse _build() {
    _$OpfsWorkerResponse _$result;
    try {
      _$result =
          _$v ??
          _$OpfsWorkerResponse._(
            requestId: BuiltValueNullFieldError.checkNotNull(
              requestId,
              r'OpfsWorkerResponse',
              'requestId',
            ),
            data: data,
            stringData: stringData,
            success: success,
            error: _error?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'error';
        _error?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'OpfsWorkerResponse',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$OpfsWorkerError extends OpfsWorkerError {
  @override
  final String error;
  @override
  final StackTrace stackTrace;

  factory _$OpfsWorkerError([void Function(OpfsWorkerErrorBuilder)? updates]) =>
      (OpfsWorkerErrorBuilder()..update(updates))._build();

  _$OpfsWorkerError._({required this.error, required this.stackTrace})
    : super._();
  @override
  OpfsWorkerError rebuild(void Function(OpfsWorkerErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpfsWorkerErrorBuilder toBuilder() => OpfsWorkerErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpfsWorkerError &&
        error == other.error &&
        stackTrace == other.stackTrace;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, stackTrace.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpfsWorkerError')
          ..add('error', error)
          ..add('stackTrace', stackTrace))
        .toString();
  }
}

class OpfsWorkerErrorBuilder
    implements Builder<OpfsWorkerError, OpfsWorkerErrorBuilder> {
  _$OpfsWorkerError? _$v;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  StackTrace? _stackTrace;
  StackTrace? get stackTrace => _$this._stackTrace;
  set stackTrace(StackTrace? stackTrace) => _$this._stackTrace = stackTrace;

  OpfsWorkerErrorBuilder();

  OpfsWorkerErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _stackTrace = $v.stackTrace;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpfsWorkerError other) {
    _$v = other as _$OpfsWorkerError;
  }

  @override
  void update(void Function(OpfsWorkerErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpfsWorkerError build() => _build();

  _$OpfsWorkerError _build() {
    final _$result =
        _$v ??
        _$OpfsWorkerError._(
          error: BuiltValueNullFieldError.checkNotNull(
            error,
            r'OpfsWorkerError',
            'error',
          ),
          stackTrace: BuiltValueNullFieldError.checkNotNull(
            stackTrace,
            r'OpfsWorkerError',
            'stackTrace',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// **************************************************************************
// WorkerBeeGenerator
// **************************************************************************

/// The JS implementation of [OpfsWorker].
class _$OpfsWorker extends OpfsWorker {
  @override
  String get name => 'OpfsWorker';

  @override
  String get jsEntrypoint {
    // Default to the compiled, published worker.
    return 'packages/embeddings_explorer/workers/workers.js';
  }

  @override
  List<String> get fallbackUrls {
    // When running in a test, we need to find the `packages` directory which
    // is symlinked in the root `test/` directory.
    final baseUri = Uri.base;
    final basePath = baseUri.pathSegments
        .takeWhile((segment) => segment != 'test')
        .map(Uri.encodeComponent)
        .join('/');
    const relativePath = 'packages/embeddings_explorer/workers/workers.js';
    final testRelativePath = Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.port,
      path: '$basePath/test/$relativePath',
    ).toString();
    return [relativePath, testRelativePath];
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indexed_db_worker.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IndexedDbRequestType _$get = const IndexedDbRequestType._('get');
const IndexedDbRequestType _$getAllKeys = const IndexedDbRequestType._(
  'getAllKeys',
);
const IndexedDbRequestType _$getStorageSize = const IndexedDbRequestType._(
  'getStorageSize',
);
const IndexedDbRequestType _$set = const IndexedDbRequestType._('set');
const IndexedDbRequestType _$delete = const IndexedDbRequestType._('delete');
const IndexedDbRequestType _$clear = const IndexedDbRequestType._('clear');
const IndexedDbRequestType _$exists = const IndexedDbRequestType._('exists');

IndexedDbRequestType _$valueOf(String name) {
  switch (name) {
    case 'get':
      return _$get;
    case 'getAllKeys':
      return _$getAllKeys;
    case 'getStorageSize':
      return _$getStorageSize;
    case 'set':
      return _$set;
    case 'delete':
      return _$delete;
    case 'clear':
      return _$clear;
    case 'exists':
      return _$exists;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IndexedDbRequestType> _$values = BuiltSet<IndexedDbRequestType>(
  const <IndexedDbRequestType>[
    _$get,
    _$getAllKeys,
    _$getStorageSize,
    _$set,
    _$delete,
    _$clear,
    _$exists,
  ],
);

Serializers _$_serializers =
    (Serializers().toBuilder()
          ..add(IndexedDbRequest.serializer)
          ..add(IndexedDbRequestType.serializer)
          ..add(IndexedDbResponse.serializer))
        .build();
Serializer<IndexedDbRequestType> _$indexedDbRequestTypeSerializer =
    _$IndexedDbRequestTypeSerializer();
Serializer<IndexedDbRequest> _$indexedDbRequestSerializer =
    _$IndexedDbRequestSerializer();
Serializer<IndexedDbResponse> _$indexedDbResponseSerializer =
    _$IndexedDbResponseSerializer();

class _$IndexedDbRequestTypeSerializer
    implements PrimitiveSerializer<IndexedDbRequestType> {
  @override
  final Iterable<Type> types = const <Type>[IndexedDbRequestType];
  @override
  final String wireName = 'IndexedDbRequestType';

  @override
  Object serialize(
    Serializers serializers,
    IndexedDbRequestType object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  IndexedDbRequestType deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => IndexedDbRequestType.valueOf(serialized as String);
}

class _$IndexedDbRequestSerializer
    implements StructuredSerializer<IndexedDbRequest> {
  @override
  final Iterable<Type> types = const [IndexedDbRequest, _$IndexedDbRequest];
  @override
  final String wireName = 'IndexedDbRequest';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    IndexedDbRequest object, {
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
        specifiedType: const FullType(IndexedDbRequestType),
      ),
    ];
    Object? value;
    value = object.key;
    if (value != null) {
      result
        ..add('key')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.value;
    if (value != null) {
      result
        ..add('value')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    return result;
  }

  @override
  IndexedDbRequest deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IndexedDbRequestBuilder();

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
                    specifiedType: const FullType(IndexedDbRequestType),
                  )!
                  as IndexedDbRequestType;
          break;
        case 'key':
          result.key =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'value':
          result.value =
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

class _$IndexedDbResponseSerializer
    implements StructuredSerializer<IndexedDbResponse> {
  @override
  final Iterable<Type> types = const [IndexedDbResponse, _$IndexedDbResponse];
  @override
  final String wireName = 'IndexedDbResponse';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    IndexedDbResponse object, {
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
    value = object.value;
    if (value != null) {
      result
        ..add('value')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    return result;
  }

  @override
  IndexedDbResponse deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IndexedDbResponseBuilder();

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
        case 'value':
          result.value =
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

class _$IndexedDbRequest extends IndexedDbRequest {
  @override
  final int requestId;
  @override
  final IndexedDbRequestType type;
  @override
  final String? key;
  @override
  final String? value;

  factory _$IndexedDbRequest([
    void Function(IndexedDbRequestBuilder)? updates,
  ]) => (IndexedDbRequestBuilder()..update(updates))._build();

  _$IndexedDbRequest._({
    required this.requestId,
    required this.type,
    this.key,
    this.value,
  }) : super._();
  @override
  IndexedDbRequest rebuild(void Function(IndexedDbRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IndexedDbRequestBuilder toBuilder() =>
      IndexedDbRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IndexedDbRequest &&
        requestId == other.requestId &&
        type == other.type &&
        key == other.key &&
        value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IndexedDbRequest')
          ..add('requestId', requestId)
          ..add('type', type)
          ..add('key', key)
          ..add('value', value))
        .toString();
  }
}

class IndexedDbRequestBuilder
    implements Builder<IndexedDbRequest, IndexedDbRequestBuilder> {
  _$IndexedDbRequest? _$v;

  int? _requestId;
  int? get requestId => _$this._requestId;
  set requestId(int? requestId) => _$this._requestId = requestId;

  IndexedDbRequestType? _type;
  IndexedDbRequestType? get type => _$this._type;
  set type(IndexedDbRequestType? type) => _$this._type = type;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  IndexedDbRequestBuilder();

  IndexedDbRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _type = $v.type;
      _key = $v.key;
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IndexedDbRequest other) {
    _$v = other as _$IndexedDbRequest;
  }

  @override
  void update(void Function(IndexedDbRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IndexedDbRequest build() => _build();

  _$IndexedDbRequest _build() {
    final _$result =
        _$v ??
        _$IndexedDbRequest._(
          requestId: BuiltValueNullFieldError.checkNotNull(
            requestId,
            r'IndexedDbRequest',
            'requestId',
          ),
          type: BuiltValueNullFieldError.checkNotNull(
            type,
            r'IndexedDbRequest',
            'type',
          ),
          key: key,
          value: value,
        );
    replace(_$result);
    return _$result;
  }
}

class _$IndexedDbResponse extends IndexedDbResponse {
  @override
  final int requestId;
  @override
  final String? value;

  factory _$IndexedDbResponse([
    void Function(IndexedDbResponseBuilder)? updates,
  ]) => (IndexedDbResponseBuilder()..update(updates))._build();

  _$IndexedDbResponse._({required this.requestId, this.value}) : super._();
  @override
  IndexedDbResponse rebuild(void Function(IndexedDbResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IndexedDbResponseBuilder toBuilder() =>
      IndexedDbResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IndexedDbResponse &&
        requestId == other.requestId &&
        value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IndexedDbResponse')
          ..add('requestId', requestId)
          ..add('value', value))
        .toString();
  }
}

class IndexedDbResponseBuilder
    implements Builder<IndexedDbResponse, IndexedDbResponseBuilder> {
  _$IndexedDbResponse? _$v;

  int? _requestId;
  int? get requestId => _$this._requestId;
  set requestId(int? requestId) => _$this._requestId = requestId;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  IndexedDbResponseBuilder();

  IndexedDbResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IndexedDbResponse other) {
    _$v = other as _$IndexedDbResponse;
  }

  @override
  void update(void Function(IndexedDbResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IndexedDbResponse build() => _build();

  _$IndexedDbResponse _build() {
    final _$result =
        _$v ??
        _$IndexedDbResponse._(
          requestId: BuiltValueNullFieldError.checkNotNull(
            requestId,
            r'IndexedDbResponse',
            'requestId',
          ),
          value: value,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// **************************************************************************
// WorkerBeeGenerator
// **************************************************************************

/// The JS implementation of [IndexedDbWorker].
class _$IndexedDbWorker extends IndexedDbWorker {
  @override
  String get name => 'IndexedDbWorker';

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

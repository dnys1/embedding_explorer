// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'libsql_worker.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LibsqlRequestType _$init = const LibsqlRequestType._('init');
const LibsqlRequestType _$execute = const LibsqlRequestType._('execute');
const LibsqlRequestType _$query = const LibsqlRequestType._('query');

LibsqlRequestType _$valueOf(String name) {
  switch (name) {
    case 'init':
      return _$init;
    case 'execute':
      return _$execute;
    case 'query':
      return _$query;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LibsqlRequestType> _$values = BuiltSet<LibsqlRequestType>(
  const <LibsqlRequestType>[_$init, _$execute, _$query],
);

Serializers _$_serializers =
    (Serializers().toBuilder()
          ..add(LibsqlRequest.serializer)
          ..add(LibsqlRequestType.serializer)
          ..add(LibsqlResponse.serializer)
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(BuiltList, const [
                const FullType.nullable(Object),
              ]),
            ]),
            () => ListBuilder<BuiltList<Object?>>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType.nullable(Object)]),
            () => ListBuilder<Object?>(),
          ))
        .build();
Serializer<LibsqlRequestType> _$libsqlRequestTypeSerializer =
    _$LibsqlRequestTypeSerializer();
Serializer<LibsqlRequest> _$libsqlRequestSerializer =
    _$LibsqlRequestSerializer();
Serializer<LibsqlResponse> _$libsqlResponseSerializer =
    _$LibsqlResponseSerializer();

class _$LibsqlRequestTypeSerializer
    implements PrimitiveSerializer<LibsqlRequestType> {
  @override
  final Iterable<Type> types = const <Type>[LibsqlRequestType];
  @override
  final String wireName = 'LibsqlRequestType';

  @override
  Object serialize(
    Serializers serializers,
    LibsqlRequestType object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  LibsqlRequestType deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => LibsqlRequestType.valueOf(serialized as String);
}

class _$LibsqlRequestSerializer implements StructuredSerializer<LibsqlRequest> {
  @override
  final Iterable<Type> types = const [LibsqlRequest, _$LibsqlRequest];
  @override
  final String wireName = 'LibsqlRequest';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    LibsqlRequest object, {
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
        specifiedType: const FullType(LibsqlRequestType),
      ),
      'sql',
      serializers.serialize(object.sql, specifiedType: const FullType(String)),
      'parameters',
      serializers.serialize(
        object.parameters,
        specifiedType: const FullType(BuiltList, const [
          const FullType.nullable(Object),
        ]),
      ),
    ];
    Object? value;
    value = object.moduleUri;
    if (value != null) {
      result
        ..add('moduleUri')
        ..add(serializers.serialize(value, specifiedType: const FullType(Uri)));
    }
    value = object.filename;
    if (value != null) {
      result
        ..add('filename')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.flags;
    if (value != null) {
      result
        ..add('flags')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.vfs;
    if (value != null) {
      result
        ..add('vfs')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    return result;
  }

  @override
  LibsqlRequest deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LibsqlRequestBuilder();

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
                    specifiedType: const FullType(LibsqlRequestType),
                  )!
                  as LibsqlRequestType;
          break;
        case 'sql':
          result.sql =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'parameters':
          result.parameters.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType.nullable(Object),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
        case 'moduleUri':
          result.moduleUri =
              serializers.deserialize(value, specifiedType: const FullType(Uri))
                  as Uri?;
          break;
        case 'filename':
          result.filename =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'flags':
          result.flags =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'vfs':
          result.vfs =
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

class _$LibsqlResponseSerializer
    implements StructuredSerializer<LibsqlResponse> {
  @override
  final Iterable<Type> types = const [LibsqlResponse, _$LibsqlResponse];
  @override
  final String wireName = 'LibsqlResponse';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    LibsqlResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'requestId',
      serializers.serialize(
        object.requestId,
        specifiedType: const FullType(int),
      ),
      'columnNames',
      serializers.serialize(
        object.columnNames,
        specifiedType: const FullType(BuiltList, const [
          const FullType(String),
        ]),
      ),
      'rows',
      serializers.serialize(
        object.rows,
        specifiedType: const FullType(BuiltList, const [
          const FullType(BuiltList, const [const FullType.nullable(Object)]),
        ]),
      ),
    ];

    return result;
  }

  @override
  LibsqlResponse deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LibsqlResponseBuilder();

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
        case 'columnNames':
          result.columnNames.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(String),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
        case 'rows':
          result.rows.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(BuiltList, const [
                      const FullType.nullable(Object),
                    ]),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$LibsqlRequest extends LibsqlRequest {
  @override
  final int requestId;
  @override
  final LibsqlRequestType type;
  @override
  final String sql;
  @override
  final BuiltList<Object?> parameters;
  @override
  final Uri? moduleUri;
  @override
  final String? filename;
  @override
  final String? flags;
  @override
  final String? vfs;

  factory _$LibsqlRequest([void Function(LibsqlRequestBuilder)? updates]) =>
      (LibsqlRequestBuilder()..update(updates))._build();

  _$LibsqlRequest._({
    required this.requestId,
    required this.type,
    required this.sql,
    required this.parameters,
    this.moduleUri,
    this.filename,
    this.flags,
    this.vfs,
  }) : super._();
  @override
  LibsqlRequest rebuild(void Function(LibsqlRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LibsqlRequestBuilder toBuilder() => LibsqlRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LibsqlRequest &&
        requestId == other.requestId &&
        type == other.type &&
        sql == other.sql &&
        parameters == other.parameters &&
        moduleUri == other.moduleUri &&
        filename == other.filename &&
        flags == other.flags &&
        vfs == other.vfs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, sql.hashCode);
    _$hash = $jc(_$hash, parameters.hashCode);
    _$hash = $jc(_$hash, moduleUri.hashCode);
    _$hash = $jc(_$hash, filename.hashCode);
    _$hash = $jc(_$hash, flags.hashCode);
    _$hash = $jc(_$hash, vfs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LibsqlRequest')
          ..add('requestId', requestId)
          ..add('type', type)
          ..add('sql', sql)
          ..add('parameters', parameters)
          ..add('moduleUri', moduleUri)
          ..add('filename', filename)
          ..add('flags', flags)
          ..add('vfs', vfs))
        .toString();
  }
}

class LibsqlRequestBuilder
    implements Builder<LibsqlRequest, LibsqlRequestBuilder> {
  _$LibsqlRequest? _$v;

  int? _requestId;
  int? get requestId => _$this._requestId;
  set requestId(int? requestId) => _$this._requestId = requestId;

  LibsqlRequestType? _type;
  LibsqlRequestType? get type => _$this._type;
  set type(LibsqlRequestType? type) => _$this._type = type;

  String? _sql;
  String? get sql => _$this._sql;
  set sql(String? sql) => _$this._sql = sql;

  ListBuilder<Object?>? _parameters;
  ListBuilder<Object?> get parameters =>
      _$this._parameters ??= ListBuilder<Object?>();
  set parameters(ListBuilder<Object?>? parameters) =>
      _$this._parameters = parameters;

  Uri? _moduleUri;
  Uri? get moduleUri => _$this._moduleUri;
  set moduleUri(Uri? moduleUri) => _$this._moduleUri = moduleUri;

  String? _filename;
  String? get filename => _$this._filename;
  set filename(String? filename) => _$this._filename = filename;

  String? _flags;
  String? get flags => _$this._flags;
  set flags(String? flags) => _$this._flags = flags;

  String? _vfs;
  String? get vfs => _$this._vfs;
  set vfs(String? vfs) => _$this._vfs = vfs;

  LibsqlRequestBuilder();

  LibsqlRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _type = $v.type;
      _sql = $v.sql;
      _parameters = $v.parameters.toBuilder();
      _moduleUri = $v.moduleUri;
      _filename = $v.filename;
      _flags = $v.flags;
      _vfs = $v.vfs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LibsqlRequest other) {
    _$v = other as _$LibsqlRequest;
  }

  @override
  void update(void Function(LibsqlRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LibsqlRequest build() => _build();

  _$LibsqlRequest _build() {
    _$LibsqlRequest _$result;
    try {
      _$result =
          _$v ??
          _$LibsqlRequest._(
            requestId: BuiltValueNullFieldError.checkNotNull(
              requestId,
              r'LibsqlRequest',
              'requestId',
            ),
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'LibsqlRequest',
              'type',
            ),
            sql: BuiltValueNullFieldError.checkNotNull(
              sql,
              r'LibsqlRequest',
              'sql',
            ),
            parameters: parameters.build(),
            moduleUri: moduleUri,
            filename: filename,
            flags: flags,
            vfs: vfs,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'parameters';
        parameters.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'LibsqlRequest',
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

class _$LibsqlResponse extends LibsqlResponse {
  @override
  final int requestId;
  @override
  final BuiltList<String> columnNames;
  @override
  final BuiltList<BuiltList<Object?>> rows;

  factory _$LibsqlResponse([void Function(LibsqlResponseBuilder)? updates]) =>
      (LibsqlResponseBuilder()..update(updates))._build();

  _$LibsqlResponse._({
    required this.requestId,
    required this.columnNames,
    required this.rows,
  }) : super._();
  @override
  LibsqlResponse rebuild(void Function(LibsqlResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LibsqlResponseBuilder toBuilder() => LibsqlResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LibsqlResponse &&
        requestId == other.requestId &&
        columnNames == other.columnNames &&
        rows == other.rows;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, columnNames.hashCode);
    _$hash = $jc(_$hash, rows.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LibsqlResponse')
          ..add('requestId', requestId)
          ..add('columnNames', columnNames)
          ..add('rows', rows))
        .toString();
  }
}

class LibsqlResponseBuilder
    implements Builder<LibsqlResponse, LibsqlResponseBuilder> {
  _$LibsqlResponse? _$v;

  int? _requestId;
  int? get requestId => _$this._requestId;
  set requestId(int? requestId) => _$this._requestId = requestId;

  ListBuilder<String>? _columnNames;
  ListBuilder<String> get columnNames =>
      _$this._columnNames ??= ListBuilder<String>();
  set columnNames(ListBuilder<String>? columnNames) =>
      _$this._columnNames = columnNames;

  ListBuilder<BuiltList<Object?>>? _rows;
  ListBuilder<BuiltList<Object?>> get rows =>
      _$this._rows ??= ListBuilder<BuiltList<Object?>>();
  set rows(ListBuilder<BuiltList<Object?>>? rows) => _$this._rows = rows;

  LibsqlResponseBuilder();

  LibsqlResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _columnNames = $v.columnNames.toBuilder();
      _rows = $v.rows.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LibsqlResponse other) {
    _$v = other as _$LibsqlResponse;
  }

  @override
  void update(void Function(LibsqlResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LibsqlResponse build() => _build();

  _$LibsqlResponse _build() {
    _$LibsqlResponse _$result;
    try {
      _$result =
          _$v ??
          _$LibsqlResponse._(
            requestId: BuiltValueNullFieldError.checkNotNull(
              requestId,
              r'LibsqlResponse',
              'requestId',
            ),
            columnNames: columnNames.build(),
            rows: rows.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'columnNames';
        columnNames.build();
        _$failedField = 'rows';
        rows.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'LibsqlResponse',
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

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// **************************************************************************
// WorkerBeeGenerator
// **************************************************************************

/// The JS implementation of [LibsqlWorker].
class _$LibsqlWorker extends LibsqlWorker {
  @override
  String get name => 'LibsqlWorker';

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

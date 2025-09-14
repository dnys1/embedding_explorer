// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'libsql_worker.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LibsqlRequestType _$init = const LibsqlRequestType._('init');
const LibsqlRequestType _$execute = const LibsqlRequestType._('execute');
const LibsqlRequestType _$query = const LibsqlRequestType._('query');
const LibsqlRequestType _$transaction = const LibsqlRequestType._(
  'transaction',
);

LibsqlRequestType _$valueOf(String name) {
  switch (name) {
    case 'init':
      return _$init;
    case 'execute':
      return _$execute;
    case 'query':
      return _$query;
    case 'transaction':
      return _$transaction;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LibsqlRequestType> _$values = BuiltSet<LibsqlRequestType>(
  const <LibsqlRequestType>[_$init, _$execute, _$query, _$transaction],
);

Serializers _$_serializers =
    (Serializers().toBuilder()
          ..add(LibsqlError.serializer)
          ..add(LibsqlRequest.serializer)
          ..add(LibsqlRequestType.serializer)
          ..add(LibsqlResponse.serializer)
          ..add(LibsqlResultSet.serializer)
          ..add(SqlStatement.serializer)
          ..add(Transaction.serializer)
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(SqlStatement)]),
            () => ListBuilder<SqlStatement>(),
          )
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
Serializer<LibsqlResultSet> _$libsqlResultSetSerializer =
    _$LibsqlResultSetSerializer();
Serializer<LibsqlError> _$libsqlErrorSerializer = _$LibsqlErrorSerializer();

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
      'transaction',
      serializers.serialize(
        object.transaction,
        specifiedType: const FullType(Transaction),
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
    value = object.vfsName;
    if (value != null) {
      result
        ..add('vfsName')
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
        case 'transaction':
          result.transaction.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(Transaction),
                )!
                as Transaction,
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
        case 'vfsName':
          result.vfsName =
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
    ];
    Object? value;
    value = object.resultSet;
    if (value != null) {
      result
        ..add('resultSet')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(LibsqlResultSet),
          ),
        );
    }
    value = object.error;
    if (value != null) {
      result
        ..add('error')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(LibsqlError),
          ),
        );
    }
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
        case 'resultSet':
          result.resultSet.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(LibsqlResultSet),
                )!
                as LibsqlResultSet,
          );
          break;
        case 'error':
          result.error.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(LibsqlError),
                )!
                as LibsqlError,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$LibsqlResultSetSerializer
    implements StructuredSerializer<LibsqlResultSet> {
  @override
  final Iterable<Type> types = const [LibsqlResultSet, _$LibsqlResultSet];
  @override
  final String wireName = 'LibsqlResultSet';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    LibsqlResultSet object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'columnNames',
      serializers.serialize(
        object.columnNames,
        specifiedType: const FullType(BuiltList, const [
          const FullType(String),
        ]),
      ),
      'lastInsertRowId',
      serializers.serialize(
        object.lastInsertRowId,
        specifiedType: const FullType(int),
      ),
      'updatedRows',
      serializers.serialize(
        object.updatedRows,
        specifiedType: const FullType(int),
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
  LibsqlResultSet deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LibsqlResultSetBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
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
        case 'lastInsertRowId':
          result.lastInsertRowId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'updatedRows':
          result.updatedRows =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
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

class _$LibsqlErrorSerializer implements StructuredSerializer<LibsqlError> {
  @override
  final Iterable<Type> types = const [LibsqlError, _$LibsqlError];
  @override
  final String wireName = 'LibsqlError';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    LibsqlError object, {
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
    Object? value;
    value = object.code;
    if (value != null) {
      result
        ..add('code')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    return result;
  }

  @override
  LibsqlError deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LibsqlErrorBuilder();

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
        case 'code':
          result.code =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int?;
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

class _$LibsqlRequest extends LibsqlRequest {
  @override
  final int requestId;
  @override
  final LibsqlRequestType type;
  @override
  final Transaction transaction;
  @override
  final Uri? moduleUri;
  @override
  final String? filename;
  @override
  final String? vfsName;

  factory _$LibsqlRequest([void Function(LibsqlRequestBuilder)? updates]) =>
      (LibsqlRequestBuilder()..update(updates))._build();

  _$LibsqlRequest._({
    required this.requestId,
    required this.type,
    required this.transaction,
    this.moduleUri,
    this.filename,
    this.vfsName,
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
        transaction == other.transaction &&
        moduleUri == other.moduleUri &&
        filename == other.filename &&
        vfsName == other.vfsName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, transaction.hashCode);
    _$hash = $jc(_$hash, moduleUri.hashCode);
    _$hash = $jc(_$hash, filename.hashCode);
    _$hash = $jc(_$hash, vfsName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LibsqlRequest')
          ..add('requestId', requestId)
          ..add('type', type)
          ..add('transaction', transaction)
          ..add('moduleUri', moduleUri)
          ..add('filename', filename)
          ..add('vfsName', vfsName))
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

  TransactionBuilder? _transaction;
  TransactionBuilder get transaction =>
      _$this._transaction ??= TransactionBuilder();
  set transaction(TransactionBuilder? transaction) =>
      _$this._transaction = transaction;

  Uri? _moduleUri;
  Uri? get moduleUri => _$this._moduleUri;
  set moduleUri(Uri? moduleUri) => _$this._moduleUri = moduleUri;

  String? _filename;
  String? get filename => _$this._filename;
  set filename(String? filename) => _$this._filename = filename;

  String? _vfsName;
  String? get vfsName => _$this._vfsName;
  set vfsName(String? vfsName) => _$this._vfsName = vfsName;

  LibsqlRequestBuilder();

  LibsqlRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _type = $v.type;
      _transaction = $v.transaction.toBuilder();
      _moduleUri = $v.moduleUri;
      _filename = $v.filename;
      _vfsName = $v.vfsName;
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
            transaction: transaction.build(),
            moduleUri: moduleUri,
            filename: filename,
            vfsName: vfsName,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'transaction';
        transaction.build();
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
  final LibsqlResultSet? resultSet;
  @override
  final LibsqlError? error;

  factory _$LibsqlResponse([void Function(LibsqlResponseBuilder)? updates]) =>
      (LibsqlResponseBuilder()..update(updates))._build();

  _$LibsqlResponse._({required this.requestId, this.resultSet, this.error})
    : super._();
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
        resultSet == other.resultSet &&
        error == other.error;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, resultSet.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LibsqlResponse')
          ..add('requestId', requestId)
          ..add('resultSet', resultSet)
          ..add('error', error))
        .toString();
  }
}

class LibsqlResponseBuilder
    implements Builder<LibsqlResponse, LibsqlResponseBuilder> {
  _$LibsqlResponse? _$v;

  int? _requestId;
  int? get requestId => _$this._requestId;
  set requestId(int? requestId) => _$this._requestId = requestId;

  LibsqlResultSetBuilder? _resultSet;
  LibsqlResultSetBuilder get resultSet =>
      _$this._resultSet ??= LibsqlResultSetBuilder();
  set resultSet(LibsqlResultSetBuilder? resultSet) =>
      _$this._resultSet = resultSet;

  LibsqlErrorBuilder? _error;
  LibsqlErrorBuilder get error => _$this._error ??= LibsqlErrorBuilder();
  set error(LibsqlErrorBuilder? error) => _$this._error = error;

  LibsqlResponseBuilder();

  LibsqlResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _resultSet = $v.resultSet?.toBuilder();
      _error = $v.error?.toBuilder();
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
            resultSet: _resultSet?.build(),
            error: _error?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'resultSet';
        _resultSet?.build();
        _$failedField = 'error';
        _error?.build();
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

class _$LibsqlResultSet extends LibsqlResultSet {
  @override
  final BuiltList<String> columnNames;
  @override
  final int lastInsertRowId;
  @override
  final int updatedRows;
  @override
  final BuiltList<BuiltList<Object?>> rows;

  factory _$LibsqlResultSet([void Function(LibsqlResultSetBuilder)? updates]) =>
      (LibsqlResultSetBuilder()..update(updates))._build();

  _$LibsqlResultSet._({
    required this.columnNames,
    required this.lastInsertRowId,
    required this.updatedRows,
    required this.rows,
  }) : super._();
  @override
  LibsqlResultSet rebuild(void Function(LibsqlResultSetBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LibsqlResultSetBuilder toBuilder() => LibsqlResultSetBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LibsqlResultSet &&
        columnNames == other.columnNames &&
        lastInsertRowId == other.lastInsertRowId &&
        updatedRows == other.updatedRows &&
        rows == other.rows;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, columnNames.hashCode);
    _$hash = $jc(_$hash, lastInsertRowId.hashCode);
    _$hash = $jc(_$hash, updatedRows.hashCode);
    _$hash = $jc(_$hash, rows.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LibsqlResultSet')
          ..add('columnNames', columnNames)
          ..add('lastInsertRowId', lastInsertRowId)
          ..add('updatedRows', updatedRows)
          ..add('rows', rows))
        .toString();
  }
}

class LibsqlResultSetBuilder
    implements Builder<LibsqlResultSet, LibsqlResultSetBuilder> {
  _$LibsqlResultSet? _$v;

  ListBuilder<String>? _columnNames;
  ListBuilder<String> get columnNames =>
      _$this._columnNames ??= ListBuilder<String>();
  set columnNames(ListBuilder<String>? columnNames) =>
      _$this._columnNames = columnNames;

  int? _lastInsertRowId;
  int? get lastInsertRowId => _$this._lastInsertRowId;
  set lastInsertRowId(int? lastInsertRowId) =>
      _$this._lastInsertRowId = lastInsertRowId;

  int? _updatedRows;
  int? get updatedRows => _$this._updatedRows;
  set updatedRows(int? updatedRows) => _$this._updatedRows = updatedRows;

  ListBuilder<BuiltList<Object?>>? _rows;
  ListBuilder<BuiltList<Object?>> get rows =>
      _$this._rows ??= ListBuilder<BuiltList<Object?>>();
  set rows(ListBuilder<BuiltList<Object?>>? rows) => _$this._rows = rows;

  LibsqlResultSetBuilder();

  LibsqlResultSetBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _columnNames = $v.columnNames.toBuilder();
      _lastInsertRowId = $v.lastInsertRowId;
      _updatedRows = $v.updatedRows;
      _rows = $v.rows.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LibsqlResultSet other) {
    _$v = other as _$LibsqlResultSet;
  }

  @override
  void update(void Function(LibsqlResultSetBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LibsqlResultSet build() => _build();

  _$LibsqlResultSet _build() {
    _$LibsqlResultSet _$result;
    try {
      _$result =
          _$v ??
          _$LibsqlResultSet._(
            columnNames: columnNames.build(),
            lastInsertRowId: BuiltValueNullFieldError.checkNotNull(
              lastInsertRowId,
              r'LibsqlResultSet',
              'lastInsertRowId',
            ),
            updatedRows: BuiltValueNullFieldError.checkNotNull(
              updatedRows,
              r'LibsqlResultSet',
              'updatedRows',
            ),
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
          r'LibsqlResultSet',
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

class _$LibsqlError extends LibsqlError {
  @override
  final String error;
  @override
  final int? code;
  @override
  final StackTrace stackTrace;

  factory _$LibsqlError([void Function(LibsqlErrorBuilder)? updates]) =>
      (LibsqlErrorBuilder()..update(updates))._build();

  _$LibsqlError._({required this.error, this.code, required this.stackTrace})
    : super._();
  @override
  LibsqlError rebuild(void Function(LibsqlErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LibsqlErrorBuilder toBuilder() => LibsqlErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LibsqlError &&
        error == other.error &&
        code == other.code &&
        stackTrace == other.stackTrace;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, stackTrace.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LibsqlError')
          ..add('error', error)
          ..add('code', code)
          ..add('stackTrace', stackTrace))
        .toString();
  }
}

class LibsqlErrorBuilder implements Builder<LibsqlError, LibsqlErrorBuilder> {
  _$LibsqlError? _$v;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  int? _code;
  int? get code => _$this._code;
  set code(int? code) => _$this._code = code;

  StackTrace? _stackTrace;
  StackTrace? get stackTrace => _$this._stackTrace;
  set stackTrace(StackTrace? stackTrace) => _$this._stackTrace = stackTrace;

  LibsqlErrorBuilder();

  LibsqlErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _code = $v.code;
      _stackTrace = $v.stackTrace;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LibsqlError other) {
    _$v = other as _$LibsqlError;
  }

  @override
  void update(void Function(LibsqlErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LibsqlError build() => _build();

  _$LibsqlError _build() {
    final _$result =
        _$v ??
        _$LibsqlError._(
          error: BuiltValueNullFieldError.checkNotNull(
            error,
            r'LibsqlError',
            'error',
          ),
          code: code,
          stackTrace: BuiltValueNullFieldError.checkNotNull(
            stackTrace,
            r'LibsqlError',
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

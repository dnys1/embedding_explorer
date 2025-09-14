// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_worker.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DatabaseRequestType _$init = const DatabaseRequestType._('init');
const DatabaseRequestType _$execute = const DatabaseRequestType._('execute');
const DatabaseRequestType _$query = const DatabaseRequestType._('query');
const DatabaseRequestType _$transaction = const DatabaseRequestType._(
  'transaction',
);

DatabaseRequestType _$valueOf(String name) {
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

final BuiltSet<DatabaseRequestType> _$values = BuiltSet<DatabaseRequestType>(
  const <DatabaseRequestType>[_$init, _$execute, _$query, _$transaction],
);

Serializers _$_serializers =
    (Serializers().toBuilder()
          ..add(DatabaseError.serializer)
          ..add(DatabaseRequest.serializer)
          ..add(DatabaseRequestType.serializer)
          ..add(DatabaseResponse.serializer)
          ..add(DatabaseResultSet.serializer)
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
Serializer<DatabaseRequestType> _$databaseRequestTypeSerializer =
    _$DatabaseRequestTypeSerializer();
Serializer<DatabaseRequest> _$databaseRequestSerializer =
    _$DatabaseRequestSerializer();
Serializer<DatabaseResponse> _$databaseResponseSerializer =
    _$DatabaseResponseSerializer();
Serializer<DatabaseResultSet> _$databaseResultSetSerializer =
    _$DatabaseResultSetSerializer();
Serializer<DatabaseError> _$databaseErrorSerializer =
    _$DatabaseErrorSerializer();

class _$DatabaseRequestTypeSerializer
    implements PrimitiveSerializer<DatabaseRequestType> {
  @override
  final Iterable<Type> types = const <Type>[DatabaseRequestType];
  @override
  final String wireName = 'DatabaseRequestType';

  @override
  Object serialize(
    Serializers serializers,
    DatabaseRequestType object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  DatabaseRequestType deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DatabaseRequestType.valueOf(serialized as String);
}

class _$DatabaseRequestSerializer
    implements StructuredSerializer<DatabaseRequest> {
  @override
  final Iterable<Type> types = const [DatabaseRequest, _$DatabaseRequest];
  @override
  final String wireName = 'DatabaseRequest';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    DatabaseRequest object, {
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
        specifiedType: const FullType(DatabaseRequestType),
      ),
      'transaction',
      serializers.serialize(
        object.transaction,
        specifiedType: const FullType(Transaction),
      ),
    ];
    Object? value;
    value = object.libsqlUri;
    if (value != null) {
      result
        ..add('libsqlUri')
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
  DatabaseRequest deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DatabaseRequestBuilder();

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
                    specifiedType: const FullType(DatabaseRequestType),
                  )!
                  as DatabaseRequestType;
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
        case 'libsqlUri':
          result.libsqlUri =
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

class _$DatabaseResponseSerializer
    implements StructuredSerializer<DatabaseResponse> {
  @override
  final Iterable<Type> types = const [DatabaseResponse, _$DatabaseResponse];
  @override
  final String wireName = 'DatabaseResponse';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    DatabaseResponse object, {
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
            specifiedType: const FullType(DatabaseResultSet),
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
            specifiedType: const FullType(DatabaseError),
          ),
        );
    }
    return result;
  }

  @override
  DatabaseResponse deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DatabaseResponseBuilder();

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
                  specifiedType: const FullType(DatabaseResultSet),
                )!
                as DatabaseResultSet,
          );
          break;
        case 'error':
          result.error.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(DatabaseError),
                )!
                as DatabaseError,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$DatabaseResultSetSerializer
    implements StructuredSerializer<DatabaseResultSet> {
  @override
  final Iterable<Type> types = const [DatabaseResultSet, _$DatabaseResultSet];
  @override
  final String wireName = 'DatabaseResultSet';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    DatabaseResultSet object, {
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
  DatabaseResultSet deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DatabaseResultSetBuilder();

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

class _$DatabaseErrorSerializer implements StructuredSerializer<DatabaseError> {
  @override
  final Iterable<Type> types = const [DatabaseError, _$DatabaseError];
  @override
  final String wireName = 'DatabaseError';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    DatabaseError object, {
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
  DatabaseError deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DatabaseErrorBuilder();

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

class _$DatabaseRequest extends DatabaseRequest {
  @override
  final int requestId;
  @override
  final DatabaseRequestType type;
  @override
  final Transaction transaction;
  @override
  final Uri? libsqlUri;
  @override
  final String? filename;
  @override
  final String? vfsName;

  factory _$DatabaseRequest([void Function(DatabaseRequestBuilder)? updates]) =>
      (DatabaseRequestBuilder()..update(updates))._build();

  _$DatabaseRequest._({
    required this.requestId,
    required this.type,
    required this.transaction,
    this.libsqlUri,
    this.filename,
    this.vfsName,
  }) : super._();
  @override
  DatabaseRequest rebuild(void Function(DatabaseRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DatabaseRequestBuilder toBuilder() => DatabaseRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DatabaseRequest &&
        requestId == other.requestId &&
        type == other.type &&
        transaction == other.transaction &&
        libsqlUri == other.libsqlUri &&
        filename == other.filename &&
        vfsName == other.vfsName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, transaction.hashCode);
    _$hash = $jc(_$hash, libsqlUri.hashCode);
    _$hash = $jc(_$hash, filename.hashCode);
    _$hash = $jc(_$hash, vfsName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DatabaseRequest')
          ..add('requestId', requestId)
          ..add('type', type)
          ..add('transaction', transaction)
          ..add('libsqlUri', libsqlUri)
          ..add('filename', filename)
          ..add('vfsName', vfsName))
        .toString();
  }
}

class DatabaseRequestBuilder
    implements Builder<DatabaseRequest, DatabaseRequestBuilder> {
  _$DatabaseRequest? _$v;

  int? _requestId;
  int? get requestId => _$this._requestId;
  set requestId(int? requestId) => _$this._requestId = requestId;

  DatabaseRequestType? _type;
  DatabaseRequestType? get type => _$this._type;
  set type(DatabaseRequestType? type) => _$this._type = type;

  TransactionBuilder? _transaction;
  TransactionBuilder get transaction =>
      _$this._transaction ??= TransactionBuilder();
  set transaction(TransactionBuilder? transaction) =>
      _$this._transaction = transaction;

  Uri? _libsqlUri;
  Uri? get libsqlUri => _$this._libsqlUri;
  set libsqlUri(Uri? libsqlUri) => _$this._libsqlUri = libsqlUri;

  String? _filename;
  String? get filename => _$this._filename;
  set filename(String? filename) => _$this._filename = filename;

  String? _vfsName;
  String? get vfsName => _$this._vfsName;
  set vfsName(String? vfsName) => _$this._vfsName = vfsName;

  DatabaseRequestBuilder();

  DatabaseRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _type = $v.type;
      _transaction = $v.transaction.toBuilder();
      _libsqlUri = $v.libsqlUri;
      _filename = $v.filename;
      _vfsName = $v.vfsName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DatabaseRequest other) {
    _$v = other as _$DatabaseRequest;
  }

  @override
  void update(void Function(DatabaseRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DatabaseRequest build() => _build();

  _$DatabaseRequest _build() {
    _$DatabaseRequest _$result;
    try {
      _$result =
          _$v ??
          _$DatabaseRequest._(
            requestId: BuiltValueNullFieldError.checkNotNull(
              requestId,
              r'DatabaseRequest',
              'requestId',
            ),
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'DatabaseRequest',
              'type',
            ),
            transaction: transaction.build(),
            libsqlUri: libsqlUri,
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
          r'DatabaseRequest',
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

class _$DatabaseResponse extends DatabaseResponse {
  @override
  final int requestId;
  @override
  final DatabaseResultSet? resultSet;
  @override
  final DatabaseError? error;

  factory _$DatabaseResponse([
    void Function(DatabaseResponseBuilder)? updates,
  ]) => (DatabaseResponseBuilder()..update(updates))._build();

  _$DatabaseResponse._({required this.requestId, this.resultSet, this.error})
    : super._();
  @override
  DatabaseResponse rebuild(void Function(DatabaseResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DatabaseResponseBuilder toBuilder() =>
      DatabaseResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DatabaseResponse &&
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
    return (newBuiltValueToStringHelper(r'DatabaseResponse')
          ..add('requestId', requestId)
          ..add('resultSet', resultSet)
          ..add('error', error))
        .toString();
  }
}

class DatabaseResponseBuilder
    implements Builder<DatabaseResponse, DatabaseResponseBuilder> {
  _$DatabaseResponse? _$v;

  int? _requestId;
  int? get requestId => _$this._requestId;
  set requestId(int? requestId) => _$this._requestId = requestId;

  DatabaseResultSetBuilder? _resultSet;
  DatabaseResultSetBuilder get resultSet =>
      _$this._resultSet ??= DatabaseResultSetBuilder();
  set resultSet(DatabaseResultSetBuilder? resultSet) =>
      _$this._resultSet = resultSet;

  DatabaseErrorBuilder? _error;
  DatabaseErrorBuilder get error => _$this._error ??= DatabaseErrorBuilder();
  set error(DatabaseErrorBuilder? error) => _$this._error = error;

  DatabaseResponseBuilder();

  DatabaseResponseBuilder get _$this {
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
  void replace(DatabaseResponse other) {
    _$v = other as _$DatabaseResponse;
  }

  @override
  void update(void Function(DatabaseResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DatabaseResponse build() => _build();

  _$DatabaseResponse _build() {
    _$DatabaseResponse _$result;
    try {
      _$result =
          _$v ??
          _$DatabaseResponse._(
            requestId: BuiltValueNullFieldError.checkNotNull(
              requestId,
              r'DatabaseResponse',
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
          r'DatabaseResponse',
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

class _$DatabaseResultSet extends DatabaseResultSet {
  @override
  final BuiltList<String> columnNames;
  @override
  final int lastInsertRowId;
  @override
  final int updatedRows;
  @override
  final BuiltList<BuiltList<Object?>> rows;

  factory _$DatabaseResultSet([
    void Function(DatabaseResultSetBuilder)? updates,
  ]) => (DatabaseResultSetBuilder()..update(updates))._build();

  _$DatabaseResultSet._({
    required this.columnNames,
    required this.lastInsertRowId,
    required this.updatedRows,
    required this.rows,
  }) : super._();
  @override
  DatabaseResultSet rebuild(void Function(DatabaseResultSetBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DatabaseResultSetBuilder toBuilder() =>
      DatabaseResultSetBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DatabaseResultSet &&
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
    return (newBuiltValueToStringHelper(r'DatabaseResultSet')
          ..add('columnNames', columnNames)
          ..add('lastInsertRowId', lastInsertRowId)
          ..add('updatedRows', updatedRows)
          ..add('rows', rows))
        .toString();
  }
}

class DatabaseResultSetBuilder
    implements Builder<DatabaseResultSet, DatabaseResultSetBuilder> {
  _$DatabaseResultSet? _$v;

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

  DatabaseResultSetBuilder();

  DatabaseResultSetBuilder get _$this {
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
  void replace(DatabaseResultSet other) {
    _$v = other as _$DatabaseResultSet;
  }

  @override
  void update(void Function(DatabaseResultSetBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DatabaseResultSet build() => _build();

  _$DatabaseResultSet _build() {
    _$DatabaseResultSet _$result;
    try {
      _$result =
          _$v ??
          _$DatabaseResultSet._(
            columnNames: columnNames.build(),
            lastInsertRowId: BuiltValueNullFieldError.checkNotNull(
              lastInsertRowId,
              r'DatabaseResultSet',
              'lastInsertRowId',
            ),
            updatedRows: BuiltValueNullFieldError.checkNotNull(
              updatedRows,
              r'DatabaseResultSet',
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
          r'DatabaseResultSet',
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

class _$DatabaseError extends DatabaseError {
  @override
  final String error;
  @override
  final int? code;
  @override
  final StackTrace stackTrace;

  factory _$DatabaseError([void Function(DatabaseErrorBuilder)? updates]) =>
      (DatabaseErrorBuilder()..update(updates))._build();

  _$DatabaseError._({required this.error, this.code, required this.stackTrace})
    : super._();
  @override
  DatabaseError rebuild(void Function(DatabaseErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DatabaseErrorBuilder toBuilder() => DatabaseErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DatabaseError &&
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
    return (newBuiltValueToStringHelper(r'DatabaseError')
          ..add('error', error)
          ..add('code', code)
          ..add('stackTrace', stackTrace))
        .toString();
  }
}

class DatabaseErrorBuilder
    implements Builder<DatabaseError, DatabaseErrorBuilder> {
  _$DatabaseError? _$v;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  int? _code;
  int? get code => _$this._code;
  set code(int? code) => _$this._code = code;

  StackTrace? _stackTrace;
  StackTrace? get stackTrace => _$this._stackTrace;
  set stackTrace(StackTrace? stackTrace) => _$this._stackTrace = stackTrace;

  DatabaseErrorBuilder();

  DatabaseErrorBuilder get _$this {
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
  void replace(DatabaseError other) {
    _$v = other as _$DatabaseError;
  }

  @override
  void update(void Function(DatabaseErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DatabaseError build() => _build();

  _$DatabaseError _build() {
    final _$result =
        _$v ??
        _$DatabaseError._(
          error: BuiltValueNullFieldError.checkNotNull(
            error,
            r'DatabaseError',
            'error',
          ),
          code: code,
          stackTrace: BuiltValueNullFieldError.checkNotNull(
            stackTrace,
            r'DatabaseError',
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

/// The JS implementation of [DatabaseWorker].
class _$DatabaseWorker extends DatabaseWorker {
  @override
  String get name => 'DatabaseWorker';

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

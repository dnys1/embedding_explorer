// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_pool_worker.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DatabasePoolRequestType _$init = const DatabasePoolRequestType._('init');
const DatabasePoolRequestType _$exportDatabase =
    const DatabasePoolRequestType._('exportDatabase');
const DatabasePoolRequestType _$importDatabase =
    const DatabasePoolRequestType._('importDatabase');
const DatabasePoolRequestType _$deleteDatabase =
    const DatabasePoolRequestType._('deleteDatabase');
const DatabasePoolRequestType _$openDatabase = const DatabasePoolRequestType._(
  'openDatabase',
);
const DatabasePoolRequestType _$closeDatabase = const DatabasePoolRequestType._(
  'closeDatabase',
);
const DatabasePoolRequestType _$wipeAll = const DatabasePoolRequestType._(
  'wipeAll',
);
const DatabasePoolRequestType _$execute = const DatabasePoolRequestType._(
  'execute',
);
const DatabasePoolRequestType _$query = const DatabasePoolRequestType._(
  'query',
);
const DatabasePoolRequestType _$transaction = const DatabasePoolRequestType._(
  'transaction',
);

DatabasePoolRequestType _$valueOf(String name) {
  switch (name) {
    case 'init':
      return _$init;
    case 'exportDatabase':
      return _$exportDatabase;
    case 'importDatabase':
      return _$importDatabase;
    case 'deleteDatabase':
      return _$deleteDatabase;
    case 'openDatabase':
      return _$openDatabase;
    case 'closeDatabase':
      return _$closeDatabase;
    case 'wipeAll':
      return _$wipeAll;
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

final BuiltSet<DatabasePoolRequestType> _$values =
    BuiltSet<DatabasePoolRequestType>(const <DatabasePoolRequestType>[
      _$init,
      _$exportDatabase,
      _$importDatabase,
      _$deleteDatabase,
      _$openDatabase,
      _$closeDatabase,
      _$wipeAll,
      _$execute,
      _$query,
      _$transaction,
    ]);

Serializers _$_serializers =
    (Serializers().toBuilder()
          ..add(DatabasePoolError.serializer)
          ..add(DatabasePoolRequest.serializer)
          ..add(DatabasePoolRequestType.serializer)
          ..add(DatabasePoolResponse.serializer)
          ..add(DatabasePoolResultSet.serializer)
          ..add(DatabasePoolStats.serializer)
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
Serializer<DatabasePoolRequestType> _$databasePoolRequestTypeSerializer =
    _$DatabasePoolRequestTypeSerializer();
Serializer<DatabasePoolRequest> _$databasePoolRequestSerializer =
    _$DatabasePoolRequestSerializer();
Serializer<DatabasePoolResponse> _$databasePoolResponseSerializer =
    _$DatabasePoolResponseSerializer();
Serializer<DatabasePoolStats> _$databasePoolStatsSerializer =
    _$DatabasePoolStatsSerializer();
Serializer<DatabasePoolResultSet> _$databasePoolResultSetSerializer =
    _$DatabasePoolResultSetSerializer();
Serializer<DatabasePoolError> _$databasePoolErrorSerializer =
    _$DatabasePoolErrorSerializer();

class _$DatabasePoolRequestTypeSerializer
    implements PrimitiveSerializer<DatabasePoolRequestType> {
  @override
  final Iterable<Type> types = const <Type>[DatabasePoolRequestType];
  @override
  final String wireName = 'DatabasePoolRequestType';

  @override
  Object serialize(
    Serializers serializers,
    DatabasePoolRequestType object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  DatabasePoolRequestType deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DatabasePoolRequestType.valueOf(serialized as String);
}

class _$DatabasePoolRequestSerializer
    implements StructuredSerializer<DatabasePoolRequest> {
  @override
  final Iterable<Type> types = const [
    DatabasePoolRequest,
    _$DatabasePoolRequest,
  ];
  @override
  final String wireName = 'DatabasePoolRequest';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    DatabasePoolRequest object, {
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
        specifiedType: const FullType(DatabasePoolRequestType),
      ),
    ];
    Object? value;
    value = object.libsqlUri;
    if (value != null) {
      result
        ..add('libsqlUri')
        ..add(serializers.serialize(value, specifiedType: const FullType(Uri)));
    }
    value = object.databaseName;
    if (value != null) {
      result
        ..add('databaseName')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.transaction;
    if (value != null) {
      result
        ..add('transaction')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(Transaction),
          ),
        );
    }
    value = object.importData;
    if (value != null) {
      result
        ..add('importData')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(Uint8List),
          ),
        );
    }
    value = object.verbose;
    if (value != null) {
      result
        ..add('verbose')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(bool)),
        );
    }
    return result;
  }

  @override
  DatabasePoolRequest deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DatabasePoolRequestBuilder();

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
                    specifiedType: const FullType(DatabasePoolRequestType),
                  )!
                  as DatabasePoolRequestType;
          break;
        case 'libsqlUri':
          result.libsqlUri =
              serializers.deserialize(value, specifiedType: const FullType(Uri))
                  as Uri?;
          break;
        case 'databaseName':
          result.databaseName =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
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
        case 'importData':
          result.importData =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Uint8List),
                  )
                  as Uint8List?;
          break;
        case 'verbose':
          result.verbose =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool?;
          break;
      }
    }

    return result.build();
  }
}

class _$DatabasePoolResponseSerializer
    implements StructuredSerializer<DatabasePoolResponse> {
  @override
  final Iterable<Type> types = const [
    DatabasePoolResponse,
    _$DatabasePoolResponse,
  ];
  @override
  final String wireName = 'DatabasePoolResponse';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    DatabasePoolResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'requestId',
      serializers.serialize(
        object.requestId,
        specifiedType: const FullType(int),
      ),
      'stats',
      serializers.serialize(
        object.stats,
        specifiedType: const FullType(DatabasePoolStats),
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
            specifiedType: const FullType(DatabasePoolResultSet),
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
            specifiedType: const FullType(DatabasePoolError),
          ),
        );
    }
    return result;
  }

  @override
  DatabasePoolResponse deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DatabasePoolResponseBuilder();

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
        case 'stats':
          result.stats.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(DatabasePoolStats),
                )!
                as DatabasePoolStats,
          );
          break;
        case 'resultSet':
          result.resultSet.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(DatabasePoolResultSet),
                )!
                as DatabasePoolResultSet,
          );
          break;
        case 'error':
          result.error.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(DatabasePoolError),
                )!
                as DatabasePoolError,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$DatabasePoolStatsSerializer
    implements StructuredSerializer<DatabasePoolStats> {
  @override
  final Iterable<Type> types = const [DatabasePoolStats, _$DatabasePoolStats];
  @override
  final String wireName = 'DatabasePoolStats';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    DatabasePoolStats object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'databaseNames',
      serializers.serialize(
        object.databaseNames,
        specifiedType: const FullType(BuiltList, const [
          const FullType(String),
        ]),
      ),
      'reservedCapacity',
      serializers.serialize(
        object.reservedCapacity,
        specifiedType: const FullType(int),
      ),
      'fileCount',
      serializers.serialize(
        object.fileCount,
        specifiedType: const FullType(int),
      ),
      'vfsName',
      serializers.serialize(
        object.vfsName,
        specifiedType: const FullType(String),
      ),
    ];

    return result;
  }

  @override
  DatabasePoolStats deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DatabasePoolStatsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'databaseNames':
          result.databaseNames.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(String),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
        case 'reservedCapacity':
          result.reservedCapacity =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'fileCount':
          result.fileCount =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'vfsName':
          result.vfsName =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
      }
    }

    return result.build();
  }
}

class _$DatabasePoolResultSetSerializer
    implements StructuredSerializer<DatabasePoolResultSet> {
  @override
  final Iterable<Type> types = const [
    DatabasePoolResultSet,
    _$DatabasePoolResultSet,
  ];
  @override
  final String wireName = 'DatabasePoolResultSet';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    DatabasePoolResultSet object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[];
    Object? value;
    value = object.exportData;
    if (value != null) {
      result
        ..add('exportData')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(Uint8List),
          ),
        );
    }
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
    value = object.success;
    if (value != null) {
      result
        ..add('success')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(bool)),
        );
    }
    return result;
  }

  @override
  DatabasePoolResultSet deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DatabasePoolResultSetBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'exportData':
          result.exportData =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Uint8List),
                  )
                  as Uint8List?;
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
        case 'success':
          result.success =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool?;
          break;
      }
    }

    return result.build();
  }
}

class _$DatabasePoolErrorSerializer
    implements StructuredSerializer<DatabasePoolError> {
  @override
  final Iterable<Type> types = const [DatabasePoolError, _$DatabasePoolError];
  @override
  final String wireName = 'DatabasePoolError';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    DatabasePoolError object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'message',
      serializers.serialize(
        object.message,
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
  DatabasePoolError deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DatabasePoolErrorBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'message':
          result.message =
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

class _$DatabasePoolRequest extends DatabasePoolRequest {
  @override
  final int requestId;
  @override
  final DatabasePoolRequestType type;
  @override
  final Uri? libsqlUri;
  @override
  final String? databaseName;
  @override
  final Transaction? transaction;
  @override
  final Uint8List? importData;
  @override
  final bool? verbose;

  factory _$DatabasePoolRequest([
    void Function(DatabasePoolRequestBuilder)? updates,
  ]) => (DatabasePoolRequestBuilder()..update(updates))._build();

  _$DatabasePoolRequest._({
    required this.requestId,
    required this.type,
    this.libsqlUri,
    this.databaseName,
    this.transaction,
    this.importData,
    this.verbose,
  }) : super._();
  @override
  DatabasePoolRequest rebuild(
    void Function(DatabasePoolRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DatabasePoolRequestBuilder toBuilder() =>
      DatabasePoolRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DatabasePoolRequest &&
        requestId == other.requestId &&
        type == other.type &&
        libsqlUri == other.libsqlUri &&
        databaseName == other.databaseName &&
        transaction == other.transaction &&
        importData == other.importData &&
        verbose == other.verbose;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, libsqlUri.hashCode);
    _$hash = $jc(_$hash, databaseName.hashCode);
    _$hash = $jc(_$hash, transaction.hashCode);
    _$hash = $jc(_$hash, importData.hashCode);
    _$hash = $jc(_$hash, verbose.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DatabasePoolRequest')
          ..add('requestId', requestId)
          ..add('type', type)
          ..add('libsqlUri', libsqlUri)
          ..add('databaseName', databaseName)
          ..add('transaction', transaction)
          ..add('importData', importData)
          ..add('verbose', verbose))
        .toString();
  }
}

class DatabasePoolRequestBuilder
    implements Builder<DatabasePoolRequest, DatabasePoolRequestBuilder> {
  _$DatabasePoolRequest? _$v;

  int? _requestId;
  int? get requestId => _$this._requestId;
  set requestId(int? requestId) => _$this._requestId = requestId;

  DatabasePoolRequestType? _type;
  DatabasePoolRequestType? get type => _$this._type;
  set type(DatabasePoolRequestType? type) => _$this._type = type;

  Uri? _libsqlUri;
  Uri? get libsqlUri => _$this._libsqlUri;
  set libsqlUri(Uri? libsqlUri) => _$this._libsqlUri = libsqlUri;

  String? _databaseName;
  String? get databaseName => _$this._databaseName;
  set databaseName(String? databaseName) => _$this._databaseName = databaseName;

  TransactionBuilder? _transaction;
  TransactionBuilder get transaction =>
      _$this._transaction ??= TransactionBuilder();
  set transaction(TransactionBuilder? transaction) =>
      _$this._transaction = transaction;

  Uint8List? _importData;
  Uint8List? get importData => _$this._importData;
  set importData(Uint8List? importData) => _$this._importData = importData;

  bool? _verbose;
  bool? get verbose => _$this._verbose;
  set verbose(bool? verbose) => _$this._verbose = verbose;

  DatabasePoolRequestBuilder();

  DatabasePoolRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _type = $v.type;
      _libsqlUri = $v.libsqlUri;
      _databaseName = $v.databaseName;
      _transaction = $v.transaction?.toBuilder();
      _importData = $v.importData;
      _verbose = $v.verbose;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DatabasePoolRequest other) {
    _$v = other as _$DatabasePoolRequest;
  }

  @override
  void update(void Function(DatabasePoolRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DatabasePoolRequest build() => _build();

  _$DatabasePoolRequest _build() {
    _$DatabasePoolRequest _$result;
    try {
      _$result =
          _$v ??
          _$DatabasePoolRequest._(
            requestId: BuiltValueNullFieldError.checkNotNull(
              requestId,
              r'DatabasePoolRequest',
              'requestId',
            ),
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'DatabasePoolRequest',
              'type',
            ),
            libsqlUri: libsqlUri,
            databaseName: databaseName,
            transaction: _transaction?.build(),
            importData: importData,
            verbose: verbose,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'transaction';
        _transaction?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DatabasePoolRequest',
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

class _$DatabasePoolResponse extends DatabasePoolResponse {
  @override
  final int requestId;
  @override
  final DatabasePoolStats stats;
  @override
  final DatabasePoolResultSet? resultSet;
  @override
  final DatabasePoolError? error;

  factory _$DatabasePoolResponse([
    void Function(DatabasePoolResponseBuilder)? updates,
  ]) => (DatabasePoolResponseBuilder()..update(updates))._build();

  _$DatabasePoolResponse._({
    required this.requestId,
    required this.stats,
    this.resultSet,
    this.error,
  }) : super._();
  @override
  DatabasePoolResponse rebuild(
    void Function(DatabasePoolResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DatabasePoolResponseBuilder toBuilder() =>
      DatabasePoolResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DatabasePoolResponse &&
        requestId == other.requestId &&
        stats == other.stats &&
        resultSet == other.resultSet &&
        error == other.error;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, stats.hashCode);
    _$hash = $jc(_$hash, resultSet.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DatabasePoolResponse')
          ..add('requestId', requestId)
          ..add('stats', stats)
          ..add('resultSet', resultSet)
          ..add('error', error))
        .toString();
  }
}

class DatabasePoolResponseBuilder
    implements Builder<DatabasePoolResponse, DatabasePoolResponseBuilder> {
  _$DatabasePoolResponse? _$v;

  int? _requestId;
  int? get requestId => _$this._requestId;
  set requestId(int? requestId) => _$this._requestId = requestId;

  DatabasePoolStatsBuilder? _stats;
  DatabasePoolStatsBuilder get stats =>
      _$this._stats ??= DatabasePoolStatsBuilder();
  set stats(DatabasePoolStatsBuilder? stats) => _$this._stats = stats;

  DatabasePoolResultSetBuilder? _resultSet;
  DatabasePoolResultSetBuilder get resultSet =>
      _$this._resultSet ??= DatabasePoolResultSetBuilder();
  set resultSet(DatabasePoolResultSetBuilder? resultSet) =>
      _$this._resultSet = resultSet;

  DatabasePoolErrorBuilder? _error;
  DatabasePoolErrorBuilder get error =>
      _$this._error ??= DatabasePoolErrorBuilder();
  set error(DatabasePoolErrorBuilder? error) => _$this._error = error;

  DatabasePoolResponseBuilder();

  DatabasePoolResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _stats = $v.stats.toBuilder();
      _resultSet = $v.resultSet?.toBuilder();
      _error = $v.error?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DatabasePoolResponse other) {
    _$v = other as _$DatabasePoolResponse;
  }

  @override
  void update(void Function(DatabasePoolResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DatabasePoolResponse build() => _build();

  _$DatabasePoolResponse _build() {
    _$DatabasePoolResponse _$result;
    try {
      _$result =
          _$v ??
          _$DatabasePoolResponse._(
            requestId: BuiltValueNullFieldError.checkNotNull(
              requestId,
              r'DatabasePoolResponse',
              'requestId',
            ),
            stats: stats.build(),
            resultSet: _resultSet?.build(),
            error: _error?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'stats';
        stats.build();
        _$failedField = 'resultSet';
        _resultSet?.build();
        _$failedField = 'error';
        _error?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DatabasePoolResponse',
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

class _$DatabasePoolStats extends DatabasePoolStats {
  @override
  final BuiltList<String> databaseNames;
  @override
  final int reservedCapacity;
  @override
  final int fileCount;
  @override
  final String vfsName;

  factory _$DatabasePoolStats([
    void Function(DatabasePoolStatsBuilder)? updates,
  ]) => (DatabasePoolStatsBuilder()..update(updates))._build();

  _$DatabasePoolStats._({
    required this.databaseNames,
    required this.reservedCapacity,
    required this.fileCount,
    required this.vfsName,
  }) : super._();
  @override
  DatabasePoolStats rebuild(void Function(DatabasePoolStatsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DatabasePoolStatsBuilder toBuilder() =>
      DatabasePoolStatsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DatabasePoolStats &&
        databaseNames == other.databaseNames &&
        reservedCapacity == other.reservedCapacity &&
        fileCount == other.fileCount &&
        vfsName == other.vfsName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, databaseNames.hashCode);
    _$hash = $jc(_$hash, reservedCapacity.hashCode);
    _$hash = $jc(_$hash, fileCount.hashCode);
    _$hash = $jc(_$hash, vfsName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DatabasePoolStats')
          ..add('databaseNames', databaseNames)
          ..add('reservedCapacity', reservedCapacity)
          ..add('fileCount', fileCount)
          ..add('vfsName', vfsName))
        .toString();
  }
}

class DatabasePoolStatsBuilder
    implements Builder<DatabasePoolStats, DatabasePoolStatsBuilder> {
  _$DatabasePoolStats? _$v;

  ListBuilder<String>? _databaseNames;
  ListBuilder<String> get databaseNames =>
      _$this._databaseNames ??= ListBuilder<String>();
  set databaseNames(ListBuilder<String>? databaseNames) =>
      _$this._databaseNames = databaseNames;

  int? _reservedCapacity;
  int? get reservedCapacity => _$this._reservedCapacity;
  set reservedCapacity(int? reservedCapacity) =>
      _$this._reservedCapacity = reservedCapacity;

  int? _fileCount;
  int? get fileCount => _$this._fileCount;
  set fileCount(int? fileCount) => _$this._fileCount = fileCount;

  String? _vfsName;
  String? get vfsName => _$this._vfsName;
  set vfsName(String? vfsName) => _$this._vfsName = vfsName;

  DatabasePoolStatsBuilder();

  DatabasePoolStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _databaseNames = $v.databaseNames.toBuilder();
      _reservedCapacity = $v.reservedCapacity;
      _fileCount = $v.fileCount;
      _vfsName = $v.vfsName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DatabasePoolStats other) {
    _$v = other as _$DatabasePoolStats;
  }

  @override
  void update(void Function(DatabasePoolStatsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DatabasePoolStats build() => _build();

  _$DatabasePoolStats _build() {
    _$DatabasePoolStats _$result;
    try {
      _$result =
          _$v ??
          _$DatabasePoolStats._(
            databaseNames: databaseNames.build(),
            reservedCapacity: BuiltValueNullFieldError.checkNotNull(
              reservedCapacity,
              r'DatabasePoolStats',
              'reservedCapacity',
            ),
            fileCount: BuiltValueNullFieldError.checkNotNull(
              fileCount,
              r'DatabasePoolStats',
              'fileCount',
            ),
            vfsName: BuiltValueNullFieldError.checkNotNull(
              vfsName,
              r'DatabasePoolStats',
              'vfsName',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'databaseNames';
        databaseNames.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DatabasePoolStats',
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

class _$DatabasePoolResultSet extends DatabasePoolResultSet {
  @override
  final Uint8List? exportData;
  @override
  final LibsqlResultSet? resultSet;
  @override
  final bool? success;

  factory _$DatabasePoolResultSet([
    void Function(DatabasePoolResultSetBuilder)? updates,
  ]) => (DatabasePoolResultSetBuilder()..update(updates))._build();

  _$DatabasePoolResultSet._({this.exportData, this.resultSet, this.success})
    : super._();
  @override
  DatabasePoolResultSet rebuild(
    void Function(DatabasePoolResultSetBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DatabasePoolResultSetBuilder toBuilder() =>
      DatabasePoolResultSetBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DatabasePoolResultSet &&
        exportData == other.exportData &&
        resultSet == other.resultSet &&
        success == other.success;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, exportData.hashCode);
    _$hash = $jc(_$hash, resultSet.hashCode);
    _$hash = $jc(_$hash, success.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DatabasePoolResultSet')
          ..add('exportData', exportData)
          ..add('resultSet', resultSet)
          ..add('success', success))
        .toString();
  }
}

class DatabasePoolResultSetBuilder
    implements Builder<DatabasePoolResultSet, DatabasePoolResultSetBuilder> {
  _$DatabasePoolResultSet? _$v;

  Uint8List? _exportData;
  Uint8List? get exportData => _$this._exportData;
  set exportData(Uint8List? exportData) => _$this._exportData = exportData;

  LibsqlResultSetBuilder? _resultSet;
  LibsqlResultSetBuilder get resultSet =>
      _$this._resultSet ??= LibsqlResultSetBuilder();
  set resultSet(LibsqlResultSetBuilder? resultSet) =>
      _$this._resultSet = resultSet;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  DatabasePoolResultSetBuilder();

  DatabasePoolResultSetBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _exportData = $v.exportData;
      _resultSet = $v.resultSet?.toBuilder();
      _success = $v.success;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DatabasePoolResultSet other) {
    _$v = other as _$DatabasePoolResultSet;
  }

  @override
  void update(void Function(DatabasePoolResultSetBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DatabasePoolResultSet build() => _build();

  _$DatabasePoolResultSet _build() {
    _$DatabasePoolResultSet _$result;
    try {
      _$result =
          _$v ??
          _$DatabasePoolResultSet._(
            exportData: exportData,
            resultSet: _resultSet?.build(),
            success: success,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'resultSet';
        _resultSet?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DatabasePoolResultSet',
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

class _$DatabasePoolError extends DatabasePoolError {
  @override
  final String message;
  @override
  final StackTrace stackTrace;

  factory _$DatabasePoolError([
    void Function(DatabasePoolErrorBuilder)? updates,
  ]) => (DatabasePoolErrorBuilder()..update(updates))._build();

  _$DatabasePoolError._({required this.message, required this.stackTrace})
    : super._();
  @override
  DatabasePoolError rebuild(void Function(DatabasePoolErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DatabasePoolErrorBuilder toBuilder() =>
      DatabasePoolErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DatabasePoolError &&
        message == other.message &&
        stackTrace == other.stackTrace;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, stackTrace.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DatabasePoolError')
          ..add('message', message)
          ..add('stackTrace', stackTrace))
        .toString();
  }
}

class DatabasePoolErrorBuilder
    implements Builder<DatabasePoolError, DatabasePoolErrorBuilder> {
  _$DatabasePoolError? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  StackTrace? _stackTrace;
  StackTrace? get stackTrace => _$this._stackTrace;
  set stackTrace(StackTrace? stackTrace) => _$this._stackTrace = stackTrace;

  DatabasePoolErrorBuilder();

  DatabasePoolErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _stackTrace = $v.stackTrace;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DatabasePoolError other) {
    _$v = other as _$DatabasePoolError;
  }

  @override
  void update(void Function(DatabasePoolErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DatabasePoolError build() => _build();

  _$DatabasePoolError _build() {
    final _$result =
        _$v ??
        _$DatabasePoolError._(
          message: BuiltValueNullFieldError.checkNotNull(
            message,
            r'DatabasePoolError',
            'message',
          ),
          stackTrace: BuiltValueNullFieldError.checkNotNull(
            stackTrace,
            r'DatabasePoolError',
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

/// The JS implementation of [DatabasePoolWorker].
class _$DatabasePoolWorker extends DatabasePoolWorker {
  @override
  String get name => 'DatabasePoolWorker';

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

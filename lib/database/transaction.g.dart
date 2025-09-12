// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Transaction> _$transactionSerializer = _$TransactionSerializer();
Serializer<SqlStatement> _$sqlStatementSerializer = _$SqlStatementSerializer();

class _$TransactionSerializer implements StructuredSerializer<Transaction> {
  @override
  final Iterable<Type> types = const [Transaction, _$Transaction];
  @override
  final String wireName = 'Transaction';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    Transaction object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'statements',
      serializers.serialize(
        object.statements,
        specifiedType: const FullType(BuiltList, const [
          const FullType(SqlStatement),
        ]),
      ),
    ];

    return result;
  }

  @override
  Transaction deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TransactionBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'statements':
          result.statements.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(SqlStatement),
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

class _$SqlStatementSerializer implements StructuredSerializer<SqlStatement> {
  @override
  final Iterable<Type> types = const [SqlStatement, _$SqlStatement];
  @override
  final String wireName = 'SqlStatement';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    SqlStatement object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
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

    return result;
  }

  @override
  SqlStatement deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SqlStatementBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
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
      }
    }

    return result.build();
  }
}

class _$Transaction extends Transaction {
  @override
  final BuiltList<SqlStatement> statements;

  factory _$Transaction([void Function(TransactionBuilder)? updates]) =>
      (TransactionBuilder()..update(updates))._build();

  _$Transaction._({required this.statements}) : super._();
  @override
  Transaction rebuild(void Function(TransactionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TransactionBuilder toBuilder() => TransactionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Transaction && statements == other.statements;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, statements.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'Transaction',
    )..add('statements', statements)).toString();
  }
}

class TransactionBuilder implements Builder<Transaction, TransactionBuilder> {
  _$Transaction? _$v;

  ListBuilder<SqlStatement>? _statements;
  ListBuilder<SqlStatement> get statements =>
      _$this._statements ??= ListBuilder<SqlStatement>();
  set statements(ListBuilder<SqlStatement>? statements) =>
      _$this._statements = statements;

  TransactionBuilder();

  TransactionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _statements = $v.statements.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Transaction other) {
    _$v = other as _$Transaction;
  }

  @override
  void update(void Function(TransactionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Transaction build() => _build();

  _$Transaction _build() {
    _$Transaction _$result;
    try {
      _$result = _$v ?? _$Transaction._(statements: statements.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'statements';
        statements.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'Transaction',
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

class _$SqlStatement extends SqlStatement {
  @override
  final String sql;
  @override
  final BuiltList<Object?> parameters;

  factory _$SqlStatement([void Function(SqlStatementBuilder)? updates]) =>
      (SqlStatementBuilder()..update(updates))._build();

  _$SqlStatement._({required this.sql, required this.parameters}) : super._();
  @override
  SqlStatement rebuild(void Function(SqlStatementBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SqlStatementBuilder toBuilder() => SqlStatementBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SqlStatement &&
        sql == other.sql &&
        parameters == other.parameters;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sql.hashCode);
    _$hash = $jc(_$hash, parameters.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SqlStatement')
          ..add('sql', sql)
          ..add('parameters', parameters))
        .toString();
  }
}

class SqlStatementBuilder
    implements Builder<SqlStatement, SqlStatementBuilder> {
  _$SqlStatement? _$v;

  String? _sql;
  String? get sql => _$this._sql;
  set sql(String? sql) => _$this._sql = sql;

  ListBuilder<Object?>? _parameters;
  ListBuilder<Object?> get parameters =>
      _$this._parameters ??= ListBuilder<Object?>();
  set parameters(ListBuilder<Object?>? parameters) =>
      _$this._parameters = parameters;

  SqlStatementBuilder();

  SqlStatementBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sql = $v.sql;
      _parameters = $v.parameters.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SqlStatement other) {
    _$v = other as _$SqlStatement;
  }

  @override
  void update(void Function(SqlStatementBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SqlStatement build() => _build();

  _$SqlStatement _build() {
    _$SqlStatement _$result;
    try {
      _$result =
          _$v ??
          _$SqlStatement._(
            sql: BuiltValueNullFieldError.checkNotNull(
              sql,
              r'SqlStatement',
              'sql',
            ),
            parameters: parameters.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'parameters';
        parameters.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SqlStatement',
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

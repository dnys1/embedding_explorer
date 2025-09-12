import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transaction.g.dart';

/// Represents a database transaction as a list of SQL statements to execute
abstract class Transaction implements Built<Transaction, TransactionBuilder> {
  /// Create a transaction with a list of statements
  factory Transaction(List<SqlStatement> statements) {
    return Transaction.build((b) => b..statements.replace(statements));
  }

  static final Transaction empty = Transaction([]);

  /// The list of SQL statements to execute in this transaction
  BuiltList<SqlStatement> get statements;

  Transaction._();

  factory Transaction.build([void Function(TransactionBuilder) updates]) =
      _$Transaction;

  static Serializer<Transaction> get serializer => _$transactionSerializer;
}

/// Represents a single SQL statement with optional parameters
abstract class SqlStatement
    implements Built<SqlStatement, SqlStatementBuilder> {
  /// Create a statement with SQL and parameters
  factory SqlStatement(String sql, [List<Object?>? parameters]) {
    return SqlStatement.build(
      (b) => b
        ..sql = sql
        ..parameters.replace(parameters ?? []),
    );
  }

  /// The SQL query to execute
  String get sql;

  /// Optional parameters for the SQL query
  BuiltList<Object?> get parameters;

  SqlStatement._();

  factory SqlStatement.build([void Function(SqlStatementBuilder) updates]) =
      _$SqlStatement;

  static Serializer<SqlStatement> get serializer => _$sqlStatementSerializer;
}

import 'package:sqlparser/sqlparser.dart';
import 'package:sqlparser/utils/node_to_text.dart';

/// A database migration consisting of a [version] and `up` and `down`
/// migrations.
class Migration {
  Migration({
    required this.version,
    required this.upStatements,
    this.downStatements = const [],
  });

  /// The version number of this migration.
  final int version;

  /// The SQL statements to be executed for this migration.
  final List<String> upStatements;

  /// The SQL statements to be executed to revert this migration.
  final List<String> downStatements;

  static final SqlEngine _engine = SqlEngine(
    EngineOptions(
      version: SqliteVersion.current,
      enabledExtensions: [Json1Extension(), Fts5Extension()],
    ),
  );

  static List<String> _parseSql(String sql) {
    sql = sql.trim();
    if (sql.isEmpty) {
      return const [];
    }

    final ParseResult result;
    if (sql.allMatches(';').length == 1) {
      result = _engine.parse(sql);
    } else {
      result = _engine.parseMultiple(sql);
    }
    if (result.errors.isNotEmpty) {
      throw ArgumentError.value(
        sql,
        'sql',
        'Could not parse SQL string:\n${result.errors.join('\n')}',
      );
    }
    return result.rootNode.childNodes.map((s) => s.toSql()).toList();
  }

  /// Creates a [Migration] by parsing the provided [sql] string.
  ///
  /// The [sql] string is considered an "up" migration.
  factory Migration.fromStrings({
    required String up,
    String? down,
    int version = -1,
  }) {
    return Migration(
      version: version,
      upStatements: _parseSql(up),
      downStatements: down != null ? _parseSql(down) : const [],
    );
  }
}

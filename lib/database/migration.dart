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

  static List<String> _parseSql(String sql) {
    return sql
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
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

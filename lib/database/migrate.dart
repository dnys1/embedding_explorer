import 'package:logging/logging.dart';

import 'database.dart';
import 'migration.dart';

class Migrate {
  factory Migrate({required List<Migration> migrations, Logger? logger}) {
    final sortedMigrations = List.of(migrations)
      ..sort((a, b) => a.version.compareTo(b.version));
    for (var i = 1; i <= sortedMigrations.length; i++) {
      final migration = sortedMigrations[i - 1];
      if (migration.version != i) {
        throw ArgumentError.value(
          migrations,
          'migrations',
          'Migrations must be sequential and start at version 1. '
              'Expected version $i but found ${migration.version}.',
        );
      }
    }

    return Migrate._(migrations: sortedMigrations, logger: logger);
  }

  Migrate._({required this.migrations, this.logger});

  /// The ordered list of migrations to be applied.
  final List<Migration> migrations;

  /// Optional logger for migration operations.
  /// If not provided, migration messages will not be logged.
  final Logger? logger;

  /// Ensures the migrations table exists in the database.
  /// Creates a table to track which migrations have been applied.
  Future<void> _ensureMigrationsTable(Database database) async {
    database.execute('''
        CREATE TABLE IF NOT EXISTS schema_migrations (
          version INTEGER PRIMARY KEY,
          applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
  }

  /// Gets the current database schema version by finding the highest
  /// version number in the migrations table.
  /// Returns 0 if no migrations have been applied yet.
  Future<int> getCurrentVersion(Database database) async {
    await _ensureMigrationsTable(database);

    final result = await database.select(
      'SELECT COALESCE(MAX(version), 0) as current_version FROM schema_migrations',
    );

    if (result.rows.isEmpty) {
      return 0;
    }

    return result.rows.first[0] as int;
  }

  /// Applies pending migrations to the database up to the specified version.
  /// Runs each migration in a transaction and records successful applications
  /// in the schema_migrations table.
  ///
  /// If [to] is specified, only migrations up to that version will be applied.
  /// If [to] is null, all pending migrations will be applied.
  /// If [to] is less than the current version, no migrations will be applied.
  Future<void> up(Database database, {int? to}) async {
    final currentVersion = await getCurrentVersion(database);

    // Determine the target version
    final targetVersion =
        to ?? (migrations.isNotEmpty ? migrations.last.version : 0);

    // Validate target version
    if (to != null && to < currentVersion) {
      logger?.warning(
        'Target version $to is less than current version $currentVersion. No migrations will be applied.',
      );
      return;
    }

    // Filter migrations that need to be applied
    final pendingMigrations = migrations
        .where(
          (migration) =>
              migration.version > currentVersion &&
              migration.version <= targetVersion,
        )
        .toList();

    if (pendingMigrations.isEmpty) {
      if (currentVersion == targetVersion) {
        logger?.info('Database is already at version $targetVersion.');
      } else {
        logger?.info('No migrations to apply.');
      }
      return;
    }

    logger?.info(
      'Migrating from version $currentVersion to version $targetVersion...',
    );

    for (final migration in pendingMigrations) {
      await database.transaction((tx) {
        // Run each migration in a batch (transaction-like behavior)
        // Execute all statements in the migration
        for (final statement in migration.upStatements) {
          tx.execute(statement);
        }

        // Record that this migration was applied
        tx.execute('INSERT INTO schema_migrations (version) VALUES (?)', [
          migration.version,
        ]);
      });
      logger?.info('Applied migration ${migration.version}');
    }

    logger?.info(
      'Migration complete. Database is now at version $targetVersion.',
    );
  }

  /// Rolls back migrations from the current version down to the specified version.
  /// Runs each rollback migration in a transaction and removes records from
  /// the schema_migrations table.
  ///
  /// If [to] is specified, migrations will be rolled back to that version.
  /// If [to] is null, only the most recent migration will be rolled back.
  /// If [to] is greater than or equal to the current version, no rollbacks will be performed.
  Future<void> down(Database database, {int? to}) async {
    final currentVersion = await getCurrentVersion(database);

    if (currentVersion == 0) {
      logger?.info('No migrations to roll back. Database is at version 0.');
      return;
    }

    // Determine the target version (default to rolling back one migration)
    final targetVersion = to ?? (currentVersion - 1);

    // Validate target version
    if (targetVersion >= currentVersion) {
      logger?.warning(
        'Target version $targetVersion is not less than current version $currentVersion. No rollbacks will be performed.',
      );
      return;
    }

    if (targetVersion < 0) {
      logger?.warning(
        'Target version $targetVersion is invalid. Must be >= 0.',
      );
      return;
    }

    // Get migrations that need to be rolled back (in reverse order)
    final migrationsToRollback =
        migrations
            .where(
              (migration) =>
                  migration.version > targetVersion &&
                  migration.version <= currentVersion,
            )
            .toList()
          ..sort((a, b) => b.version.compareTo(a.version)); // Reverse order

    if (migrationsToRollback.isEmpty) {
      logger?.info(
        'No migrations found to roll back from version $currentVersion to version $targetVersion.',
      );
      return;
    }

    logger?.info(
      'Rolling back from version $currentVersion to version $targetVersion...',
    );

    for (final migration in migrationsToRollback) {
      if (migration.downStatements.isEmpty) {
        throw StateError(
          'Migration ${migration.version} has no down statements. Cannot roll back.',
        );
      }

      await database.transaction((tx) {
        // Execute all down statements in the migration
        for (final statement in migration.downStatements) {
          tx.execute(statement);
        }

        // Remove the migration record
        tx.execute('DELETE FROM schema_migrations WHERE version = ?', [
          migration.version,
        ]);
      });
      logger?.info('Rolled back migration ${migration.version}');
    }

    logger?.info(
      'Rollback complete. Database is now at version $targetVersion.',
    );
  }
}

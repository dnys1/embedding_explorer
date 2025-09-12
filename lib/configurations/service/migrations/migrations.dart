import '../../../database/migration.dart';
import '001_init.dart' as _001;
import '002_embedding_tables.dart' as _002;

final List<Migration> configMigrations = [_001.migration, _002.migration];

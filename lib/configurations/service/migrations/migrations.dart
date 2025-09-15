import '../../../database/migration.dart';
import '001_init.dart' as _001;
import '002_embedding_tables.dart' as _002;
import '003_job_orchestration.dart' as _003;

final List<Migration> configMigrations = [
  _001.migration,
  _002.migration,
  _003.migration,
];

import '../../database/migration.dart';
import 'migrations/001_init.dart' as _001;

final List<Migration> allMigrations = [_001.migration];

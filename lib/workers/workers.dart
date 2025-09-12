import 'package:worker_bee/worker_bee.dart';

import 'indexed_db_worker.dart';
import 'libsql_worker.dart';

final _workers = <String, WorkerBeeBuilder>{
  'IndexedDbWorker': IndexedDbWorker.create,
  'LibsqlWorker': LibsqlWorker.create,
};
void main() => runHive(_workers);

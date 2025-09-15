import 'package:worker_bee/worker_bee.dart';

import 'database_pool_worker.dart';
import 'database_worker.dart';
import 'indexed_db_worker.dart';
import 'opfs_worker.dart';

final _workers = <String, WorkerBeeBuilder>{
  'IndexedDbWorker': IndexedDbWorker.create,
  'DatabasePoolWorker': DatabasePoolWorker.create,
  'DatabaseWorker': DatabaseWorker.create,
  'OpfsWorker': OpfsWorker.create,
};
void main() => runHive(_workers);

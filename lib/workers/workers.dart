import 'indexed_db_worker.dart';
import 'package:worker_bee/worker_bee.dart';

final _workers = <String, WorkerBeeBuilder>{
  'IndexedDbWorker': IndexedDbWorker.create,
};
void main() => runHive(_workers);

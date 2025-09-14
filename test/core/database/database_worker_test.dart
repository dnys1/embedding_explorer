@TestOn('browser')
library;

import 'package:embeddings_explorer/database/database.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  setupTests();

  group('DatabaseWorker', () {
    group('basic functionality', () {
      for (final filename in [':memory:', 'test.db']) {
        group(filename, () {
          test('can spawn', () async {
            final worker = await Database.worker(
              filename: filename,
              libsqlUri: testLibsqlUri,
            );
            await worker.close();
          });
        });
      }
    });
  });
}

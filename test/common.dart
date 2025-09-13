import 'package:embeddings_explorer/util/logging.dart';
import 'package:logging/logging.dart';

void setupTests() {
  configureLogging(level: Level.ALL);
}

Uri get testLibsqlUri => Uri.parse(
  'https://unpkg.com/@libsql/libsql-wasm-experimental@0.0.3/index.mjs',
);

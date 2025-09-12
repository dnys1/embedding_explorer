import 'dart:js_interop';

import 'package:logging/logging.dart';
import 'package:web/web.dart';

void setupTests() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final buffer = StringBuffer();
    buffer.write('[${record.loggerName}]: ${record.message}');
    if (record.error case final error?) {
      buffer
        ..writeln()
        ..write('Error: $error');
    }
    if (record.stackTrace case final stackTrace?) {
      buffer
        ..writeln()
        ..write('StackTrace: $stackTrace');
    }
    final message = buffer.toString().toJS;
    print(message);
    switch (record.level) {
      case Level.SEVERE || Level.SHOUT:
        console.error(message);
      case Level.WARNING:
        console.warn(message);
      case Level.CONFIG || Level.INFO:
        console.info(message);
      case Level.FINE || Level.FINER || Level.FINEST:
        console.debug(message);
    }
  });
}

Uri get testLibsqlUri => Uri.parse(
  'https://unpkg.com/@libsql/libsql-wasm-experimental@0.0.3/index.mjs',
);

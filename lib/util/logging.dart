import 'dart:async';
import 'dart:js_interop';

import 'package:logging/logging.dart';
import 'package:web/web.dart';

StreamSubscription<LogRecord> configureLogging({
  required Level level,
  bool isTest = false,
}) {
  Logger.root.level = level;
  return Logger.root.onRecord.listen((record) {
    final buffer = StringBuffer();
    buffer.write('[${record.loggerName}]: ${record.message}');
    if (record.error case final error?) {
      buffer
        ..writeln()
        ..write(error);
    }
    if (record.stackTrace case final stackTrace? when level == Level.ALL) {
      buffer
        ..writeln()
        ..write(stackTrace);
    }
    final message = buffer.toString().toJS;
    if (isTest) {
      // Print to console in tests so that logs show in CLI output.
      print(message);
    }
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

import 'package:embeddings_explorer/app.dart';
import 'package:embeddings_explorer/interop/common.dart';
import 'package:jaspr/browser.dart';
import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:web/web.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
      '[${record.time} - ${record.loggerName}] '
      '${record.level.name}: ${record.message}',
    );
    if (record.error case final error?) {
      final message = error.toString();
      final jsError = switch (record.stackTrace) {
        final StackTrace stackTrace => () {
          final trace = Trace.from(stackTrace);
          return JSError.at(
            message,
            trace.frames.first.uri.toString(),
            trace.frames.first.line,
          );
        }(),
        _ => JSError(message),
      };
      console.error(jsError);
    }
  });

  runApp(App());
}

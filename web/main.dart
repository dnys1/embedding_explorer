import 'dart:js_interop';

import 'package:embeddings_explorer/app.dart';
import 'package:embeddings_explorer/util/logging.dart';
import 'package:jaspr/browser.dart';
import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:web/web.dart';

void main() {
  Chain.capture(
    when: kDebugMode,
    () {
      configureLogging(level: kDebugMode ? Level.ALL : Level.INFO);
      runApp(App());
    },
    onError: (error, stack) {
      // TODO: add Sentry
      console.error('Uncaught error: $error\n$stack'.toJS);
    },
  );
}

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Waits for an element with the given [id] to appear in the DOM.
///
/// Returns a [Future] that completes with the element when it appears,
/// or completes with an error if the [timeout] is reached.
///
/// Uses [MutationObserver] for efficient DOM watching when available,
/// falls back to polling every 100ms otherwise.
Future<T> waitForElement<T extends web.Element>(
  String id, {
  Duration timeout = const Duration(seconds: 1),
}) async {
  // Check if element already exists
  final existing = web.document.getElementById(id);
  if (existing != null) {
    return existing as T;
  }

  final completer = Completer<T>();

  // Set up timeout
  Timer? timeoutTimer;
  if (timeout != Duration.zero) {
    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException(
            'Element with id "$id" not found within $timeout',
            timeout,
          ),
        );
      }
    });
  }

  web.MutationObserver? observer;
  Timer? pollTimer;

  void cleanup() {
    timeoutTimer?.cancel();
    observer?.disconnect();
    pollTimer?.cancel();
  }

  // Try using MutationObserver for efficient DOM watching
  try {
    observer = web.MutationObserver(
      (JSArray<web.MutationRecord> mutations, web.MutationObserver observer) {
        final element = web.document.getElementById(id);
        if (element != null && !completer.isCompleted) {
          cleanup();
          completer.complete(element as T);
        }
      }.toJS,
    );

    observer.observe(
      web.document,
      web.MutationObserverInit(childList: true, subtree: true),
    );
  } catch (e) {
    // Fallback to polling if MutationObserver fails
    pollTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final element = web.document.getElementById(id);
      if (element != null && !completer.isCompleted) {
        cleanup();
        completer.complete(element as T);
      }
    });
  }

  return completer.future;
}

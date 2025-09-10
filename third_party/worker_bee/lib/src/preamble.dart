// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:aws_common/aws_common.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:source_map_stack_trace/source_map_stack_trace.dart';
import 'package:source_maps/parser.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:worker_bee/src/exception/worker_bee_exception.dart';
import 'package:worker_bee/worker_bee.dart';

export 'vm/preamble.dart' if (dart.library.js_interop) 'js/preamble.dart';

/// {@template worker_bee.worker_assignment}
/// The worker bee assignment sent from the main thread.
/// {@endtemplate}
class WorkerAssignment {
  /// {@macro worker_bee.worker_assignment}
  const WorkerAssignment(this.role, this.logsChannel);

  /// The name of the worker bee to be spawned.
  final String role;

  /// The log channel to communicate over.
  final StreamChannel<LogRecord> logsChannel;
}

/// Factory for a worker bee.
typedef WorkerBeeBuilder<W extends WorkerBeeBase<Object, dynamic>> =
    W Function();

/// Initializes worker bees by checking if running in a web worker, and awaiting
/// the assigned role if so.
///
/// This only needs to be used when targeting Web. It is a no-op on VM.
Future<void> runHive(
  Map<String, WorkerBeeBuilder> workers, [
  FutureOr<void> Function()? runApp,
]) async {
  if (isWebWorker) {
    final assignment = await getWorkerAssignment();
    final worker = workers[assignment.role];
    if (worker == null) {
      throw StateError('No worker found for role: $assignment');
    }
    await worker().connect(logsChannel: assignment.logsChannel);
  } else {
    await runApp?.call();
  }
}

/// Runs [action] in an error zone and automatically handles serialization
/// of unhandled errors.
@internal
R runTraced<R>(
  R Function() action, {
  required void Function(WorkerBeeException, StackTrace) onError,
}) {
  // Since this could be called from within a worker, e.g. in the case
  // of a worker pool, any uncaught errors lose visibility when they're
  // reported back _unless_ we serialize them first.
  Future<void> wrappedOnError(Object error, StackTrace stackTrace) async {
    if (isWebWorker) {
      if (_cachedSourceMap == null) {
        final sourceMapUri = p.url.setExtension(
          currentUri.toString(),
          '.js.map',
        );
        final sourceMapText = await http.get(Uri.parse(sourceMapUri)).then((
          res,
        ) {
          if (res.statusCode != 200) {
            return null;
          }
          return res.body;
        });

        if (sourceMapText != null) {
          _cachedSourceMap = parse(sourceMapText, mapUrl: sourceMapUri);
        }
      }
      if (_cachedSourceMap case final sourceMap?) {
        stackTrace = mapStackTrace(
          sourceMap,
          stackTrace,
          minified: zReleaseMode,
        );
      }
    }
    final trace = stackTrace is Trace ? stackTrace : Trace.from(stackTrace);
    final workerException = error is WorkerBeeException
        ? error.rebuild((b) => b.stackTrace = trace)
        : WorkerBeeExceptionImpl(error, trace);
    onError(workerException, trace);
  }

  if (zDebugMode) {
    return Chain.capture(action, onError: wrappedOnError);
  }
  return runZonedGuarded(action, wrappedOnError) as R;
}

Mapping? _cachedSourceMap;

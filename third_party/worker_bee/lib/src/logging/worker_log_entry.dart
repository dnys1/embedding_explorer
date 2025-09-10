// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:logging/logging.dart';

/// {@template worker_bee.worker_log_entry}
/// A [LogRecord] emitted by a worker bee.
/// {@endtemplate}
class WorkerLogRecord extends LogRecord {
  /// {@macro worker_bee.worker_log_entry}
  WorkerLogRecord(
    super.level,
    super.message,
    super.loggerName,
    super.error,
    super.stackTrace, {
    required this.time,
    required this.local,
  });

  /// Creates a [WorkerLogRecord] by wrapping [entry].
  WorkerLogRecord.from(LogRecord entry, {bool? local, DateTime? time})
    : this(
        entry.level,
        entry.message,
        entry.loggerName,
        entry.error,
        entry.stackTrace,
        local: local,
        time: time ?? entry.time,
      );

  @override
  // ignore: overridden_fields
  final DateTime time;

  /// Whether the log was emitted locally or in a worker.
  final bool? local;
}

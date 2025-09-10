// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

@internal
library;

import 'package:built_value/serializer.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:worker_bee/worker_bee.dart';

/// {@template worker_bee.log_entry_serializer}
/// Serializer for [LogRecord] and [WorkerLogRecord].
/// {@endtemplate}
class LogRecordSerializer implements StructuredSerializer<LogRecord> {
  /// {@macro worker_bee.log_entry_serializer}
  const LogRecordSerializer();

  @override
  Iterable<Type> get types => const [LogRecord, WorkerLogRecord];

  @override
  String get wireName => 'LogRecord';

  @override
  LogRecord deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    late Level level;
    late String message;
    late String loggerName;
    late DateTime time;
    Object? error;
    StackTrace? stackTrace;
    bool? local;
    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final value = iterator.current;
      switch (key) {
        case 'level':
          level = Level.LEVELS.firstWhere((e) => e.name == value as String);
        case 'message':
          message = value as String;
        case 'loggerName':
          loggerName = value as String;
        case 'time':
          time =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
        case 'error':
          error = value?.toString();
        case 'stackTrace':
          stackTrace =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(StackTrace),
                  )
                  as StackTrace;
        case 'local':
          local = value as bool;
      }
    }

    final entry = LogRecord(level, message, loggerName, error, stackTrace);
    if (local != null) {
      return WorkerLogRecord.from(entry, local: local, time: time);
    }
    return entry;
  }

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    LogRecord object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return [
      'level',
      object.level.name,
      'message',
      object.message,
      'loggerName',
      object.loggerName,
      'time',
      serializers.serialize(
        object.time.toUtc(),
        specifiedType: const FullType(DateTime),
      ),
      if (object.error != null) ...['error', object.error.toString()],
      if (object.stackTrace != null) ...[
        'stackTrace',
        serializers.serialize(
          object.stackTrace,
          specifiedType: const FullType(StackTrace),
        ),
      ],
      if (object is WorkerLogRecord) ...['local', object.local],
    ];
  }
}

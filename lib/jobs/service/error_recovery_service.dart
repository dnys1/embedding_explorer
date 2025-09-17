import 'dart:async';
import 'dart:math' as math;

import 'package:async/async.dart';
import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';

import '../../util/retryable_exception.dart';

/// Result of a retry operation
class RetryResult<T> {
  const RetryResult({
    required this.result,
    this.allErrors = const [],
    required this.attemptCount,
    required this.totalDuration,
  });

  final Result<T> result;
  final List<Object> allErrors;
  final int attemptCount;
  final Duration totalDuration;

  T unwrap() {
    if (result.isValue) {
      return result.asValue!.value;
    } else {
      final stackTrace = Chain([
        Trace.current(),
        Trace.from(result.asError!.stackTrace),
      ]);
      Error.throwWithStackTrace(result.asError!.error, stackTrace);
    }
  }

  bool get success => result.isValue;
}

/// Simple service for handling retryable exceptions
class ErrorRecoveryService {
  static final Logger _logger = Logger('ErrorRecoveryService');

  final _random = math.Random();

  /// Execute an operation with retry logic for RetryableExceptions
  Future<RetryResult<T>> executeWithRetry<T>(
    Future<T> Function() operation, {
    String? context,
  }) async {
    final stopwatch = Stopwatch()..start();
    final errors = <Object>[];
    int attemptCount = 0;

    while (true) {
      attemptCount++;

      try {
        _logger.fine(
          'Executing operation attempt $attemptCount${context != null ? ' ($context)' : ''}',
        );
        final result = await operation();

        stopwatch.stop();
        _logger.info(
          'Operation succeeded on attempt $attemptCount${context != null ? ' ($context)' : ''}',
        );

        return RetryResult<T>(
          result: Result.value(result),
          attemptCount: attemptCount,
          totalDuration: stopwatch.elapsed,
          allErrors: errors,
        );
      } catch (exception, st) {
        errors.add(exception);

        _logger.warning(
          'Operation failed on attempt $attemptCount${context != null ? ' ($context)' : ''}: ${exception.toString()}',
        );

        // Try to convert to a retryable exception first
        RetryableException? retryableException;
        if (exception is RetryableException) {
          retryableException = exception;
        } else {
          // Attempt to convert common exception types to retryable exceptions
          retryableException = RetryableException.tryFrom(exception);
          if (retryableException != null) {
            _logger.info(
              'Converted exception to retryable: ${exception.toString()}${context != null ? ' ($context)' : ''}',
            );
          }
        }

        // Check if we have a retryable exception (original or converted)
        if (retryableException != null) {
          if (attemptCount >= retryableException.maxAttempts) {
            stopwatch.stop();
            _logger.severe(
              'RetryableException failed after ${retryableException.maxAttempts} attempts, giving up${context != null ? ' ($context)' : ''}',
            );

            return RetryResult<T>(
              result: Result.error(exception, st),
              attemptCount: attemptCount,
              totalDuration: stopwatch.elapsed,
              allErrors: errors,
            );
          }

          // Calculate delay for next attempt
          final delay = _calculateDelay(retryableException, attemptCount - 1);
          _logger.info(
            'Retrying operation in ${delay.inMilliseconds}ms (attempt ${attemptCount + 1}/${retryableException.maxAttempts})${context != null ? ' ($context)' : ''}',
          );

          await Future<void>.delayed(delay);
        } else {
          // Non-retryable exception, fail immediately
          stopwatch.stop();
          _logger.severe(
            'Non-retryable exception occurred, giving up${context != null ? ' ($context)' : ''}: ${exception.toString()}',
          );

          return RetryResult<T>(
            result: Result.error(exception, st),
            attemptCount: attemptCount,
            totalDuration: stopwatch.elapsed,
            allErrors: errors,
          );
        }
      }
    }
  }

  /// Calculate exponential backoff delay with jitter
  Duration _calculateDelay(RetryableException exception, int attemptIndex) {
    final baseDelay = exception.initialDelay;
    final exponentialDelay = Duration(
      milliseconds:
          (baseDelay.inMilliseconds *
                  math.pow(exception.backoffMultiplier, attemptIndex))
              .round(),
    );

    // Apply maximum delay limit
    final cappedDelay = Duration(
      milliseconds: math.min(
        exponentialDelay.inMilliseconds,
        exception.maxDelay.inMilliseconds,
      ),
    );

    // Add jitter to prevent thundering herd
    if (exception.enableJitter) {
      final jitterMs = _random.nextInt(cappedDelay.inMilliseconds ~/ 2);
      return Duration(milliseconds: cappedDelay.inMilliseconds + jitterMs);
    }

    return cappedDelay;
  }
}

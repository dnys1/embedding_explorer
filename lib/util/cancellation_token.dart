import 'dart:async';

import 'package:logging/logging.dart';

class CancellationException implements Exception {
  CancellationException({this.message = 'Cancelled by user', this.reason});

  final String message;
  final String? reason;

  @override
  String toString() => '$message${reason != null ? ' (reason: $reason)' : ''}';
}

/// Simple cancellation token to signal job cancellation
class CancellationToken {
  CancellationToken(this.id);

  final String id;
  String? _reason;
  String? get reason => _reason;

  static final Logger _logger = Logger('CancellationToken');

  final Completer<void> _completer = Completer<void>.sync();

  /// Future that completes when the token is cancelled
  Future<void> get asFuture => _completer.future;

  /// Whether this token has been cancelled
  bool get isCancelled => _completer.isCompleted;

  /// Cancel the token
  void cancel([String? reason]) {
    if (!isCancelled) {
      _logger.info('Cancelling token $id');
      _reason = reason;
      _completer.complete();
    }
  }

  /// Throws if the token is cancelled
  void throwIfCancelled() {
    if (isCancelled) {
      throw CancellationException(
        message: 'Token $id was cancelled',
        reason: reason,
      );
    }
  }
}

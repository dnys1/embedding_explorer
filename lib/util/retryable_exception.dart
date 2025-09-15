import 'dart:async';
import 'dart:js_interop';

import '../interop/common.dart';

/// Exception that can be retried with specific parameters
class RetryableException implements Exception {
  final String message;
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final bool enableJitter;
  final Exception? originalException;

  const RetryableException(
    this.message, {
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(minutes: 5),
    this.enableJitter = true,
    this.originalException,
  });

  /// Create a retryable exception for rate limiting
  factory RetryableException.rateLimited({
    String? message,
    int? retryAfterSeconds,
    Exception? originalException,
  }) {
    final delay = retryAfterSeconds != null
        ? Duration(seconds: retryAfterSeconds)
        : const Duration(seconds: 60);

    return RetryableException(
      message ?? 'Rate limited by provider',
      maxAttempts: 5,
      initialDelay: delay,
      backoffMultiplier: 1.5,
      maxDelay: const Duration(minutes: 10),
      enableJitter: true,
      originalException: originalException,
    );
  }

  /// Create a retryable exception for network timeouts
  factory RetryableException.timeout({
    String? message,
    Exception? originalException,
  }) {
    return RetryableException(
      message ?? 'Network timeout',
      maxAttempts: 3,
      initialDelay: const Duration(seconds: 2),
      backoffMultiplier: 2.0,
      maxDelay: const Duration(minutes: 2),
      enableJitter: true,
      originalException: originalException,
    );
  }

  /// Create a retryable exception for temporary service issues
  factory RetryableException.serviceUnavailable({
    String? message,
    Exception? originalException,
  }) {
    return RetryableException(
      message ?? 'Service temporarily unavailable',
      maxAttempts: 4,
      initialDelay: const Duration(seconds: 5),
      backoffMultiplier: 1.8,
      maxDelay: const Duration(minutes: 5),
      enableJitter: true,
      originalException: originalException,
    );
  }

  /// Attempts to convert a common exception type to a RetryableException.
  /// Returns null if the exception is not retryable or unknown.
  static RetryableException? tryFrom(Object? ex) {
    if (ex == null) return null;

    if (ex is RetryableException) {
      return ex;
    }

    // Handle Dart timeout exceptions
    if (ex is TimeoutException) {
      return RetryableException.timeout(
        message: 'Request timed out: ${ex.message ?? 'unknown timeout'}',
        originalException: ex,
      );
    }

    // Try to handle as JavaScript exception
    final jsEx = ex as JSAny?;

    if (jsEx.isA<JSDOMException>()) {
      final jsError = jsEx as JSDOMException;
      // Check for specific DOMException names that indicate retryable errors
      switch (jsError.name) {
        case 'TimeoutError':
          return RetryableException.timeout(
            message: 'DOM timeout error: ${jsError.message}',
            originalException: Exception(jsError.message),
          );
        case 'NetworkError':
          return RetryableException.serviceUnavailable(
            message: 'DOM network error: ${jsError.message}',
            originalException: Exception(jsError.message),
          );
        case 'AbortError':
          return RetryableException.timeout(
            message: 'DOM abort error: ${jsError.message}',
            originalException: Exception(jsError.message),
          );
      }
    }

    // Handle generic JavaScript errors that might indicate retryable conditions
    if (jsEx.isA<JSError>()) {
      final jsError = jsEx as JSError;
      final message = jsError.message.toLowerCase();

      // Check for common retryable error patterns
      if (message.contains('timeout') || message.contains('timed out')) {
        return RetryableException.timeout(
          message: 'JavaScript error (timeout): ${jsError.message}',
          originalException: Exception(jsError.message),
        );
      }

      if (message.contains('network') ||
          message.contains('connection') ||
          message.contains('fetch')) {
        return RetryableException.serviceUnavailable(
          message: 'JavaScript error (network): ${jsError.message}',
          originalException: Exception(jsError.message),
        );
      }

      if (message.contains('rate limit') ||
          message.contains('too many requests') ||
          message.contains('429')) {
        return RetryableException.rateLimited(
          message: 'JavaScript error (rate limited): ${jsError.message}',
          originalException: Exception(jsError.message),
        );
      }
    }

    // Not a retryable exception type
    return null;
  }

  @override
  String toString() => 'RetryableException: $message';
}

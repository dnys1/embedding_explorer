@TestOn('browser')
library;

import 'dart:async';

import 'package:embeddings_explorer/interop/common.dart';
import 'package:embeddings_explorer/util/retryable_exception.dart';
import 'package:test/test.dart';

void main() {
  group('RetryableException.tryFrom', () {
    test('returns null for null input', () {
      expect(RetryableException.tryFrom(null), isNull);
    });

    test('returns null for non-retryable exceptions', () {
      expect(RetryableException.tryFrom('not an exception'), isNull);
      expect(RetryableException.tryFrom(42), isNull);
      expect(RetryableException.tryFrom(ArgumentError('test')), isNull);
    });

    group('Dart exceptions', () {
      test('converts TimeoutException to timeout RetryableException', () {
        final timeout = TimeoutException(
          'Operation timed out',
          const Duration(seconds: 30),
        );
        final retryable = RetryableException.tryFrom(timeout);

        expect(retryable, isNotNull);
        expect(retryable!.message, contains('Request timed out'));
        expect(retryable.message, contains('Operation timed out'));
        expect(retryable.originalException, equals(timeout));
        expect(retryable.maxAttempts, equals(3));
        expect(retryable.initialDelay, equals(const Duration(seconds: 2)));
      });

      test('converts TimeoutException with null message', () {
        final timeout = TimeoutException(null, const Duration(seconds: 10));
        final retryable = RetryableException.tryFrom(timeout);

        expect(retryable, isNotNull);
        expect(retryable!.message, contains('unknown timeout'));
      });
    });

    group('JavaScript exceptions', () {
      test('converts JSTimeoutError to timeout RetryableException', () {
        final jsError = JSTimeoutError('JavaScript timeout occurred');
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNotNull);
        expect(retryable!.message, contains('DOM timeout error'));
        expect(retryable.message, contains('JavaScript timeout occurred'));
        expect(retryable.maxAttempts, equals(3));
        expect(retryable.initialDelay, equals(const Duration(seconds: 2)));
      });

      test(
        'converts JSNetworkError to serviceUnavailable RetryableException',
        () {
          final jsError = JSNetworkError('Network connection failed');
          final retryable = RetryableException.tryFrom(jsError);

          expect(retryable, isNotNull);
          expect(retryable!.message, contains('DOM network error'));
          expect(retryable.message, contains('Network connection failed'));
          expect(retryable.maxAttempts, equals(4));
          expect(retryable.initialDelay, equals(const Duration(seconds: 5)));
        },
      );

      test('converts JSAbortError to timeout RetryableException', () {
        final jsError = JSAbortError('Request was aborted');
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNotNull);
        expect(retryable!.message, contains('DOM abort error'));
        expect(retryable.message, contains('Request was aborted'));
        expect(retryable.maxAttempts, equals(3));
      });

      test('converts JSDOMException with TimeoutError name', () {
        final jsError = JSDOMException(
          'DOM operation timed out',
          'TimeoutError',
        );
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNotNull);
        expect(retryable!.message, contains('DOM timeout error'));
        expect(retryable.message, contains('DOM operation timed out'));
      });

      test('converts JSDOMException with NetworkError name', () {
        final jsError = JSDOMException('DOM network failed', 'NetworkError');
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNotNull);
        expect(retryable!.message, contains('DOM network error'));
        expect(retryable.message, contains('DOM network failed'));
        expect(retryable.maxAttempts, equals(4));
      });

      test('converts JSDOMException with AbortError name', () {
        final jsError = JSDOMException('DOM operation aborted', 'AbortError');
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNotNull);
        expect(retryable!.message, contains('DOM abort error'));
        expect(retryable.message, contains('DOM operation aborted'));
      });

      test('ignores JSDOMException with non-retryable name', () {
        final jsError = JSDOMException(
          'Invalid operation',
          'InvalidStateError',
        );
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNull);
      });
    });

    group('Generic JavaScript errors with patterns', () {
      test('converts JSError with timeout pattern', () {
        final jsError = JSError('The operation timed out after 30 seconds');
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNotNull);
        expect(retryable!.message, contains('JavaScript error (timeout)'));
        expect(retryable.maxAttempts, equals(3));
      });

      test('converts JSError with network pattern', () {
        final jsError = JSError('Network connection error occurred');
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNotNull);
        expect(retryable!.message, contains('JavaScript error (network)'));
        expect(retryable.maxAttempts, equals(4));
      });

      test('converts JSError with fetch pattern', () {
        final jsError = JSError('Fetch request failed');
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNotNull);
        expect(retryable!.message, contains('JavaScript error (network)'));
      });

      test('converts JSError with rate limit pattern', () {
        final jsError = JSError('Too many requests - rate limit exceeded');
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNotNull);
        expect(retryable!.message, contains('JavaScript error (rate limited)'));
        expect(retryable.maxAttempts, equals(5));
        expect(retryable.initialDelay, equals(const Duration(seconds: 60)));
      });

      test('converts JSError with 429 status pattern', () {
        final jsError = JSError('HTTP 429 error occurred');
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNotNull);
        expect(retryable!.message, contains('JavaScript error (rate limited)'));
      });

      test('ignores JSError with non-retryable patterns', () {
        final jsError = JSError('Invalid syntax error');
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNull);
      });
    });

    group('Edge cases', () {
      test('handles empty error messages gracefully', () {
        final jsError = JSError('');
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNull);
      });

      test('is case insensitive for pattern matching', () {
        final jsError = JSError('NETWORK CONNECTION FAILED');
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNotNull);
        expect(retryable!.message, contains('JavaScript error (network)'));
      });

      test('handles multiple pattern matches prioritizing first match', () {
        final jsError = JSError('Network timeout occurred during fetch');
        final retryable = RetryableException.tryFrom(jsError);

        expect(retryable, isNotNull);
        // Should match timeout pattern first
        expect(retryable!.message, contains('JavaScript error (timeout)'));
        expect(retryable.maxAttempts, equals(3));
      });
    });

    group('Factory method consistency', () {
      test('timeout RetryableException has expected defaults', () {
        final retryable = RetryableException.tryFrom(
          TimeoutException('test', const Duration(seconds: 1)),
        );

        expect(retryable!.maxAttempts, equals(3));
        expect(retryable.initialDelay, equals(const Duration(seconds: 2)));
        expect(retryable.backoffMultiplier, equals(2.0));
        expect(retryable.maxDelay, equals(const Duration(minutes: 2)));
        expect(retryable.enableJitter, isTrue);
      });

      test('service unavailable RetryableException has expected defaults', () {
        final retryable = RetryableException.tryFrom(
          JSNetworkError('network error'),
        );

        expect(retryable!.maxAttempts, equals(4));
        expect(retryable.initialDelay, equals(const Duration(seconds: 5)));
        expect(retryable.backoffMultiplier, equals(1.8));
        expect(retryable.maxDelay, equals(const Duration(minutes: 5)));
        expect(retryable.enableJitter, isTrue);
      });

      test('rate limited RetryableException has expected defaults', () {
        final retryable = RetryableException.tryFrom(
          JSError('rate limit exceeded'),
        );

        expect(retryable!.maxAttempts, equals(5));
        expect(retryable.initialDelay, equals(const Duration(seconds: 60)));
        expect(retryable.backoffMultiplier, equals(1.5));
        expect(retryable.maxDelay, equals(const Duration(minutes: 10)));
        expect(retryable.enableJitter, isTrue);
      });
    });
  });
}

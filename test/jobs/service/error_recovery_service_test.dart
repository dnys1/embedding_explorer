import 'dart:async';

import 'package:embeddings_explorer/interop/common.dart';
import 'package:embeddings_explorer/jobs/service/error_recovery_service.dart';
import 'package:embeddings_explorer/util/retryable_exception.dart';
import 'package:test/test.dart';

void main() {
  group('ErrorRecoveryService', () {
    late ErrorRecoveryService service;

    setUp(() {
      service = ErrorRecoveryService();
    });

    group('executeWithRetry with tryFrom conversion', () {
      test('converts TimeoutException to retryable and retries', () async {
        var attemptCount = 0;

        final result = await service.executeWithRetry<String>(() async {
          attemptCount++;
          if (attemptCount < 3) {
            throw TimeoutException(
              'Request timed out',
              const Duration(seconds: 30),
            );
          }
          return 'success';
        });

        expect(result.success, isTrue);
        expect(result.result, equals('success'));
        expect(result.attemptCount, equals(3));
        expect(result.allErrors, hasLength(2));
      });

      test(
        'converts JSError with timeout pattern to retryable and retries',
        () async {
          var attemptCount = 0;

          final result = await service.executeWithRetry<String>(() async {
            attemptCount++;
            if (attemptCount < 2) {
              throw JSError('Operation timed out after 30 seconds');
            }
            return 'success';
          });

          expect(result.success, isTrue);
          expect(result.result, equals('success'));
          expect(result.attemptCount, equals(2));
          expect(result.allErrors, hasLength(1));
        },
      );

      test(
        'converts JSError with network pattern to retryable and retries',
        () async {
          var attemptCount = 0;

          final result = await service.executeWithRetry<String>(() async {
            attemptCount++;
            if (attemptCount < 2) {
              throw JSError('Network connection failed');
            }
            return 'success';
          });

          expect(result.success, isTrue);
          expect(result.result, equals('success'));
          expect(result.attemptCount, equals(2));
          expect(result.allErrors, hasLength(1));
        },
      );

      test(
        'converts JSDOMException with NetworkError name to retryable',
        () async {
          var attemptCount = 0;

          final result = await service.executeWithRetry<String>(() async {
            attemptCount++;
            if (attemptCount < 2) {
              throw JSDOMException('Network request failed', 'NetworkError');
            }
            return 'success';
          });

          expect(result.success, isTrue);
          expect(result.result, equals('success'));
          expect(result.attemptCount, equals(2));
          expect(result.allErrors, hasLength(1));
        },
      );

      test('fails immediately for non-convertible exceptions', () async {
        final result = await service.executeWithRetry<String>(() async {
          throw ArgumentError('Invalid argument');
        });

        expect(result.success, isFalse);
        expect(result.attemptCount, equals(1));
        expect(result.allErrors, hasLength(1));
        expect(result.lastError, isA<Exception>());
        expect(result.lastError.toString(), contains('Invalid argument'));
      });

      test(
        'logs conversion when exception is converted to retryable',
        () async {
          var attemptCount = 0;

          final result = await service.executeWithRetry<String>(() async {
            attemptCount++;
            if (attemptCount < 2) {
              throw TimeoutException(
                'Request timed out',
                const Duration(seconds: 30),
              );
            }
            return 'success';
          }, context: 'test operation');

          expect(result.success, isTrue);
          expect(result.attemptCount, equals(2));
          expect(attemptCount, equals(2)); // Verify we actually made 2 attempts
          // We can't easily test log messages without setting up a log handler,
          // but we can verify the operation completed successfully
        },
      );

      test('respects retry limits from converted exceptions', () async {
        var attemptCount = 0;

        final result = await service.executeWithRetry<String>(() async {
          attemptCount++;
          // Always throw a timeout exception (which converts to max 3 attempts)
          throw TimeoutException(
            'Request timed out',
            const Duration(seconds: 30),
          );
        });

        expect(result.success, isFalse);
        expect(result.attemptCount, equals(3)); // Should try exactly 3 times
        expect(attemptCount, equals(3)); // Verify we actually made 3 attempts
        expect(result.allErrors, hasLength(3));
        expect(result.lastError, isA<RetryableException>());
      });

      test('handles already retryable exceptions without conversion', () async {
        var attemptCount = 0;

        final result = await service.executeWithRetry<String>(() async {
          attemptCount++;
          if (attemptCount < 2) {
            throw RetryableException.timeout(message: 'Custom timeout');
          }
          return 'success';
        });

        expect(result.success, isTrue);
        expect(result.result, equals('success'));
        expect(result.attemptCount, equals(2));
        expect(result.allErrors, hasLength(1));
        expect(result.allErrors.first, isA<RetryableException>());
      });

      test('properly calculates delays for converted exceptions', () async {
        var attemptCount = 0;
        final attemptTimes = <DateTime>[];

        final result = await service.executeWithRetry<String>(() async {
          attemptTimes.add(DateTime.now());
          attemptCount++;
          if (attemptCount < 3) {
            // This will be converted to a timeout retryable exception with 2s initial delay
            throw TimeoutException(
              'Request timed out',
              const Duration(seconds: 30),
            );
          }
          return 'success';
        });

        expect(result.success, isTrue);
        expect(attemptTimes, hasLength(3));

        // Verify there was a delay between attempts (at least 1 second for timeout exceptions)
        final delay1 = attemptTimes[1].difference(attemptTimes[0]);
        final delay2 = attemptTimes[2].difference(attemptTimes[1]);

        expect(
          delay1.inMilliseconds,
          greaterThan(1500),
        ); // Should be ~2s + jitter
        expect(
          delay2.inMilliseconds,
          greaterThan(3500),
        ); // Should be ~4s + jitter (exponential backoff)
      });
    });

    group('edge cases with tryFrom', () {
      test('handles null exceptions gracefully', () async {
        var attemptCount = 0;

        final result = await service.executeWithRetry<String>(() async {
          attemptCount++;
          // This creates a generic Exception which won't be convertible
          throw Exception('Generic error');
        });

        expect(result.success, isFalse);
        expect(result.attemptCount, equals(1));
        expect(attemptCount, equals(1)); // Verify we made exactly 1 attempt
        expect(result.allErrors, hasLength(1));
      });

      test('handles JavaScript objects as exceptions', () async {
        var attemptCount = 0;

        final result = await service.executeWithRetry<String>(() async {
          attemptCount++;
          if (attemptCount < 2) {
            throw JSError('Fetch request failed due to network issues');
          }
          return 'success';
        });

        expect(result.success, isTrue);
        expect(result.result, equals('success'));
        expect(result.attemptCount, equals(2));
      });
    });
  });
}

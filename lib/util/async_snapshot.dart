import 'package:jaspr/jaspr.dart';

sealed class AsyncResult<T> {
  const AsyncResult();
}

final class AsyncLoading<T> extends AsyncResult<T> {
  const AsyncLoading();
}

final class AsyncData<T> extends AsyncResult<T> {
  const AsyncData(this.data);

  final T data;
}

final class AsyncError<T> extends AsyncResult<T> {
  const AsyncError(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;
}

extension AsAsyncResult<T> on AsyncSnapshot<T> {
  AsyncResult<T> get result {
    if (hasError) {
      return AsyncError<T>(error!, stackTrace);
    } else if (connectionState == ConnectionState.waiting) {
      return AsyncLoading<T>();
    } else {
      return AsyncData<T>(requireData);
    }
  }
}

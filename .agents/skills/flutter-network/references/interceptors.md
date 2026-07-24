# Network Interceptors

All interceptors live under `lib/src/core/network/interceptors/`. Only these files (and `dio_client.dart`) import `package:dio`.

## `auth_interceptor.dart`

Attaches the Bearer token from `SecureStorage` to every request.

```dart
import 'package:dio/dio.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);
  final SecureStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read('access_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

## `logging_interceptor.dart`

Logs request method/URI, response status, and errors via `AppLogger`.

```dart
import 'package:dio/dio.dart';
import '../../logging/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logger);
  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.debug(
      '← ${response.statusCode} ${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.warn(
      '× ${err.requestOptions.method} ${err.requestOptions.uri} '
      '(${err.response?.statusCode ?? err.type})',
      error: err,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }
}
```

## `error_interceptor.dart`

Maps `DioException` to typed `Failure` before propagating the error.

```dart
import 'package:dio/dio.dart';
import '../../error/failure.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(err.copyWith(error: FailureException(_mapToFailure(err))));
  }

  Failure _mapToFailure(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return const UnknownFailure();
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        final message = _extractMessage(err.response?.data) ??
            'Server error ($status).';
        if (status == 401) return UnauthorizedFailure(message);
        if (status == 404) return NotFoundFailure(message);
        if (status >= 500) return ServerFailure(message, statusCode: status);
        return ServerFailure(message, statusCode: status);
    }
  }

  String? _extractMessage(Object? data) {
    if (data is Map<String, Object?>) {
      final m = data['message'] ?? data['error'];
      if (m is String && m.isNotEmpty) return m;
    }
    return null;
  }
}
```

## `retry_interceptor_factory.dart`

App-owned factory wrapping `dio_smart_retry`. Third-party import is isolated here.

```dart
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

/// App-owned factory that creates a [RetryInterceptor] for a given [Dio].
/// Wraps `dio_smart_retry` — third-party import stays in this single file.
class RetryInterceptorFactory {
  const RetryInterceptorFactory({
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
  });

  final int retries;
  final List<Duration> retryDelays;

  Interceptor create(Dio dio) => RetryInterceptor(
        dio: dio,
        retries: retries,
        retryDelays: retryDelays,
      );
}
```

## Interceptor order

In `buildDio`, interceptors are added in this order:

```
retry → logging → error
```

Retry fires first on error so the re-attempt goes through logging again.

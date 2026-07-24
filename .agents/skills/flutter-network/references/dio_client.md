# DioClient

Builds and configures the shared `Dio` instance. This is the only file (outside interceptors) that imports `package:dio`.

## `lib/src/core/network/dio_client.dart`

```dart
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor_factory.dart';
import 'interceptors/security_interceptor.dart';

/// Creates a [Dio] instance with base config and non-auth interceptors.
/// AuthInterceptor is added separately in service_locator.dart to avoid
/// a circular dependency (AuthInterceptor needs Dio for retry).
Dio buildDio({
  required AppConfig config,
  required SecurityInterceptor security,
  required RetryInterceptorFactory retryFactory,
  required LoggingInterceptor logging,
  required ErrorInterceptor error,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: Duration(seconds: config.connectTimeoutSeconds),
      receiveTimeout: Duration(seconds: config.receiveTimeoutSeconds),
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  // Apply SSL pinning (configured per flavor in EnvConfig)
  security.apply(dio);

  // Order matters: retry → logging → error
  // Retry fires first on error so the re-attempt goes through logging again.
  dio.interceptors.addAll([retryFactory.create(dio), logging, error]);
  return dio;
}
```

## Notes

- `baseUrl`, `connectTimeout`, and `receiveTimeout` come from `AppConfig` (injected, flavor-aware).
- `AuthInterceptor` is added separately in `service_locator.dart` to avoid a circular dependency.
- SSL pinning via `SecurityInterceptor` — see `flutter-security` skill for the full implementation.
- Never create new `Dio()` instances per request — always inject the configured `Dio` from DI.

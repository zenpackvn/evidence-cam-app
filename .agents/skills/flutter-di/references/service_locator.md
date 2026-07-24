# Service Locator — `service_locator.dart`

The composition root that wires the entire DI graph.

## `lib/src/core/di/service_locator.dart`

```dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../animations/app_animate.dart';
import '../animations/app_animate_impl.dart';
import '../config/app_config.dart';
import '../logging/app_logger.dart';
import '../logging/logger_impl.dart';
import '../network/api_client.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';
import '../storage/secure_storage.dart';
import '../storage/secure_storage_impl.dart';
import '../../features/home/di/home_module.dart';
import 'animations_module.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies(Env env) async {
  // 1. Config
  getIt.registerSingleton<AppConfig>(AppConfig.fromEnv(env));

  // 2. Logging
  getIt.registerLazySingleton<AppLogger>(LoggerImpl.new);

  // 3. Storage
  getIt.registerLazySingleton<SecureStorage>(SecureStorageImpl.new);

  // 4. Network (Dio + ApiClient — before Auth, because AuthService needs ApiClient)
  getIt.registerLazySingleton<SecurityInterceptor>(
    () => SecurityInterceptor(config: getIt<AppConfig>()),
  );
  getIt.registerLazySingleton<RetryInterceptorFactory>(
    RetryInterceptorFactory.new,
  );
  getIt.registerLazySingleton<LoggingInterceptor>(
    () => LoggingInterceptor(getIt<AppLogger>()),
  );
  getIt.registerLazySingleton<ErrorInterceptor>(ErrorInterceptor.new);
  getIt.registerLazySingleton<Dio>(
    () => buildDio(
      config: getIt<AppConfig>(),
      security: getIt<SecurityInterceptor>(),
      retryFactory: getIt<RetryInterceptorFactory>(),
      logging: getIt<LoggingInterceptor>(),
      error: getIt<ErrorInterceptor>(),
    ),
  );
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));

  // 5. Auth (after Network — AuthService needs ApiClient)
  registerAuthModule(getIt);

  // 6. AuthInterceptor (after Auth — needs TokenManager + AuthService + Dio)
  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(
      tokenManager: getIt<TokenManager>(),
      authService: getIt<AuthService>(),
      dio: getIt<Dio>(),
    ),
  );
  getIt<Dio>().interceptors.insert(0, getIt<AuthInterceptor>());

  // 7. Animations (presets + convenience extension wiring)
  registerAnimationsModule(getIt);

  // 8. Feature modules
  registerHomeModule(getIt);
}
```

## Registration order

Register bottom-up — later registrations depend on earlier ones:

1. `AppConfig` (singleton)
2. `AppLogger` (lazy singleton)
3. `SecureStorage` / `KeyValueStore` (lazy singleton)
4. `SecurityInterceptor` + `RetryInterceptorFactory` + `LoggingInterceptor` + `ErrorInterceptor` + `Dio` + `ApiClient` (lazy singletons)
5. Auth module (`AuthService`, `TokenManager`) — needs ApiClient
6. `AuthInterceptor` (after Auth — needs TokenManager + Dio) — inserted at position 0
7. `registerAnimationsModule` — wires `AppAnimatePresets` + calls `initAppAnimatePresets` for the extension
8. Feature modules: data sources, repositories (lazy singletons), use cases (factories), blocs/cubits (factories)

Anything that requires async init (`SharedPreferences.getInstance()`, secure storage probes, remote config) is awaited inside `configureDependencies()` before `runApp`. Use `registerSingletonAsync` or resolve the async value first and register the result as a regular singleton.

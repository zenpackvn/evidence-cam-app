# Auth — DI Module & Service Locator Wiring

## `lib/src/features/auth/di/auth_module.dart`

```dart
import 'package:get_it/get_it.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/auth/auth_service_impl.dart';
import '../../../core/auth/biometric_service.dart';
import '../../../core/auth/biometric_service_impl.dart';
import '../../../core/auth/token_manager.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../presentation/cubit/auth_cubit.dart';
import '../presentation/cubit/sign_in_cubit.dart';

void registerAuthModule(GetIt getIt) {
  // ── Core auth services (singletons — maintain stream / token state) ──

  getIt.registerSingleton<TokenManager>(
    TokenManager(getIt<SecureStorage>()),
  );

  getIt.registerSingleton<AuthService>(
    AuthServiceImpl(
      tokenManager: getIt<TokenManager>(),
      apiClient: getIt<ApiClient>(),
      logger: getIt<AppLogger>(),
    ),
  );

  // ── Biometric (lazy — only instantiated if used) ──

  getIt.registerLazySingleton<BiometricService>(
    BiometricServiceImpl.new,
  );

  // ── Cubits ──

  // AuthCubit is a singleton — it holds global auth state for the router guard.
  getIt.registerSingleton<AuthCubit>(
    AuthCubit(getIt<AuthService>()),
  );

  // SignInCubit is a factory — new instance per sign-in screen visit.
  getIt.registerFactory<SignInCubit>(
    () => SignInCubit(getIt<AuthService>()),
  );
}
```

---

## Updated `service_locator.dart` registration order

Add auth module registration **after** network and **before** feature modules:

```dart
import '../../features/auth/di/auth_module.dart';

Future<void> configureDependencies(Env env) async {
  // 1. Config
  // 2. Logging
  // 3. Storage
  // 4. Network (Dio, ApiClient, interceptors)

  // 5. Auth (depends on Storage + Network)
  registerAuthModule(getIt);

  // 6. Check initial auth status (seeds the AuthStatus stream)
  await (getIt<AuthService>() as AuthServiceImpl).checkInitialAuthStatus();

  // 7. Feature modules
  registerHomeModule(getIt);
}
```

> **Note:** `AuthInterceptor` now depends on `TokenManager` and `AuthService`. Update the interceptor registration in `service_locator.dart` accordingly — it must be registered **after** `registerAuthModule`:
>
> ```dart
> getIt.registerLazySingleton<AuthInterceptor>(
>   () => AuthInterceptor(
>     tokenManager: getIt<TokenManager>(),
>     authService: getIt<AuthService>(),
>     dio: getIt<Dio>(),
>     logger: getIt<AppLogger>(),
>   ),
> );
> ```

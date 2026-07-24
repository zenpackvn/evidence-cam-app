# Feature Modules

When a feature has more than ~5 registrations, split them into a feature module.

## Example — auth module

```dart
// lib/src/features/auth/di/auth_module.dart
void registerAuthModule(GetIt getIt) {
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: getIt<AuthRemoteDataSource>(),
      storage: getIt<SecureStorage>(),
      logger: getIt<AppLogger>(),
    ),
  );
  getIt.registerFactory<SignInUseCase>(
    () => SignInUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<SignInCubit>(
    () => SignInCubit(getIt<SignInUseCase>()),
  );
}
```

Called exactly once from `configureDependencies()`:

```dart
Future<void> configureDependencies(Env env) async {
  // infrastructure registrations first
  registerAuthModule(getIt);
  registerHomeModule(getIt);
  // ...
}
```

## Optional: `injectable`

When the DI graph grows past ~20 bindings, introduce `injectable` + `injectable_generator`. Keep the same rules: annotations live on implementations, the generated `configureDependencies()` stays under `lib/src/core/di/`, and the wrapper rule still applies.

# Template — Authentication

Full auth flow: login, token refresh, biometric, session management, router guard. Part of the project layout in [template-app-shell.md](template-app-shell.md).

Only `auth_service_impl.dart` coordinates token storage and API calls. Only `biometric_service_impl.dart` imports `package:local_auth`. The wrapper rule applies throughout.

## Reference Files

Load only the file(s) relevant to the task.

| Topic | File |
|---|---|
| AuthStatus enum, AuthService interface, AuthServiceImpl | [auth_service.md](auth_service.md) |
| TokenManager (JWT decode, SecureStorage, expiry check) | [token_manager.md](token_manager.md) |
| BiometricService interface + local_auth wrapper | [biometric_service.md](biometric_service.md) |
| AuthInterceptor (401 → refresh → retry, race-condition safe) | [auth_interceptor.md](auth_interceptor.md) |
| AuthCubit, AuthCubitState, SignInCubit, SignInState | [auth_cubit.md](auth_cubit.md) |
| SignInForm widget + SignInPage | [sign_in_ui.md](sign_in_ui.md) |
| auth_module.dart + service_locator registration order | [auth_di_module.md](auth_di_module.md) |
| GoRouter guard, AuthNotifier, app-level BlocProvider | [router_guard.md](router_guard.md) |
| Test fakes (FakeAuthService, FakeTokenManager, FakeBiometricService) + cubit tests | [test_fakes_and_tests.md](test_fakes_and_tests.md) |
| Rules + anti-patterns | [rules_and_antipatterns.md](rules_and_antipatterns.md) |

---

## ⚠️ Common Mistakes

> These are the most frequent auth bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Storing tokens in `SharedPreferences`** | Tokens visible in unencrypted app storage on rooted devices | Use `SecureStorage` exclusively — Keychain (iOS) / EncryptedSharedPreferences (Android) |
| 2 | **Concurrent 401s triggering multiple refresh calls** | Race condition → two refresh requests → second one fails → user logged out | `AuthInterceptor` must extend `QueuedInterceptor` with a `Completer` guard — see [auth_interceptor.md](auth_interceptor.md) |
| 3 | **Refresh endpoint included in the refresh-retry path** | Infinite loop: refresh 401 → retry refresh → 401 → … | Skip the interceptor for the refresh URL: `if (request.path == '/auth/refresh') return handler.next(request)` |
| 4 | **`AuthCubit` registered as `registerFactory`** | Auth state resets on every screen push — user is logged out mid-flow | `AuthCubit` is `registerLazySingleton`; only `SignInCubit` is `registerFactory` |
| 5 | **Individual pages checking auth state and redirecting** | Multiple redirect paths, guard bypasses, inconsistent behaviour | Auth guard in `AppRouter` is the **only** redirect point — pages never check auth |
| 6 | **Not calling `checkInitialAuthStatus()` on startup** | Router guard starts in `unknown` state → flicker or wrong initial route | Call in `configureDependencies()` before `runApp()` |
| 7 | **Showing biometric option without calling `isAvailable()`** | Biometric UI shown on devices with no hardware or no enrolled fingers | Always guard with `await biometricService.isAvailable()` first |
| 8 | **`SignInCubit` depending on `AuthCubit` directly** | Tight coupling, hard to test, sign-in success doesn't propagate cleanly | `SignInCubit` calls `AuthService.signIn()` only; `AuthCubit` observes `AuthService.authStatusStream` independently |

---

## Quick Summary

- **Tokens only in `SecureStorage`** — never `SharedPreferences`. Keychain on iOS, EncryptedSharedPreferences on Android.
- **Single concurrent refresh** — `AuthInterceptor` extends `QueuedInterceptor` and uses a `Completer` so N concurrent 401s produce exactly one refresh call.
- **`AuthCubit` is a singleton; `SignInCubit` is a factory** — auth state lives for the app lifetime; sign-in state resets per screen visit.
- **Router guard is the single auth gate** — individual pages never check auth state and never redirect manually.
- **Seed auth on startup** — call `checkInitialAuthStatus()` in `configureDependencies()` so the guard has a known state on the first frame.
- **Biometric is opt-in** — always call `isAvailable()` before showing the biometric option.
- **Skip refresh for the refresh endpoint** — prevents the infinite 401 → refresh → 401 loop.

## Cross-references

- [flutter-storage](../../flutter-storage/references/template.md) — `SecureStorage` for token persistence (Keychain / EncryptedSharedPreferences)
- [flutter-network](../../flutter-network/references/template.md) — `AuthInterceptor` wired into `DioClient`; token refresh on 401
- [flutter-routing](../../flutter-routing/references/template.md) — GoRouter auth guard; the only redirect point in the app
- [flutter-di](../../flutter-di/references/template.md) — `AuthService`, `TokenManager`, `BiometricService` registration lifetimes

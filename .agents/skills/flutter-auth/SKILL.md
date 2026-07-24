---
name: flutter-auth
description: Use this skill when implementing Flutter authentication — login, logout, sign-in flow, token management, JWT tokens, access token, refresh token, token refresh interceptor, race condition handling, biometric authentication, local_auth, session management, auth guard, AuthService, TokenManager, BiometricService, or any authentication/authorization feature.
---

# Flutter Auth

Full reference: [`template.md`](references/template.md)

## Files

```
lib/src/core/auth/
  auth_service.dart           ← interface (login, logout, refreshToken, status stream)
  auth_service_impl.dart      ← implementation (only file importing auth packages)
  auth_status.dart            ← enum: unknown | authenticated | unauthenticated
  token_manager.dart          ← interface (get/set/clear access + refresh token)
  token_manager_impl.dart     ← wraps SecureStorage
  biometric_service.dart      ← interface (isAvailable, authenticate)
  biometric_service_impl.dart ← only file importing local_auth
lib/src/features/auth/
  domain/repositories/auth_repository.dart   ← feature-level contract
  data/repositories/auth_repository_impl.dart← delegates to AuthService
  domain/usecases/sign_in_usecase.dart
  domain/usecases/logout_usecase.dart
  domain/usecases/observe_auth_status_usecase.dart
  presentation/cubit/auth_cubit.dart         ← drives the auth guard
  presentation/cubit/sign_in_cubit.dart
```

## Key rules

- `AuthService.status` is a **broadcast stream** — multiple listeners are valid.
- Token refresh uses a `Completer` to coalesce concurrent 401s — only one refresh in flight at a time.
- Auth interceptor: on 401 → call `authService.refreshToken()` → retry original request. On refresh failure → `authService.logout()`.
- `AuthCubit` listens to `ObserveAuthStatusUseCase` stream and emits `AuthAuthenticated`/`AuthUnauthenticated` — the router `redirect` reads this state.
- `BiometricService` result is checked before calling `AuthService.login()` — biometric is a pre-auth gate, not a replacement.
- Never store tokens in `SharedPreferences` — always `SecureStorage`.

## Co-load with

- `flutter-storage` — `SecureStorage` for tokens
- `flutter-network` — auth interceptor wired into `DioClient`
- `flutter-routing` — auth guard in GoRouter
- `flutter-di` — `AuthService`, `TokenManager`, `BiometricService` registration

# Auth — AuthState, AuthService Interface & Implementation

## Folder structure

```text
lib/src/
  core/
    auth/
      auth_service.dart              ← App-owned auth interface
      auth_service_impl.dart         ← Implementation (token storage + API)
      auth_state.dart                ← AuthStatus enum (authenticated, unauthenticated, unknown)
```

---

## `lib/src/core/auth/auth_state.dart`

```dart
/// Authentication status broadcast by [AuthService].
enum AuthStatus {
  /// Initial state — auth check has not completed yet.
  unknown,

  /// User has a valid session.
  authenticated,

  /// No session or session expired.
  unauthenticated,
}
```

---

## `lib/src/core/auth/auth_service.dart`

```dart
import 'auth_state.dart';

/// App-owned auth interface.
/// Only [AuthServiceImpl] implements this — it is the single place
/// that coordinates tokens, API calls, and auth-status broadcasts.
abstract interface class AuthService {
  /// Stream of auth status changes. Used by [AuthCubit] and the router guard.
  Stream<AuthStatus> get status;

  /// Current auth status (synchronous snapshot).
  AuthStatus get currentStatus;

  /// Authenticate with email + password.
  /// Throws [FailureException] on network or credential errors.
  Future<void> login({required String email, required String password});

  /// Clear session and emit [AuthStatus.unauthenticated].
  Future<void> logout();

  /// Attempt to refresh the access token using the stored refresh token.
  /// Throws [FailureException] if the refresh fails.
  Future<void> refreshToken();

  /// Returns the current access token, or `null` if unauthenticated.
  Future<String?> getAccessToken();

  /// Returns the current refresh token, or `null` if unauthenticated.
  Future<String?> getRefreshToken();
}
```

---

## `lib/src/core/auth/auth_service_impl.dart`

```dart
import 'dart:async';

import '../error/failure.dart';
import '../logging/app_logger.dart';
import '../network/api_client.dart';
import 'auth_service.dart';
import 'auth_state.dart';
import 'token_manager.dart';

class AuthServiceImpl implements AuthService {
  AuthServiceImpl({
    required TokenManager tokenManager,
    required ApiClient apiClient,
    required AppLogger logger,
  })  : _tokenManager = tokenManager,
        _apiClient = apiClient,
        _logger = logger;

  final TokenManager _tokenManager;
  final ApiClient _apiClient;
  final AppLogger _logger;

  final _controller = StreamController<AuthStatus>.broadcast();
  AuthStatus _currentStatus = AuthStatus.unknown;

  // ── Public API ──

  @override
  Stream<AuthStatus> get status => _controller.stream;

  @override
  AuthStatus get currentStatus => _currentStatus;

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.login(
        body: {'email': email, 'password': password},
      );

      await _tokenManager.saveTokens(
        accessToken: response['access_token'] as String,
        refreshToken: response['refresh_token'] as String,
      );

      _emit(AuthStatus.authenticated);
    } on FailureException {
      rethrow;
    } catch (e, s) {
      _logger.error('Login failed', error: e, stackTrace: s);
      throw const FailureException(UnknownFailure('Login failed.'));
    }
  }

  @override
  Future<void> logout() async {
    await _tokenManager.clearTokens();
    _emit(AuthStatus.unauthenticated);
    _logger.info('User logged out');
  }

  @override
  Future<void> refreshToken() async {
    final refresh = await _tokenManager.getRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      await logout();
      throw const FailureException(
        UnauthorizedFailure('No refresh token available.'),
      );
    }

    try {
      final response = await _apiClient.refreshToken(
        body: {'refresh_token': refresh},
      );

      await _tokenManager.saveTokens(
        accessToken: response['access_token'] as String,
        refreshToken: response['refresh_token'] as String,
      );

      _emit(AuthStatus.authenticated);
    } catch (e, s) {
      _logger.error('Token refresh failed — forcing logout', error: e, stackTrace: s);
      await logout();
      throw const FailureException(
        UnauthorizedFailure('Session expired. Please sign in again.'),
      );
    }
  }

  @override
  Future<String?> getAccessToken() => _tokenManager.getAccessToken();

  @override
  Future<String?> getRefreshToken() => _tokenManager.getRefreshToken();

  /// Call once at app startup to seed the initial auth status.
  Future<void> checkInitialAuthStatus() async {
    final valid = await _tokenManager.hasValidToken();
    _emit(valid ? AuthStatus.authenticated : AuthStatus.unauthenticated);
  }

  // ── Internal ──

  void _emit(AuthStatus status) {
    _currentStatus = status;
    _controller.add(status);
  }

  /// Clean up. Call from the composition root if the app ever tears down.
  void dispose() {
    _controller.close();
  }
}
```

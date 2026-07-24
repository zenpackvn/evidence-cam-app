# Auth — Test Fakes & Cubit Tests

## `test/fakes/fake_auth_service.dart`

```dart
import 'dart:async';

import 'package:app/src/core/auth/auth_service.dart';
import 'package:app/src/core/auth/auth_state.dart';

class FakeAuthService implements AuthService {
  final _controller = StreamController<AuthStatus>.broadcast();
  AuthStatus _currentStatus = AuthStatus.unauthenticated;

  /// Set this to make [login] throw.
  Exception? loginException;

  /// Set this to make [refreshToken] throw.
  Exception? refreshException;

  @override
  Stream<AuthStatus> get status => _controller.stream;

  @override
  AuthStatus get currentStatus => _currentStatus;

  @override
  Future<void> login({required String email, required String password}) async {
    if (loginException != null) throw loginException!;
    _emit(AuthStatus.authenticated);
  }

  @override
  Future<void> logout() async {
    _emit(AuthStatus.unauthenticated);
  }

  @override
  Future<void> refreshToken() async {
    if (refreshException != null) throw refreshException!;
  }

  @override
  Future<String?> getAccessToken() async => 'fake_access_token';

  @override
  Future<String?> getRefreshToken() async => 'fake_refresh_token';

  void _emit(AuthStatus status) {
    _currentStatus = status;
    _controller.add(status);
  }

  void dispose() => _controller.close();
}
```

---

## `test/fakes/fake_token_manager.dart`

```dart
import 'package:app/src/core/auth/token_manager.dart';
import 'package:app/src/core/storage/secure_storage.dart';

class FakeTokenManager extends TokenManager {
  FakeTokenManager() : super(FakeSecureStorage());

  String? accessToken;
  String? refreshToken;
  bool validToken = false;

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
  }

  @override
  Future<bool> hasValidToken() async => validToken;
}

class FakeSecureStorage implements SecureStorage {
  final _store = <String, String>{};

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async => _store[key] = value;

  @override
  Future<void> delete(String key) async => _store.remove(key);

  @override
  Future<void> deleteAll() async => _store.clear();
}
```

---

## `test/fakes/fake_biometric_service.dart`

```dart
import 'package:app/src/core/auth/biometric_service.dart';

class FakeBiometricService implements BiometricService {
  bool available = false;
  bool authenticateResult = false;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate({required String reason}) async =>
      authenticateResult;
}
```

---

## `test/features/auth/auth_cubit_test.dart`

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/src/core/auth/auth_state.dart';
import 'package:app/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:app/src/features/auth/presentation/cubit/auth_cubit_state.dart';

import '../../fakes/fake_auth_service.dart';

void main() {
  late FakeAuthService authService;

  setUp(() {
    authService = FakeAuthService();
  });

  tearDown(() {
    authService.dispose();
  });

  blocTest<AuthCubit, AuthCubitState>(
    'emits [AuthAuthenticated] when auth service reports authenticated',
    build: () => AuthCubit(authService),
    act: (cubit) => authService.login(email: 'a@b.com', password: '123456'),
    expect: () => [const AuthAuthenticated()],
  );

  blocTest<AuthCubit, AuthCubitState>(
    'emits [AuthAuthenticated, AuthUnauthenticated] on login then logout',
    build: () => AuthCubit(authService),
    act: (cubit) async {
      await authService.login(email: 'a@b.com', password: '123456');
      await authService.logout();
    },
    expect: () => [
      const AuthAuthenticated(),
      const AuthUnauthenticated(),
    ],
  );

  blocTest<AuthCubit, AuthCubitState>(
    'initial state is AuthUnknown',
    build: () => AuthCubit(authService),
    verify: (cubit) => expect(cubit.state, const AuthUnknown()),
  );
}
```

---

## `test/features/auth/sign_in_cubit_test.dart`

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/src/core/error/failure.dart';
import 'package:app/src/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:app/src/features/auth/presentation/cubit/sign_in_state.dart';

import '../../fakes/fake_auth_service.dart';

void main() {
  late FakeAuthService authService;

  setUp(() {
    authService = FakeAuthService();
  });

  tearDown(() {
    authService.dispose();
  });

  group('SignInCubit', () {
    blocTest<SignInCubit, SignInState>(
      'emits [SignInSubmitting, SignInSuccess] on successful login',
      build: () => SignInCubit(authService),
      act: (cubit) => cubit.login(email: 'a@b.com', password: '123456'),
      expect: () => [
        const SignInSubmitting(),
        const SignInSuccess(),
      ],
    );

    blocTest<SignInCubit, SignInState>(
      'emits [SignInSubmitting, SignInError] on login failure',
      build: () {
        authService.loginException = const FailureException(
          UnauthorizedFailure('Invalid credentials.'),
        );
        return SignInCubit(authService);
      },
      act: (cubit) => cubit.login(email: 'a@b.com', password: 'wrong'),
      expect: () => [
        const SignInSubmitting(),
        const SignInError(UnauthorizedFailure('Invalid credentials.')),
      ],
    );

    blocTest<SignInCubit, SignInState>(
      'emits [SignInSubmitting, SignInError] on network failure',
      build: () {
        authService.loginException = const FailureException(NetworkFailure());
        return SignInCubit(authService);
      },
      act: (cubit) => cubit.login(email: 'a@b.com', password: '123456'),
      expect: () => [
        const SignInSubmitting(),
        const SignInError(NetworkFailure()),
      ],
    );

    blocTest<SignInCubit, SignInState>(
      'guards duplicate submissions while submitting',
      build: () => SignInCubit(authService),
      seed: () => const SignInSubmitting(),
      act: (cubit) => cubit.login(email: 'a@b.com', password: '123456'),
      expect: () => <SignInState>[], // no state change — guarded
    );

    blocTest<SignInCubit, SignInState>(
      'reset returns to SignInInitial',
      build: () => SignInCubit(authService),
      seed: () => const SignInError(UnknownFailure()),
      act: (cubit) => cubit.reset(),
      expect: () => [const SignInInitial()],
    );
  });
}
```

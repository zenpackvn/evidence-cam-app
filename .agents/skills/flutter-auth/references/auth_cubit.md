# Auth — AuthCubit, SignInCubit & States

## `lib/src/features/auth/presentation/cubit/auth_cubit_state.dart`

Global auth state — consumed by the router guard and top-level `BlocProvider`.

```dart
import 'package:equatable/equatable.dart';

sealed class AuthCubitState extends Equatable {
  const AuthCubitState();

  @override
  List<Object?> get props => const [];
}

class AuthUnknown extends AuthCubitState {
  const AuthUnknown();
}

class AuthAuthenticated extends AuthCubitState {
  const AuthAuthenticated();
}

class AuthUnauthenticated extends AuthCubitState {
  const AuthUnauthenticated();
}
```

---

## `lib/src/features/auth/presentation/cubit/auth_cubit.dart`

Singleton — listens to `AuthService.status` and maps to cubit state. Provided at the app level above `MaterialApp`.

```dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/auth/auth_state.dart';
import 'auth_cubit_state.dart';

class AuthCubit extends Cubit<AuthCubitState> with SafeEmitMixin<AuthCubitState> {
  AuthCubit(this._authService) : super(const AuthUnknown()) {
    _subscription = _authService.status.listen(_onStatusChanged);
  }

  final AuthService _authService;
  late final StreamSubscription<AuthStatus> _subscription;

  void _onStatusChanged(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        safeEmit(const AuthAuthenticated());
      case AuthStatus.unauthenticated:
        safeEmit(const AuthUnauthenticated());
      case AuthStatus.unknown:
        safeEmit(const AuthUnknown());
    }
  }

  Future<void> logout() => _authService.logout();

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
```

---

## `lib/src/features/auth/presentation/cubit/sign_in_state.dart`

```dart
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';

sealed class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object?> get props => const [];
}

class SignInInitial extends SignInState {
  const SignInInitial();
}

class SignInSubmitting extends SignInState {
  const SignInSubmitting();
}

class SignInSuccess extends SignInState {
  const SignInSuccess();
}

class SignInError extends SignInState {
  const SignInError(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
```

---

## `lib/src/features/auth/presentation/cubit/sign_in_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/error/failure.dart';
import 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> with SafeEmitMixin<SignInState> {
  SignInCubit(this._authService) : super(const SignInInitial());
  final AuthService _authService;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (state is SignInSubmitting) return; // guard duplicate taps

    safeEmit(const SignInSubmitting());

    try {
      await _authService.login(email: email, password: password);
      safeEmit(const SignInSuccess());
    } on FailureException catch (e) {
      safeEmit(SignInError(e.failure));
    }
  }

  /// Reset to initial so the form can be reused after an error.
  void reset() => safeEmit(const SignInInitial());
}
```

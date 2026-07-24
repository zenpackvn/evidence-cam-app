# SafeEmitMixin

Mixin providing a guarded `emit` for any cubit. Use on cubits that don't follow the fetch-data lifecycle of `BaseCubit` — i.e., mutation cubits, form submissions, settings changes.

## File

`lib/src/core/base/safe_emit_mixin.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

/// Mixin providing a guarded emit for any cubit.
/// Use on cubits that don't follow the fetch-data lifecycle of [BaseCubit].
mixin SafeEmitMixin<S> on Cubit<S> {
  void safeEmit(S state) {
    if (!isClosed) emit(state);
  }
}
```

## Usage

```dart
class SignInCubit extends Cubit<SignInState> with SafeEmitMixin<SignInState> {
  SignInCubit({required this.authService}) : super(const SignInInitial());

  final AuthService authService;

  Future<void> signIn(String email, String password) async {
    safeEmit(const SignInLoading());
    try {
      await authService.signIn(email, password);
      safeEmit(const SignInSuccess());
    } on FailureException catch (e) {
      safeEmit(SignInError(e.failure));
    }
  }
}
```

## When to use

| | Choose |
|--|--|
| Fetching/displaying data | `BaseCubit<T>` |
| Mutations, form submissions, settings | `Cubit<S> with SafeEmitMixin<S>` |
| State must survive process death | `BaseHydratedCubit<S>` |

## Rules

- Always use `safeEmit()` instead of raw `emit()` — prevents `StateError` when async completes after cubit is disposed.
- `BaseCubit` already includes this mixin — do not add it again on `BaseCubit` subclasses.

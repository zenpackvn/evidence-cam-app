# Forms — Single-Page Form Example (Login)

A complete single-page form: state, cubit, and page widget.

## `lib/src/features/login/presentation/login_state.dart`

```dart
import '../../../core/forms/form_field_state.dart';

sealed class LoginState {
  const LoginState();
}

class LoginForm extends LoginState {
  const LoginForm({
    this.email = const FormFieldState<String>(),
    this.password = const FormFieldState<String>(),
    this.isSubmitting = false,
    this.serverError,
  });

  final FormFieldState<String> email;
  final FormFieldState<String> password;
  final bool isSubmitting;
  final String? serverError;

  bool get isValid => email.isValid && password.isValid;

  LoginForm copyWith({
    FormFieldState<String>? email,
    FormFieldState<String>? password,
    bool? isSubmitting,
    String? Function()? serverError,
  }) {
    return LoginForm(
      email: email ?? this.email,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      serverError: serverError != null ? serverError() : this.serverError,
    );
  }
}

class LoginSuccess extends LoginState {
  const LoginSuccess();
}
```

---

## `lib/src/features/login/presentation/login_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/forms/form_field_state.dart';
import '../../../core/forms/form_validator.dart';
import '../../../core/forms/form_mixin.dart';
import '../../auth/domain/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> with FormMixin<LoginState> {
  LoginCubit({required this.authRepository}) : super(const LoginForm());

  final AuthRepository authRepository;

  // ── Validators (composed once) ──

  final _emailValidator = composeValidators<String>([
    isRequired(),
    email(),
  ]);

  final _passwordValidator = composeValidators<String>([
    isRequired(),
    minLength(8),
  ]);

  // ── Field updates ──

  void emailChanged(String value) {
    final current = state;
    if (current is! LoginForm) return;

    final field = current.email.copyWith(
      value: value,
      isDirty: true,
      error: () => current.email.isTouched ? _emailValidator(value) : null,
    );
    emit(current.copyWith(email: field, serverError: () => null));
  }

  void emailFocusLost() {
    final current = state;
    if (current is! LoginForm) return;

    final field = current.email.copyWith(
      isTouched: true,
      error: () => _emailValidator(current.email.value),
    );
    emit(current.copyWith(email: field));
  }

  void passwordChanged(String value) {
    final current = state;
    if (current is! LoginForm) return;

    final field = current.password.copyWith(
      value: value,
      isDirty: true,
      error: () => current.password.isTouched ? _passwordValidator(value) : null,
    );
    emit(current.copyWith(password: field, serverError: () => null));
  }

  void passwordFocusLost() {
    final current = state;
    if (current is! LoginForm) return;

    final field = current.password.copyWith(
      isTouched: true,
      error: () => _passwordValidator(current.password.value),
    );
    emit(current.copyWith(password: field));
  }

  // ── Submission ──

  Future<void> submit() async {
    var current = state;
    if (current is! LoginForm) return;

    // Touch all fields to show errors.
    current = _validateAllFields(current);
    emit(current);
    if (!current.isValid) return;

    emit(current.copyWith(isSubmitting: true, serverError: () => null));

    try {
      await authRepository.login(
        email: current.email.value!,
        password: current.password.value!,
      );
      emit(const LoginSuccess());
    } on AuthFailure catch (e) {
      emit(current.copyWith(
        isSubmitting: false,
        serverError: () => e.message,
      ));
    }
  }

  // ── FormMixin ──

  @override
  LoginState validateAll(LoginState state) {
    if (state is! LoginForm) return state;
    return _validateAllFields(state);
  }

  @override
  bool isFormValid(LoginState state) {
    if (state is! LoginForm) return false;
    return state.isValid;
  }

  LoginForm _validateAllFields(LoginForm form) {
    return form.copyWith(
      email: form.email.copyWith(
        isTouched: true,
        error: () => _emailValidator(form.email.value),
      ),
      password: form.password.copyWith(
        isTouched: true,
        error: () => _passwordValidator(form.password.value),
      ),
    );
  }
}
```

---

## `lib/src/features/login/presentation/login_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/forms/form_field_state.dart';
import 'login_cubit.dart';
import 'login_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) context.read<LoginCubit>().emailFocusLost();
    });
    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) context.read<LoginCubit>().passwordFocusLost();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          // Navigate to home or show success.
        }
      },
      builder: (context, state) {
        if (state is! LoginForm) return const SizedBox.shrink();
        final cubit = context.read<LoginCubit>();

        return Scaffold(
          appBar: AppBar(title: const Text('Login')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _FormField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  fieldState: state.email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: cubit.emailChanged,
                ),
                const SizedBox(height: 16),
                _FormField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  fieldState: state.password,
                  label: 'Password',
                  obscureText: true,
                  onChanged: cubit.passwordChanged,
                ),
                if (state.serverError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.serverError!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isSubmitting ? null : cubit.submit,
                    child: state.isSubmitting
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.focusNode,
    required this.fieldState,
    required this.label,
    required this.onChanged,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FormFieldState<String> fieldState;
  final String label;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        errorText: fieldState.shouldShowError ? fieldState.error : null,
      ),
    );
  }
}
```

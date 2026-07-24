# Auth — Sign-In UI (Form & Page)

Uses `AppTextField`, `AppPasswordField` from [template-common-widgets.md](template-common-widgets.md) and `LoadingButton` from [template-loading.md](template-loading.md).

## `lib/src/features/auth/presentation/widgets/sign_in_form.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/common/app_text_field.dart';
import '../../../../core/widgets/common/app_password_field.dart';
import '../../../../core/widgets/loading/loading_button.dart';
import '../cubit/sign_in_cubit.dart';
import '../cubit/sign_in_state.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<SignInCubit>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
          ),
          const SizedBox(height: AppSpacing.md),
          AppPasswordField(
            controller: _passwordController,
            label: 'Password',
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: _validatePassword,
          ),
          const SizedBox(height: AppSpacing.xl),
          BlocBuilder<SignInCubit, SignInState>(
            builder: (context, state) {
              return LoadingButton(
                onPressed: _submit,
                label: 'Sign In',
                isLoading: state is SignInSubmitting,
                expanded: true,
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Validators ──

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }
}
```

---

## `lib/src/features/auth/presentation/pages/sign_in_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/app_navigator.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/dialog/app_dialog.dart';
import '../cubit/sign_in_cubit.dart';
import '../cubit/sign_in_state.dart';
import '../widgets/sign_in_form.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
      create: (_) => getIt<SignInCubit>(),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatelessWidget {
  const _SignInView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SignInCubit, SignInState>(
      listener: _handleState,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome Back',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sign in to continue',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const SignInForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleState(BuildContext context, SignInState state) {
    switch (state) {
      case SignInSuccess():
        // Router guard handles redirect — just navigate to home.
        getIt<AppNavigator>().goHome();
      case SignInError(:final failure):
        getIt<AppDialog>().showNotification(
          message: failure.message,
          type: AppNotifyType.error,
        );
        // Reset so the user can retry.
        context.read<SignInCubit>().reset();
      case SignInInitial() || SignInSubmitting():
        break;
    }
  }
}
```

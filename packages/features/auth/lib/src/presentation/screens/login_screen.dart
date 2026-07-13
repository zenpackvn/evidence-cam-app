import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../auth_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/widgets.dart';

/// StampMail sign-in screen.
///
/// Email/password submit dispatches to [AuthBloc]; the per-provider social
/// buttons are still local-only (ponytail — a provider event is added when
/// Google/Apple sign-in is wired end-to-end).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Temporary-lock window per SM-001 (5 wrong passwords → 15 minutes).
  static const _lockDuration = Duration(minutes: 15);

  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  AuthProvider? _socialLoading;
  String? _formError;
  Duration? _lockRemaining;
  Timer? _lockTimer;

  bool get _isLocked => _lockRemaining != null;

  @override
  void dispose() {
    _lockTimer?.cancel();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final bloc = context.read<AuthBloc>();
    // Ignore repeat submits while one is in flight (Enter key / double-tap).
    if (bloc.state is AuthSubmitting || _isLocked) return;
    setState(() => _formError = null);
    if (!_formKey.currentState!.validate()) return;
    bloc.add(
      AuthSignInRequested(
        username: _identifierController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  /// Maps a sign-in failure onto the design's form states: a locked account
  /// starts the countdown banner (F01-S05), anything else shows the error
  /// banner above the CTA (F01-S04).
  void _onFailure(Failure failure) {
    final l10n = context.l10n;
    if (failure is PermissionFailure) {
      _startLockCountdown();
      return;
    }
    setState(() {
      _formError = failure is InvalidCredentialsFailure
          ? l10n.smErrWrongCredentials
          : l10n.smErrGeneric;
    });
  }

  void _startLockCountdown() {
    _lockTimer?.cancel();
    setState(() {
      _formError = null;
      _lockRemaining = _lockDuration;
    });
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = _lockRemaining;
      if (remaining == null || remaining <= const Duration(seconds: 1)) {
        timer.cancel();
        setState(() => _lockRemaining = null);
      } else {
        setState(() => _lockRemaining = remaining - const Duration(seconds: 1));
      }
    });
  }

  String get _lockClock {
    final total = _lockRemaining?.inSeconds ?? 0;
    final minutes = (total ~/ 60).toString().padLeft(2, '0');
    final seconds = (total % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onSocial(AuthProvider provider) {
    if (provider == AuthProvider.google) {
      setState(() => _socialLoading = provider);
      context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
      return;
    }
    // ponytail: Apple/Facebook cần sign_in_with_apple / flutter_facebook_auth
    // (chưa thêm dependency) — báo sắp ra mắt thay vì im lặng.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider == AuthProvider.apple
              ? 'Đăng nhập Apple sắp ra mắt ✨'
              : 'Đăng nhập Facebook sắp ra mắt ✨',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Drive the submit spinner / disabled state off the bloc so it reflects the
    // real in-flight sign-in rather than a local flag.
    final submitting = context.watch<AuthBloc>().state is AuthSubmitting;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          setState(() => _socialLoading = null);
          _onFailure(state.failure);
        }
      },
      child: _buildScaffold(context, l10n, submitting),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    AppLocalizations l10n,
    bool submitting,
  ) {
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrandHeader().animateSlideDown(),
            const SizedBox(height: AppSpacing.md),
            AuthHeading(
              title: l10n.smLoginTitle,
              subtitle: l10n.smLoginSubtitle,
            ).animateSlideDown(delay: 50.ms),
            const SizedBox(height: 18),
            AuthTextField(
              controller: _identifierController,
              hint: l10n.smLoginIdentifierHint,
              icon: FontAwesomeIcons.envelope,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !submitting,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.smValEmailRequired
                  : null,
            ).animateSlideLeft(delay: 100.ms),
            const SizedBox(height: AppSpacing.md),
            AuthTextField(
              controller: _passwordController,
              hint: l10n.smLoginPasswordHint,
              icon: FontAwesomeIcons.lock,
              obscureText: _obscurePassword,
              enabled: !submitting,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _submit(),
              validator: (value) => (value == null || value.isEmpty)
                  ? l10n.smValPasswordRequired
                  : null,
              suffix: _PasswordToggle(
                obscured: _obscurePassword,
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ).animateSlideLeft(delay: 150.ms),
            // Locked (F01-S05): forgot link gives way to the lock banner and
            // the retry countdown; otherwise the design's forgot row, with the
            // error banner beneath it when sign-in failed (F01-S04).
            if (_isLocked) ...[
              const SizedBox(height: 10),
              AuthFormBanner(
                message: l10n.smLoginLockedMessage,
                icon: FontAwesomeIcons.lock,
              ).animateShake(),
              const SizedBox(height: 10),
              _LockCountdown(
                template: l10n.smLoginRetryIn(_lockClock),
                time: _lockClock,
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: submitting
                      ? null
                      : () => context.push(AuthRoutes.forgotPassword),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: context.brand.link,
                    // .pen: body-md (15) at w500 in the link blue.
                    textStyle: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Text(l10n.smLoginForgot),
                ),
              ),
              if (_formError != null) ...[
                const SizedBox(height: 10),
                AuthFormBanner(message: _formError!).animateShake(),
              ],
            ],
            const SizedBox(height: 14),
            AuthPrimaryButton(
              label: l10n.smLoginSubmit,
              onPressed: _submit,
              isLoading: submitting,
              locked: _isLocked,
            ).animateSlideUp(delay: 250.ms),
            const SizedBox(height: AppSpacing.lg),
            AuthSocialButtons(
              dividerLabel: l10n.smLoginDivider,
              loading: _socialLoading,
              labelFor: (p) => switch (p) {
                AuthProvider.apple => l10n.smContinueApple,
                AuthProvider.google => l10n.smContinueGoogle,
                AuthProvider.facebook => l10n.smContinueFacebook,
              },
              onPressed: _onSocial,
            ),
            const SizedBox(height: 14),
            _RegisterPrompt(disabled: submitting).animateSlideUp(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}

class _PasswordToggle extends StatelessWidget {
  const _PasswordToggle({required this.obscured, required this.onPressed});

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IconButton(
      tooltip: obscured ? l10n.loginShowPassword : l10n.loginHidePassword,
      onPressed: onPressed,
      icon: FaIcon(
        obscured ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
        size: 18,
        color: context.colorScheme.outline,
      ),
    );
  }
}

/// The "Thử lại sau 14:32" row (F01-S05): the localized template in
/// `text-secondary` with the ticking clock emphasized in coral w700.
class _LockCountdown extends StatelessWidget {
  const _LockCountdown({required this.template, required this.time});

  /// The full localized string with [time] already interpolated.
  final String template;
  final String time;

  @override
  Widget build(BuildContext context) {
    final base = context.textTheme.bodyMedium?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    final index = template.indexOf(time);
    if (index < 0) return Text(template, textAlign: TextAlign.center);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: template.substring(0, index)),
          TextSpan(
            text: time,
            style: TextStyle(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: template.substring(index + time.length)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt({required this.disabled});

  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l10n.smLoginNoAccount,
          // .pen footer: body-md in text-primary (not the muted secondary).
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        TextButton(
          onPressed: disabled ? null : () => context.go(AuthRoutes.register),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(l10n.smLoginRegisterCta),
        ),
      ],
    );
  }
}

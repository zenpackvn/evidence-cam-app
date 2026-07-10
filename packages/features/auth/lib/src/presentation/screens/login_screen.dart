import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../auth_routes.dart';
import '../widgets/widgets.dart';

/// StampMail sign-in screen.
///
/// UI-only for now: form state, the per-provider social spinners, and the
/// temporary-lock countdown are driven by local state so the screen can be
/// reviewed before the Firebase data layer is wired in. The submit path will
/// later dispatch to `AuthBloc`.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // ── Local demo state (to be replaced by AuthBloc) ──
  bool _submitting = false;
  AuthProvider? _socialLoading;
  String? _formError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _formError = null);
    if (!_formKey.currentState!.validate()) return;
    // ponytail: wired to AuthBloc.signIn in the data-layer pass.
    setState(() => _submitting = true);
  }

  void _onSocial(AuthProvider provider) {
    // ponytail: wired to AuthBloc provider sign-in later.
    setState(() => _socialLoading = provider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrandHeader().animateSlideDown(),
            const SizedBox(height: AppSpacing.xl),
            AuthHeading(
              title: l10n.smLoginTitle,
              subtitle: l10n.smLoginSubtitle,
            ).animateSlideDown(delay: 50.ms),
            const SizedBox(height: AppSpacing.xxxl),
            AuthTextField(
              controller: _identifierController,
              hint: l10n.smLoginIdentifierHint,
              icon: FontAwesomeIcons.envelope,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !_submitting,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.smValEmailRequired
                  : null,
            ).animateSlideLeft(delay: 100.ms),
            const SizedBox(height: AppSpacing.lg),
            AuthTextField(
              controller: _passwordController,
              hint: l10n.smLoginPasswordHint,
              icon: FontAwesomeIcons.lock,
              obscureText: _obscurePassword,
              enabled: !_submitting,
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
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _submitting
                    ? null
                    : () => context.push(AuthRoutes.forgotPassword),
                child: Text(l10n.smLoginForgot),
              ),
            ),
            if (_formError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _FormError(_formError!).animateShake(),
            ],
            const SizedBox(height: AppSpacing.lg),
            AuthPrimaryButton(
              label: l10n.smLoginSubmit,
              onPressed: _submit,
              isLoading: _submitting,
            ).animateSlideUp(delay: 250.ms),
            const SizedBox(height: AppSpacing.xxxl),
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
            const SizedBox(height: AppSpacing.xl),
            _RegisterPrompt(disabled: _submitting).animateSlideUp(delay: 500.ms),
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

class _FormError extends StatelessWidget {
  const _FormError(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colorScheme.error,
      ),
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
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
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

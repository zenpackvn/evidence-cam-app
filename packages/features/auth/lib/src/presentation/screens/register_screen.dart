import 'package:app_ui/app_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../auth_routes.dart';
import '../widgets/widgets.dart';

/// StampMail account-creation screen.
///
/// UI-only: form validation runs locally; the 13+ confirmation gates the submit
/// (BR-03 / AC-06). The submit path will later dispatch to `AuthBloc.register`.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _ageConfirmed = false;
  bool _ageError = false;

  bool _submitting = false;
  AuthProvider? _socialLoading;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final formValid = _formKey.currentState!.validate();
    setState(() => _ageError = !_ageConfirmed);
    if (!formValid || !_ageConfirmed) return;
    // ponytail: wired to AuthBloc.register in the data-layer pass.
    setState(() => _submitting = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      showBottomArt: false,
      topRightAsset: 'reg-top-right-plane.png',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrandHeader().animateSlideDown(),
            const SizedBox(height: AppSpacing.xl),
            AuthHeading(
              title: l10n.smRegisterTitle,
              subtitle: l10n.smRegisterSubtitle,
            ).animateSlideDown(delay: 50.ms),
            const SizedBox(height: AppSpacing.xxxl),
            AuthTextField(
              controller: _emailController,
              hint: l10n.smRegisterEmailHint,
              icon: FontAwesomeIcons.envelope,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !_submitting,
              autofillHints: const [AutofillHints.email],
              validator: _validateEmail,
            ).animateSlideLeft(delay: 100.ms),
            const SizedBox(height: AppSpacing.lg),
            AuthTextField(
              controller: _passwordController,
              hint: l10n.smLoginPasswordHint,
              icon: FontAwesomeIcons.lock,
              obscureText: _obscurePassword,
              enabled: !_submitting,
              autofillHints: const [AutofillHints.newPassword],
              validator: _validatePassword,
              suffix: _Toggle(
                obscured: _obscurePassword,
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ).animateSlideLeft(delay: 150.ms),
            const SizedBox(height: AppSpacing.lg),
            AuthTextField(
              controller: _confirmController,
              hint: l10n.smRegisterConfirmHint,
              icon: FontAwesomeIcons.lock,
              obscureText: _obscureConfirm,
              enabled: !_submitting,
              validator: _validateConfirm,
              suffix: _Toggle(
                obscured: _obscureConfirm,
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ).animateSlideLeft(delay: 200.ms),
            const SizedBox(height: AppSpacing.lg),
            _AgeConfirmation(
              value: _ageConfirmed,
              hasError: _ageError,
              onChanged: (v) => setState(() {
                _ageConfirmed = v;
                if (v) _ageError = false;
              }),
            ).animateSlideLeft(delay: 250.ms),
            const SizedBox(height: AppSpacing.xl),
            AuthPrimaryButton(
              label: l10n.smRegisterSubmit,
              onPressed: _submit,
              isLoading: _submitting,
            ).animateSlideUp(delay: 300.ms),
            const SizedBox(height: AppSpacing.xxxl),
            AuthSocialButtons(
              dividerLabel: l10n.smRegisterDivider,
              loading: _socialLoading,
              labelFor: (p) => switch (p) {
                AuthProvider.apple => l10n.smContinueApple,
                AuthProvider.google => l10n.smContinueGoogle,
                AuthProvider.facebook => l10n.smContinueFacebook,
              },
              onPressed: (p) => setState(() => _socialLoading = p),
            ),
            const SizedBox(height: AppSpacing.xl),
            _LoginPrompt(disabled: _submitting).animateSlideUp(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return context.l10n.smValEmailRequired;
    if (!_emailPattern.hasMatch(v)) return context.l10n.smValEmailInvalid;
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return context.l10n.smValPasswordRequired;
    if (v.length < 6) return context.l10n.smValPasswordMin;
    return null;
  }

  String? _validateConfirm(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return context.l10n.smValConfirmRequired;
    if (v != _passwordController.text) return context.l10n.smValConfirmMismatch;
    return null;
  }
}

final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

class _AgeConfirmation extends StatelessWidget {
  const _AgeConfirmation({
    required this.value,
    required this.hasError,
    required this.onChanged,
  });

  final bool value;
  final bool hasError;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final linkStyle = context.textTheme.bodyMedium?.copyWith(
      color: context.brand.link,
      fontWeight: FontWeight.w600,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                side: hasError
                    ? BorderSide(color: colorScheme.error, width: 2)
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  children: [
                    TextSpan(text: l10n.smRegisterAgePrefix),
                    TextSpan(
                      text: l10n.smRegisterTerms,
                      style: linkStyle,
                      recognizer: TapGestureRecognizer()..onTap = () {},
                    ),
                    TextSpan(text: l10n.smRegisterAnd),
                    TextSpan(
                      text: l10n.smRegisterPrivacy,
                      style: linkStyle,
                      recognizer: TapGestureRecognizer()..onTap = () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs, left: 36),
            child: Text(
              l10n.smRegisterAgeRequired,
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.obscured, required this.onPressed});

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: FaIcon(
        obscured ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
        size: 18,
        color: context.colorScheme.outline,
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.disabled});

  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l10n.smRegisterHaveAccount,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: disabled ? null : () => context.go(AuthRoutes.login),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(l10n.smRegisterLoginCta),
        ),
      ],
    );
  }
}

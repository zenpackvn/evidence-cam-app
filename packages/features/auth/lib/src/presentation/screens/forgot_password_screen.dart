import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../widgets/widgets.dart';

/// The four-step reset-password flow (F01-S11 → S14): collect an email, enter
/// the 6-digit code, choose a new password, then the success confirmation.
///
/// UI-only. The submit paths will later dispatch to `AuthBloc`; per BR-12 the
/// email step never reveals whether the address exists, and the OTP accepts
/// any 6 digits until the backend endpoint lands.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

enum _ForgotStep { email, code, reset, success }

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const _codeTtl = Duration(minutes: 10);
  static const _resendCooldown = Duration(seconds: 90);

  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();

  _ForgotStep _step = _ForgotStep.email;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String _code = '';

  Duration _expiresIn = _codeTtl;
  Duration _resendIn = _resendCooldown;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (!_emailFormKey.currentState!.validate()) return;
    // ponytail: dispatches AuthBloc.sendPasswordReset once the endpoint lands.
    setState(() {
      _step = _ForgotStep.code;
      _expiresIn = _codeTtl;
      _resendIn = _resendCooldown;
    });
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_expiresIn > Duration.zero) {
          _expiresIn -= const Duration(seconds: 1);
        }
        if (_resendIn > Duration.zero) {
          _resendIn -= const Duration(seconds: 1);
        }
      });
    });
  }

  void _resend() {
    setState(() {
      _expiresIn = _codeTtl;
      _resendIn = _resendCooldown;
    });
  }

  void _confirmCode() {
    if (_code.length != 6) return;
    _ticker?.cancel();
    setState(() => _step = _ForgotStep.reset);
  }

  void _savePassword() {
    if (!_resetFormKey.currentState!.validate()) return;
    setState(() => _step = _ForgotStep.success);
  }

  static String _clock(Duration d) {
    final m = (d.inSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDurations.fast,
      child: switch (_step) {
        _ForgotStep.email => _EmailStep(
          key: const ValueKey('email'),
          formKey: _emailFormKey,
          controller: _emailController,
          onSubmit: _sendCode,
        ),
        _ForgotStep.code => _CodeStep(
          key: const ValueKey('code'),
          email: _emailController.text.trim(),
          expiresIn: _clock(_expiresIn),
          resendIn: _resendIn == Duration.zero ? null : _clock(_resendIn),
          canContinue: _code.length == 6,
          onChanged: (code) => setState(() => _code = code),
          onResend: _resend,
          onContinue: _confirmCode,
        ),
        _ForgotStep.reset => _ResetStep(
          key: const ValueKey('reset'),
          formKey: _resetFormKey,
          newController: _newPasswordController,
          confirmController: _confirmController,
          obscureNew: _obscureNew,
          obscureConfirm: _obscureConfirm,
          onToggleNew: () => setState(() => _obscureNew = !_obscureNew),
          onToggleConfirm: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
          minSatisfied: _newPasswordController.text.length >= 6,
          onEdited: () => setState(() {}),
          onSubmit: _savePassword,
        ),
        _ForgotStep.success => const _SuccessStep(key: ValueKey('success')),
      },
    );
  }
}

// ─────────────────────────────────────────────────────── step 1 · email ──

class _EmailStep extends StatelessWidget {
  const _EmailStep({
    required this.formKey,
    required this.controller,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrandHeader().animateSlideDown(),
            const SizedBox(height: AppSpacing.xl),
            AuthHeading(
              title: l10n.smForgotTitle,
              subtitle: l10n.smForgotSubtitle,
              subtitleGap: AppSpacing.md,
            ).animateSlideDown(delay: 50.ms),
            const SizedBox(height: AppSpacing.xxl),
            AuthTextField(
              controller: controller,
              hint: l10n.smForgotEmailHint,
              icon: FontAwesomeIcons.envelope,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              onSubmitted: (_) => onSubmit(),
              validator: (value) => _validateEmail(context, value),
            ).animateSlideLeft(delay: 100.ms),
            const SizedBox(height: 22),
            AuthPrimaryButton(
              label: l10n.smForgotSubmit,
              onPressed: onSubmit,
            ).animateSlideUp(delay: 200.ms),
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                style: TextButton.styleFrom(
                  foregroundColor: context.brand.link,
                  textStyle: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(l10n.smForgotBackToLogin),
              ),
            ).animateSlideUp(delay: 250.ms),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(BuildContext context, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return context.l10n.smValEmailRequired;
    if (!_emailPattern.hasMatch(v)) return context.l10n.smValEmailInvalid;
    return null;
  }
}

// ──────────────────────────────────────────────────────── step 2 · code ──

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    required this.email,
    required this.expiresIn,
    required this.resendIn,
    required this.canContinue,
    required this.onChanged,
    required this.onResend,
    required this.onContinue,
    super.key,
  });

  final String email;
  final String expiresIn;

  /// Remaining cooldown, or `null` once resend unlocks.
  final String? resendIn;
  final bool canContinue;
  final ValueChanged<String> onChanged;
  final VoidCallback onResend;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      bottomAsset: 'otp-key-envelope.png',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthBrandHeader().animateSlideDown(),
          const SizedBox(height: 18),
          Text(
            l10n.smForgotCodeTitle,
            textAlign: TextAlign.center,
            style: context.textTheme.displayMedium,
          ).animateSlideDown(delay: 50.ms),
          const SizedBox(height: 10),
          Text(
            l10n.smForgotCodeSubtitle,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            email,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          OtpInput(
            onChanged: onChanged,
            onCompleted: (_) {},
          ).animateSlideLeft(delay: 100.ms),
          const SizedBox(height: 18),
          Center(
            child: _TwoTone(
              template: l10n.smVerifyExpiresIn(expiresIn),
              emphasis: expiresIn,
              emphasisColor: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: resendIn == null
                ? TextButton(
                    onPressed: onResend,
                    style: TextButton.styleFrom(
                      foregroundColor: context.brand.link,
                      textStyle: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(l10n.smVerifyResend),
                  )
                : _TwoTone(
                    template: l10n.smVerifyResendIn(resendIn!),
                    emphasis: l10n.smVerifyResend,
                    emphasisColor: context.brand.link,
                    emphasisWeight: FontWeight.w600,
                  ),
          ),
          const SizedBox(height: 18),
          AuthPrimaryButton(
            label: l10n.smForgotCodeContinue,
            onPressed: canContinue ? onContinue : () {},
          ).animateSlideUp(delay: 200.ms),
        ],
      ),
    );
  }
}

/// Renders [template] with the [emphasis] substring re-colored (the coral
/// countdown / blue resend link inside the localized sentence).
class _TwoTone extends StatelessWidget {
  const _TwoTone({
    required this.template,
    required this.emphasis,
    required this.emphasisColor,
    this.emphasisWeight = FontWeight.w700,
  });

  final String template;
  final String emphasis;
  final Color emphasisColor;
  final FontWeight emphasisWeight;

  @override
  Widget build(BuildContext context) {
    final base = context.textTheme.bodyLarge;
    final index = template.indexOf(emphasis);
    if (index < 0) return Text(template, style: base);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: template.substring(0, index)),
          TextSpan(
            text: emphasis,
            style: TextStyle(color: emphasisColor, fontWeight: emphasisWeight),
          ),
          TextSpan(text: template.substring(index + emphasis.length)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

// ─────────────────────────────────────────────────────── step 3 · reset ──

class _ResetStep extends StatelessWidget {
  const _ResetStep({
    required this.formKey,
    required this.newController,
    required this.confirmController,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.minSatisfied,
    required this.onEdited,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController newController;
  final TextEditingController confirmController;
  final bool obscureNew;
  final bool obscureConfirm;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final bool minSatisfied;
  final VoidCallback onEdited;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      bottomAsset: 'reset-lock-envelope.png',
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrandHeader().animateSlideDown(),
            const SizedBox(height: 18),
            AuthHeading(
              title: l10n.smResetTitle,
              subtitle: l10n.smResetSubtitle,
              subtitleGap: 10,
            ).animateSlideDown(delay: 50.ms),
            const SizedBox(height: AppSpacing.xl),
            AuthTextField(
              controller: newController,
              hint: l10n.smResetNewHint,
              icon: FontAwesomeIcons.lock,
              obscureText: obscureNew,
              autofillHints: const [AutofillHints.newPassword],
              validator: (v) => _validateNew(context, v),
              onChanged: (_) => onEdited(),
              suffix: _EyeToggle(obscured: obscureNew, onPressed: onToggleNew),
            ).animateSlideLeft(delay: 100.ms),
            const SizedBox(height: AppSpacing.md),
            AuthTextField(
              controller: confirmController,
              hint: l10n.smResetConfirmHint,
              icon: FontAwesomeIcons.lock,
              obscureText: obscureConfirm,
              validator: (v) => _validateConfirm(context, v),
              suffix: _EyeToggle(
                obscured: obscureConfirm,
                onPressed: onToggleConfirm,
              ),
            ).animateSlideLeft(delay: 150.ms),
            const SizedBox(height: 10),
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.circleCheck,
                  size: 18,
                  color: minSatisfied
                      ? context.semanticColors.success
                      : context.colorScheme.outline,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(l10n.smResetHintMin, style: context.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 18),
            AuthPrimaryButton(
              label: l10n.smResetSubmit,
              onPressed: onSubmit,
            ).animateSlideUp(delay: 200.ms),
            const SizedBox(height: 18),
            _BackToLoginDivider(label: l10n.smForgotBackToLogin),
          ],
        ),
      ),
    );
  }

  String? _validateNew(BuildContext context, String? value) {
    final v = value ?? '';
    if (v.isEmpty) return context.l10n.smValPasswordRequired;
    // BR: minimum 6 characters (business rule overrides the mock's 8).
    if (v.length < 6) return context.l10n.smValPasswordMin;
    return null;
  }

  String? _validateConfirm(BuildContext context, String? value) {
    final v = value ?? '';
    if (v.isEmpty) return context.l10n.smValConfirmRequired;
    if (v != newController.text) return context.l10n.smValConfirmMismatch;
    return null;
  }
}

class _EyeToggle extends StatelessWidget {
  const _EyeToggle({required this.obscured, required this.onPressed});

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
        color: context.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// "Quay lại đăng nhập" rendered between the divider hairlines, coral w600
/// (the .pen reset frame reuses `Divider/Label` with a link-styled label).
class _BackToLoginDivider extends StatelessWidget {
  const _BackToLoginDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final line = Expanded(
      child: Divider(
        color: scheme.outlineVariant.withValues(alpha: 0.9),
        thickness: 1.5,
      ),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: TextButton(
            onPressed: () => context.pop(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: scheme.primary,
              textStyle: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(label),
          ),
        ),
        line,
      ],
    );
  }
}

// ───────────────────────────────────────────────────── step 4 · success ──

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthBrandHeader().animateSlideDown(),
          const SizedBox(height: AppSpacing.xl),
          AuthHeading(
            title: l10n.smResetSuccessTitle,
            subtitle: l10n.smResetSuccessSubtitle,
            subtitleGap: AppSpacing.md,
          ).animateSlideDown(delay: 50.ms),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Image.asset(
              'assets/illustrations/success-envelope.png',
              package: 'feature_auth',
              width: 330,
              excludeFromSemantics: true,
            ),
          ).animateFadeIn(delay: 100.ms),
          const SizedBox(height: AppSpacing.xxl),
          AuthPrimaryButton(
            label: l10n.smResetSuccessCta,
            onPressed: () => context.pop(),
          ).animateSlideUp(delay: 200.ms),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(
                foregroundColor: context.colorScheme.primary,
                textStyle: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(l10n.smResetSuccessBack),
            ),
          ).animateSlideUp(delay: 250.ms),
        ],
      ),
    );
  }
}

final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

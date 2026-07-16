import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import '../widgets/widgets.dart';

/// StampMail email-verification WAITING screen (F01-S08, SM-001 BR-02): the
/// user was emailed a confirmation LINK; this screen shows where it went, lets
/// them resend after a cooldown, and checks verification when they return.
///
/// The link opens Firebase's hosted confirm page on the web; after confirming
/// the user comes back and taps "Tôi đã xác nhận".
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    required this.email,
    this.onVerified,
    this.onResend,
    this.onCheckVerified,
    super.key,
  });

  final String email;

  /// Called once verification is confirmed (flow continues to
  /// choose-username, F01-S08 → S09).
  final VoidCallback? onVerified;

  /// Re-sends the verification email (each send invalidates the old link).
  final Future<void> Function()? onResend;

  /// Returns whether the email is verified (fresh from the server).
  final Future<bool> Function()? onCheckVerified;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  /// SM-001 BR-02: the link stays valid for thirty minutes.
  static const int _expirySeconds = 30 * 60;

  /// SM-001 BR-02: resend unlocks after sixty seconds.
  static const int _resendCooldownSeconds = 60;

  Timer? _timer;
  int _expiresIn = _expirySeconds;
  int _resendIn = _resendCooldownSeconds;
  bool _notVerifiedYet = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_expiresIn > 0) _expiresIn--;
        if (_resendIn > 0) _resendIn--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    if (_checking) return;
    setState(() => _checking = true);
    final verified = await widget.onCheckVerified?.call() ?? true;
    if (!mounted) return;
    setState(() {
      _checking = false;
      _notVerifiedYet = !verified;
    });
    if (verified) widget.onVerified?.call();
  }

  Future<void> _resend() async {
    setState(() {
      _resendIn = _resendCooldownSeconds;
      _expiresIn = _expirySeconds;
      _notVerifiedYet = false;
    });
    await widget.onResend?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canResend = _resendIn == 0;
    final email = widget.email.isEmpty ? 'hello@stampmail.com' : widget.email;
    return AuthScaffold(
      topLeftAsset: 'verify-top-left-letter.png',
      topLeftWidth: 90,
      topRightAsset: 'reg-top-right-plane.png',
      topRightWidth: 117,
      bottomAsset: 'verify-envelope-check.png',
      bottomWidth: 338,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthBrandHeader().animateSlideDown(),
          const SizedBox(height: AppSpacing.xxl),
          AuthHeading(title: l10n.smVerifyTitle).animateSlideDown(delay: 50.ms),
          const SizedBox(height: AppSpacing.md),
          _VerifySubtitle(email: email).animateSlideDown(delay: 80.ms),
          const SizedBox(height: AppSpacing.xxxl),
          AuthPrimaryButton(
            label: l10n.smVerifyCheckCta,
            onPressed: _checking ? () {} : _check,
          ).animateSlideUp(delay: 150.ms),
          if (_notVerifiedYet) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.smVerifyInvalidCode,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.error,
              ),
            ).animateShake(),
          ],
          const SizedBox(height: AppSpacing.xxl),
          Text(
            l10n.smVerifyExpiresIn(_format(_expiresIn)),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton(
              onPressed: canResend ? _resend : null,
              child: Text(
                canResend
                    ? l10n.smVerifyResend
                    : l10n.smVerifyResendIn(_format(_resendIn)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

/// The verify subtitle with the email address emphasized, by splitting the
/// localized string around the interpolated address.
class _VerifySubtitle extends StatelessWidget {
  const _VerifySubtitle({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final full = context.l10n.smVerifySubtitle(email);
    final index = full.indexOf(email);
    final base = context.textTheme.bodyLarge?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: index < 0
            ? [TextSpan(text: full)]
            : [
                TextSpan(text: full.substring(0, index)),
                TextSpan(
                  text: email,
                  style: base?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: full.substring(index + email.length)),
              ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

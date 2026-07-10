import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import '../widgets/widgets.dart';

/// StampMail email-verification screen: a 6-digit code with an expiry countdown
/// and a resend action that unlocks after a short cooldown.
///
/// UI-only. `onCompleted` will later verify the code via `AuthBloc`; the design
/// uses an OTP code, which on Firebase requires a Cloud Function issuing codes
/// (the SDK's native path is a verification *link*) — see the data-layer plan.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({required this.email, super.key});

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const int _expirySeconds = 10 * 60;
  static const int _resendCooldownSeconds = 45;

  Timer? _timer;
  int _expiresIn = _expirySeconds;
  int _resendIn = _resendCooldownSeconds;
  bool _hasError = false;

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

  void _onCompleted(String code) {
    // ponytail: verify via AuthBloc; here just demo an error state.
    setState(() => _hasError = code != '123456');
  }

  void _resend() {
    // ponytail: re-request the code via AuthBloc.
    setState(() {
      _resendIn = _resendCooldownSeconds;
      _expiresIn = _expirySeconds;
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canResend = _resendIn == 0;
    final email = widget.email.isEmpty ? 'hello@stampmail.com' : widget.email;
    return AuthScaffold(
      bottomAsset: 'verify-envelope-check.png',
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
          OtpInput(
            hasError: _hasError,
            onChanged: (_) {
              if (_hasError) setState(() => _hasError = false);
            },
            onCompleted: _onCompleted,
          ).animateSlideUp(delay: 150.ms),
          if (_hasError) ...[
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

/// The verify subtitle with the email address emphasized on its own line, by
/// splitting the localized string around the interpolated address.
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

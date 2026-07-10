import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../widgets/widgets.dart';

/// StampMail forgot-password screen: collect an email and send a reset code.
///
/// UI-only. The submit path will later dispatch to `AuthBloc` and navigate to
/// the OTP screen; per BR-12 the response never reveals whether the email
/// exists.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // ponytail: wired to AuthBloc.sendPasswordReset in the data-layer pass.
    setState(() => _submitting = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      bottomAsset: 'forgot-envelope.png',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrandHeader().animateSlideDown(),
            const SizedBox(height: AppSpacing.xxl),
            AuthHeading(
              title: l10n.smForgotTitle,
              subtitle: l10n.smForgotSubtitle,
            ).animateSlideDown(delay: 50.ms),
            const SizedBox(height: AppSpacing.xxxl),
            AuthTextField(
              controller: _emailController,
              hint: l10n.smForgotEmailHint,
              icon: FontAwesomeIcons.envelope,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              enabled: !_submitting,
              autofillHints: const [AutofillHints.email],
              onSubmitted: (_) => _submit(),
              validator: _validateEmail,
            ).animateSlideLeft(delay: 100.ms),
            const SizedBox(height: AppSpacing.xl),
            AuthPrimaryButton(
              label: l10n.smForgotSubmit,
              onPressed: _submit,
              isLoading: _submitting,
            ).animateSlideUp(delay: 200.ms),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: TextButton(
                onPressed: _submitting ? null : () => context.pop(),
                child: Text(l10n.smForgotBackToLogin),
              ),
            ).animateSlideUp(delay: 250.ms),
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
}

final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

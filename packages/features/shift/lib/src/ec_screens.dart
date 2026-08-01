/// EvidenceCam screens, built pixel-perfect from
/// `specs/projects/evidencecam/design-spec/pencil-app-dna.pen`.
///
/// These are presentational (data-in, callbacks-out) so they can be verified in
/// isolation now and wired to auth/router as those land. Every dimension, gap,
/// font size/weight and color is taken directly from the design file — compare
/// against `PenF101`/`PenF102` (the design file transcribed verbatim by
/// `tool/pen2dart.py`) and the goldens under `test/design/goldens/`.
library;

import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoPageScaffold, CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:localization/localization.dart';

// Shared text styles (Inter is inherited from the CupertinoApp text theme).
TextStyle _t(double size, FontWeight weight, Color color) =>
    TextStyle(fontSize: size, fontWeight: weight, color: color, height: 1.3);

/// Splash (`F1-01`) — logo, wordmark, sparkle rule, three-line tagline, hero
/// art, primary "Bắt đầu" button and the version line.
class EcSplashScreen extends StatelessWidget {
  const EcSplashScreen({this.onStart, this.version = 'v1.0.0', super.key});

  final VoidCallback? onStart;
  final String version;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // The design lays this screen out absolutely on an 844pt artboard: the
    // brand block hangs off the top, the button and version off the bottom,
    // and the slack between them lives around the hero art. Devices are
    // taller than the artboard, so the art takes the slack instead of a
    // fixed spacer — that keeps every other gap at its design value.
    // Every node on this screen is `layoutPosition: absolute` in the design,
    // so it is placed by coordinate rather than flowed: the brand block is
    // anchored to the top, the button and version to the bottom, and a taller
    // device only grows the gap around the hero art.
    return PenScreen(
      scrollable: false,
      child: Stack(
        children: [
          Positioned(
            left: 135,
            top: 52,
            child: Image.asset(
              'assets/design/logo.png',
              package: 'ec_ui',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 178,
            child: PenText(
              'ZenPack',
              size: 36,
              color: PenColors.primary,
              weight: FontWeight.w800,
              align: TextAlign.center,
              softWrap: false,
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 239,
            child: PenOrnamentRule(lineWidth: 78, gap: 1, sparkleSize: 14),
          ),
          Positioned(
            left: 30,
            top: 274,
            width: 330,
            child: Column(
              // The design centres each tagline line inside the 330pt column.
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final line in [
                  l10n.onboardingTaglineOne,
                  l10n.onboardingTaglineTwo,
                  l10n.onboardingTaglineThree,
                ]) ...[
                  if (line != l10n.onboardingTaglineOne)
                    const SizedBox(height: 8),
                  PenText(
                    line,
                    size: 20,
                    color: PenColors.ink,
                    weight: FontWeight.w500,
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            left: 24,
            top: 365,
            width: 342,
            height: 325,
            child: Image.asset(
              'assets/design/flow1-zenpack-hero-art-splash.png',
              package: 'ec_ui',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 30,
            right: 30,
            bottom: 64,
            child: PenPrimaryButton(
              label: l10n.onboardingStart,
              height: 64,
              labelSize: 20,
              onPressed: onStart,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 33,
            child: PenText(
              version,
              size: 12,
              color: PenColors.mut,
              align: TextAlign.center,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}

/// Login — language chip, title, email/password fields, forgot link, primary
/// login button, "hoặc" divider, Google + Apple buttons, register footer.
class EcLoginScreen extends StatelessWidget {
  const EcLoginScreen({
    this.emailController,
    this.passwordController,
    this.onLogin,
    this.onForgot,
    this.onGoogle,
    this.onApple,
    this.onRegister,
    this.onLanguage,
    super.key,
  });

  final TextEditingController? emailController;
  final TextEditingController? passwordController;
  final VoidCallback? onLogin;
  final VoidCallback? onForgot;
  final VoidCallback? onGoogle;
  final VoidCallback? onApple;
  final VoidCallback? onRegister;
  final VoidCallback? onLanguage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      child: PenScreen(
        child: Stack(
          children: [
            Padding(
              // Design `Body`: padding [14, 26, 0, 26]; `Form` opens 18 under
              // the title block and separates its groups by 25.
              padding: const EdgeInsets.fromLTRB(26, 14, 26, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PenBrandHeader(
                    title: l10n.authSignIn,
                    subtitle: l10n.authChooseMethod,
                  ),
                  const SizedBox(height: 18),
                  PenField(
                    label: 'Email',
                    hint: l10n.authEmailPlaceholder,
                    icon: LucideIcons.mail,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: l10n.authEmailRequired,
                      ),
                      FormBuilderValidators.email(
                        errorText: l10n.authEmailInvalid,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  PenField(
                    label: l10n.authPassword,
                    hint: l10n.authPasswordPlaceholder,
                    icon: LucideIcons.lock,
                    controller: passwordController,
                    obscure: true,
                    validator: FormBuilderValidators.required(
                      errorText: l10n.authPasswordRequired,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: PenLink(l10n.authForgotPassword, onTap: onForgot),
                  ),
                  const SizedBox(height: 25),
                  _ValidatedPrimaryButton(
                    label: l10n.authSignIn,
                    onValid: onLogin,
                  ),
                  const SizedBox(height: 25),
                  PenLabelledRule(l10n.authOr),
                  const SizedBox(height: 25),
                  PenOutlineButton(
                    label: l10n.authSignInGoogle,
                    icon: const PenGoogleMark(),
                    onPressed: onGoogle,
                  ),
                  const SizedBox(height: 12),
                  PenOutlineButton(
                    label: l10n.authSignInApple,
                    icon: const PenAppleMark(),
                    onPressed: onApple,
                  ),
                  const SizedBox(height: 25),
                  PenPromptLink(
                    prompt: l10n.authNoAccountPrompt.trim(),
                    action: l10n.authRegister,
                    onTap: onRegister,
                  ),
                ],
              ),
            ),
            Positioned(
              // Design `LangPill`: x=294, y=14 on the 390pt artboard.
              top: 14,
              right: 12,
              child: PenLangPill(label: 'VI', onTap: onLanguage),
            ),
          ],
        ),
      ),
    );
  }
}

// --- shared pieces (pixel specs from pencil-new.pen) ---

class _EcPrimaryButton extends StatelessWidget {
  const _EcPrimaryButton({required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) =>
      // Design `BtnLogin`: 62pt tall, 14pt radius, 18/700 label — the shared
      // primary button, not the older 52/12/16 one.
      PenPrimaryButton(label: label, onPressed: onPressed);
}

/// Primary button that validates the enclosing [Form] before firing [onValid];
/// invalid fields surface their inline errors and [onValid] is skipped.
class _ValidatedPrimaryButton extends StatelessWidget {
  const _ValidatedPrimaryButton({required this.label, this.onValid});
  final String label;
  final VoidCallback? onValid;

  @override
  Widget build(BuildContext context) {
    return _EcPrimaryButton(
      label: label,
      onPressed: onValid == null
          ? null
          : () {
              if (Form.of(context).validate()) onValid!();
            },
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: BrandColors.line),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 14, color: BrandColors.ink),
            const SizedBox(width: 5),
            Text('VI', style: _t(12, FontWeight.w600, BrandColors.ink)),
            const SizedBox(width: 5),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 12,
              color: BrandColors.mut,
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatefulWidget {
  const _Field({
    required this.label,
    required this.hint,
    this.controller,
    this.obscure = false,
    this.trailing,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final IconData? trailing;
  final TextInputType? keyboardType;

  /// When set, the field registers with the enclosing [Form] and shows an
  /// inline error beneath itself; null keeps the plain (unvalidated) field.
  final String? Function(String?)? validator;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  // Local reveal state; the [trailing] eye toggles it on obscured fields.
  late bool _obscure = widget.obscure;

  @override
  Widget build(BuildContext context) {
    if (widget.validator == null) return _decorated(null);
    return FormField<String>(
      initialValue: widget.controller?.text ?? '',
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: _decorated,
    );
  }

  Widget _decorated(FormFieldState<String>? state) {
    final error = state?.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: _t(14, FontWeight.w500, BrandColors.ink)),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: ecSquircleDecoration(
            radius: 12,
            color: BrandColors.bg,
            side: BorderSide(
              color: error == null ? BrandColors.line : BrandColors.rec,
            ),
          ),
          child: CupertinoTextField(
            controller: widget.controller,
            onChanged: state?.didChange,
            obscureText: _obscure,
            keyboardType: widget.keyboardType,
            style: _t(14, FontWeight.w400, BrandColors.ink),
            placeholder: widget.hint,
            placeholderStyle: _t(14, FontWeight.w400, BrandColors.mut),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            // The squircle border comes from the wrapping DecoratedBox.
            decoration: const BoxDecoration(),
            suffix: _buildSuffix(),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(error, style: _t(12, FontWeight.w400, BrandColors.rec)),
        ],
      ],
    );
  }

  Widget? _buildSuffix() {
    final trailing = widget.trailing;
    if (trailing == null) return null;
    // On obscured fields the eye is a live reveal toggle; otherwise decorative.
    final icon = widget.obscure
        ? Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 18,
            color: BrandColors.mut,
          )
        : Icon(trailing, size: 18, color: BrandColors.mut);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: widget.obscure
          ? EcTap(
              onTap: () => setState(() => _obscure = !_obscure),
              child: icon,
            )
          : icon,
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: BrandColors.line, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            context.l10n.authOr,
            style: _t(12, FontWeight.w400, BrandColors.mut),
          ),
        ),
        const Expanded(child: Divider(color: BrandColors.line, height: 1)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.background,
    required this.borderColor,
    required this.foreground,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final Color background;
  final Color borderColor;
  final Color foreground;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onPressed,
      child: Container(
        height: 54,
        decoration: ecSquircleDecoration(
          radius: 12,
          color: background,
          side: BorderSide(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: _t(14, FontWeight.w500, foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Google's 4-color "G" mark, verbatim from the `GoogleG` paths in
/// pencil-new.pen (viewBox 48x48), replacing the single-color material glyph.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) =>
      SvgPicture.string(_googleGSvg, width: 18, height: 18);
}

const _googleGSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
<path fill="#4285F4" d="M45.12 24.5c0-1.56-.14-3.06-.4-4.5H24v8.51h11.84c-.51 2.75-2.06 5.08-4.39 6.64v5.52h7.11c4.16-3.83 6.56-9.47 6.56-16.17z"/>
<path fill="#34A853" d="M24 46c5.94 0 10.92-1.97 14.56-5.33l-7.11-5.52c-1.97 1.32-4.49 2.1-7.45 2.1-5.73 0-10.58-3.87-12.31-9.07H4.34v5.7C7.96 41.07 15.4 46 24 46z"/>
<path fill="#FBBC05" d="M11.69 28.18C11.25 26.86 11 25.45 11 24s.25-2.86.69-4.18v-5.7H4.34C2.85 17.09 2 20.45 2 24s.85 6.91 2.34 9.88l7.35-5.7z"/>
<path fill="#EA4335" d="M24 10.75c3.23 0 6.13 1.11 8.41 3.29l6.31-6.31C34.91 4.18 29.93 2 24 2 15.4 2 7.96 6.93 4.34 14.12l7.35 5.7c1.73-5.2 6.58-9.07 12.31-9.07z"/>
</svg>''';

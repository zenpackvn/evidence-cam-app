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

import 'ec_form_limits.dart';

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
    // Every node on this screen is `layoutPosition: absolute` in the design,
    // so it is placed by coordinate rather than flowed: the brand block is
    // anchored to the top, the button and version to the bottom, and the hero
    // art takes whatever slack is left between them.
    //
    // Those coordinates describe a 390x844 artboard, so anything centred in
    // the design is expressed as an equal left/right pair rather than a `left`
    // plus a `width` — a device narrower than 390 would otherwise push it off
    // centre by half the difference. The art is likewise anchored top *and*
    // bottom so a screen shorter than 844 shrinks it instead of letting the
    // button ride over it. On a 390x844 box both spellings are identical.
    return PenScreen(
      scrollable: false,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 52,
            child: Center(
              child: Image.asset(
                'assets/design/logo.png',
                package: 'ec_ui',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
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
            right: 30,
            top: 274,
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
            right: 24,
            top: 365,
            // The button is 64 tall and sits 64 off the bottom; the design
            // leaves 26 between it and the art, so 154 is the art's floor.
            bottom: 154,
            // `contain` over `cover`: the asset is exactly 3x the design's
            // 342x325 box, so this is pixel-identical at the artboard size,
            // but a shorter screen scales the whole illustration down instead
            // of cropping it to a strip.
            child: Image.asset(
              'assets/design/flow1-zenpack-hero-art-splash.png',
              package: 'ec_ui',
              fit: BoxFit.contain,
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
    this.showApple = true,
    this.onRegister,
    this.onLanguage,
    this.languageLabel = 'VI',
    super.key,
  });

  final TextEditingController? emailController;
  final TextEditingController? passwordController;
  final VoidCallback? onLogin;
  final VoidCallback? onForgot;
  final VoidCallback? onGoogle;
  final VoidCallback? onApple;

  /// Whether to offer Apple sign-in at all. False on platforms with no native
  /// Apple ID sheet, where the button could only ever fail.
  final bool showApple;
  final VoidCallback? onRegister;
  final VoidCallback? onLanguage;

  /// Mã ngôn ngữ ĐANG dùng, viết hoa — "VI", "EN", "TH"…
  ///
  /// Trước đây viên này in cứng chữ "VI": đổi sang tiếng Anh xong cả màn hình
  /// dịch hết, riêng viên ngôn ngữ vẫn ghi "VI". Người dùng đọc ra là lượt đổi
  /// không ăn và bấm lại lần nữa — đổi ngược về đúng thứ tiếng họ vừa bỏ.
  final String languageLabel;

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
                    maxLength: kEmailMaxLength,
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
                    maxLength: kPasswordMaxLength,
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
                  if (showApple) ...[
                    const SizedBox(height: 12),
                    PenOutlineButton(
                      label: l10n.authSignInApple,
                      icon: const PenAppleMark(),
                      onPressed: onApple,
                    ),
                  ],
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
              child: PenLangPill(label: languageLabel, onTap: onLanguage),
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

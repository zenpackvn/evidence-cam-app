/// EvidenceCam "Flow 1 — Vào ca" screens, built pixel-perfect from
/// `specs/projects/evidencecam/design-spec/pencil-new.pen`.
///
/// These are presentational (data-in, callbacks-out), following the same
/// conventions established in `ec_screens.dart`: every dimension, gap, font
/// size/weight and color is taken directly from the design file.
library;

import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoActionSheet,
        CupertinoActionSheetAction,
        CupertinoActivityIndicator,
        CupertinoPageScaffold,
        CupertinoTextField,
        showCupertinoModalPopup;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:localization/localization.dart';
import 'package:shared_contracts/shared_contracts.dart';

// Shared text style (Inter is inherited from the CupertinoApp text theme).
TextStyle _t(double size, FontWeight weight, Color color) =>
    TextStyle(fontSize: size, fontWeight: weight, color: color, height: 1.3);

// --- shared buttons ---

class _EcPrimaryButton extends StatelessWidget {
  const _EcPrimaryButton({required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return EcTap(
      onTap: onPressed,
      child: Container(
        height: 52,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: ecSquircleDecoration(
          radius: 12,
          color: enabled
              ? BrandColors.dark
              : BrandColors.dark.withValues(alpha: 0.4),
        ),
        child: Text(label, style: _t(16, FontWeight.w600, Colors.white)),
      ),
    );
  }
}

/// Primary button that validates the enclosing [Form] before firing [onValid];
/// invalid fields surface their inline errors and [onValid] is skipped.
class _ValidatedPrimaryButton extends StatelessWidget {
  const _ValidatedPrimaryButton({
    required this.label,
    this.icon,
    this.onValid,
  });
  final String label;
  final IconData? icon;
  final VoidCallback? onValid;

  @override
  Widget build(BuildContext context) {
    return PenPrimaryButton(
      label: label,
      icon: icon,
      onPressed: onValid == null
          ? null
          : () {
              if (Form.of(context).validate()) onValid!();
            },
    );
  }
}

class _EcOutlineButton extends StatelessWidget {
  const _EcOutlineButton({required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onPressed,
      child: Container(
        height: 52,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: ecSquircleDecoration(
          radius: 12,
          color: BrandColors.bg,
          side: const BorderSide(color: BrandColors.line),
        ),
        child: Text(label, style: _t(16, FontWeight.w500, BrandColors.ink)),
      ),
    );
  }
}

// --- shared chrome ---

class _BackButton extends StatelessWidget {
  const _BackButton({this.onTap, this.size = 22});
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: Icon(Icons.arrow_back_ios_new, size: size, color: BrandColors.ink),
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
// ponytail: duplicated from ec_screens.dart; promote to a shared file if a
// third screen needs it.
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

/// Small caps section header used inside settings-style screens (e.g.
/// "THÀNH VIÊN", "CÀI ĐẶT SHOP").
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: _t(12, FontWeight.w600, BrandColors.mut));
  }
}

/// Header used by screens pushed on top of a list (back arrow + title),
/// e.g. CreateShop, ShopMgmt, ShopDetail.
class _SimpleHeader extends StatelessWidget {
  const _SimpleHeader({required this.title, this.onBack});
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _BackButton(onTap: onBack, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: _t(16, FontWeight.w600, BrandColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shop header (`C/ShopHeader`): back arrow + shop name on the left, an
/// upload-queue count chip on the right. Used by the main tabs (e.g.
/// HomeOrders).
class _ShopHeader extends StatelessWidget {
  const _ShopHeader({
    required this.shopName,
    this.queueCount = 0,
    this.onBack,
    this.onQueueTap,
  });

  final String shopName;
  final int queueCount;
  final VoidCallback? onBack;
  final VoidCallback? onQueueTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 0),
      child: Row(
        children: [
          PenBackButton(onTap: onBack),
          const SizedBox(width: 14),
          Expanded(
            child: PenText(
              shopName,
              size: 24,
              color: PenColors.ink,
              weight: FontWeight.w800,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          EcTap(
            onTap: onQueueTap,
            child: PenBox(
              fill: PenColors.bg,
              radius: 999,
              axis: PenAxis.row,
              gap: 8,
              cross: CrossAxisAlignment.center,
              hugMain: true,
              padding: const EdgeInsets.symmetric(
                vertical: 9,
                horizontal: 15,
              ),
              children: [
                const Icon(
                  LucideIcons.cloudUpload,
                  size: 20,
                  color: PenColors.ink,
                ),
                PenText(
                  '$queueCount',
                  size: 16,
                  color: PenColors.ink,
                  weight: FontWeight.w700,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom tab bar (`C/Nav3`): Vận đơn / Ghi hình / Tài khoản.
class _Nav3Bar extends StatelessWidget {
  const _Nav3Bar({
    required this.activeIndex,
    this.onOrders,
    this.onRecord,
    this.onAccount,
  });

  final int activeIndex;
  final VoidCallback? onOrders;
  final VoidCallback? onRecord;
  final VoidCallback? onAccount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenTabBar(
      activeIndex: activeIndex,
      tabs: [
        (LucideIcons.package, l10n.navOrders, onOrders),
        (LucideIcons.camera, l10n.navRecord, onRecord),
        (LucideIcons.user, l10n.navAccount, onAccount),
      ],
    );
  }
}

/// Shared frame for the two modal dialogs (CreateType, ConfirmDelete): a
/// dimmed backdrop with a centered white rounded card, 12px gap between
/// [children].
class _EcDialogFrame extends StatelessWidget {
  const _EcDialogFrame({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Tap outside the card closes the dialog (barrier dismiss).
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: ecSquircleDecoration(
                      radius: 16,
                      color: BrandColors.bg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < children.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          children[i],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Register
// ============================================================================

/// Dịch [PasswordProblem] sang chuỗi hiển thị. Trả `null` khi mật khẩu đạt —
/// đúng giao kèo của `FormFieldValidator`.
String? _passwordError(BuildContext context, String? value, String? email) =>
    switch (passwordProblem(value, email: email)) {
      PasswordProblem.tooShort => context.l10n.passwordMin8Error,
      PasswordProblem.needsLetterAndDigit =>
        context.l10n.passwordNeedsLetterDigit,
      PasswordProblem.tooCommon => context.l10n.passwordTooCommon,
      null => null,
    };

/// Register — same chrome as Login (lang chip, title) plus name/email/phone/
/// password/confirm fields, a policy checkbox, primary "Tạo tài khoản"
/// button, an email-merge note, a login footer link and Google/Apple buttons.
class EcRegisterScreen extends StatelessWidget {
  const EcRegisterScreen({
    this.nameController,
    this.emailController,
    this.phoneController,
    this.passwordController,
    this.confirmPasswordController,
    this.policyAccepted = true,
    this.onPolicyChanged,
    this.onBack,
    this.onLanguage,
    this.onRegister,
    this.onViewPolicy,
    this.onGoogle,
    this.onApple,
    this.onLogin,
    super.key,
  });

  final TextEditingController? nameController;
  final TextEditingController? emailController;
  final TextEditingController? phoneController;
  final TextEditingController? passwordController;
  final TextEditingController? confirmPasswordController;

  /// Whether the policy checkbox is currently checked. The design only
  /// specifies the checked visual (dark fill + check mark); defaults to
  /// `true` to match it.
  final bool policyAccepted;
  final ValueChanged<bool>? onPolicyChanged;
  final VoidCallback? onBack;
  final VoidCallback? onLanguage;
  final VoidCallback? onRegister;
  final VoidCallback? onViewPolicy;
  final VoidCallback? onGoogle;
  final VoidCallback? onApple;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      child: PenScreen(
        child: Stack(
          children: [
            Padding(
              // Design `Body`: padding [14, 26, 0, 26]; `Form` opens 16 below
              // the title block and spaces every row by 8.
              padding: const EdgeInsets.fromLTRB(26, 14, 26, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PenBrandHeader(
                    title: l10n.authRegister,
                    subtitle: l10n.registerCreateAccountSubtitle,
                  ),
                  const SizedBox(height: 16),
                  PenStackedField(
                    icon: LucideIcons.user,
                    label: l10n.registerFullName,
                    controller: nameController,
                    validator: FormBuilderValidators.required(
                      errorText: l10n.registerFullNameRequired,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PenStackedField(
                    icon: LucideIcons.mail,
                    label: 'Email',
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
                  const SizedBox(height: 8),
                  PenStackedField(
                    icon: LucideIcons.phone,
                    label: l10n.registerPhone,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 8),
                  PenStackedField(
                    icon: LucideIcons.lock,
                    label: l10n.authPassword,
                    controller: passwordController,
                    obscure: true,
                    validator: (value) => _passwordError(
                      context,
                      value,
                      emailController?.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PenStackedField(
                    icon: LucideIcons.lock,
                    label: l10n.registerConfirmPassword,
                    controller: confirmPasswordController,
                    obscure: true,
                    validator: (value) => value == passwordController?.text
                        ? null
                        : l10n.passwordMismatch,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      PenCheckbox(
                        checked: policyAccepted,
                        onChanged: onPolicyChanged,
                      ),
                      const SizedBox(width: 10),
                      PenText(
                        l10n.registerAgreePrefix,
                        size: 14,
                        color: PenColors.ink,
                        softWrap: false,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: PenLink(
                          l10n.registerTermsOfUse,
                          onTap: onViewPolicy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _ValidatedPrimaryButton(
                    label: l10n.registerCreateAccount,
                    onValid: policyAccepted ? onRegister : null,
                  ),
                  const SizedBox(height: 10),
                  PenLabelledRule(l10n.authOr),
                  const SizedBox(height: 10),
                  PenOutlineButton(
                    label: l10n.registerWithGoogle,
                    icon: const PenGoogleMark(),
                    onPressed: onGoogle,
                  ),
                  const SizedBox(height: 12),
                  PenOutlineButton(
                    label: l10n.registerWithApple,
                    icon: const PenAppleMark(),
                    onPressed: onApple,
                  ),
                  const SizedBox(height: 12),
                  PenPromptLink(
                    prompt: l10n.registerHaveAccountPrompt.trim(),
                    action: l10n.authSignIn,
                    onTap: onLogin,
                  ),
                ],
              ),
            ),
            // Design `Back`: x=26, y=16, 28pt chevron.
            Positioned(
              left: 26,
              top: 16,
              child: PenBackButton(onTap: onLogin, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

/// ForgotPassword — lang chip, title, email field, primary "Gửi link đặt
/// lại" button, an optional "sent" confirmation box, login footer link.
class EcForgotPasswordScreen extends StatelessWidget {
  const EcForgotPasswordScreen({
    this.emailController,
    this.sent = false,
    this.onBack,
    this.onLanguage,
    this.onSend,
    this.onLogin,
    super.key,
  });

  final TextEditingController? emailController;

  /// Whether to show the "Đã gửi" confirmation box. Not part of the design's
  /// interaction spec (a static mockup only shows one state) so this
  /// defaults to `false` until a send actually succeeds.
  final bool sent;
  final VoidCallback? onBack;
  final VoidCallback? onLanguage;
  final VoidCallback? onSend;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      child: PenScreen(
        decorations: const [
          // Design `SupportArt`: x=26, y=524, 338x254.
          Positioned(
            left: 26,
            top: 524,
            width: 338,
            height: 254,
            child: Image(
              image: AssetImage(
                'assets/design/flow1-zenpack-hero-art-support.png',
                package: 'ec_ui',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ],
        child: Stack(
          children: [
            Padding(
              // Design `Body`: padding [14, 26, 0, 26]; `FieldWrap` opens 40
              // below the title block and spaces its rows by 22.
              padding: const EdgeInsets.fromLTRB(26, 14, 26, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PenBrandHeader(
                    title: l10n.forgotPasswordTitle,
                    subtitle: l10n.forgotPasswordSubtitle,
                  ),
                  const SizedBox(height: 40),
                  PenField(
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
                  const SizedBox(height: 22),
                  _ValidatedPrimaryButton(
                    label: l10n.forgotPasswordSubmit,
                    icon: LucideIcons.send,
                    onValid: onSend,
                  ),
                  if (sent) ...[
                    const SizedBox(height: 22),
                    PenBox(
                      width: double.infinity,
                      fill: PenColors.bg,
                      radius: 14,
                      axis: PenAxis.row,
                      gap: 16,
                      cross: CrossAxisAlignment.center,
                      padding: const EdgeInsets.all(18),
                      children: [
                        Expanded(
                          child: PenText(
                            l10n.forgotPasswordSent,
                            size: 14,
                            color: PenColors.ink,
                            lineHeight: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 22),
                  PenPromptLink(
                    prompt: l10n.forgotPasswordRememberPrompt.trim(),
                    action: l10n.authSignIn,
                    onTap: onLogin,
                  ),
                ],
              ),
            ),
            // Design `Back`: x=26, y=16, 28pt chevron.
            Positioned(
              left: 26,
              top: 16,
              child: PenBackButton(onTap: onBack, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ChooseShop
// ============================================================================

/// A shop summary as listed on the ChooseShop screen.
class EcShopSummary {
  const EcShopSummary({
    required this.name,
    required this.platform,
    this.id = '',
    this.meta,
    this.role = 'owner',
    this.resolution = '720p',
    this.clipBudget = ClipBudget.fallback,
  });

  /// Backend shop id (used to fetch that shop's orders). Empty for design mocks.
  final String id;

  /// Display name.
  final String name;

  /// Marketplace id understood by [BrandColors.platform] (`shopee`,
  /// `tiktok`, `lazada`, `tiki`, or anything else for "Khác").
  final String platform;

  /// Preformatted meta line, e.g. "Shopee · ID: 123456". Falls back to just
  /// the platform label when omitted.
  final String? meta;

  /// The signed-in user's role in this shop: `owner` / `manager` / `staff`
  /// (FR-05). Drives what they may do once clocked in (e.g. delete evidence).
  final String role;

  /// Ngân sách thời lượng/dung lượng clip của shop (FR-17/FR-18) — seed trần
  /// quay của Flow 3 và mục "Thời lượng/video" ở màn Chi tiết cửa hàng.
  final ClipBudget clipBudget;

  /// The shop's recording resolution setting (`240p` / `480p` / `720p`) —
  /// seeds the camera when clocked into this shop.
  final String resolution;
}

String _platformLabel(String platform) => switch (platform) {
  'shopee' => 'Shopee',
  'tiktok' => 'TikTok Shop',
  'lazada' => 'Lazada',
  'tiki' => 'Tiki',
  _ => 'Khác',
};

/// ChooseShop — "Shop của bạn": tap a shop to clock into it, a "Quản lý cửa
/// hàng" row for owners/managers, logout, and a hint footer.
class EcChooseShopScreen extends StatelessWidget {
  const EcChooseShopScreen({
    required this.shops,
    this.onSelect,
    this.onManage,
    this.onAddShop,
    this.onLogout,
    this.showManage = true,
    super.key,
  });

  final List<EcShopSummary> shops;
  final ValueChanged<EcShopSummary>? onSelect;
  final VoidCallback? onManage;

  /// "Thêm cửa hàng mới" — the design puts a create entry on this screen too.
  final VoidCallback? onAddShop;
  final VoidCallback? onLogout;

  /// Whether the "Quản lý cửa hàng" row is shown — hidden when the user is only
  /// staff (Nhân viên) and manages no shop (FR-05).
  final bool showManage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenScreen(
      decorations: const [
        Positioned(left: 49, top: 25, child: PenPlatformHero()),
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 186, 22, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PenText(
              l10n.shopChooseTitle,
              size: 30,
              color: PenColors.ink,
              weight: FontWeight.w800,
              align: TextAlign.center,
            ),
            const SizedBox(height: 6),
            PenText(
              l10n.shopChooseSubtitle,
              size: 14,
              color: PenColors.mut,
              align: TextAlign.center,
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < shops.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _ShopRow(
                shop: shops[i],
                selected: i == 0,
                onTap: onSelect == null ? null : () => onSelect!(shops[i]),
              ),
            ],
            const SizedBox(height: 16),
            if (showManage) ...[
              PenCard(
                gap: 16,
                padding: const EdgeInsets.all(16),
                onTap: onManage,
                children: [
                  const Icon(
                    LucideIcons.settings,
                    size: 26,
                    color: PenColors.ink,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PenText(
                          l10n.shopManageTitle,
                          size: 18,
                          color: PenColors.ink,
                          weight: FontWeight.w700,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        PenText(
                          l10n.shopManageOwnerOnly,
                          size: 12,
                          color: PenColors.mut,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 21,
                    color: PenColors.mut,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            EcTap(
              onTap: onAddShop,
              child: PenBox(
                width: double.infinity,
                height: 58,
                fill: PenColors.bg,
                stroke: PenColors.line,
                radius: 14,
                axis: PenAxis.row,
                gap: 12,
                main: MainAxisAlignment.center,
                cross: CrossAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.plus, size: 22, color: PenColors.ink),
                  Flexible(
                    child: PenText(
                      l10n.shopAddNew,
                      size: 16,
                      color: PenColors.link,
                      weight: FontWeight.w600,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: EcTap(
                onTap: onLogout,
                child: PenText(
                  l10n.accountSignOut,
                  size: 16,
                  color: PenColors.ink,
                  weight: FontWeight.w700,
                  softWrap: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One selectable shop: platform tile, name + meta, selection dot. The selected
/// row is filled `--secondary` grey (the design never tints it green).
class _ShopRow extends StatelessWidget {
  const _ShopRow({required this.shop, required this.selected, this.onTap});

  final EcShopSummary shop;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PenCard(
      fill: selected ? PenColors.soft : PenColors.card,
      stroke: selected ? PenColors.soft : PenColors.line,
      gap: 16,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      children: [
        PenBox(
          width: 52,
          height: 52,
          fill: PenColors.card,
          stroke: PenColors.line,
          radius: 14,
          axis: PenAxis.row,
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          children: [PenPlatforms.logo(shop.platform)],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              PenText(
                shop.name,
                size: 18,
                color: PenColors.ink,
                weight: FontWeight.w700,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              PenText(
                shop.meta ?? shop.platform,
                size: 14,
                color: PenColors.mut,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        PenRadio(selected: selected),
      ],
    );
  }
}

/// NoShop — empty state shown when the account has no shop yet: create a
/// new shop, or wait for an invite.
class EcNoShopScreen extends StatelessWidget {
  const EcNoShopScreen({this.onCreate, this.onInviteTap, super.key});
  final VoidCallback? onCreate;
  final VoidCallback? onInviteTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenScreen(
      decorations: const [
        Positioned(left: 49, top: 118, child: PenPlatformHero()),
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 376, 32, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PenText(
              l10n.noShopTitle,
              size: 30,
              color: PenColors.ink,
              weight: FontWeight.w800,
              align: TextAlign.center,
            ),
            const SizedBox(height: 16),
            for (final line in [
              l10n.noShopLineOne,
              l10n.noShopLineTwo,
              l10n.noShopLineThree,
            ]) ...[
              PenText(
                line,
                size: 14,
                color: PenColors.mut,
                align: TextAlign.center,
              ),
              const SizedBox(height: 4),
            ],
            const SizedBox(height: 24),
            EcTap(
              onTap: onCreate,
              child: PenBox(
                width: double.infinity,
                height: 62,
                fill: PenColors.primary,
                radius: 14,
                axis: PenAxis.row,
                gap: 12,
                main: MainAxisAlignment.center,
                cross: CrossAxisAlignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Flexible(
                    child: PenText(
                      l10n.noShopCreateCta,
                      size: 16,
                      color: PenColors.card,
                      weight: FontWeight.w700,
                      align: TextAlign.center,
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: PenColors.card,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PenCard(
              stroke: PenColors.soft,
              gap: 16,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              children: [
                const PenBox(
                  width: 44,
                  height: 44,
                  fill: PenColors.soft,
                  radius: 999,
                  axis: PenAxis.row,
                  main: MainAxisAlignment.center,
                  cross: CrossAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.mail, size: 22, color: PenColors.success),
                  ],
                ),
                Expanded(
                  child: PenText(
                    l10n.noShopInviteHint,
                    size: 14,
                    color: PenColors.ink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// CreateShop — name field, single-select platform pills, an ownership
/// note, primary "Tạo shop" button.
class EcCreateShopScreen extends StatelessWidget {
  const EcCreateShopScreen({
    this.nameController,
    this.selectedPlatform = 'shopee',
    this.onPlatformSelected,
    this.onBack,
    this.onCreate,
    super.key,
  });

  final TextEditingController? nameController;
  final String? selectedPlatform;
  final ValueChanged<String>? onPlatformSelected;
  final VoidCallback? onBack;
  final VoidCallback? onCreate;

  static const List<(String, String)> _platforms = [
    ('shopee', 'Shopee'),
    ('tiktok', 'TikTok'),
    ('lazada', 'Lazada'),
    ('tiki', 'Tiki'),
    ('other', 'Khác'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      child: PenScreen(
        decorations: const [
          Positioned(
            left: 38,
            bottom: 116,
            child: Image(
              image: AssetImage(
                'assets/design/flow1-zenpack-hero-art-create-shop.png',
                package: 'ec_ui',
              ),
              width: 314,
              height: 240,
              fit: BoxFit.cover,
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PenHeader(title: l10n.createShopTitle, onBack: onBack),
              const SizedBox(height: 26),
              PenText(
                l10n.createShopNameLabel,
                size: 16,
                color: PenColors.ink,
                weight: FontWeight.w600,
              ),
              const SizedBox(height: 10),
              PenBox(
                width: double.infinity,
                height: 62,
                fill: PenColors.card,
                stroke: PenColors.line,
                radius: 14,
                axis: PenAxis.row,
                cross: CrossAxisAlignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: nameController,
                      padding: EdgeInsets.zero,
                      decoration: const BoxDecoration(),
                      placeholder: l10n.createShopNameHint,
                      style: const TextStyle(
                        fontSize: 16,
                        color: PenColors.ink,
                      ),
                      placeholderStyle: const TextStyle(
                        fontSize: 16,
                        color: PenColors.mut,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PenText(
                l10n.createShopPlatformLabel,
                size: 16,
                color: PenColors.ink,
                weight: FontWeight.w600,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final (key, label) in _platforms) ...[
                    if (key != _platforms.first.$1) const SizedBox(width: 10),
                    Expanded(
                      child: _PlatformChoice(
                        platform: key,
                        label: label,
                        selected: selectedPlatform == key,
                        onTap: onPlatformSelected == null
                            ? null
                            : () => onPlatformSelected!(key),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              PenCard(
                fill: PenColors.bg,
                stroke: null,
                lifted: false,
                gap: 14,
                padding: const EdgeInsets.all(16),
                children: [
                  const Icon(LucideIcons.info, size: 24, color: PenColors.ink),
                  Expanded(
                    child: PenText(
                      l10n.createShopOwnerNote,
                      size: 14,
                      color: PenColors.ink,
                      lineHeight: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _ValidatedPrimaryButton(
                label: l10n.createShopSubmit,
                onValid: onCreate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One marketplace tile in the create-shop picker: 86px tall, and when picked
/// it takes that marketplace's own brand colour for its border and label —
/// the design's single sanctioned exception to the token palette.
class _PlatformChoice extends StatelessWidget {
  const _PlatformChoice({
    required this.platform,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String platform;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brand = PenPlatforms.brand[platform] ?? PenColors.ink;
    return EcTap(
      onTap: onTap,
      child: PenBox(
        height: 86,
        fill: PenColors.card,
        stroke: selected ? brand : PenColors.line,
        strokeWidth: selected ? 2 : 1,
        radius: 14,
        axis: PenAxis.column,
        gap: 8,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          PenPlatforms.logo(platform, size: 26),
          PenText(
            label,
            size: 11,
            color: selected ? brand : PenColors.ink,
            weight: FontWeight.w600,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// A shop entry as listed on the ShopMgmt screen.
class EcShopMgmtEntry {
  const EcShopMgmtEntry({
    required this.name,
    required this.meta,
    this.id,
    this.platform,
    this.resolution,
    this.role,
    this.clipBudget = ClipBudget.fallback,
  });

  /// Display name.
  final String name;

  /// Preformatted meta line, e.g. "Shopee · 3 thành viên".
  final String meta;

  final String? id;
  final String? platform;
  final String? resolution;
  final String? role;
  final ClipBudget clipBudget;
}

/// ShopMgmt — "Quản lý cửa hàng": list of shops with a logo placeholder,
/// an "add shop" row and a permission-scoped footer note.
class EcShopMgmtScreen extends StatelessWidget {
  const EcShopMgmtScreen({
    required this.shops,
    this.onBack,
    this.onShopTap,
    this.onAddShop,
    super.key,
  });

  final List<EcShopMgmtEntry> shops;
  final VoidCallback? onBack;
  final ValueChanged<EcShopMgmtEntry>? onShopTap;
  final VoidCallback? onAddShop;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenScreen(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 30, 26, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PenHeader(
              title: l10n.shopManageTitle,
              onBack: onBack,
              gap: 14,
            ),
            const SizedBox(height: 18),
            PenText(
              l10n.shopManageDescription,
              size: 14,
              color: PenColors.mut,
              lineHeight: 1.5,
            ),
            const SizedBox(height: 20),
            PenCard(
              axis: PenAxis.column,
              stroke: null,
              clip: true,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              children: [
                for (var i = 0; i < shops.length; i++) ...[
                  if (i > 0)
                    const PenBox(
                      width: double.infinity,
                      height: 1,
                      fill: PenColors.line,
                    ),
                  _ShopMgmtRow(
                    entry: shops[i],
                    onTap: onShopTap == null
                        ? null
                        : () => onShopTap!(shops[i]),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            EcTap(
              onTap: onAddShop,
              child: PenBox(
                width: double.infinity,
                height: 82,
                fill: PenColors.card,
                radius: 14,
                shadows: const [penCardShadow],
                axis: PenAxis.row,
                gap: 14,
                main: MainAxisAlignment.center,
                cross: CrossAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.plus, size: 24, color: PenColors.ink),
                  Flexible(
                    child: PenText(
                      l10n.shopManageAddCta,
                      size: 18,
                      color: PenColors.link,
                      weight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.info, size: 20, color: PenColors.ink),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PenText(
                      l10n.shopManageStaffNote,
                      size: 14,
                      color: PenColors.mut,
                      lineHeight: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopMgmtRow extends StatelessWidget {
  const _ShopMgmtRow({required this.entry, this.onTap});

  final EcShopMgmtEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final platform = entry.platform ?? 'other';
    final known = PenPlatforms.brand.containsKey(platform);
    return EcTap(
      onTap: onTap,
      child: PenBox(
        width: double.infinity,
        axis: PenAxis.row,
        gap: 17,
        cross: CrossAxisAlignment.center,
        padding: const EdgeInsets.symmetric(vertical: 19),
        children: [
          PenBox(
            width: 56,
            height: 56,
            fill: known ? PenColors.card : PenColors.bg,
            stroke: known ? PenColors.line : null,
            radius: 14,
            axis: PenAxis.row,
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            children: [PenPlatforms.logo(platform)],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                PenText(
                  entry.name,
                  size: 18,
                  color: PenColors.ink,
                  weight: FontWeight.w700,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                PenText(
                  entry.meta,
                  size: 14,
                  color: PenColors.mut,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            size: 22,
            color: PenColors.ink,
          ),
        ],
      ),
    );
  }
}

/// A shop member as listed on the ShopDetail screen.
class EcShopMember {
  const EcShopMember({
    required this.name,
    required this.role,
    this.accountUid,
    this.roleCode,
  });
  final String name;
  final String role;
  final String? accountUid;
  final String? roleCode;
}

/// A configurable video type on the ShopDetail screen. The three built-in
/// types (Đóng hàng, ĐV vận chuyển, Trả hàng) are `locked` and only show a
/// lock icon; custom types show edit/delete actions.
class EcVideoType {
  const EcVideoType({
    required this.name,
    this.id,
    this.locked = false,
    this.icon = LucideIcons.video,
    this.iconKey,
    this.colorHex,
  });

  final String name;
  final String? id;
  final bool locked;
  final IconData icon;

  /// Khóa icon người tạo đã chọn (một trong [EcCreateTypeScreen.iconKeys]).
  /// `null` với 3 loại mặc định và loại tạo trước khi có tính năng này.
  final String? iconKey;

  /// `#RRGGBB` người tạo đã chọn; `null` = chưa chọn.
  final String? colorHex;

  /// Màu để tô icon trong danh sách. Chưa chọn thì trả `null` để nơi hiển thị
  /// dùng màu mặc định của nó.
  Color? get color {
    final hex = colorHex;
    if (hex == null || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) return null;
    return Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));
  }
}

/// ShopDetail — member list + invite row, then shop settings: recording
/// resolution and the video type list (locked defaults + custom types).
class EcShopDetailScreen extends StatelessWidget {
  const EcShopDetailScreen({
    required this.shopName,
    required this.platformLabel,
    required this.members,
    required this.videoTypes,
    this.resolution = '720p',
    this.clipBudget = ClipBudget.fallback,
    this.onBack,
    this.onMemberMore,
    this.onInviteMember,
    this.onTapResolution,
    this.onTapClipDuration,
    this.onEditType,
    this.onDeleteType,
    this.onAddType,
    super.key,
  });

  final String shopName;
  final String platformLabel;
  final List<EcShopMember> members;
  final List<EcVideoType> videoTypes;
  final String resolution;
  final ClipBudget clipBudget;
  final VoidCallback? onBack;
  final ValueChanged<EcShopMember>? onMemberMore;
  final VoidCallback? onInviteMember;
  final VoidCallback? onTapResolution;
  final VoidCallback? onTapClipDuration;
  final ValueChanged<EcVideoType>? onEditType;
  final ValueChanged<EcVideoType>? onDeleteType;
  final VoidCallback? onAddType;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenScreen(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PenHeader(
              title: l10n.shopDetailTitle,
              onBack: onBack,
              gap: 14,
            ),
            const SizedBox(height: 8),
            PenCard(
              stroke: null,
              gap: 16,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              children: [
                PenBox(
                  width: 54,
                  height: 54,
                  fill: PenColors.card,
                  stroke: PenColors.line,
                  radius: 16,
                  axis: PenAxis.row,
                  main: MainAxisAlignment.center,
                  cross: CrossAxisAlignment.center,
                  children: [
                    PenPlatforms.logo(platformLabel.toLowerCase(), size: 40),
                  ],
                ),
                Expanded(
                  child: PenText(
                    shopName,
                    size: 24,
                    color: PenColors.ink,
                    weight: FontWeight.w800,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _PenSectionCard(
              icon: LucideIcons.users,
              label: l10n.sectionMembers,
              children: [
                for (var i = 0; i < members.length; i++) ...[
                  if (i > 0)
                    const PenBox(
                      width: double.infinity,
                      height: 1,
                      fill: PenColors.line,
                    ),
                  _MemberRow(
                    member: members[i],
                    onTap: onMemberMore == null
                        ? null
                        : () => onMemberMore!(members[i]),
                  ),
                ],
                EcTap(
                  onTap: onInviteMember,
                  child: PenBox(
                    width: double.infinity,
                    stroke: PenColors.soft,
                    radius: 10,
                    axis: PenAxis.row,
                    gap: 14,
                    cross: CrossAxisAlignment.center,
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                      horizontal: 12,
                    ),
                    children: [
                      const Icon(
                        LucideIcons.plus,
                        size: 22,
                        color: PenColors.ink,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PenText(
                              l10n.inviteMemberTitle,
                              size: 14,
                              color: PenColors.link,
                              weight: FontWeight.w700,
                              softWrap: false,
                            ),
                            const SizedBox(height: 2),
                            PenText(
                              l10n.inviteMemberHint,
                              size: 12,
                              color: PenColors.mut,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _PenSectionCard(
              icon: LucideIcons.settings,
              label: l10n.sectionShopSettings,
              children: [
                EcTap(
                  onTap: onTapResolution,
                  child: PenBox(
                    width: double.infinity,
                    fill: PenColors.card,
                    stroke: PenColors.line,
                    radius: 10,
                    axis: PenAxis.row,
                    gap: 14,
                    cross: CrossAxisAlignment.center,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    children: [
                      const PenBox(
                        width: 38,
                        height: 38,
                        fill: PenColors.bg,
                        radius: 10,
                        axis: PenAxis.row,
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.video,
                            size: 22,
                            color: PenColors.ink,
                          ),
                        ],
                      ),
                      Expanded(
                        child: PenText(
                          l10n.shopDetailResolution,
                          size: 16,
                          color: PenColors.ink,
                        ),
                      ),
                      PenText(
                        resolution,
                        size: 16,
                        color: PenColors.ink,
                        weight: FontWeight.w600,
                        softWrap: false,
                      ),
                      const Icon(
                        LucideIcons.chevronRight,
                        size: 18,
                        color: PenColors.mut,
                      ),
                    ],
                  ),
                ),
                _ClipDurationRow(
                  budget: clipBudget,
                  platformLabel: platformLabel,
                  resolution: resolution,
                  onTap: onTapClipDuration,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _PenSectionCard(
              icon: LucideIcons.squarePlay,
              label: l10n.sectionVideoTypes,
              children: [
                for (final type in videoTypes)
                  _VideoTypeRow(
                    type: type,
                    onEdit: onEditType == null ? null : () => onEditType!(type),
                    onDelete: onDeleteType == null
                        ? null
                        : () => onDeleteType!(type),
                  ),
                EcTap(
                  onTap: onAddType,
                  child: PenBox(
                    width: double.infinity,
                    stroke: PenColors.soft,
                    radius: 10,
                    axis: PenAxis.row,
                    gap: 12,
                    main: MainAxisAlignment.center,
                    cross: CrossAxisAlignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    children: [
                      const Icon(
                        LucideIcons.plus,
                        size: 21,
                        color: PenColors.ink,
                      ),
                      Flexible(
                        child: PenText(
                          l10n.shopDetailAddType,
                          size: 16,
                          color: PenColors.link,
                          weight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "Thời lượng/video" row + the recommendation caption + the amber warning that
/// appears only once the shop has raised the cap past what the marketplace
/// accepts as a direct attachment (FR-18, FR-19).
class _ClipDurationRow extends StatelessWidget {
  const _ClipDurationRow({
    required this.budget,
    required this.platformLabel,
    required this.resolution,
    this.onTap,
  });

  final ClipBudget budget;
  final String platformLabel;
  final String resolution;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final minutes = _minutes(budget.seconds);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        EcTap(
          onTap: onTap,
          child: PenBox(
            width: double.infinity,
            fill: PenColors.card,
            stroke: PenColors.line,
            radius: 10,
            axis: PenAxis.row,
            gap: 14,
            cross: CrossAxisAlignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            children: [
              const PenBox(
                width: 38,
                height: 38,
                fill: PenColors.bg,
                radius: 10,
                axis: PenAxis.row,
                main: MainAxisAlignment.center,
                cross: CrossAxisAlignment.center,
                children: [
                  Icon(LucideIcons.timer, size: 22, color: PenColors.ink),
                ],
              ),
              Expanded(
                child: PenText(
                  l10n.shopDetailClipDuration,
                  size: 16,
                  color: PenColors.ink,
                ),
              ),
              PenText(
                l10n.clipDurationValue(minutes),
                size: 16,
                color: PenColors.ink,
                weight: FontWeight.w600,
                softWrap: false,
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: PenColors.mut,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        PenText(
          budget.platformLimitsVerified
              ? l10n.clipRecommendedHint(
                  _minutes(budget.recommendedSeconds),
                  platformLabel,
                  _megabytes(budget.maxVideoBytes),
                  resolution,
                )
              : l10n.clipRecommendedHintUnverified(
                  _minutes(budget.recommendedSeconds),
                  platformLabel,
                ),
          size: 12,
          color: PenColors.mut,
        ),
        if (budget.exceedsRecommended) ...[
          const SizedBox(height: 8),
          PenBox(
            width: double.infinity,
            fill: _warnFill,
            stroke: _warnStroke,
            radius: 10,
            axis: PenAxis.row,
            gap: 10,
            cross: CrossAxisAlignment.start,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            children: [
              const Icon(
                LucideIcons.triangleAlert,
                size: 18,
                color: _warnInk,
              ),
              Expanded(
                child: PenText(
                  l10n.clipOverRecommendedWarning(
                    _minutes(budget.recommendedSeconds),
                    platformLabel,
                    minutes,
                    _megabytes(
                      ClipBudget.estimatedBytes(budget.seconds, resolution),
                    ),
                  ),
                  size: 12.5,
                  color: _warnInk,
                  weight: FontWeight.w600,
                  lineHeight: 1.4,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Amber of the design file's warn bar (F3-05) — the one warning colour the
/// EvidenceCam DNA has; reused here so the two screens read as the same system.
const _warnInk = Color(0xFFB6770B);
const _warnFill = Color(0x14B6770B);
const _warnStroke = Color(0x4DB6770B);

String _minutes(int seconds) => '${(seconds / 60).round()}';

String _megabytes(int bytes) => ClipBudget.megabytesLabel(bytes);

/// A white card that opens with an icon + all-caps section label, then its
/// rows — the shape every panel on the shop-detail screen uses.
class _PenSectionCard extends StatelessWidget {
  const _PenSectionCard({
    required this.icon,
    required this.label,
    required this.children,
  });

  final IconData icon;
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return PenCard(
      axis: PenAxis.column,
      stroke: null,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 13),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              Icon(icon, size: 22, color: PenColors.ink),
              const SizedBox(width: 12),
              Expanded(
                child: PenText(
                  label.toUpperCase(),
                  size: 14,
                  color: PenColors.mut,
                  weight: FontWeight.w700,
                  letterSpacing: 0.6,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, this.onTap});

  final EcShopMember member;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: PenBox(
        width: double.infinity,
        axis: PenAxis.row,
        gap: 14,
        cross: CrossAxisAlignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const PenBox(
            width: 38,
            height: 38,
            fill: PenColors.soft,
            radius: 999,
            axis: PenAxis.row,
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            children: [
              Icon(LucideIcons.user, size: 20, color: PenColors.ink),
            ],
          ),
          Expanded(
            child: PenText(
              member.name,
              size: 16,
              color: PenColors.ink,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PenBox(
            fill: PenColors.bg,
            radius: 999,
            axis: PenAxis.row,
            hugMain: true,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 11),
            children: [
              PenText(
                member.role,
                size: 12,
                color: PenColors.ink,
                softWrap: false,
              ),
            ],
          ),
          const Icon(
            LucideIcons.chevronRight,
            size: 18,
            color: PenColors.mut,
          ),
        ],
      ),
    );
  }
}

class _VideoTypeRow extends StatelessWidget {
  const _VideoTypeRow({required this.type, this.onEdit, this.onDelete});

  final EcVideoType type;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      width: double.infinity,
      axis: PenAxis.row,
      gap: 14,
      cross: CrossAxisAlignment.center,
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        PenBox(
          width: 36,
          height: 36,
          fill: PenColors.bg,
          radius: 10,
          axis: PenAxis.row,
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          // Màu người tạo chọn hiện ở đây — nếu không thì hai hàng chọn
          // icon/màu ở màn tạo loại chẳng dẫn tới đâu cả.
          children: [
            Icon(type.icon, size: 21, color: type.color ?? PenColors.ink),
          ],
        ),
        Expanded(
          child: PenText(
            type.name,
            size: 14,
            color: PenColors.ink,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Built-in types can't be renamed or removed; the design marks that
        // with a padlock instead of hiding the affordances.
        if (type.locked)
          const Icon(LucideIcons.lock, size: 19, color: PenColors.mut)
        else ...[
          EcTap(
            onTap: onEdit,
            child: const Icon(
              LucideIcons.pencil,
              size: 19,
              color: PenColors.ink,
            ),
          ),
          EcTap(
            onTap: onDelete,
            child: const Icon(
              LucideIcons.trash2,
              size: 19,
              color: PenColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}

/// CreateType — dialog to name a new custom video type.
class EcCreateTypeScreen extends StatelessWidget {
  const EcCreateTypeScreen({
    this.nameController,
    this.selectedIcon = 0,
    this.onIconSelected,
    this.selectedColor = 0,
    this.onColorSelected,
    this.onCancel,
    this.onCreate,
    super.key,
  });

  final TextEditingController? nameController;

  /// Index into the design's six-icon palette.
  final int selectedIcon;
  final ValueChanged<int>? onIconSelected;

  /// Index into the design's six-swatch palette.
  final int selectedColor;
  final ValueChanged<int>? onColorSelected;
  final VoidCallback? onCancel;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenSheet(
      children: [
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: PenText(
            l10n.createVideoTypeTitle,
            size: 24,
            color: PenColors.link,
            weight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: PenText(
            l10n.videoTypeName,
            size: 14,
            color: PenColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        PenBox(
          width: double.infinity,
          height: 56,
          fill: PenColors.card,
          stroke: PenColors.line,
          radius: 14,
          axis: PenAxis.row,
          cross: CrossAxisAlignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: nameController,
                padding: EdgeInsets.zero,
                decoration: const BoxDecoration(),
                placeholder: l10n.videoTypeNameHint,
                style: const TextStyle(fontSize: 16, color: PenColors.ink),
                placeholderStyle: const TextStyle(
                  fontSize: 16,
                  color: PenColors.mut,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: PenText(l10n.videoTypeIcon, size: 14, color: PenColors.ink),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < _iconChoices.length; i++) ...[
              if (i > 0) const SizedBox(width: 9),
              Expanded(
                child: _PickTile(
                  selected: i == selectedIcon,
                  onTap: onIconSelected == null
                      ? null
                      : () => onIconSelected!(i),
                  child: Icon(
                    _iconChoices[i],
                    size: 23,
                    color: PenColors.ink,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: PenText(l10n.videoTypeColor, size: 14, color: PenColors.ink),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < _colorChoices.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: EcTap(
                  onTap: onColorSelected == null
                      ? null
                      : () => onColorSelected!(i),
                  child: PenBox(
                    height: 48,
                    stroke: i == selectedColor ? PenColors.line : null,
                    strokeWidth: 2,
                    radius: 999,
                    axis: PenAxis.row,
                    main: MainAxisAlignment.center,
                    cross: CrossAxisAlignment.center,
                    children: [
                      PenEllipse(
                        width: i == selectedColor ? 36 : 44,
                        height: i == selectedColor ? 36 : 44,
                        color: _colorChoices[i],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: PenDialogButton(
                label: l10n.commonCancel,
                primary: false,
                height: 56,
                radius: 14,
                onPressed: onCancel,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: PenDialogButton(
                label: l10n.createVideoTypeSubmit,
                primary: true,
                height: 56,
                radius: 14,
                onPressed: onCreate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// The six icons the design offers for a custom video type.
  /// Khóa gửi lên backend cho từng ô icon, **cùng thứ tự** với
  /// [_iconChoices]. Để sát nhau để thêm/bớt icon là thấy ngay phải sửa cả
  /// hai; backend chỉ nhận đúng 6 khóa này.
  static const iconKeys = [
    'archive',
    'truck',
    'shopping-cart',
    'clipboard-check',
    'shield-check',
    'package-open',
  ];

  /// `#RRGGBB` của từng ô màu, cùng thứ tự với [_colorChoices].
  static const colorHexes = [
    '#161616',
    '#16522C',
    '#1F9047',
    '#B6770B',
    '#D02D27',
    '#636363',
  ];

  /// Icon ứng với khóa đã lưu, `null` nếu khóa lạ (backend đổi danh sách mà
  /// app chưa cập nhật) — nơi gọi tự chọn icon dự phòng.
  static IconData? iconFor(String key) {
    final i = iconKeys.indexOf(key);
    return i < 0 ? null : _iconChoices[i];
  }

  /// Vị trí ô ứng với khóa/màu đã lưu; không nhận ra thì rơi về ô đầu.
  static int iconIndexOf(String? key) {
    final i = iconKeys.indexOf(key ?? '');
    return i < 0 ? 0 : i;
  }

  static int colorIndexOf(String? hex) {
    final i = colorHexes.indexOf((hex ?? '').toUpperCase());
    return i < 0 ? 0 : i;
  }

  static const _iconChoices = [
    LucideIcons.archive,
    LucideIcons.truck,
    LucideIcons.shoppingCart,
    LucideIcons.clipboardCheck,
    LucideIcons.shieldCheck,
    LucideIcons.packageOpen,
  ];

  /// The six swatches: ink, the two greens, `--warning` amber, destructive
  /// red and muted grey — in the design file's own order.
  static const _colorChoices = [
    PenColors.ink,
    PenColors.primary,
    PenColors.success,
    Color(0xFFB6770B),
    PenColors.danger,
    PenColors.mut,
  ];
}

/// One tile in the icon picker: selected reads as a bordered light tile, the
/// rest as flat grey (the design never tints a selection).
class _PickTile extends StatelessWidget {
  const _PickTile({required this.selected, required this.child, this.onTap});

  final bool selected;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: PenBox(
        height: 52,
        fill: selected ? PenColors.bg : PenColors.soft,
        stroke: selected ? PenColors.line : null,
        strokeWidth: 2,
        radius: 14,
        axis: PenAxis.row,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        children: [child],
      ),
    );
  }
}

/// ConfirmDelete — dialog confirming that a custom video type should stop
/// being offered for new videos. Backend blocks deletion once videos use it.
class EcConfirmDeleteScreen extends StatelessWidget {
  const EcConfirmDeleteScreen({
    this.typeName = 'Cân hàng',
    this.onCancel,
    this.onConfirm,
    super.key,
  });

  final String typeName;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenDialog(
      children: [
        SizedBox(
          width: 62,
          height: 62,
          child: Stack(
            children: [
              const PenEllipse(width: 56, height: 56, color: PenColors.soft),
              const Positioned(
                left: 16,
                top: 15,
                child: Icon(
                  LucideIcons.trash2,
                  size: 25,
                  color: PenColors.success,
                ),
              ),
              Positioned(
                left: 36,
                top: 34,
                child: PenBox(
                  width: 22,
                  height: 22,
                  fill: PenColors.danger,
                  radius: 999,
                  axis: PenAxis.row,
                  main: MainAxisAlignment.center,
                  cross: CrossAxisAlignment.center,
                  children: const [
                    PenText(
                      '!',
                      size: 14,
                      color: PenColors.card,
                      weight: FontWeight.w800,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        PenText(
          l10n.deleteVideoTypeTitle(typeName),
          size: 20,
          color: PenColors.danger,
          weight: FontWeight.w800,
          align: TextAlign.center,
        ),
        const SizedBox(height: 10),
        PenText(
          l10n.deleteVideoTypeBody,
          size: 12,
          color: PenColors.mut,
          align: TextAlign.center,
          lineHeight: 1.55,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: PenDialogButton(
                label: l10n.commonCancel,
                primary: false,
                onPressed: onCancel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PenDialogButton(
                label: l10n.commonConfirm,
                primary: true,
                onPressed: onConfirm,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.shieldCheck,
              size: 16,
              color: PenColors.mut,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: PenText(
                l10n.deleteVideoTypeSafeNote,
                size: 12,
                color: PenColors.mut,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// InviteMember — dialog to add an existing user to the shop by email/phone
/// with a role. Fills the member control that previously had no destination.
class EcInviteMemberScreen extends StatefulWidget {
  const EcInviteMemberScreen({
    this.contactController,
    this.onCancel,
    this.onInvite,
    super.key,
  });

  final TextEditingController? contactController;
  final VoidCallback? onCancel;

  /// Fires with the entered contact and chosen role.
  final ValueChanged<EcMemberInvite>? onInvite;

  @override
  State<EcInviteMemberScreen> createState() => _EcInviteMemberScreenState();
}

class _EcInviteMemberScreenState extends State<EcInviteMemberScreen> {
  String _role = 'Nhân viên';

  @override
  Widget build(BuildContext context) {
    return _EcDialogFrame(
      children: [
        Text(
          context.l10n.addMemberTitle,
          style: _t(16, FontWeight.w600, BrandColors.ink),
        ),
        Text(
          context.l10n.addMemberBody,
          style: _t(14, FontWeight.w400, BrandColors.mut),
        ),
        _Field(
          label: context.l10n.emailOrPhone,
          hint: 'ban@email.com',
          controller: widget.contactController,
        ),
        Text('Vai trò', style: _t(14, FontWeight.w500, BrandColors.ink)),
        _RoleOption(
          label: 'Nhân viên',
          desc: 'Chỉ quay + xem video mình quay',
          selected: _role == 'Nhân viên',
          onTap: () => setState(() => _role = 'Nhân viên'),
        ),
        _RoleOption(
          label: 'Quản lý shop',
          desc: 'Toàn quyền trong shop',
          selected: _role == 'Quản lý shop',
          onTap: () => setState(() => _role = 'Quản lý shop'),
        ),
        Row(
          children: [
            Expanded(
              child: _EcOutlineButton(
                label: context.l10n.commonCancel,
                onPressed: widget.onCancel,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EcPrimaryButton(
                label: context.l10n.addMemberSubmit,
                onPressed: () {
                  final contact = widget.contactController?.text.trim() ?? '';
                  if (contact.isEmpty) return;
                  widget.onInvite?.call(EcMemberInvite(contact, _role));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class EcMemberInvite {
  const EcMemberInvite(this.contact, this.role);

  final String contact;
  final String role;
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.label,
    required this.desc,
    required this.selected,
    this.onTap,
  });
  final String label;
  final String desc;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: DecoratedBox(
        decoration: ecSquircleDecoration(
          radius: 12,
          side: BorderSide(
            color: selected ? BrandColors.dark : BrandColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20,
                color: selected ? BrandColors.dark : BrandColors.mut,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: _t(14, FontWeight.w600, BrandColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(desc, style: _t(14, FontWeight.w400, BrandColors.mut)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// MemberActions — bottom sheet from the ⋮ on a member row: change role or
/// remove from shop.
class EcMemberActionsScreen extends StatelessWidget {
  const EcMemberActionsScreen({
    required this.member,
    this.onSetManager,
    this.onSetStaff,
    this.onRemove,
    super.key,
  });

  final EcShopMember member;
  final VoidCallback? onSetManager;
  final VoidCallback? onSetStaff;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final isManager = member.role.contains('Quản lý');
    return _EcSheetFrame(
      title: member.name,
      subtitle: context.l10n.memberCurrentRole(member.role),
      children: [
        _EcSheetActionRow(
          icon: Icons.shield_outlined,
          label: context.l10n.setAsManager,
          selected: isManager,
          onTap: onSetManager,
        ),
        _EcSheetActionRow(
          icon: Icons.person_outline,
          label: context.l10n.setAsStaff,
          selected: !isManager,
          onTap: onSetStaff,
        ),
        _EcSheetActionRow(
          icon: Icons.person_remove_outlined,
          label: context.l10n.removeFromShop,
          destructive: true,
          onTap: onRemove,
        ),
      ],
    );
  }
}

/// Resolution — bottom sheet picking recording resolution for the shop.
class EcResolutionSheetScreen extends StatelessWidget {
  const EcResolutionSheetScreen({
    this.selected = '720p',
    this.onSelect,
    super.key,
  });

  final String selected;
  final ValueChanged<String>? onSelect;

  static const _options = ['720p', '480p', '240p'];

  @override
  Widget build(BuildContext context) {
    return _EcSheetFrame(
      title: context.l10n.recordResolution,
      subtitle: context.l10n.resolutionAppliesNote,
      children: [
        for (final r in _options)
          _EcSheetActionRow(
            icon: Icons.videocam_outlined,
            label: r == '720p' ? context.l10n.resolutionDefaultOption : r,
            selected: r == selected,
            onTap: () => onSelect?.call(r),
          ),
      ],
    );
  }
}

/// ClipDuration — bottom sheet picking the shop's max length per video.
///
/// Options run 1 minute → the plan ceiling. The recommendation is labelled
/// rather than enforced: everything above it stays selectable, it just carries
/// the amber warning back on the shop-detail screen (FR-19 — cảnh báo, không
/// chặn).
class EcClipDurationSheetScreen extends StatelessWidget {
  const EcClipDurationSheetScreen({
    required this.budget,
    required this.platformLabel,
    this.onSelect,
    super.key,
  });

  final ClipBudget budget;
  final String platformLabel;

  /// Emits the chosen cap in **seconds**.
  final ValueChanged<int>? onSelect;

  /// Minute marks offered, capped by the plan. Coarse past 10 minutes — nobody
  /// needs to tell a packing clip 23 from 24 minutes, and a 25-row sheet is
  /// worse than a short one.
  static const _marks = [1, 2, 3, 5, 8, 10, 15, 20, 25];

  List<int> get _options {
    final capMinutes = (budget.planMaxSeconds / 60).floor();
    final marks = _marks.where((m) => m <= capMinutes).toList();
    final recommended = (budget.recommendedSeconds / 60).round();
    // Mức đề xuất luôn phải chọn được, kể cả khi nó không rơi vào mốc nào.
    if (recommended <= capMinutes && !marks.contains(recommended)) {
      marks
        ..add(recommended)
        ..sort();
    }
    return marks;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedMinutes = (budget.seconds / 60).round();
    final recommended = (budget.recommendedSeconds / 60).round();
    return _EcSheetFrame(
      title: l10n.clipDurationTitle,
      subtitle: l10n.clipDurationSubtitle('$recommended', platformLabel),
      children: [
        for (final m in _options)
          _EcSheetActionRow(
            icon: LucideIcons.timer,
            label: m == recommended
                ? l10n.clipDurationOptionRecommended('$m')
                : l10n.clipDurationValue('$m'),
            selected: m == selectedMinutes,
            onTap: () => onSelect?.call(m * 60),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: PenText(
            l10n.clipDurationPlanCap('${(budget.planMaxSeconds / 60).floor()}'),
            size: 12,
            color: PenColors.mut,
          ),
        ),
      ],
    );
  }
}

/// Shared bottom-sheet chrome for flow-1 sheets (dim scrim + rounded panel).
class _EcSheetFrame extends StatelessWidget {
  const _EcSheetFrame({
    required this.title,
    required this.children,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final sub = subtitle;
    return ColoredBox(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: const ColoredBox(color: Colors.black54),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: BrandColors.bg,
                  shape: SmoothRectangleBorder(
                    smoothness: ecCornerSmoothing,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: BrandColors.line,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: _t(16, FontWeight.w600, BrandColors.ink),
                            ),
                            if (sub != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                sub,
                                style: _t(14, FontWeight.w400, BrandColors.mut),
                              ),
                            ],
                          ],
                        ),
                      ),
                      ...children,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EcSheetActionRow extends StatelessWidget {
  const _EcSheetActionRow({
    required this.icon,
    required this.label,
    this.selected = false,
    this.destructive = false,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? BrandColors.rec : BrandColors.ink;
    return EcTap(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: BrandColors.line)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: _t(16, FontWeight.w500, color)),
            ),
            if (selected)
              const Icon(Icons.check, size: 20, color: BrandColors.dark),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HomeOrders
// ============================================================================

/// A quick stat shown at the top of HomeOrders (e.g. "24" / "Vận đơn").
class EcHomeStat {
  const EcHomeStat({
    required this.value,
    required this.label,
    this.icon = LucideIcons.package,
  });
  final String value;
  final String label;

  /// The lucide glyph the design puts in the stat's tile.
  final IconData icon;
}

/// An order row on HomeOrders.
class EcOrderRow {
  const EcOrderRow({
    required this.code,
    required this.time,
    required this.type,
    required this.videoCount,
    this.errorCount = 0,
    this.pendingCount = 0,
  });

  /// Tracking code.
  final String code;

  /// Time label, e.g. "10:23".
  final String time;

  /// Video type label, e.g. "Đóng hàng đi".
  final String type;
  final int videoCount;
  final int errorCount;
  final int pendingCount;
}

/// One selectable video type in the "Loại video" filter.
@immutable
class EcVideoTypeOption {
  const EcVideoTypeOption({required this.id, required this.name});

  /// Backend id, sent as the `video_type_id` query param.
  final String id;

  /// User-authored name — shop data, so never translated.
  final String name;
}

/// The "Vận đơn" tab's three filters (Flow 2·1), as currently selected. A null
/// field means that filter is off.
///
/// These are applied by the backend, not by the widget: the list is paged, so
/// a client-side filter would only ever narrow the rows already loaded and
/// would silently hide matches sitting on the next page.
@immutable
class EcOrderFilters {
  const EcOrderFilters({this.uploadState, this.fromTs, this.videoTypeId});

  /// `pending` | `error` | `done` — the backend's `upload_state` param.
  final String? uploadState;

  /// Epoch ms lower bound on the order's creation time (`from`).
  final int? fromTs;

  /// Restricts to orders holding at least one clip of this type.
  final String? videoTypeId;

  bool get isEmpty =>
      uploadState == null && fromTs == null && videoTypeId == null;
}

/// Vị trí của trang đang xem trong toàn bộ kết quả, cho thanh phân trang ở
/// cuối danh sách vận đơn (F2-01). [total] là tổng số đơn khớp bộ lọc trên
/// server, [shown] là số đơn trang này thực sự trả về.
@immutable
class EcOrderPage {
  const EcOrderPage({
    this.page = 1,
    this.total = 0,
    this.pageSize = 10,
    this.shown = 0,
  });

  /// 1-based.
  final int page;
  final int total;
  final int pageSize;
  final int shown;

  int get pageCount => total <= 0 ? 1 : (total + pageSize - 1) ~/ pageSize;

  /// Số thứ tự đơn đầu/cuối trang này — nhãn "1–10 / 128".
  int get firstIndex => shown == 0 ? 0 : (page - 1) * pageSize + 1;
  int get lastIndex => shown == 0 ? 0 : firstIndex + shown - 1;

  /// Chỉ có một trang thì thanh phân trang là nhiễu, ẩn đi.
  bool get hasPages => pageCount > 1;
}

/// HomeOrders — the main "Vận đơn" tab: shop header with upload queue,
/// quick stats, a tracking-code search box, the three filter chips, the order
/// list and the bottom tab bar (Vận đơn active).
class EcHomeOrdersScreen extends StatefulWidget {
  const EcHomeOrdersScreen({
    required this.shopName,
    required this.orders,
    this.queueCount = 0,
    this.stats = const [
      EcHomeStat(value: '0', label: 'Vận đơn'),
      EcHomeStat(
        value: '0',
        label: 'Video đã quay',
        icon: LucideIcons.video,
      ),
      EcHomeStat(
        value: '0',
        label: 'Chờ tải',
        icon: LucideIcons.cloudUpload,
      ),
    ],
    this.videoTypes = const [],
    this.searchHint = 'Nhập mã vận đơn',
    this.emptyText = 'Shop chưa có đơn nào',
    this.onBack,
    this.onQueueTap,
    this.onScan,
    this.onScanResult,
    this.onSearchChanged,
    this.onFiltersChanged,
    this.onOrderTap,
    this.onRefresh,
    this.pageInfo = const EcOrderPage(),
    this.onPageChanged,
    this.isPageLoading = false,
    this.onNavOrders,
    this.onNavRecord,
    this.onNavAccount,
    super.key,
  });

  final String shopName;
  final List<EcOrderRow> orders;
  final int queueCount;
  final List<EcHomeStat> stats;

  /// Options for the "Loại video" chip — the shop's video types. An empty list
  /// leaves the chip with only its "all types" entry.
  final List<EcVideoTypeOption> videoTypes;
  final String searchHint;

  /// Shown when the shop genuinely has no orders (distinct from a search that
  /// matched nothing).
  final String emptyText;
  final VoidCallback? onBack;
  final VoidCallback? onQueueTap;

  /// Opens the barcode scanner; the returned code fills the search box.
  final Future<String?> Function()? onScan;

  /// Fired with a scanned (not typed) code — a full, exact tracking number,
  /// so the parent should show just that one order rather than every
  /// partial match [onSearchChanged] would. Falls back to [onSearchChanged]
  /// when unset.
  final ValueChanged<String>? onScanResult;

  /// Fired when the tracking-code search query changes.
  final ValueChanged<String>? onSearchChanged;

  /// Fired with the whole selection whenever any filter chip changes, so the
  /// parent can re-query the backend with all three applied at once.
  final ValueChanged<EcOrderFilters>? onFiltersChanged;
  final ValueChanged<EcOrderRow>? onOrderTap;

  /// Pull-to-refresh — reloads the current page.
  final Future<void> Function()? onRefresh;

  /// Vị trí trang hiện tại trong toàn bộ kết quả.
  final EcOrderPage pageInfo;

  /// Người dùng bấm sang trang khác (1-based). Bỏ trống = ẩn thanh phân trang.
  final ValueChanged<int>? onPageChanged;

  /// Đang tải trang mới — thanh phân trang mờ đi và không nhận thêm cú bấm.
  final bool isPageLoading;
  final VoidCallback? onNavOrders;
  final VoidCallback? onNavRecord;
  final VoidCallback? onNavAccount;

  @override
  State<EcHomeOrdersScreen> createState() => _EcHomeOrdersScreenState();
}

/// One option inside a filter chip's action sheet: the value handed back to
/// the parent, plus the label shown for it.
@immutable
class _FilterOption {
  const _FilterOption(this.value, this.label);

  /// `null` is the "no filter" entry — every chip's first option.
  final String? value;
  final String label;
}

class _EcHomeOrdersScreenState extends State<EcHomeOrdersScreen> {
  final _search = TextEditingController();
  String _query = '';

  String? _uploadState;
  String? _timeWindow;
  String? _videoTypeId;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Midnight-today / rolling 7 or 30 days, as an epoch-ms lower bound. Today
  /// starts at local midnight rather than "24h ago" so it means the same thing
  /// as the date the rows are grouped under.
  static int? _fromTsFor(String? window) {
    final now = DateTime.now();
    return switch (window) {
      'today' => DateTime(now.year, now.month, now.day).millisecondsSinceEpoch,
      '7d' => now.subtract(const Duration(days: 7)).millisecondsSinceEpoch,
      '30d' => now.subtract(const Duration(days: 30)).millisecondsSinceEpoch,
      _ => null,
    };
  }

  EcOrderFilters get _filters => EcOrderFilters(
    uploadState: _uploadState,
    fromTs: _fromTsFor(_timeWindow),
    videoTypeId: _videoTypeId,
  );

  List<_FilterOption> _statusOptions(AppLocalizations l10n) => [
    _FilterOption(null, l10n.filterStatusAll),
    _FilterOption('pending', l10n.filterStatusPending),
    _FilterOption('error', l10n.filterStatusError),
    _FilterOption('done', l10n.filterStatusDone),
  ];

  List<_FilterOption> _timeOptions(AppLocalizations l10n) => [
    _FilterOption(null, l10n.filterTimeAll),
    _FilterOption('today', l10n.filterTimeToday),
    _FilterOption('7d', l10n.filterTime7d),
    _FilterOption('30d', l10n.filterTime30d),
  ];

  List<_FilterOption> _typeOptions(AppLocalizations l10n) => [
    _FilterOption(null, l10n.filterTypeAll),
    // Shop-authored names — data, not chrome, so they are never translated.
    for (final type in widget.videoTypes) _FilterOption(type.id, type.name),
  ];

  /// Orders as handed in. Filtering is the backend's job (see
  /// [EcOrderFilters]); the only local narrowing left is the search box, and
  /// only while the parent isn't running the search server-side itself.
  List<EcOrderRow> get _visibleOrders {
    if (widget.onSearchChanged != null) return widget.orders;
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.orders;
    return widget.orders
        .where((order) => order.code.toLowerCase().contains(query))
        .toList();
  }

  void _select(void Function(String?) apply, String? value) {
    setState(() => apply(value));
    widget.onFiltersChanged?.call(_filters);
  }

  /// Opens the scanner and, if a code comes back, drops it into the search box.
  Future<void> _onScan() async {
    final code = await widget.onScan?.call();
    if (code == null || !mounted) return;
    _search.text = code;
    setState(() => _query = code);
    if (widget.onScanResult != null) {
      widget.onScanResult!(code);
    } else {
      widget.onSearchChanged?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visible = _visibleOrders;
    final unfiltered = _filters.isEmpty && _query.trim().isEmpty;
    // Tìm kiếm bỏ qua phân trang ở backend (trả hết kết quả một lần), nên
    // thanh phân trang chỉ có nghĩa khi không đang tìm kiếm.
    final showPager =
        widget.onPageChanged != null &&
        widget.pageInfo.hasPages &&
        _query.trim().isEmpty;
    return CupertinoPageScaffold(
      backgroundColor: PenColors.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ShopHeader(
              shopName: widget.shopName,
              queueCount: widget.queueCount,
              onBack: widget.onBack,
              onQueueTap: widget.onQueueTap,
            ),
            Expanded(
              child: RefreshIndicator.adaptive(
                onRefresh: widget.onRefresh ?? () async {},
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // The three stat cards are equal height in the
                      // design even when one label wraps, which inside a
                      // scroll view needs an intrinsic pass.
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < widget.stats.length; i++) ...[
                              if (i > 0) const SizedBox(width: 10),
                              Expanded(
                                child: _StatBox(stat: widget.stats[i]),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: PenBox(
                              height: 56,
                              fill: PenColors.card,
                              stroke: PenColors.line,
                              radius: 14,
                              axis: PenAxis.row,
                              gap: 12,
                              cross: CrossAxisAlignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              children: [
                                const Icon(
                                  LucideIcons.search,
                                  size: 22,
                                  color: PenColors.mut,
                                ),
                                Expanded(
                                  child: CupertinoTextField(
                                    controller: _search,
                                    onChanged: (v) {
                                      setState(() => _query = v);
                                      widget.onSearchChanged?.call(v);
                                    },
                                    textInputAction: TextInputAction.search,
                                    padding: EdgeInsets.zero,
                                    decoration: const BoxDecoration(),
                                    placeholder: widget.searchHint,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: PenColors.ink,
                                    ),
                                    placeholderStyle: const TextStyle(
                                      fontSize: 16,
                                      color: PenColors.mut,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 11),
                          EcTap(
                            onTap: widget.onScan == null ? null : _onScan,
                            child: const PenBox(
                              width: 56,
                              height: 56,
                              fill: PenColors.card,
                              stroke: PenColors.line,
                              radius: 14,
                              axis: PenAxis.row,
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.scan,
                                  size: 22,
                                  color: PenColors.ink,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              name: l10n.filterStatusLabel,
                              options: _statusOptions(l10n),
                              selected: _uploadState,
                              onSelected: (v) =>
                                  _select((x) => _uploadState = x, v),
                            ),
                            const SizedBox(width: 10),
                            _FilterChip(
                              name: l10n.filterTimeLabel,
                              options: _timeOptions(l10n),
                              selected: _timeWindow,
                              onSelected: (v) =>
                                  _select((x) => _timeWindow = x, v),
                            ),
                            const SizedBox(width: 10),
                            _FilterChip(
                              showChevron: true,
                              name: l10n.filterTypeLabel,
                              options: _typeOptions(l10n),
                              selected: _videoTypeId,
                              onSelected: (v) =>
                                  _select((x) => _videoTypeId = x, v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      // With the filters applied server-side, an empty list
                      // no longer means "this shop has no orders" — say
                      // which of the two it is.
                      if (visible.isEmpty)
                        _OrdersEmpty(
                          text: unfiltered
                              ? widget.emptyText
                              : l10n.ordersNotFound,
                          hint: unfiltered ? null : l10n.ordersNotFoundHint,
                        )
                      else
                        PenCard(
                          axis: PenAxis.column,
                          clip: true,
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 14,
                          ),
                          children: [
                            for (var i = 0; i < visible.length; i++) ...[
                              if (i > 0)
                                const PenBox(
                                  width: double.infinity,
                                  height: 1,
                                  fill: PenColors.line,
                                ),
                              _OrderTile(
                                order: visible[i],
                                onTap: widget.onOrderTap == null
                                    ? null
                                    : () => widget.onOrderTap!(visible[i]),
                              ),
                            ],
                            // Phân trang nằm trong thẻ, dưới một đường kẻ —
                            // nó thuộc về danh sách chứ không trôi tự do
                            // dưới đáy màn hình. Tìm kiếm trả về mọi kết quả
                            // trong một lần nên không có trang để chuyển.
                            if (showPager) ...[
                              const PenBox(
                                width: double.infinity,
                                height: 1,
                                fill: PenColors.line,
                              ),
                              _OrdersPager(
                                info: widget.pageInfo,
                                busy: widget.isPageLoading,
                                onPageChanged: widget.onPageChanged!,
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            _Nav3Bar(
              activeIndex: 0,
              onOrders: widget.onNavOrders,
              onRecord: widget.onNavRecord,
              onAccount: widget.onNavAccount,
            ),
          ],
        ),
      ),
    );
  }
}

/// Các ô số hiện trên thanh phân trang: cửa sổ 3 số quanh [page], kèm trang
/// cuối sau dấu "…" khi nó nằm ngoài cửa sổ. `null` = dấu "…".
///
/// ponytail: không có "1 …" ở đầu — trên màn hình 390px hàng nút sẽ tràn. Từ
/// giữa danh sách muốn về trang 1 phải bấm ‹ nhiều lần; thêm nếu người dùng
/// thực sự kêu.
List<int?> ecOrderPageWindow(int page, int count) {
  if (count <= 4) return [for (var p = 1; p <= count; p++) p];
  var start = math.max(1, page - 1);
  final end = math.min(count, start + 2);
  start = math.max(1, end - 2);
  return [
    for (var p = start; p <= end; p++) p,
    if (end < count) ...[if (end < count - 1) null, count],
  ];
}

/// Thanh phân trang cuối danh sách vận đơn: nhãn "1–10 / 128 vận đơn" bên
/// trái, các nút trang bên phải.
class _OrdersPager extends StatelessWidget {
  const _OrdersPager({
    required this.info,
    required this.busy,
    required this.onPageChanged,
  });

  final EcOrderPage info;
  final bool busy;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slots = ecOrderPageWindow(info.page, info.pageCount);
    return Opacity(
      opacity: busy ? 0.5 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.ordersPageRange(
                  info.firstIndex,
                  info.lastIndex,
                  info.total,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(12, FontWeight.w500, PenColors.mut),
              ),
            ),
            _PagerArrow(
              icon: LucideIcons.chevronLeft,
              tooltip: l10n.ordersPagePrevious,
              onTap: busy || info.page <= 1
                  ? null
                  : () => onPageChanged(info.page - 1),
            ),
            for (final slot in slots) ...[
              const SizedBox(width: _pagerGap),
              if (slot == null)
                Text('…', style: _t(13, FontWeight.w500, PenColors.mut))
              else
                _PagerNumber(
                  page: slot,
                  active: slot == info.page,
                  onTap: busy || slot == info.page
                      ? null
                      : () => onPageChanged(slot),
                ),
            ],
            const SizedBox(width: 4),
            _PagerArrow(
              icon: LucideIcons.chevronRight,
              tooltip: l10n.ordersPageNext,
              onTap: busy || info.page >= info.pageCount
                  ? null
                  : () => onPageChanged(info.page + 1),
            ),
          ],
        ),
      ),
    );
  }
}

const _pagerButtonSize = 32.0;

/// Khoảng hở giữa các nút trang. 2pt là mức khung design chốt lại để nhãn
/// "1–10 / 128 vận đơn" và cả dải nút cùng vừa bề ngang thẻ 330pt.
const _pagerGap = 2.0;

class _PagerArrow extends StatelessWidget {
  const _PagerArrow({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;

  /// `null` = hết đường theo hướng này; nút mờ đi và không bấm được.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: tooltip,
      child: EcTap(
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.4 : 1,
          child: PenBox(
            width: _pagerButtonSize,
            height: _pagerButtonSize,
            radius: _pagerButtonSize / 2,
            stroke: PenColors.line,
            axis: PenAxis.row,
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            children: [Icon(icon, size: 16, color: PenColors.ink)],
          ),
        ),
      ),
    );
  }
}

class _PagerNumber extends StatelessWidget {
  const _PagerNumber({
    required this.page,
    required this.active,
    required this.onTap,
  });

  final int page;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: context.l10n.ordersPageNumber(page),
      child: EcTap(
        onTap: onTap,
        child: PenBox(
          width: _pagerButtonSize,
          height: _pagerButtonSize,
          radius: _pagerButtonSize / 2,
          // Luật 3 của design DNA: trạng thái đang chọn là grey
          // `--sidebar-accent`, không phải green.
          fill: active ? PenColors.selected : null,
          axis: PenAxis.row,
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          children: [
            Text(
              '$page',
              style: _t(
                13,
                active ? FontWeight.w700 : FontWeight.w500,
                active ? PenColors.ink : PenColors.mut,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersEmpty extends StatelessWidget {
  const _OrdersEmpty({required this.text, this.hint});
  final String text;

  /// Shown under [text] in a smaller, muted line — the "gợi ý kiểm tra lại
  /// mã" suggestion for a search/filter that matched nothing. Omit for the
  /// "this shop has no orders at all" case, where there's no code to recheck.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 36,
            color: BrandColors.mut,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: _t(14, FontWeight.w400, BrandColors.mut),
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: _t(12, FontWeight.w400, BrandColors.mut),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.stat});
  final EcHomeStat stat;

  @override
  Widget build(BuildContext context) {
    // The design stacks the tile+number row over the label; it used to be a
    // single row with the label beside the number.
    return PenBox(
      fill: PenColors.card,
      stroke: PenColors.line,
      radius: 14,
      axis: PenAxis.column,
      gap: 8,
      cross: CrossAxisAlignment.start,
      hugMain: true,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PenBox(
              width: 36,
              height: 36,
              fill: PenColors.bg,
              radius: 10,
              axis: PenAxis.row,
              main: MainAxisAlignment.center,
              cross: CrossAxisAlignment.center,
              children: [Icon(stat.icon, size: 19, color: PenColors.ink)],
            ),
            const SizedBox(width: 10),
            PenText(
              stat.value,
              size: 24,
              color: PenColors.ink,
              weight: FontWeight.w800,
              softWrap: false,
            ),
          ],
        ),
        PenText(stat.label, size: 12, color: PenColors.mut, softWrap: false),
      ],
    );
  }
}

/// A filter pill that opens an action sheet of [options] and shows the chosen
/// one. [name] is the filter's dimension ("Thời gian"), used as the sheet title
/// and the semantics label — all three pills read some flavour of "all" until
/// touched, so without it they are indistinguishable to a screen reader.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.name,
    required this.options,
    required this.selected,
    this.onSelected,
    this.showChevron = false,
  });
  final String name;
  final List<_FilterOption> options;

  /// The design only marks the video-type filter as a dropdown; the status and
  /// time chips carry no trailing glyph.
  final bool showChevron;

  /// Value of the current selection, or null when this filter is off.
  final String? selected;
  final ValueChanged<String?>? onSelected;

  _FilterOption get _current => options.firstWhere(
    (o) => o.value == selected,
    orElse: () => options.first,
  );

  bool get _isActive => selected != null;

  Future<void> _pick(BuildContext context) async {
    // The sheet pops the chosen option's index rather than its value, so the
    // "all" entry (value null) is distinguishable from a dismissed sheet.
    final index = await showCupertinoModalPopup<int>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(name, style: _t(14, FontWeight.w500, BrandColors.mut)),
        actions: [
          for (var i = 0; i < options.length; i++)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(sheetContext).pop(i),
              child: Text(
                options[i].label,
                style: _t(
                  16,
                  options[i].value == selected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  options[i].value == selected
                      ? BrandColors.dark
                      : BrandColors.ink,
                ),
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: Text(
            context.l10n.commonCancel,
            style: _t(16, FontWeight.w600, BrandColors.ink),
          ),
        ),
      ),
    );
    if (index != null) onSelected?.call(options[index].value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: name,
      value: _current.label,
      button: true,
      child: PenChip(
        label: _current.label,
        // An active filter is narrowing the list — the design marks that with
        // the selected grey fill and a bold label, never a brand tint.
        selected: _isActive,
        trailing: showChevron ? LucideIcons.chevronDown : null,
        onTap: () => _pick(context),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order, this.onTap});
  final EcOrderRow order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final failed = order.errorCount > 0;
    return EcTap(
      onTap: onTap,
      child: PenBox(
        width: double.infinity,
        axis: PenAxis.row,
        gap: 13,
        cross: CrossAxisAlignment.center,
        padding: const EdgeInsets.symmetric(vertical: 13),
        children: [
          const PenBox(
            width: 52,
            height: 52,
            fill: PenColors.bg,
            radius: 14,
            axis: PenAxis.row,
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            children: [PenParcelGlyph()],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                PenText(
                  order.code,
                  size: 16,
                  color: PenColors.ink,
                  weight: FontWeight.w700,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                PenText(
                  '${order.time} · ${order.type}',
                  size: 12,
                  color: PenColors.mut,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // A failed upload replaces the clip count with a red error badge —
          // the count is meaningless while evidence is missing.
          if (failed)
            PenBox(
              stroke: PenColors.danger,
              radius: 999,
              axis: PenAxis.row,
              gap: 6,
              cross: CrossAxisAlignment.center,
              hugMain: true,
              padding: const EdgeInsets.symmetric(
                vertical: 3,
                horizontal: 9,
              ),
              children: [
                PenText(
                  context.l10n.orderErrorCount(order.errorCount),
                  size: 12,
                  color: PenColors.danger,
                  weight: FontWeight.w700,
                  softWrap: false,
                ),
              ],
            )
          else
            PenBox(
              axis: PenAxis.row,
              gap: 6,
              cross: CrossAxisAlignment.center,
              hugMain: true,
              children: [
                const Icon(
                  LucideIcons.video,
                  size: 19,
                  color: PenColors.ink,
                ),
                PenText(
                  '${order.videoCount}',
                  size: 16,
                  color: PenColors.ink,
                  weight: FontWeight.w700,
                  softWrap: false,
                ),
              ],
            ),
          const Icon(
            LucideIcons.chevronRight,
            size: 19,
            color: PenColors.mut,
          ),
        ],
      ),
    );
  }
}

/// EvidenceCam "Flow 1 — Vào ca" screens, built pixel-perfect from
/// `specs/projects/evidencecam/design-spec/pencil-new.pen`.
///
/// These are presentational (data-in, callbacks-out), following the same
/// conventions established in `ec_screens.dart`: every dimension, gap, font
/// size/weight and color is taken directly from the design file.
library;

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
            style: _t(15, FontWeight.w400, BrandColors.ink),
            placeholder: widget.hint,
            placeholderStyle: _t(15, FontWeight.w400, BrandColors.mut),
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
          child: Text(context.l10n.authOr, style: _t(12, FontWeight.w400, BrandColors.mut)),
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
                style: _t(15, FontWeight.w500, foreground),
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
    return Text(label, style: _t(11, FontWeight.w600, BrandColors.mut));
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
              style: _t(17, FontWeight.w600, BrandColors.ink),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BackButton(onTap: onBack, size: 24),
              const SizedBox(width: 10),
              Text(shopName, style: _t(19, FontWeight.w700, BrandColors.ink)),
            ],
          ),
          EcTap(
            onTap: onQueueTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: BrandColors.soft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.upload_outlined,
                    size: 18,
                    color: BrandColors.ink,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$queueCount',
                    style: _t(14, FontWeight.w600, BrandColors.ink),
                  ),
                ],
              ),
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
    return Container(
      decoration: const BoxDecoration(
        color: BrandColors.bg,
        border: Border(top: BorderSide(color: BrandColors.line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              icon: Icons.receipt_long_outlined,
              label: context.l10n.navOrders,
              active: activeIndex == 0,
              onTap: onOrders,
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.videocam_outlined,
              label: context.l10n.navRecord,
              active: activeIndex == 1,
              onTap: onRecord,
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.person_outline,
              label: context.l10n.navAccount,
              active: activeIndex == 2,
              onTap: onAccount,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? BrandColors.ink : BrandColors.mut;
    return EcTap(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 5),
          Text(
            label,
            style: _t(12, active ? FontWeight.w600 : FontWeight.w400, color),
          ),
        ],
      ),
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
    return Form(
      child: CupertinoPageScaffold(
        backgroundColor: BrandColors.bg,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _BackButton(onTap: onBack),
                          _LangChip(onTap: onLanguage),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Text(
                              context.l10n.authRegister,
                              style: _t(24, FontWeight.w700, BrandColors.ink),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.l10n.registerTitle,
                              style: _t(13, FontWeight.w400, BrandColors.mut),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        label: context.l10n.accountFullName,
                        hint: 'Nguyễn Văn A',
                        controller: nameController,
                        validator: FormBuilderValidators.required(
                          errorText: context.l10n.accountFullNameRequired,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        label: 'Email',
                        hint: 'ban@email.com',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: context.l10n.authEmailRequired,
                          ),
                          FormBuilderValidators.email(
                            errorText: context.l10n.authEmailInvalid,
                          ),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        label: context.l10n.phoneLabel,
                        hint: '090 123 4567',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: context.l10n.phoneRequired,
                          ),
                          // ponytail: library's general phone check; swap for a
                          // strict VN 9–11 digit rule if it proves too loose.
                          FormBuilderValidators.phoneNumber(
                            errorText: context.l10n.phoneInvalid,
                          ),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        label: context.l10n.authPassword,
                        hint: context.l10n.passwordMinHint,
                        controller: passwordController,
                        obscure: true,
                        trailing: Icons.visibility_outlined,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: context.l10n.authPasswordRequired,
                          ),
                          (value) => _passwordError(
                            context,
                            value,
                            emailController?.text,
                          ),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        label: context.l10n.registerConfirmPassword,
                        hint: '••••••••',
                        controller: confirmPasswordController,
                        obscure: true,
                        trailing: Icons.visibility_outlined,
                        validator: (value) => value == passwordController?.text
                            ? null
                            : context.l10n.passwordMismatch,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _PolicyCheckbox(
                            checked: policyAccepted,
                            onChanged: onPolicyChanged,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  context.l10n.registerAgreePolicy,
                                  style: _t(
                                    12,
                                    FontWeight.w400,
                                    BrandColors.ink,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: onViewPolicy,
                                  child: Text(
                                    context.l10n.registerViewPolicy,
                                    style: _t(
                                      12,
                                      FontWeight.w600,
                                      BrandColors.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _ValidatedPrimaryButton(
                        label: context.l10n.registerCreateAccount,
                        onValid: onRegister,
                      ),
                      const SizedBox(height: 10),
                      const _OrDivider(),
                      const SizedBox(height: 10),
                      _SocialButton(
                        label: context.l10n.authSignInGoogle,
                        background: Colors.white,
                        borderColor: const Color(0xFFDADCE0),
                        foreground: const Color(0xFF3C4043),
                        icon: const _GoogleLogo(),
                        onPressed: onGoogle,
                      ),
                      if (defaultTargetPlatform != TargetPlatform.android) ...[
                        const SizedBox(height: 10),
                        _SocialButton(
                          label: context.l10n.authSignInApple,
                          background: Colors.black,
                          borderColor: Colors.black,
                          foreground: Colors.white,
                          icon: const Icon(
                            Icons.apple,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: onApple,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        context.l10n.registerSameEmailNote,
                        textAlign: TextAlign.center,
                        style: _t(11, FontWeight.w400, BrandColors.mut),
                      ),
                      const Spacer(),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            context.l10n.registerHaveAccountPrompt,
                            style: _t(13, FontWeight.w400, BrandColors.mut),
                          ),
                          GestureDetector(
                            onTap: onLogin,
                            child: Text(
                              context.l10n.authSignIn,
                              style: _t(13, FontWeight.w600, BrandColors.ink),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyCheckbox extends StatelessWidget {
  const _PolicyCheckbox({required this.checked, this.onChanged});
  final bool checked;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!checked),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: BrandColors.dark,
          borderRadius: BorderRadius.circular(5),
        ),
        alignment: Alignment.center,
        child: checked
            ? const Icon(Icons.check, size: 11, color: Colors.white)
            : null,
      ),
    );
  }
}

// ============================================================================
// ForgotPassword
// ============================================================================

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
    return Form(
      child: CupertinoPageScaffold(
        backgroundColor: BrandColors.bg,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _BackButton(onTap: onBack),
                          _LangChip(onTap: onLanguage),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Text(
                              context.l10n.forgotPasswordTitle,
                              style: _t(24, FontWeight.w700, BrandColors.ink),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.l10n.forgotPasswordSubtitle,
                              textAlign: TextAlign.center,
                              style: _t(13, FontWeight.w400, BrandColors.mut),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        label: 'Email',
                        hint: 'ban@email.com',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: context.l10n.authEmailRequired,
                          ),
                          FormBuilderValidators.email(
                            errorText: context.l10n.authEmailInvalid,
                          ),
                        ]),
                      ),
                      const SizedBox(height: 14),
                      _ValidatedPrimaryButton(
                        label: context.l10n.forgotPasswordSubmit,
                        onValid: onSend,
                      ),
                      if (sent) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: BrandColors.soft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.mail_outline,
                                size: 16,
                                color: BrandColors.ink,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  context.l10n.forgotPasswordSent,
                                  style: _t(
                                    12,
                                    FontWeight.w400,
                                    BrandColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      const SizedBox(height: 14),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            context.l10n.forgotPasswordRememberPrompt,
                            style: _t(13, FontWeight.w400, BrandColors.mut),
                          ),
                          GestureDetector(
                            onTap: onLogin,
                            child: Text(
                              context.l10n.authSignIn,
                              style: _t(13, FontWeight.w600, BrandColors.ink),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    this.onLogout,
    this.showManage = true,
    super.key,
  });

  final List<EcShopSummary> shops;
  final ValueChanged<EcShopSummary>? onSelect;
  final VoidCallback? onManage;
  final VoidCallback? onLogout;

  /// Whether the "Quản lý cửa hàng" row is shown — hidden when the user is only
  /// staff (Nhân viên) and manages no shop (FR-05).
  final bool showManage;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.l10n.shopYourShops,
                      style: _t(22, FontWeight.w700, BrandColors.ink),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.shopTapToClockIn,
                      style: _t(13, FontWeight.w400, BrandColors.mut),
                    ),
                    const SizedBox(height: 12),
                    for (final shop in shops) ...[
                      _ShopListTile(
                        shop: shop,
                        onTap: onSelect == null ? null : () => onSelect!(shop),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (showManage) _ManageRow(onTap: onManage),
                    const Spacer(),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: onLogout,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout,
                              size: 16,
                              color: BrandColors.ink,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              context.l10n.accountSignOut,
                              style: _t(13, FontWeight.w500, BrandColors.ink),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.shopLastOpenedNote,
                      textAlign: TextAlign.center,
                      style: _t(12, FontWeight.w400, BrandColors.mut),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopListTile extends StatelessWidget {
  const _ShopListTile({required this.shop, this.onTap});
  final EcShopSummary shop;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = BrandColors.platform(shop.platform);
    return EcTap(
      onTap: onTap,
      child: Container(
        decoration: ecSquircleDecoration(
          radius: 12,
          color: BrandColors.bg,
          side: const BorderSide(color: BrandColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: BrandColors.soft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.storefront, size: 24, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      shop.name,
                      style: _t(17, FontWeight.w600, BrandColors.ink),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      shop.meta ?? _platformLabel(shop.platform),
                      style: _t(14, FontWeight.w400, BrandColors.mut),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: BrandColors.mut),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageRow extends StatelessWidget {
  const _ManageRow({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: Container(
        decoration: ecSquircleDecoration(
          radius: 12,
          color: BrandColors.soft,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(
                Icons.settings_outlined,
                size: 22,
                color: BrandColors.ink,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.shopManageStore,
                      style: _t(16, FontWeight.w600, BrandColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.shopManageVisibilityNote,
                      style: _t(13, FontWeight.w400, BrandColors.mut),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: BrandColors.mut),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// NoShop
// ============================================================================

/// NoShop — empty state shown when the account has no shop yet: create a
/// new shop, or wait for an invite.
class EcNoShopScreen extends StatelessWidget {
  const EcNoShopScreen({this.onCreate, this.onInviteTap, super.key});
  final VoidCallback? onCreate;
  final VoidCallback? onInviteTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: BrandColors.soft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  size: 36,
                  color: BrandColors.mut,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.l10n.shopEmpty,
                style: _t(18, FontWeight.w700, BrandColors.ink),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 280,
                child: Text(
                  context.l10n.shopEmptyBody,
                  textAlign: TextAlign.center,
                  style: _t(13, FontWeight.w400, BrandColors.mut),
                ),
              ),
              const SizedBox(height: 14),
              _EcPrimaryButton(
                label: context.l10n.shopCreateNew,
                onPressed: onCreate,
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: onInviteTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: BrandColors.line),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.mail_outline,
                        size: 16,
                        color: BrandColors.ink,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.shopInvitesHere,
                          style: _t(12, FontWeight.w400, BrandColors.mut),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CreateShop
// ============================================================================

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
    ('tiktok', 'TikTok Shop'),
    ('lazada', 'Lazada'),
    ('tiki', 'Tiki'),
    ('other', 'Khác'),
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      child: CupertinoPageScaffold(
        backgroundColor: BrandColors.bg,
        child: SafeArea(
          child: Column(
            children: [
              _SimpleHeader(title: context.l10n.shopCreateTitle, onBack: onBack),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Field(
                              label: context.l10n.shopNameLabel,
                              hint: context.l10n.shopNameLabel,
                              controller: nameController,
                              validator: FormBuilderValidators.required(
                                errorText: context.l10n.shopNameRequired,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.l10n.shopPlatform,
                              style: _t(13, FontWeight.w500, BrandColors.ink),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final (id, label) in _platforms)
                                  _PlatformPill(
                                    id: id,
                                    label: label,
                                    selected: selectedPlatform == id,
                                    onTap: onPlatformSelected == null
                                        ? null
                                        : () => onPlatformSelected!(id),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: BrandColors.soft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: BrandColors.ink,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      context.l10n.shopCreateOwnerNote,
                                      style: _t(
                                        12,
                                        FontWeight.w400,
                                        BrandColors.ink,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(height: 16),
                            _ValidatedPrimaryButton(
                              label: context.l10n.shopCreateTitle,
                              onValid: onCreate,
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _PlatformPill extends StatelessWidget {
  const _PlatformPill({
    required this.id,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String id;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final platformColor = BrandColors.platform(id);
    final background = selected ? platformColor : BrandColors.bg;
    final border = selected ? platformColor : BrandColors.line;
    final foreground = selected ? Colors.white : BrandColors.ink;
    return EcTap(
      onTap: onTap,
      child: Container(
        decoration: ecSquircleDecoration(
          radius: 999,
          color: background,
          side: BorderSide(color: border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 13),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.storefront,
                size: 15,
                color: selected ? Colors.white : platformColor,
              ),
              const SizedBox(width: 6),
              Text(label, style: _t(13, FontWeight.w500, foreground)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ShopMgmt
// ============================================================================

/// A shop entry as listed on the ShopMgmt screen.
class EcShopMgmtEntry {
  const EcShopMgmtEntry({
    required this.name,
    required this.meta,
    this.id,
    this.platform,
    this.resolution,
    this.role,
  });

  /// Display name.
  final String name;

  /// Preformatted meta line, e.g. "Shopee · 3 thành viên".
  final String meta;

  final String? id;
  final String? platform;
  final String? resolution;
  final String? role;
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
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            _SimpleHeader(title: context.l10n.shopManageStore, onBack: onBack),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final shop in shops) ...[
                      _ShopMgmtTile(
                        shop: shop,
                        onTap: onShopTap == null
                            ? null
                            : () => onShopTap!(shop),
                      ),
                      const SizedBox(height: 10),
                    ],
                    _AddShopRow(onTap: onAddShop),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        context.l10n.shopMgmtVisibilityNote,
                        style: _t(11, FontWeight.w400, BrandColors.mut),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopMgmtTile extends StatelessWidget {
  const _ShopMgmtTile({required this.shop, this.onTap});
  final EcShopMgmtEntry shop;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: Container(
        decoration: ecSquircleDecoration(
          radius: 12,
          color: BrandColors.bg,
          side: const BorderSide(color: BrandColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: BrandColors.soft,
                  border: Border.all(color: BrandColors.line),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      shop.name,
                      style: _t(17, FontWeight.w600, BrandColors.ink),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      shop.meta,
                      style: _t(14, FontWeight.w400, BrandColors.mut),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: BrandColors.mut),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddShopRow extends StatelessWidget {
  const _AddShopRow({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: Container(
        decoration: ecSquircleDecoration(
          radius: 12,
          color: BrandColors.bg,
          side: const BorderSide(color: BrandColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.add, size: 16, color: BrandColors.ink),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.shopAddNew,
                  style: _t(14, FontWeight.w500, BrandColors.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ShopDetail
// ============================================================================

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
    this.icon = Icons.videocam_outlined,
  });

  final String name;
  final String? id;
  final bool locked;
  final IconData icon;
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
    this.onBack,
    this.onMemberMore,
    this.onInviteMember,
    this.onTapResolution,
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
  final VoidCallback? onBack;
  final ValueChanged<EcShopMember>? onMemberMore;
  final VoidCallback? onInviteMember;
  final VoidCallback? onTapResolution;
  final ValueChanged<EcVideoType>? onEditType;
  final ValueChanged<EcVideoType>? onDeleteType;
  final VoidCallback? onAddType;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      _SectionLabel(context.l10n.sectionMembers),
      for (final member in members)
        _MemberRow(
          member: member,
          onMore: onMemberMore == null ? null : () => onMemberMore!(member),
        ),
      _InviteMemberRow(onTap: onInviteMember),
      Padding(
        padding: const EdgeInsets.only(top: 14),
        child: _SectionLabel(context.l10n.sectionShopSettings),
      ),
      _ResolutionRow(resolution: resolution, onTap: onTapResolution),
      Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(context.l10n.sectionVideoTypes),
            const SizedBox(height: 2),
            Text(
              context.l10n.videoTypesLockedNote,
              style: _t(11, FontWeight.w400, BrandColors.mut),
            ),
          ],
        ),
      ),
      for (final type in videoTypes)
        _VideoTypeRow(
          type: type,
          onEdit: onEditType == null ? null : () => onEditType!(type),
          onDelete: onDeleteType == null ? null : () => onDeleteType!(type),
        ),
      _AddTypeRow(onTap: onAddType),
    ];

    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            _SimpleHeader(title: '$shopName · $platformLabel', onBack: onBack),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < sections.length; i++) ...[
                      if (i > 0) const SizedBox(height: 6),
                      sections[i],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, this.onMore});
  final EcShopMember member;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: BrandColors.line)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BrandColors.soft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 18,
              color: BrandColors.mut,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.name,
                  style: _t(16, FontWeight.w500, BrandColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  member.role,
                  style: _t(13, FontWeight.w400, BrandColors.mut),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onMore,
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.more_horiz,
              size: 20,
              color: BrandColors.mut,
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteMemberRow extends StatelessWidget {
  const _InviteMemberRow({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            const Icon(Icons.add, size: 20, color: BrandColors.ink),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.addMemberByContact,
                style: _t(15, FontWeight.w500, BrandColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResolutionRow extends StatelessWidget {
  const _ResolutionRow({required this.resolution, this.onTap});
  final String resolution;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: BrandColors.bg,
          border: Border.all(color: BrandColors.line),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.recordResolution,
                    overflow: TextOverflow.ellipsis,
                    style: _t(16, FontWeight.w400, BrandColors.ink),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '240p / 480p / 720p',
                    overflow: TextOverflow.ellipsis,
                    style: _t(13, FontWeight.w400, BrandColors.mut),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  resolution,
                  style: _t(15, FontWeight.w500, BrandColors.ink),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: BrandColors.mut,
                ),
              ],
            ),
          ],
        ),
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
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: BrandColors.line)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(type.icon, size: 22, color: BrandColors.ink),
              const SizedBox(width: 12),
              Text(type.name, style: _t(16, FontWeight.w400, BrandColors.ink)),
            ],
          ),
          if (type.locked)
            const Icon(Icons.lock_outline, size: 18, color: BrandColors.mut)
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onEdit,
                  behavior: HitTestBehavior.opaque,
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 19,
                    color: BrandColors.mut,
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: onDelete,
                  behavior: HitTestBehavior.opaque,
                  child: const Icon(
                    Icons.delete_outline,
                    size: 19,
                    color: BrandColors.mut,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AddTypeRow extends StatelessWidget {
  const _AddTypeRow({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            const Icon(Icons.add, size: 20, color: BrandColors.ink),
            const SizedBox(width: 10),
            Text(
              context.l10n.addVideoType,
              style: _t(15, FontWeight.w500, BrandColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CreateType (modal)
// ============================================================================

/// CreateType — dialog to name a new custom video type.
class EcCreateTypeScreen extends StatelessWidget {
  const EcCreateTypeScreen({
    this.nameController,
    this.onCancel,
    this.onCreate,
    super.key,
  });

  final TextEditingController? nameController;
  final VoidCallback? onCancel;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return _EcDialogFrame(
      children: [
        Text(context.l10n.createVideoTypeTitle, style: _t(16, FontWeight.w700, BrandColors.ink)),
        _Field(
          label: context.l10n.videoTypeName,
          hint: context.l10n.videoTypeNameHint,
          controller: nameController,
        ),
        Row(
          children: [
            Expanded(
              child: _EcOutlineButton(label: context.l10n.commonCancel, onPressed: onCancel),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EcPrimaryButton(label: context.l10n.createVideoType, onPressed: onCreate),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// ConfirmDelete (modal)
// ============================================================================

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
    return _EcDialogFrame(
      children: [
        Text(
          context.l10n.deleteVideoTypeTitle(typeName),
          style: _t(16, FontWeight.w700, BrandColors.ink),
        ),
        Text(
          context.l10n.deleteVideoTypeBody,
          style: _t(13, FontWeight.w400, BrandColors.mut),
        ),
        Row(
          children: [
            Expanded(
              child: _EcOutlineButton(label: context.l10n.commonCancel, onPressed: onCancel),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EcPrimaryButton(
                label: context.l10n.deleteVideoTypeConfirm,
                onPressed: onConfirm,
              ),
            ),
          ],
        ),
        Text(
          context.l10n.deleteVideoTypeNote,
          textAlign: TextAlign.center,
          style: _t(11, FontWeight.w400, BrandColors.mut),
        ),
      ],
    );
  }
}

// ============================================================================
// InviteMember (dialog) · MemberActions (sheet) · Resolution (sheet)
// — wireframe-backlog screens for Chi tiết shop (Flow 1·9).
// ============================================================================

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
          style: _t(16, FontWeight.w700, BrandColors.ink),
        ),
        Text(
          context.l10n.addMemberBody,
          style: _t(13, FontWeight.w400, BrandColors.mut),
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
              child: _EcOutlineButton(label: context.l10n.commonCancel, onPressed: widget.onCancel),
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
                      style: _t(15, FontWeight.w600, BrandColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(desc, style: _t(13, FontWeight.w400, BrandColors.mut)),
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
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
                              style: _t(17, FontWeight.w700, BrandColors.ink),
                            ),
                            if (sub != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                sub,
                                style: _t(13, FontWeight.w400, BrandColors.mut),
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

/// A quick stat shown at the top of HomeOrders (e.g. "24" / "Vận đơn hôm nay").
class EcHomeStat {
  const EcHomeStat({required this.value, required this.label});
  final String value;
  final String label;
}

/// An order row on HomeOrders.
class EcOrderRow {
  const EcOrderRow({
    required this.code,
    required this.time,
    required this.type,
    required this.videoCount,
    this.errorCount = 0,
  });

  /// Tracking code.
  final String code;

  /// Time label, e.g. "10:23".
  final String time;

  /// Video type label, e.g. "Đóng hàng đi".
  final String type;
  final int videoCount;
  final int errorCount;
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

/// HomeOrders — the main "Vận đơn" tab: shop header with upload queue,
/// quick stats, a tracking-code search box, the three filter chips, the order
/// list and the bottom tab bar (Vận đơn active).
class EcHomeOrdersScreen extends StatefulWidget {
  const EcHomeOrdersScreen({
    required this.shopName,
    required this.orders,
    this.queueCount = 0,
    this.stats = const [
      EcHomeStat(value: '0', label: 'Vận đơn hôm nay'),
      EcHomeStat(value: '0', label: 'Video đã quay'),
      EcHomeStat(value: '0', label: 'Chờ tải'),
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
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
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

  /// Pull-to-refresh — reloads the first page.
  final Future<void> Function()? onRefresh;

  /// Called when the list is scrolled near the bottom and [hasMore] is true.
  final VoidCallback? onLoadMore;

  /// Whether a next page is currently being fetched (shows a trailing spinner).
  final bool isLoadingMore;

  /// Whether more pages remain to load.
  final bool hasMore;
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

  /// Triggers [EcHomeOrdersScreen.onLoadMore] when the user scrolls within
  /// [_loadMoreThreshold] of the bottom and more pages remain.
  static const _loadMoreThreshold = 240.0;
  bool _onScroll(ScrollNotification n) {
    if (!widget.hasMore || widget.isLoadingMore || widget.onLoadMore == null) {
      return false;
    }
    if (n.metrics.pixels >= n.metrics.maxScrollExtent - _loadMoreThreshold) {
      widget.onLoadMore!.call();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleOrders;
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
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
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            for (var i = 0; i < widget.stats.length; i++) ...[
                              if (i > 0) const SizedBox(width: 10),
                              Expanded(child: _StatBox(stat: widget.stats[i])),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: ecSquircleDecoration(
                            radius: 12,
                            color: BrandColors.soft,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                size: 20,
                                color: BrandColors.mut,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CupertinoTextField(
                                  controller: _search,
                                  onChanged: (v) {
                                    setState(() => _query = v);
                                    widget.onSearchChanged?.call(v);
                                  },
                                  textInputAction: TextInputAction.search,
                                  style: _t(
                                    16,
                                    FontWeight.w400,
                                    BrandColors.ink,
                                  ),
                                  placeholder: widget.searchHint,
                                  placeholderStyle: _t(
                                    16,
                                    FontWeight.w400,
                                    BrandColors.mut,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 11,
                                  ),
                                  decoration: const BoxDecoration(),
                                ),
                              ),
                              EcTap(
                                onTap: widget.onScan == null ? null : _onScan,
                                child: const Icon(
                                  Icons.qr_code_scanner,
                                  size: 22,
                                  color: BrandColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                name: context.l10n.filterStatusLabel,
                                options: _statusOptions(context.l10n),
                                selected: _uploadState,
                                onSelected: (v) =>
                                    _select((x) => _uploadState = x, v),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                name: context.l10n.filterTimeLabel,
                                options: _timeOptions(context.l10n),
                                selected: _timeWindow,
                                onSelected: (v) =>
                                    _select((x) => _timeWindow = x, v),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                name: context.l10n.filterTypeLabel,
                                options: _typeOptions(context.l10n),
                                selected: _videoTypeId,
                                onSelected: (v) =>
                                    _select((x) => _videoTypeId = x, v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // With the filters applied server-side, an empty list
                        // no longer means "this shop has no orders" — say
                        // which of the two it is.
                        if (visible.isEmpty)
                          _OrdersEmpty(
                            text:
                                _filters.isEmpty && _query.trim().isEmpty
                                ? widget.emptyText
                                : context.l10n.ordersNotFound,
                          )
                        else
                          for (final order in visible) ...[
                            _OrderTile(
                              order: order,
                              onTap: widget.onOrderTap == null
                                  ? null
                                  : () => widget.onOrderTap!(order),
                            ),
                            const SizedBox(height: 14),
                          ],
                        if (widget.isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CupertinoActivityIndicator()),
                          ),
                      ],
                    ),
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

class _OrdersEmpty extends StatelessWidget {
  const _OrdersEmpty({required this.text});
  final String text;

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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        color: BrandColors.soft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(stat.value, style: _t(24, FontWeight.w700, BrandColors.ink)),
          const SizedBox(height: 4),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: _t(13, FontWeight.w400, BrandColors.mut),
          ),
        ],
      ),
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
  });
  final String name;
  final List<_FilterOption> options;

  /// Value of the current selection, or null when this filter is off.
  final String? selected;
  final ValueChanged<String?>? onSelected;

  _FilterOption get _current =>
      options.firstWhere((o) => o.value == selected, orElse: () => options.first);

  bool get _isActive => selected != null;

  Future<void> _pick(BuildContext context) async {
    // The sheet pops the chosen option's index rather than its value, so the
    // "all" entry (value null) is distinguishable from a dismissed sheet.
    final index = await showCupertinoModalPopup<int>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(name, style: _t(13, FontWeight.w500, BrandColors.mut)),
        actions: [
          for (var i = 0; i < options.length; i++)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(sheetContext).pop(i),
              child: Text(
                options[i].label,
                style: _t(
                  16,
                  options[i].value == selected
                      ? FontWeight.w700
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
          child: Text(context.l10n.commonCancel, style: _t(16, FontWeight.w600, BrandColors.ink)),
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
      child: EcTap(
        onTap: () => _pick(context),
        child: DecoratedBox(
          // An active filter is narrowing the list — make that visible, so an
          // empty list reads as "filtered" rather than "no data".
          decoration: ecSquircleDecoration(
            radius: 999,
            color: _isActive ? BrandColors.soft : BrandColors.bg,
            side: BorderSide(
              color: _isActive ? BrandColors.dark : BrandColors.line,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _current.label,
                  style: _t(
                    15,
                    _isActive ? FontWeight.w600 : FontWeight.w500,
                    _isActive ? BrandColors.dark : BrandColors.ink,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: _isActive ? BrandColors.dark : BrandColors.mut,
                ),
              ],
            ),
          ),
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: BrandColors.line)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: BrandColors.soft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 22,
                color: BrandColors.mut,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    order.code,
                    style: _t(16, FontWeight.w600, BrandColors.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.time} · ${order.type}',
                    style: _t(14, FontWeight.w400, BrandColors.mut),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.videocam_outlined,
                  size: 20,
                  color: BrandColors.ink,
                ),
                const SizedBox(width: 5),
                Text(
                  '${order.videoCount}',
                  style: _t(15, FontWeight.w600, BrandColors.ink),
                ),
                if (order.errorCount > 0) ...[
                  const SizedBox(width: 3),
                  Text(
                    context.l10n.ordersErrorCount(order.errorCount),
                    style: _t(13, FontWeight.w600, BrandColors.rec),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, size: 20, color: BrandColors.mut),
          ],
        ),
      ),
    );
  }
}

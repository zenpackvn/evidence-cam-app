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
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

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
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
          child: Text('hoặc', style: _t(12, FontWeight.w400, BrandColors.mut)),
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
    required this.iconColor,
    this.onPressed,
  });

  final String label;
  final Color background;
  final Color borderColor;
  final Color foreground;
  final IconData icon;
  final Color iconColor;
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
            Icon(icon, size: 20, color: iconColor),
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

/// Bottom tab bar (`C/Nav3`): Đơn hàng / Ghi hình / Tài khoản.
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
              label: 'Đơn hàng',
              active: activeIndex == 0,
              onTap: onOrders,
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.videocam_outlined,
              label: 'Ghi hình',
              active: activeIndex == 1,
              onTap: onRecord,
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.person_outline,
              label: 'Tài khoản',
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
                              'Đăng ký',
                              style: _t(24, FontWeight.w700, BrandColors.ink),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tạo tài khoản mới',
                              style: _t(13, FontWeight.w400, BrandColors.mut),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        label: 'Họ tên',
                        hint: 'Nguyễn Văn A',
                        controller: nameController,
                        validator: FormBuilderValidators.required(
                          errorText: 'Vui lòng nhập họ tên',
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
                            errorText: 'Vui lòng nhập email',
                          ),
                          FormBuilderValidators.email(
                            errorText: 'Email không hợp lệ',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        label: 'Số điện thoại',
                        hint: '090 123 4567',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Vui lòng nhập số điện thoại',
                          ),
                          // ponytail: library's general phone check; swap for a
                          // strict VN 9–11 digit rule if it proves too loose.
                          FormBuilderValidators.phoneNumber(
                            errorText: 'Số điện thoại không hợp lệ',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        label: 'Mật khẩu',
                        hint: 'Tối thiểu 8 ký tự',
                        controller: passwordController,
                        obscure: true,
                        trailing: Icons.visibility_outlined,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Vui lòng nhập mật khẩu',
                          ),
                          FormBuilderValidators.minLength(
                            8,
                            errorText: 'Mật khẩu tối thiểu 8 ký tự',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        label: 'Nhập lại mật khẩu',
                        hint: '••••••••',
                        controller: confirmPasswordController,
                        obscure: true,
                        trailing: Icons.visibility_outlined,
                        validator: (value) => value == passwordController?.text
                            ? null
                            : 'Mật khẩu nhập lại không khớp',
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
                                  'Tôi đồng ý chính sách ',
                                  style: _t(
                                    12,
                                    FontWeight.w400,
                                    BrandColors.ink,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: onViewPolicy,
                                  child: Text(
                                    'Xem chính sách',
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
                        label: 'Tạo tài khoản',
                        onValid: onRegister,
                      ),
                      const SizedBox(height: 10),
                      const _OrDivider(),
                      const SizedBox(height: 10),
                      Text(
                        'Cùng email sẽ tự liên kết về một tài khoản',
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
                            'Đã có tài khoản? ',
                            style: _t(13, FontWeight.w400, BrandColors.mut),
                          ),
                          GestureDetector(
                            onTap: onLogin,
                            child: Text(
                              'Đăng nhập',
                              style: _t(13, FontWeight.w600, BrandColors.ink),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              label: 'Google',
                              background: Colors.white,
                              borderColor: const Color(0xFFDADCE0),
                              foreground: const Color(0xFF3C4043),
                              icon: Icons.g_mobiledata,
                              iconColor: const Color(0xFF4285F4),
                              onPressed: onGoogle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SocialButton(
                              label: 'Apple',
                              background: Colors.black,
                              borderColor: Colors.black,
                              foreground: Colors.white,
                              icon: Icons.apple,
                              iconColor: Colors.white,
                              onPressed: onApple,
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
                              'Quên mật khẩu',
                              style: _t(24, FontWeight.w700, BrandColors.ink),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Nhập email để nhận link đặt lại mật khẩu',
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
                            errorText: 'Vui lòng nhập email',
                          ),
                          FormBuilderValidators.email(
                            errorText: 'Email không hợp lệ',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 14),
                      _ValidatedPrimaryButton(
                        label: 'Gửi link đặt lại',
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
                                  'Đã gửi — kiểm tra hộp thư (kể cả mục spam)',
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
                            'Nhớ mật khẩu rồi? ',
                            style: _t(13, FontWeight.w400, BrandColors.mut),
                          ),
                          GestureDetector(
                            onTap: onLogin,
                            child: Text(
                              'Đăng nhập',
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

  /// Display name, e.g. "Shop ABC".
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
                      'Shop của bạn',
                      style: _t(22, FontWeight.w700, BrandColors.ink),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chạm shop để vào ca · quản lý ngay tại đây',
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
                              'Đăng xuất',
                              style: _t(13, FontWeight.w500, BrandColors.ink),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Shop vào gần nhất sẽ được mở thẳng ở lần sau',
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
                      'Quản lý cửa hàng',
                      style: _t(16, FontWeight.w600, BrandColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chỉ hiện với Chủ tài khoản / Quản lý shop',
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
                'Chưa có shop nào',
                style: _t(18, FontWeight.w700, BrandColors.ink),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 280,
                child: Text(
                  'Tài khoản của bạn chưa thuộc shop nào. Tạo shop mới để bắt '
                  'đầu, hoặc chờ lời mời từ chủ shop.',
                  textAlign: TextAlign.center,
                  style: _t(13, FontWeight.w400, BrandColors.mut),
                ),
              ),
              const SizedBox(height: 14),
              _EcPrimaryButton(
                label: 'Tạo shop mới (tên + sàn)',
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
                          'Lời mời vào shop sẽ hiện ở đây',
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
    ('khac', 'Khác'),
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      child: CupertinoPageScaffold(
        backgroundColor: BrandColors.bg,
        child: SafeArea(
          child: Column(
            children: [
              _SimpleHeader(title: 'Tạo shop', onBack: onBack),
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
                              label: 'Tên shop',
                              hint: 'Ví dụ: Shop ABC',
                              controller: nameController,
                              validator: FormBuilderValidators.required(
                                errorText: 'Vui lòng nhập tên shop',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sàn thương mại',
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
                                      'Bạn sẽ là Chủ shop — thêm thành viên sau '
                                      'trong Quản lý cửa hàng',
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
                              label: 'Tạo shop',
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
  const EcShopMgmtEntry({required this.name, required this.meta});

  /// Display name, e.g. "Shop ABC".
  final String name;

  /// Preformatted meta line, e.g. "Shopee · 3 thành viên".
  final String meta;
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
            _SimpleHeader(title: 'Quản lý cửa hàng', onBack: onBack),
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
                        'Nhân viên không thấy màn này · QL shop chỉ thấy shop '
                        'mình quản',
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
                  'Thêm shop mới (tên + sàn)',
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
  const EcShopMember({required this.name, required this.role});
  final String name;
  final String role;
}

/// A configurable video type on the ShopDetail screen. The three built-in
/// types (Đóng hàng, ĐV vận chuyển, Trả hàng) are `locked` and only show a
/// lock icon; custom types show edit/delete actions.
class EcVideoType {
  const EcVideoType({
    required this.name,
    this.locked = false,
    this.icon = Icons.videocam_outlined,
  });

  final String name;
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
      const _SectionLabel('THÀNH VIÊN'),
      for (final member in members)
        _MemberRow(
          member: member,
          onMore: onMemberMore == null ? null : () => onMemberMore!(member),
        ),
      _InviteMemberRow(onTap: onInviteMember),
      const Padding(
        padding: EdgeInsets.only(top: 14),
        child: _SectionLabel('CÀI ĐẶT SHOP'),
      ),
      _ResolutionRow(resolution: resolution, onTap: onTapResolution),
      Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel('LOẠI VIDEO'),
            const SizedBox(height: 2),
            Text(
              '3 loại có sẵn bị khóa — không sửa/xóa được',
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
                'Mời thành viên (chưa có tài khoản → gửi lời mời)',
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
                    'Độ phân giải quay',
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
              'Thêm loại (nhập tên)',
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
        Text('Tạo loại video', style: _t(16, FontWeight.w700, BrandColors.ink)),
        _Field(
          label: 'Tên loại video',
          hint: 'Ví dụ: Cân hàng',
          controller: nameController,
        ),
        Row(
          children: [
            Expanded(
              child: _EcOutlineButton(label: 'Hủy', onPressed: onCancel),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EcPrimaryButton(label: 'Tạo loại', onPressed: onCreate),
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
/// being offered for new videos (old videos keep the type).
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
          'Xóa loại “$typeName”?',
          style: _t(16, FontWeight.w700, BrandColors.ink),
        ),
        Text(
          'Loại này đã được dùng trong các video. Các video cũ vẫn được giữ '
          'nguyên nhưng người dùng sẽ không thể chọn loại này cho video mới.',
          style: _t(13, FontWeight.w400, BrandColors.mut),
        ),
        Row(
          children: [
            Expanded(
              child: _EcOutlineButton(label: 'Hủy', onPressed: onCancel),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EcPrimaryButton(
                label: 'Ngừng sử dụng',
                onPressed: onConfirm,
              ),
            ),
          ],
        ),
        Text(
          '(Video cũ vẫn giữ nguyên)',
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

/// InviteMember — dialog to invite a user to the shop by email/phone with a
/// role. Fills the "Mời thành viên" control that previously had no destination.
class EcInviteMemberScreen extends StatefulWidget {
  const EcInviteMemberScreen({
    this.contactController,
    this.onCancel,
    this.onInvite,
    super.key,
  });

  final TextEditingController? contactController;
  final VoidCallback? onCancel;

  /// Fires with the chosen role ('Nhân viên' | 'Quản lý shop').
  final ValueChanged<String>? onInvite;

  @override
  State<EcInviteMemberScreen> createState() => _EcInviteMemberScreenState();
}

class _EcInviteMemberScreenState extends State<EcInviteMemberScreen> {
  String _role = 'Nhân viên';

  @override
  Widget build(BuildContext context) {
    return _EcDialogFrame(
      children: [
        Text('Mời thành viên', style: _t(16, FontWeight.w700, BrandColors.ink)),
        Text(
          'Nhập email hoặc số điện thoại — người chưa có tài khoản sẽ nhận lời '
          'mời để đăng ký vào shop.',
          style: _t(13, FontWeight.w400, BrandColors.mut),
        ),
        _Field(
          label: 'Email hoặc số điện thoại',
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
              child: _EcOutlineButton(label: 'Hủy', onPressed: widget.onCancel),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EcPrimaryButton(
                label: 'Gửi lời mời',
                onPressed: () => widget.onInvite?.call(_role),
              ),
            ),
          ],
        ),
      ],
    );
  }
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
      subtitle: 'Vai trò hiện tại: ${member.role}',
      children: [
        _EcSheetActionRow(
          icon: Icons.shield_outlined,
          label: 'Đặt làm Quản lý shop',
          selected: isManager,
          onTap: onSetManager,
        ),
        _EcSheetActionRow(
          icon: Icons.person_outline,
          label: 'Đặt làm Nhân viên',
          selected: !isManager,
          onTap: onSetStaff,
        ),
        _EcSheetActionRow(
          icon: Icons.person_remove_outlined,
          label: 'Gỡ khỏi shop',
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
      title: 'Độ phân giải quay',
      subtitle: 'Áp dụng cho video quay mới của shop',
      children: [
        for (final r in _options)
          _EcSheetActionRow(
            icon: Icons.videocam_outlined,
            label: r == '720p' ? '720p (mặc định)' : r,
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

/// A quick stat shown at the top of HomeOrders (e.g. "24" / "Đơn hôm nay").
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

  /// Tracking code, e.g. "SPXVN024567890".
  final String code;

  /// Time label, e.g. "10:23".
  final String time;

  /// Video type label, e.g. "Đóng hàng đi".
  final String type;
  final int videoCount;
  final int errorCount;
}

/// HomeOrders — the main "Đơn hàng" tab: shop header with upload queue,
/// quick stats, a tracking-code search box, filter chips, the order list and
/// the bottom tab bar (Đơn hàng active).
/// Label of the type-filter chip — the only chip backed by real order data
/// today. `ponytail:` status/date chips are select-only until orders carry
/// those fields; wire their predicates here once the backend supplies them.
const _typeFilterLabel = 'Loại video';

class EcHomeOrdersScreen extends StatefulWidget {
  const EcHomeOrdersScreen({
    required this.shopName,
    required this.orders,
    this.queueCount = 0,
    this.stats = const [
      EcHomeStat(value: '24', label: 'Đơn hôm nay'),
      EcHomeStat(value: '38', label: 'Video đã quay'),
      EcHomeStat(value: '4', label: 'Chờ tải'),
    ],
    this.filters = const ['Tất cả', 'Hôm nay', 'Loại video'],
    this.searchHint = 'Nhập mã vận đơn',
    this.emptyText = 'Shop chưa có đơn nào',
    this.onBack,
    this.onQueueTap,
    this.onScan,
    this.onFilterTap,
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
  final List<String> filters;
  final String searchHint;

  /// Shown when the shop genuinely has no orders (distinct from a search that
  /// matched nothing).
  final String emptyText;
  final VoidCallback? onBack;
  final VoidCallback? onQueueTap;

  /// Opens the barcode scanner; the returned code fills the search box.
  final Future<String?> Function()? onScan;

  /// Fired with the chosen value whenever a filter chip's selection changes.
  final ValueChanged<String>? onFilterTap;
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

class _EcHomeOrdersScreenState extends State<EcHomeOrdersScreen> {
  final _search = TextEditingController();
  String _query = '';

  /// Selected value per chip index; defaults to the chip's own label (= "all").
  final _selected = <int, String>{};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _selectionFor(int i) => _selected[i] ?? widget.filters[i];

  /// Menu options for chip [i]. The type chip is populated from the distinct
  /// order types actually present; the others get a small static set so they
  /// still function as selects.
  List<String> _optionsFor(int i) {
    final label = widget.filters[i];
    if (label == _typeFilterLabel) {
      final types = {for (final o in widget.orders) o.type};
      return [label, ...types];
    }
    return [label];
  }

  /// Orders after applying the search query and the type filter.
  List<EcOrderRow> get _visibleOrders {
    final query = _query.trim().toLowerCase();
    return widget.orders.where((order) {
      if (query.isNotEmpty && !order.code.toLowerCase().contains(query)) {
        return false;
      }
      for (final entry in _selected.entries) {
        final label = widget.filters[entry.key];
        if (label == _typeFilterLabel &&
            entry.value != label &&
            order.type != entry.value) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _onFilterSelected(int i, String value) {
    setState(() => _selected[i] = value);
    widget.onFilterTap?.call(value);
  }

  /// Opens the scanner and, if a code comes back, drops it into the search box.
  Future<void> _onScan() async {
    final code = await widget.onScan?.call();
    if (code == null || !mounted) return;
    _search.text = code;
    setState(() => _query = code);
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
                                  onChanged: (v) => setState(() => _query = v),
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
                              for (
                                var i = 0;
                                i < widget.filters.length;
                                i++
                              ) ...[
                                if (i > 0) const SizedBox(width: 8),
                                _FilterChip(
                                  label: _selectionFor(i),
                                  options: _optionsFor(i),
                                  onSelected: (v) => _onFilterSelected(i, v),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (widget.orders.isEmpty)
                          _OrdersEmpty(text: widget.emptyText)
                        else if (visible.isEmpty)
                          const _OrdersEmpty(text: 'Không tìm thấy đơn hàng')
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.options,
    this.onSelected,
  });
  final String label;
  final List<String> options;
  final ValueChanged<String>? onSelected;

  Future<void> _pick(BuildContext context) async {
    final choice = await showCupertinoModalPopup<String>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(label, style: _t(13, FontWeight.w500, BrandColors.mut)),
        actions: [
          for (final option in options)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(sheetContext).pop(option),
              child: Text(
                option,
                style: _t(16, FontWeight.w500, BrandColors.ink),
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: Text('Hủy', style: _t(16, FontWeight.w600, BrandColors.ink)),
        ),
      ),
    );
    if (choice != null) onSelected?.call(choice);
  }

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: () => _pick(context),
      child: DecoratedBox(
        decoration: ecSquircleDecoration(
          radius: 999,
          color: BrandColors.bg,
          side: const BorderSide(color: BrandColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: _t(15, FontWeight.w500, BrandColors.ink)),
              const SizedBox(width: 6),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: BrandColors.mut,
              ),
            ],
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
                    '· ${order.errorCount} lỗi',
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

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
        CupertinoButton,
        CupertinoDatePicker,
        CupertinoDatePickerMode,
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

import 'invite_contact.dart';

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

/// Shop header (`C/ShopHeader`): back arrow + shop name, nothing else.
///
/// Khung F1-12/F2-01 chỉ có nút back, tên shop và một spacer chiếm phần còn
/// lại — không có chip mây. Chip đó từng nằm ở đây và đẩy toàn bộ màn xuống
/// 9pt so với design; lối vào hàng đợi upload giờ là thẻ "Chờ tải".
class _ShopHeader extends StatelessWidget {
  const _ShopHeader({
    required this.shopName,
    this.onBack,
    this.onShopTap,
    this.onSettings,
  });

  final String shopName;
  final VoidCallback? onBack;

  /// Chạm vào tên shop mở Chi tiết cửa hàng (F1-09).
  final VoidCallback? onShopTap;

  /// Bánh răng góc phải: mở Quản lý cửa hàng.
  ///
  /// Lối vào đó trước nằm ở màn Chọn cửa hàng — một màn người dùng chỉ đi qua
  /// một lần lúc vào ca rồi không quay lại nữa. Muốn sửa cài đặt shop thì phải
  /// thoát ca ra ngoài. Nay nó nằm ngay trong ca làm.
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    // Header nằm trên [PenBrandBanner] nên chữ và mũi tên đều trắng.
    //
    // Đệm trên 0: header dính sát mép dưới vùng an toàn. Đây là SÀN — thấp
    // hơn nữa phải bỏ `SafeArea`, và lúc đó tên shop chui vào tai thỏ.
    //
    // Vùng an toàn của iOS đã chừa sẵn chỗ cho tai thỏ, nên 28 của bản gốc là
    // một dải trống cộng thêm, nhìn ra như lỗi căn lề chứ không phải khoảng thở.
    //
    // Sửa số này thì phải sửa chiều cao `PenBrandBanner` ở `EcHomeOrdersScreen`
    // đúng bằng chừng ấy — banner neo vào tai thỏ chứ không trôi theo nội dung,
    // nên lệch nhau là ô nhập mã vận đơn thụt vào vùng xanh.
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Row(
        children: [
          PenBackButton(onTap: onBack, color: PenColors.card),
          const SizedBox(width: 14),
          Expanded(
            child: EcTap(
              onTap: onShopTap,
              child: PenText(
                shopName,
                size: 24,
                color: PenColors.card,
                weight: FontWeight.w800,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // The upload-queue chip used to live here; the "Chờ tải" stat card
          // below already shows the same number and is the tap target now.
          if (onSettings != null)
            EcTap(
              onTap: onSettings,
              child: const Padding(
                // Lề phải 0 để bánh răng thẳng hàng với mép phải của ba thẻ số
                // bên dưới; đệm quanh chỉ để nới vùng chạm.
                padding: EdgeInsets.fromLTRB(10, 6, 0, 6),
                child: Icon(
                  LucideIcons.settings,
                  size: 24,
                  color: PenColors.card,
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
    this.onClaims,
  });

  final int activeIndex;
  final VoidCallback? onOrders;
  final VoidCallback? onRecord;

  /// Tab thứ ba nay là Hồ sơ khiếu nại, không còn là Tài khoản.
  ///
  /// Tài khoản dời ra màn Chọn cửa hàng — nó là thứ mỗi ca chạm một lần, trong
  /// khi hồ sơ khiếu nại là việc làm giữa ca, ngay sau khi quay xong. Một chỗ
  /// đi qua hằng ngày không nên chiếm ô tab của việc làm hằng giờ.
  final VoidCallback? onClaims;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenTabBar(
      activeIndex: activeIndex,
      tabs: [
        (LucideIcons.package, l10n.navOrders, onOrders),
        (LucideIcons.camera, l10n.navRecord, onRecord),
        (LucideIcons.fileText, l10n.navClaims, onClaims),
      ],
    );
  }
}

/// Lớp `Dim` thiết kế vẽ sau mọi hộp thoại — cùng mã màu với `PenSheet`.
const _ecDialogDim = Color(0xA6636363);

/// Shared frame for the two modal dialogs (CreateType, ConfirmDelete): a
/// dimmed backdrop with a centered white rounded card, 12px gap between
/// [children].
///
/// Nền phải là `Dim` chứ không phải trong suốt: route mở hộp thoại
/// (`_modalPage`) đã cố ý đặt `barrierColor: transparent` vì tin rằng mỗi màn
/// modal tự vẽ lớp mờ của mình. Khung này lại để trong suốt, nên hộp thoại nổi
/// lên giữa một màn hình vẫn sáng nguyên — không có gì tách nó khỏi trang bên
/// dưới.
class _EcDialogFrame extends StatelessWidget {
  const _EcDialogFrame({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _ecDialogDim,
      child: Stack(
        children: [
          // Bấm ra ngoài thẻ: bàn phím đang mở thì HẠ BÀN PHÍM trước, lần bấm
          // sau mới đóng hộp thoại.
          //
          // Đang gõ dở mà bấm ra ngoài, ý người dùng là "cho tôi nhìn lại cái
          // form" chứ không phải "vứt hết đi làm lại". Đóng thẳng là mất chữ
          // vừa nhập. Cùng cách xử lý hai nhịp với `PenSheet`.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (MediaQuery.viewInsetsOf(context).bottom > 0) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  return;
                }
                Navigator.of(context).maybePop();
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: GestureDetector(
                  // Bấm vào chỗ trống trong thẻ cũng hạ bàn phím — nút bấm và
                  // ô nhập vẫn nhận chạm của chúng như thường.
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  // Thẻ phóng nhẹ từ 0.94 lên 1 khi hiện: chỉ mờ dần thì hộp
                  // thoại "có sẵn ở đó rồi", còn nảy lên thì mắt bám theo được
                  // là nó vừa mở ra.
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.94, end: 1),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: ecSquircleDecoration(
                        radius: 16,
                        color: BrandColors.bg,
                        // Thiết kế nhấc mọi hộp thoại khỏi lớp `Dim`.
                        shadows: const [
                          BoxShadow(
                            color: Color(0x33161616),
                            offset: Offset(0, 14),
                            blurRadius: 36,
                          ),
                        ],
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
    this.showApple = true,
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

  /// Whether to offer Apple sign-up at all. False on platforms with no native
  /// Apple ID sheet, where the button could only ever fail.
  final bool showApple;
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
                  // Không bắt buộc và không chặn gì: email là danh tính, số
                  // điện thoại chỉ để hỗ trợ tài khoản khi cần liên hệ.
                  PenStackedField(
                    icon: LucideIcons.phone,
                    label: l10n.phoneOptionalLabel,
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
                  if (showApple) ...[
                    const SizedBox(height: 12),
                    PenOutlineButton(
                      label: l10n.registerWithApple,
                      icon: const PenAppleMark(),
                      onPressed: onApple,
                    ),
                  ],
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

/// ChooseShop — "Shop của bạn": chạm một shop để vào ca, một thẻ Tài khoản,
/// rồi hai hàng ghim đáy: thêm cửa hàng và đăng xuất.
class EcChooseShopScreen extends StatelessWidget {
  const EcChooseShopScreen({
    required this.shops,
    this.onSelect,
    this.onAccountTap,
    this.onAddShop,
    this.onJoinByInvite,
    this.onLogout,
    super.key,
  });

  final List<EcShopSummary> shops;

  final ValueChanged<EcShopSummary>? onSelect;

  /// Mở màn Tài khoản. Nó không còn là một tab — tab thứ ba nay là Hồ sơ khiếu
  /// nại, thứ người bán mở giữa ca. Tài khoản thì mỗi ca chạm một lần, nên nó
  /// về đúng chỗ đi qua một lần: màn chọn cửa hàng.
  final VoidCallback? onAccountTap;

  /// Dấu cộng xanh cạnh tiêu đề — lối tạo shop DUY NHẤT, cố định ở màn này.
  ///
  /// Quản lý cửa hàng đã dời vào bánh răng ở header trang Vận đơn, nên nó không
  /// còn là chỗ chứa nút tạo shop được: muốn vào đó phải đang ở trong một shop.
  final VoidCallback? onAddShop;

  /// "Tôi có lời mời" — dán link trong email mời để vào shop.
  ///
  /// Máy chủ KHÔNG tự ghép lời mời treo với tài khoản lúc đăng nhập, kể cả khi
  /// email trùng: token trong link mới là bằng chứng sở hữu hộp thư. Không có
  /// lối này thì người được mời đăng nhập vào app và thấy một màn trống, không
  /// hiểu vì sao shop mời mình lại không có ở đây.
  final VoidCallback? onJoinByInvite;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenScreen(
      scrollable: false,
      decorations: const [
        // Cụm icon sàn kéo lên sát mép trên: nút Tài khoản nay chiếm góc phải
        // nên khoảng trống phía trên không còn chỗ dùng.
        Positioned(left: 49, top: 4, child: PenPlatformHero()),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nút Tài khoản: viên xanh góc phải TRÊN CÙNG, chỉ một chữ.
          //
          // Trước nó là một thẻ to bằng thẻ shop, đứng lẫn trong danh sách —
          // mà đây không phải một cửa hàng. Đưa lên góc và thu lại thành một
          // viên nhỏ thì nó thôi giả làm shop, và trả chỗ cho danh sách.
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: onAccountTap == null
                    ? const SizedBox.shrink()
                    : _AccountPill(onTap: onAccountTap!),
              ),
            ),
          ),
          // Tiêu đề KHOÁ cùng nút Tài khoản, ngoài vùng cuộn: nó nói màn này
          // đang hỏi gì, mà một câu hỏi trôi mất khi kéo danh sách thì người
          // dùng phải cuộn ngược lên mới nhớ mình đang ở đâu.
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 88, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dấu cộng đứng sát tiêu đề nhưng KHÔNG được xô nó lệch trục
                // giữa màn: ô trống bên trái rộng đúng bằng nút + khoảng hở,
                // nên "Chọn cửa hàng" vẫn căn giữa như khi chưa có nút. Nút
                // nhô cao hơn dòng chữ bằng đệm dưới — nhô bằng toạ độ âm thì
                // phần trồi ra ngoài khung mất luôn vùng chạm.
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (onAddShop != null) const SizedBox(width: 46),
                    Flexible(
                      child: PenText(
                        l10n.shopChooseTitle,
                        size: 30,
                        color: PenColors.ink,
                        weight: FontWeight.w800,
                        align: TextAlign.center,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onAddShop != null) ...[
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _AddShopButton(onTap: onAddShop!),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                PenText(
                  l10n.shopChooseSubtitle,
                  size: 14,
                  color: PenColors.mut,
                  align: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < shops.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _ShopRow(
                      shop: shops[i],
                      onTap: onSelect == null
                          ? null
                          : () => onSelect!(shops[i]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Hai hàng này GHIM ở đáy, ngoài vùng cuộn: tài khoản nhiều shop thì
          // danh sách dài quá màn, mà "thêm cửa hàng" với "đăng xuất" là hai
          // việc không thuộc về cuối danh sách — chúng thuộc về cả màn hình.
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (onJoinByInvite != null) ...[
                    _JoinByInviteRow(onTap: onJoinByInvite),
                    const SizedBox(height: 4),
                  ],
                  _LogoutRow(onTap: onLogout),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút Tài khoản ở góc phải trên màn Chọn cửa hàng — viên bo tròn xanh, đúng
/// một chữ.
///
/// Trước nó là một thẻ to bằng thẻ shop, có avatar và email, đứng lẫn trong
/// danh sách cửa hàng. Nhưng tài khoản KHÔNG phải một cửa hàng: để cùng khuôn
/// và cùng hàng với chúng là mời người dùng chạm nhầm khi đang vội chọn shop
/// vào ca.
class _AccountPill extends StatelessWidget {
  const _AccountPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => EcTap(
    onTap: onTap,
    child: PenBox(
      fill: PenColors.primary,
      radius: 999,
      axis: PenAxis.row,
      gap: 7,
      hugMain: true,
      cross: CrossAxisAlignment.center,
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 15),
      children: [
        const Icon(LucideIcons.user, size: 17, color: PenColors.card),
        PenText(
          context.l10n.navAccount,
          size: 14,
          color: PenColors.card,
          weight: FontWeight.w700,
          softWrap: false,
        ),
      ],
    ),
  );
}

/// One selectable shop: platform tile, name + meta, navigation chevron. The
/// selected row is filled `--secondary` grey (the design never tints it
/// green).
class _ShopRow extends StatelessWidget {
  const _ShopRow({required this.shop, this.onTap});

  final EcShopSummary shop;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PenCard(
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
        // Tapping a row goes straight into the shop, so the design ends it
        // with a chevron — there is no confirm step a radio would feed.
        const Icon(
          LucideIcons.chevronRight,
          size: 22,
          color: PenColors.ink,
        ),
      ],
    );
  }
}

/// Dấu cộng xanh cạnh tiêu đề "Chọn cửa hàng" — lối vào màn tạo cửa hàng.
///
/// Nhãn chữ đi vào [Semantics] chứ không hiện ra: một viên tròn 36 điểm là đủ
/// to để chạm, còn trình đọc màn hình vẫn phải nghe được đây là "Thêm cửa hàng
/// mới" thay vì một dấu cộng không rõ làm gì.
class _AddShopButton extends StatelessWidget {
  const _AddShopButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.l10n.shopAddNew,
    child: EcTap(
      onTap: onTap,
      child: const PenBox(
        width: 36,
        height: 36,
        fill: PenColors.primary,
        radius: 999,
        axis: PenAxis.row,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        children: const [
          Icon(LucideIcons.plus, size: 21, color: PenColors.card),
        ],
      ),
    ),
  );
}

/// "Tôi có lời mời" — cùng khuôn với hàng thêm cửa hàng, ngay dưới nó.
///
/// Đứng cạnh "Thêm cửa hàng mới" vì hai hàng trả lời cùng một câu hỏi của
/// người đang nhìn một màn trống: làm sao để có cửa hàng ở đây.
class _JoinByInviteRow extends StatelessWidget {
  const _JoinByInviteRow({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => EcTap(
    onTap: onTap,
    child: PenBox(
      width: double.infinity,
      stroke: PenColors.soft,
      radius: 14,
      axis: PenAxis.row,
      gap: 10,
      main: MainAxisAlignment.center,
      cross: CrossAxisAlignment.center,
      padding: const EdgeInsets.symmetric(vertical: 15),
      children: [
        const Icon(LucideIcons.qrCode, size: 20, color: PenColors.ink),
        Flexible(
          child: PenText(
            context.l10n.inviteJoinRow,
            size: 16,
            color: PenColors.link,
            weight: FontWeight.w700,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

/// The centred `log-out` + "Đăng xuất" row both shop-picking screens end on —
/// the only way out of an account that has no shop to enter.
class _LogoutRow extends StatelessWidget {
  const _LogoutRow({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Không padding thì vùng bấm chỉ cao bằng dòng 16pt — hầu hết cú chạm
    // trượt ra ngoài.
    return EcTap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.logOut, size: 18, color: PenColors.ink),
            const SizedBox(width: 8),
            PenText(
              context.l10n.accountSignOut,
              size: 16,
              color: PenColors.ink,
              weight: FontWeight.w700,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }
}

/// NoShop — empty state shown when the account has no shop yet: create a
/// new shop, or wait for an invite.
class EcNoShopScreen extends StatelessWidget {
  const EcNoShopScreen({
    this.onCreate,
    this.onAccountTap,
    this.onJoinByInvite,
    this.onLogout,
    super.key,
  });
  final VoidCallback? onCreate;

  /// Nút Tài khoản, cùng viên xanh góc phải như màn chọn shop.
  ///
  /// Tài khoản vừa đăng ký rơi thẳng vào màn này và mắc kẹt: đổi ngôn ngữ, xem
  /// hồ sơ, đổi mật khẩu đều nằm trong Tài khoản, mà đường duy nhất tới đó lại
  /// đi qua một shop — thứ người mới chưa có. Trước đây màn này chỉ có "Đăng
  /// xuất", nên lựa chọn thật sự là làm lại từ đầu.
  final VoidCallback? onAccountTap;

  /// Quét mã QR lời mời. Đây là màn hình người vừa được mời đứng khi họ mở app
  /// lần đầu, nên nó là chỗ đúng nhất để có nút này.
  final VoidCallback? onJoinByInvite;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenScreen(
      decorations: [
        const Positioned(left: 49, top: 118, child: PenPlatformHero()),
        // Cùng vị trí, cùng hình dáng với màn chọn shop: hai màn này là hai
        // mặt của một chỗ đứng, nên nút Tài khoản phải ở đúng một nơi.
        if (onAccountTap != null)
          Positioned(
            right: 22,
            top: 8,
            child: SafeArea(
              bottom: false,
              child: _AccountPill(onTap: onAccountTap!),
            ),
          ),
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
            // Chỉ còn MỘT đường nhận lời mời: hàng "Tôi có lời mời" ngay dưới.
            // Trước đây trên nó còn một thẻ "Lời mời vào shop sẽ hiện ở đây",
            // nhưng bên gọi nối cả hai vào cùng một hàm `_joinByInvite` — bấm
            // chỗ nào cũng ra đúng màn quét mã. Hai hàng cho một việc chỉ làm
            // người mới tưởng đây là hai thứ khác nhau.
            if (onJoinByInvite != null) ...[
              const SizedBox(height: 14),
              _JoinByInviteRow(onTap: onJoinByInvite),
            ],
            const SizedBox(height: 24),
            _LogoutRow(onTap: onLogout),
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
        // Hình minh hoạ neo ở đáy màn. Nếu để bàn phím bóp màn lại, chạm vào ô
        // "Tên cửa hàng" là cả cụm hình + nút bị hất lên giữa màn.
        resizeToAvoidBottomInset: false,
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
    this.email,
    this.accountUid,
    this.roleCode,
    this.inviteId,
  });
  final String name;
  final String role;

  /// Địa chỉ hộp thư, hiện ngay dưới tên.
  ///
  /// Một cửa hàng có hai người trùng tên là chuyện thường, và tên hiển thị thì
  /// người dùng tự đặt — nên tên KHÔNG phân biệt được ai với ai. Email thì có.
  ///
  /// Để rỗng khi chính nó đã là dòng tên: lời mời chưa có tài khoản thì thứ duy
  /// nhất biết được về người ta là địa chỉ đã mời, và in lại lần nữa ở dòng
  /// dưới chỉ là hai dòng nói cùng một điều.
  final String? email;
  final String? accountUid;
  final String? roleCode;

  /// Có giá trị = hàng này là lời mời còn treo, chưa khớp tài khoản nào. Đổi
  /// vai trò không áp vào đâu được; việc duy nhất làm được là xóa lời mời.
  final String? inviteId;
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
/// Khe giữa hai thẻ nhóm trên Chi tiết cửa hàng. Lớn hơn [_sectionRowGap] để
/// ranh giới giữa hai nhóm luôn rõ hơn ranh giới giữa hai mục cùng nhóm.
const _sectionCardGap = 12.0;

/// Khe giữa các mục *trong* một thẻ nhóm. `PenBox` nhân số này với
/// `penDensityScale` nên ~10pt thật.
const _sectionRowGap = 12.0;

/// Khe giữa một hàng cài đặt và dòng chú thích "Đề xuất …" của chính nó. Phải
/// nhỏ hơn [_sectionRowGap] sau khi nhân tỉ lệ, nếu không chú thích nằm lửng
/// giữa hai hàng và không biết thuộc hàng nào.

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
    this.onShopQr,
    this.onEditType,
    this.onDeleteType,
    this.onAddType,
    this.onTapStorage,
    this.storageLabel = '',
    this.onDeleteShop,
    this.onRenameShop,
    this.membersError = false,
    this.membersUnavailable = false,
    this.onRetryMembers,
    this.readOnly = false,
    super.key,
  });

  /// Chế độ chỉ xem, dành cho nhân viên.
  ///
  /// Không chỉ là bỏ trống callback: những hàng chỉ tồn tại để mở ra một thao
  /// tác — "Mời thành viên", "Thêm loại" — bị ẩn hẳn. Một nút bấm không ăn thì
  /// người dùng bấm đi bấm lại rồi kết luận app hỏng, chứ không đoán ra là
  /// mình không có quyền.
  final bool readOnly;

  final String shopName;
  final String platformLabel;
  final List<EcShopMember> members;

  /// Đọc danh sách thành viên hỏng.
  ///
  /// Tách hẳn khỏi "[members] rỗng": một cửa hàng luôn có ít nhất người tạo ra
  /// nó, nên danh sách trống đọc ra là mất chủ shop chứ không phải chưa tải
  /// được. Bật cờ này thì phần thành viên báo lỗi kèm nút thử lại, phần còn
  /// lại của màn hình vẫn dùng bình thường.
  final bool membersError;

  /// Vai trò hiện tại không được xem danh sách thành viên.
  ///
  /// Khác hẳn [membersError]: đây không phải hỏng mà là không có quyền, nên
  /// không có nút thử lại — bấm bao nhiêu lần cũng vẫn 403. Nhân viên thấy một
  /// dòng nói rõ vì sao trống, thay vì một khối lỗi mời họ thử lại mãi mãi.
  final bool membersUnavailable;
  final VoidCallback? onRetryMembers;
  final List<EcVideoType> videoTypes;
  final String resolution;
  final ClipBudget clipBudget;
  final VoidCallback? onBack;
  final ValueChanged<EcShopMember>? onMemberMore;

  /// Mở mã QR vào cửa hàng. `null` = không hiện nút (nhân viên, hoặc bên gọi
  /// chưa nối).
  final VoidCallback? onShopQr;
  final VoidCallback? onInviteMember;

  /// Trần riêng cho ảnh và cho video. Rỗng thì hàng vẫn hiện nhưng bấm không
  /// ra gì — bên gọi phải nối cả hai.
  final ValueChanged<EcVideoType>? onEditType;
  final ValueChanged<EcVideoType>? onDeleteType;
  final VoidCallback? onAddType;

  /// Xoá hẳn cửa hàng. `null` = không hiện nút (nhân viên, hoặc bên gọi chưa
  /// nối). Rào chắn "phải gỡ hết người trước" nằm ở bên gọi, không ở đây: màn
  /// này biết danh sách thành viên nhưng không biết ai đang đăng nhập.
  /// Kho lưu trữ. Mở cho mọi vai trò — xem tình trạng kho không phải đặc quyền
  /// của chủ shop, chỉ ĐỔI kho mới là.
  final VoidCallback? onTapStorage;

  /// Dòng tóm tắt kho đang dùng ("Cloud Zenpack", "Kho riêng của bạn"…).
  final String storageLabel;

  final VoidCallback? onDeleteShop;

  /// Đổi tên cửa hàng. `null` = không hiện bút sửa (nhân viên).
  final VoidCallback? onRenameShop;

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
            const SizedBox(height: _sectionCardGap),
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
                // Bút sửa nằm ngay cạnh tên, không phải trong một màn cài đặt
                // riêng: tên shop là thứ đầu tiên trên màn này, sửa nó là việc
                // của đúng chỗ đó. Nhân viên không thấy nút.
                if (!readOnly && onRenameShop != null)
                  EcTap(
                    onTap: onRenameShop,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        LucideIcons.pencil,
                        size: 20,
                        color: PenColors.mut,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: _sectionCardGap),
            _PenSectionCard(
              icon: LucideIcons.users,
              label: l10n.sectionMembers,
              children: [
                if (membersUnavailable)
                  _MembersNoticeRow(
                    icon: LucideIcons.lock,
                    message: l10n.membersRestricted,
                  )
                else if (membersError)
                  _MembersNoticeRow(
                    icon: LucideIcons.triangleAlert,
                    message: l10n.errorLoadMembers,
                    onRetry: onRetryMembers,
                  )
                else
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
                if (!readOnly)
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
                        // Mã QR là ĐƯỜNG MỜI THỨ HAI, không phải cách trình
                        // bày khác của đường thứ nhất: mời qua email dành cho
                        // người chưa có tài khoản, còn quét mã dành cho người
                        // đã có — họ chỉ cần vào shop, không cần ai gõ đúng
                        // địa chỉ hộp thư của họ. Nên nó đứng cùng hàng, ở
                        // rìa phải, chứ không nằm sau bước nhập email.
                        if (onShopQr != null)
                          EcTap(
                            onTap: onShopQr,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                LucideIcons.qrCode,
                                size: 24,
                                color: PenColors.ink,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: _sectionCardGap),
            _PenSectionCard(
              icon: LucideIcons.settings,
              label: l10n.sectionShopSettings,
              children: [
                // Hai mức CỐ ĐỊNH, không đặt được. Độ phân giải thì đổi ngay
                // trên thanh dưới màn quay nên không nằm ở đây.
                //
                // Trần ẢNH thì CÒN, và cố ý còn. Đợt 2026-08-07 bỏ trần theo
                // byte của QUOTA — quota nay tính theo số video, một tấm ảnh
                // nặng bao nhiêu cũng không tốn suất nào. Còn 5 MB ở đây là
                // chặn một TỆP ĐƠN LẺ, để ảnh máy ảnh 40MB không đi qua đường
                // đính kèm; xem [kFixedImageBytes]. Chú thích cũ ở chỗ này ghi
                // là "đã bỏ, không còn trần nào" trong khi dòng ngay dưới vẫn
                // hiện đúng con số đó.
                _FixedSettingRow(
                  icon: LucideIcons.timer,
                  label: l10n.shopDetailClipLength,
                  value: l10n.clipDurationValue('${kFixedClipSeconds ~/ 60}'),
                ),
                _FixedSettingRow(
                  icon: LucideIcons.fileUp,
                  label: l10n.shopDetailImageSize,
                  value: l10n.uploadSizeValue('${kFixedImageBytes ~/ 1000000}'),
                ),
                // Kho lưu trữ mở cho MỌI vai trò, khác các hàng trên. Kho hỏng
                // là chuyện xảy ra giữa ca đóng hàng và người đầu tiên chịu là
                // người đang cầm máy quay — bắt họ đi hỏi chủ shop mới biết
                // clip của mình đang nằm ở đâu là quá muộn.
                _FixedSettingRow(
                  icon: LucideIcons.hardDrive,
                  label: l10n.storageTitle,
                  value: storageLabel,
                  onTap: onTapStorage,
                ),
              ],
            ),
            const SizedBox(height: _sectionCardGap),
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
                if (!readOnly)
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
            // Xoá shop nằm CUỐI CÙNG, tách khỏi mọi thẻ khác, và chỉ chủ shop
            // thấy. Đây là thao tác không hoàn tác được duy nhất trên màn này.
            if (!readOnly && onDeleteShop != null) ...[
              const SizedBox(height: _sectionCardGap),
              _DeleteShopRow(onTap: onDeleteShop!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Nút xoá shop — đỏ, viền, không phải nút đặc.
///
/// Nút đặc màu đỏ ở cuối một danh sách cài đặt hút mắt hơn mọi thứ trên màn và
/// mời người ta chạm thử. Đây là thao tác không lấy lại được, nên nó phải nhìn
/// ra là nghiêm trọng mà không nhìn ra là hấp dẫn.
class _DeleteShopRow extends StatelessWidget {
  const _DeleteShopRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => EcTap(
    onTap: onTap,
    child: PenBox(
      width: double.infinity,
      stroke: PenColors.danger,
      radius: 12,
      axis: PenAxis.row,
      gap: 10,
      main: MainAxisAlignment.center,
      cross: CrossAxisAlignment.center,
      padding: const EdgeInsets.symmetric(vertical: 13),
      children: [
        const Icon(LucideIcons.trash2, size: 20, color: PenColors.danger),
        PenText(
          context.l10n.shopDeleteTitle,
          size: 16,
          color: PenColors.danger,
          weight: FontWeight.w700,
          softWrap: false,
        ),
      ],
    ),
  );
}

/// Một hàng cài đặt CỐ ĐỊNH ở màn chi tiết cửa hàng.
///
/// Không bấm được, không mũi tên, không sheet. Trước đây hai hàng này mở ra
/// một danh sách mốc để chọn, nhưng con số chọn xong đi qua ba tầng kẹp (shop
/// đặt → trần gói → server kẹp lại) nên thứ hiện ra thường không phải thứ vừa
/// bấm. Đặt được mà không giữ được thì khó chịu hơn hẳn không cho đặt.
///
/// Giá trị lấy từ [kFixedClipSeconds] — cùng hằng số máy quay dùng, nên dòng
/// chữ ở đây không thể lệch với thứ app thật sự làm.
class _FixedSettingRow extends StatelessWidget {
  const _FixedSettingRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Null = hàng chỉ đọc (mức cố định). Có = hàng mở sang màn khác, và khi đó
  /// chữ "mặc định" nhường chỗ cho mũi tên — hai kiểu hàng phải nhìn ra khác
  /// nhau, không thì người dùng đi tìm chỗ bấm trên một hàng không bấm được.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => EcTap(
    onTap: onTap,
    child: _row(context),
  );

  Widget _row(BuildContext context) => PenBox(
    width: double.infinity,
    fill: PenColors.card,
    stroke: PenColors.line,
    radius: 10,
    axis: PenAxis.row,
    gap: 14,
    cross: CrossAxisAlignment.center,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    children: [
      PenBox(
        width: 38,
        height: 38,
        fill: PenColors.bg,
        radius: 10,
        axis: PenAxis.row,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        children: [Icon(icon, size: 22, color: PenColors.ink)],
      ),
      // Nhãn co lại trước, giá trị giữ chỗ theo nội dung nhưng CÓ TRẦN.
      //
      // Trước đây giá trị là một `PenText` trần với `softWrap: false`: gặp một
      // giá trị dài — "Kho đám mây riêng (chuẩn S3)" chẳng hạn — là hàng tràn
      // ra ngoài khung thẻ, và phần tràn nằm ngoài vùng chạm nên hàng trông
      // như bấm không ăn.
      Flexible(
        child: PenText(
          label,
          size: 16,
          color: PenColors.ink,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Flexible(
        child: PenText(
          value,
          size: 16,
          color: PenColors.ink,
          weight: FontWeight.w600,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          align: TextAlign.end,
        ),
      ),
      // Chữ "mặc định" thay chỗ mũi tên cũ. Bỏ trống chỗ đó thì hàng trông y
      // như một hàng bấm được vừa hỏng; nói thẳng đây là mức mặc định thì
      // người dùng thôi tìm chỗ bấm.
      if (onTap == null)
        PenText(
          context.l10n.settingDefaultSuffix,
          size: 13,
          color: PenColors.mut,
          softWrap: false,
        )
      else
        const Icon(LucideIcons.chevronRight, size: 18, color: PenColors.mut),
    ],
  );
}

/// Amber of the design file's warn bar (F3-05) — the one warning colour the
/// EvidenceCam DNA has; reused here so the two screens read as the same system.
const _warnInk = Color(0xFFB6770B);

String _minutes(int seconds) => '${(seconds / 60).round()}';

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
      // Không có gap thì nhãn nhóm, các hàng và nút ở cuối thẻ xếp sát 0pt và
      // đọc thành một khối liền — mỗi con là một mục riêng nên phải có khe.
      gap: _sectionRowGap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 13),
      children: [
        Row(
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
        ...children,
      ],
    );
  }
}

/// Chỗ của danh sách thành viên khi đọc hỏng — nói rõ là chưa tải được, kèm
/// đường thử lại. Thà thừa một dòng chữ còn hơn để trống và bị đọc thành
/// "cửa hàng này không có ai".
/// Dòng thay chỗ danh sách thành viên: đọc hỏng (có [onRetry]) hoặc không đủ
/// quyền để đọc (không có).
class _MembersNoticeRow extends StatelessWidget {
  const _MembersNoticeRow({
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenBox(
      width: double.infinity,
      axis: PenAxis.row,
      gap: 12,
      cross: CrossAxisAlignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        Icon(icon, size: 20, color: PenColors.mut),
        Expanded(
          child: PenText(
            message,
            size: 14,
            color: PenColors.mut,
            lineHeight: 1.4,
          ),
        ),
        if (onRetry != null)
          EcTap(
            onTap: onRetry,
            child: PenText(
              l10n.commonRetry,
              size: 14,
              color: PenColors.link,
              weight: FontWeight.w700,
              softWrap: false,
            ),
          ),
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
    // Chủ shop không đổi vai trò được và cũng không gỡ khỏi shop được, nên màn
    // quản lý thành viên mở ra chẳng có hành động nào — bấm vào là mở rồi đóng
    // lại tay không. Bỏ luôn cả vùng bấm lẫn mũi tên để hàng này trông đúng
    // bản chất: một dòng thông tin, không phải một mục bấm được.
    final isOwner = member.roleCode == 'owner';
    // Cùng lý do khi [onTap] rỗng: nhân viên mở màn này chỉ thấy đúng dòng của
    // chính mình, và không có thao tác nào trên nó. Mũi tên ở đó là lời hứa
    // suông — bấm vào không đi đâu cả.
    final tappable = !isOwner && onTap != null;
    return EcTap(
      onTap: tappable ? onTap : null,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                PenText(
                  member.name,
                  size: 16,
                  color: PenColors.ink,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((member.email ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  PenText(
                    member.email!,
                    size: 12.5,
                    color: PenColors.mut,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // `Flexible` chứ không để viên nhãn tự do: nó dùng `softWrap: false`
          // nên chiếm đúng bề rộng của chữ, và một nhãn dài
          // ("Nhân viên · chờ xác nhận") trên màn hẹp đẩy cả hàng tràn ra ngoài
          // — đo được 33px trong test. Cho nó co lại và cắt bằng dấu ba chấm;
          // phần tên bên trái đã `Expanded` nên hai bên tự chia nhau.
          //
          // `Align` là thứ ghim nhãn vào mép phải. Không có nó, `Flexible` chỉ
          // *cho phép* nhãn nhỏ hơn phần được chia chứ không trả lại chỗ thừa:
          // nhãn ngắn ("Chủ shop") nằm sát mép trái phần của mình, tức lơ lửng
          // giữa hàng, và mỗi hàng lại lệch một kiểu tuỳ độ dài chữ.
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: PenBox(
                fill: PenColors.bg,
                radius: 999,
                axis: PenAxis.row,
                hugMain: true,
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 11,
                ),
                children: [
                  Flexible(
                    child: PenText(
                      member.role,
                      size: 12,
                      color: PenColors.ink,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Chỗ của mũi tên luôn được giữ, kể cả hàng không bấm được (chủ shop,
          // hoặc nhân viên tự xem mình). Bỏ hẳn ô này thì hàng đó rộng thêm
          // đúng bằng mũi tên + khoảng cách, và viên nhãn của nó thò ra phải
          // hơn các hàng khác — nhìn là thấy so le ngay.
          SizedBox(
            width: 18,
            child: tappable
                ? const Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: PenColors.mut,
                  )
                : null,
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
                  // Khung 44pt của design chỉ vừa trên máy rộng ≥390pt; máy
                  // 360pt thì mỗi ô chỉ còn ~42.7pt và hàng bị tràn. Bám trần
                  // 44pt nhưng co theo ô để không máy nào tràn.
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final diameter = math.min(44.0, constraints.maxWidth);
                      final size = i == selectedColor ? diameter - 8 : diameter;
                      return PenBox(
                        height: 48,
                        stroke: i == selectedColor ? PenColors.line : null,
                        strokeWidth: 2,
                        radius: 999,
                        axis: PenAxis.row,
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        children: [
                          PenEllipse(
                            width: size,
                            height: size,
                            color: _colorChoices[i],
                          ),
                        ],
                      );
                    },
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

/// InviteMember — dialog to add an existing user to the shop by email with a
/// role. Fills the member control that previously had no destination.
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
  /// Mã vai trò backend hiểu, KHÔNG phải nhãn hiển thị.
  ///
  /// Giữ nhãn tiếng Việt ở đây rồi suy ngược ra mã bằng `contains('Quản lý')`
  /// là máy để tiếng Anh thì gán nhầm ai cũng thành nhân viên. Nhãn là thứ
  /// dịch được; mã thì không.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: _buildDialog(context),
    );
  }

  Widget _buildDialog(BuildContext context) {
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
          label: context.l10n.emailLabel,
          hint: 'ban@email.com',
          controller: widget.contactController,
          keyboardType: TextInputType.emailAddress,
          // Gõ sai định dạng thì backend vẫn nhận và tạo một lời mời không bao
          // giờ tới được ai — chặn ngay tại đây thay vì để nó chết âm thầm.
          validator: (value) {
            final contact = (value ?? '').trim();
            if (contact.isEmpty) return context.l10n.emailRequired;
            return isInviteContact(contact) ? null : context.l10n.emailInvalid;
          },
        ),
        // Chỉ còn MỘT vai trò mời được: nhân viên. Shop có đúng hai hạng —
        // chủ và nhân viên — nên một danh sách một lựa chọn là thừa, và một nút
        // radio luôn sáng mà bấm không được thì còn tệ hơn: nó trông như một
        // lựa chọn. Nói thẳng bằng chữ.
        Text(
          context.l10n.inviteRoleFixedNote,
          style: _t(13, FontWeight.w400, BrandColors.mut),
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
                  // Chốt cửa theo controller — đó mới là chuỗi sẽ gửi đi.
                  // `FormField` chỉ cập nhật khi người dùng gõ (`onChanged`),
                  // nên lấy nó làm cửa là hai nguồn sự thật khác nhau. Vẫn gọi
                  // `validate()` để dòng lỗi được vẽ ra.
                  _formKey.currentState?.validate();
                  final contact = widget.contactController?.text ?? '';
                  if (!isInviteContact(contact.trim())) return;
                  widget.onInvite?.call(
                    // Mã vai trò backend hiểu, KHÔNG phải nhãn hiển thị: gửi
                    // nhãn rồi để server suy ngược là máy đổi ngôn ngữ thì gán
                    // nhầm. Hai cấp nên chỉ còn đúng một mã.
                    EcMemberInvite(inviteContactOf(contact), 'staff'),
                  );
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

  /// Email đã viết thường, sẵn sàng gửi lên backend.
  final String contact;

  /// Mã vai trò backend hiểu: `staff` hoặc `manager`. Không phải nhãn hiển
  /// thị — nhãn đổi theo ngôn ngữ máy, mã thì không.
  final String role;
}

/// MemberActions — bottom sheet from the ⋮ on a member row: change role or
/// remove from shop.
class EcMemberActionsScreen extends StatelessWidget {
  const EcMemberActionsScreen({
    required this.member,
    this.onRemove,
    super.key,
  });

  final EcShopMember member;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    // Chủ cửa hàng KHÔNG có hàng trong shop_members — quyền sở hữu nằm ở
    // shops.owner_uid. Đổi vai trò trả 404, còn gỡ thì trước đây trả 204 mà
    // không gỡ gì: người dùng nhận thông báo "đã gỡ" cho một việc chưa xảy ra.
    // Không bày ra hai việc máy chủ không làm được.
    final isOwner = member.roleCode == 'owner';
    // Lời mời chưa ai nhận thì không có tài khoản để đổi vai trò — bày hai dòng
    // đó ra chỉ để bấm vào là báo lỗi. Còn đúng một việc: xóa lời mời.
    final isPendingInvite = member.inviteId != null;
    return _EcSheetFrame(
      title: member.name,
      subtitle: context.l10n.memberCurrentRole(member.role),
      children: [
        if (isOwner)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: PenText(
              context.l10n.memberOwnerLocked,
              size: 13,
              color: PenColors.mut,
            ),
          )
        else ...[
          // Không còn hai dòng đổi vai trò: shop chỉ có chủ và nhân viên, mà
          // chủ thì không đổi được (quyền sở hữu nằm ở `shops.owner_uid`).
          // Còn đúng một việc làm được với một thành viên: gỡ họ ra.
          _EcSheetActionRow(
            icon: isPendingInvite
                ? Icons.delete_outline
                : Icons.person_remove_outlined,
            label: isPendingInvite
                ? context.l10n.revokeInvite
                : context.l10n.removeFromShop,
            destructive: true,
            onTap: onRemove,
          ),
        ],
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

  /// Trần thời lượng, tính bằng phút.
  ///
  /// Thời lượng clip là trần DUY NHẤT còn lại, và backend từ chối thẳng khi
  /// vượt. Chặn ở đây thì người dùng thấy con số được phép; không chặn thì họ
  /// thấy một lỗi mạng không liên quan gì tới việc họ vừa làm.
  int get _planMaxMinutes => (budget.planMaxSeconds / 60).floor();

  /// Các mốc gợi ý, cắt theo trần.
  List<int> get _options {
    final marks = [..._marks];
    final max = _planMaxMinutes;
    // Mốc vượt trần gói bị bỏ hẳn, không phải làm mờ: bấm được mà máy chủ từ
    // chối thì tệ hơn không hiện. Trần bằng 0 (backend chưa trả) nghĩa là chưa
    // biết, nên không cắt gì cả.
    return [
      for (final m in marks)
        if (max <= 0 || m <= max) m,
    ]..sort();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedMinutes = (budget.seconds / 60).round();
    return _EcSheetFrame(
      title: l10n.clipDurationTitle,
      subtitle: l10n.clipDurationSubtitle,
      children: [
        for (final m in _options)
          _EcSheetActionRow(
            icon: LucideIcons.timer,
            label: l10n.clipDurationValue('$m'),
            selected: m == selectedMinutes,
            onTap: () => onSelect?.call(m * 60),
          ),
        // Số tự nhập đứng riêng ở CUỐI danh sách gợi ý, không trộn vào giữa
        // các mốc: nó là lựa chọn của riêng shop này, xếp lẫn vào thì mở sheet
        // ra không phân biệt được đâu là mốc có sẵn, đâu là mức mình đã đặt.
        if (!_options.contains(selectedMinutes))
          _EcSheetActionRow(
            icon: LucideIcons.timer,
            label: l10n.clipDurationValue('$selectedMinutes'),
            selected: true,
            onTap: () => onSelect?.call(selectedMinutes * 60),
          ),
        _EcSheetCustomInput(
          label: l10n.clipDurationCustomLabel,
          unit: l10n.unitMinutes,
          min: 1,
          // Trần của GÓI, thứ backend thật sự enforce. Gõ quá số này thì máy
          // chủ từ chối, và app dịch cái từ chối đó thành "kiểm tra mạng" —
          // nên chặn ở đây, kèm đúng con số được phép. 0 nghĩa là backend chưa
          // trả trần nào, lúc đó đừng bịa ra một cái.
          max: _planMaxMinutes > 0 ? _planMaxMinutes : null,
          initial: selectedMinutes,
          onSubmit: (m) => onSelect?.call(m * 60),
        ),
      ],
    );
  }
}

/// Shared bottom-sheet chrome for flow-1 sheets (dim scrim + rounded panel).
/// Ô nhập tự do cho sheet thời lượng clip.
///
/// Các mốc bên trên chỉ là gợi ý — chủ shop nào cũng có thể có ràng buộc riêng
/// mà một danh sách cố định không phủ hết, nên phải cho gõ thẳng con số. Giá
/// trị ngoài khoảng [min]..[max] bị chặn tại chỗ kèm lý do, thay vì để backend
/// từ chối sau khi người dùng đã rời màn.
class _EcSheetCustomInput extends StatefulWidget {
  const _EcSheetCustomInput({
    required this.label,
    required this.unit,
    required this.min,
    required this.initial,
    required this.onSubmit,
    this.max,
  });

  final String label;
  final String unit;

  /// Giá trị nhỏ nhất chấp nhận được.
  final int min;

  /// Giá trị lớn nhất, hoặc `null` khi thật sự không có trần.
  ///
  /// Dung lượng tệp thì không có trần: shop trả tiền theo dung lượng thực dùng
  /// nên đặt bao nhiêu là quyền của họ. Thời lượng clip thì CÓ — gói quy định
  /// (`plan_max_clip_seconds`) và backend từ chối số vượt. Không kẹp ở đây thì
  /// người dùng gõ 60 phút, ăn một lỗi trông y như lỗi mạng, và không có gì
  /// nói cho họ biết con số nào mới được.
  final int? max;
  final int initial;

  /// Nhận giá trị đã hợp lệ, theo đúng đơn vị hiển thị (phút hoặc MB).
  final ValueChanged<int> onSubmit;

  @override
  State<_EcSheetCustomInput> createState() => _EcSheetCustomInputState();
}

class _EcSheetCustomInputState extends State<_EcSheetCustomInput> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial.toString(),
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text.trim());
    final max = widget.max;
    if (value == null || value < widget.min || (max != null && value > max)) {
      // Có trần thì nêu CẢ khoảng: người gõ quá cần biết số nào mới được, chứ
      // "nhập từ 1 trở lên" không nói gì về việc 60 vừa bị từ chối.
      setState(
        () => _error = max == null
            ? context.l10n.sheetCustomMin('${widget.min}', widget.unit)
            : context.l10n.sheetCustomRange(
                '${widget.min}',
                '$max',
                widget.unit,
              ),
      );
      return;
    }
    setState(() => _error = null);
    widget.onSubmit(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PenText(widget.label, size: 13, color: PenColors.mut),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: PenBox(
                  height: 48,
                  fill: PenColors.card,
                  stroke: _error == null ? PenColors.line : PenColors.danger,
                  radius: 12,
                  axis: PenAxis.row,
                  cross: CrossAxisAlignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _controller,
                        padding: EdgeInsets.zero,
                        decoration: const BoxDecoration(),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                        onSubmitted: (_) => _submit(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: PenColors.ink,
                        ),
                      ),
                    ),
                    PenText(widget.unit, size: 14, color: PenColors.mut),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              EcTap(
                onTap: _submit,
                child: PenBox(
                  height: 48,
                  fill: PenColors.primary,
                  radius: 12,
                  axis: PenAxis.row,
                  main: MainAxisAlignment.center,
                  cross: CrossAxisAlignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    PenText(
                      l10n.commonApply,
                      size: 15,
                      color: PenColors.card,
                      weight: FontWeight.w700,
                      softWrap: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: PenText(_error!, size: 12, color: PenColors.danger),
            ),
        ],
      ),
    );
  }
}

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
    // Khung này từng tự dựng lại panel: góc vuông, không kéo xuống được, và
    // bọc SafeArea *chồng lên* padding đáy 28 nên đuôi sheet thừa một dải
    // trắng. PenSheet đã có sẵn cả ba thứ — dùng lại thay vì sửa bản sao.
    return PenSheet(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _t(16, FontWeight.w600, BrandColors.ink)),
              if (sub != null) ...[
                const SizedBox(height: 3),
                Text(sub, style: _t(14, FontWeight.w400, BrandColors.mut)),
              ],
            ],
          ),
        ),
        ...children,
      ],
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
    this.accent = PenColors.primary,
    this.tintValue = false,
    this.onTap,
  });
  final String value;
  final String label;

  /// Makes the card tappable — "Chờ tải" uses it to open the upload queue.
  final VoidCallback? onTap;

  /// The lucide glyph the design puts in the stat's tile.
  final IconData icon;

  /// Colour of the glyph and its tile wash. One hue per stat in the design:
  /// green for orders, light green for clips, amber for the upload backlog.
  final Color accent;

  /// Paints the number in [accent] too. The design only does this for "Chờ
  /// tải", where a non-zero count is something to act on.
  final bool tintValue;
}

/// An order row on HomeOrders.
class EcOrderRow {
  const EcOrderRow({
    required this.code,
    required this.time,
    required this.type,
    required this.videoCount,
    this.photoCount = 0,
    this.capturedAtMs,
    this.errorCount = 0,
    this.pendingCount = 0,
    this.thumbUrl,
  });

  /// Tracking code.
  final String code;

  /// Time label, e.g. "10:23".
  final String time;

  /// Video type label, e.g. "Đóng hàng đi".
  final String type;
  final int videoCount;

  /// Ảnh đính kèm còn sống trong đơn. Dòng chỉ vẽ số này khi nó > 0: máy chủ
  /// KHÔNG trả số ảnh trong danh sách đơn, nên với đơn chưa mở lần nào thì app
  /// không biết — in "0 ảnh" ở đó là nói sai chứ không phải nói thiếu.
  final int photoCount;

  /// Lần quay gần nhất (đơn chưa có clip thì lùi về lúc tạo đơn), epoch ms.
  /// Dùng cho nhãn ngày trên dòng — [time] chỉ có `HH:mm` nên không suy ra
  /// ngày được. KHÔNG phải trục chip thời gian lọc theo: chip lọc `created_at`,
  /// và việc đó do server làm.
  final int? capturedAtMs;
  final int errorCount;
  final int pendingCount;

  /// Ảnh overview của đơn: poster frame của clip mới nhất (hoặc chính tấm ảnh
  /// đính kèm). `null` khi chưa có clip nào lên xong — dòng rơi về glyph kiện
  /// hàng.
  final String? thumbUrl;
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
  const EcOrderFilters({
    this.uploadState,
    this.fromTs,
    this.toTs,
    this.videoTypeId,
  });

  /// `pending` | `error` | `done` — the backend's `upload_state` param.
  final String? uploadState;

  /// Epoch ms lower bound on the order's creation time (`from`).
  final int? fromTs;

  /// Epoch ms upper bound, inclusive (`to`). Null on the rolling windows
  /// ("today", "last 7 days"), which run up to now and need no ceiling — it is
  /// the closed ranges ("yesterday", a single picked date) that set it.
  final int? toTs;

  /// Restricts to orders holding at least one clip of this type.
  final String? videoTypeId;

  bool get isEmpty =>
      uploadState == null &&
      fromTs == null &&
      toTs == null &&
      videoTypeId == null;
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
    this.totalVideos = 0,
  });

  /// 1-based.
  final int page;
  final int total;
  final int pageSize;
  final int shown;

  /// Tổng video của mọi đơn khớp bộ lọc, không riêng trang này.
  final int totalVideos;

  int get pageCount => total <= 0 ? 1 : (total + pageSize - 1) ~/ pageSize;

  /// Số thứ tự đơn đầu/cuối trang này — nhãn "1–10 / 128".
  int get firstIndex => shown == 0 ? 0 : (page - 1) * pageSize + 1;
  int get lastIndex => shown == 0 ? 0 : firstIndex + shown - 1;

  /// Chỉ có một trang thì thanh phân trang là nhiễu, ẩn đi.
  bool get hasPages => pageCount > 1;
}

/// HomeOrders — the main "Vận đơn" tab: shop header, quick stats, a
/// tracking-code search box, the three filter chips, the order list and the
/// bottom tab bar (Vận đơn active).
class EcHomeOrdersScreen extends StatefulWidget {
  const EcHomeOrdersScreen({
    required this.shopName,
    required this.orders,
    this.stats = const [
      EcHomeStat(value: '0', label: 'Vận đơn'),
      EcHomeStat(
        value: '0',
        label: 'Video đã quay',
        icon: LucideIcons.video,
        accent: PenColors.success,
      ),
      EcHomeStat(
        value: '0',
        label: 'Chờ tải',
        icon: LucideIcons.cloudUpload,
        accent: PenColors.warning,
        tintValue: true,
      ),
    ],
    this.platform,
    this.videoTypes = const [],
    this.searchHint = 'Nhập mã vận đơn',
    this.emptyText = 'Shop chưa có đơn nào',
    this.onBack,
    this.onShopTap,
    this.onSettings,
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
    this.onNavClaims,
    super.key,
  });

  final String shopName;
  final List<EcOrderRow> orders;
  final List<EcHomeStat> stats;

  /// Marketplace của shop (`shopee`, `tiktok`, …) — badge góc ảnh mỗi dòng.
  /// Mọi đơn trên màn này đều thuộc một shop nên badge dùng chung.
  final String? platform;

  /// Options for the "Loại video" chip — the shop's video types. An empty list
  /// leaves the chip with only its "all types" entry.
  final List<EcVideoTypeOption> videoTypes;
  final String searchHint;

  /// Shown when the shop genuinely has no orders (distinct from a search that
  /// matched nothing).
  final String emptyText;
  final VoidCallback? onBack;

  /// Chạm vào tên shop trên header — mở Chi tiết cửa hàng.
  final VoidCallback? onShopTap;

  /// Bánh răng góc phải header — mở Quản lý cửa hàng.
  final VoidCallback? onSettings;

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

  /// Tab thứ ba: Hồ sơ khiếu nại.
  final VoidCallback? onNavClaims;

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

  /// The day chosen through the date picker. Kept alongside [_timeWindow]
  /// rather than encoded into it so re-opening the sheet can start the wheels
  /// on the day already in force.
  DateTime? _pickedDate;

  /// Sheet value for "one specific day", the only option whose bounds come
  /// from user input rather than the clock.
  static const _timeWindowDate = 'date';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Epoch-ms bounds for a window, as `(from, to)`.
  ///
  /// Bounds apply to the order's **creation** time — that is what the backend
  /// compares (`orderScope`), and the app follows it so the same chip means the
  /// same list here and on the web console.
  ///
  /// Day-shaped windows ("today", "yesterday", a picked date) snap to local
  /// midnight; the rolling ones stay relative to the current instant. Only the
  /// closed windows get a `to` — the rest run up to now.
  ///
  /// `to` is the last millisecond *inside* the day rather than the next
  /// midnight: the backend compares with `created_at <= ?` (see `orderScope`),
  /// so an exclusive bound would leak the following day's first order in.
  static (int?, int?) _boundsFor(String? window, DateTime? picked) {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    int ms(DateTime d) => d.millisecondsSinceEpoch;
    int endOfDay(DateTime d) => ms(DateTime(d.year, d.month, d.day + 1)) - 1;
    final yesterday = midnight.subtract(const Duration(days: 1));
    return switch (window) {
      'today' => (ms(midnight), null),
      'yesterday' => (ms(yesterday), endOfDay(yesterday)),
      '7d' => (ms(now.subtract(const Duration(days: 7))), null),
      '30d' => (ms(now.subtract(const Duration(days: 30))), null),
      _timeWindowDate when picked != null => (
        ms(DateTime(picked.year, picked.month, picked.day)),
        endOfDay(picked),
      ),
      _ => (null, null),
    };
  }

  EcOrderFilters get _filters {
    final (from, to) = _boundsFor(_timeWindow, _pickedDate);
    return EcOrderFilters(
      uploadState: _uploadState,
      fromTs: from,
      toTs: to,
      videoTypeId: _videoTypeId,
    );
  }

  List<_FilterOption> _statusOptions(AppLocalizations l10n) => [
    _FilterOption(null, l10n.filterStatusAll),
    _FilterOption('pending', l10n.filterStatusPending),
    _FilterOption('error', l10n.filterStatusError),
    _FilterOption('done', l10n.filterStatusDone),
  ];

  List<_FilterOption> _timeOptions(AppLocalizations l10n) => [
    _FilterOption(null, l10n.filterTimeAll),
    _FilterOption('today', l10n.filterTimeToday),
    _FilterOption('yesterday', l10n.filterTimeYesterday),
    _FilterOption('7d', l10n.filterTime7d),
    _FilterOption('30d', l10n.filterTime30d),
    // Once a day is in force the pill shows it instead of the generic prompt,
    // so the chip still reads as the filter actually applied.
    _FilterOption(
      _timeWindowDate,
      _pickedDate == null ? l10n.filterTimePickDate : _formatDay(_pickedDate!),
    ),
  ];

  /// `d/M/yyyy` — the shortest unambiguous form for a chip label.
  static String _formatDay(DateTime d) => '${d.day}/${d.month}/${d.year}';

  List<_FilterOption> _typeOptions(AppLocalizations l10n) => [
    _FilterOption(null, l10n.filterTypeAll),
    // Shop-authored names — data, not chrome, so they are never translated.
    for (final type in widget.videoTypes) _FilterOption(type.id, type.name),
  ];

  /// Orders as handed in, thu hẹp theo ô tìm kiếm.
  ///
  /// KHÔNG còn lọc theo ngày ở đây. Bản trước lọc tại chỗ theo ngày QUAY vì
  /// server lọc theo ngày TẠO đơn — hai trục khác nhau, nên cùng một chip
  /// "Hôm nay" cho ra hai danh sách khác nhau giữa app và web. Nay server lọc
  /// theo `from`/`to` như web, và lọc thêm một lần nữa ở đây sẽ giấu mất chính
  /// những đơn server vừa trả về đúng.
  ///
  /// Lọc theo mã thì vẫn giữ: `/api/shops/{id}/orders` bỏ qua tham số `q`, nên
  /// gõ một mã mà tin hẳn vào server thì vẫn ra toàn bộ đơn.
  List<EcOrderRow> get _visibleOrders {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.orders;
    return widget.orders
        .where((order) => order.code.toLowerCase().contains(query))
        .toList();
  }

  void _select(void Function(String?) apply, String? value) {
    setState(() => apply(value));
    _applyFilters();
  }

  /// Báo bộ lọc mới, rồi CHẠY LẠI tìm kiếm nếu ô tìm còn mã.
  ///
  /// Đổi bộ lọc làm phía app nạp lại trang đầu mà không kèm từ khoá, trong khi
  /// widget vẫn giữ mã để lọc tại chỗ — mã đó thường không nằm trong trang
  /// đầu nên danh sách ra rỗng. Người dùng vừa tra một đơn thì đổi khoảng thời
  /// gian là để xem chính đơn đó, không phải để mất nó; nên giữ mã và tra lại.
  void _applyFilters() {
    widget.onFiltersChanged?.call(_filters);
    final query = _query.trim();
    if (query.isNotEmpty) widget.onSearchChanged?.call(query);
  }

  /// Time is the one filter whose selection can need a second step: picking a
  /// specific day opens a date wheel, and backing out of that must leave the
  /// previous window untouched rather than half-applying an empty one.
  Future<void> _selectTime(String? value) async {
    if (value != _timeWindowDate) {
      _select((x) => _timeWindow = x, value);
      return;
    }
    final picked = await _pickDay(context, _pickedDate ?? DateTime.now());
    if (picked == null || !mounted) return;
    setState(() {
      _pickedDate = picked;
      _timeWindow = _timeWindowDate;
    });
    _applyFilters();
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
      child: Stack(
        children: [
          // Dải xanh chạy hết bề ngang, luồn cả sau thanh trạng thái; header
          // và ba thẻ số nằm đè lên nó.
          // Dải xanh phải lùi ĐÚNG BẰNG lượng nội dung lùi lên (28 -> 12), nếu
          // không thì mọi thứ trượt lên mà nền xanh đứng yên: nhìn ra là "không
          // đổi gì", và ô nhập mã vận đơn thụt vào trong vùng xanh.
          //
          // `PenBrandBanner` cao `safeArea.top + height`, nên con số này là
          // phần NẰM DƯỚI tai thỏ chứ không phải tổng chiều cao.
          const Align(
            alignment: Alignment.topCenter,
            child: PenBrandBanner(height: 150),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _ShopHeader(
                  shopName: widget.shopName,
                  onBack: widget.onBack,
                  onShopTap: widget.onShopTap,
                  onSettings: widget.onSettings,
                ),
                // Phần cố định: thống kê, ô tìm và hàng lọc không cuộn
                // theo danh sách. Hất danh sách lên mà bộ lọc trôi mất thì
                // muốn đổi trạng thái phải cuộn ngược lên đầu — với đơn dài
                // vài chục dòng đó là thao tác thừa mỗi lần lọc.
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
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
                      const SizedBox(height: 38),
                      // Khung F2-01 vẽ một ô duy nhất: icon kính lúp, ô nhập,
                      // vạch ngăn 1pt rồi nút quét 40x40 *bên trong* ô — không
                      // phải ô nhập cộng một nút vuông rời bên cạnh.
                      PenBox(
                        height: 56,
                        fill: PenColors.card,
                        stroke: PenColors.line,
                        radius: 14,
                        axis: PenAxis.row,
                        gap: 10,
                        cross: CrossAxisAlignment.center,
                        padding: const EdgeInsets.only(left: 16, right: 8),
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
                          const PenBox(
                            width: 1,
                            height: 26,
                            fill: PenColors.line,
                          ),
                          EcTap(
                            onTap: widget.onScan == null ? null : _onScan,
                            child: const PenBox(
                              width: 40,
                              height: 40,
                              fill: PenColors.bg,
                              radius: 12,
                              axis: PenAxis.row,
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.scanBarcode,
                                  size: 22,
                                  color: PenColors.ink,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                              onSelected: _selectTime,
                            ),
                            const SizedBox(width: 10),
                            _FilterChip(
                              name: l10n.filterTypeLabel,
                              options: _typeOptions(l10n),
                              selected: _videoTypeId,
                              onSelected: (v) =>
                                  _select((x) => _videoTypeId = x, v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator.adaptive(
                    onRefresh: widget.onRefresh ?? () async {},
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
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
                              // Design: padding [6,12]. PenBox vẽ viền đè lên mép
                              // nên padding đo từ mép ngoài, không cộng thêm 1pt.
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12,
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
                                    platform: widget.platform,
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
                  onClaims: widget.onNavClaims,
                ),
              ],
            ),
          ),
          if (widget.onBack != null) _BackSwipeEdge(onBack: widget.onBack!),
        ],
      ),
    );
  }
}

/// Dải mép trái nhận thao tác vuốt-để-quay-lại.
///
/// Màn vận đơn là một tab gốc chứ không phải trang được push, nên iOS không tự
/// cho vuốt về — trong khi ngón tay người dùng thì vẫn quen làm thế. Dải này
/// dựng lại đúng thao tác đó và gọi cùng một [onBack] với nút trên header.
///
/// Chỉ rộng 20 như `_kBackGestureWidth` của Cupertino: rộng hơn là nuốt luôn
/// thao tác kéo ngang hàng viên lọc nằm ngay bên dưới.
class _BackSwipeEdge extends StatefulWidget {
  const _BackSwipeEdge({required this.onBack});

  final VoidCallback onBack;

  static const _width = 20.0;

  @override
  State<_BackSwipeEdge> createState() => _BackSwipeEdgeState();
}

class _BackSwipeEdgeState extends State<_BackSwipeEdge> {
  double _dragged = 0;

  @override
  Widget build(BuildContext context) => Positioned(
    left: 0,
    top: 0,
    bottom: 0,
    width: _BackSwipeEdge._width,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => _dragged = 0,
      onHorizontalDragUpdate: (d) => _dragged += d.delta.dx,
      // Nhận cả hai kiểu: hất nhanh, hoặc kéo chậm đủ xa. Chỉ xét vận tốc thì
      // cú kéo từ tốn có vận tốc gần 0 lúc nhả tay và bị bỏ qua.
      onHorizontalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) > 300 || _dragged > 60) widget.onBack();
      },
    ),
  );
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
    final card = PenBox(
      fill: PenColors.card,
      stroke: PenColors.line,
      radius: 16,
      // Thẻ đè lên dải xanh nên đổ bóng ám xanh, không phải bóng mực.
      shadows: const [penBrandCardShadow],
      axis: PenAxis.column,
      gap: 8,
      // Khung F2-01 canh giữa cả hàng icon+số lẫn nhãn trong thẻ.
      cross: CrossAxisAlignment.center,
      hugMain: true,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      children: [
        // Ba thẻ chia đều bề ngang, nên ô hẹp lại theo máy và theo độ dài nhãn
        // (bản tiếng Anh dài hơn tiếng Việt). Số và nhãn co lại vừa ô thay vì
        // tràn/cắt cụt như trước.
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PenBox(
              width: 36,
              height: 36,
              // Wash of the stat's own hue at 10% — the design's `1A` alpha.
              fill: stat.accent.withValues(alpha: 0.1),
              radius: 11,
              axis: PenAxis.row,
              main: MainAxisAlignment.center,
              cross: CrossAxisAlignment.center,
              children: [Icon(stat.icon, size: 19, color: stat.accent)],
            ),
            const SizedBox(width: 10),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: PenText(
                  stat.value,
                  size: 24,
                  color: stat.tintValue ? stat.accent : PenColors.ink,
                  weight: FontWeight.w800,
                  softWrap: false,
                ),
              ),
            ),
          ],
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: PenText(
            stat.label,
            size: 12,
            color: PenColors.mut,
            softWrap: false,
          ),
        ),
      ],
    );
    return stat.onTap == null ? card : EcTap(onTap: stat.onTap, child: card);
  }
}

/// Asks for a single day on a Cupertino date wheel, returning null if the
/// seller backs out.
///
/// Cupertino has no range picker and the orders list is queried a day at a
/// time, so this deliberately stays single-date: the presets above it already
/// cover every multi-day span the shop actually filters by.
///
/// The wheel writes to a local instead of popping straight from
/// `onDateTimeChanged` — that callback fires on every scroll tick, so
/// committing there would re-query for each day the wheel spins past.
Future<DateTime?> _pickDay(BuildContext context, DateTime initial) {
  final l10n = context.l10n;
  var draft = initial;
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (sheetContext) => Align(
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        // Bo hai góc trên như mọi sheet khác; đáy chừa chỗ cho home indicator.
        decoration: const BoxDecoration(
          color: PenColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(
                        l10n.commonCancel,
                        style: _t(16, FontWeight.w500, BrandColors.ink),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.of(sheetContext).pop(draft),
                      child: Text(
                        l10n.commonDone,
                        style: _t(16, FontWeight.w600, BrandColors.dark),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initial,
                    // Orders only exist in the past; letting the wheel run
                    // forward would just offer days that always come back
                    // empty.
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (value) => draft = value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// A filter pill that opens an action sheet of [options]. [name] is the
/// filter's dimension ("Thời gian"): the pill shows it alone while the filter
/// is off and prefixes the chosen value with it once applied ("Thời gian: Hôm
/// nay"), so a row of pills reads as the dimensions you can narrow by rather
/// than three interchangeable flavours of "all".
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
        label: _isActive ? '$name: ${_current.label}' : name,
        // An active filter is narrowing the list — the design marks that with
        // the ink fill and a white label, never a brand tint.
        selected: _isActive,
        trailing: LucideIcons.chevronDown,
        onTap: () => _pick(context),
      ),
    );
  }
}

/// `dd/MM/yyyy` cho dòng phụ của hàng đơn; `null` khi đơn chưa có mốc thời
/// gian nào, để chỗ gọi bỏ hẳn phần ngày thay vì in một chỗ trống.
String? _dayLabel(int? epochMs) {
  if (epochMs == null) return null;
  final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.order,
    this.platform,
    this.onTap,
  });
  final EcOrderRow order;
  final String? platform;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final failed = order.errorCount > 0;
    return EcTap(
      onTap: onTap,
      child: PenBox(
        width: double.infinity,
        axis: PenAxis.row,
        gap: 12,
        cross: CrossAxisAlignment.center,
        padding: const EdgeInsets.symmetric(vertical: 13),
        children: [
          PenOrderThumb(imageUrl: order.thumbUrl, platform: platform),
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
                  // Ngày đứng TRƯỚC giờ và loại: danh sách trải dài nhiều
                  // ngày, mà chỉ có `10:23` thì không biết của hôm nào —
                  // người tra đơn khiếu nại cần ngày hơn cần phút.
                  [
                    ?_dayLabel(order.capturedAtMs),
                    order.time,
                    order.type,
                  ].join(' · '),
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
              axis: PenAxis.row,
              gap: 6,
              cross: CrossAxisAlignment.center,
              hugMain: true,
              children: [
                const Icon(
                  LucideIcons.circleAlert,
                  size: 19,
                  color: PenColors.danger,
                ),
                PenText(
                  context.l10n.orderErrorCount(order.errorCount),
                  size: 14,
                  color: PenColors.danger,
                  weight: FontWeight.w600,
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
                  color: PenColors.primary,
                ),
                PenText(
                  '${order.videoCount}',
                  size: 16,
                  color: PenColors.primary,
                  weight: FontWeight.w700,
                  softWrap: false,
                ),
                if (order.photoCount > 0) ...[
                  const Icon(
                    LucideIcons.image,
                    size: 19,
                    color: PenColors.primary,
                  ),
                  PenText(
                    '${order.photoCount}',
                    size: 16,
                    color: PenColors.primary,
                    weight: FontWeight.w700,
                    softWrap: false,
                  ),
                ],
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

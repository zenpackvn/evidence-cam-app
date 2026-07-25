/// EvidenceCam Flow 4 (Tài khoản cá nhân) screens, built pixel-perfect from
/// `specs/projects/evidencecam/design-spec/pencil-new.pen`.
///
/// These are presentational (data-in, callbacks-out) so they can be verified
/// in isolation now and wired to auth/router as those land. Every dimension,
/// gap, font size/weight and color is taken directly from the design file.
library;

import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoPageScaffold, CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// Shared text style (Inter is inherited from AppTheme's textTheme).
TextStyle _t(double size, FontWeight weight, Color color) =>
    TextStyle(fontSize: size, fontWeight: weight, color: color, height: 1.3);

/// AccountTab — shop header w/ upload queue chip, profile row, two settings
/// groups (Gói & ứng dụng / Bảo mật & đăng nhập) and the 3-tab bottom nav.
class EcAccountTabScreen extends StatelessWidget {
  const EcAccountTabScreen({
    this.userName = 'Nguyễn Văn A',
    this.userEmail = 'nguyenvana@gmail.com',
    this.shopName = 'Shop ABC',
    this.queueCount = 3,
    this.planLabel = 'Pro 500',
    this.languageLabel = 'Tiếng Việt',
    this.loginMethodsLabel = '3 liên kết',
    this.onBack,
    this.onProfileTap,
    this.onQuotaTap,
    this.onLanguageTap,
    this.onChangePasswordTap,
    this.onLoginMethodsTap,
    this.onLogout,
    this.onDeleteAccount,
    this.onNavOrders,
    this.onNavCapture,
    super.key,
  });

  final String userName;
  final String userEmail;
  final String shopName;
  final int queueCount;
  final String planLabel;
  final String languageLabel;
  final String loginMethodsLabel;
  final VoidCallback? onBack;
  final VoidCallback? onProfileTap;
  final VoidCallback? onQuotaTap;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onChangePasswordTap;
  final VoidCallback? onLoginMethodsTap;
  final VoidCallback? onLogout;
  final VoidCallback? onDeleteAccount;
  final VoidCallback? onNavOrders;
  final VoidCallback? onNavCapture;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            _ShopHeader(
              shopName: shopName,
              queueCount: queueCount,
              onBack: onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _UserRow(
                      name: userName,
                      email: userEmail,
                      onTap: onProfileTap,
                    ),
                    const _SectionHeader('GÓI & ỨNG DỤNG'),
                    _SettingsRow(
                      icon: Icons.credit_card_outlined,
                      label: 'Gói cước & Quota',
                      value: planLabel,
                      onTap: onQuotaTap,
                    ),
                    _SettingsRow(
                      icon: Icons.language,
                      label: 'Ngôn ngữ',
                      value: languageLabel,
                      onTap: onLanguageTap,
                    ),
                    const _SectionHeader('BẢO MẬT & ĐĂNG NHẬP'),
                    _SettingsRow(
                      icon: Icons.lock_outline,
                      label: 'Đổi mật khẩu',
                      onTap: onChangePasswordTap,
                    ),
                    _SettingsRow(
                      icon: Icons.vpn_key_outlined,
                      label: 'Phương thức đăng nhập',
                      value: loginMethodsLabel,
                      onTap: onLoginMethodsTap,
                    ),
                    _SettingsRow(
                      icon: Icons.logout,
                      label: 'Đăng xuất',
                      onTap: onLogout,
                    ),
                    _SettingsRow(
                      icon: Icons.delete_outline,
                      label: 'Xóa tài khoản',
                      onTap: onDeleteAccount,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Quản lý shop/thành viên: bấm back trên header '
                        'để về lớp Shop',
                        style: _t(11, FontWeight.w400, BrandColors.mut),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomNav(
              active: _NavTab.account,
              onOrders: onNavOrders,
              onCapture: onNavCapture,
            ),
          ],
        ),
      ),
    );
  }
}

/// EditProfile — avatar picker, editable name/phone, locked email, save.
class EcEditProfileScreen extends StatelessWidget {
  const EcEditProfileScreen({
    this.nameController,
    this.phoneController,
    this.email = 'nguyenvana@gmail.com',
    this.avatarPath,
    this.onBack,
    this.onChangeAvatar,
    this.onSave,
    super.key,
  });

  final TextEditingController? nameController;
  final TextEditingController? phoneController;
  final String email;

  /// Local file path of a just-picked avatar; shows a placeholder when null.
  final String? avatarPath;
  final VoidCallback? onBack;
  final VoidCallback? onChangeAvatar;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: CupertinoPageScaffold(
        backgroundColor: BrandColors.bg,
        child: SafeArea(
          child: Column(
            children: [
              _SimpleHeader(title: 'Thông tin tài khoản', onBack: onBack),
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
                            Center(
                              child: _AvatarPicker(
                                avatarPath: avatarPath,
                                onChangeAvatar: onChangeAvatar,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _Field(
                              label: 'Họ tên',
                              hint: 'Nhập họ tên',
                              controller: nameController,
                              validator: FormBuilderValidators.required(
                                errorText: 'Vui lòng nhập họ tên',
                              ),
                            ),
                            const SizedBox(height: 14),
                            _Field(
                              label: 'Số điện thoại',
                              hint: 'Nhập số điện thoại',
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              // Phone is optional here, but must be well-formed
                              // when provided.
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? null
                                  : FormBuilderValidators.phoneNumber(
                                      errorText: 'Số điện thoại không hợp lệ',
                                    )(value),
                            ),
                            const SizedBox(height: 14),
                            _LockedField(label: 'Email', value: email),
                            const Spacer(),
                            const SizedBox(height: 14),
                            _ValidatedPrimaryButton(
                              label: 'Lưu thay đổi',
                              onValid: onSave,
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

/// Forced phone capture shown right after an Apple/Google sign-in when the
/// account has no phone (those providers don't supply one). No back action —
/// the user must enter a number to continue. Presentational: data-in,
/// callbacks-out.
class EcPhoneSetupScreen extends StatelessWidget {
  const EcPhoneSetupScreen({this.phoneController, this.onContinue, super.key});

  final TextEditingController? phoneController;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: PopScope(
        canPop: false,
        child: CupertinoPageScaffold(
          backgroundColor: BrandColors.bg,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Thêm số điện thoại',
                    style: _t(22, FontWeight.w700, BrandColors.ink),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tài khoản đăng nhập bằng Apple/Google chưa có số điện thoại. '
                    'Vui lòng nhập số điện thoại để tiếp tục.',
                    style: _t(14, FontWeight.w400, BrandColors.mut),
                  ),
                  const SizedBox(height: 24),
                  _Field(
                    label: 'Số điện thoại',
                    hint: 'Nhập số điện thoại',
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Vui lòng nhập số điện thoại',
                      ),
                      FormBuilderValidators.phoneNumber(
                        errorText: 'Số điện thoại không hợp lệ',
                      ),
                    ]),
                  ),
                  const Spacer(),
                  _ValidatedPrimaryButton(
                    label: 'Tiếp tục',
                    onValid: onContinue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Selectable interface language.
enum EcAppLanguage {
  /// Tiếng Việt (default).
  vi,

  /// English.
  en,
}

/// Language — VI/English picker with radio-style selected rows.
class EcLanguageScreen extends StatelessWidget {
  const EcLanguageScreen({
    this.selected = EcAppLanguage.vi,
    this.onBack,
    this.onSelect,
    super.key,
  });

  final EcAppLanguage selected;
  final VoidCallback? onBack;
  final ValueChanged<EcAppLanguage>? onSelect;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            _SimpleHeader(title: 'Ngôn ngữ', onBack: onBack),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LanguageOption(
                      title: 'Tiếng Việt',
                      subtitle: 'Vietnamese',
                      selected: selected == EcAppLanguage.vi,
                      onTap: () => onSelect?.call(EcAppLanguage.vi),
                    ),
                    const SizedBox(height: 10),
                    _LanguageOption(
                      title: 'English',
                      subtitle: 'Tiếng Anh',
                      selected: selected == EcAppLanguage.en,
                      onTap: () => onSelect?.call(EcAppLanguage.en),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Thay đổi áp dụng ngay trên toàn bộ app',
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

/// LoginMethods — lists linked sign-in methods (email identity + Google/Apple)
/// with link/unlink actions. Fills the "Phương thức đăng nhập ›" control.
class EcLoginMethodsScreen extends StatelessWidget {
  const EcLoginMethodsScreen({
    this.email = 'nguyenvana@gmail.com',
    this.googleLinked = true,
    this.appleLinked = false,
    this.onBack,
    this.onToggleGoogle,
    this.onToggleApple,
    super.key,
  });

  final String email;
  final bool googleLinked;
  final bool appleLinked;
  final VoidCallback? onBack;
  final VoidCallback? onToggleGoogle;
  final VoidCallback? onToggleApple;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            _SimpleHeader(title: 'Phương thức đăng nhập', onBack: onBack),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LoginMethodRow(
                      icon: Icons.mail_outline,
                      name: 'Email',
                      detail: email,
                      linked: true,
                      isIdentity: true,
                    ),
                    const SizedBox(height: 10),
                    _LoginMethodRow(
                      icon: Icons.g_mobiledata,
                      name: 'Google',
                      detail: googleLinked ? 'Đã liên kết' : 'Chưa liên kết',
                      linked: googleLinked,
                      onToggle: onToggleGoogle,
                    ),
                    const SizedBox(height: 10),
                    _LoginMethodRow(
                      icon: Icons.apple,
                      name: 'Apple',
                      detail: appleLinked ? 'Đã liên kết' : 'Chưa liên kết',
                      linked: appleLinked,
                      onToggle: onToggleApple,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Email là định danh tài khoản — không thể gỡ. Liên kết '
                        'Google/Apple để đăng nhập nhanh cùng một tài khoản.',
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
    );
  }
}

class _LoginMethodRow extends StatelessWidget {
  const _LoginMethodRow({
    required this.icon,
    required this.name,
    required this.detail,
    required this.linked,
    this.isIdentity = false,
    this.onToggle,
  });
  final IconData icon;
  final String name;
  final String detail;
  final bool linked;
  final bool isIdentity;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: BrandColors.ink),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: _t(16, FontWeight.w600, BrandColors.ink)),
                const SizedBox(height: 2),
                Text(detail, style: _t(13, FontWeight.w400, BrandColors.mut)),
              ],
            ),
          ),
          if (isIdentity)
            Text('Định danh', style: _t(13, FontWeight.w500, BrandColors.mut))
          else
            EcTap(
              onTap: onToggle,
              child: Text(
                linked ? 'Hủy liên kết' : 'Liên kết',
                style: _t(
                  14,
                  FontWeight.w600,
                  linked ? BrandColors.rec : BrandColors.dark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Quota — current plan, monthly video quota w/ progress bar, retention,
/// and an upgrade CTA.
class EcQuotaScreen extends StatelessWidget {
  const EcQuotaScreen({
    this.planLabel = 'Pro 500 (P1)',
    this.usedVideos = 263,
    this.totalVideos = 500,
    this.retentionUsedDays = 45,
    this.retentionTotalDays = 90,
    this.onBack,
    this.onUpgrade,
    super.key,
  });

  final String planLabel;
  final int usedVideos;
  final int totalVideos;
  final int retentionUsedDays;
  final int retentionTotalDays;
  final VoidCallback? onBack;
  final VoidCallback? onUpgrade;

  int get _usedPercent {
    if (totalVideos <= 0) return 0;
    final pct = (usedVideos / totalVideos * 100).floor();
    if (pct < 0) return 0;
    if (pct > 100) return 100;
    return pct;
  }

  double get _usedFraction => _usedPercent / 100;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            _SimpleHeader(title: 'Báo cáo & Quota', onBack: onBack),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _InfoCard(
                            children: [
                              Text(
                                'Gói hiện tại',
                                style: _t(12, FontWeight.w400, BrandColors.mut),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                planLabel,
                                style: _t(20, FontWeight.w700, BrandColors.ink),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _InfoCard(
                            children: [
                              Text(
                                'Còn lại trong tháng',
                                style: _t(12, FontWeight.w400, BrandColors.mut),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$usedVideos / $totalVideos video',
                                style: _t(20, FontWeight.w700, BrandColors.ink),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                height: 8,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2E2E2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: _usedFraction,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: BrandColors.dark,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Đã dùng $_usedPercent%',
                                style: _t(11, FontWeight.w400, BrandColors.mut),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _InfoCard(
                            row: true,
                            children: [
                              Text(
                                'Lưu trữ',
                                style: _t(14, FontWeight.w400, BrandColors.ink),
                              ),
                              const Spacer(),
                              Text(
                                '$retentionUsedDays / $retentionTotalDays '
                                'ngày',
                                style: _t(14, FontWeight.w600, BrandColors.ink),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const SizedBox(height: 14),
                          _EcPrimaryButton(
                            label: 'Nâng cấp gói',
                            onPressed: onUpgrade,
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
    );
  }
}

/// Centered dialog chrome with tap-outside-to-dismiss (matches flow-1's
/// dialogs). [onDismiss] fires when the area outside the card is tapped.
class _DialogFrame extends StatelessWidget {
  const _DialogFrame({required this.children, this.onDismiss});
  final List<Widget> children;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss ?? () => Navigator.of(context).maybePop(),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
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
                      children: children,
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

/// DeleteAccount — two-step confirm dialog with a pending-shares warning.
///
/// Step 1 shows the destructive-action warning; confirming advances to step
/// 2 (final confirmation) before [onConfirmDelete] fires. This mirrors the
/// design note "Bước 1/2 — sẽ yêu cầu xác nhận lại".
class EcDeleteAccountScreen extends StatefulWidget {
  const EcDeleteAccountScreen({
    this.pendingSharedProfilesCount = 2,
    this.onCancel,
    this.onConfirmDelete,
    super.key,
  });

  final int pendingSharedProfilesCount;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirmDelete;

  @override
  State<EcDeleteAccountScreen> createState() => _EcDeleteAccountScreenState();
}

class _EcDeleteAccountScreenState extends State<EcDeleteAccountScreen> {
  var _isFirstStep = true;

  void _handlePrimary() {
    if (_isFirstStep) {
      setState(() => _isFirstStep = false);
    } else {
      widget.onConfirmDelete?.call();
    }
  }

  void _handleCancel() {
    if (_isFirstStep) {
      widget.onCancel?.call();
    } else {
      setState(() => _isFirstStep = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFirstStep = _isFirstStep;
    return _DialogFrame(
      onDismiss: _handleCancel,
      children: [
        Text(
          isFirstStep ? 'Xóa tài khoản?' : 'Xác nhận xóa vĩnh viễn?',
          style: _t(16, FontWeight.w700, BrandColors.ink),
        ),
        const SizedBox(height: 12),
        Text(
          isFirstStep
              ? 'Toàn bộ video, đơn hàng và hồ sơ của bạn sẽ bị '
                    'xóa vĩnh viễn. Hành động này không thể hoàn '
                    'tác.'
              : 'Đây là bước xác nhận cuối cùng. Sau khi xóa, '
                    'bạn sẽ được đăng xuất khỏi ứng dụng ngay '
                    'lập tức.',
          style: _t(13, FontWeight.w400, BrandColors.mut),
        ),
        if (isFirstStep && widget.pendingSharedProfilesCount > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BrandColors.soft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: BrandColors.ink,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bạn còn ${widget.pendingSharedProfilesCount} '
                    'hồ sơ "đã gửi sàn" — link chia sẻ sẽ ngừng '
                    'hoạt động',
                    style: _t(12, FontWeight.w400, BrandColors.ink),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _EcSecondaryButton(
                label: 'Hủy',
                onPressed: _handleCancel,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EcPrimaryButton(
                label: 'Xóa vĩnh viễn',
                fontSize: 14,
                onPressed: _handlePrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            isFirstStep
                ? 'Bước 1/2 — sẽ yêu cầu xác nhận lại · xong đăng '
                      'xuất ngay'
                : 'Bước 2/2 — hành động này không thể hoàn tác',
            textAlign: TextAlign.center,
            style: _t(11, FontWeight.w400, BrandColors.mut),
          ),
        ),
      ],
    );
  }
}

/// ChangePassword — current/new/confirm password dialog. Set
/// [hasExistingPassword] to `false` for the "Tạo mật khẩu" variant (no
/// current-password field), used by accounts without a password yet.
class EcChangePasswordScreen extends StatelessWidget {
  const EcChangePasswordScreen({
    this.hasExistingPassword = true,
    this.currentPasswordController,
    this.newPasswordController,
    this.confirmPasswordController,
    this.onCancel,
    this.onSave,
    super.key,
  });

  final bool hasExistingPassword;
  final TextEditingController? currentPasswordController;
  final TextEditingController? newPasswordController;
  final TextEditingController? confirmPasswordController;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: _DialogFrame(
        onDismiss: onCancel,
        children: [
          Text(
            hasExistingPassword ? 'Đổi mật khẩu' : 'Tạo mật khẩu',
            style: _t(16, FontWeight.w700, BrandColors.ink),
          ),
          const SizedBox(height: 12),
          if (hasExistingPassword) ...[
            _PasswordField(
              label: 'Mật khẩu hiện tại',
              hint: '••••••••',
              controller: currentPasswordController,
              validator: FormBuilderValidators.required(
                errorText: 'Vui lòng nhập mật khẩu hiện tại',
              ),
            ),
            const SizedBox(height: 12),
          ],
          _PasswordField(
            label: 'Mật khẩu mới',
            hint: 'Tối thiểu 8 ký tự',
            controller: newPasswordController,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'Vui lòng nhập mật khẩu mới',
              ),
              FormBuilderValidators.minLength(
                8,
                errorText: 'Mật khẩu tối thiểu 8 ký tự',
              ),
            ]),
          ),
          const SizedBox(height: 12),
          _PasswordField(
            label: 'Nhập lại mật khẩu mới',
            hint: '••••••••',
            controller: confirmPasswordController,
            validator: (value) => value == newPasswordController?.text
                ? null
                : 'Mật khẩu nhập lại không khớp',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _EcSecondaryButton(
                  label: 'Hủy',
                  onPressed: onCancel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ValidatedPrimaryButton(
                  label: hasExistingPassword ? 'Lưu mật khẩu' : 'Tạo mật khẩu',
                  onValid: onSave,
                ),
              ),
            ],
          ),
          if (hasExistingPassword) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                '(Đổi xong sẽ đăng xuất khỏi các thiết bị khác)',
                textAlign: TextAlign.center,
                style: _t(11, FontWeight.w400, BrandColors.mut),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// --- shared pieces (pixel specs from pencil-new.pen) ---

class _EcPrimaryButton extends StatelessWidget {
  const _EcPrimaryButton({
    required this.label,
    this.onPressed,
    this.fontSize = 16,
  });

  final String label;
  final VoidCallback? onPressed;
  final double fontSize;

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
        child: Text(label, style: _t(fontSize, FontWeight.w600, Colors.white)),
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

class _EcSecondaryButton extends StatelessWidget {
  const _EcSecondaryButton({required this.label, this.onPressed});

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

class _ShopHeader extends StatelessWidget {
  const _ShopHeader({
    required this.shopName,
    required this.queueCount,
    this.onBack,
  });

  final String shopName;
  final int queueCount;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: BrandColors.ink,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              shopName,
              overflow: TextOverflow.ellipsis,
              style: _t(15, FontWeight.w600, BrandColors.ink),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BrandColors.soft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_outlined,
                  size: 14,
                  color: BrandColors.ink,
                ),
                const SizedBox(width: 4),
                Text(
                  '$queueCount',
                  style: _t(12, FontWeight.w600, BrandColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: BrandColors.ink,
            ),
          ),
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

class _UserRow extends StatelessWidget {
  const _UserRow({required this.name, required this.email, this.onTap});

  final String name;
  final String email;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: DecoratedBox(
        decoration: const BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: BrandColors.soft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 28,
                  color: BrandColors.mut,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: _t(18, FontWeight.w600, BrandColors.ink)),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: _t(14, FontWeight.w400, BrandColors.mut),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: BrandColors.mut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(label, style: _t(13, FontWeight.w600, BrandColors.mut)),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: BrandColors.line)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, size: 22, color: BrandColors.ink),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: _t(16, FontWeight.w400, BrandColors.ink),
                ),
              ),
              if (value != null) ...[
                Text(value!, style: _t(14, FontWeight.w400, BrandColors.mut)),
                const SizedBox(width: 6),
              ],
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: BrandColors.mut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _NavTab { orders, capture, account }

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.active, this.onOrders, this.onCapture});

  final _NavTab active;
  final VoidCallback? onOrders;
  final VoidCallback? onCapture;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: const BoxDecoration(
        color: BrandColors.bg,
        border: Border(top: BorderSide(color: BrandColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              icon: Icons.inventory_2_outlined,
              label: 'Đơn hàng',
              active: active == _NavTab.orders,
              onTap: onOrders,
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.camera_alt_outlined,
              label: 'Ghi hình',
              active: active == _NavTab.capture,
              onTap: onCapture,
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.person_outline,
              label: 'Tài khoản',
              active: active == _NavTab.account,
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

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({this.avatarPath, this.onChangeAvatar});

  final String? avatarPath;
  final VoidCallback? onChangeAvatar;

  @override
  Widget build(BuildContext context) {
    final path = avatarPath;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: BrandColors.soft,
                  shape: BoxShape.circle,
                  border: Border.all(color: BrandColors.line),
                ),
                child: path == null
                    ? const Icon(
                        Icons.person_outline,
                        size: 40,
                        color: BrandColors.mut,
                      )
                    : Image.file(File(path), fit: BoxFit.cover),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: EcTap(
                  onTap: onChangeAvatar,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: BrandColors.dark,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        EcTap(
          onTap: onChangeAvatar,
          child: Text(
            'Đổi ảnh đại diện',
            style: _t(12, FontWeight.w500, BrandColors.ink),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  /// When set, the field registers with the enclosing [Form] and shows an
  /// inline error beneath itself; null keeps the plain (unvalidated) field.
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    if (validator == null) return _decorated(null);
    return FormField<String>(
      initialValue: controller?.text ?? '',
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: _decorated,
    );
  }

  Widget _decorated(FormFieldState<String>? state) {
    final error = state?.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: _t(14, FontWeight.w500, BrandColors.ink)),
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
            controller: controller,
            onChanged: state?.didChange,
            keyboardType: keyboardType,
            style: _t(15, FontWeight.w400, BrandColors.ink),
            placeholder: hint,
            placeholderStyle: _t(15, FontWeight.w400, BrandColors.mut),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: const BoxDecoration(),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(error, style: _t(12, FontWeight.w400, BrandColors.rec)),
        ],
      ],
    );
  }
}

class _LockedField extends StatelessWidget {
  const _LockedField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: _t(14, FontWeight.w500, BrandColors.ink)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: BrandColors.soft,
            border: Border.all(color: BrandColors.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: _t(15, FontWeight.w400, BrandColors.mut),
                ),
              ),
              const Icon(Icons.lock_outline, size: 14, color: BrandColors.mut),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    this.onTap,
  });

  final String title;
  final String subtitle;
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
            color: selected ? BrandColors.ink : BrandColors.line,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: _t(15, FontWeight.w600, BrandColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: _t(12, FontWeight.w400, BrandColors.mut),
                    ),
                  ],
                ),
              ),
              if (selected)
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: BrandColors.dark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 13, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children, this.row = false});

  final List<Widget> children;
  final bool row;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ecSquircleDecoration(
        radius: 14,
        side: const BorderSide(color: BrandColors.line),
      ),
      child: row
          ? Row(children: children)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.hint,
    this.controller,
    this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;

  /// When set, the field registers with the enclosing [Form] and shows an
  /// inline error beneath itself; null keeps the plain (unvalidated) field.
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    if (validator == null) return _decorated(null);
    return FormField<String>(
      initialValue: controller?.text ?? '',
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: _decorated,
    );
  }

  Widget _decorated(FormFieldState<String>? state) {
    final error = state?.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: _t(14, FontWeight.w500, BrandColors.ink)),
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
            controller: controller,
            onChanged: state?.didChange,
            obscureText: true,
            style: _t(15, FontWeight.w400, BrandColors.ink),
            placeholder: hint,
            placeholderStyle: _t(15, FontWeight.w400, BrandColors.mut),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: const BoxDecoration(),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(error, style: _t(12, FontWeight.w400, BrandColors.rec)),
        ],
      ],
    );
  }
}

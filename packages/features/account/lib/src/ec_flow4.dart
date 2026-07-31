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
import 'package:localization/localization.dart';
import 'package:shared_contracts/shared_contracts.dart';

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
    this.passwordActionLabel = 'Đổi mật khẩu',
    this.avatarPath,
    this.onBack,
    this.onProfileTap,
    this.onQuotaTap,
    this.onLanguageTap,
    this.onStopCodeTap,
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
  final String passwordActionLabel;
  final String? avatarPath;
  final VoidCallback? onBack;
  final VoidCallback? onProfileTap;
  final VoidCallback? onQuotaTap;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onStopCodeTap;
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
                      avatarPath: avatarPath,
                      onTap: onProfileTap,
                    ),
                    _SectionHeader(context.l10n.accountSectionApp),
                    _SettingsRow(
                      icon: Icons.credit_card_outlined,
                      label: context.l10n.accountPlanQuota,
                      value: planLabel,
                      onTap: onQuotaTap,
                    ),
                    _SettingsRow(
                      icon: Icons.language,
                      label: context.l10n.accountLanguage,
                      value: languageLabel,
                      onTap: onLanguageTap,
                    ),
                    _SettingsRow(
                      icon: Icons.qr_code_2,
                      label: context.l10n.stopCodeTitle,
                      onTap: onStopCodeTap,
                    ),
                    _SectionHeader(context.l10n.accountSectionSecurity),
                    _SettingsRow(
                      icon: Icons.lock_outline,
                      label: passwordActionLabel,
                      onTap: onChangePasswordTap,
                    ),
                    _SettingsRow(
                      icon: Icons.vpn_key_outlined,
                      label: context.l10n.accountLoginMethods,
                      value: loginMethodsLabel,
                      onTap: onLoginMethodsTap,
                    ),
                    _SettingsRow(
                      icon: Icons.logout,
                      label: context.l10n.accountSignOut,
                      onTap: onLogout,
                    ),
                    _SettingsRow(
                      icon: Icons.delete_outline,
                      label: context.l10n.accountDeleteAccount,
                      onTap: onDeleteAccount,
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
              _SimpleHeader(
                title: context.l10n.accountInfoTitle,
                onBack: onBack,
              ),
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
                              label: context.l10n.accountFullName,
                              hint: context.l10n.accountFullNameHint,
                              controller: nameController,
                              validator: FormBuilderValidators.required(
                                errorText: context.l10n.accountFullNameRequired,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _Field(
                              label: context.l10n.phoneLabel,
                              hint: context.l10n.phoneHint,
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              // Phone is optional here, but must be well-formed
                              // when provided.
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? null
                                  : FormBuilderValidators.phoneNumber(
                                      errorText: context.l10n.phoneInvalid,
                                    )(value),
                            ),
                            const SizedBox(height: 14),
                            _LockedField(
                              label: 'Email',
                              value: email,
                              hint: context.l10n.accountEmailLockedHint,
                            ),
                            const Spacer(),
                            const SizedBox(height: 14),
                            _ValidatedPrimaryButton(
                              label: context.l10n.accountSaveChanges,
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
                    context.l10n.phoneAddTitle,
                    style: _t(24, FontWeight.w600, BrandColors.ink),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.phoneAddBody,
                    style: _t(14, FontWeight.w400, BrandColors.mut),
                  ),
                  const SizedBox(height: 24),
                  _Field(
                    label: context.l10n.phoneLabel,
                    hint: context.l10n.phoneHint,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: context.l10n.phoneRequired,
                      ),
                      FormBuilderValidators.phoneNumber(
                        errorText: context.l10n.phoneInvalid,
                      ),
                    ]),
                  ),
                  const Spacer(),
                  _ValidatedPrimaryButton(
                    label: context.l10n.commonContinue,
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
    final l10n = context.l10n;
    return PenScreen(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SimpleHeader(title: l10n.accountLanguage, onBack: onBack),
            const SizedBox(height: 22),
            _LanguageOption(
              title: 'Tiếng Việt',
              subtitle: l10n.languageNameVietnamese,
              selected: selected == EcAppLanguage.vi,
              onTap: () => onSelect?.call(EcAppLanguage.vi),
            ),
            const SizedBox(height: 14),
            _LanguageOption(
              title: 'English',
              subtitle: l10n.languageNameEnglish,
              selected: selected == EcAppLanguage.en,
              onTap: () => onSelect?.call(EcAppLanguage.en),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: PenText(
                l10n.languageChangeAppliesNote,
                size: 14,
                color: PenColors.mut,
              ),
            ),
            const SizedBox(height: 24),
            const Center(child: PenGlobeIllustration()),
            const SizedBox(height: 8),
            PenText(
              l10n.languageChangeScopeNote,
              size: 14,
              color: PenColors.mut,
              align: TextAlign.center,
              lineHeight: 1.5,
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
            _SimpleHeader(
              title: context.l10n.accountLoginMethods,
              onBack: onBack,
            ),
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
                      detail: googleLinked
                          ? context.l10n.linkLinked
                          : context.l10n.linkNotLinked,
                      linked: googleLinked,
                      onToggle: onToggleGoogle,
                    ),
                    const SizedBox(height: 10),
                    _LoginMethodRow(
                      icon: Icons.apple,
                      name: 'Apple',
                      detail: appleLinked
                          ? context.l10n.linkLinked
                          : context.l10n.linkNotLinked,
                      linked: appleLinked,
                      onToggle: onToggleApple,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        context.l10n.loginMethodsEmailNote,
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
        borderRadius: BorderRadius.circular(AppRadius.card),
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
                Text(detail, style: _t(14, FontWeight.w400, BrandColors.mut)),
              ],
            ),
          ),
          if (isIdentity)
            Text(
              context.l10n.loginMethodIdentity,
              style: _t(14, FontWeight.w500, BrandColors.mut),
            )
          else
            EcTap(
              onTap: onToggle,
              child: Text(
                linked ? context.l10n.linkUnlink : context.l10n.linkAction,
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

/// Formats a byte count as a compact GB/MB/KB label (e.g. `60 GB`, `500 MB`).
String ecHumanBytes(int b) {
  const gb = 1024 * 1024 * 1024;
  const mb = 1024 * 1024;
  if (b >= gb) {
    return '${(b / gb).toStringAsFixed(b % gb == 0 ? 0 : 1)} GB';
  }
  if (b >= mb) return '${(b / mb).round()} MB';
  return '${(b / 1024).round()} KB';
}

/// [ecHumanBytes], but with the Vietnamese comma decimal separator (the rest
/// of this screen's copy is Vietnamese-first).
String ecHumanBytesVi(int b) => ecHumanBytes(b).replaceAll('.', ',');

/// One video type's local storage footprint, used by [EcQuotaScreen]'s
/// "Dung lượng theo loại" breakdown. Computed on-device from the upload
/// queue's actual clip files, so it always agrees with what's really stored —
/// never a separate, possibly-stale server figure.
@immutable
class EcQuotaTypeUsage {
  const EcQuotaTypeUsage({
    required this.type,
    required this.videoCount,
    required this.bytes,
  });

  final String type;
  final int videoCount;
  final int bytes;
}

/// Chart colors for the per-type breakdown bar/dots. Not part of the design
/// token set (`PenColors`) — that file has no data-viz palette — chosen to
/// stay visually distinct and calm against the rest of the screen.
const _quotaTypeColors = <Color>[
  PenColors.link,
  Color(0xFF1AA6A6),
  Color(0xFFE08A2E),
  PenColors.danger,
];

/// Quota — current plan, storage usage (GB) w/ progress bar, retention,
/// a by-type storage breakdown and an upgrade CTA.
class EcQuotaScreen extends StatelessWidget {
  const EcQuotaScreen({
    this.planLabel = '500 MB',
    this.usedBytes = 0,
    this.remainingBytes,
    this.capBytes = 500 * 1024 * 1024,
    this.retentionTotalDays = 20,
    this.videoCount = 0,
    this.typeUsage = const [],
    this.onBack,
    this.onUpgrade,
    this.onPaymentHistoryTap,
    this.canManagePlan = true,
    super.key,
  });

  final String planLabel;
  final int usedBytes;
  final int? remainingBytes;
  final int capBytes;
  final int retentionTotalDays;

  /// Total clips still stored on this device — the same source of truth as
  /// [typeUsage], so this number and the sum of the breakdown always agree.
  final int videoCount;

  /// Per-type breakdown, pre-sorted largest-first by the caller.
  final List<EcQuotaTypeUsage> typeUsage;
  final VoidCallback? onBack;
  final VoidCallback? onUpgrade;
  final VoidCallback? onPaymentHistoryTap;

  /// Gói cước gắn với tài khoản CHỦ shop. Quản lý/nhân viên vẫn thấy gói đang
  /// chi phối ca làm (giới hạn quay, retention) nhưng không có đường nâng gói —
  /// thay nút bằng một dòng giải thích để họ biết hỏi ai.
  final bool canManagePlan;

  int get _usedPercent {
    if (capBytes <= 0) return 0;
    final pct = (usedBytes / capBytes * 100).floor();
    if (pct < 0) return 0;
    if (pct > 100) return 100;
    return pct;
  }

  double get _usedFraction => _usedPercent / 100;
  int get _remainingBytes {
    final explicit = remainingBytes;
    if (explicit != null) return explicit;
    final calculated = capBytes - usedBytes;
    if (calculated < 0) return 0;
    if (calculated > capBytes) return capBytes;
    return calculated;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            _SimpleHeader(title: context.l10n.quotaScreenTitle, onBack: onBack),
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
                          PenCard(
                            axis: PenAxis.column,
                            lifted: false,
                            padding: const EdgeInsets.all(16),
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        PenText(
                                          context.l10n.quotaCurrentPlan,
                                          size: 12,
                                          color: PenColors.mut,
                                        ),
                                        const SizedBox(height: 4),
                                        PenText(
                                          planLabel,
                                          size: 20,
                                          weight: FontWeight.w600,
                                          color: PenColors.ink,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (canManagePlan)
                                    EcTap(
                                      onTap: onUpgrade,
                                      child: PenBox(
                                        fill: PenColors.primary,
                                        radius: 999,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        children: [
                                          PenText(
                                            context.l10n.quotaUpgradeShort,
                                            size: 14,
                                            weight: FontWeight.w600,
                                            color: PenColors.card,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              PenText(
                                '${ecHumanBytesVi(_remainingBytes)} ${context.l10n.quotaRemainingThisMonth.toLowerCase()}',
                                size: 20,
                                weight: FontWeight.w600,
                                color: PenColors.ink,
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                height: 8,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: PenColors.soft,
                                        borderRadius: BorderRadius.circular(
                                          4,
                                        ),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: _usedFraction,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: PenColors.primary,
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
                              PenText(
                                context.l10n.quotaUsedRatio(
                                  ecHumanBytesVi(usedBytes),
                                  ecHumanBytesVi(capBytes),
                                  _usedPercent,
                                ),
                                size: 12,
                                color: PenColors.mut,
                              ),
                              const SizedBox(height: 16),
                              const _QuotaDivider(),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _QuotaStat(
                                      value: context.l10n
                                          .quotaVideosStoredCount(videoCount),
                                      label: context.l10n.quotaVideosStored,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 32,
                                    child: VerticalDivider(
                                      width: 1,
                                      color: PenColors.line,
                                    ),
                                  ),
                                  Expanded(
                                    child: _QuotaStat(
                                      value: context.l10n.quotaRetentionDays(
                                        retentionTotalDays,
                                      ),
                                      label: context.l10n.quotaStorage,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              PenBox(
                                width: double.infinity,
                                fill: PenColors.soft,
                                radius: 12,
                                axis: PenAxis.row,
                                gap: 10,
                                cross: CrossAxisAlignment.start,
                                padding: const EdgeInsets.all(12),
                                children: [
                                  const Icon(
                                    LucideIcons.clock,
                                    size: 16,
                                    color: PenColors.mut,
                                  ),
                                  Expanded(
                                    child: PenText(
                                      context.l10n.quotaRefundNote(
                                        retentionTotalDays,
                                      ),
                                      size: 12,
                                      color: PenColors.mut,
                                      lineHeight: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (typeUsage.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            _QuotaBreakdownCard(typeUsage: typeUsage),
                          ],
                          const SizedBox(height: 14),
                          PenCard(
                            axis: PenAxis.column,
                            lifted: false,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            children: [
                              _SettingsRow(
                                icon: LucideIcons.receipt,
                                label: context.l10n.quotaPaymentHistory,
                                onTap: onPaymentHistoryTap,
                              ),
                            ],
                          ),
                          const Spacer(),
                          const SizedBox(height: 14),
                          if (canManagePlan)
                            _EcPrimaryButton(
                              label: context.l10n.quotaUpgradePlan,
                              onPressed: onUpgrade,
                            )
                          else
                            PenText(
                              context.l10n.quotaOwnerOnlyNote,
                              align: TextAlign.center,
                              size: 14,
                              color: PenColors.mut,
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

class _QuotaDivider extends StatelessWidget {
  const _QuotaDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: PenColors.line);
}

class _QuotaStat extends StatelessWidget {
  const _QuotaStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PenText(
          value,
          size: 16,
          weight: FontWeight.w600,
          color: PenColors.ink,
        ),
        const SizedBox(height: 2),
        PenText(label, size: 12, color: PenColors.mut),
      ],
    );
  }
}

/// "Dung lượng theo loại" — a stacked bar plus a row per video type, each
/// tagged with the same color so the bar segment and its row read as one.
class _QuotaBreakdownCard extends StatelessWidget {
  const _QuotaBreakdownCard({required this.typeUsage});

  final List<EcQuotaTypeUsage> typeUsage;

  @override
  Widget build(BuildContext context) {
    final totalBytes = typeUsage.fold<int>(0, (sum, u) => sum + u.bytes);
    return PenCard(
      axis: PenAxis.column,
      lifted: false,
      gap: 14,
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            PenText(
              context.l10n.quotaByType,
              size: 15,
              weight: FontWeight.w600,
              color: PenColors.ink,
            ),
            const Spacer(),
            PenText(
              ecHumanBytesVi(totalBytes),
              size: 14,
              weight: FontWeight.w600,
              color: PenColors.ink,
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                for (var i = 0; i < typeUsage.length; i++)
                  Expanded(
                    flex: typeUsage[i].bytes.clamp(1, 1 << 40),
                    child: ColoredBox(
                      color: _quotaTypeColors[i % _quotaTypeColors.length],
                    ),
                  ),
              ],
            ),
          ),
        ),
        for (var i = 0; i < typeUsage.length; i++)
          _QuotaBreakdownRow(
            usage: typeUsage[i],
            color: _quotaTypeColors[i % _quotaTypeColors.length],
          ),
      ],
    );
  }
}

class _QuotaBreakdownRow extends StatelessWidget {
  const _QuotaBreakdownRow({required this.usage, required this.color});

  final EcQuotaTypeUsage usage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PenText(
            usage.type,
            size: 14,
            color: PenColors.ink,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PenText(
              context.l10n.quotaByTypeVideosCount(usage.videoCount),
              size: 12,
              color: PenColors.mut,
            ),
            const SizedBox(height: 2),
            PenText(
              ecHumanBytesVi(usage.bytes),
              size: 14,
              weight: FontWeight.w600,
              color: PenColors.ink,
            ),
          ],
        ),
      ],
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
                  onTap: () => FocusScope.of(context).unfocus(),
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
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: BrandColors.recTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_rounded,
              size: 28,
              color: BrandColors.rec,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isFirstStep
              ? context.l10n.deleteAccountTitleStep1
              : context.l10n.deleteAccountTitleStep2,
          textAlign: TextAlign.center,
          style: _t(18, FontWeight.w700, BrandColors.rec),
        ),
        const SizedBox(height: 12),
        Text(
          isFirstStep
              ? context.l10n.deleteAccountBodyStep1
              : context.l10n.deleteAccountBodyStep2,
          textAlign: TextAlign.center,
          style: _t(14, FontWeight.w400, BrandColors.mut),
        ),
        if (isFirstStep && widget.pendingSharedProfilesCount > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BrandColors.recTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: BrandColors.rec,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.deletePendingProfilesWarning(
                      widget.pendingSharedProfilesCount,
                    ),
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
                label: context.l10n.commonCancel,
                onPressed: _handleCancel,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EcPrimaryButton(
                label: context.l10n.deleteConfirmPermanent,
                onPressed: _handlePrimary,
                color: BrandColors.rec,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            isFirstStep
                ? context.l10n.deleteStep1Hint
                : context.l10n.deleteStep2Hint,
            textAlign: TextAlign.center,
            style: _t(12, FontWeight.w400, BrandColors.mut),
          ),
        ),
      ],
    );
  }
}

/// Dịch [PasswordProblem] sang chuỗi hiển thị. Trả `null` khi mật khẩu đạt —
/// đúng giao kèo của `FormFieldValidator`. Không truyền email vào đây: màn đổi
/// mật khẩu không có sẵn email trong form, còn luật chung vẫn giữ nguyên.
String? _passwordError(BuildContext context, String? value) =>
    switch (passwordProblem(value)) {
      PasswordProblem.tooShort => context.l10n.passwordMin8Error,
      PasswordProblem.needsLetterAndDigit =>
        context.l10n.passwordNeedsLetterDigit,
      PasswordProblem.tooCommon => context.l10n.passwordTooCommon,
      null => null,
    };

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
            hasExistingPassword
                ? context.l10n.accountChangePassword
                : context.l10n.accountCreatePassword,
            style: _t(16, FontWeight.w600, BrandColors.ink),
          ),
          const SizedBox(height: 12),
          if (hasExistingPassword) ...[
            _PasswordField(
              label: context.l10n.passwordCurrentLabel,
              hint: '••••••••',
              controller: currentPasswordController,
              validator: FormBuilderValidators.required(
                errorText: context.l10n.passwordCurrentRequired,
              ),
            ),
            const SizedBox(height: 12),
          ],
          _PasswordField(
            label: context.l10n.passwordNewLabel,
            hint: context.l10n.passwordMinHint,
            controller: newPasswordController,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: context.l10n.passwordNewRequired,
              ),
              (value) => _passwordError(context, value),
            ]),
          ),
          const SizedBox(height: 12),
          _PasswordField(
            label: context.l10n.passwordConfirmLabel,
            hint: '••••••••',
            controller: confirmPasswordController,
            validator: (value) => value == newPasswordController?.text
                ? null
                : context.l10n.passwordMismatch,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _EcSecondaryButton(
                  label: context.l10n.commonCancel,
                  onPressed: onCancel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ValidatedPrimaryButton(
                  label: hasExistingPassword
                      ? context.l10n.passwordSave
                      : context.l10n.accountCreatePassword,
                  onValid: onSave,
                ),
              ),
            ],
          ),
          if (hasExistingPassword) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                context.l10n.passwordChangeLogoutNote,
                textAlign: TextAlign.center,
                style: _t(12, FontWeight.w400, BrandColors.mut),
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
    this.color = PenColors.primary,
  });
  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) => PenPrimaryButton(
    label: label,
    height: 64,
    onPressed: onPressed,
    color: color,
  );
}

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
  Widget build(BuildContext context) =>
      PenOutlineButton(label: label, onPressed: onPressed);
}

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
    return Row(
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
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 15),
            children: [
              const Icon(
                LucideIcons.cloudUpload,
                size: 19,
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
    );
  }
}

class _SimpleHeader extends StatelessWidget {
  const _SimpleHeader({required this.title, this.onBack});
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return PenHeader(title: title, onBack: onBack, gap: 14);
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.name,
    required this.email,
    this.avatarPath,
    this.onTap,
  });

  final String name;
  final String email;
  final String? avatarPath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final path = avatarPath;
    final file = path == null ? null : File(path);
    final hasLocalFile = file?.existsSync() ?? false;
    return PenCard(
      stroke: null,
      gap: 16,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      children: [
        PenBox(
          width: 62,
          height: 62,
          fill: PenColors.soft,
          radius: 999,
          clip: true,
          axis: PenAxis.row,
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          children: [
            if (!hasLocalFile)
              const Icon(LucideIcons.user, size: 34, color: PenColors.ink)
            else
              SizedBox.expand(
                child: Image.file(
                  file!,
                  fit: BoxFit.cover,
                  // Avatars are re-saved to the same path each time, so the
                  // path alone isn't a valid cache key — without this, a
                  // freshly changed photo keeps showing the stale decoded
                  // image until the app restarts.
                  key: ValueKey(file.lastModifiedSync()),
                ),
              ),
          ],
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PenText(
                name,
                size: 20,
                color: PenColors.ink,
                weight: FontWeight.w700,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              PenText(
                email,
                size: 14,
                color: PenColors.mut,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Icon(LucideIcons.chevronRight, size: 22, color: PenColors.mut),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
      child: PenText(
        label.toUpperCase(),
        size: 14,
        color: PenColors.mut,
        weight: FontWeight.w600,
        letterSpacing: 0.7,
      ),
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
      child: PenBox(
        width: double.infinity,
        axis: PenAxis.row,
        gap: 16,
        cross: CrossAxisAlignment.center,
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Icon(icon, size: 25, color: PenColors.ink),
          Expanded(
            child: PenText(
              label,
              size: 16,
              color: PenColors.ink,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (value != null)
            PenText(value!, size: 14, color: PenColors.ink, softWrap: false),
          const Icon(LucideIcons.chevronRight, size: 20, color: PenColors.mut),
        ],
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
    final l10n = context.l10n;
    return PenTabBar(
      activeIndex: switch (active) {
        _NavTab.orders => 0,
        _NavTab.capture => 1,
        _NavTab.account => 2,
      },
      tabs: [
        (LucideIcons.package, l10n.navOrders, onOrders),
        (LucideIcons.camera, l10n.navRecord, onCapture),
        (LucideIcons.user, l10n.navAccount, null),
      ],
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({this.avatarPath, this.onChangeAvatar});

  final String? avatarPath;
  final VoidCallback? onChangeAvatar;

  static void _showPreview(BuildContext context, File file) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: InteractiveViewer(
              child: Center(
                child: Image.file(
                  file,
                  key: ValueKey(file.lastModifiedSync()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = avatarPath;
    final file = path == null ? null : File(path);
    final hasLocalFile = file?.existsSync() ?? false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Tapping the photo views it full-screen; changing it is the
              // camera badge's job, so the two intents don't collide on one
              // tap target.
              EcTap(
                onTap: hasLocalFile
                    ? () => _showPreview(context, file!)
                    : null,
                child: PenBox(
                  width: 124,
                  height: 124,
                  fill: PenColors.soft,
                  radius: 999,
                  clip: true,
                  axis: PenAxis.row,
                  main: MainAxisAlignment.center,
                  cross: CrossAxisAlignment.center,
                  children: [
                    if (!hasLocalFile)
                      const Icon(
                        LucideIcons.user,
                        size: 56,
                        color: PenColors.ink,
                      )
                    else
                      SizedBox.expand(
                        child: Image.file(
                          file!,
                          fit: BoxFit.cover,
                          key: ValueKey(file.lastModifiedSync()),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                left: 88,
                top: 84,
                child: EcTap(
                  onTap: onChangeAvatar,
                  child: const PenBox(
                    width: 42,
                    height: 42,
                    fill: PenColors.ink,
                    radius: 999,
                    axis: PenAxis.row,
                    main: MainAxisAlignment.center,
                    cross: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.camera,
                        size: 21,
                        color: PenColors.card,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        EcTap(
          onTap: onChangeAvatar,
          child: PenText(
            context.l10n.changeAvatar,
            size: 16,
            color: PenColors.ink,
            softWrap: false,
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
        PenText(label, size: 16, color: PenColors.ink),
        const SizedBox(height: 9),
        PenBox(
          width: double.infinity,
          height: 62,
          fill: PenColors.card,
          stroke: error == null ? PenColors.line : PenColors.danger,
          radius: 14,
          axis: PenAxis.row,
          cross: CrossAxisAlignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: controller,
                onChanged: state?.didChange,
                keyboardType: keyboardType,
                padding: EdgeInsets.zero,
                decoration: const BoxDecoration(),
                placeholder: hint,
                style: const TextStyle(fontSize: 16, color: PenColors.ink),
                placeholderStyle: const TextStyle(
                  fontSize: 16,
                  color: PenColors.mut,
                ),
              ),
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          PenText(error, size: 12, color: PenColors.danger),
        ],
      ],
    );
  }
}

class _LockedField extends StatelessWidget {
  const _LockedField({required this.label, required this.value, this.hint});

  final String label;
  final String value;

  /// Small caption shown below the field explaining why it's locked.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PenText(label, size: 16, color: PenColors.ink),
        const SizedBox(height: 9),
        PenBox(
          width: double.infinity,
          height: 62,
          fill: PenColors.soft,
          stroke: PenColors.line,
          radius: 14,
          axis: PenAxis.row,
          gap: 10,
          cross: CrossAxisAlignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          children: [
            Expanded(
              child: PenText(
                value,
                size: 16,
                color: PenColors.ink,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(LucideIcons.lock, size: 21, color: PenColors.ink),
          ],
        ),
        if (hint != null)
          PenBox(
            width: double.infinity,
            axis: PenAxis.row,
            gap: 8,
            cross: CrossAxisAlignment.center,
            padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
            children: [
              const Icon(LucideIcons.info, size: 16, color: PenColors.mut),
              Expanded(
                child: PenText(hint!, size: 12, color: PenColors.mut),
              ),
            ],
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
    return PenCard(
      fill: selected ? PenColors.soft : PenColors.card,
      stroke: PenColors.line,
      // The design thickens the border of the chosen language rather than
      // tinting it — selection reads as ink, never as brand.
      gap: 12,
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PenText(
                title,
                size: 20,
                color: PenColors.ink,
                weight: FontWeight.w700,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              PenText(
                subtitle,
                size: 14,
                color: PenColors.mut,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (selected)
          const PenBox(
            width: 32,
            height: 32,
            fill: PenColors.ink,
            radius: 999,
            axis: PenAxis.row,
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            children: [
              Icon(LucideIcons.check, size: 18, color: PenColors.card),
            ],
          )
        else
          const PenEllipse(
            width: 32,
            height: 32,
            color: PenColors.mut,
            ring: 0.88,
          ),
      ],
    );
  }
}

/// A password input with the design's 62pt field, a leading padlock and a
/// reveal toggle.
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
    return PenField(
      icon: LucideIcons.lock,
      label: label,
      hint: hint,
      controller: controller,
      obscure: true,
      validator: validator,
    );
  }
}

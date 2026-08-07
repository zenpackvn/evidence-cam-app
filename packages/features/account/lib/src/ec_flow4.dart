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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:localization/localization.dart';
import 'package:shared_contracts/shared_contracts.dart';

// Shared text style (Inter is inherited from AppTheme's textTheme).
TextStyle _t(double size, FontWeight weight, Color color) =>
    TextStyle(fontSize: size, fontWeight: weight, color: color, height: 1.3);

/// AccountTab — profile row, two settings groups (Gói & ứng dụng / Bảo mật &
/// đăng nhập) and the 3-tab bottom nav.
///
/// Design (`F4-01`) opens with a shop-name header, but this is a root tab of
/// the bottom nav: the chevron it drew reads as a back button, and the name
/// itself duplicates the Vận đơn tab's header. Both are dropped here, so Chi
/// tiết cửa hàng (F1-09) is reached from the Vận đơn tab instead.
class EcAccountTabScreen extends StatelessWidget {
  const EcAccountTabScreen({
    this.userName = 'Nguyễn Văn A',
    this.userEmail = 'nguyenvana@gmail.com',
    this.planLabel = 'Cơ bản',
    this.languageLabel = 'Tiếng Việt',
    this.loginMethodsLabel = '3 liên kết',
    this.passwordActionLabel = 'Đổi mật khẩu',
    this.avatarPath,
    this.appVersion = '1.0.0',
    this.onProfileTap,
    this.onQuotaTap,
    this.onLanguageTap,
    this.onEndQrTap,
    this.onClaimsTap,
    this.onChangePasswordTap,
    this.onLoginMethodsTap,
    this.onLogout,
    this.onDeleteAccount,
    this.onNavOrders,
    this.onNavCapture,
    this.onFacebook,
    this.onZalo,
    this.onCall,
    this.onFeedback,
    this.onRateApp,
    super.key,
  });

  final String userName;
  final String userEmail;
  final String planLabel;
  final String languageLabel;
  final String loginMethodsLabel;
  final String passwordActionLabel;
  final String? avatarPath;

  /// Shown in the footer under the ZenPack wordmark.
  final String appVersion;
  final VoidCallback? onProfileTap;
  final VoidCallback? onQuotaTap;
  final VoidCallback? onLanguageTap;

  /// Mở tờ QR "kết thúc phiên" để in. Mã dùng chung cho mọi máy, nên nó thuộc
  /// nhóm cài đặt app chứ không phải của riêng shop nào.
  final VoidCallback? onEndQrTap;

  /// Mở danh sách hồ sơ khiếu nại đã tạo.
  final VoidCallback? onClaimsTap;
  final VoidCallback? onChangePasswordTap;
  final VoidCallback? onLoginMethodsTap;
  final VoidCallback? onLogout;
  final VoidCallback? onDeleteAccount;
  final VoidCallback? onNavOrders;
  final VoidCallback? onNavCapture;

  /// Ba kênh hỗ trợ nổi ở góc trái dưới.
  final VoidCallback? onFacebook;
  final VoidCallback? onZalo;
  final VoidCallback? onCall;

  /// Mục "Giới thiệu": góp ý và đánh giá app trên store.
  final VoidCallback? onFeedback;
  final VoidCallback? onRateApp;

  /// Chiều cao dải xanh (phần NẰM DƯỚI tai thỏ — `PenBrandBanner` tự cộng
  /// `safeArea.top` vào), dùng cả ở chỗ vẽ lẫn chỗ tính trần khối cố định —
  /// hai chỗ lệch nhau là sinh ra khe hở hoặc phần xanh bị đè.
  ///
  /// Lùi 14 cùng lúc với [_cardTopGap] (26 -> 12). Kéo thẻ lên mà để nền xanh
  /// đứng yên thì trông y như chưa sửa gì.
  static const _bannerHeight = 126.0;

  /// Khoảng hở giữa mép dưới tai thỏ và thẻ tài khoản.
  ///
  /// Vùng an toàn của iOS đã chừa sẵn chỗ cho tai thỏ, nên con số này chỉ là
  /// khoảng thở thêm. 26 cũ tạo ra một dải trống nhìn như lỗi căn lề.
  static const _cardTopGap = 12.0;

  /// Chiều cao khối cố định tính từ mép dưới tai thỏ: [_cardTopGap] + thẻ tài
  /// khoản (đệm 16 mỗi phía quanh nội dung cao 62).
  ///
  /// Vùng cuộn lấy đúng số này làm lề trên. Lấy theo [_bannerHeight] như bản
  /// trước là sai: đáy thẻ nằm thấp hơn đáy dải xanh, nên mục đầu tiên bị thẻ
  /// che mất một phần ngay khi chưa cuộn. Suy ra từ [_cardTopGap] chứ không gõ
  /// lại số: sửa một chỗ mà quên chỗ kia là sinh đúng cái khe hở này.
  static const _headerBlockHeight = _cardTopGap + 62.0 + 32.0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: Stack(
        children: [
          // Vùng cuộn chiếm toàn màn và vẽ TRƯỚC, nên nội dung trượt lên là
          // chui xuống dưới dải xanh lẫn thẻ tài khoản. Lề trên đúng bằng đáy
          // thẻ nên lúc chưa cuộn không có gì bị che.
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                18,
                MediaQuery.paddingOf(context).top + _headerBlockHeight,
                18,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionHeader(context.l10n.accountSectionApp, top: 38),
                  _SettingsGroup(
                    rows: [
                      _SettingsRow(
                        icon: LucideIcons.creditCard,
                        label: context.l10n.accountPlanQuota,
                        value: planLabel,
                        onTap: onQuotaTap,
                      ),
                      _SettingsRow(
                        icon: LucideIcons.globe,
                        label: context.l10n.accountLanguage,
                        value: languageLabel,
                        onTap: onLanguageTap,
                      ),
                      _SettingsRow(
                        icon: LucideIcons.qrCode,
                        label: context.l10n.accountEndQr,
                        onTap: onEndQrTap,
                      ),
                      _SettingsRow(
                        icon: LucideIcons.fileText,
                        label: context.l10n.accountClaims,
                        onTap: onClaimsTap,
                      ),
                    ],
                  ),
                  _SectionHeader(context.l10n.accountSectionSecurity),
                  _SettingsGroup(
                    rows: [
                      _SettingsRow(
                        icon: LucideIcons.lock,
                        label: passwordActionLabel,
                        onTap: onChangePasswordTap,
                      ),
                      _SettingsRow(
                        icon: LucideIcons.keyRound,
                        label: context.l10n.accountLoginMethods,
                        value: loginMethodsLabel,
                        onTap: onLoginMethodsTap,
                      ),
                      _SettingsRow(
                        icon: LucideIcons.logOut,
                        label: context.l10n.accountSignOut,
                        onTap: onLogout,
                      ),
                      _SettingsRow(
                        icon: LucideIcons.trash2,
                        label: context.l10n.accountDeleteAccount,
                        onTap: onDeleteAccount,
                      ),
                    ],
                  ),
                  _SectionHeader(context.l10n.accountSectionAbout),
                  _SettingsGroup(
                    rows: [
                      _SettingsRow(
                        icon: LucideIcons.messageSquareText,
                        label: context.l10n.accountFeedback,
                        subtitle: context.l10n.accountFeedbackNote,
                        onTap: onFeedback,
                      ),
                      _SettingsRow(
                        icon: LucideIcons.star,
                        label: context.l10n.accountRateApp,
                        subtitle: context.l10n.accountRateAppNote,
                        onTap: onRateApp,
                      ),
                    ],
                  ),
                  _AppFooter(version: appVersion),
                  // Chừa chỗ cho thanh tab nổi bên dưới, nếu không mục cuối
                  // nằm khuất sau nó. Cùng nguồn số với chỗ kê nút liên hệ.
                  SizedBox(height: PenTabBar.heightOf(context) + 16),
                ],
              ),
            ),
          ),
          // Dải xanh khoá, vẽ SAU vùng cuộn nên nội dung chui xuống dưới nó.
          const Align(
            alignment: Alignment.topCenter,
            child: PenBrandBanner(height: _bannerHeight),
          ),
          // Thẻ tài khoản khoá, nằm trên cùng.
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, _cardTopGap, 18, 0),
              child: _UserRow(
                name: userName,
                email: userEmail,
                avatarPath: avatarPath,
                onTap: onProfileTap,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomNav(
              active: _NavTab.account,
              onOrders: onNavOrders,
              onCapture: onNavCapture,
            ),
          ),
          // Cụm liên hệ nổi ở góc phải dưới. Nằm trong Stack nên nó không cuộn
          // theo nội dung — người cần hỗ trợ thường đang bí, bắt họ cuộn tìm
          // là thêm một rào nữa.
          //
          // Kê lên đúng chiều cao thật của thanh tab, để nút dưới cùng không
          // đè lên mục "Tài khoản" — đè lên là bấm nhầm sang tab khác thay vì
          // gọi hỗ trợ. Lấy từ `PenTabBar.heightOf` chứ không chép số: bản
          // trước chép 82 trong khi thanh cao 92, lệch đúng 10pt.
          Positioned(
            right: 16,
            bottom: PenTabBar.heightOf(context) + 12,
            child: _SupportContactColumn(
              onFacebook: onFacebook,
              onZalo: onZalo,
              onCall: onCall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Đuôi màn Tài khoản: logo, wordmark, số phiên bản.
class _AppFooter extends StatelessWidget {
  const _AppFooter({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 22),
      child: Column(
        children: [
          Image.asset(
            'assets/design/logo.png',
            package: 'ec_ui',
            width: 34,
            height: 34,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 4),
          const PenText(
            'ZenPack',
            size: 15,
            color: PenColors.primary,
            weight: FontWeight.w800,
            softWrap: false,
          ),
          const SizedBox(height: 4),
          PenText(
            context.l10n.accountVersion(version),
            size: 12,
            color: PenColors.mut,
            weight: FontWeight.w500,
            softWrap: false,
          ),
        ],
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
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  // Design `Body`: padding [28, 26, 0, 26].
                  padding: const EdgeInsets.fromLTRB(26, 28, 26, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SimpleHeader(
                        title: context.l10n.accountInfoTitle,
                        onBack: onBack,
                      ),
                      Center(
                        child: _AvatarPicker(
                          avatarPath: avatarPath,
                          onChangeAvatar: onChangeAvatar,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _Field(
                        label: context.l10n.accountFullName,
                        hint: context.l10n.accountFullNameHint,
                        controller: nameController,
                        validator: FormBuilderValidators.required(
                          errorText: context.l10n.accountFullNameRequired,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Field(
                        label: context.l10n.phoneOptionalLabel,
                        hint: context.l10n.phoneOptionalHint,
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
                      const SizedBox(height: 20),
                      _LockedField(
                        label: 'Email',
                        value: email,
                        hint: context.l10n.accountEmailLockedHint,
                      ),
                    ],
                  ),
                ),
              ),
              // Design `SaveWrap`: padding [0, 26, 26, 26].
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 26),
                child: _ValidatedPrimaryButton(
                  label: context.l10n.accountSaveChanges,
                  onValid: onSave,
                ),
              ),
            ],
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
      scrollable: false,
      // The globe and its caption are absolutely placed in the design
      // (`layoutPosition: absolute`), sitting behind the options rather than
      // flowing after them.
      decorations: [
        const Positioned(left: 45, top: 392, child: PenGlobeIllustration()),
        // The sprig hangs to the left of the globe's own box, so it is placed
        // on the screen rather than inside the illustration (which would clip
        // it).
        const Positioned(left: 32, top: 486, child: PenLeafSprig()),
        Positioned(
          left: 45,
          top: 542,
          child: SizedBox(
            width: 300,
            child: Column(
              children: [
                for (final line in l10n.languageChangeScopeNote.split('\n'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: PenText(
                      line,
                      size: 14,
                      color: PenColors.mut,
                      align: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
      // Fills the viewport so the absolutely-placed decorations above stay
      // inside the screen's stack instead of being clipped away.
      child: SizedBox.expand(
        child: Padding(
          // Design `Body`: padding [28, 22, 0, 22].
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _SimpleHeader(title: l10n.accountLanguage, onBack: onBack),
              const SizedBox(height: 22),
              _LanguageOption(
                title: 'Tiếng Việt',
                // The pair reads as native-name over other-language-name, so
                // these two labels are fixed rather than locale-dependent.
                subtitle: 'Vietnamese',
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
            ],
          ),
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
    this.showApple = true,
    this.onBack,
    this.onToggleGoogle,
    this.onToggleApple,
    super.key,
  });

  final String email;
  final bool googleLinked;
  final bool appleLinked;

  /// Whether Apple can be linked on this platform. False hides the row, unless
  /// [appleLinked] — a link made on another device stays listed so it can still
  /// be removed, and so the row count matches the "N methods" summary.
  final bool showApple;
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
                      icon: const Icon(
                        Icons.mail_outline,
                        size: 24,
                        color: BrandColors.ink,
                      ),
                      name: 'Email',
                      detail: email,
                      linked: true,
                      isIdentity: true,
                    ),
                    const SizedBox(height: 10),
                    _LoginMethodRow(
                      // `Icons.g_mobiledata` chỉ vẽ chữ "G" trần, nhìn như
                      // thiếu icon chứ không phải logo Google.
                      icon: const FaIcon(
                        FontAwesomeIcons.google,
                        size: 20,
                        color: BrandColors.ink,
                      ),
                      name: 'Google',
                      detail: googleLinked
                          ? context.l10n.linkLinked
                          : context.l10n.linkNotLinked,
                      linked: googleLinked,
                      onToggle: onToggleGoogle,
                    ),
                    if (showApple || appleLinked) ...[
                      const SizedBox(height: 10),
                      _LoginMethodRow(
                        icon: const Icon(
                          Icons.apple,
                          size: 24,
                          color: BrandColors.ink,
                        ),
                        name: 'Apple',
                        detail: appleLinked
                            ? context.l10n.linkLinked
                            : context.l10n.linkNotLinked,
                        linked: appleLinked,
                        onToggle: onToggleApple,
                      ),
                    ],
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
  final Widget icon;
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
          // Nhận thẳng widget: logo Google nằm ở bộ Font Awesome (`FaIcon`),
          // còn Apple/Email dùng bộ Material — hai kiểu `IconData` khác nhau
          // nên không gói chung một tham số được.
          SizedBox(width: 26, child: Center(child: icon)),
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

/// Drops [used]'s unit when [cap] already carries the same one, so the ratio
/// reads "Đã dùng 28,2 / 60 GB" the way the design writes it — not
/// "28,2 GB / 60 GB".
String _withoutSharedUnit(String used, String cap) {
  final unit = ' ${cap.split(' ').last}';
  return used.endsWith(unit)
      ? used.substring(0, used.length - unit.length)
      : used;
}

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

/// The breakdown ramp, straight from the design: two greens, then amber and
/// red — `--chart-1/2` plus `--warning` and `--destructive`. Largest slice
/// first, so rank 0 is the darkest green.
const _quotaTypeColors = <Color>[
  PenColors.primary,
  PenColors.success,
  _warning,
  PenColors.danger,
];

/// One icon per breakdown rank, matching the design's row glyphs.
const _quotaTypeIcons = <IconData>[
  LucideIcons.packageCheck,
  LucideIcons.truck,
  LucideIcons.rotateCcw,
  LucideIcons.scale,
];

Color _quotaTypeColor(int rank) =>
    _quotaTypeColors[rank % _quotaTypeColors.length];

IconData _quotaTypeIcon(int rank) =>
    _quotaTypeIcons[rank % _quotaTypeIcons.length];

/// Quota — current plan, storage usage (GB) w/ progress bar, retention,
/// a by-type storage breakdown and an upgrade CTA.
class EcQuotaScreen extends StatelessWidget {
  const EcQuotaScreen({
    this.planLabel = 'Cơ bản',
    this.planCode = 'P1',
    this.usedBytes = 0,
    this.remainingBytes,
    this.capBytes = 500 * 1024 * 1024,
    this.retentionTotalDays = 30,
    this.videoCount = 0,
    this.typeUsage = const [],
    this.onBack,
    this.canManagePlan = true,
    super.key,
  });

  final String planLabel;

  /// Short plan code shown in the header chip (design: "P1").
  final String planCode;
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

  /// Gói cước gắn với tài khoản CHỦ shop; quản lý/nhân viên chỉ xem.
  ///
  /// Từ khi app không bán gói nữa thì AI CŨNG chỉ xem, nên cờ này không còn bật
  /// tắt nút nào. Giữ lại vì backend vẫn trả về và màn hình còn có thể cần phân
  /// biệt hai vai trò sau này.
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
    final l10n = context.l10n;
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // Design `Body`: gap 12, padding [24, 18, 0, 18].
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        PenBackButton(onTap: onBack),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PenText(
                                l10n.quotaScreenTitle,
                                size: 23,
                                color: PenColors.ink,
                                weight: FontWeight.w800,
                                softWrap: false,
                              ),
                              const SizedBox(height: 2),
                              PenText(
                                l10n.quotaSubtitle,
                                size: 12,
                                color: PenColors.mut,
                                softWrap: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _PlanChip(label: planCode),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _QuotaSummaryCard(
                      planLabel: planLabel,
                      remainingLabel: ecHumanBytesVi(_remainingBytes),
                      usedLabel: _withoutSharedUnit(
                        ecHumanBytesVi(usedBytes),
                        ecHumanBytesVi(capBytes),
                      ),
                      capLabel: ecHumanBytesVi(capBytes),
                      usedPercent: _usedPercent,
                      usedFraction: _usedFraction,
                      videoCount: videoCount,
                      retentionTotalDays: retentionTotalDays,
                      canManagePlan: canManagePlan,
                    ),
                    if (typeUsage.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _QuotaBreakdownCard(typeUsage: typeUsage),
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

/// The amber `PlanChip` in the quota header — the plan's short code.
class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => PenBox(
    fill: const Color(0xFFFFF6E5),
    radius: 999,
    axis: PenAxis.row,
    gap: 6,
    cross: CrossAxisAlignment.center,
    hugMain: true,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 11),
    children: [
      const Icon(LucideIcons.badgeCheck, size: 15, color: _warning),
      PenText(
        label,
        size: 13,
        color: _warning,
        weight: FontWeight.w800,
        softWrap: false,
      ),
    ],
  );
}

/// `--warning` / `--chart-4` — the amber the design uses for plan and
/// renewal accents (design-dna-app.md §1).
const _warning = Color(0xFFB6770B);

/// `CardUsageSummary` — plan, remaining headline, usage bar and the two
/// stored/retention stats.
class _QuotaSummaryCard extends StatelessWidget {
  const _QuotaSummaryCard({
    required this.planLabel,
    required this.remainingLabel,
    required this.usedLabel,
    required this.capLabel,
    required this.usedPercent,
    required this.usedFraction,
    required this.videoCount,
    required this.retentionTotalDays,
    required this.canManagePlan,
  });

  final String planLabel;
  final String remainingLabel;
  final String usedLabel;
  final String capLabel;
  final int usedPercent;
  final double usedFraction;
  final int videoCount;
  final int retentionTotalDays;
  final bool canManagePlan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenCard(
      axis: PenAxis.column,
      stroke: null,
      gap: 12,
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PenText(
                    l10n.quotaCurrentPlan,
                    size: 13,
                    color: PenColors.mut,
                    softWrap: false,
                  ),
                  const SizedBox(height: 3),
                  PenText(
                    planLabel,
                    size: 24,
                    color: PenColors.ink,
                    weight: FontWeight.w800,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PenText(
              l10n.quotaRemainingAmount(remainingLabel),
              size: 28,
              color: PenColors.ink,
              weight: FontWeight.w800,
              softWrap: false,
            ),
            const SizedBox(height: 4),
            PenText(
              l10n.quotaUsedRatio(usedLabel, capLabel, usedPercent),
              size: 13,
              color: PenColors.mut,
              softWrap: false,
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            width: double.infinity,
            height: 10,
            child: Stack(
              children: [
                const Positioned.fill(child: ColoredBox(color: _track)),
                // `Positioned.fill`, not a bare child: a `Stack` hands
                // non-positioned children *loose* constraints, so the fill
                // would collapse to zero height and never paint.
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: usedFraction.clamp(0.0, 1.0),
                    // Rounded on its own, so the fill ends in a cap the way
                    // the design draws it instead of a square edge.
                    child: const PenBox(
                      fill: PenColors.success,
                      radius: 999,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _QuotaStat(
                  label: l10n.quotaVideosStored,
                  value: l10n.quotaVideosStoredCount(videoCount),
                ),
              ),
              const SizedBox(width: 14),
              const SizedBox(
                width: 1,
                height: 34,
                child: ColoredBox(
                  color: PenColors.line,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _QuotaStat(
                  label: l10n.quotaStorage,
                  value: l10n.quotaRetentionDays(retentionTotalDays),
                ),
              ),
            ],
          ),
        ),
        PenBox(
          width: double.infinity,
          fill: const Color(0xFFF7F7F7),
          radius: 10,
          axis: PenAxis.row,
          gap: 8,
          cross: CrossAxisAlignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          children: [
            const Icon(LucideIcons.refreshCw, size: 16, color: _warning),
            Expanded(
              child: PenText(
                l10n.quotaRefundNote(retentionTotalDays),
                size: 12,
                color: PenColors.mut,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// `#EDEDED` — the unfilled part of every progress/stack bar in this design.
const _track = Color(0xFFEDEDED);

class _QuotaStat extends StatelessWidget {
  const _QuotaStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PenText(label, size: 12, color: PenColors.mut, softWrap: false),
        const SizedBox(height: 4),
        PenText(
          value,
          size: 17,
          color: PenColors.ink,
          weight: FontWeight.w700,
          softWrap: false,
        ),
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
      stroke: null,
      gap: 10,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      children: [
        Row(
          children: [
            Expanded(
              child: PenText(
                context.l10n.quotaByType,
                size: 17,
                color: PenColors.ink,
                weight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            PenText(
              ecHumanBytesVi(totalBytes),
              size: 18,
              color: PenColors.ink,
              weight: FontWeight.w800,
              softWrap: false,
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            width: double.infinity,
            height: 10,
            child: Row(
              // `stretch`, not the default `center`: a centered child gets
              // loose height constraints and a bare `ColoredBox` collapses to
              // nothing, leaving the bar invisible.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < typeUsage.length; i++)
                  Expanded(
                    flex: typeUsage[i].bytes.clamp(1, 1 << 40),
                    child: ColoredBox(color: _quotaTypeColor(i)),
                  ),
              ],
            ),
          ),
        ),
        // The design's `Rows` frame is one child with no gap of its own, so
        // the card's 10pt gap must not fall between the rows.
        _BreakdownRows(typeUsage: typeUsage),
      ],
    );
  }
}

class _BreakdownRows extends StatelessWidget {
  const _BreakdownRows({required this.typeUsage});

  final List<EcQuotaTypeUsage> typeUsage;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < typeUsage.length; i++) ...[
        if (i > 0) const SizedBox(height: 1, child: ColoredBox(color: _track)),
        _QuotaBreakdownRow(usage: typeUsage[i], rank: i),
      ],
    ],
  );
}

class _QuotaBreakdownRow extends StatelessWidget {
  const _QuotaBreakdownRow({required this.usage, required this.rank});

  final EcQuotaTypeUsage usage;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final color = _quotaTypeColor(rank);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          PenBox(
            width: 30,
            height: 30,
            fill: const Color(0xFFF7F7F7),
            radius: 999,
            axis: PenAxis.row,
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            children: [Icon(_quotaTypeIcon(rank), size: 17, color: color)],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PenText(
                  usage.type,
                  size: 14,
                  color: PenColors.ink,
                  weight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                const SizedBox(height: 2),
                PenText(
                  context.l10n.quotaByTypeVideosCount(usage.videoCount),
                  size: 12,
                  color: PenColors.mut,
                  softWrap: false,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          PenText(
            ecHumanBytesVi(usage.bytes),
            size: 16,
            color: PenColors.ink,
            weight: FontWeight.w800,
            softWrap: false,
          ),
        ],
      ),
    );
  }
}

/// Centered dialog chrome with tap-outside-to-dismiss (matches flow-1's
/// dialogs). [onDismiss] fires when the area outside the card is tapped.
/// The modal scrim the design paints behind every dialog (`Dim` in the `.pen`).
const _dimFill = Color(0xA6636363);

/// Dialog shell — the design's `Dialog` frame: a [width]pt card with a 14pt
/// radius over a [_dimFill] scrim, anchored at the design's own [top] offset
/// on the 844pt artboard. Taller-than-viewport content scrolls, and the anchor
/// collapses toward the top edge on shorter screens so the card always fits.
class _DialogFrame extends StatelessWidget {
  const _DialogFrame({
    required this.children,
    this.onDismiss,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 18),
    this.width = 314,
    this.top = 248,
  });
  final List<Widget> children;
  final VoidCallback? onDismiss;
  final EdgeInsets padding;
  final double width;
  final double top;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _dimFill,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss ?? () => Navigator.of(context).maybePop(),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.only(
                top: (top / 844 * constraints.maxHeight).clamp(16.0, top),
                bottom: 24,
              ),
              child: Align(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: PenBox(
                    width: width,
                    fill: PenColors.card,
                    radius: 14,
                    // The design lifts every dialog off its scrim.
                    shadows: const [
                      BoxShadow(
                        color: Color(0x1F161616),
                        offset: Offset(0, 14),
                        blurRadius: 36,
                      ),
                    ],
                    axis: PenAxis.column,
                    cross: CrossAxisAlignment.center,
                    hugMain: true,
                    padding: padding,
                    children: children,
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

/// The dialog action pair: two 52pt / 10pt-radius buttons with a 12pt gap.
class _DialogButtons extends StatelessWidget {
  const _DialogButtons({
    required this.cancelLabel,
    required this.confirmLabel,
    this.onCancel,
    this.onConfirm,
    this.confirmColor = PenColors.primary,
  });

  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final Color confirmColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: EcTap(
            onTap: onCancel,
            child: PenBox(
              height: 52,
              fill: PenColors.card,
              stroke: PenColors.line,
              radius: 10,
              axis: PenAxis.row,
              main: MainAxisAlignment.center,
              cross: CrossAxisAlignment.center,
              children: [
                PenText(
                  cancelLabel,
                  size: 16,
                  color: PenColors.ink,
                  weight: FontWeight.w600,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: EcTap(
            onTap: onConfirm,
            child: PenBox(
              height: 52,
              fill: confirmColor,
              radius: 10,
              axis: PenAxis.row,
              main: MainAxisAlignment.center,
              cross: CrossAxisAlignment.center,
              children: [
                PenText(
                  confirmLabel,
                  size: 16,
                  color: PenColors.card,
                  weight: FontWeight.w700,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ),
      ],
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
    final showNote = isFirstStep && widget.pendingSharedProfilesCount > 0;
    return _DialogFrame(
      onDismiss: _handleCancel,
      children: [
        const PenBox(
          width: 82,
          height: 82,
          fill: BrandColors.recTint,
          radius: 999,
          axis: PenAxis.row,
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          children: [
            Icon(LucideIcons.triangleAlert, size: 40, color: PenColors.danger),
          ],
        ),
        const SizedBox(height: 18),
        PenText(
          isFirstStep
              ? context.l10n.deleteAccountTitleStep1
              : context.l10n.deleteAccountTitleStep2,
          size: 24,
          color: PenColors.danger,
          weight: FontWeight.w800,
          align: TextAlign.center,
        ),
        const SizedBox(height: 12),
        PenText(
          isFirstStep
              ? context.l10n.deleteAccountBodyStep1
              : context.l10n.deleteAccountBodyStep2,
          size: 14,
          color: PenColors.mut,
          align: TextAlign.center,
          lineHeight: 1.55,
        ),
        if (showNote) ...[
          const SizedBox(height: 16),
          PenBox(
            width: double.infinity,
            fill: BrandColors.recTint,
            radius: 10,
            axis: PenAxis.row,
            gap: 12,
            cross: CrossAxisAlignment.center,
            padding: const EdgeInsets.all(14),
            children: [
              const Icon(LucideIcons.info, size: 22, color: PenColors.success),
              Expanded(
                child: PenText(
                  context.l10n.deletePendingProfilesWarning(
                    widget.pendingSharedProfilesCount,
                  ),
                  size: 12,
                  color: PenColors.ink,
                  lineHeight: 1.45,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        _DialogButtons(
          cancelLabel: context.l10n.commonCancel,
          confirmLabel: context.l10n.deleteConfirmPermanent,
          confirmColor: PenColors.danger,
          onCancel: _handleCancel,
          onConfirm: _handlePrimary,
        ),
        const SizedBox(height: 14),
        PenText(
          isFirstStep
              ? context.l10n.deleteStep1Hint
              : context.l10n.deleteStep2Hint,
          size: 12,
          color: PenColors.mut,
          align: TextAlign.center,
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
      child: Builder(
        builder: (context) => _DialogFrame(
          onDismiss: onCancel,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          children: [
            PenText(
              hasExistingPassword
                  ? context.l10n.accountChangePassword
                  : context.l10n.accountCreatePassword,
              size: 20,
              color: PenColors.ink,
              weight: FontWeight.w800,
              align: TextAlign.center,
            ),
            const SizedBox(height: 18),
            if (hasExistingPassword) ...[
              _DialogPasswordField(
                label: context.l10n.passwordCurrentLabel,
                hint: '•••••••••',
                controller: currentPasswordController,
                validator: FormBuilderValidators.required(
                  errorText: context.l10n.passwordCurrentRequired,
                ),
              ),
              const SizedBox(height: 14),
            ],
            _DialogPasswordField(
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
            const SizedBox(height: 14),
            _DialogPasswordField(
              label: context.l10n.passwordConfirmLabel,
              hint: '•••••••••',
              controller: confirmPasswordController,
              validator: (value) => value == newPasswordController?.text
                  ? null
                  : context.l10n.passwordMismatch,
            ),
            const SizedBox(height: 20),
            _DialogButtons(
              cancelLabel: context.l10n.commonCancel,
              confirmLabel: hasExistingPassword
                  ? context.l10n.passwordSave
                  : context.l10n.accountCreatePassword,
              onCancel: onCancel,
              onConfirm: onSave == null
                  ? null
                  : () {
                      if (Form.of(context).validate()) onSave!();
                    },
            ),
            if (hasExistingPassword) ...[
              const SizedBox(height: 14),
              PenText(
                context.l10n.passwordChangeLogoutNote,
                size: 12,
                color: PenColors.mut,
                align: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The dialog-sized password input: a 14/400 label, 8pt gap, then a 54pt
/// field with a 10pt radius and a reveal toggle (design `G-*` groups in
/// F4-05). Distinct from the full-screen [PenField], which is taller.
class _DialogPasswordField extends StatefulWidget {
  const _DialogPasswordField({
    required this.label,
    required this.hint,
    this.controller,
    this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  State<_DialogPasswordField> createState() => _DialogPasswordFieldState();
}

class _DialogPasswordFieldState extends State<_DialogPasswordField> {
  var _obscured = true;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.controller?.text ?? '',
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        final error = state.errorText;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PenText(widget.label, size: 14, color: PenColors.ink),
            const SizedBox(height: 8),
            PenBox(
              width: double.infinity,
              height: 54,
              fill: PenColors.card,
              stroke: error == null ? PenColors.line : PenColors.danger,
              radius: 10,
              axis: PenAxis.row,
              gap: 10,
              cross: CrossAxisAlignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: widget.controller,
                    onChanged: state.didChange,
                    obscureText: _obscured,
                    padding: EdgeInsets.zero,
                    decoration: const BoxDecoration(),
                    placeholder: widget.hint,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: PenColors.ink,
                    ),
                    // The weight has to be spelled out: `placeholderStyle`
                    // inherits from `style` above, so the hint would come out
                    // bold like the value.
                    placeholderStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: PenColors.mut,
                    ),
                  ),
                ),
                EcTap(
                  onTap: () => setState(() => _obscured = !_obscured),
                  child: Icon(
                    _obscured ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 20,
                    color: PenColors.ink,
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
      },
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

class _SimpleHeader extends StatelessWidget {
  const _SimpleHeader({required this.title, this.onBack});
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return PenHeader(title: title, onBack: onBack, gap: 14, backSize: 26);
  }
}

/// Ảnh đại diện từ đường dẫn file trên máy HOẶC URL công khai.
///
/// Hai nguồn vì ảnh vừa chọn nằm trên máy (hiện ngay, không chờ mạng), còn
/// máy mới hay sau khi cài lại app thì chỉ có URL trên hồ sơ Firebase.
/// `null` khi không dựng được, để chỗ gọi rơi về icon mặc định.
Widget? _avatarImage(String? path, {required double size}) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
  final file = File(path);
  if (!file.existsSync()) return null;
  return SizedBox(
    width: size,
    height: size,
    child: Image.file(
      file,
      fit: BoxFit.cover,
      // Avatar được ghi đè lên cùng đường dẫn mỗi lần đổi, nên riêng đường dẫn
      // không đủ làm khoá bộ nhớ đệm — thiếu dòng này thì ảnh mới vẫn hiện bản
      // cũ cho tới khi khởi động lại app.
      key: ValueKey(file.lastModifiedSync()),
    ),
  );
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
    final image = _avatarImage(avatarPath, size: 62);
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
          // Vòng trắng 2pt tách ảnh khỏi thẻ khi thẻ đè lên dải xanh.
          stroke: PenColors.card,
          strokeWidth: 2,
          radius: 999,
          clip: true,
          axis: PenAxis.row,
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          children: [
            image ??
                const Icon(LucideIcons.user, size: 34, color: PenColors.ink),
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

/// Ba nút liên hệ hỗ trợ, xếp dọc ở góc trái dưới trang Tài khoản.
/// Sheet góp ý: một ô nhập nhiều dòng, đếm ký tự, và nút gửi.
///
/// Giới hạn [maxLength] ký tự có chủ đích — góp ý dài thành bài viết thì người
/// đọc bên trong không xử lý nổi, mà người gửi cũng không biết mình đã vượt
/// mức nào nếu không có bộ đếm.
class EcFeedbackSheet extends StatefulWidget {
  const EcFeedbackSheet({this.onSubmit, this.onClose, super.key});

  /// Nhận nội dung góp ý đã cắt khoảng trắng thừa.
  final ValueChanged<String>? onSubmit;
  final VoidCallback? onClose;

  static const maxLength = 300;

  @override
  State<EcFeedbackSheet> createState() => _EcFeedbackSheetState();
}

class _EcFeedbackSheetState extends State<EcFeedbackSheet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = _controller.text.trim();
    final canSend = text.isNotEmpty;
    return PenSheet(
      onDismiss: widget.onClose,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: [
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PenText(
                l10n.feedbackTitle,
                size: 19,
                color: PenColors.ink,
                weight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 12),
            EcTap(
              onTap: widget.onClose,
              child: const Icon(
                LucideIcons.x,
                size: 22,
                color: PenColors.mut,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PenBox(
          width: double.infinity,
          height: 168,
          fill: PenColors.card,
          stroke: PenColors.line,
          radius: 12,
          axis: PenAxis.column,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: _controller,
                padding: EdgeInsets.zero,
                decoration: const BoxDecoration(),
                placeholder: l10n.feedbackHint,
                maxLength: EcFeedbackSheet.maxLength,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 16, color: PenColors.ink),
                placeholderStyle: const TextStyle(
                  fontSize: 16,
                  color: PenColors.mut,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: PenText(
            '${_controller.text.characters.length} / '
            '${EcFeedbackSheet.maxLength}',
            size: 13,
            color: PenColors.mut,
          ),
        ),
        const SizedBox(height: 12),
        EcTap(
          onTap: canSend ? () => widget.onSubmit?.call(text) : null,
          child: Opacity(
            opacity: canSend ? 1 : 0.45,
            child: PenBox(
              width: double.infinity,
              height: 54,
              fill: PenColors.primary,
              radius: 14,
              axis: PenAxis.row,
              main: MainAxisAlignment.center,
              cross: CrossAxisAlignment.center,
              children: [
                PenText(
                  l10n.feedbackSend,
                  size: 16,
                  color: PenColors.card,
                  weight: FontWeight.w700,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Sheet xác nhận sau khi gửi góp ý.
class EcFeedbackThanksSheet extends StatelessWidget {
  const EcFeedbackThanksSheet({this.onClose, super.key});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenSheet(
      onDismiss: onClose,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: [
        const SizedBox(height: 26),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: PenColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              LucideIcons.check,
              size: 38,
              color: PenColors.card,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: PenText(
            l10n.feedbackThanksTitle,
            size: 20,
            color: PenColors.ink,
            weight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: PenText(
            l10n.feedbackThanksBody,
            size: 15,
            color: PenColors.mut,
            align: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        EcTap(
          onTap: onClose,
          child: PenBox(
            width: double.infinity,
            height: 54,
            fill: PenColors.primary,
            radius: 14,
            axis: PenAxis.row,
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            children: [
              PenText(
                l10n.commonClose,
                size: 16,
                color: PenColors.card,
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

class _SupportContactColumn extends StatelessWidget {
  const _SupportContactColumn({this.onFacebook, this.onZalo, this.onCall});

  final VoidCallback? onFacebook;
  final VoidCallback? onZalo;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SupportBubble(
          onTap: onFacebook,
          fill: const Color(0xFF1877F2),
          semanticLabel: l10n.supportFacebook,
          child: const FaIcon(
            FontAwesomeIcons.facebookF,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _SupportBubble(
          onTap: onZalo,
          // Xanh thương hiệu Zalo, chữ trắng — đồng bộ với hai nút kia (nền
          // màu, hình trắng). Bản trước để nền trắng chữ xanh nên nó chìm hẳn
          // giữa Facebook và nút gọi.
          fill: const Color(0xFF0068FF),
          semanticLabel: l10n.supportZalo,
          // Zalo không có trong bộ icon nào sẵn có; chữ trong vòng tròn là
          // cách nhận diện chính thức của họ nên vẽ thẳng bằng text.
          child: const Text(
            'Zalo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SupportBubble(
          onTap: onCall,
          fill: const Color(0xFF5CA872),
          semanticLabel: l10n.supportCall,
          child: const Icon(LucideIcons.phone, size: 20, color: Colors.white),
        ),
      ],
    );
  }
}

class _SupportBubble extends StatelessWidget {
  const _SupportBubble({
    required this.child,
    required this.fill,
    required this.semanticLabel,
    this.onTap,
  });

  final Widget child;
  final Color fill;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: EcTap(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x33161616),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label, {this.top = 22});

  final String label;

  /// Nhóm đầu tiên nằm xa thẻ hồ sơ hơn (38) để thoát khỏi dải xanh.
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4, top, 4, 10),
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
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;

  /// Dòng phụ dưới nhãn, giải thích hàng này làm gì. Null thì hàng giữ nguyên
  /// dáng một dòng như các mục cài đặt còn lại.
  final String? subtitle;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                PenText(label, size: 16, color: PenColors.ink),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  PenText(subtitle!, size: 13, color: PenColors.mut),
                ],
              ],
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

/// Wraps a section's [_SettingsRow]s in one rounded card, hairline dividers
/// between rows — the grouped-list look the reference design uses for
/// "GÓI & ỨNG DỤNG" / "BẢO MẬT & ĐĂNG NHẬP".
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.rows});

  final List<_SettingsRow> rows;

  @override
  Widget build(BuildContext context) {
    return PenCard(
      axis: PenAxis.column,
      stroke: null,
      clip: true,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            const Divider(height: 1, thickness: 1, color: PenColors.line),
          rows[i],
        ],
      ],
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
    final file = path == null || path.startsWith('http') ? null : File(path);
    final hasLocalFile = file?.existsSync() ?? false;
    final image = _avatarImage(path, size: 124);
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
                onTap: hasLocalFile ? () => _showPreview(context, file!) : null,
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
                    image ??
                        const Icon(
                          LucideIcons.user,
                          size: 56,
                          color: PenColors.ink,
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
        if (hint != null) ...[
          // The design's field group carries a 9pt gap between all three of
          // label / box / caption, on top of the caption's own 4pt padding.
          const SizedBox(height: 9),
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
      // The design both tints the chosen language and doubles its border —
      // selection reads as ink, never as brand.
      strokeWidth: selected ? 2 : 1,
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

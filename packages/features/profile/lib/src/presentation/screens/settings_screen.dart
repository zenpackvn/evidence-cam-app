import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// SM-027 — "Cài đặt" (F07-S06): grouped settings (Security, Personal,
/// Notifications) plus a danger "delete account" card. Matched to
/// `pencil-new.pen` fg0364 frame by frame.
///
/// Online it renders normally; offline the [isOffline] flag shows the
/// "Đang xem ngoại tuyến" pill at the top (SM-004 BR-07). Actions are surfaced
/// as callbacks so the host wires the real flows.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.onChangePassword,
    required this.onSignOut,
    required this.onSignOutAll,
    required this.onLanguage,
    required this.onNotifications,
    required this.onDeleteAccount,
    this.languageLabel = 'Tiếng Việt',
    this.soundOn = true,
    this.onSoundChanged,
    this.isOffline = false,
    super.key,
  });

  final VoidCallback onChangePassword;
  final VoidCallback onSignOut;
  final VoidCallback onSignOutAll;
  final VoidCallback onLanguage;
  final VoidCallback onNotifications;
  final VoidCallback onDeleteAccount;
  final String languageLabel;
  final bool soundOn;
  final ValueChanged<bool>? onSoundChanged;

  /// SM-004 BR-07 — when true, the "viewing offline" notice shows at the top.
  final bool isOffline;

  static const _ground = Color(0xFFFBF1E9);
  static const _rowDivider = Color(0xFFEFE9E3);
  static const _muted = Color(0xFF716B66);
  static const _chevron = Color(0xFFAFA7A0);

  // The soft icon-chip palettes (fg0364).
  static const _pinkIcon = Color(0xFFF35B43);
  static const _pinkBg = Color(0xFFFDE8E4);
  static const _orangeIcon = Color(0xFFF47A43);
  static const _orangeBg = Color(0xFFFDF1E0);
  static const _purpleIcon = Color(0xFF8B6BD8);
  static const _purpleBg = Color(0xFFEFEAFB);
  static const _dangerIcon = Color(0xFFC93D33);
  static const _dangerChipBg = Color(0xFFFBD9D4);
  static const _dangerCardBg = Color(0xFFFDE9E7);
  static const _dangerBorder = Color(0xFFD65A51);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            if (isOffline) ...[
              const _OfflinePill(),
              const SizedBox(height: 6),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: _Header(onBack: () => Navigator.of(context).maybePop()),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  0,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                ),
                children: [
                  _Group(
                    title: 'Bảo mật',
                    rows: [
                      _Row(
                        icon: Icons.lock_outline,
                        iconColor: _pinkIcon,
                        iconBg: _pinkBg,
                        label: 'Đổi mật khẩu',
                        onTap: onChangePassword,
                      ),
                      _Row(
                        icon: Icons.logout,
                        iconColor: _orangeIcon,
                        iconBg: _orangeBg,
                        label: 'Đăng xuất',
                        onTap: onSignOut,
                      ),
                      _Row(
                        icon: Icons.devices_outlined,
                        iconColor: _purpleIcon,
                        iconBg: _purpleBg,
                        label: 'Đăng xuất tất cả thiết bị',
                        onTap: onSignOutAll,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _Group(
                    title: 'Cá nhân',
                    rows: [
                      _Row(
                        icon: Icons.language,
                        iconColor: _orangeIcon,
                        iconBg: _orangeBg,
                        label: 'Ngôn ngữ',
                        trailing: Text(
                          languageLabel,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: _muted,
                          ),
                        ),
                        onTap: onLanguage,
                      ),
                      _Row(
                        icon: Icons.volume_up_outlined,
                        iconColor: _purpleIcon,
                        iconBg: _purpleBg,
                        label: 'Âm thanh mở thư',
                        trailing: Switch(
                          value: soundOn,
                          onChanged: onSoundChanged,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _Group(
                    title: 'Thông báo',
                    rows: [
                      _Row(
                        icon: Icons.notifications_outlined,
                        iconColor: _orangeIcon,
                        iconBg: _orangeBg,
                        label: 'Cài đặt thông báo',
                        onTap: onNotifications,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // "Xoá tài khoản" stands apart in its own danger card.
                  _DangerCard(onTap: onDeleteAccount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The "Đang xem ngoại tuyến" pill (fg0368).
class _OfflinePill extends StatelessWidget {
  const _OfflinePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFBE3DC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 15, color: Color(0xFFF35B43)),
          const SizedBox(width: 8),
          Text(
            'Đang xem ngoại tuyến',
            style: context.textTheme.bodySmall?.copyWith(
              color: const Color(0xFFD94B36),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Back button, centered "Cài đặt" title (fg0364 header).
class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: context.brand.surfaceElevated,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onBack,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.chevron_left, size: 22),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Cài đặt',
              style: context.textTheme.displayMedium?.copyWith(fontSize: 22),
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }
}

/// A titled group: the section label above a white card of rows (fg0364).
class _Group extends StatelessWidget {
  const _Group({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F24211F),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              color: SettingsScreen._muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: context.brand.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: SettingsScreen._rowDivider),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: SettingsScreen._rowDivider),
                  rows[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    this.labelColor,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final Color? labelColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 19, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: labelColor ?? context.colorScheme.onSurface,
                  ),
                ),
              ),
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 4),
              ] else
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: SettingsScreen._chevron,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The standalone "Xoá tài khoản" danger card (fg0364 g-Vùng nguy hiểm).
class _DangerCard extends StatelessWidget {
  const _DangerCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F24211F),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: SettingsScreen._dangerCardBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: SettingsScreen._dangerBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: _Row(
          icon: Icons.delete_outline,
          iconColor: SettingsScreen._dangerIcon,
          iconBg: SettingsScreen._dangerChipBg,
          label: 'Xoá tài khoản',
          labelColor: SettingsScreen._dangerIcon,
          onTap: onTap,
        ),
      ),
    );
  }
}

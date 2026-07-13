import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// SM-027 — "Cài đặt" (F07-S06): grouped settings (Security, Personal, Privacy).
/// Actions are surfaced as callbacks so the host wires the real flows (change
/// password, sign out, language, delete account). The "letter open sound" toggle
/// is local state persisted by the host.
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

  static const _ground = Color(0xFFFBF1E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Cài đặt',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            _Group(
              title: 'Bảo mật',
              children: [
                _Row(
                  icon: Icons.lock_outline,
                  label: 'Đổi mật khẩu',
                  onTap: onChangePassword,
                ),
                _Row(
                  icon: Icons.logout,
                  label: 'Đăng xuất',
                  onTap: onSignOut,
                ),
                _Row(
                  icon: Icons.devices_outlined,
                  label: 'Đăng xuất tất cả thiết bị',
                  onTap: onSignOutAll,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _Group(
              title: 'Cá nhân',
              children: [
                _Row(
                  icon: Icons.language,
                  label: 'Ngôn ngữ',
                  trailing: Text(
                    languageLabel,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: onLanguage,
                ),
                _Row(
                  icon: Icons.volume_up_outlined,
                  label: 'Âm thanh mở thư',
                  trailing: Switch(
                    value: soundOn,
                    onChanged: onSoundChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _Group(
              title: 'Quyền riêng tư',
              children: [
                _Row(
                  icon: Icons.notifications_outlined,
                  label: 'Cài đặt thông báo',
                  onTap: onNotifications,
                ),
                _Row(
                  icon: Icons.delete_outline,
                  label: 'Xoá tài khoản',
                  danger: true,
                  onTap: onDeleteAccount,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            title,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final color = danger ? scheme.error : scheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: danger ? scheme.error : scheme.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyLarge?.copyWith(color: color),
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

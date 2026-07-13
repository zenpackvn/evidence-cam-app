import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

/// SM-024 — "Hồ sơ" (F07-S01 Free / F07-S02 Premium): the user's profile with
/// avatar, name/handle, plan badge, an edit action, a bio, the Premium upsell
/// card (hidden for Premium users), and a Settings entry.
class StampMailProfileScreen extends StatelessWidget {
  const StampMailProfileScreen({
    required this.onEditProfile,
    required this.onOpenSettings,
    required this.onUpgrade,
    this.isPremium = false,
    super.key,
  });

  final bool isPremium;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onUpgrade;

  static const _ground = Color(0xFFFBF1E9);

  @override
  Widget build(BuildContext context) {
    final user = SessionScope.of(context).currentUser;
    return Scaffold(
      backgroundColor: _ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            Text(
              'Hồ sơ',
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _ProfileHeader(
              username: user?.username ?? 'Bạn',
              isPremium: isPremium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _EditButton(onTap: onEditProfile),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Yêu chụp ảnh, sưu tập tem và viết thư cho bạn bè.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (!isPremium) ...[
              _PremiumCard(onUpgrade: onUpgrade),
              const SizedBox(height: AppSpacing.lg),
            ],
            _SettingsButton(onTap: onOpenSettings),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.username, required this.isPremium});

  final String username;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: scheme.primaryContainer,
          child: Icon(Icons.person, size: 36, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '@$username',
                style: context.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _PlanBadge(isPremium: isPremium),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isPremium
            ? const Color(0xFFFEF6E3)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium ? Icons.workspace_premium : Icons.check_circle_outline,
            size: 14,
            color: isPremium ? const Color(0xFFF5BC58) : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            isPremium ? 'Premium' : 'Miễn phí',
            style: context.textTheme.labelSmall?.copyWith(
              color: isPremium
                  ? const Color(0xFFB8860B)
                  : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: const Text('Sửa hồ sơ'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.onUpgrade});

  final VoidCallback onUpgrade;

  static const List<(IconData, String)> _features = [
    (Icons.all_inclusive, 'Gửi không giới hạn'),
    (Icons.mail_lock_outlined, 'Lưu tem vô hạn'),
    (Icons.auto_awesome, 'Sticker cao cấp'),
    (Icons.star_outline, 'Ưu tiên hỗ trợ'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EF),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: Color(0xFFF5BC58)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'StampMail Premium',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tạo, gửi và lưu mọi kỷ niệm không giới hạn.',
            style: context.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (icon, label) in _features)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: scheme.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(label, style: context.textTheme.labelSmall),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onUpgrade,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Nâng cấp Premium'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(Icons.settings_outlined, color: scheme.onSurface),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Cài đặt',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

/// SM-024 — "Hồ sơ" (F07-S01 Free / F07-S02 Premium): the user's profile with
/// avatar, name/handle, plan badge, an edit action, a bio, the Premium upsell
/// card (hidden for Premium users), and a Settings entry. Matched to
/// `pencil-new.pen` fg0010 frame by frame.
class StampMailProfileScreen extends StatelessWidget {
  const StampMailProfileScreen({
    required this.onEditProfile,
    required this.onOpenSettings,
    required this.onUpgrade,
    this.isPremium = false,
    this.premiumExpiry,
    this.onManagePlan,
    this.avatarUrl,
    this.avatarBytes,
    this.isSavingAvatar = false,
    this.onEditAvatar,
    this.name,
    this.username,
    super.key,
  });

  /// The saved profile's display name and handle (from SM-024). When null the
  /// screen falls back to the session user's username — so an edit shows here
  /// the moment the host reloads the profile.
  final String? name;
  final String? username;

  /// The current avatar's URL (empty/null shows the placeholder). Tapping the
  /// camera badge runs [onEditAvatar] — pick → crop (F07-S04) → upload → save.
  final String? avatarUrl;

  /// A just-cropped avatar shown immediately (optimistic), before/independent of
  /// the upload landing; takes precedence over [avatarUrl].
  final Uint8List? avatarBytes;
  final bool isSavingAvatar;
  final VoidCallback? onEditAvatar;

  final bool isPremium;

  /// SM-024 BR-10 / AC-12: when the user is Premium, the plan's expiry date is
  /// shown next to the "Premium" badge. Sourced from SM-029 (managed by the
  /// host); `null` renders the badge without a date.
  final DateTime? premiumExpiry;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onUpgrade;

  /// SM-029 — "Quản lý gói" on the Premium card (F07-S02); falls back to
  /// [onUpgrade] when the host hasn't wired a dedicated manage flow.
  final VoidCallback? onManagePlan;

  static const _ground = Color(0xFFFBF1E9);
  static const _border = Color(0xFFDED6CF);
  // Premium badge palette (fg0110 pill / expiry).
  static const _goldIcon = Color(0xFFE9A23B);
  static const _goldText = Color(0xFFB07C2A);

  @override
  Widget build(BuildContext context) {
    final sessionName = (SessionScope.of(context).currentUser?.username ?? '')
        .trim();
    final resolvedName = (name ?? '').trim().isNotEmpty
        ? name!.trim()
        : sessionName;
    final resolvedHandle = (username ?? sessionName).trim();
    return Scaffold(
      backgroundColor: _ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            14,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          children: [
            Center(
              child: Text(
                'Hồ sơ',
                style: context.textTheme.displayMedium?.copyWith(fontSize: 22),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _ProfileCard(
              name: resolvedName,
              username: resolvedHandle,
              isPremium: isPremium,
              premiumExpiry: premiumExpiry,
              onEditProfile: onEditProfile,
              avatarUrl: avatarUrl,
              avatarBytes: avatarBytes,
              isSavingAvatar: isSavingAvatar,
              onEditAvatar: onEditAvatar ?? onEditProfile,
            ),
            const SizedBox(height: AppSpacing.md),
            const _BioCard(
              text: 'Yêu chụp ảnh, sưu tập tem và viết thư cho bạn bè.',
            ),
            const SizedBox(height: AppSpacing.md),
            if (isPremium)
              _PremiumManageCard(onManage: onManagePlan ?? onUpgrade)
            else
              _PremiumCard(onUpgrade: onUpgrade),
            const SizedBox(height: AppSpacing.md),
            _OutlineButton(
              icon: Icons.settings_outlined,
              label: 'Cài đặt',
              onTap: onOpenSettings,
            ),
          ],
        ),
      ),
    );
  }
}

/// The white profile card: avatar (with a camera edit badge), name/handle, the
/// plan badge, and the "Sửa hồ sơ" button.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.username,
    required this.isPremium,
    required this.premiumExpiry,
    required this.onEditProfile,
    required this.avatarUrl,
    required this.avatarBytes,
    required this.isSavingAvatar,
    required this.onEditAvatar,
  });

  final String name;
  final String username;
  final bool isPremium;
  final DateTime? premiumExpiry;
  final VoidCallback onEditProfile;
  final String? avatarUrl;
  final Uint8List? avatarBytes;
  final bool isSavingAvatar;
  final VoidCallback onEditAvatar;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    // Empty name (account with no handle yet) falls back to "Bạn"; the lone
    // "@" handle line is hidden when there is no username.
    final displayName = name.isEmpty ? 'Bạn' : name;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1424211F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(
                avatarUrl: avatarUrl,
                avatarBytes: avatarBytes,
                isSaving: isSavingAvatar,
                onTap: onEditAvatar,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (username.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '@$username',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    _PlanBadge(isPremium: isPremium),
                    // SM-024 BR-10 / AC-12: Premium shows the plan's expiry.
                    if (isPremium && premiumExpiry != null) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 14,
                            color: StampMailProfileScreen._goldText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Hết hạn ${_formatDate(premiumExpiry!)}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: StampMailProfileScreen._goldText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _OutlineButton(
            icon: Icons.edit_outlined,
            label: 'Sửa hồ sơ',
            onTap: onEditProfile,
          ),
        ],
      ),
    );
  }

  /// Formats an expiry date as `dd/MM/yyyy` without pulling in `intl`, matching
  /// the app's Vietnamese date convention.
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

/// Circular avatar with a coral camera badge; tapping runs the pick → crop →
/// save flow. The badge becomes a spinner while the new avatar uploads.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.avatarUrl,
    required this.avatarBytes,
    required this.isSaving,
    required this.onTap,
  });

  final String? avatarUrl;
  final Uint8List? avatarBytes;
  final bool isSaving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final url = avatarUrl ?? '';
    final bytes = avatarBytes;
    return GestureDetector(
      onTap: isSaving ? null : onTap,
      child: SizedBox(
        width: 88,
        height: 88,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 84,
              height: 84,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primaryContainer,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: bytes != null
                  ? Image.memory(
                      bytes,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                    )
                  : url.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 40,
                      color: scheme.onPrimaryContainer,
                    )
                  : AppNetworkImage(imageUrl: url, width: 84, height: 84),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    if (isPremium) {
      // fg0110 pill: gold gradient, crown + "Premium" + sparkles.
      return Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFDEDC5), Color(0xFFF8DFA0)],
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFF5C664)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.workspace_premium,
              size: 15,
              color: StampMailProfileScreen._goldIcon,
            ),
            const SizedBox(width: 6),
            Text(
              'Premium',
              style: context.textTheme.bodyMedium?.copyWith(
                color: StampMailProfileScreen._goldText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.auto_awesome,
              size: 12,
              color: StampMailProfileScreen._goldIcon,
            ),
          ],
        ),
      );
    }
    // fg0010 pill: soft-pink, sparkles + "Miễn phí".
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8EC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 14, color: scheme.primary),
          const SizedBox(width: 5),
          Text(
            'Miễn phí',
            style: context.textTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// The one-line bio card (fg0059): a heart glyph and the bio text.
class _BioCard extends StatelessWidget {
  const _BioCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F24211F),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('❤️', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: context.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

/// A white, outlined pill button (edit / settings) — fg0009 / kyqle.
class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.brand.surfaceElevated,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: StampMailProfileScreen._border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: context.colorScheme.onSurface),
              const SizedBox(width: 8),
              Text(
                label,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// SM-024 BR-11 — the Premium upsell card (fg0010 premCard): a warm gradient
/// panel with a crown seal, the benefit grid, and the gradient CTA.
class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.onUpgrade});

  final VoidCallback onUpgrade;

  static const _titleColor = Color(0xFF3A241B);
  static const _benefitIcon = Color(0xFFD94B36);

  static const List<(IconData, String)> _benefits = [
    (Icons.mark_email_unread_outlined, 'Gửi không giới hạn'),
    (Icons.collections_outlined, 'Lưu tem vô hạn'),
    (Icons.auto_awesome, 'Sticker cao cấp'),
    (Icons.verified_outlined, 'Ưu tiên hỗ trợ'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7DC), Color(0xFFFFE3B8), Color(0xFFFFC0A7)],
          stops: [0, 0.46, 1],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xB3FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x248A2A1A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero: crown seal + title/PRO pill + subtitle.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CrownSeal(),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'StampMail Premium',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.displayMedium?.copyWith(
                              fontSize: 21,
                              color: _titleColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xB8FFFFFF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'PRO',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: _benefitIcon,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Tạo, gửi và lưu mọi kỷ niệm không giới hạn',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6C4332),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Benefit grid: two rows of two pills.
          Row(
            children: [
              Expanded(child: _BenefitPill(_benefits[0])),
              const SizedBox(width: 8),
              Expanded(child: _BenefitPill(_benefits[1])),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _BenefitPill(_benefits[2])),
              const SizedBox(width: 8),
              Expanded(child: _BenefitPill(_benefits[3])),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PremiumCta(
            onTap: onUpgrade,
            icon: Icons.auto_awesome,
            title: 'Nâng cấp Premium',
            subtitle: 'Mở toàn bộ tính năng',
          ),
        ],
      ),
    );
  }
}

/// SM-029 — the Premium *manage* card (fg0110 premiumManageCard): shown to
/// Premium users in place of the upsell. Same warm gradient panel, but it
/// confirms the plan is active and offers "Quản lý gói".
class _PremiumManageCard extends StatelessWidget {
  const _PremiumManageCard({required this.onManage});

  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7DC), Color(0xFFFFE3B8), Color(0xFFFFC0A7)],
          stops: [0, 0.46, 1],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xB3FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x248A2A1A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CrownSeal(),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Gói Premium',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.displayMedium?.copyWith(
                              fontSize: 21,
                              color: _PremiumCard._titleColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xB8FFFFFF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 12,
                                color: _PremiumCard._benefitIcon,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ĐANG DÙNG',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: _PremiumCard._benefitIcon,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Không giới hạn thư, tem và bộ trang trí',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6C4332),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _BenefitPill((
            Icons.auto_awesome,
            'Tất cả tính năng Premium đã mở khoá',
          )),
          const SizedBox(height: AppSpacing.md),
          _PremiumCta(
            onTap: onManage,
            icon: Icons.settings,
            title: 'Quản lý gói',
            subtitle: 'Gia hạn, hoá đơn và huỷ gói',
          ),
        ],
      ),
    );
  }
}

/// The crown seal used on both Premium cards (fg0010 / fg0110).
class _CrownSeal extends StatelessWidget {
  const _CrownSeal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF6C95C), Color(0xFFF35B43)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x38D94B36),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.workspace_premium,
        size: 27,
        color: Colors.white,
      ),
    );
  }
}

class _BenefitPill extends StatelessWidget {
  const _BenefitPill(this.data);

  final (IconData, String) data;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = data;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xB8FFFFFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _PremiumCard._benefitIcon),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: _PremiumCard._titleColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The gradient call-to-action on the Premium card — "Nâng cấp Premium"
/// (fg0010) or "Quản lý gói" (fg0110).
class _PremiumCta extends StatelessWidget {
  const _PremiumCta({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF7656),
                Color(0xFFF35B43),
                Color(0xFFD94B36),
              ],
              stops: [0, 0.48, 1],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3FB33325),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x2EFFFFFF),
                ),
                child: Icon(icon, size: 21, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: const Color(0xD9FFFFFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Color(0xFFD94B36),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

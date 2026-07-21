import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/services/letter_share.dart';

/// SM-016 success (F03-S12) — "Gửi thành công": confirms the share link(s) were
/// created (with their one-time / 7-day rules) and offers to track the letter,
/// write another, or go home.
///
/// Everything the screen states reflects what was actually sent — the platform
/// pills, the "N nền tảng"/"N liên kết" counts, and the letter/stamp summary all
/// come from [platforms], [letterTitle] and [stampName]; nothing is hard-coded.
class SendSuccessScreen extends StatelessWidget {
  const SendSuccessScreen({
    required this.linkUrl,
    required this.platforms,
    required this.onDone,
    this.letterTitle,
    this.stampName,
    this.stampImageUrl,
    this.onNewLetter,
    this.onHome,
    super.key,
  });

  /// The minted link (kept so the host can copy/share it); no longer shown as a
  /// chip — the design surfaces the platform pills instead.
  final String linkUrl;

  /// The platform(s) the letter was actually sent to, in the order picked.
  final List<SharePlatform> platforms;

  /// The letter's template label and the attached stamp, for the summary row.
  final String? letterTitle;
  final String? stampName;
  final String? stampImageUrl;

  /// Primary action — "Theo dõi thư".
  final VoidCallback onDone;

  /// "Tạo thư mới" / "Về Trang chủ"; both fall back to [onDone].
  final VoidCallback? onNewLetter;
  final VoidCallback? onHome;

  static const _ground = Color(0xFFFBF5EC);
  static const _heroFill = Color(0xFFFFF4EF);
  static const _heroStroke = Color(0xFFEFE9E3);
  static const _package = 'feature_letters';

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final home = onHome ?? onDone;
    final count = platforms.length;
    final subtitle = count <= 1
        ? 'Thư của bạn đã sẵn sàng để gửi đi.'
        : 'Thư của bạn đã sẵn sàng trên $count nền tảng.';
    final heroTitle = count <= 1
        ? 'Đã tạo liên kết thành công!'
        : 'Đã tạo $count liên kết thành công!';
    return Scaffold(
      backgroundColor: _ground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: context.brand.surfaceElevated,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: home,
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(Icons.chevron_left, size: 22),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                children: [
                  Text(
                    'Gửi thành công',
                    style: context.textTheme.displayMedium?.copyWith(
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Hero card: success illustration, count, and a pill per
                  // platform the letter went to.
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: _heroFill,
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      border: Border.all(color: _heroStroke),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/platforms/f3-success-hero.png',
                            package: _package,
                            fit: BoxFit.contain,
                            excludeFromSemantics: true,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          heroTitle,
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final p in platforms)
                              _PlatformPill(platform: p),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Rules card — one two-line feature row per link rule.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: context.brand.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F24211F),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        _FeatureRow(
                          icon: Icons.lock_outline,
                          title: 'Link chỉ mở 1 lần',
                          desc: 'Người đầu tiên mở link sẽ nhận thư.',
                        ),
                        SizedBox(height: AppSpacing.sm),
                        _FeatureRow(
                          icon: Icons.calendar_month_outlined,
                          title: 'Hiệu lực 7 ngày',
                          desc: 'Liên kết tự hết hạn sau 7 ngày.',
                        ),
                        SizedBox(height: AppSpacing.sm),
                        _FeatureRow(
                          icon: Icons.notifications_none,
                          title: 'Thông báo khi đã đọc',
                          desc: 'Báo ngay khi người nhận mở thư.',
                        ),
                      ],
                    ),
                  ),
                  if (letterTitle != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _SummaryRow(
                      letterTitle: letterTitle!,
                      stampName: stampName,
                      stampImageUrl: stampImageUrl,
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: onDone,
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        shape: const StadiumBorder(),
                        textStyle: context.textTheme.titleMedium,
                      ),
                      icon: const Icon(Icons.send, size: 20),
                      label: const Text('Theo dõi thư'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: onNewLetter ?? onDone,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.primary,
                        backgroundColor: context.brand.surfaceElevated,
                        side: BorderSide(color: scheme.primary, width: 1.5),
                        shape: const StadiumBorder(),
                        textStyle: context.textTheme.titleMedium,
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Tạo thư mới'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: home,
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.onSurface,
                      textStyle: context.textTheme.titleMedium,
                    ),
                    child: const Text('Về Trang chủ 🌿'),
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

/// A single platform chip (logo + name), matching the `.pen` PlatformPill.
class _PlatformPill extends StatelessWidget {
  const _PlatformPill({required this.platform});

  final SharePlatform platform;

  static const _package = 'feature_letters';

  @override
  Widget build(BuildContext context) {
    final (label, asset) = _platformMeta(platform);
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F24211F),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset(
              'assets/platforms/$asset',
              package: _package,
              width: 20,
              height: 20,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// The label + brand-logo asset for each platform (matches the send screen's
/// grid order, SM-016 AC-07).
(String, String) _platformMeta(SharePlatform platform) => switch (platform) {
  SharePlatform.messenger => ('Messenger', 'f3-pf-1c.png'),
  SharePlatform.instagram => ('Instagram DM', 'f3-pf-2c.png'),
  SharePlatform.tiktok => ('TikTok DM', 'f3-pf-3c.png'),
  SharePlatform.threads => ('Threads', 'f3-pf-4c.png'),
  SharePlatform.zalo => ('Zalo', 'f3-pf-5c.png'),
  SharePlatform.whatsapp => ('WhatsApp', 'f3-pf-6c.png'),
  SharePlatform.imessage => ('iMessage', 'f3-pf-7c.png'),
  SharePlatform.twitter => ('X / Twitter', 'f3-pf-8c.png'),
};

/// A two-line rule row: a rounded icon tile, a bold title and a muted blurb.
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.brand.softPeach,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: scheme.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                desc,
                style: context.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The letter/stamp summary row: a thumbnail, "Thư: …" / "Tem: …", and a
/// chevron hinting the letter can be opened from the tracker.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.letterTitle,
    required this.stampName,
    required this.stampImageUrl,
  });

  final String letterTitle;
  final String? stampName;
  final String? stampImageUrl;

  static const _package = 'feature_letters';

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final image = stampImageUrl;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 46,
              child: image != null && image.isNotEmpty
                  ? Image.network(image, fit: BoxFit.cover)
                  : Image.asset(
                      'assets/platforms/f3-summary-stamp.png',
                      package: _package,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LabelledValue(label: 'Thư:', value: letterTitle),
                _LabelledValue(
                  label: 'Tem:',
                  value: stampName ?? 'Chưa dán tem',
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _LabelledValue extends StatelessWidget {
  const _LabelledValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// SM-016 success (F03-S12) — "Gửi thành công": confirms the share link was
/// created (with its one-time / 7-day rules) and offers to track the letter,
/// write another, or go home. The link is shown so the sender can copy it if
/// the DM didn't open.
class SendSuccessScreen extends StatelessWidget {
  const SendSuccessScreen({
    required this.linkUrl,
    required this.onDone,
    this.onCopy,
    this.onNewLetter,
    this.onHome,
    super.key,
  });

  final String linkUrl;

  /// Primary action — "Theo dõi thư".
  final VoidCallback onDone;
  final VoidCallback? onCopy;

  /// "Tạo thư mới" / "Về Trang chủ"; both fall back to [onDone].
  final VoidCallback? onNewLetter;
  final VoidCallback? onHome;

  static const _ground = Color(0xFFFBF5EC);
  static const _package = 'feature_letters';

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final home = onHome ?? onDone;
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
                    'Thư của bạn đã sẵn sàng để gửi đi.',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Hero card: success illustration + link chip to copy.
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: context.brand.softPeach,
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
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
                          'Đã tạo liên kết thành công!',
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _LinkChip(url: linkUrl, onCopy: onCopy),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Rules card.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: context.brand.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: const Column(
                      children: [
                        _InfoRow(
                          icon: Icons.check_circle_outline,
                          text: 'Link chỉ mở được 1 lần.',
                        ),
                        SizedBox(height: 10),
                        _InfoRow(
                          icon: Icons.schedule_outlined,
                          text: 'Hiệu lực trong 7 ngày.',
                        ),
                        SizedBox(height: 10),
                        _InfoRow(
                          icon: Icons.notifications_none,
                          text: 'Thông báo khi người nhận đã đọc.',
                        ),
                      ],
                    ),
                  ),
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
                        side: BorderSide(color: context.brand.borderSubtle),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(text, style: context.textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({required this.url, this.onCopy});

  final String url;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.brand.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          IconButton(
            onPressed: onCopy,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.copy, size: 18, color: scheme.primary),
          ),
        ],
      ),
    );
  }
}

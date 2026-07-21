import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/stamp_draft.dart';
import '../widgets/creator_theme.dart';
import '../widgets/stamp_frame.dart';

/// SM-011 — the "Đã đạt giới hạn 30 tem/tháng" modal (F02-S13), shown when a Free
/// user's save is rejected for hitting the monthly quota (403). A dimmed stamp
/// hero behind a centred card with a star badge, an upgrade CTA and a dismiss.
Future<void> showQuotaReachedSheet(
  BuildContext context, {
  StampDraft? draft,
  VoidCallback? onUpgrade,
}) {
  return Navigator.of(context).push<void>(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black26,
      pageBuilder: (_, _, _) =>
          QuotaReachedSheet(draft: draft, onUpgrade: onUpgrade),
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    ),
  );
}

class QuotaReachedSheet extends StatelessWidget {
  const QuotaReachedSheet({this.draft, this.onUpgrade, super.key});

  final StampDraft? draft;
  final VoidCallback? onUpgrade;

  void _upgrade(BuildContext context) {
    final onUpgrade = this.onUpgrade;
    Navigator.of(context).maybePop();
    if (onUpgrade != null) {
      onUpgrade();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tính năng Premium sắp ra mắt ✨')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final draft = this.draft;
    return Scaffold(
      backgroundColor: CreatorColors.ground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxxl,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Đã đạt giới hạn 30 tem/tháng',
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Tài khoản miễn phí được lưu tối đa 30 tem mỗi tháng.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.47,
                        ),
                      ),
                    ],
                  ),
                ),
                if (draft != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Opacity(
                    opacity: 0.35,
                    child: SizedBox(
                      width: 170,
                      child: StampFrame(draft: draft),
                    ),
                  ),
                ],
                const Spacer(),
                _Modal(onUpgrade: () => _upgrade(context)),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Modal extends StatelessWidget {
  const _Modal({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 28),
            decoration: BoxDecoration(
              color: context.brand.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2924211F),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bạn đã đạt giới hạn 30 tem trong tháng này.',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    height: 1.47,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Hãy đợi đến đầu tháng sau hoặc nâng cấp Premium '
                  'để lưu không giới hạn.',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.47,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _UpgradeButton(onTap: onUpgrade),
                const SizedBox(height: AppSpacing.md),
                _LaterButton(
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '✨ Premium: lưu tem không giới hạn',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // The star badge overlapping the card's top edge.
          const Positioned(top: -38, child: _StarBadge()),
        ],
      ),
    );
  }
}

class _StarBadge extends StatelessWidget {
  const _StarBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3E6),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2924211F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.star_rounded,
        size: 40,
        color: context.colorScheme.primary,
      ),
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 18,
                  color: Color(0xFFFFE1A8),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Nâng cấp Premium',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LaterButton extends StatelessWidget {
  const _LaterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: scheme.primary, width: 1.5),
            ),
            child: Text(
              'Để tháng sau',
              style: context.textTheme.titleMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

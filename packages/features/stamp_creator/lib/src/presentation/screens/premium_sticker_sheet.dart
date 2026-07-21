import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/stamp_draft.dart';
import '../widgets/creator_theme.dart';
import '../widgets/stamp_frame.dart';

/// A premium sticker pack shown on the unlock sheet: a labelled header and four
/// preview glyphs.
typedef _Pack = ({String name, List<String> stickers});

const List<_Pack> _packs = [
  (name: '🍃 Mùa', stickers: ['🌸', '🍁', '❄️', '🌻']),
  (name: '💗 Cảm xúc', stickers: ['😊', '😍', '😂', '😭']),
  (name: '✈️ Du lịch', stickers: ['🧳', '✈️', '🌴', '📷']),
];

/// SM-009 — the "Mở sticker đặc biệt" upsell (F02-S12): a dimmed stamp hero with
/// a floating sheet that lets a Free user pick a premium sticker pack to unlock
/// and upgrade to Premium. Push it over the decorate step; tapping outside the
/// sheet or system-back dismisses it.
Future<void> showPremiumStickerSheet(
  BuildContext context, {
  StampDraft? draft,
  VoidCallback? onUpgrade,
}) {
  return Navigator.of(context).push<void>(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black26,
      pageBuilder: (_, _, _) =>
          PremiumStickerSheet(draft: draft, onUpgrade: onUpgrade),
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    ),
  );
}

class PremiumStickerSheet extends StatefulWidget {
  const PremiumStickerSheet({this.draft, this.onUpgrade, super.key});

  final StampDraft? draft;
  final VoidCallback? onUpgrade;

  @override
  State<PremiumStickerSheet> createState() => _PremiumStickerSheetState();
}

class _PremiumStickerSheetState extends State<PremiumStickerSheet> {
  int _selected = 0;

  void _upgrade() {
    final onUpgrade = widget.onUpgrade;
    if (onUpgrade != null) {
      onUpgrade();
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng Premium sắp ra mắt ✨')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final draft = widget.draft;
    return Scaffold(
      backgroundColor: CreatorColors.ground,
      body: SafeArea(
        child: Stack(
          children: [
            // Tapping the dimmed area (anywhere outside the sheet) dismisses.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: AppSpacing.xxxxl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxxxl,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Mở sticker đặc biệt',
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Mở khóa các bộ sticker cao cấp\n'
                        'để trang trí tem sinh động hơn.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.47,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // The dimmed decorated-stamp hero behind the sheet.
                if (draft != null)
                  Opacity(
                    opacity: 0.45,
                    child: SizedBox(
                      width: 180,
                      child: StampFrame(draft: draft),
                    ),
                  ),
                const Spacer(),
                _Sheet(
                  selected: _selected,
                  onSelect: (i) => setState(() => _selected = i),
                  onUpgrade: _upgrade,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.selected,
    required this.onSelect,
    required this.onUpgrade,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
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
            'Chọn bộ sticker bạn muốn mở khóa',
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, pack) in _packs.indexed) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _PackCard(
                      pack: pack,
                      selected: i == selected,
                      onTap: () => onSelect(i),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _UpgradeButton(onTap: onUpgrade),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '✨ Bộ sticker sẽ được mở khóa vĩnh viễn.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({
    required this.pack,
    required this.selected,
    required this.onTap,
  });

  static const _softCoral = Color(0xFFFCEEE9);
  static const _border = Color(0xFFEFE6DA);

  final _Pack pack;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? _softCoral : context.brand.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: selected ? scheme.primary : _border,
            width: selected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pack.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${pack.stickers[0]} ${pack.stickers[1]}',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 2),
            Text(
              '${pack.stickers[2]} ${pack.stickers[3]}',
              style: const TextStyle(fontSize: 22),
            ),
          ],
        ),
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
            height: 52,
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

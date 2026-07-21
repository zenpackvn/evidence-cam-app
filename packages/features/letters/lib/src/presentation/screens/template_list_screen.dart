import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../composer_catalog.dart';
import 'template_preview_screen.dart';

/// SM-012 — "Danh sách template" (F03-S01): pick a letter template to start
/// composing. Tapping any card opens the full preview first (BR-04): Free
/// templates preview with a "Dùng template này" CTA, Premium ones show the same
/// full preview with a lock and an upgrade CTA instead (BR-03).
///
/// When [replyToName] is set the screen is entered as a reply (SM-020): the
/// original sender is shown as the recipient so the user doesn't re-enter it
/// (BR-01).
class TemplateListScreen extends StatelessWidget {
  const TemplateListScreen({
    required this.onPick,
    this.isPremium = false,
    this.replyToName,
    this.onUpgrade,
    super.key,
  });

  final ValueChanged<LetterTemplate> onPick;
  final bool isPremium;

  /// The original sender's name when composing a reply (SM-020 BR-01).
  final String? replyToName;

  /// Routes to the Premium upgrade screen (SM-028) when a Free user confirms a
  /// locked template's preview (BR-03). No-op when null.
  final VoidCallback? onUpgrade;

  static const _ground = Color(0xFFFBF5EC);

  /// SM-012 BR-04/AC-02..03/AC-07: open the full preview for [index]. Free →
  /// "Dùng template này" starts composing; Premium (locked for a Free user) →
  /// full preview with an upgrade CTA that routes to SM-028.
  void _openPreview(BuildContext context, int index) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TemplatePreviewScreen(
          templates: letterTemplates,
          initialIndex: index,
          isPremium: isPremium,
          onUse: (template) {
            Navigator.of(context).pop();
            onPick(template);
          },
          onUpgrade: onUpgrade == null
              ? null
              : () {
                  Navigator.of(context).pop();
                  onUpgrade!.call();
                },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isReply = replyToName != null && replyToName!.isNotEmpty;
    // Split the catalog into the Free grid and the Premium row (F03-S01),
    // keeping each template's global index for the preview route.
    final free = <({int index, LetterTemplate template})>[];
    final premium = <({int index, LetterTemplate template})>[];
    for (final (i, t) in letterTemplates.indexed) {
      (t.premium ? premium : free).add((index: i, template: t));
    }
    // .pen F03-S01: back button, "Chọn template" 32px, a search row, the
    // category chips, then the template grid. (The .pen also draws the app tab
    // bar, but this is a pushed sub-screen with a back button, so it is omitted.)
    return Scaffold(
      backgroundColor: _ground,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/illustrations/f3-decor-tr-c.png',
                package: 'feature_letters',
                width: 144,
                excludeFromSemantics: true,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CircleButton(
                        icon: Icons.chevron_left,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isReply ? 'Trả lời' : 'Chọn template',
                        style: context.textTheme.displayMedium?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isReply)
                        Text(
                          'Gửi tới $replyToName',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: 10),
                      const _SearchRow(),
                      const SizedBox(height: 10),
                      const _CategoryChips(),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.md,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(title: 'Miễn phí'),
                        const SizedBox(height: AppSpacing.sm),
                        // The art is a landscape card (166×117) with the name and
                        // FREE badge baked in; match its ratio so nothing (esp.
                        // the title below) is cropped.
                        _TemplateGrid(
                          entries: free,
                          crossAxisCount: 2,
                          aspectRatio: 166 / 117,
                          onOpen: (i) => _openPreview(context, i),
                        ),
                        if (premium.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          const _SectionHeader(title: 'Premium 👑'),
                          const SizedBox(height: AppSpacing.sm),
                          // Premium cards are the smaller 108×65 art (crown + lock
                          // baked in), three to a row.
                          _TemplateGrid(
                            entries: premium,
                            crossAxisCount: 3,
                            aspectRatio: 108 / 65,
                            onOpen: (i) => _openPreview(context, i),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A round pill button (`.pen` `cbtn`): surface-elevated with a centered icon.
class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.brand.surfaceElevated,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: 22,
            color: iconColor ?? context.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// The search field + filter button (`.pen` searchRow). ponytail: visual only —
/// the catalog is 6 items, so wire filtering when it grows.
class _SearchRow extends StatelessWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: ShapeDecoration(
              color: context.brand.surfaceElevated,
              shape: const StadiumBorder(),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Tìm template',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _CircleButton(
          icon: Icons.tune,
          size: 46,
          iconColor: scheme.primary,
          onTap: () {},
        ),
      ],
    );
  }
}

/// The category filter chips (`.pen` chips, `Content/FilterChip`). ponytail:
/// visual only for now — "Tất cả" is the active state.
class _CategoryChips extends StatelessWidget {
  const _CategoryChips();

  static const _labels = [
    'Tất cả',
    'Sinh nhật',
    'Tình yêu',
    'Cảm ơn',
    'Chúc mừng',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final active = i == 0;
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: ShapeDecoration(
              color: active ? scheme.primary : context.brand.surfaceElevated,
              shape: StadiumBorder(
                side: active
                    ? BorderSide.none
                    : BorderSide(color: scheme.outlineVariant),
              ),
            ),
            child: Text(
              _labels[i],
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: active ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A section header (`.pen` `cSecHeader`): the title on the left and a "Xem tất
/// cả" affordance on the right. The catalog shows every template already, so the
/// link is a visual match for F03-S01 rather than a navigation.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          'Xem tất cả',
          style: context.textTheme.bodyMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Icon(Icons.chevron_right, size: 18, color: scheme.primary),
      ],
    );
  }
}

/// A non-scrolling grid of template cards for a section (Free or Premium).
class _TemplateGrid extends StatelessWidget {
  const _TemplateGrid({
    required this.entries,
    required this.crossAxisCount,
    required this.aspectRatio,
    required this.onOpen,
  });

  final List<({int index, LetterTemplate template})> entries;
  final int crossAxisCount;
  final double aspectRatio;

  /// Called with the template's global index in [letterTemplates].
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: aspectRatio,
      ),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final entry = entries[i];
        return _TemplateCard(
          key: ValueKey('template-${entry.template.id}'),
          template: entry.template,
          // The lock/crown is baked into the Premium art, so no overlay.
          locked: false,
          onTap: () => onOpen(entry.index),
        );
      },
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.locked,
    required this.onTap,
    super.key,
  });

  final LetterTemplate template;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    // The .pen card shows no visible label (the name is baked into the art),
    // so the template name lives in the accessible name instead.
    return Semantics(
      label: template.label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Color(template.paperColor),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F24211F),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (template.artAsset != null)
                // The art already carries the name, sample text and FREE badge
                // (F03-S01); show it whole so the title below is never cut.
                Image.asset(template.artAsset!, fit: BoxFit.cover)
              else
                Center(
                  child: Icon(
                    Icons.mail_outline,
                    size: 40,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
              if (locked)
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: Icon(Icons.lock, size: 18, color: scheme.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

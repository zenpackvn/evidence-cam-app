import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// One onboarding page's content. Immutable; the screen owns the list.
@immutable
class OnboardingStepData {
  const OnboardingStepData({
    required this.title,
    required this.description,
    required this.heroAsset,
    this.showFilters = false,
  });

  final String title;
  final String description;

  /// Illustration filename under `assets/illustrations/`.
  final String heroAsset;

  /// Whether to show the demo filter chip row beneath the hero (slide 1).
  final bool showFilters;
}

/// Renders a single onboarding page: a hero illustration, an optional filter
/// chip row, a large rounded title, and a supporting description.
class OnboardingStep extends StatelessWidget {
  const OnboardingStep({required this.data, super.key});

  final OnboardingStepData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const StampMailBrandmark(),
          // .pen F01-S02 flow gaps: brand→hero 14, hero→filter 18,
          // filter→title 20, title→body 10.
          const SizedBox(height: 14),
          Image.asset(
            'assets/illustrations/${data.heroAsset}',
            package: 'feature_onboarding',
            width: 357,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ).animateScale(),
          if (data.showFilters) ...[
            const SizedBox(height: 18),
            const _FilterRow(),
          ],
          const SizedBox(height: 20),
          // .pen heading: Baloo 2 27/w700, breaking to two lines — constrain
          // the width so it wraps like the design instead of on one line.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: context.textTheme.displaySmall?.copyWith(
                color: context.colorScheme.onSurface,
                fontSize: 27,
                fontWeight: FontWeight.w700,
              ),
            ).animateSlideUp(delay: 60.ms),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            // .pen subtitle: body-md, 333 wide.
            constraints: const BoxConstraints(maxWidth: 333),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                height: 1.47,
              ),
            ).animateFadeIn(delay: 120.ms),
          ),
        ],
      ),
    );
  }
}

/// The decorative "filters" strip shown on the first slide, hinting at the
/// stamp editor. Static — purely illustrative.
class _FilterRow extends StatelessWidget {
  const _FilterRow();

  static const List<(FaIconData, String)> _filters = [
    (FontAwesomeIcons.sun, 'Sáng'),
    (FontAwesomeIcons.circleHalfStroke, 'Tương phản'),
    (FontAwesomeIcons.droplet, 'Ấm áp'),
    (FontAwesomeIcons.wandMagicSparkles, 'Tươi tắn'),
    (FontAwesomeIcons.image, 'Vintage'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    // .pen filterBar: 337 wide, surface-elevated, radius-20, padding [v12,h10];
    // icons 22, caption labels; "Sáng" active in coral (w600), rest secondary.
    return Container(
      width: 337,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: context.brand.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final (index, (icon, label)) in _filters.indexed)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  icon,
                  size: 22,
                  color: index == 0
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: index == 0
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: index == 0 ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

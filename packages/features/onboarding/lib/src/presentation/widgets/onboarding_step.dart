import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localization/localization.dart';

/// The StampMail wordmark (logo + name) shown atop each onboarding slide.
class _OnboardingBrand extends StatelessWidget {
  const _OnboardingBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/illustrations/logo-stamp.png',
          package: 'feature_onboarding',
          width: 60,
          height: 60,
          excludeFromSemantics: true,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.appTitle,
          style: context.textTheme.headlineMedium?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

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
          const _OnboardingBrand(),
          const SizedBox(height: AppSpacing.xxl),
          Image.asset(
            'assets/illustrations/${data.heroAsset}',
            package: 'feature_onboarding',
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ).animateScale(),
          if (data.showFilters) ...[
            const SizedBox(height: AppSpacing.xl),
            const _FilterRow(),
          ],
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: context.textTheme.displaySmall?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ).animateSlideUp(delay: 60.ms),
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                height: 1.5,
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                  size: 20,
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
                    fontWeight: index == 0
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import 'creator_theme.dart';

/// A photo-source option card (SM-005): a hero image over a labelled action row
/// with a leading icon. Matches the F02-S02 `card-*` frames pixel-for-pixel
/// (24-radius, soft outer shadow, 64px row, 40px tinted icon box).
class SourceCard extends StatelessWidget {
  const SourceCard({
    required this.icon,
    required this.label,
    required this.heroHeight,
    required this.hero,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;

  /// Design heights differ per card: 183 for "camera", 130 for "gallery".
  final double heroHeight;

  /// The illustration shown above the action row.
  final Widget hero;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1424211F),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: heroHeight,
                  width: double.infinity,
                  child: hero,
                ),
                SizedBox(
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: CreatorColors.iconBox,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            icon,
                            size: 22,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md + AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            label,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
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

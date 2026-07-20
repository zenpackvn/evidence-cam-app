import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../composer_catalog.dart';

/// The horizontal font picker (F03-S04): a chip per font, rendered in that font
/// so the user previews the look. The active chip is coral-outlined.
class FontChipRow extends StatelessWidget {
  const FontChipRow({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: letterFonts.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final font = letterFonts[i];
          final active = font == selected;
          return InkWell(
            onTap: () => onSelected(font),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: active ? scheme.primary : scheme.outlineVariant,
                  width: active ? 1.5 : 1,
                ),
              ),
              child: Text(
                font.split(' ').first,
                style: TextStyle(
                  fontFamily: font,
                  fontSize: 15,
                  color: active ? scheme.primary : scheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

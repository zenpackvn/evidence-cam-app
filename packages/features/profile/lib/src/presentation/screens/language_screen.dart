import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/profile_sub_scaffold.dart';

/// F07-S08 — language picker: a white card of language rows; the active row
/// tints `#FDE8EC` with a coral stroke and a filled check circle.
///
// ponytail: only vi/en are wired to the app locale today; ko/ja rows render
// per the design and no-op until those translations exist.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  /// The active locale code ('vi', 'en', …).
  final String selected;
  final ValueChanged<String> onSelect;

  static const _options = <(String, String, String)>[
    ('vi', '🇻🇳', 'Tiếng Việt'),
    ('en', '🇺🇸', 'English'),
    ('ko', '🇰🇷', '한국어'),
    ('ja', '🇯🇵', '日本語'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return ProfileSubScaffold(
      title: 'Ngôn ngữ',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Icon(Icons.bolt, size: 16, color: scheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Thay đổi áp dụng ngay.',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.brand.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Column(
                children: [
                  for (final (i, option) in _options.indexed) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _LanguageRow(
                      flag: option.$2,
                      label: option.$3,
                      selected: option.$1 == selected,
                      onTap: () => onSelect(option.$1),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFDE8EC)
              : context.brand.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? scheme.primary : context.brand.borderSubtle,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Text(
              label,
              style: context.textTheme.titleMedium,
            ),
            const Spacer(),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primary
                    : context.brand.surfaceElevated,
                shape: BoxShape.circle,
                border: selected
                    ? null
                    : Border.all(color: scheme.outlineVariant, width: 1.5),
              ),
              child: selected
                  ? Icon(Icons.check, size: 15, color: scheme.onPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

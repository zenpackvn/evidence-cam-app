import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/profile_sub_scaffold.dart';

/// F07-S08 — language picker: a white card of language rows; the active row
/// tints `#FDE8EC` with a coral stroke and a filled check circle. Picking a
/// language applies it app-wide immediately (the whole UI rebuilds under the
/// new locale).
///
// ponytail: only vi/en carry bundled translations today; ko/ja render per the
// design and the app keeps the current locale until those translations exist.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  /// The active locale code ('vi', 'en', …).
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // Local so the tick moves the instant a row is tapped; onSelect applies it to
  // the whole app.
  late String _selected = widget.selected;

  static const _options = <(String, String, String)>[
    ('vi', 'Vi', 'Tiếng Việt'),
    ('en', 'En', 'English'),
    ('ko', '한', '한국어'),
    ('ja', 'あ', '日本語'),
  ];

  // Only marks the choice; nothing changes until "Lưu".
  void _pick(String code) => setState(() => _selected = code);

  void _save() {
    widget.onSelect(_selected);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final changed = _selected != widget.selected;
    return ProfileSubScaffold(
      title: 'Ngôn ngữ',
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Icon(Icons.bolt, size: 16, color: scheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Chọn ngôn ngữ rồi bấm Lưu để áp dụng.',
                        style: context.textTheme.bodyMedium?.copyWith(
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
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F24211F),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        for (final (i, option) in _options.indexed) ...[
                          if (i > 0) const SizedBox(height: 10),
                          _LanguageRow(
                            badge: option.$2,
                            label: option.$3,
                            selected: option.$1 == _selected,
                            onTap: () => _pick(option.$1),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.md,
              AppSpacing.xxl,
              AppSpacing.xxl,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: changed ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  shape: const StadiumBorder(),
                  textStyle: context.textTheme.titleMedium,
                ),
                icon: const Icon(Icons.check, size: 20),
                label: const Text('Lưu'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.badge,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String badge;
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
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 14),
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
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? Colors.white : const Color(0xFFF6F0E8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(label, style: context.textTheme.titleMedium),
            const Spacer(),
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
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

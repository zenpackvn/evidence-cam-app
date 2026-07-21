import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// .pen `Editor/EditorTab`: 20px glyph + caption label, coral when active with
/// a 40×3 underline.
///
/// The design uses this same item for both roles in the composer's bottom sheet
/// — the panel's tabs (F03-S05 `tab-Giấy nền` …) and the formatting toggles
/// (F03-S04 `tab-In đậm` / `tab-Nghiêng` / `tab-Gạch chân`, whose `enabled`
/// flag is this widget's [active]).
class EditorTabItem extends StatelessWidget {
  const EditorTabItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.expand = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  /// Wrap in [Expanded] for an equal-width row (default). Set false to use it in
  /// a horizontally-scrolling tab bar where each item has its own fixed width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final color = active ? scheme.primary : scheme.onSurfaceVariant;
    final item = InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: active ? scheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
    return expand ? Expanded(child: item) : item;
  }
}

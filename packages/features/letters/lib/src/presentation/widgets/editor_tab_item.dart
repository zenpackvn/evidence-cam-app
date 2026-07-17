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
    super.key,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final color = active ? scheme.primary : scheme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
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
      ),
    );
  }
}

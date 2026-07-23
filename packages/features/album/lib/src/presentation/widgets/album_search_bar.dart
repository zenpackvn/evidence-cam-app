import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// The Album search row (F02-S10): a rounded search field plus a square
/// filter button (sort). Live: [onChanged] filters as the user types, the
/// topnav's search icon focuses the field via [focusNode].
class AlbumSearchBar extends StatelessWidget {
  const AlbumSearchBar({
    this.onChanged,
    this.onFilter,
    this.focusNode,
    super.key,
  });

  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilter;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F24211F),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 20, color: scheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    focusNode: focusNode,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Tìm kiếm tem...',
                      hintStyle: context.textTheme.bodyMedium?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        InkWell(
          onTap: onFilter,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F24211F),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.tune, size: 20, color: scheme.onSurface),
          ),
        ),
      ],
    );
  }
}

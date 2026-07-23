import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// The Album search row (F02-S10): a rounded search field plus a square
/// filter button (sort). Live: [onChanged] filters as the user types; the
/// trailing ✕ clears the field and reports an empty query so the full list
/// comes back. [focusNode] lets callers focus the field.
class AlbumSearchBar extends StatefulWidget {
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
  State<AlbumSearchBar> createState() => _AlbumSearchBarState();
}

class _AlbumSearchBarState extends State<AlbumSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    // Rebuild so the clear (✕) button shows/hides with the text.
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    // Report the now-empty query so the album filter resets to every stamp.
    widget.onChanged?.call('');
    widget.focusNode?.unfocus();
    setState(() {});
  }

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
                    controller: _controller,
                    focusNode: widget.focusNode,
                    onChanged: _handleChanged,
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
                if (_controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: _clear,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        InkWell(
          onTap: widget.onFilter,
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

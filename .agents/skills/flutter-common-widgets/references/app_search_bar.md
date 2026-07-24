# AppSearchBar / AppSliverBar

`AppSearchBar` — App bar with integrated search field. Animates between title mode and search mode.

`AppSliverBar` — Collapsing sliver app bar for scroll-to-collapse layouts.

## File

`lib/src/core/widgets/common/app_search_bar.dart`

```dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';

class AppSearchBar extends StatefulWidget implements PreferredSizeWidget {
  const AppSearchBar({
    super.key,
    required this.title,
    required this.onChanged,
    this.hintText = 'Search...',
    this.onClear,
    this.actions,
    this.debounceMs = 300,
  });

  final String title;
  final ValueChanged<String> onChanged;
  final String hintText;
  final VoidCallback? onClear;
  final List<Widget>? actions;
  final int debounceMs;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  bool _isSearching = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _controller.clear();
        widget.onChanged('');
        widget.onClear?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _controller,
              autofocus: true,
              onChanged: widget.onChanged,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            )
          : Text(widget.title),
      actions: [
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _toggleSearch,
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
          ),
          if (widget.actions != null) ...widget.actions!,
        ],
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

/// Collapsing sliver app bar for scroll-to-collapse layouts.
class AppSliverBar extends StatelessWidget {
  const AppSliverBar({
    super.key,
    required this.title,
    this.expandedHeight = 200,
    this.flexibleContent,
    this.actions,
    this.pinned = true,
    this.floating = false,
  });

  final String title;
  final double expandedHeight;
  final Widget? flexibleContent;
  final List<Widget>? actions;
  final bool pinned;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      title: Text(title),
      actions: actions,
      flexibleSpace: flexibleContent != null
          ? FlexibleSpaceBar(background: flexibleContent)
          : null,
    );
  }
}
```

## Rules

- Use `AppSearchBar` instead of raw `SearchBar(...)` or `SearchAnchor(...)`.
- Use `AppSliverBar` for scroll-to-collapse layouts.

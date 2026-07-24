# AppSearchField

Standalone search input with clear button. For use inside page bodies (not app bar).

> For an app bar with integrated search, use `AppSearchBar` — see [app_search_bar.md](app_search_bar.md).

## File

`lib/src/core/widgets/common/app_search_field.dart`

```dart
import 'package:flutter/material.dart';

class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.onChanged,
    this.hint = 'Search...',
    this.controller,
    this.autofocus = false,
    this.onSubmitted,
    this.onClear,
  });

  final ValueChanged<String> onChanged;
  final String hint;
  final TextEditingController? controller;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clear,
              )
            : null,
      ),
    );
  }
}
```

## Rules

- Use `AppSearchField` for in-body search inputs instead of raw `TextField` or `SearchBar`.
- Clear button is shown automatically when text is non-empty — do not add one manually.

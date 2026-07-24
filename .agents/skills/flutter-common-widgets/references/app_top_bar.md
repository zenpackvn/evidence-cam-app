# AppTopBar

Thin wrapper over `AppBar`. Inherits `appBarTheme` from `AppTheme`. Adds app conventions: automatic back button, consistent action spacing.

## File

`lib/src/core/widgets/common/app_top_bar.dart`

```dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.bottom,
    this.centerTitle,
    this.elevation,
  });

  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool? centerTitle;
  final double? elevation;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      elevation: elevation,
      automaticallyImplyLeading: showBack,
      leading: showBack && Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(width: AppSpacing.xs),
            ]
          : null,
      bottom: bottom,
    );
  }
}
```

## Rules

- Always use `AppTopBar` instead of raw `AppBar(...)`.
- Styling is inherited from `appBarTheme` — do not override colors or text styles inline.

# AppListTile

Standardized list item with consistent spacing. Adds `onLongPress` and `borderRadius` over Material `ListTile`.

## File

`lib/src/core/widgets/common/app_list_tile.dart`

```dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.contentPadding,
    this.dense = false,
    this.enabled = true,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? contentPadding;
  final bool dense;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      dense: dense,
      enabled: enabled,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
    );
  }
}
```

## Rules

- Use `AppListTile` instead of raw `ListTile(...)`.
- Compose with `AppAvatar`, `AppStatusChip`, `AppTag` for richer list items.

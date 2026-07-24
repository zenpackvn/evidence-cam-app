# AppTag

Small label tag for filters and categories. Supports tap, remove, and selected state.

## File

`lib/src/core/widgets/common/app_tag.dart`

```dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';

class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.onTap,
    this.onRemove,
    this.color,
    this.selected = false,
  });

  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final Color? color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    if (onRemove != null || onTap != null) {
      return InputChip(
        label: Text(label),
        selected: selected,
        onPressed: onTap,
        onDeleted: onRemove,
        selectedColor: effectiveColor.withValues(alpha: 0.12),
        labelStyle: theme.textTheme.labelSmall?.copyWith(
          color: selected ? effectiveColor : null,
        ),
      );
    }

    return Chip(
      label: Text(label),
      backgroundColor: selected
          ? effectiveColor.withValues(alpha: 0.12)
          : null,
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: selected ? effectiveColor : null,
      ),
    );
  }
}
```

## Rules

- Use `AppTag` instead of raw `Chip(...)` for filter/category labels.
- For status display use `AppStatusChip` instead.

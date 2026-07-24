# AppSelectableCard

Card with selected/unselected state and optional check indicator.

## File

`lib/src/core/widgets/common/app_selectable_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';

class AppSelectableCard extends StatelessWidget {
  const AppSelectableCard({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onTap,
    this.padding,
    this.showCheck = true,
  });

  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return Card(
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(child: child),
              if (showCheck && isSelected) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: AppSpacing.iconMd,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

## Rules

- `isSelected` state must come from the cubit — not managed in widget state.
- Uses `theme.colorScheme.primary` for selection color — do not hardcode colors.

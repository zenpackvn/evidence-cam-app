# AppCard

Content card. Inherits shape, elevation, and color from `cardTheme` in `AppTheme`. Adds consistent inner padding.

## File

`lib/src/core/widgets/common/app_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation,
      margin: margin,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    );

    return onTap != null ? card : Card(
      elevation: elevation,
      margin: margin,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}
```

## Rules

- Use `AppCard` instead of raw `Card(...)`.
- Padding defaults to `AppSpacing.md` — do not wrap the child in another `Padding` unless overriding.
- Prefer composing `AppCard` + `AppListTile` + `AppStatusChip` rather than building a mega-widget.

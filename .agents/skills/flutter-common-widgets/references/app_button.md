# AppButton / AppOutlinedButton / AppTextButton / AppDangerButton / AppIconButton

Thin wrappers that add app conventions (sizes, icon+label layout) on top of Material button themes from `AppTheme`. Styling is inherited — not redefined.

> **Loading state?** Use `LoadingButton` from [template-loading.md](../../flutter-loading/references/template.md).

## File

`lib/src/core/widgets/common/app_button.dart`

```dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';

/// Standard sizes — control height and text scale.
enum AppButtonSize {
  small(36),
  medium(48),
  large(56);

  const AppButtonSize(this.height);
  final double height;
}

/// Primary filled button.
/// Inherits colors, shape, and text style from `elevatedButtonTheme` in AppTheme.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = AppButtonSize.medium,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonSize size;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    Widget button = icon != null
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: AppSpacing.iconMd),
            label: Text(label),
            style: FilledButton.styleFrom(
              minimumSize: Size(0, size.height),
            ),
          )
        : FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              minimumSize: Size(0, size.height),
            ),
            child: Text(label),
          );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Secondary outlined button.
/// Inherits from `outlinedButtonTheme` in AppTheme.
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = AppButtonSize.medium,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonSize size;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    Widget button = icon != null
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: AppSpacing.iconMd),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(0, size.height),
            ),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(0, size.height),
            ),
            child: Text(label),
          );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Minimal text button.
/// Inherits from `textButtonTheme` in AppTheme.
class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return icon != null
        ? TextButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: AppSpacing.iconSm),
            label: Text(label),
          )
        : TextButton(
            onPressed: onPressed,
            child: Text(label),
          );
  }
}

/// Destructive action button — uses error color from theme.
/// Use for delete, remove, cancel subscription, and other irreversible actions.
/// Always pair with a confirmation dialog ([AppDialog.showConfirm]).
class AppDangerButton extends StatelessWidget {
  const AppDangerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = AppButtonSize.medium,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonSize size;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = FilledButton.styleFrom(
      backgroundColor: theme.colorScheme.error,
      foregroundColor: theme.colorScheme.onError,
      minimumSize: Size(0, size.height),
    );

    Widget button = icon != null
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: AppSpacing.iconMd),
            label: Text(label),
            style: style,
          )
        : FilledButton(
            onPressed: onPressed,
            style: style,
            child: Text(label),
          );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Icon button with optional label underneath.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.size = AppSpacing.iconMd,
    this.color,
    this.tooltip,
    this.badge,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;
  final double size;
  final Color? color;
  final String? tooltip;

  /// Optional badge widget (e.g., AppBadge) stacked on the icon.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;

    Widget iconWidget = Icon(icon, size: size, color: effectiveColor);

    if (badge != null) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(top: -4, right: -4, child: badge!),
        ],
      );
    }

    final button = IconButton(
      onPressed: onPressed,
      icon: iconWidget,
      tooltip: tooltip,
    );

    if (label == null) return button;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        Text(
          label!,
          style: theme.textTheme.labelSmall?.copyWith(color: effectiveColor),
        ),
      ],
    );
  }
}
```

## Rules

- Use `AppButton` instead of raw `FilledButton(...)` / `ElevatedButton(...)`.
- Use `AppOutlinedButton` instead of raw `OutlinedButton(...)`.
- Use `AppTextButton` instead of raw `TextButton(...)` or `GestureDetector(child: Text(...))`.
- Use `AppDangerButton` for destructive actions — always pair with `AppDialog.showConfirm`.
- Use `AppIconButton` instead of raw `IconButton(...)`.
- For loading state, use `LoadingButton` — not `AppButton` with manual spinner.

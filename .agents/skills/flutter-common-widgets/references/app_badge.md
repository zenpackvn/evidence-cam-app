# AppBadge

Notification count badge that stacks on any widget.

## File

`lib/src/core/widgets/common/app_badge.dart`

```dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.child,
    this.count = 0,
    this.showZero = false,
    this.maxCount = 99,
    this.color,
  });

  final Widget child;
  final int count;
  final bool showZero;
  final int maxCount;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final show = count > 0 || showZero;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (show)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxs,
                vertical: 1,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: color ?? theme.colorScheme.error,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              alignment: Alignment.center,
              child: Text(
                count > maxCount ? '$maxCount+' : '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
```

## Usage

```dart
AppIconButton(
  icon: Icons.notifications_outlined,
  tooltip: 'Notifications',
  badge: const AppBadge(
    count: 5,
    child: SizedBox.shrink(),
  ),
  onPressed: () {},
)
```

## Rules

- Use `AppBadge` instead of raw `Badge(...)`.
- Badge color defaults to `theme.colorScheme.error`.

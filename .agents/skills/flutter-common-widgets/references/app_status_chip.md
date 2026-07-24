# AppStatusChip

Colored chip for status display. Uses semantic colors from `AppColors`.

## File

`lib/src/core/widgets/common/app_status_chip.dart`

```dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

enum AppChipStatus {
  active(AppColors.success),
  inactive(AppColors.disabled),
  pending(AppColors.warning),
  error(AppColors.error),
  info(AppColors.info);

  const AppChipStatus(this.color);
  final Color color;
}

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    required this.status,
    this.icon,
  });

  final String label;
  final AppChipStatus status;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: status.color),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Usage

```dart
AppStatusChip(
  label: 'Active',
  status: AppChipStatus.active,
  icon: Icons.check_circle_outline,
)
```

## Rules

- Use `AppStatusChip` instead of raw `Chip(...)` for status display.
- Colors come from `AppChipStatus` enum — do not pass custom `Color` values.

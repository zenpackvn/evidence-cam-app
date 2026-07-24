# AppErrorState

Error state with retry button for non-list pages.

> For list screens, use `SuperListView` from the loading skill — it handles error state automatically.

## File

`lib/src/core/widgets/common/app_error_state.dart`

```dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.icon = Icons.error_outline,
    this.title = 'Something went wrong',
    this.subtitle,
    this.retryLabel = 'Retry',
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

## Rules

- Use `AppErrorState` instead of a manual `Column([Icon(error_outline), ..., AppButton(...)])`.
- For list screens, prefer `SuperListView` which manages error state automatically.

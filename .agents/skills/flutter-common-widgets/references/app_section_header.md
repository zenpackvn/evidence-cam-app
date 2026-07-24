# AppSectionHeader

Section label with optional trailing action and divider below.

## File

`lib/src/core/widgets/common/app_section_header.dart`

```dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.padding,
    this.showDivider = true,
  });

  final String title;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (action != null) action!,
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
```

## Usage

```dart
AppSectionHeader(
  title: 'Account',
  action: AppTextButton(label: 'Edit', onPressed: () {}),
)
```

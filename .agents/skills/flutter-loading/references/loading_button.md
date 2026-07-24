# Loading — LoadingButton

Button that shows a spinner while an async action is in progress. Disables tap to prevent duplicate submissions.

## `lib/src/core/widgets/loading/loading_button.dart`

```dart
import 'package:flutter/material.dart';
import 'app_loading_indicator.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.icon,
    this.style,
    this.loadingColor,
    this.expanded = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final IconData? icon;
  final ButtonStyle? style;
  final Color? loadingColor;

  /// When true, button stretches to full width.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLoadingColor =
        loadingColor ?? theme.colorScheme.onPrimary;

    Widget button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? AppLoadingIndicator(
              size: AppLoadingSize.small,
              color: effectiveLoadingColor,
            )
          : _buildContent(),
    );

    if (expanded) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSpacing.iconSm),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }
    return Text(label);
  }
}
```

### Outlined variant

```dart
class LoadingOutlinedButton extends StatelessWidget {
  const LoadingOutlinedButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.style,
    this.expanded = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final ButtonStyle? style;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? AppLoadingIndicator(
              size: AppLoadingSize.small,
              color: theme.colorScheme.primary,
            )
          : Text(label),
    );

    if (expanded) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
```

### Usage with cubit state

```dart
BlocBuilder<SignInCubit, SignInState>(
  builder: (context, state) {
    return LoadingButton(
      label: 'Sign In',
      isLoading: state is SignInSubmitting,
      expanded: true,
      onPressed: () => context.read<SignInCubit>().submit(),
    );
  },
)
```

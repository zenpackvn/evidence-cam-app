# Loading — ScreenLoading and LoadingOverlay

## `lib/src/core/widgets/loading/screen_loading.dart`

Full-screen centered loading for list screens, detail screens, or any page waiting for non-list data.

```dart
import 'package:flutter/material.dart';
import 'app_loading_indicator.dart';

class ScreenLoading extends StatelessWidget {
  const ScreenLoading({
    super.key,
    this.message,
    this.size = AppLoadingSize.large,
  });

  final String? message;
  final AppLoadingSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLoadingIndicator(size: size),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
```

### Usage in a page

```dart
BlocBuilder<HomeCubit, HomeState>(
  builder: (context, state) => switch (state) {
    HomeInitial() || HomeLoading() => const ScreenLoading(),
    HomeEmpty() => const Center(child: Text('No items')),
    HomeError(:final failure) => Center(child: Text(failure.message)),
    HomeLoaded(:final items) => ItemListView(items: items),
  },
)
```

---

## `lib/src/core/widgets/loading/loading_overlay.dart`

Modal overlay that locks the screen until an async operation completes. Prevents user interaction — use for form submissions, payment processing, file uploads. Driven declaratively by bloc state.

```dart
import 'package:flutter/material.dart';
import '../common/app_card.dart';
import 'app_loading_indicator.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.barrierColor,
  });

  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? barrierColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          ColoredBox(
            color: barrierColor ??
                Theme.of(context).colorScheme.scrim.withValues(alpha: 0.4),
            child: SizedBox.expand(
              child: Center(
                child: _OverlayContent(message: message),
              ),
            ),
          ),
      ],
    );
  }
}

class _OverlayContent extends StatelessWidget {
  const _OverlayContent({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      elevation: 4,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLoadingIndicator(size: AppLoadingSize.medium),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
```

### Usage — wrapping a page

```dart
BlocBuilder<CheckoutCubit, CheckoutState>(
  builder: (context, state) {
    return LoadingOverlay(
      isLoading: state is CheckoutSubmitting,
      message: 'Processing payment…',
      child: const CheckoutForm(),
    );
  },
)
```

> **Imperative loading dialog?** Use `AppDialog.showLoading()` from the dialog template instead. `LoadingOverlay` is for declarative in-tree usage driven by bloc state. `AppDialog.showLoading()` is for imperative one-off operations from `BlocListener`.

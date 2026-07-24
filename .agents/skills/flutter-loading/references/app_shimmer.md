# Loading — AppShimmer

The **only file** that imports `shimmer_animation`. Provides a shimmer wrapper and ready-made list skeleton builders.

## `pubspec.yaml` addition

```yaml
dependencies:
  shimmer_animation: 2.2.1  # exact version, never ^
```

## `lib/src/core/widgets/loading/app_shimmer.dart`

```dart
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

/// Wraps [child] in a shimmer sweep animation.
class AppShimmer extends StatelessWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Shimmer(
      duration: const Duration(seconds: 2),
      colorOpacity: 0.25,
      color: Theme.of(context).colorScheme.onSurface,
      child: child,
    );
  }
}

/// A single shimmer placeholder row — mimics a list item.
class ShimmerListItem extends StatelessWidget {
  const ShimmerListItem({
    super.key,
    this.height = 72,
    this.leadingSize = 48,
    this.hasLeading = true,
  });

  final double height;
  final double leadingSize;
  final bool hasLeading;

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context)
        .colorScheme
        .surfaceContainerHighest
        .withValues(alpha: 0.5);

    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (hasLeading) ...[
              Container(
                width: leadingSize,
                height: leadingSize,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 160,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Builds a full-screen shimmer skeleton list. Use as the loading state
/// of [SuperListView] or standalone.
class ShimmerListSkeleton extends StatelessWidget {
  const ShimmerListSkeleton({
    super.key,
    this.itemCount = 8,
    this.itemBuilder,
  });

  final int itemCount;

  /// Override to provide a custom shimmer row.
  final Widget Function(BuildContext context, int index)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder ??
          (context, index) => const ShimmerListItem(),
    );
  }
}
```

### Custom shimmer shapes

Override `itemBuilder` for cards, grids, or any layout:

```dart
ShimmerListSkeleton(
  itemCount: 6,
  itemBuilder: (context, index) => const ShimmerListItem(
    height: 100,
    hasLeading: false,
  ),
)
```

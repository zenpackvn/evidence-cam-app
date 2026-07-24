# AppCachedImage

Network image with loading placeholder and error fallback. The **only file** that imports `cached_network_image`. Wrapper rule applies.

## `pubspec.yaml` addition

```yaml
dependencies:
  cached_network_image: 3.4.1    # exact version, never ^
```

## File

`lib/src/core/widgets/common/app_cached_image.dart`

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';

class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.image_outlined,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.broken_image_outlined,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}
```

## Rules

- **Only this file** imports `cached_network_image`. No other file in the project may import it directly.
- To swap the image caching library, edit only this file.
- Use `AppCachedImage` instead of raw `CachedNetworkImage(...)`.

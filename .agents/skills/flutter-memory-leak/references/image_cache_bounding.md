# Image Cache Bounding

Unbounded image caches cause OOM (out-of-memory) on image-heavy feeds.

## Bootstrap configuration

```dart
// lib/src/app/bootstrap/app_bootstrap.dart
void _configureImageCache() {
  PaintingBinding.instance.imageCache
    ..maximumSize = 150          // max 150 images
    ..maximumSizeBytes = 100 << 20; // 100 MB
}
```

Call `_configureImageCache()` in `appBootstrap()` before `runApp`.

## `AppCachedImage` widget

Wraps `CachedNetworkImage` with decode-size constraints to prevent full-resolution decoding for thumbnails.

```dart
// lib/src/core/network/app_cached_image.dart
class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  final String url;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth ?? width?.toInt(),
      memCacheHeight: memCacheHeight ?? height?.toInt(),
      // Constrain decode size — prevents full-res decode for thumbnails
    );
  }
}
```

## Rules

- Always pass `width`/`height` and `memCacheWidth`/`memCacheHeight` to `AppCachedImage`.
- Call `_configureImageCache()` in bootstrap before `runApp`.
- If `ImageCache` size keeps growing in DevTools → missing `memCacheWidth`/`memCacheHeight` somewhere.

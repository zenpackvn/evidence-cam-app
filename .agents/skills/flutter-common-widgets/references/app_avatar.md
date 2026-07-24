# AppAvatar

Circular avatar with image, initials fallback, and optional status dot.

## File

`lib/src/core/widgets/common/app_avatar.dart`

```dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import 'app_cached_image.dart';

enum AppAvatarSize {
  small(32),
  medium(40),
  large(56),
  xlarge(80);

  const AppAvatarSize(this.diameter);
  final double diameter;
}

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppAvatarSize.medium,
    this.statusColor,
    this.onTap,
  });

  final String? imageUrl;
  final String? name;
  final AppAvatarSize size;

  /// Status dot color (e.g., green for online). Null = no dot.
  final Color? statusColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = ClipOval(
        child: AppCachedImage(
          imageUrl: imageUrl!,
          width: size.diameter,
          height: size.diameter,
          fit: BoxFit.cover,
        ),
      );
    } else {
      avatar = CircleAvatar(
        radius: size.diameter / 2,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          _initials,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontSize: size.diameter * 0.36,
          ),
        ),
      );
    }

    if (statusColor != null) {
      final dotSize = size.diameter * 0.28;
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}
```

## Rules

- Use `AppAvatar` instead of raw `CircleAvatar(...)`.
- Image loading goes through `AppCachedImage` — do not import `cached_network_image` directly.
- Initials are derived from `name` automatically when `imageUrl` is null or empty.

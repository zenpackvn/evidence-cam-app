# AppDivider / AppVerticalDivider

Inherits `dividerTheme` from `AppTheme`.

## File

`lib/src/core/widgets/common/app_divider.dart`

```dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';

/// Horizontal divider with optional indent. Styled by `dividerTheme`.
class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
    this.height,
  });

  final double indent;
  final double endIndent;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Divider(
      indent: indent,
      endIndent: endIndent,
      height: height,
    );
  }
}

/// Vertical divider for row layouts.
class AppVerticalDivider extends StatelessWidget {
  const AppVerticalDivider({
    super.key,
    this.width,
    this.indent = 0,
    this.endIndent = 0,
  });

  final double? width;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: width,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
```

## Rules

- Use `AppDivider` instead of raw `Divider(...)`.
- Use `AppVerticalDivider` instead of raw `VerticalDivider(...)`.
- Do not set color inline — inherits from `dividerTheme`.

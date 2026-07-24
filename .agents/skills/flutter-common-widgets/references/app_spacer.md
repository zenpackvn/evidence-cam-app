# AppSpacerV / AppSpacerH

Consistent gap widgets using `AppSpacing` tokens. Avoids magic `SizedBox(height: 16)` everywhere.

## File

`lib/src/core/widgets/common/app_spacer.dart`

```dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';

/// Vertical gap — use between rows, sections, form fields.
class AppSpacerV extends StatelessWidget {
  const AppSpacerV.xxs({super.key}) : _height = AppSpacing.xxs;
  const AppSpacerV.xs({super.key}) : _height = AppSpacing.xs;
  const AppSpacerV.sm({super.key}) : _height = AppSpacing.sm;
  const AppSpacerV.md({super.key}) : _height = AppSpacing.md;
  const AppSpacerV.lg({super.key}) : _height = AppSpacing.lg;
  const AppSpacerV.xl({super.key}) : _height = AppSpacing.xl;
  const AppSpacerV.xxl({super.key}) : _height = AppSpacing.xxl;

  final double _height;

  @override
  Widget build(BuildContext context) => SizedBox(height: _height);
}

/// Horizontal gap — use between items in a Row.
class AppSpacerH extends StatelessWidget {
  const AppSpacerH.xxs({super.key}) : _width = AppSpacing.xxs;
  const AppSpacerH.xs({super.key}) : _width = AppSpacing.xs;
  const AppSpacerH.sm({super.key}) : _width = AppSpacing.sm;
  const AppSpacerH.md({super.key}) : _width = AppSpacing.md;
  const AppSpacerH.lg({super.key}) : _width = AppSpacing.lg;
  const AppSpacerH.xl({super.key}) : _width = AppSpacing.xl;
  const AppSpacerH.xxl({super.key}) : _width = AppSpacing.xxl;

  final double _width;

  @override
  Widget build(BuildContext context) => SizedBox(width: _width);
}
```

## Rules

- Use `AppSpacerV.md()` etc. instead of `SizedBox(height: AppSpacing.md)` or any magic number.
- Use `AppSpacerH.md()` etc. instead of `SizedBox(width: AppSpacing.md)`.

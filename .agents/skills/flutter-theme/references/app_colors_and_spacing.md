# AppColors and AppSpacing

## `lib/src/app/theme/app_colors.dart`

```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ──
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color secondary = Color(0xFF34A853);

  // ── Neutral ──
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color divider = Color(0xFFE0E0E0);

  // ── Text ──
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFFE8EAED);
  static const Color textSecondaryDark = Color(0xFF9AA0A6);

  // ── Semantic ──
  static const Color error = Color(0xFFD93025);
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC04);
  static const Color info = Color(0xFF4285F4);

  // ── Interaction ──
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color ripple = Color(0x1A1A73E8);

  /// Derive a [ColorScheme] for light mode.
  static ColorScheme get lightScheme => const ColorScheme.light(
        primary: primary,
        onPrimary: textOnPrimary,
        secondary: secondary,
        error: error,
        surface: surface,
        onSurface: textPrimary,
      );

  /// Derive a [ColorScheme] for dark mode.
  static ColorScheme get darkScheme => const ColorScheme.dark(
        primary: primary,
        onPrimary: textOnPrimary,
        secondary: secondary,
        error: error,
        surface: surfaceDark,
        onSurface: textPrimaryDark,
      );
}
```

## `lib/src/app/theme/app_spacing.dart`

```dart
abstract final class AppSpacing {
  /// 4
  static const double xxs = 4;

  /// 8
  static const double xs = 8;

  /// 12
  static const double sm = 12;

  /// 16
  static const double md = 16;

  /// 20
  static const double lg = 20;

  /// 24
  static const double xl = 24;

  /// 32
  static const double xxl = 32;

  /// 40
  static const double xxxl = 40;

  /// 48
  static const double huge = 48;

  // ── Radius ──
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // ── Icon sizes ──
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
}
```

# AppTypography

> **Requires** `google_fonts: x.y.z` (exact pin, no `^`) in `pubspec.yaml`.
> `GoogleFonts.inter(...)` returns a non-const `TextStyle`, so all members are
> `static TextStyle get` getters — **never** `static const TextStyle`.

## `lib/src/app/theme/app_typography.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  // ── Display ──
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.29,
      );

  // ── Headline ──
  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.33,
      );

  // ── Title ──
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.1,
      );

  // ── Body ──
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.15,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
      );

  // ── Label ──
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.5,
      );

  // ── Caption ──
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        color: AppColors.textSecondary,
      );

  /// Sets Inter across all Material text roles.
  /// The inner [TextTheme] stays const — no fontFamily needed there.
  static TextTheme get textTheme => GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.5),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.29),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.33),
          headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.33),
          titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5),
          titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.43, letterSpacing: 0.1),
          bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
          bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.43, letterSpacing: 0.15),
          bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33, letterSpacing: 0.4),
          labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.1),
          labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.45, letterSpacing: 0.5),
        ),
      );
}
```

## Rules

- `GoogleFonts.inter(...)` returns a non-const `TextStyle` — all members must be `static TextStyle get` getters, never `static const TextStyle`.
- `textTheme` styles stay `inherit: true` — apply colors via `.apply(bodyColor:, displayColor:)`. This lets every `Text` widget inherit color from context.
- Add `google_fonts: x.y.z` (exact version, no `^`) to `pubspec.yaml`. The `GoogleFonts` import is acceptable directly in `app_typography.dart` — its output is a standard Flutter `TextStyle` so no third-party type leaks out.

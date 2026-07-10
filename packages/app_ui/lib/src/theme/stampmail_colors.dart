import 'package:flutter/material.dart';

/// StampMail Material [ColorScheme]s derived from the design tokens in
/// `stampmail/flows/pencil-new.pen` (Foundations/Colors).
///
/// Kept as hand-authored schemes (rather than `ColorScheme.fromSeed`) so the
/// warm coral/cream palette matches the design pixel-for-pixel instead of what
/// a seed algorithm derives. Mapping of tokens → Material roles:
///
/// - `primary` ← brand-coral-500, `onPrimary` ← text-inverse
/// - `surface` ← surface-primary, `surfaceContainerLowest` ← surface-elevated
/// - `onSurface` ← text-primary, `onSurfaceVariant` ← text-secondary
/// - `outline` ← text-tertiary, `outlineVariant` ← border-default
/// - `error` ← text-error
abstract final class StampMailColors {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFF35B43),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFF0EC),
    onPrimaryContainer: Color(0xFFD94B36),
    secondary: Color(0xFFF47A43),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFF4EF),
    onSecondaryContainer: Color(0xFF8A4A28),
    tertiary: Color(0xFF6E9A6C),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFF0F6EF),
    onTertiaryContainer: Color(0xFF35502F),
    error: Color(0xFFC93D33),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFCEAE8),
    onErrorContainer: Color(0xFF8A241C),
    surface: Color(0xFFFBF7F3),
    onSurface: Color(0xFF24211F),
    onSurfaceVariant: Color(0xFF716B66),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFFDF9),
    surfaceContainer: Color(0xFFF7F1EA),
    surfaceContainerHigh: Color(0xFFF1E9E1),
    surfaceContainerHighest: Color(0xFFEBE2D9),
    outline: Color(0xFFAFA7A0),
    outlineVariant: Color(0xFFDED6CF),
    shadow: Color(0xFF24211F),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF322B25),
    onInverseSurface: Color(0xFFF4EEE8),
    inversePrimary: Color(0xFFF86A50),
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF86A50),
    onPrimary: Color(0xFF3A1710),
    primaryContainer: Color(0xFF3A2A25),
    onPrimaryContainer: Color(0xFFFFD9CF),
    secondary: Color(0xFFF98A52),
    onSecondary: Color(0xFF3A1E0C),
    secondaryContainer: Color(0xFF382E27),
    onSecondaryContainer: Color(0xFFFFD9C2),
    tertiary: Color(0xFF9FC69D),
    onTertiary: Color(0xFF16340F),
    tertiaryContainer: Color(0xFF2A322A),
    onTertiaryContainer: Color(0xFFD4EFD1),
    error: Color(0xFFFF8A7A),
    onError: Color(0xFF5A150C),
    errorContainer: Color(0xFF43302C),
    onErrorContainer: Color(0xFFFFD5CE),
    surface: Color(0xFF201B18),
    onSurface: Color(0xFFF4EEE8),
    onSurfaceVariant: Color(0xFFB8AFA7),
    surfaceContainerLowest: Color(0xFF1A1512),
    surfaceContainerLow: Color(0xFF2A241F),
    surfaceContainer: Color(0xFF322B25),
    surfaceContainerHigh: Color(0xFF3C342D),
    surfaceContainerHighest: Color(0xFF473E36),
    outline: Color(0xFF7E756D),
    outlineVariant: Color(0xFF4A423A),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFF4EEE8),
    onInverseSurface: Color(0xFF322B25),
    inversePrimary: Color(0xFFF35B43),
  );
}

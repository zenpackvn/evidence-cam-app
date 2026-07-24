---
name: flutter-theme
description: Use this skill when working on Flutter app theming — AppColors, AppSpacing, AppTypography, AppTheme, color tokens, spacing scale, border radii, TextTheme, light mode, dark mode, ThemeData, color scheme, Google Fonts, Inter font, ThemeCubit, ThemeStore, theme switching, typography, text styles, or any design tokens.
---

# Flutter Theme

Full reference: [`template.md`](references/template.md)

## Files

```
lib/src/app/theme/
  app_colors.dart       ← color tokens + ColorScheme builders
  app_spacing.dart      ← spacing scale + radii + icon sizes
  app_typography.dart   ← TextStyle getters via GoogleFonts.inter(...)
  app_theme.dart        ← builds light + dark ThemeData (only file that creates ThemeData)
lib/src/core/theme/
  theme_store.dart      ← domain interface (ThemeMode read/write)
  theme_cubit.dart      ← HydratedCubit<ThemeMode> implementing ThemeStore
```

## Key rules

- `google_fonts: x.y.z` (exact pin, no `^`) in `pubspec.yaml`.
- All `AppTypography` members are `static TextStyle get` getters — **never** `static const TextStyle` (Google Fonts returns non-const objects).
- `textTheme` uses `GoogleFonts.interTextTheme(const TextTheme(...))`. Inner `TextTheme` args stay `const`.
- `app_theme.dart` is the **only** file that builds `ThemeData`.
- All non-`textTheme` styles in component themes use the file-level `_t()` helper — sets `inherit: false`, explicit `color`, `textBaseline: TextBaseline.alphabetic`.
- Both light and dark must define the **same set** of component themes.
- No hardcoded `Color(0xFF...)`, magic-number padding, or inline `TextStyle(fontSize: ...)` anywhere outside `app_theme.dart`.
- Widgets read colors via `Theme.of(context).colorScheme` or `AppColors` constants — never inline hex.
- `ThemeStore` is the domain interface; `ThemeCubit` implements it. Data layer injects `ThemeStore`; presentation layer resolves `ThemeCubit`.

## Co-load with

- `flutter-di` — `ThemeCubit`/`ThemeStore` registration
- `flutter-localization` — no hardcoded strings alongside theme

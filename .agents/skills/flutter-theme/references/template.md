# Template — Theme

Design tokens and `ThemeData` assembly. All colors, spacing, and text styles are centralized in four files — no magic numbers or inline styles anywhere in widgets.

## Topics

| Topic | File |
|---|---|
| AppColors (brand, neutral, semantic, ColorScheme) and AppSpacing | [app_colors_and_spacing.md](app_colors_and_spacing.md) |
| AppTypography (Inter via google_fonts, textTheme, getters) | [app_typography.md](app_typography.md) |
| AppTheme light + dark ThemeData assembly, `_t()` helper | [app_theme.md](app_theme.md) |
| ThemeCubit, ThemeStore, DI registration, widget usage | [theme_cubit_and_usage.md](theme_cubit_and_usage.md) |
| Anti-patterns with code examples | [theme_anti_patterns.md](theme_anti_patterns.md) |

## ⚠️ Common Mistakes

> These are the most frequent theme bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **`static const TextStyle` used for `AppTypography` members** | Compile error: `GoogleFonts.inter(...)` is not a const expression | Declare all `AppTypography` members as `static TextStyle get` getters — `GoogleFonts.inter(...)` returns a non-const value |
| 2 | **Non-textTheme component style missing `_t()` wrapper** | `TextStyleTween` lerp warning in debug console; `InputDecorator` null crash; button text invisible in dark mode | Wrap every component-theme text style (appBarTheme, elevatedButtonTheme, inputDecorationTheme, etc.) with `_t(style, color)` which sets `inherit: false`, explicit `color`, and `textBaseline: TextBaseline.alphabetic` |
| 3 | **Component theme defined in light but omitted from dark** | Flutter lerps between `inherit: false` (light) and Material's `inherit: true` (dark default); `TextStyleTween` warning fires on theme switch | Define the same set of component themes in both `AppTheme.light` and `AppTheme.dark`; omitting any theme in dark is a defect |
| 4 | **`ThemeData` created inside a feature widget** | Theme overrides bleed only into a widget subtree; dark mode and design system updates are not applied | `app_theme.dart` is the only file that creates `ThemeData`; never use `ThemeData(...)` or `Theme(data: ...)` in feature code |
| 5 | **Hardcoded `Color(0xFF...)`, magic-number padding, or inline `TextStyle` in widgets** | Design token changes (rebrand, accessibility update) require hunting down every hardcoded value | Use `AppColors.*`, `AppSpacing.*`, and `AppTypography.*` tokens everywhere; use `Theme.of(context).colorScheme.*` and `Theme.of(context).textTheme.*` for Material-integrated styles |
| 6 | **Repository or data-layer class imports `ThemeCubit` directly** | Dependency inversion violation; data layer depends on presentation layer; circular import risk | Data-layer consumers must inject `ThemeStore` (domain interface), not `ThemeCubit`; register both in DI: `getIt.registerLazySingleton<ThemeStore>(() => getIt<ThemeCubit>())` |
| 7 | **`textTheme` styles wrapped with `_t()` (setting `inherit: false`)** | `Text` widgets stop inheriting color from `DefaultTextStyle`; dark mode text color not applied | Leave `textTheme` styles with `inherit: true` and apply colors via `.apply(bodyColor:, displayColor:)` in `AppTheme`; only non-textTheme component styles use `_t()` |
| 8 | **Feature-specific color constants duplicating `AppColors`** | Two sources of truth for the same color; rebranding requires updating both; review comment flags duplication | Add any new color to `AppColors` and reference it from there; never define `static const Color` inside a feature directory |

## Quick Summary

- **Every color, spacing value, and text style comes from the token files** — no hardcoded `Color(0xFF...)`, magic-number padding, or inline `TextStyle(fontSize: ...)` in widgets.
- **`app_theme.dart` is the only file that builds `ThemeData`** — never create `ThemeData` in feature code or override it mid-tree with `Theme(data: ...)`.
- **`GoogleFonts.inter(...)` returns non-const `TextStyle`** — all `AppTypography` members must be `static TextStyle get` getters, never `static const TextStyle`.
- **Use `_t()` for all non-textTheme component styles** — sets `inherit: false`, explicit `color`, and `textBaseline: TextBaseline.alphabetic`. This prevents three distinct Flutter crashes (TextStyleTween lerp warning, InputDecorator null crash, invisible dark-mode text).
- **`textTheme` styles stay `inherit: true`** — apply colors via `.apply(bodyColor:, displayColor:)`.
- **Both light and dark themes must define the same set of component themes** — omitting a theme in dark causes Flutter to lerp between `inherit: false` and Material's `inherit: true` default during theme switches.
- **`ThemeStore` decouples data layer from `ThemeCubit`** — repositories inject `ThemeStore`, not `ThemeCubit`. Cubits that mutate theme call `setTheme()` on `ThemeStore` directly.

## Folder structure

```text
lib/src/app/theme/
  app_colors.dart      ← Central color tokens and semantic color mapping
  app_spacing.dart     ← Spacing scale, border radii, icon sizes
  app_typography.dart  ← Text styles and TextTheme builder
  app_theme.dart       ← Builds final light and dark ThemeData (only file that creates ThemeData)
lib/src/core/theme/
  theme_store.dart     ← Domain interface for reading/writing ThemeMode
  theme_cubit.dart     ← HydratedCubit that persists ThemeMode, implements ThemeStore
```

## Cross-references

- [flutter-di](../../flutter-di/references/template.md) — `ThemeCubit` and `ThemeStore` are registered as `lazySingleton` in the composition root
- [flutter-localization](../../flutter-localization/references/template.md) — no hardcoded strings should appear alongside theme tokens; locale and theme are set up together in bootstrap
- [flutter-base-classes](../../flutter-base-classes/references/template.md) — `ThemeCubit` extends `HydratedCubit` to persist `ThemeMode` across cold starts

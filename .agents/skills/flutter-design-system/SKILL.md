---
name: flutter-design-system
description: Use this skill when building a Flutter design system — Figma token pipeline, Figma to Dart token export, Widgetbook component catalog, golden tests for components, multi-brand theming, theme extensions, design tokens, component governance, storybook-style component library, or maintaining a shared UI component library.
---

# Flutter Design System

Full reference: [`template.md`](references/template.md)

## Key rules

- Figma → JSON → Dart token pipeline: export design tokens from Figma Style Dictionary → run codegen → output `app_colors.dart`, `app_spacing.dart`, `app_typography.dart`. Tokens are the single source of truth.
- `ThemeExtension<T>` for brand-specific tokens that `ThemeData` doesn't cover natively (custom semantic colors, brand radius, etc.).
- Widgetbook: one `@WidgetbookUseCase` per component variant. Knobs for all configurable properties.
- Golden tests: one golden per component state (default, hover, disabled, error). Run `flutter test --update-goldens` when intentional visual changes happen.
- Component governance: new shared widgets require a Widgetbook entry + golden test before merging.
- Multi-brand: separate `AppConfig.brand` enum drives which `ThemeExtension` values are loaded. Swap at runtime without rebuilding.
- Never hardcode brand-specific colors in components — read from `Theme.of(context).extension<BrandTokens>()`.

## `BrandTokens` interface

```dart
@immutable
class BrandTokens extends ThemeExtension<BrandTokens> {
  const BrandTokens({
    required this.accentPrimary,
    required this.accentSecondary,
    required this.surfaceBrand,
    required this.borderRadius,
    required this.brandName,
  });

  final Color accentPrimary;
  final Color accentSecondary;
  final Color surfaceBrand;
  final double borderRadius;
  final String brandName;

  @override
  BrandTokens copyWith({...}) => BrandTokens(...);

  @override
  BrandTokens lerp(BrandTokens? other, double t) => BrandTokens(
    accentPrimary: Color.lerp(accentPrimary, other?.accentPrimary, t)!,
    // ...
  );
}
```

Usage in widgets:

```dart
final brand = Theme.of(context).extension<BrandTokens>()!;
Container(color: brand.accentPrimary, ...);
```

## Files

```
tools/token_export/           ← Figma export + codegen scripts
lib/src/app/theme/
  brand_tokens.dart           ← ThemeExtension<BrandTokens>
widgetbook/                   ← Widgetbook app (separate package or flavored entry)
test/goldens/                 ← component golden images
```

## Co-load with

- `flutter-app-shell` — tokens integrate into bootstrap and AppConfig brand enum
- `flutter-theme` — tokens feed AppColors/AppSpacing/AppTypography
- `flutter-common-widgets` — components registered in Widgetbook
- `flutter-tests` — golden test setup
- `flutter-ci` — golden diffs in CI
- `flutter-accessibility` — WCAG contrast check per component

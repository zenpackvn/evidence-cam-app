# Template — Design System

Component catalog, Widgetbook integration, Figma → Dart token pipeline, and design system governance. Builds on top of [template-theme.md](template-theme.md) (tokens) and [template-common-widgets.md](template-common-widgets.md) (components).

| Already covered | This template adds |
|---|---|
| `AppColors`, `AppSpacing`, `AppTypography` (hand-coded) | Figma → JSON → Dart automated token pipeline |
| Individual widget files in `core/widgets/` | Widgetbook catalog with use-cases, knobs, and golden tests |
| Light + dark `ThemeData` | Multi-brand token sets, token aliasing, theme preview |
| Inline usage examples in template code | Living documentation: each component shows all variants, states, and API |

## Topics

| Topic | File |
|---|---|
| Figma → JSON → Dart pipeline: token JSON schema, generator script, generated output, alias bridge, Makefile | [token_pipeline.md](token_pipeline.md) |
| Widgetbook package setup, `pubspec.yaml`, `main.dart`, addons, running locally | [widgetbook_setup.md](widgetbook_setup.md) |
| Use-case examples: token preview, button knobs, text field states | [widgetbook_use_cases.md](widgetbook_use_cases.md) |
| `ComponentDoc` widget, golden test patterns, update/check commands | [component_doc_and_golden_tests.md](component_doc_and_golden_tests.md) |
| Multi-brand `BrandTheme`, component lifecycle, token drift CI, anti-patterns | [multi_brand_and_governance.md](multi_brand_and_governance.md) |

## ⚠️ Common Mistakes

> These are the most frequent design-system bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Editing `design_tokens.dart` by hand** | Hand-added constants are overwritten on the next generator run; token drift is silently introduced | Only edit `design_tokens.json`; run `dart run lib/src/core/design_system/tokens/token_generator.dart` to regenerate — the file header says `GENERATED — do not edit by hand` |
| 2 | **Widgets referencing `DesignTokenColors.*` directly instead of `AppColors.*`** | Token rename in the generated file breaks every widget that imports it; the alias layer is bypassed | Widgets always use `AppColors.primary`, `AppSpacing.md`, etc. — the `AppColors`/`AppSpacing`/`AppTypography` files are the single source of truth for widgets |
| 3 | **Importing `package:widgetbook/widgetbook.dart` in the main app** | Widgetbook dev tooling becomes a runtime dependency; app bundle size grows and catalog tooling leaks into production | Widgetbook lives in its own separate package (`widgetbook/`); the main app never imports it — only `widgetbook/` imports the main app via `path: ../` |
| 4 | **Skipping golden tests for new Widgetbook use-cases** | Visual regressions in the new component go undetected; CI has no signal when a style change breaks the component | Every Widgetbook use-case must have a corresponding golden test covering all variants (enabled, disabled, loading, error, light, dark); commit golden files and update with `flutter test --update-goldens` |
| 5 | **Creating parallel `AppColors` subclasses per brand** | Brand switching requires changing import statements; shared tokens diverge; dark mode overrides must be duplicated | Use `BrandTheme.fromBrand(primary: ..., secondary: ...)` which calls `AppTheme.light.copyWith(colorScheme: ...)` — one `AppColors` class aliased from generated tokens for all brands |
| 6 | **Running `build_runner` to generate tokens** | Token generator errors with a `build_runner` plugin not found; the generator has no `build_runner` dependency | The token generator is a plain Dart script using `dart:io` + `dart:convert` only; run it with `dart run lib/src/core/design_system/tokens/token_generator.dart` — no `build_runner` involved |
| 7 | **No token drift CI check** | Figma tokens are updated but `design_tokens.dart` is not regenerated; the app ships stale colors/spacing for weeks | Add the `token-drift.yml` workflow that re-runs the generator weekly and fails if `git diff` shows changes to `design_tokens.dart` |
| 8 | **Skipping Widgetbook use-case for a new component** | The component has no interactive catalog; reviewers cannot verify all states (disabled, loading, error, dark mode) without building a feature | Create one use-case file per widget file (`app_button.dart` → `widgetbook/lib/components/buttons.dart`) with knobs for every configurable prop and a variant showing all states |

## Quick Summary

- **Token source of truth chain**: `design_tokens.json` (Figma export) → `design_tokens.dart` (generated, never edit by hand) → `AppColors`/`AppSpacing`/`AppTypography` (aliased). Widgets always use `AppColors.primary`, not `DesignTokenColors.brandPrimary`.
- **Token generator is pure Dart** — `dart:io` + `dart:convert` only. No `build_runner`. Run with `dart run lib/src/core/design_system/tokens/token_generator.dart`.
- **Widgetbook is a separate package** — it imports the main app via `path: ../`, but the main app never imports Widgetbook. No DI wrapper needed for dev tools.
- **One use-case file per widget file** — `app_button.dart` → `widgetbook/lib/components/buttons.dart`.
- **Golden test every variant** — enabled, disabled, loading, error, light theme, dark theme. Committed golden files catch visual regressions automatically.
- **Multi-brand via `ThemeData.copyWith`** — don't create parallel `AppColors` trees. Override brand tokens in `BrandTheme.fromBrand(primary: ..., secondary: ...)`.
- **Component lifecycle**: Proposal → Draft → Review → Stable. Add `@Deprecated` before removal; never delete without a migration guide.
- **CI catches token drift** — run the generator weekly; fail the workflow if `design_tokens.dart` changes unexpectedly.

## Cross-references

- [template-theme.md](template-theme.md) — `AppColors`, `AppSpacing`, `AppTypography`, `AppTheme` (the alias layer)
- [template-common-widgets.md](template-common-widgets.md) — Widget implementations that Widgetbook catalogs
- [template-loading.md](template-loading.md) — Loading components (`LoadingButton`, `SuperListView`) in the catalog
- [template-dialog.md](template-dialog.md) — Dialog components in the catalog
- [template-tests.md](template-tests.md) — Golden testing patterns
- [template-ci.md](template-ci.md) — Token drift detection CI workflow
- [template-accessibility.md](template-accessibility.md) — Contrast, semantics, tap target checks for components

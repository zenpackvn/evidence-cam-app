# Multi-Brand Token Sets and Design System Governance

## Multi-brand token sets

For white-label apps that serve multiple brands from the same codebase:

```json
// design_tokens_brand_a.json
{
  "color": {
    "brand": {
      "primary": { "value": "#1A73E8", "type": "color" },
      "secondary": { "value": "#34A853", "type": "color" }
    }
  }
}

// design_tokens_brand_b.json
{
  "color": {
    "brand": {
      "primary": { "value": "#FF6B00", "type": "color" },
      "secondary": { "value": "#7C4DFF", "type": "color" }
    }
  }
}
```

```dart
// lib/src/app/theme/brand_theme.dart
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Builds brand-specific ThemeData by overriding base tokens.
abstract final class BrandTheme {
  static ThemeData fromBrand({
    required Color primary,
    required Color secondary,
    Brightness brightness = Brightness.light,
  }) {
    final base = brightness == Brightness.light ? AppTheme.light : AppTheme.dark;
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: secondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: base.elevatedButtonTheme.style?.copyWith(
          backgroundColor: WidgetStatePropertyAll(primary),
        ),
      ),
    );
  }
}
```

**Don't** create parallel color classes per brand — use `ThemeData.copyWith` to override brand tokens from the base theme.

## Component lifecycle

| Stage | Description | What's needed |
|---|---|---|
| **Proposal** | Designer or dev proposes a new component | Figma spec, use cases, similar existing components checked |
| **Draft** | Implementation with wrapper rule + DI | Code + Widgetbook use-case + unit test |
| **Review** | Team review: API, states, accessibility | PR review, Widgetbook walkthrough |
| **Stable** | Merged, documented, golden tested | Golden files committed, token preview updated |
| **Deprecated** | Superseded by new component | `@Deprecated` annotation, migration guide |

## Token drift detection — CI workflow

```yaml
# .github/workflows/token-drift.yml
name: Token Drift Check
on:
  schedule:
    - cron: '0 9 * * 1'  # Weekly Monday 9am
  workflow_dispatch:

jobs:
  check-tokens:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - name: Re-generate tokens
        run: dart run lib/src/core/design_system/tokens/token_generator.dart
      - name: Check for drift
        run: |
          if git diff --quiet lib/src/core/design_system/tokens/design_tokens.dart; then
            echo "Tokens in sync."
          else
            echo "::warning::design_tokens.dart has drifted from design_tokens.json"
            git diff lib/src/core/design_system/tokens/design_tokens.dart
            exit 1
          fi
```

## Anti-patterns

### DON'T: Edit generated token files by hand

```dart
// BAD — manual edit in design_tokens.dart
abstract final class DesignTokenColors {
  static const Color brandPrimary = Color(0xFF1A73E8);
  static const Color brandAccent = Color(0xFFFF5722); // hand-added, will be lost on next generate
}

// GOOD — add to design_tokens.json, re-run generator
// Or add to AppColors directly (for app-specific tokens not in Figma)
```

### DON'T: Import Widgetbook in the main app

```dart
// BAD — Widgetbook is a dev tool, not a runtime dependency
import 'package:widgetbook/widgetbook.dart';

// GOOD — Widgetbook lives in its own package: widgetbook/
// Main app never knows it exists
```

### DON'T: Skip golden tests for new components

```dart
// BAD — component added to Widgetbook but no golden test
// Visual regressions go undetected

// GOOD — every Widgetbook use-case has a corresponding golden test
// Run: flutter test --update-goldens
```

### DON'T: Duplicate tokens across brand themes

```dart
// BAD — separate color classes per brand
class BrandAColors { static const primary = Color(0xFF1A73E8); }
class BrandBColors { static const primary = Color(0xFFFF6B00); }

// GOOD — one AppColors aliased from DesignTokenColors
// Brand variation via ThemeData.copyWith in BrandTheme
```

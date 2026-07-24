# Figma → Dart Token Pipeline

Automated pipeline: export design tokens from Figma as JSON, run a pure-Dart generator script, and alias the output into the existing `AppColors`/`AppSpacing`/`AppTypography` layer.

## Folder structure

```text
lib/src/
  core/
    design_system/
      tokens/
        design_tokens.dart             ← Generated from Figma JSON (colors, spacing, typography, radii, shadows, durations)
        token_generator.dart           ← Script: reads JSON → writes design_tokens.dart
      components/
        component_doc.dart             ← ComponentDoc widget for self-documenting components
    widgets/
      common/                          ← Existing common widgets (template-common-widgets.md)
    theme/                             ← Existing theme tokens (template-theme.md)
```

## Step 1: Export tokens from Figma

Use the [Tokens Studio](https://tokens.studio/) Figma plugin (or Figma Variables API) to export design tokens as JSON.

**Expected JSON structure** (`design_tokens.json`):

```json
{
  "color": {
    "brand": {
      "primary": { "value": "#1A73E8", "type": "color" },
      "primaryDark": { "value": "#1557B0", "type": "color" },
      "secondary": { "value": "#34A853", "type": "color" }
    },
    "neutral": {
      "background": { "value": "#F8F9FA", "type": "color" },
      "surface": { "value": "#FFFFFF", "type": "color" },
      "surfaceDark": { "value": "#1E1E1E", "type": "color" },
      "divider": { "value": "#E0E0E0", "type": "color" }
    },
    "text": {
      "primary": { "value": "#202124", "type": "color" },
      "secondary": { "value": "#5F6368", "type": "color" },
      "onPrimary": { "value": "#FFFFFF", "type": "color" }
    },
    "semantic": {
      "error": { "value": "#D93025", "type": "color" },
      "success": { "value": "#34A853", "type": "color" },
      "warning": { "value": "#FBBC04", "type": "color" },
      "info": { "value": "#4285F4", "type": "color" }
    }
  },
  "spacing": {
    "xxs": { "value": 4, "type": "spacing" },
    "xs": { "value": 8, "type": "spacing" },
    "sm": { "value": 12, "type": "spacing" },
    "md": { "value": 16, "type": "spacing" },
    "lg": { "value": 20, "type": "spacing" },
    "xl": { "value": 24, "type": "spacing" },
    "xxl": { "value": 32, "type": "spacing" },
    "xxxl": { "value": 40, "type": "spacing" }
  },
  "radius": {
    "sm": { "value": 8, "type": "borderRadius" },
    "md": { "value": 12, "type": "borderRadius" },
    "lg": { "value": 16, "type": "borderRadius" },
    "xl": { "value": 24, "type": "borderRadius" },
    "full": { "value": 999, "type": "borderRadius" }
  },
  "typography": {
    "displayLarge": {
      "value": { "fontFamily": "Roboto", "fontSize": 32, "fontWeight": 700, "lineHeight": 1.25, "letterSpacing": -0.5 },
      "type": "typography"
    },
    "headlineLarge": {
      "value": { "fontFamily": "Roboto", "fontSize": 24, "fontWeight": 600, "lineHeight": 1.33 },
      "type": "typography"
    },
    "bodyMedium": {
      "value": { "fontFamily": "Roboto", "fontSize": 14, "fontWeight": 400, "lineHeight": 1.43, "letterSpacing": 0.15 },
      "type": "typography"
    },
    "labelLarge": {
      "value": { "fontFamily": "Roboto", "fontSize": 14, "fontWeight": 500, "lineHeight": 1.43, "letterSpacing": 0.1 },
      "type": "typography"
    }
  },
  "shadow": {
    "sm": { "value": { "x": 0, "y": 1, "blur": 3, "spread": 0, "color": "#0000001A" }, "type": "boxShadow" },
    "md": { "value": { "x": 0, "y": 4, "blur": 8, "spread": -1, "color": "#00000026" }, "type": "boxShadow" },
    "lg": { "value": { "x": 0, "y": 8, "blur": 24, "spread": -4, "color": "#00000033" }, "type": "boxShadow" }
  },
  "duration": {
    "fast": { "value": 150, "type": "duration" },
    "normal": { "value": 300, "type": "duration" },
    "slow": { "value": 500, "type": "duration" }
  }
}
```

## Step 2: Token generator script

```dart
// lib/src/core/design_system/tokens/token_generator.dart
// Run: dart run lib/src/core/design_system/tokens/token_generator.dart
//
// Reads design_tokens.json → writes design_tokens.dart
// No third-party imports — pure dart:io + dart:convert.

import 'dart:convert';
import 'dart:io';

void main() {
  final input = File('design_tokens.json');
  if (!input.existsSync()) {
    stderr.writeln('design_tokens.json not found in cwd.');
    exit(1);
  }

  final json = jsonDecode(input.readAsStringSync()) as Map<String, dynamic>;
  final buffer = StringBuffer();

  buffer.writeln("// GENERATED — do not edit by hand.");
  buffer.writeln("// Run: dart run lib/src/core/design_system/tokens/token_generator.dart");
  buffer.writeln("// Source: design_tokens.json (exported from Figma Tokens Studio)");
  buffer.writeln();
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln();

  _generateColors(buffer, json['color'] as Map<String, dynamic>? ?? {});
  _generateSpacing(buffer, json['spacing'] as Map<String, dynamic>? ?? {});
  _generateRadius(buffer, json['radius'] as Map<String, dynamic>? ?? {});
  _generateTypography(buffer, json['typography'] as Map<String, dynamic>? ?? {});
  _generateShadows(buffer, json['shadow'] as Map<String, dynamic>? ?? {});
  _generateDurations(buffer, json['duration'] as Map<String, dynamic>? ?? {});

  final output = File('lib/src/core/design_system/tokens/design_tokens.dart');
  output.createSync(recursive: true);
  output.writeAsStringSync(buffer.toString());
  stdout.writeln('Generated ${output.path}');
}

void _generateColors(StringBuffer b, Map<String, dynamic> groups) {
  b.writeln('abstract final class DesignTokenColors {');
  for (final entry in groups.entries) {
    final group = entry.value as Map<String, dynamic>;
    b.writeln('  // ── ${_capitalize(entry.key)} ──');
    for (final token in group.entries) {
      final value = token.value['value'] as String;
      final hex = value.replaceFirst('#', '');
      final color = hex.length == 6 ? 'FF$hex' : hex;
      b.writeln("  static const Color ${_camelCase('${entry.key}_${token.key}')} = Color(0x$color);");
    }
    b.writeln();
  }
  b.writeln('}');
  b.writeln();
}

void _generateSpacing(StringBuffer b, Map<String, dynamic> tokens) {
  b.writeln('abstract final class DesignTokenSpacing {');
  for (final entry in tokens.entries) {
    final value = entry.value['value'];
    b.writeln('  static const double ${entry.key} = ${value}.0;');
  }
  b.writeln('}');
  b.writeln();
}

void _generateRadius(StringBuffer b, Map<String, dynamic> tokens) {
  b.writeln('abstract final class DesignTokenRadius {');
  for (final entry in tokens.entries) {
    final value = entry.value['value'];
    b.writeln('  static const double ${entry.key} = ${value}.0;');
  }
  b.writeln('}');
  b.writeln();
}

void _generateTypography(StringBuffer b, Map<String, dynamic> tokens) {
  b.writeln('abstract final class DesignTokenTypography {');
  for (final entry in tokens.entries) {
    final v = entry.value['value'] as Map<String, dynamic>;
    final family = v['fontFamily'] ?? 'Roboto';
    final size = v['fontSize'] ?? 14;
    final weight = _fontWeight(v['fontWeight'] ?? 400);
    final height = v['lineHeight'] ?? 1.5;
    final spacing = v['letterSpacing'] ?? 0;
    b.writeln('  static const TextStyle ${entry.key} = TextStyle(');
    b.writeln("    fontFamily: '$family',");
    b.writeln('    fontSize: $size,');
    b.writeln('    fontWeight: $weight,');
    b.writeln('    height: $height,');
    if (spacing != 0) b.writeln('    letterSpacing: $spacing,');
    b.writeln('  );');
    b.writeln();
  }
  b.writeln('}');
  b.writeln();
}

void _generateShadows(StringBuffer b, Map<String, dynamic> tokens) {
  b.writeln('abstract final class DesignTokenShadows {');
  for (final entry in tokens.entries) {
    final v = entry.value['value'] as Map<String, dynamic>;
    final hex = (v['color'] as String).replaceFirst('#', '');
    // Figma exports RGBA (#RRGGBBAA); Dart Color expects ARGB (0xAARRGGBB).
    final color = hex.length == 8
        ? '${hex.substring(6)}${hex.substring(0, 6)}'
        : 'FF$hex';
    b.writeln('  static const BoxShadow ${entry.key} = BoxShadow(');
    b.writeln('    offset: Offset(${v['x']}, ${v['y']}),');
    b.writeln('    blurRadius: ${v['blur']}.0,');
    b.writeln('    spreadRadius: ${v['spread']}.0,');
    b.writeln('    color: Color(0x$color),');
    b.writeln('  );');
    b.writeln();
  }
  b.writeln('}');
  b.writeln();
}

void _generateDurations(StringBuffer b, Map<String, dynamic> tokens) {
  b.writeln('abstract final class DesignTokenDurations {');
  for (final entry in tokens.entries) {
    final value = entry.value['value'];
    b.writeln('  static const Duration ${entry.key} = Duration(milliseconds: $value);');
  }
  b.writeln('}');
  b.writeln();
}

String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

String _camelCase(String s) {
  final parts = s.split('_');
  return parts.first + parts.skip(1).map(_capitalize).join();
}

String _fontWeight(dynamic w) {
  final weight = w is int ? w : int.tryParse(w.toString()) ?? 400;
  return switch (weight) {
    100 => 'FontWeight.w100',
    200 => 'FontWeight.w200',
    300 => 'FontWeight.w300',
    400 => 'FontWeight.w400',
    500 => 'FontWeight.w500',
    600 => 'FontWeight.w600',
    700 => 'FontWeight.w700',
    800 => 'FontWeight.w800',
    900 => 'FontWeight.w900',
    _ => 'FontWeight.w400',
  };
}
```

## Step 3: Generated output (example)

```dart
// lib/src/core/design_system/tokens/design_tokens.dart
// GENERATED — do not edit by hand.
// Run: dart run lib/src/core/design_system/tokens/token_generator.dart
// Source: design_tokens.json (exported from Figma Tokens Studio)

import 'package:flutter/material.dart';

abstract final class DesignTokenColors {
  // ── Brand ──
  static const Color brandPrimary = Color(0xFF1A73E8);
  static const Color brandPrimaryDark = Color(0xFF1557B0);
  static const Color brandSecondary = Color(0xFF34A853);

  // ── Neutral ──
  static const Color neutralBackground = Color(0xFFF8F9FA);
  static const Color neutralSurface = Color(0xFFFFFFFF);
  static const Color neutralSurfaceDark = Color(0xFF1E1E1E);
  static const Color neutralDivider = Color(0xFFE0E0E0);

  // ── Text ──
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Semantic ──
  static const Color semanticError = Color(0xFFD93025);
  static const Color semanticSuccess = Color(0xFF34A853);
  static const Color semanticWarning = Color(0xFFFBBC04);
  static const Color semanticInfo = Color(0xFF4285F4);
}

abstract final class DesignTokenSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
}

abstract final class DesignTokenShadows {
  // Shadow colors: Figma RGBA #0000001A → Dart ARGB 0x1A000000
  static const BoxShadow sm = BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 3.0,
    spreadRadius: 0.0,
    color: Color(0x1A000000),
  );

  static const BoxShadow md = BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 8.0,
    spreadRadius: -1.0,
    color: Color(0x26000000),
  );

  static const BoxShadow lg = BoxShadow(
    offset: Offset(0, 8),
    blurRadius: 24.0,
    spreadRadius: -4.0,
    color: Color(0x33000000),
  );
}

// ... DesignTokenRadius, DesignTokenTypography, DesignTokenDurations
```

## Step 4: Bridge generated tokens → AppColors / AppSpacing / AppTypography

**Do not replace the existing theme files.** Instead, alias generated tokens into them:

```dart
// lib/src/app/theme/app_colors.dart
import '../../core/design_system/tokens/design_tokens.dart';

abstract final class AppColors {
  // ── Brand (aliased from generated tokens) ──
  static const Color primary = DesignTokenColors.brandPrimary;
  static const Color primaryDark = DesignTokenColors.brandPrimaryDark;
  static const Color secondary = DesignTokenColors.brandSecondary;

  // ── Neutral ──
  static const Color background = DesignTokenColors.neutralBackground;
  static const Color surface = DesignTokenColors.neutralSurface;
  static const Color surfaceDark = DesignTokenColors.neutralSurfaceDark;
  static const Color divider = DesignTokenColors.neutralDivider;

  // ── Text ──
  static const Color textPrimary = DesignTokenColors.textPrimary;
  static const Color textSecondary = DesignTokenColors.textSecondary;
  static const Color textOnPrimary = DesignTokenColors.textOnPrimary;

  // ── Semantic ──
  static const Color error = DesignTokenColors.semanticError;
  static const Color success = DesignTokenColors.semanticSuccess;
  static const Color warning = DesignTokenColors.semanticWarning;
  static const Color info = DesignTokenColors.semanticInfo;

  // ... ColorSchemes unchanged
}
```

This way:
- **AppColors/AppSpacing/AppTypography remain the single source of truth** for widgets
- **DesignTokens is the single source of truth** for values from Figma
- Designers update Figma → export JSON → run generator → tokens flow through automatically
- Hand-coded overrides are still possible (just don't alias that token)

## Token pipeline automation

```yaml
# Makefile or script
.PHONY: sync-tokens
sync-tokens:
	@echo "Downloading tokens from Figma..."
	# Option A: Tokens Studio CLI
	# npx token-transformer design_tokens.json design_tokens_resolved.json
	# Option B: Figma Variables API (requires access token)
	# curl -H "X-Figma-Token: $(FIGMA_TOKEN)" \
	#   "https://api.figma.com/v1/files/$(FILE_KEY)/variables/local" \
	#   -o design_tokens.json
	@echo "Generating Dart tokens..."
	dart run lib/src/core/design_system/tokens/token_generator.dart
	@echo "Running analyze..."
	flutter analyze --no-pub
	@echo "Tokens synced."
```

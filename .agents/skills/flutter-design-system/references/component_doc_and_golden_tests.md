# ComponentDoc Widget and Golden Tests

## ComponentDoc — self-documenting components

For self-documenting components inside the main app (not just Widgetbook):

```dart
// lib/src/core/design_system/components/component_doc.dart
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Wraps a widget example with a title, description, and code snippet.
/// Used in Widgetbook use-cases and internal dev documentation.
class ComponentDoc extends StatelessWidget {
  final String name;
  final String? description;
  final String? codeSnippet;
  final Widget child;

  const ComponentDoc({
    super.key,
    required this.name,
    this.description,
    this.codeSnippet,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: AppTypography.headlineSmall),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(description!, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: child,
          ),
          if (codeSnippet != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: SelectableText(
                codeSnippet!,
                style: AppTypography.bodySmall.copyWith(
                  fontFamily: 'monospace',
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

## Golden Tests from Widgetbook

Generate golden tests that catch visual regressions for each component state:

```dart
// widgetbook/test/golden/button_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/src/app/theme/app_theme.dart';
import 'package:my_app/src/core/widgets/common/app_button.dart';

void main() {
  group('AppButton golden tests', () {
    Future<void> pumpButton(
      WidgetTester tester, {
      required String variant,
      VoidCallback? onPressed,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: AppButton(label: 'Continue', onPressed: onPressed),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('enabled - light', (tester) async {
      await pumpButton(tester, variant: 'enabled', onPressed: () {});
      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_enabled_light.png'),
      );
    });

    testWidgets('disabled - light', (tester) async {
      await pumpButton(tester, variant: 'disabled');
      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_disabled_light.png'),
      );
    });

    testWidgets('enabled - dark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Center(
              child: AppButton(label: 'Continue', onPressed: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_enabled_dark.png'),
      );
    });
  });
}
```

```bash
# Generate golden files
cd widgetbook && flutter test --update-goldens

# Check for regressions
cd widgetbook && flutter test
```

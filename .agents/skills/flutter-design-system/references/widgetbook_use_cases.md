# Widgetbook Use-Case Examples

Component use-case files demonstrating interactive knobs and variant showcases.

## Token preview page — `token_preview.dart`

```dart
// widgetbook/lib/theme/token_preview.dart
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:my_app/src/app/theme/app_colors.dart';
import 'package:my_app/src/app/theme/app_spacing.dart';
import 'package:my_app/src/app/theme/app_typography.dart';
import 'package:my_app/src/core/design_system/tokens/design_tokens.dart';

WidgetbookComponent colorPaletteComponent() {
  return WidgetbookComponent(
    name: 'Color Palette',
    useCases: [
      WidgetbookUseCase(
        name: 'All Colors',
        builder: (context) => const _ColorPalette(),
      ),
    ],
  );
}

class _ColorPalette extends StatelessWidget {
  const _ColorPalette();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _colorSection('Brand', [
          _ColorSwatch('primary', AppColors.primary),
          _ColorSwatch('primaryDark', AppColors.primaryDark),
          _ColorSwatch('secondary', AppColors.secondary),
        ]),
        _colorSection('Neutral', [
          _ColorSwatch('background', AppColors.background),
          _ColorSwatch('surface', AppColors.surface),
          _ColorSwatch('divider', AppColors.divider),
        ]),
        _colorSection('Semantic', [
          _ColorSwatch('error', AppColors.error),
          _ColorSwatch('success', AppColors.success),
          _ColorSwatch('warning', AppColors.warning),
          _ColorSwatch('info', AppColors.info),
        ]),
        _colorSection('Text', [
          _ColorSwatch('textPrimary', AppColors.textPrimary),
          _ColorSwatch('textSecondary', AppColors.textSecondary),
          _ColorSwatch('textOnPrimary', AppColors.textOnPrimary),
        ]),
      ],
    );
  }

  Widget _colorSection(String title, List<_ColorSwatch> swatches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(title, style: AppTypography.headlineSmall),
        ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: swatches.map((s) => _buildSwatch(s)).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildSwatch(_ColorSwatch swatch) {
    final hex = '#${swatch.color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: swatch.color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(swatch.name, style: AppTypography.labelSmall),
        Text(hex, style: AppTypography.caption),
      ],
    );
  }
}

class _ColorSwatch {
  final String name;
  final Color color;
  const _ColorSwatch(this.name, this.color);
}

WidgetbookComponent spacingScaleComponent() {
  return WidgetbookComponent(
    name: 'Spacing Scale',
    useCases: [
      WidgetbookUseCase(
        name: 'All Spacings',
        builder: (context) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _spacingRow('xxs', AppSpacing.xxs),
            _spacingRow('xs', AppSpacing.xs),
            _spacingRow('sm', AppSpacing.sm),
            _spacingRow('md', AppSpacing.md),
            _spacingRow('lg', AppSpacing.lg),
            _spacingRow('xl', AppSpacing.xl),
            _spacingRow('xxl', AppSpacing.xxl),
            _spacingRow('xxxl', AppSpacing.xxxl),
          ],
        ),
      ),
    ],
  );
}

Widget _spacingRow(String name, double value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      children: [
        SizedBox(
          width: 60,
          child: Text('$name (${value.toInt()})', style: AppTypography.bodySmall),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(width: value, height: 24, color: AppColors.primary),
      ],
    ),
  );
}

WidgetbookComponent typographyPreviewComponent() {
  return WidgetbookComponent(
    name: 'Typography',
    useCases: [
      WidgetbookUseCase(
        name: 'All Styles',
        builder: (context) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _typographyRow('displayLarge', AppTypography.displayLarge),
            _typographyRow('displayMedium', AppTypography.displayMedium),
            _typographyRow('headlineLarge', AppTypography.headlineLarge),
            _typographyRow('headlineMedium', AppTypography.headlineMedium),
            _typographyRow('headlineSmall', AppTypography.headlineSmall),
            _typographyRow('titleLarge', AppTypography.titleLarge),
            _typographyRow('titleMedium', AppTypography.titleMedium),
            _typographyRow('bodyLarge', AppTypography.bodyLarge),
            _typographyRow('bodyMedium', AppTypography.bodyMedium),
            _typographyRow('bodySmall', AppTypography.bodySmall),
            _typographyRow('labelLarge', AppTypography.labelLarge),
            _typographyRow('labelSmall', AppTypography.labelSmall),
          ],
        ),
      ),
    ],
  );
}

Widget _typographyRow(String name, TextStyle style) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: AppTypography.caption),
        Text('The quick brown fox jumps over the lazy dog', style: style),
        Text(
          '${style.fontSize}px / w${style.fontWeight?.value ?? 400} / ${style.height}x',
          style: AppTypography.caption,
        ),
        const Divider(),
      ],
    ),
  );
}

WidgetbookComponent shadowPreviewComponent() {
  return WidgetbookComponent(
    name: 'Shadows',
    useCases: [
      WidgetbookUseCase(
        name: 'All Shadows',
        builder: (context) => ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            _shadowCard('sm', DesignTokenShadows.sm),
            _shadowCard('md', DesignTokenShadows.md),
            _shadowCard('lg', DesignTokenShadows.lg),
          ],
        ),
      ),
    ],
  );
}

Widget _shadowCard(String name, BoxShadow shadow) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
    child: Column(
      children: [
        Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [shadow],
          ),
          alignment: Alignment.center,
          child: Text('shadow.$name', style: AppTypography.bodyMedium),
        ),
      ],
    ),
  );
}
```

## Button use-cases — `buttons.dart`

```dart
// widgetbook/lib/components/buttons.dart
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:my_app/src/core/widgets/common/app_button.dart';
import 'package:my_app/src/core/widgets/common/app_loading_button.dart';
import 'package:my_app/src/app/theme/app_spacing.dart';

List<WidgetbookComponent> buttonUseCases() {
  return [
    WidgetbookComponent(
      name: 'AppButton',
      useCases: [
        WidgetbookUseCase(
          name: 'Primary',
          builder: (context) => Center(
            child: AppButton(
              label: context.knobs.string(label: 'Label', initialValue: 'Continue'),
              onPressed: context.knobs.boolean(label: 'Enabled', initialValue: true)
                  ? () {}
                  : null,
              isExpanded: context.knobs.boolean(label: 'Expanded', initialValue: false),
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'All Variants',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(label: 'Primary', onPressed: () {}),
                const SizedBox(height: AppSpacing.sm),
                AppOutlinedButton(label: 'Outlined', onPressed: () {}),
                const SizedBox(height: AppSpacing.sm),
                AppTextButton(label: 'Text', onPressed: () {}),
                const SizedBox(height: AppSpacing.sm),
                AppIconButton(icon: Icons.add, onPressed: () {}),
                const SizedBox(height: AppSpacing.xl),
                const AppButton(label: 'Disabled', onPressed: null),
                const SizedBox(height: AppSpacing.sm),
                const AppOutlinedButton(label: 'Disabled', onPressed: null),
              ],
            ),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'LoadingButton',
      useCases: [
        WidgetbookUseCase(
          name: 'Interactive',
          builder: (context) => Center(
            child: LoadingButton(
              label: context.knobs.string(label: 'Label', initialValue: 'Submit'),
              isLoading: context.knobs.boolean(label: 'Loading', initialValue: false),
              onPressed: () {},
            ),
          ),
        ),
      ],
    ),
  ];
}
```

## Text field use-cases — `text_fields.dart`

```dart
// widgetbook/lib/components/text_fields.dart
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:my_app/src/core/widgets/common/app_text_field.dart';
import 'package:my_app/src/core/widgets/common/app_password_field.dart';
import 'package:my_app/src/core/widgets/common/app_search_field.dart';
import 'package:my_app/src/app/theme/app_spacing.dart';

List<WidgetbookComponent> textFieldUseCases() {
  return [
    WidgetbookComponent(
      name: 'AppTextField',
      useCases: [
        WidgetbookUseCase(
          name: 'Interactive',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppTextField(
              label: context.knobs.string(label: 'Label', initialValue: 'Email'),
              hint: context.knobs.string(label: 'Hint', initialValue: 'you@example.com'),
              errorText: context.knobs.stringOrNull(label: 'Error text'),
              enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
              prefixIcon: context.knobs.boolean(label: 'Prefix icon', initialValue: false)
                  ? const Icon(Icons.email)
                  : null,
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'All States',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                const AppTextField(label: 'Default', hint: 'Placeholder'),
                const SizedBox(height: AppSpacing.md),
                const AppTextField(label: 'With Value', hint: 'Placeholder', initialValue: 'hello@example.com'),
                const SizedBox(height: AppSpacing.md),
                const AppTextField(label: 'Error', hint: 'Placeholder', errorText: 'Invalid email'),
                const SizedBox(height: AppSpacing.md),
                const AppTextField(label: 'Disabled', hint: 'Placeholder', enabled: false),
              ],
            ),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'AppPasswordField',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: AppPasswordField(label: 'Password'),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'AppSearchField',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppSearchField(
              hint: context.knobs.string(label: 'Hint', initialValue: 'Search posts...'),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    ),
  ];
}
```

# Widgetbook Integration

Component catalog with use-cases, knobs, theme/device/locale addons, and golden test generation.

## Folder structure

```text
widgetbook/
  lib/
    main.dart                          ← Widgetbook app entry point
    components/                        ← Use-case files organized by category
      buttons.dart
      text_fields.dart
      cards.dart
      dialogs.dart
      loading.dart
      navigation.dart
      feedback.dart
      layout.dart
    theme/
      token_preview.dart               ← Color palette, spacing scale, typography preview
  pubspec.yaml                         ← Separate package, imports the main app
  test/
    golden/                            ← Golden tests generated from widgetbook use-cases
```

## `widgetbook/pubspec.yaml`

```yaml
name: widgetbook_app
description: Component catalog for the design system.
publish_to: 'none'

environment:
  sdk: ">= 3.6.0 < 4.0.0"
  flutter: ">= 3.27.0 < 4.0.0"

dependencies:
  flutter:
    sdk: flutter
  widgetbook: 3.10.0
  widgetbook_annotation: 3.2.0
  # Import the main app as a path dependency
  my_app:
    path: ../

dev_dependencies:
  flutter_test:
    sdk: flutter
  widgetbook_generator: 3.9.0
  build_runner: 2.4.13
```

> **Wrapper rule**: `widgetbook` is a dev tool, not a runtime dependency. It lives in its own package and is never imported by the main app. No wrapper needed.

## `widgetbook/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:my_app/src/app/theme/app_theme.dart';

import 'components/buttons.dart';
import 'components/text_fields.dart';
import 'components/cards.dart';
import 'components/dialogs.dart';
import 'components/loading.dart';
import 'components/navigation.dart';
import 'components/feedback.dart';
import 'components/layout.dart';
import 'theme/token_preview.dart';

void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      appBuilder: (context, child) => child,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: AppTheme.light),
            WidgetbookTheme(name: 'Dark', data: AppTheme.dark),
          ],
        ),
        DeviceFrameAddon(
          devices: [
            Devices.ios.iPhone13,
            Devices.ios.iPadPro11Inches,
            Devices.android.samsungGalaxyS20,
          ],
        ),
        TextScaleAddon(scales: [1.0, 1.5, 2.0]),
        LocalizationAddon(
          locales: [const Locale('en'), const Locale('vi'), const Locale('ar')],
          localizationsDelegates: [
            // App's localization delegates
          ],
        ),
      ],
      directories: [
        WidgetbookFolder(
          name: 'Tokens',
          children: [
            colorPaletteComponent(),
            spacingScaleComponent(),
            typographyPreviewComponent(),
            shadowPreviewComponent(),
          ],
        ),
        WidgetbookFolder(name: 'Buttons', children: buttonUseCases()),
        WidgetbookFolder(name: 'Text Fields', children: textFieldUseCases()),
        WidgetbookFolder(name: 'Cards', children: cardUseCases()),
        WidgetbookFolder(name: 'Dialogs', children: dialogUseCases()),
        WidgetbookFolder(name: 'Loading', children: loadingUseCases()),
        WidgetbookFolder(name: 'Navigation', children: navigationUseCases()),
        WidgetbookFolder(name: 'Feedback', children: feedbackUseCases()),
        WidgetbookFolder(name: 'Layout', children: layoutUseCases()),
      ],
    );
  }
}
```

## Running Widgetbook

```bash
cd widgetbook
flutter pub get
flutter run -d chrome          # Browser (best for sharing)
flutter run -d macos            # Desktop
flutter run -d <device-id>      # Mobile
```

# Localization — DI Registration and App Root Integration

## DI Registration

```dart
// lib/src/core/di/service_locator.dart

import '../localization/localization_service.dart';
import '../localization/localization_service_impl.dart';
import '../storage/key_value_store.dart';

// Inside configureDependencies(Env env):

final localizationImpl = LocalizationServiceImpl(
  storage: getIt<KeyValueStore>(),
);
await localizationImpl.init();

getIt.registerSingleton<LocalizationService>(localizationImpl);

// After LocalizationService is registered:
getIt.registerLazySingleton<LocaleCubit>(
  () => LocaleCubit(localization: getIt<LocalizationService>()),
);

getIt.registerLazySingleton<AppFormatter>(
  () => AppFormatter(localizationService: getIt<LocalizationService>()),
);
```

**Registration order**: After `KeyValueStore` (needs storage to persist locale choice), before router and features.

---

## App Root Integration — `lib/src/app/app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/service_locator.dart';
import '../core/localization/locale_cubit.dart';
import '../core/localization/localization_service.dart';
import '../core/theme/theme_cubit.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = getIt<LocalizationService>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: getIt<ThemeCubit>()),
        BlocProvider<LocaleCubit>.value(value: getIt<LocaleCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) => MaterialApp.router(
            title: 'App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            themeAnimationDuration: Duration.zero,
            routerConfig: AppRouter.instance,
            supportedLocales: l10n.supportedLocales,
            localizationsDelegates: l10n.delegates,
            locale: locale,
          ),
        ),
      ),
    );
  }
}
```

---

## Dynamic Locale Switching

`LocaleCubit` is provided at the app root. `context.tr()` calls `context.watch<LocaleCubit>()`, which registers each widget as a rebuild listener. When `setLanguage()` is called, `safeEmit(locale)` fires — all widgets using `context.tr()` rebuild and fetch updated translations from the singleton.

### Language Picker (Settings page)

```dart
BlocBuilder<LocaleCubit, Locale>(
  builder: (context, locale) => Row(
    children: [
      _LanguageChip(
        label: 'English',
        locale: const Locale('en'),
        selected: locale.languageCode == 'en',
        onTap: () => context.read<LocaleCubit>().setLanguage(const Locale('en')),
      ),
      _LanguageChip(
        label: 'Tiếng Việt',
        locale: const Locale('vi'),
        selected: locale.languageCode == 'vi',
        onTap: () => context.read<LocaleCubit>().setLanguage(const Locale('vi')),
      ),
    ],
  ),
)
```

---

## JSON Asset Alternative

For teams that prefer JSON files over in-code maps (easier for translators):

### `assets/i18n/en.json`

```json
{
  "common_ok": "OK",
  "common_cancel": "Cancel",
  "common_save": "Save",
  "common_greeting": "Hello, %s!",
  "item_count_zero": "No items",
  "item_count_one": "1 item",
  "item_count_other": "%d items",
  "order_summary": "You ordered {count} {item}."
}
```

### Loading JSON assets in `LocalizationServiceImpl`

```dart
import 'dart:convert';
import 'package:flutter/services.dart';

/// Load translations from JSON assets instead of in-code maps.
Future<Map<String, dynamic>> _loadJson(String languageCode) async {
  final jsonString = await rootBundle.loadString('assets/i18n/$languageCode.json');
  return json.decode(jsonString) as Map<String, dynamic>;
}
```

Add to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/i18n/
```

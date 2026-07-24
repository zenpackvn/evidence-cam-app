# ThemeCubit and Theme Usage

## ThemeCubit and ThemeStore

`ThemeCubit` is a `HydratedCubit` — it owns both the current `ThemeMode` state and its own persistence. Because it lives in the presentation layer, any data-layer class that needs to read or write the theme must go through a **domain interface** (`ThemeStore`) to avoid a dependency inversion violation.

### `core/theme/theme_store.dart`

```dart
import 'package:flutter/material.dart';

/// Domain-layer abstraction for reading and writing the active [ThemeMode].
/// Keeps data-layer consumers decoupled from the presentation-layer [ThemeCubit].
abstract interface class ThemeStore {
  ThemeMode get currentTheme;
  void setTheme(ThemeMode mode);
}
```

### `core/theme/theme_cubit.dart`

```dart
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'theme_store.dart';

/// Persists and manages [ThemeMode] across app restarts via [HydratedCubit].
/// Implements [ThemeStore] so data-layer consumers stay decoupled from this cubit.
class ThemeCubit extends HydratedCubit<ThemeMode> implements ThemeStore {
  ThemeCubit() : super(ThemeMode.system);

  @override
  ThemeMode get currentTheme => state;

  @override
  void setTheme(ThemeMode mode) => emit(mode);

  @override
  ThemeMode fromJson(Map<String, dynamic> json) {
    final index = json['themeMode'] as int?;
    if (index == null || index < 0 || index >= ThemeMode.values.length) {
      return ThemeMode.system;
    }
    return ThemeMode.values[index];
  }

  @override
  Map<String, dynamic> toJson(ThemeMode state) => {'themeMode': state.index};
}
```

### DI registration (`service_locator.dart`)

Register both types so callers can depend on either:

```dart
// 18. Theme
getIt.registerLazySingleton<ThemeCubit>(ThemeCubit.new);
getIt.registerLazySingleton<ThemeStore>(() => getIt<ThemeCubit>());
```

- **Presentation layer** (e.g. `app.dart` `BlocBuilder`) resolves `ThemeCubit` directly.
- **Data layer** (e.g. `SettingsRepositoryImpl`) resolves `ThemeStore` — no presentation import.
- **Cubits that mutate theme** (e.g. `SettingsCubit`) resolve `ThemeStore` and call `setTheme()` directly — do **not** route mutations through a repository.

## Usage in widgets

Always use theme tokens — never hardcode colors, sizes, or text styles:

```dart
// Correct — uses theme tokens
Text(
  'Title',
  style: AppTypography.headlineMedium,
)

Padding(
  padding: const EdgeInsets.all(AppSpacing.md),
  child: Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    ),
  ),
)

// Wrong — hardcoded values
Text(
  'Title',
  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
)

Padding(
  padding: const EdgeInsets.all(16),
  child: Container(
    decoration: BoxDecoration(
      color: Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

## Anti-Patterns

See [theme_anti_patterns.md](theme_anti_patterns.md) for code examples covering: hardcoded colors/spacing, duplicate feature color constants, mid-tree ThemeData override, `static const TextStyle`, and asymmetric light/dark component themes.

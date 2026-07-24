# EnumHydratedCubit

Eliminates boilerplate `fromJson`/`toJson` for cubits whose state is a Dart enum (e.g., `ThemeMode`, `ActionPosition`, locale). Subclasses declare three getters — no serialization code needed.

## File

`lib/src/core/base/enum_hydrated_cubit.dart`

```dart
import 'package:flutter/foundation.dart';

import 'base_hydrated_cubit.dart';

/// Eliminates boilerplate `fromJson`/`toJson` for cubits whose state is a
/// Dart enum (e.g., ThemeMode, ActionPosition, Locale language code).
///
/// Subclasses declare three getters — no serialization code needed.
abstract class EnumHydratedCubit<E extends Enum>
    extends BaseHydratedCubit<E> {
  EnumHydratedCubit(super.initialState);

  /// All enum values — typically `MyEnum.values`.
  List<E> get values;

  /// JSON key used to persist the enum index.
  String get jsonKey;

  /// Fallback value used when persisted data is missing or corrupt.
  E get defaultValue;

  @override
  E fromJson(Map<String, dynamic> json) {
    final index = json[jsonKey] as int?;
    if (index == null || index < 0 || index >= values.length) {
      return defaultValue;
    }
    return values[index];
  }

  @override
  Map<String, dynamic> toJson(E state) => {jsonKey: state.index};
}
```

## Usage

```dart
import '../../../../core/base/enum_hydrated_cubit.dart';
import '../entities/action_position.dart';

class SettingsCubit extends EnumHydratedCubit<ActionPosition> {
  SettingsCubit() : super(ActionPosition.right);

  @override List<ActionPosition> get values => ActionPosition.values;
  @override String get jsonKey => 'actionPosition';
  @override ActionPosition get defaultValue => ActionPosition.right;

  void setPosition(ActionPosition position) => safeEmit(position);
}
```

```dart
// Theme cubit
class ThemeCubit extends EnumHydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  @override List<ThemeMode> get values => ThemeMode.values;
  @override String get jsonKey => 'themeMode';
  @override ThemeMode get defaultValue => ThemeMode.system;

  void setTheme(ThemeMode mode) => safeEmit(mode);
}
```

## Rules

- Use `EnumHydratedCubit` when the entire cubit state is a single enum value.
- For complex persisted state (multi-step forms, etc.), use `BaseHydratedCubit` and implement `fromJson`/`toJson` manually.
- `jsonKey` must be unique across all persisted cubits.

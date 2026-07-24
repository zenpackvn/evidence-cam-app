# BaseHydratedCubit

Wrapper around `HydratedCubit` + `SafeEmitMixin`. Use when cubit state must survive process death or cold app restarts. Only this file imports `hydrated_bloc` — all feature cubits import this wrapper.

## File

`lib/src/core/base/base_hydrated_cubit.dart`

```dart
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'safe_emit_mixin.dart';

/// Wrapper around [HydratedCubit] + [SafeEmitMixin].
/// Only this file imports hydrated_bloc — all feature cubits import this wrapper.
abstract class BaseHydratedCubit<S> extends HydratedCubit<S>
    with SafeEmitMixin<S> {
  BaseHydratedCubit(super.initialState);
}
```

## Usage

```dart
// feature cubit — imports only the wrapper, never hydrated_bloc directly
import '../../../../core/base/base_hydrated_cubit.dart';

class TaskFormCubit extends BaseHydratedCubit<TaskFormState> {
  TaskFormCubit({...}) : super(const TaskFormEditing());

  @override
  TaskFormState? fromJson(Map<String, dynamic> json) {
    try {
      // restore state
    } on Object catch (e, s) {
      logger.warn('corrupt restoration data, resetting', error: e, stackTrace: s);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(TaskFormState state) { ... }
}
```

## Rules

- Only `base_hydrated_cubit.dart` imports `hydrated_bloc`. Feature cubits import `BaseHydratedCubit` — wrapper rule applies.
- Must implement `fromJson`/`toJson`. Return `null` from `fromJson` on corrupt data — this resets to `initialState`.
- Use `safeEmit()` (inherited) instead of `emit()`.
- For enum state, use `EnumHydratedCubit` — no serialization code needed.

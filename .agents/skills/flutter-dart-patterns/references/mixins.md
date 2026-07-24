# Mixins

Mixins inject reusable behavior across the class hierarchy without coupling via inheritance.

## `SafeEmitMixin` — prevents emit-after-close

```dart
// lib/src/core/bloc/safe_emit_mixin.dart
mixin SafeEmitMixin<S> on Cubit<S> {
  /// Emits [state] only if the cubit is not yet closed.
  void safeEmit(S state) {
    if (!isClosed) emit(state);
  }
}
```

## `BaseRepository` — wraps every data call in typed failure

```dart
// lib/src/core/repository/base_repository.dart
mixin BaseRepository {
  /// Wraps [call] and converts exceptions to [AppFailure] subtypes.
  Future<T> safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AppFailure {
      rethrow; // already typed
    } on DioException catch (e) {
      throw NetworkFailure.fromDioError(e);
    } catch (e, st) {
      getIt<AppLogger>().error('Repository error', e, st);
      throw UnknownFailure(e.toString());
    }
  }
}
```

## Usage — combining mixins

```dart
// A cubit uses SafeEmitMixin
class TaskListCubit extends Cubit<TaskListState> with SafeEmitMixin<TaskListState> {
  TaskListCubit(...) : super(const TaskListInitial());

  Future<void> load() async {
    safeEmit(const TaskListLoading());   // safe, never raw emit
    // ...
  }
}

// A repository uses BaseRepository
class TaskRepositoryImpl with BaseRepository implements TaskRepository {
  @override
  Future<TaskPage> getTasks({required int page, required int limit}) =>
      safeCall(() async {
        final dtos = await _remote.getTasks(page: page, limit: limit);
        return (
          tasks: dtos.items.map((d) => d.toEntity()).toList(),
          hasMore: dtos.hasMore,
          totalCount: dtos.totalCount,
        );
      });
}
```

## Rules for mixins

- Use `on` constraints to limit mixin to specific superclasses: `mixin SafeEmitMixin<S> on Cubit<S>`
- Prefer mixins over abstract base classes when the behavior is purely additive with no constructor logic
- Keep each mixin focused on one responsibility
- Prefer mixins over abstract classes used only for mixins

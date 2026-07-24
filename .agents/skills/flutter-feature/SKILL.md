---
name: flutter-feature
description: Use this skill when building a Flutter feature end-to-end — cubit, state, repository, use case, DI module, page, BlocProvider wiring, BLoC/Cubit patterns, BlocBuilder, BlocListener, async state handling, loading/error/success states, or scaffolding a self-contained feature with all layers.
---

# Flutter Feature

Full reference: [`template.md`](references/template.md)

## When to use this skill vs `flutter-architecture`

| Scenario | Use this skill | Use `flutter-architecture` |
|---|---|---|
| Build a single feature end-to-end | Yes — cubit + use case + repo + page | No |
| Understand layer boundaries + SOLID/DRY | No | Yes — full layer diagram + rules |
| Scaffold a new screen with BlocProvider | Yes | No |
| Decide where domain logic lives | No | Yes — use case vs repo vs cubit |
| Wire DI module for a feature | Yes | No |

**Both skills share the same architecture.** This skill is the hands-on builder; `flutter-architecture` is the design authority. Co-load both when building a new feature for the first time.

## Key rules

- **BlocProvider at the page level** — never higher in the tree unless shared across routes.
- `create: (_) => getIt<MyCubit>()` — **only** place `getIt` is called in widget code.
- Cubit depends on **use cases**, not repositories. One use case per action.
- State is a `sealed` class with `Equatable`. Use separate subclasses for loading/loaded/error/empty — no boolean flags.
- `BlocConsumer` = `BlocBuilder` + `BlocListener` combined when you need both UI and side effects.
- `safeEmit()` instead of `emit()` everywhere — never emit after cubit is closed.

## Pattern: UseCase

```dart
// domain/usecases/get_tasks_usecase.dart
final class GetTasksUseCase extends UseCase<TaskPage, ({int page, int limit})> {
  GetTasksUseCase({required TaskRepository repository}) : _repository = repository;
  final TaskRepository _repository;

  @override
  Future<TaskPage> call(({int page, int limit}) params) =>
      _repository.getTasks(page: params.page, limit: params.limit);
}
```

Use `NoParams` for use cases that take no arguments. One `call()` method only — no business logic.

## Pattern: Repository interface + impl

```dart
// domain/repositories/task_repository.dart
abstract interface class TaskRepository {
  Future<TaskPage> getTasks({required int page, required int limit});
}

// data/repositories/task_repository_impl.dart
final class TaskRepositoryImpl with BaseRepository implements TaskRepository {
  TaskRepositoryImpl({required TaskRemoteDataSource remote}) : _remote = remote;
  final TaskRemoteDataSource _remote;

  @override
  Future<TaskPage> getTasks({required int page, required int limit}) =>
      safeCall(() async {
        final dtos = await _remote.getTasks(page: page, limit: limit);
        return TaskPage(tasks: dtos.map((d) => d.toEntity()).toList(), hasMore: dtos.length >= limit);
      });
}
```

## Pattern: Cubit → UseCase

```dart
class TaskListCubit extends BasePaginatedCubit<Task> {
  TaskListCubit({required GetTasksUseCase getTasksUseCase, required super.logger})
      : _getTasksUseCase = getTasksUseCase;
  final GetTasksUseCase _getTasksUseCase;

  @override
  Future<({List<Task> items, bool hasMore})> fetchPage(int page) async {
    final result = await _getTasksUseCase((page: page, limit: pageSize));
    return (items: result.tasks, hasMore: result.hasMore);
  }
}
```

## Pattern: DI module

```dart
// di/task_module.dart
void registerTaskModule() {
  getIt
    ..registerLazySingleton<TaskRemoteDataSource>(
        () => TaskRemoteDataSourceImpl(apiClient: getIt()))
    ..registerLazySingleton<TaskRepository>(
        () => TaskRepositoryImpl(remote: getIt()))
    ..registerLazySingleton(() => GetTasksUseCase(repository: getIt()))
    ..registerFactory(() => TaskListCubit(getTasksUseCase: getIt(), logger: getIt()));
}
```

## Pattern: Page with BlocProvider

```dart
class TaskListPage extends BasePage {
  static Widget withDependencies() => BlocProvider(
    create: (_) => getIt<TaskListCubit>()..load(),
    child: const TaskListPage._(),
  );
}
```

## BlocListener side-effect actions

Use `BlocListener` (or `BlocConsumer.listener`) for:
- Navigation (`context.go(...)`)
- Showing dialogs/toasts (`getIt<AppDialog>().showToast(...)`)
- Logging errors

## Co-load with

- `flutter-base-classes` — BaseCubit, BasePaginatedCubit, sealed states
- `flutter-architecture` — full clean-arch layers
- `flutter-di` — feature module registration
- `flutter-loading` — SuperListView for list pages
- `flutter-common-widgets` — App widgets for the UI layer

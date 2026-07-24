---
name: flutter-dart-patterns
description: Use this skill when writing modern Dart 3 code — records, sealed classes, pattern matching, switch expressions, extension methods, mixins, typedefs, destructuring, or when the task involves multi-value returns, exhaustive switch on state/failure hierarchies, adding behavior to types you don't own, or cross-cutting concerns via mixins in a Flutter app. Also trigger for SafeEmitMixin, BaseRepository safeCall, BuildContextX extensions, typed failure hierarchies, or any Dart language feature question.
---

# Flutter Dart Patterns

Full reference: [`template.md`](references/template.md)

## Key rules

### Records for multi-value returns — no custom result classes
```dart
// DON'T — unnecessary class for a simple pair
class TaskPage {
  final List<Task> tasks;
  final bool hasMore;
  TaskPage({required this.tasks, required this.hasMore});
}

// DO — named record fields, destructurable at call sites
typedef TaskPage = ({List<Task> tasks, bool hasMore});

Future<TaskPage> call(({int page, int limit}) params) async {
  final dtos = await _remote.getTasks(page: params.page, limit: params.limit);
  return (tasks: dtos.map((d) => d.toEntity()).toList(), hasMore: dtos.length == params.limit);
}

// Call site — destructure inline
final (:tasks, :hasMore) = await getTasksUseCase((page: 1, limit: 20));
```

### Sealed classes — exhaustive hierarchies for state and failures
```dart
// Cubit state — sealed for exhaustive switch in UI
sealed class TaskListState extends Equatable {
  const TaskListState();
}
final class TaskListInitial   extends TaskListState { ... }
final class TaskListLoading   extends TaskListState { ... }
final class TaskListLoaded    extends TaskListState { ... }
final class TaskListError     extends TaskListState { ... }

// UI — switch must cover all branches or compiler errors
return switch (state) {
  TaskListInitial()     => const SizedBox.shrink(),
  TaskListLoading()     => const AppShimmer(),
  TaskListLoaded(:final tasks, :final hasMore) => TaskListView(tasks: tasks),
  TaskListError(:final message) => AppErrorState(message: message),
};
```

### Extension methods — add behavior to types you don't own
```dart
// DON'T — utility function scattered across files
String formatDate(DateTime dt) => DateFormat('MMM d, y').format(dt);

// DO — extension on the type itself
extension DateTimeX on DateTime {
  String get formatted => DateFormat('MMM d, y').format(this);
  bool get isToday => DateUtils.isSameDay(this, DateTime.now());
}

// BuildContext extensions reduce boilerplate
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  bool get isMobile => MediaQuery.sizeOf(this).width < 600;
}
```

### Mixins — cross-cutting behavior without inheritance coupling
```dart
// SafeEmitMixin prevents emit-after-close crashes
mixin SafeEmitMixin<S> on Cubit<S> {
  void safeEmit(S state) {
    if (!isClosed) emit(state);
  }
}

// BaseRepository.safeCall wraps every data call in typed failure
mixin BaseRepository {
  Future<T> safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw NetworkFailure.fromDioError(e);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
```

### Pattern matching — destructure in switch expressions
```dart
// Switch expression (returns a value)
Widget build(BuildContext context) {
  return BlocBuilder<TaskListCubit, TaskListState>(
    builder: (context, state) => switch (state) {
      TaskListLoaded(:final tasks) when tasks.isEmpty => const EmptyState(),
      TaskListLoaded(:final tasks) => TaskList(tasks: tasks),
      TaskListError(:final message) => ErrorState(message: message),
      _ => const LoadingShimmer(),
    },
  );
}
```

### Typedefs — name complex types for readability
```dart
// Inline record params — typedef keeps signatures clean
typedef PageParams = ({int page, int limit});
typedef AuthResult = ({String accessToken, String refreshToken, User user});

// Function types
typedef OnTaskSelected = void Function(Task task);
typedef TaskFilter = bool Function(Task task);
```

## Anti-patterns

| Anti-pattern | Fix |
|---|---|
| Custom 2-field result class | Named record typedef |
| `if (state is X)` chain | Sealed class + `switch` expression |
| Static utility method | Extension on the relevant type |
| Abstract class just for shared code | `mixin` with `on` constraint |
| Wildcard `_` catches all sealed variants | Name each variant explicitly |
| Complex nested `?? ?? ??` chains | Pattern matching with guard clauses |

## Co-load with

- `flutter-base-classes` — `BaseCubit`, `BaseRepository`, `SafeEmitMixin` use these patterns
- `flutter-architecture` — sealed `Failure` hierarchy, use case record returns
- `flutter-feature` — cubit state sealed classes, switch in BlocBuilder
- `flutter-error-handling` — sealed `AppFailure` hierarchy

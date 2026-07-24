# Records

Records are anonymous immutable value types. Use them for multi-value returns instead of creating a dedicated class.

## Basic record

```dart
// Positional record
(String, int) get nameAndAge => ('Alice', 30);
final (name, age) = nameAndAge;

// Named record — preferred: fields are self-documenting
({String name, int age}) get userInfo => (name: 'Alice', age: 30);
final (:name, :age) = userInfo;
```

## Typedef for reuse

```dart
// lib/src/features/task/domain/use_cases/get_tasks_use_case.dart
typedef TaskPage = ({List<Task> tasks, bool hasMore, int totalCount});
typedef PageParams = ({int page, int limit});

final class GetTasksUseCase extends UseCase<TaskPage, PageParams> {
  GetTasksUseCase({required TaskRepository repository})
      : _repository = repository;

  final TaskRepository _repository;

  @override
  Future<TaskPage> call(PageParams params) =>
      _repository.getTasks(page: params.page, limit: params.limit);
}
```

## Destructuring at call sites

```dart
// In a cubit
Future<void> load({int page = 1}) async {
  safeEmit(const TaskListLoading());
  try {
    final (:tasks, :hasMore, :totalCount) =
        await _getTasksUseCase((page: page, limit: _pageSize));
    safeEmit(TaskListLoaded(tasks: tasks, hasMore: hasMore));
  } on AppFailure catch (f) {
    safeEmit(TaskListError(failure: f));
  }
}
```

## When NOT to use records

- When the type needs methods, validation, or identity semantics → use a class/entity
- When the type is reused across many files with complex behaviour → a named class is clearer
- When you need Equatable / JSON serialization → use `@freezed` or a plain class

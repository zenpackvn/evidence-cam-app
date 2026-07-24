# Typedefs and Use Case Base Class

## Typedefs

Typedefs name complex types to improve readability and reduce duplication.

```dart
// lib/src/core/types/app_typedefs.dart

// Record typedefs
typedef PageParams   = ({int page, int limit});
typedef TaskPage     = ({List<Task> tasks, bool hasMore, int totalCount});
typedef AuthResult   = ({String accessToken, String refreshToken, User user});
typedef SearchParams = ({String query, int page, int limit});

// Callback typedefs
typedef OnTaskSelected  = void Function(Task task);
typedef OnPageChanged   = void Function(int page);
typedef TaskPredicate   = bool Function(Task task);

// JSON typedef
typedef JsonMap = Map<String, dynamic>;
```

## Use Case Base Class

Records pair naturally with a typed use case base class:

```dart
// lib/src/core/use_cases/use_case.dart
abstract interface class UseCase<Output, Input> {
  Future<Output> call(Input params);
}

// No-input use case
abstract interface class NoParamUseCase<Output> {
  Future<Output> call();
}

// Stream use case
abstract interface class StreamUseCase<Output, Input> {
  Stream<Output> call(Input params);
}
```

## Concrete use case with record params

```dart
// lib/src/features/task/domain/use_cases/search_tasks_use_case.dart
final class SearchTasksUseCase extends UseCase<TaskPage, SearchParams> {
  SearchTasksUseCase({required TaskRepository repository}) : _repository = repository;

  final TaskRepository _repository;

  @override
  Future<TaskPage> call(SearchParams params) =>
      _repository.searchTasks(
        query: params.query,
        page: params.page,
        limit: params.limit,
      );
}
```

## Rules

- Use record typedefs (`typedef TaskPage = ({...})`) instead of creating a dedicated 2-field result class for use case returns.
- Use callback typedefs (`typedef OnTaskSelected = void Function(Task)`) instead of raw `Function` types in widget APIs.
- Use `typedef JsonMap = Map<String, dynamic>` instead of repeating the verbose type in every method signature.
- Every use case implements `UseCase<Output, Input>`, `NoParamUseCase<Output>`, or `StreamUseCase<Output, Input>`.

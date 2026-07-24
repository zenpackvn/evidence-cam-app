# UseCase / StreamUseCase / NoParams

Base classes for all use cases. Every feature action must have a use case. Cubits depend on use cases — never on repositories directly.

## File

`lib/src/core/base/use_case.dart`

```dart
/// Base class for all use cases.
///
/// [T] is the return type. [Params] is the input type.
/// Use [NoParams] when the use case takes no arguments.
abstract class UseCase<T, Params> {
  const UseCase();

  Future<T> call(Params params);
}

/// Use case that returns a [Stream] instead of a [Future].
abstract class StreamUseCase<T, Params> {
  const StreamUseCase();

  Stream<T> call(Params params);
}

/// Marker class for use cases that take no parameters.
class NoParams {
  const NoParams();
}
```

## Usage

```dart
// Single param — use the type directly
class GetTaskUseCase extends UseCase<Task, int> {
  GetTaskUseCase({required this.repository});
  final TaskRepository repository;

  @override
  Future<Task> call(int id) => repository.getTask(id);
}

// Multiple params — use a record typedef
typedef CreateTaskParams = ({String title, String body, int userId});

class CreateTaskUseCase extends UseCase<CreatedTask, CreateTaskParams> {
  CreateTaskUseCase({required this.repository});
  final TaskRepository repository;

  @override
  Future<CreatedTask> call(CreateTaskParams params) =>
      repository.createTask(
        title: params.title,
        body: params.body,
        userId: params.userId,
      );
}

// No params
class LogoutUseCase extends UseCase<void, NoParams> {
  LogoutUseCase({required this.authService});
  final AuthService authService;

  @override
  Future<void> call(NoParams params) => authService.logout();
}

// Stream use case
class ObserveAuthStatusUseCase extends StreamUseCase<AuthStatus, NoParams> {
  ObserveAuthStatusUseCase({required this.authService});
  final AuthService authService;

  @override
  Stream<AuthStatus> call(NoParams params) => authService.authStatusStream;
}
```

## Naming conventions

| | Convention |
|--|--|
| File | `<action>_<entity>_use_case.dart` |
| Class | `<Action><Entity>UseCase` (always suffixed with `UseCase`) |

Examples: `GetUserUseCase`, `CreateOrderUseCase`, `LogoutUseCase`, `ObserveAuthStatusUseCase`.

## Rules

- Every feature action must have a use case extending `UseCase` or `StreamUseCase`.
- Cubits depend on use cases — **never on repositories directly**.
- Use `NoParams` for parameterless use cases.
- Use a record typedef for multiple params — no separate `Params` class needed.

# Pattern Matching

Dart 3 pattern matching works in `switch` expressions, `switch` statements, `if-case`, and `for` loops.

## Destructuring in `switch`

```dart
// Named field destructuring
switch (failure) {
  case NetworkFailure(:final statusCode) when statusCode == 401:
    await _authService.logout();
  case NetworkFailure(:final message):
    logger.error(message);
  case _:
    logger.error('Unknown failure');
}
```

## Guard clauses (`when`)

```dart
return switch (state) {
  TaskListLoaded(:final tasks) when tasks.isEmpty => const EmptyTasksView(),
  TaskListLoaded(:final tasks, :final hasMore)    => TaskListView(tasks: tasks, hasMore: hasMore),
  _                                               => const LoadingView(),
};
```

## `if-case` for single-pattern checks

```dart
if (result case Ok(:final value)) {
  safeEmit(TaskListLoaded(tasks: value.tasks, hasMore: value.hasMore));
}
```

## List / map patterns

```dart
// Check first element
final [first, ...rest] = tasks;

// Map pattern — extract known keys
if (json case {'status': final String status, 'data': final Map<String, dynamic> data}) {
  processData(status, data);
}
```

## Rules

- Prefer `switch` expressions over `if (state is X)` chains — exhaustiveness is compiler-enforced with sealed classes.
- Use `when` guards for sub-conditions within a pattern arm rather than nesting `if` inside the arm body.
- Use `if-case` for one-off single-pattern checks rather than a full `switch`.
- Replace deeply nested `?. ?? ??` chains with `if-case` or `switch` for clarity.

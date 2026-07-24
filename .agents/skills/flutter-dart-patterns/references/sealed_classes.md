# Sealed Classes

Sealed classes define a closed type hierarchy. The compiler enforces exhaustiveness in `switch` expressions — every subtype must be handled.

## Cubit state hierarchy

```dart
// lib/src/features/task/presentation/cubit/task_list_state.dart
sealed class TaskListState extends Equatable {
  const TaskListState();
}

final class TaskListInitial extends TaskListState {
  const TaskListInitial();
  @override
  List<Object?> get props => [];
}

final class TaskListLoading extends TaskListState {
  const TaskListLoading();
  @override
  List<Object?> get props => [];
}

final class TaskListLoaded extends TaskListState {
  const TaskListLoaded({required this.tasks, required this.hasMore});
  final List<Task> tasks;
  final bool hasMore;
  @override
  List<Object?> get props => [tasks, hasMore];
}

final class TaskListError extends TaskListState {
  const TaskListError({required this.failure});
  final AppFailure failure;
  @override
  List<Object?> get props => [failure];
}
```

## Failure hierarchy

```dart
// lib/src/core/error/app_failure.dart
sealed class AppFailure {
  const AppFailure(this.message);
  final String message;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message, {this.statusCode});
  final int? statusCode;

  factory NetworkFailure.fromDioError(DioException e) =>
      NetworkFailure(e.message ?? 'Network error', statusCode: e.response?.statusCode);
}

final class CacheFailure extends AppFailure {
  const CacheFailure(super.message);
}

final class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message);
}
```

## Exhaustive switch in UI

```dart
// lib/src/features/task/presentation/pages/task_list_page.dart
BlocBuilder<TaskListCubit, TaskListState>(
  builder: (context, state) => switch (state) {
    TaskListInitial()                            => const SizedBox.shrink(),
    TaskListLoading()                            => const AppShimmer(),
    TaskListLoaded(:final tasks) when tasks.isEmpty => AppEmptyState(
                                                    message: context.l10n.noTasksYet,
                                                  ),
    TaskListLoaded(:final tasks, :final hasMore) => TaskList(
                                                    tasks: tasks,
                                                    hasMore: hasMore,
                                                  ),
    TaskListError(:final failure)                => AppErrorState(
                                                    message: failure.message,
                                                    onRetry: context.read<TaskListCubit>().load,
                                                  ),
  },
)
```

## Exhaustive switch in cubit (failure handling)

```dart
String _messageFor(AppFailure failure) => switch (failure) {
  NetworkFailure(:final statusCode) when statusCode == 401 => 'Session expired',
  NetworkFailure(:final statusCode) when statusCode == 404 => 'Not found',
  NetworkFailure()   => 'No connection',
  CacheFailure()     => 'Failed to load cached data',
  AuthFailure()      => 'Authentication required',
  UnknownFailure()   => 'Something went wrong',
};
```

## Rules

- Always name each sealed variant explicitly in switch expressions — never rely on a wildcard `_` to silently swallow new variants. The compiler will catch unhandled cases when you add a new subtype.
- Seal both states (`TaskListState`) and failures (`AppFailure`) — these are the two primary closed hierarchies in the architecture.
- Mark subtypes `final` to prevent further subclassing outside the sealed family.

# BaseState / PaginatedState

`BaseState<T>` — generic sealed state for standard fetch flows: initial → loading → success / empty / error.

`PaginatedState<T>` — state for paginated list cubits.

## File

`lib/src/core/base/base_state.dart`

```dart
import 'package:equatable/equatable.dart';

import '../error/failure.dart';

/// Generic sealed state for any cubit.
///
/// Use this when the feature has a standard flow:
/// initial → loading → success(data) / empty / error.
///
/// For custom states (e.g., multi-step forms), define your own sealed class.
sealed class BaseState<T> extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no data loaded yet.
class BaseInitial<T> extends BaseState<T> {
  const BaseInitial();
}

/// Loading state — data is being fetched.
class BaseLoading<T> extends BaseState<T> {
  const BaseLoading();
}

/// Success state — data is available.
class BaseSuccess<T> extends BaseState<T> {
  const BaseSuccess(this.data);
  final T data;

  @override
  List<Object?> get props => [data];
}

/// Empty state — request succeeded but returned no data.
class BaseEmpty<T> extends BaseState<T> {
  const BaseEmpty();
}

/// Error state — request failed with a typed failure.
class BaseError<T> extends BaseState<T> {
  const BaseError(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
```

## Paginated state variant

Used with `BasePaginatedCubit<T>`. See [base_paginated_cubit.md](base_paginated_cubit.md).

```dart
import 'package:equatable/equatable.dart';

import '../error/failure.dart';

/// State for paginated list cubits.
sealed class PaginatedState<T> extends Equatable {
  const PaginatedState();

  @override
  List<Object?> get props => [];
}

class PaginatedInitial<T> extends PaginatedState<T> {
  const PaginatedInitial();
}

class PaginatedLoading<T> extends PaginatedState<T> {
  const PaginatedLoading();
}

class PaginatedLoaded<T> extends PaginatedState<T> {
  const PaginatedLoaded({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<T> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  PaginatedLoaded<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PaginatedLoaded<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, page, hasMore, isLoadingMore];
}

class PaginatedEmpty<T> extends PaginatedState<T> {
  const PaginatedEmpty();
}

class PaginatedError<T> extends PaginatedState<T> {
  const PaginatedError(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
```

## Rules

- Use `BaseState<T>` for standard load/display flows. Define a custom sealed class for complex flows (auth, multi-step forms, onboarding).
- `PaginatedState<T>` is used exclusively with `BasePaginatedCubit<T>` — do not use it manually.

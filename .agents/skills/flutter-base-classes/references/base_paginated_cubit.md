# BasePaginatedCubit

Base cubit for paginated lists. Handles load, refresh, and loadMore with page tracking. Subclasses only implement `fetchPage()`.

## File

`lib/src/core/base/base_paginated_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/failure.dart';
import '../logging/app_logger.dart';
import 'base_state.dart';

/// Base cubit for paginated lists.
///
/// Subclass must implement [fetchPage] which returns items + hasMore.
/// Handles load, refresh, loadMore with page tracking.
abstract class BasePaginatedCubit<T> extends Cubit<PaginatedState<T>> {
  BasePaginatedCubit({required this.logger}) : super(const PaginatedInitial());

  final AppLogger logger;

  /// Implement this — fetch a single page of items.
  Future<({List<T> items, bool hasMore})> fetchPage(int page);

  /// Items per page. Override if different.
  int get pageSize => 20;

  // ── Lifecycle ──

  Future<void> load() async {
    _safeEmit(const PaginatedLoading());
    await _loadPage(1, isRefresh: false);
  }

  Future<void> refresh() async {
    await _loadPage(1, isRefresh: true);
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! PaginatedLoaded<T> || !current.hasMore || current.isLoadingMore) {
      return;
    }

    _safeEmit(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.page + 1;
      final result = await fetchPage(nextPage);
      _safeEmit(PaginatedLoaded<T>(
        items: [...current.items, ...result.items],
        page: nextPage,
        hasMore: result.hasMore,
      ));
    } on FailureException {
      // Keep existing data on load-more failure.
      _safeEmit(current.copyWith(isLoadingMore: false));
    } catch (e, s) {
      logger.error('${runtimeType}.loadMore() failed', error: e, stackTrace: s);
      _safeEmit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _loadPage(int page, {required bool isRefresh}) async {
    try {
      final result = await fetchPage(page);
      if (result.items.isEmpty) {
        _safeEmit(const PaginatedEmpty());
      } else {
        _safeEmit(PaginatedLoaded<T>(
          items: result.items,
          page: page,
          hasMore: result.hasMore,
        ));
      }
    } on FailureException catch (e) {
      _safeEmit(PaginatedError(e.failure));
    } catch (e, s) {
      logger.error('${runtimeType}.fetchPage($page) failed', error: e, stackTrace: s);
      _safeEmit(const PaginatedError(UnknownFailure()));
    }
  }

  void _safeEmit(PaginatedState<T> state) {
    if (!isClosed) emit(state);
  }
}
```

## Usage

```dart
class OrderListCubit extends BasePaginatedCubit<Order> {
  OrderListCubit({
    required this.orderRepository,
    required super.logger,
  });

  final OrderRepository orderRepository;

  @override
  Future<({List<Order> items, bool hasMore})> fetchPage(int page) async {
    final result = await orderRepository.getOrders(page: page);
    return (items: result.orders, hasMore: result.hasMore);
  }
}
```

## Rules

- Use `BasePaginatedCubit<T>` for all paginated list cubits.
- Override only `fetchPage()`. `load()`, `refresh()`, `loadMore()` are all inherited.
- `SuperListView` from [template-loading.md](../../flutter-loading/references/template.md) works with `PaginatedState` out of the box.

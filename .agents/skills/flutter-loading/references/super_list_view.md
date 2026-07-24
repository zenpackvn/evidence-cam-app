# Loading — SuperListView

The all-in-one paginated list widget. The **only file** that imports `pullex`. Handles four states: shimmer loading → error with retry → empty with retry → data with pull-to-refresh + load-more.

Pass it `PaginatedState<T>` and callbacks — it owns the `RefreshController` internally and picks the right UI. The cubit stays pure: no UI imports, no controller references.

## `pubspec.yaml` addition

```yaml
dependencies:
  pullex: 1.0.4             # exact version, never ^
```

## `lib/src/core/widgets/loading/super_list_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:pullex/pullex.dart';

import '../../../app/theme/app_spacing.dart';
import '../../base/base_state.dart';
import '../../localization/localization_extensions.dart';
import '../common/app_button.dart';
import '../common/app_empty_state.dart';
import '../common/app_error_state.dart';
import 'app_loading_indicator.dart';
import 'app_shimmer.dart';

/// All-in-one paginated list widget.
///
/// - Only this file imports `package:pullex`.
/// - Owns [RefreshController] internally — cubit stays pure.
/// - Accepts [PaginatedState<T>] directly; syncs controller via [didUpdateWidget].
/// - Uses [_isRefreshing] / [_isLoadingMore] flags so the controller is only
///   signalled for the operation that actually triggered the state change.
class SuperListView<T> extends StatefulWidget {
  const SuperListView({
    super.key,
    required this.state,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onRetry,
    this.shimmerItemCount = 8,
    this.shimmerItemBuilder,
    this.separator,
    this.padding,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final PaginatedState<T> state;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final VoidCallback onRetry;

  final int shimmerItemCount;
  final Widget Function(BuildContext context, int index)? shimmerItemBuilder;

  /// Optional divider widget placed between items. Wrapped in a builder
  /// internally — callers pass a widget, not a builder function.
  final Widget? separator;

  final EdgeInsetsGeometry? padding;
  final Widget Function(BuildContext context, VoidCallback onRetry)? emptyBuilder;
  final Widget Function(BuildContext context, VoidCallback onRetry)? errorBuilder;

  @override
  State<SuperListView<T>> createState() => _SuperListViewState<T>();
}

class _SuperListViewState<T> extends State<SuperListView<T>> {
  final _controller = RefreshController();
  bool _isRefreshing = false;
  bool _isLoadingMore = false;

  @override
  void didUpdateWidget(SuperListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(widget.state);
  }

  void _syncController(PaginatedState<T> next) {
    if (next is PaginatedLoaded<T>) {
      if (_isRefreshing) {
        _controller.refreshCompleted(resetFooterState: true);
        _isRefreshing = false;
      }
      if (_isLoadingMore) {
        if (next.hasMore) {
          _controller.loadComplete();
        } else {
          _controller.loadNoData();
        }
        _isLoadingMore = false;
      }
    } else if (next is PaginatedError<T>) {
      if (_isRefreshing) {
        _controller.refreshFailed();
        _isRefreshing = false;
      }
      if (_isLoadingMore) {
        _controller.loadFailed();
        _isLoadingMore = false;
      }
    } else if (next is PaginatedEmpty<T>) {
      if (_isRefreshing) {
        _controller.refreshCompleted();
        _isRefreshing = false;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => switch (widget.state) {
        PaginatedInitial<T>() || PaginatedLoading<T>() => _buildShimmer(),
        PaginatedEmpty<T>() => _buildEmpty(context),
        PaginatedError<T>(:final failure) => _buildError(context, failure.message),
        PaginatedLoaded<T>(:final items, :final isLoadingMore) =>
          _buildLoaded(context, items, isLoadingMore),
      };

  Widget _buildShimmer() => ShimmerListSkeleton(
        itemCount: widget.shimmerItemCount,
        itemBuilder: widget.shimmerItemBuilder,
      );

  Widget _buildEmpty(BuildContext context) {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context, widget.onRetry);
    }
    return AppEmptyState(
      message: context.tr('common_empty'),
      actionLabel: context.tr('common_refresh'),
      onAction: widget.onRetry,
    );
  }

  Widget _buildError(BuildContext context, String message) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, widget.onRetry);
    }
    return AppErrorState(
      message: message,
      onRetry: widget.onRetry,
    );
  }

  Widget _buildLoaded(BuildContext context, List<T> items, bool isLoadingMore) {
    final theme = Theme.of(context);
    final sep = widget.separator;

    final list = sep != null
        ? ListView.separated(
            padding: widget.padding,
            itemCount: items.length,
            separatorBuilder: (_, __) => sep,
            itemBuilder: (ctx, i) => widget.itemBuilder(ctx, items[i], i),
          )
        : ListView.builder(
            padding: widget.padding,
            itemCount: items.length,
            itemBuilder: (ctx, i) => widget.itemBuilder(ctx, items[i], i),
          );

    return PullexRefresh(
      controller: _controller,
      enablePullDown: true,
      enablePullUp: true,
      header: MaterialHeader(
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
      ),
      footer: CustomFooter(
        builder: (context, mode) => switch (mode) {
          LoadStatus.loading => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: AppLoadingIndicator(
                size: AppLoadingSize.small,
                color: theme.colorScheme.primary,
              ),
            ),
          LoadStatus.noMore => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                context.tr('list_no_more'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          LoadStatus.failed => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: AppTextButton(
                label: context.tr('list_load_failed'),
                icon: Icons.refresh,
                onPressed: () => _controller.requestLoading(),
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
      onRefresh: () async {
        _isRefreshing = true;
        await widget.onRefresh();
      },
      onLoading: () async {
        _isLoadingMore = true;
        await widget.onLoadMore();
      },
      child: list,
    );
  }
}
```

---

## End-to-end example

### Cubit — pure, no UI imports

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_paginated_cubit.dart';
import '../../domain/post.dart';
import '../../domain/post_repository.dart';

class PostListCubit extends BasePaginatedCubit<Post> {
  PostListCubit({required this.repository, required super.logger});

  final PostRepository repository;

  @override
  Future<({List<Post> items, bool hasMore})> fetchPage(int page) async {
    final result = await repository.fetchPosts(page: page, limit: pageSize);
    return (items: result.posts, hasMore: result.hasMore);
  }
}
```

No `RefreshController` in the cubit. `RefreshController` is a UI concern from `pullex` — it lives inside `SuperListView` and is managed entirely there.

### Page — pass state + callbacks, nothing else

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/common/app_divider.dart';
import '../../../../core/widgets/common/app_list_tile.dart';
import '../../../../core/widgets/common/app_top_bar.dart';
import '../../../../core/widgets/loading/super_list_view.dart';
import '../../domain/post.dart';
import '../cubit/post_list_cubit.dart';

class PostListPage extends StatelessWidget {
  const PostListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostListCubit>(
      create: (_) => getIt<PostListCubit>()..load(),
      child: const _PostListView(),
    );
  }
}

class _PostListView extends StatelessWidget {
  const _PostListView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PostListCubit>();

    return Scaffold(
      appBar: const AppTopBar(title: 'Posts', showBack: false),
      body: BlocBuilder<PostListCubit, PaginatedState<Post>>(
        builder: (context, state) => SuperListView<Post>(
          state: state,
          onRefresh: cubit.refresh,
          onLoadMore: cubit.loadMore,
          onRetry: cubit.load,
          itemBuilder: (context, post, index) => AppListTile(
            title: Text(post.title),
            subtitle: Text(post.body),
          ),
          separator: const AppDivider(),
        ),
      ),
    );
  }
}
```

### Custom shimmer shape

```dart
SuperListView<Post>(
  // ...
  shimmerItemCount: 6,
  shimmerItemBuilder: (context, index) => const ShimmerListItem(
    height: 100,
    hasLeading: true,
    leadingSize: 56,
  ),
)
```

### Custom empty / error UI

```dart
SuperListView<Post>(
  // ...
  emptyBuilder: (context, onRetry) => EmptyStateWidget(
    title: 'No posts yet',
    subtitle: 'Pull down to refresh',
    onAction: onRetry,
  ),
  errorBuilder: (context, onRetry) => ErrorStateWidget(
    message: 'Oops!',
    onRetry: onRetry,
  ),
)
```

---

## Anti-patterns

```dart
// ❌ hard string + magic number + raw layout
Text('No items found', style: theme.textTheme.bodyLarge)
SizedBox(height: 16)
Icon(Icons.inbox_outlined, size: 56)

// ❌ raw tap target instead of AppTextButton
GestureDetector(onTap: ..., child: Text('Tap to retry', style: ...))

// ❌ separatorBuilder callback — callers must not pass a function
SuperListView(separatorBuilder: (ctx, i) => const Divider())

// ✅ correct empty fallback
AppEmptyState(
  message: context.tr('common_empty'),
  actionLabel: context.tr('common_refresh'),
  onAction: onRetry,
)

// ✅ correct inline tap target
AppTextButton(
  label: context.tr('list_load_failed'),
  icon: Icons.refresh,
  onPressed: () => _controller.requestLoading(),
)

// ✅ correct separator — pass a widget, not a builder
SuperListView(separator: const AppDivider())
```

# Presentation Layer

Imports only from domain (entities, use cases). Never imports DTOs, data sources, or `*_impl` classes.

---

## Post List — paginated with SuperListView

### `presentation/cubit/post_list_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/post.dart';

sealed class PostListState extends Equatable {
  const PostListState();
  @override
  List<Object?> get props => const [];
}

class PostListInitial extends PostListState { const PostListInitial(); }
class PostListLoading extends PostListState { const PostListLoading(); }
class PostListEmpty extends PostListState { const PostListEmpty(); }

class PostListLoaded extends PostListState {
  const PostListLoaded({
    required this.posts,
    required this.hasMore,
    required this.page,
  });
  final List<Post> posts;
  final bool hasMore;
  final int page;

  @override
  List<Object?> get props => [posts, hasMore, page];
}

class PostListError extends PostListState {
  const PostListError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
```

### `presentation/cubit/post_list_cubit.dart`

The cubit **owns the `RefreshController`** — creates it, signals completion, and disposes it in `close()`.

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/widgets/loading/super_list_view.dart';
import '../../domain/repositories/post_repository.dart';
import 'post_list_state.dart';

class PostListCubit extends Cubit<PostListState> {
  PostListCubit(this._repository) : super(const PostListInitial());
  final PostRepository _repository;

  final RefreshController refreshController = RefreshController();

  Future<void> load() async {
    emit(const PostListLoading());
    try {
      final result = await _repository.getPosts(page: 1);
      if (result.posts.isEmpty) {
        emit(const PostListEmpty());
        return;
      }
      emit(PostListLoaded(posts: result.posts, hasMore: result.hasMore, page: 1));
    } on FailureException catch (e) {
      emit(PostListError(e.failure));
    }
  }

  Future<void> refresh() async {
    try {
      final result = await _repository.getPosts(page: 1);
      if (result.posts.isEmpty) {
        emit(const PostListEmpty());
      } else {
        emit(PostListLoaded(posts: result.posts, hasMore: result.hasMore, page: 1));
      }
    } on FailureException catch (e) {
      emit(PostListError(e.failure));
    } finally {
      refreshController.refreshCompleted();
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! PostListLoaded || !current.hasMore) {
      refreshController.loadComplete();
      return;
    }
    try {
      final nextPage = current.page + 1;
      final result = await _repository.getPosts(page: nextPage);
      emit(PostListLoaded(
        posts: [...current.posts, ...result.posts],
        hasMore: result.hasMore,
        page: nextPage,
      ));
    } on FailureException {
      // Keep existing data on load-more failure.
    } finally {
      refreshController.loadComplete();
    }
  }

  @override
  Future<void> close() {
    refreshController.dispose();
    return super.close();
  }
}
```

### `presentation/widgets/post_list_tile.dart`

```dart
import 'package:flutter/material.dart';
import '../../domain/entities/post.dart';

class PostListTile extends StatelessWidget {
  const PostListTile({super.key, required this.post, this.onTap});
  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text('by ${post.authorName}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
```

### `presentation/pages/post_list_page.dart`

`SuperListView` handles shimmer loading, error/empty with retry, data with pull-to-refresh + load-more.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/loading/super_list_view.dart';
import '../../domain/entities/post.dart';
import '../cubit/post_list_cubit.dart';
import '../cubit/post_list_state.dart';
import '../widgets/post_list_tile.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: BlocBuilder<PostListCubit, PostListState>(
        builder: (context, state) {
          final cubit = context.read<PostListCubit>();
          return SuperListView<Post>(
            status: _mapStatus(state),
            items: state is PostListLoaded ? state.posts : const [],
            refreshController: cubit.refreshController,
            onRefresh: cubit.refresh,
            onLoadMore: cubit.loadMore,
            onRetry: cubit.load,
            enablePullUp: state is PostListLoaded && state.hasMore,
            itemBuilder: (context, post, index) => PostListTile(
              post: post,
              onTap: () => context.push('/posts/${post.id}'),
            ),
            separatorBuilder: (context, index) => const Divider(height: 1),
          );
        },
      ),
    );
  }

  SuperListStatus _mapStatus(PostListState state) => switch (state) {
        PostListInitial() || PostListLoading() => SuperListStatus.loading,
        PostListEmpty() => SuperListStatus.empty,
        PostListError() => SuperListStatus.error,
        PostListLoaded() => SuperListStatus.loaded,
      };
}
```

---

## Post Detail — simple detail page

### `presentation/cubit/post_detail_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';

sealed class PostDetailState extends Equatable {
  const PostDetailState();
  @override
  List<Object?> get props => const [];
}

class PostDetailInitial extends PostDetailState { const PostDetailInitial(); }
class PostDetailLoading extends PostDetailState { const PostDetailLoading(); }

class PostDetailLoaded extends PostDetailState {
  const PostDetailLoaded({required this.post, required this.comments});
  final Post post;
  final List<Comment> comments;
  @override
  List<Object?> get props => [post, comments];
}

class PostDetailError extends PostDetailState {
  const PostDetailError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
```

### `presentation/cubit/post_detail_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../domain/usecases/get_post_detail_usecase.dart';
import 'post_detail_state.dart';

class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit(this._getPostDetail) : super(const PostDetailInitial());
  final GetPostDetailUseCase _getPostDetail;

  Future<void> load(int postId) async {
    emit(const PostDetailLoading());
    try {
      final result = await _getPostDetail(postId);
      emit(PostDetailLoaded(post: result.post, comments: result.comments));
    } on FailureException catch (e) {
      emit(PostDetailError(e.failure));
    }
  }
}
```

### `presentation/widgets/post_detail_content.dart`

```dart
import 'package:flutter/material.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import 'post_comment_tile.dart';

class PostDetailContent extends StatelessWidget {
  const PostDetailContent({
    super.key,
    required this.post,
    required this.comments,
  });

  final Post post;
  final List<Comment> comments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(post.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('by ${post.authorName}', style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),
        Text(post.body, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 24),
        Text('Comments (${comments.length})', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ...comments.map((c) => PostCommentTile(comment: c)),
      ],
    );
  }
}
```

### `presentation/widgets/post_comment_tile.dart`

```dart
import 'package:flutter/material.dart';
import '../../domain/entities/comment.dart';

class PostCommentTile extends StatelessWidget {
  const PostCommentTile({super.key, required this.comment});
  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(comment.authorName, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(comment.body),
          ],
        ),
      ),
    );
  }
}
```

### `presentation/pages/post_detail_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/loading/screen_loading.dart';
import '../cubit/post_detail_cubit.dart';
import '../cubit/post_detail_state.dart';
import '../widgets/post_detail_content.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.postId});
  final int postId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostDetailCubit>(
      create: (_) => getIt<PostDetailCubit>()..load(postId),
      child: const _PostDetailView(),
    );
  }
}

class _PostDetailView extends StatelessWidget {
  const _PostDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Detail')),
      body: BlocBuilder<PostDetailCubit, PostDetailState>(
        builder: (context, state) => switch (state) {
          PostDetailInitial() || PostDetailLoading() => const ScreenLoading(),
          PostDetailError(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(failure.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      final page = context
                          .findAncestorWidgetOfExactType<PostDetailPage>();
                      if (page != null) {
                        context.read<PostDetailCubit>().load(page.postId);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          PostDetailLoaded(:final post, :final comments) =>
            PostDetailContent(post: post, comments: comments),
        },
      ),
    );
  }
}
```

## Rules

- Presentation imports only domain entities and use cases — never DTOs, sources, or `*_impl` classes.
- Cubits catch `FailureException`, never `DioException` (that's a data-layer concern).
- `BlocProvider` is created in the page widget; the inner `_View` widget reads from context.
- Cubit owns `RefreshController` for paginated lists — dispose it in `close()`.

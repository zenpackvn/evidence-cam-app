# Tests

## `test/features/post/fake_post_repository.dart`

Shared fake used by both list and detail tests. Prefer a fake over a mock for repository contracts — fakes make tests more readable and more robust.

```dart
import 'package:your_app/src/core/error/failure.dart';
import 'package:your_app/src/features/post/domain/entities/comment.dart';
import 'package:your_app/src/features/post/domain/entities/post.dart';
import 'package:your_app/src/features/post/domain/repositories/post_repository.dart';

class FakePostRepository implements PostRepository {
  List<Post> postsToReturn = [];
  List<Comment> commentsToReturn = [];
  bool shouldFail = false;

  @override
  Future<({List<Post> posts, bool hasMore})> getPosts({
    required int page,
    int limit = 20,
  }) async {
    if (shouldFail) throw const FailureException(ServerFailure('Network error'));
    return (posts: postsToReturn, hasMore: false);
  }

  @override
  Future<Post> getPost(int id) async {
    if (shouldFail) throw const FailureException(ServerFailure('Network error'));
    return postsToReturn.first;
  }

  @override
  Future<List<Comment>> getComments(int postId) async {
    if (shouldFail) throw const FailureException(ServerFailure('Network error'));
    return commentsToReturn;
  }
}
```

## `test/features/post/post_list_cubit_test.dart`

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/src/features/post/domain/entities/post.dart';
import 'package:your_app/src/features/post/presentation/cubit/post_list_cubit.dart';
import 'package:your_app/src/features/post/presentation/cubit/post_list_state.dart';
import 'fake_post_repository.dart';

void main() {
  late FakePostRepository fakeRepository;

  final testPost = Post(
    id: 1,
    title: 'Test Post',
    body: 'Test body',
    authorName: 'Author',
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    fakeRepository = FakePostRepository()..postsToReturn = [testPost];
  });

  blocTest<PostListCubit, PostListState>(
    'emits [loading, loaded] on success',
    build: () => PostListCubit(fakeRepository),
    act: (cubit) => cubit.load(),
    expect: () => [
      const PostListLoading(),
      isA<PostListLoaded>()
          .having((s) => s.posts.length, 'posts.length', 1)
          .having((s) => s.page, 'page', 1),
    ],
  );

  blocTest<PostListCubit, PostListState>(
    'emits [loading, empty] when no posts',
    build: () {
      fakeRepository.postsToReturn = [];
      return PostListCubit(fakeRepository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [const PostListLoading(), const PostListEmpty()],
  );

  blocTest<PostListCubit, PostListState>(
    'emits [loading, error] on failure',
    build: () {
      fakeRepository.shouldFail = true;
      return PostListCubit(fakeRepository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [const PostListLoading(), isA<PostListError>()],
  );
}
```

## `test/features/post/post_detail_cubit_test.dart`

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/src/features/post/domain/entities/comment.dart';
import 'package:your_app/src/features/post/domain/entities/post.dart';
import 'package:your_app/src/features/post/domain/usecases/get_post_detail_usecase.dart';
import 'package:your_app/src/features/post/presentation/cubit/post_detail_cubit.dart';
import 'package:your_app/src/features/post/presentation/cubit/post_detail_state.dart';
import 'fake_post_repository.dart';

void main() {
  late FakePostRepository fakeRepository;
  late GetPostDetailUseCase getPostDetail;

  final testPost = Post(
    id: 1,
    title: 'Test Post',
    body: 'Test body',
    authorName: 'Author',
    createdAt: DateTime(2024, 1, 1),
  );
  const testComment = Comment(id: 1, body: 'Nice!', authorName: 'Reader');

  setUp(() {
    fakeRepository = FakePostRepository()
      ..postsToReturn = [testPost]
      ..commentsToReturn = [testComment];
    getPostDetail = GetPostDetailUseCase(fakeRepository);
  });

  blocTest<PostDetailCubit, PostDetailState>(
    'emits [loading, loaded] on success',
    build: () => PostDetailCubit(getPostDetail),
    act: (cubit) => cubit.load(1),
    expect: () => [
      const PostDetailLoading(),
      isA<PostDetailLoaded>()
          .having((s) => s.post.id, 'post.id', 1)
          .having((s) => s.comments.length, 'comments.length', 1),
    ],
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'emits [loading, error] on failure',
    build: () {
      fakeRepository.shouldFail = true;
      return PostDetailCubit(getPostDetail);
    },
    act: (cubit) => cubit.load(1),
    expect: () => [const PostDetailLoading(), isA<PostDetailError>()],
  );
}
```

## Rules

- Use a shared `FakeRepository` across cubit tests for the same feature.
- Test cubits via `bloc_test` — not by calling methods and checking state directly.
- Base classes (`BaseCubit`, `BaseRepository`) are tested once in core; feature tests cover only `fetchData()` and custom actions.

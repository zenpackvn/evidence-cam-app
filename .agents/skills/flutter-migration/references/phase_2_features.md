# Phase 2: Features (1 PR per feature)

Migrate features one at a time. Each feature gets:

1. A `di/` folder with its own module.
2. Constructor injection (no `getIt<T>()` inside the feature).
3. Typed `Failure` handling (no raw `try/catch Exception`).

## Migration Order

Start with the simplest, lowest-risk feature. Save auth for later.

```
1. Settings (read-only, simple state)
2. Profile (read + write, one API call)
3. Posts / Feed (list, pagination, error states)
4. Auth (complex, touches everything — migrate last)
```

## Feature Migration Steps

Using Posts as an example:

**Step 1**: Move DI registrations to a feature module.

```dart
// lib/src/features/posts/di/post_module.dart
import 'package:get_it/get_it.dart';
import '../../../core/di/service_locator.dart';
import '../data/post_repository_impl.dart';
import '../domain/post_repository.dart';
import '../presentation/post_list_cubit.dart';

void registerPostModule() {
  getIt
    ..registerLazySingleton<PostRepository>(
      () => PostRepositoryImpl(apiClient: getIt()),
    )
    ..registerFactory<PostListCubit>(
      () => PostListCubit(repository: getIt(), logger: getIt()),
    );
}
```

```dart
// In configureDependencies():
// ── 4. Features ──
registerPostModule();
```

**Step 2**: Fix constructor injection violations.

```dart
// Before (violation):
class PostListCubit extends Cubit<PostListState> {
  PostListCubit() : super(const PostListInitial()) {
    _repo = getIt<PostRepository>(); // BAD: service location
  }
  late final PostRepository _repo;
}

// After (constructor injection + BaseCubit):
class PostListCubit extends BaseCubit<List<Post>> {
  PostListCubit({
    required PostRepository repository,
    required super.logger,
  }) : _repository = repository;

  final PostRepository _repository;

  @override
  Future<List<Post>> fetchData() => _repository.fetchPosts();
}
```

**Step 3**: Add typed failure handling.

```dart
// Before (raw exception):
try {
  final posts = await _repo.getPosts();
  emit(PostListLoaded(posts));
} catch (e) {
  emit(PostListError(e.toString()));
}

// After (typed Failure):
try {
  final posts = await _repository.getPosts();
  emit(PostListLoaded(posts));
} on FailureException catch (e) {
  _logger.error('Failed to load posts', error: e);
  emit(PostListError(e.failure));
}
```

**Verify**: `flutter analyze` + `flutter test` + feature smoke test.

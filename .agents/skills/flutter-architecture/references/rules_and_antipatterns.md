# Rules, Anti-Patterns, SOLID & DRY

## Rules

1. **Domain layer has zero imports from data or presentation.** Entities depend only on `equatable`. Repository contracts are `abstract interface class`.
2. **DTOs stay in data.** `toEntity()` mapping lives on the DTO. Never leak `Map<String, dynamic>` or DTOs into domain or presentation.
3. **Repository impl catches raw exceptions** and throws `FailureException` with a typed `Failure`. Cubits catch `FailureException`, never `DioException`.
4. **Use cases are required.** Every feature must have use cases as the entry point from presentation to domain. Cubits depend on use cases, never on repositories directly.
5. **Use case naming:** File `<action>_<entity>_use_case.dart`. Class `<Action><Entity>UseCase`. Extends `UseCase<T, Params>` or `StreamUseCase<T, Params>`.
6. **Cubits are always DI factories, never singletons.** State leaks across screens if registered as singletons.
7. **Feature DI module** is called from `configureDependencies()`, never self-registers.
8. **Regenerate** after adding/changing DTOs: `dart run build_runner build --delete-conflicting-outputs`.

---

## Anti-Patterns

### DON'T: Let presentation depend on data layer

```dart
// BAD — page imports data-layer DTO
import '../../data/dto/post_dto.dart';

// GOOD — page depends only on domain entities
import '../../domain/entity/post.dart';
```

### DON'T: Let cubits depend on repositories directly

```dart
// BAD — cubit bypasses use case layer
class PostDetailCubit extends BaseCubit<Post> {
  PostDetailCubit({required this.repository}); // repo directly
  final PostRepository repository;
}

// GOOD — cubit depends on use case
class PostDetailCubit extends BaseCubit<Post> {
  PostDetailCubit({required this.getPostDetail}); // use case
  final GetPostDetailUseCase getPostDetail;
}
```

### DON'T: Leak raw exceptions across boundaries

```dart
// BAD — cubit catches DioException (data layer concern)
try {
  final posts = await repository.getPosts();
} on DioException catch (e) { ... }

// GOOD — repository maps to typed Failure; cubit catches FailureException
try {
  final posts = await repository.getPosts();
} on FailureException catch (e) {
  emit(PostState.error(e.failure));
}
```

### DON'T: Put mapping logic in cubits

```dart
// BAD — cubit knows about DTOs
final dto = await apiClient.getPost(id);
final post = Post(title: dto.title, body: dto.body);

// GOOD — mapping lives in data layer (DTO.toEntity or data source)
final post = await repository.getPost(id); // already an entity
```

### DON'T: Route UI state mutations through a repository

Repositories are read-only facades over storage/APIs. When state mutation belongs to an app-level service or cubit (theme, locale, session), the cubit calls that service directly — no repository middleman.

```dart
// BAD — repository calls ThemeCubit from data layer
class SettingsRepositoryImpl implements SettingsRepository {
  void updateTheme(ThemeMode mode) => _themeCubit.setTheme(mode); // wrong direction
}

// GOOD — cubit calls the service directly
class SettingsCubit extends BaseCubit<SettingsState> {
  void updateTheme(ThemeMode mode) {
    _themeStore.setTheme(mode); // direct
    safeEmit(SettingsLoaded(_getSettings()));
  }
}
```

---

## SOLID

### S — Single Responsibility

One use case per operation.

```dart
// GOOD
class GetPostsUseCase extends UseCase<({List<Post> posts, bool hasMore}), GetPostsParams> { ... }
class GetPostDetailUseCase extends UseCase<Post, int> { ... }

// BAD — one class with branching behaviour
class PostUseCase {
  Future<dynamic> call({int? id, int? page}) async {
    if (id != null) return repository.getPost(id!);
    return repository.getPosts(page: page ?? 1);
  }
}
```

### O — Open/Closed

New behaviour → new use case. Never add params to an existing use case to cover a new case.

```dart
// GOOD — new use case for new behaviour
class PostCommentUseCase extends UseCase<Comment, PostCommentParams> { ... }

// BAD — patching existing use case with a new flag that breaks all callers
class GetPostDetailUseCase {
  // added includeComments flag — breaks existing callers
}
```

### L — Liskov Substitution

`MockPostRepository` in tests must honour the same contract as `PostRepository`. Never throw where the interface promises a return value.

```dart
// GOOD
class MockPostRepository extends Mock implements PostRepository {}

// BAD
class BadMock implements PostRepository {
  @override
  Future<Post> getPost(int id) => throw UnimplementedError(); // contract violation
}
```

### I — Interface Segregation

Split repository interfaces when cubits only use a subset of methods.

```dart
// GOOD — focused interfaces
abstract interface class PostReadRepository {
  Future<({List<Post> posts, bool hasMore})> getPosts({required int page});
  Future<Post> getPost(int id);
}
abstract interface class PostWriteRepository {
  Future<Post> createPost({required String title, required String body});
}

// BAD — fat interface injected into a read-only cubit
abstract interface class PostRepository { /* 10 methods, cubit uses 1 */ }
```

### D — Dependency Inversion

Cubits import use cases. Use cases import repository interfaces. Nothing imports `*_impl.dart` except the DI module.

```dart
// GOOD
class PostListCubit extends BasePaginatedCubit<Post> {
  PostListCubit({required GetPostsUseCase getPostsUseCase, ...}) ...
}

// BAD — importing impl in a cubit
import '../data/repositories/post_repository_impl.dart';
```

---

## DRY

Every repeated concern has one canonical source.

| Concern | Single source | Violation |
|---|---|---|
| Error wrapping | `BaseRepository.safeCall()` | Manual `try/catch/DioException` in repository impl |
| Loading/error/empty state | `BaseState` via `BaseCubit` | Custom `isLoading` / `errorMessage` field in cubit state |
| Paginated fetch | `BasePaginatedCubit` | Manual `page`/`offset` tracking in cubit |
| Validation rules | `core/forms/form_validator.dart` | Same regex or length check written twice |
| Network boilerplate | `ApiClient` owns headers + interceptors | Data source adding its own headers |
| Offline-first fallback | Private `_withLocalFallback()` helper in repository | Identical try/catch+warn block copy-pasted per method |

### Offline fallback — extract, don't repeat

```dart
// GOOD — one private helper per offline-first repository
Future<T> _withLocalFallback<T>({
  required Future<T> Function() remote,
  required Future<T> Function() local,
  required String tag,
}) async {
  if (connectivityService.currentStatus == ConnectivityStatus.online) {
    try {
      return await remote();
    } catch (e) {
      logger.warn('$tag remote failed, falling back to local', error: e);
    }
  }
  return local();
}

// BAD — same try/catch+warn duplicated per method
Future<List<Task>> getTasks(...) => safeCall(() async {
  if (online) { try { /* remote */ } catch (e) { logger.warn(...); } } // repeated
  return localDataSource.getAll();
});
Future<Task> getTask(int id) => safeCall(() async {
  if (online) { try { /* remote */ } catch (e) { logger.warn(...); } } // same block again
  return localDataSource.getById(id) ?? (throw ...);
});
```

# Offline-First Repository Pattern

A repository that writes locally first, enqueues for sync, and returns local data immediately. Users see instant feedback; sync happens in the background.

## `lib/src/features/post/domain/post_repository.dart`

```dart
import '../domain/post.dart';

abstract interface class PostRepository {
  Future<List<Post>> getPosts();
  Future<void> createPost(Post post);
  Future<void> updatePost(Post post);
  Future<void> deletePost(String id);
}
```

## `lib/src/features/post/data/post_repository_impl.dart`

```dart
import '../../../core/connectivity/connectivity_service.dart';
import '../../../core/connectivity/connectivity_status.dart';
import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/sync/sync_operation.dart';
import '../../../core/sync/sync_queue.dart';
import '../domain/post.dart';
import '../domain/post_repository.dart';
import 'post_local_data_source.dart';
import 'post_remote_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({
    required PostRemoteDataSource remoteSource,
    required PostLocalDataSource localSource,
    required SyncQueue syncQueue,
    required ConnectivityService connectivity,
    required AppLogger logger,
  })  : _remoteSource = remoteSource,
        _localSource = localSource,
        _syncQueue = syncQueue,
        _connectivity = connectivity,
        _logger = logger;

  final PostRemoteDataSource _remoteSource;
  final PostLocalDataSource _localSource;
  final SyncQueue _syncQueue;
  final ConnectivityService _connectivity;
  final AppLogger _logger;

  @override
  Future<List<Post>> getPosts() async {
    // Always read from local first
    final local = await _localSource.getAll();

    // If online, fetch remote and sync to local
    if (_connectivity.currentStatus == ConnectivityStatus.online) {
      try {
        final remote = await _remoteSource.fetchPosts();
        await _localSource.saveAll(remote);
        return remote.map((dto) => dto.toEntity()).toList();
      } on FailureException catch (e) {
        _logger.warn(
          'Remote fetch failed, returning local data',
          error: e,
        );
      }
    }

    return local.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> createPost(Post post) async {
    // Save locally immediately (optimistic update)
    await _localSource.insert(post.toLocalModel());

    // Enqueue for remote sync
    await _syncQueue.enqueue(
      SyncOperation(
        id: post.id,
        type: 'create_post',
        payload: post.toJson(),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> updatePost(Post post) async {
    await _localSource.update(post.toLocalModel());

    await _syncQueue.enqueue(
      SyncOperation(
        id: '${post.id}_update_${DateTime.now().millisecondsSinceEpoch}',
        type: 'update_post',
        payload: post.toJson(),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> deletePost(String id) async {
    await _localSource.delete(id);

    await _syncQueue.enqueue(
      SyncOperation(
        id: '${id}_delete_${DateTime.now().millisecondsSinceEpoch}',
        type: 'delete_post',
        payload: {'id': id},
        createdAt: DateTime.now(),
      ),
    );
  }
}
```

## `_withLocalFallback` helper — DRY pattern

When multiple read methods share the same remote→local fallback, extract a private helper to avoid duplicated try/catch+warn blocks:

```dart
/// Tries [remote] when online; on any failure logs a warning and falls back
/// to [local]. When offline, [local] is called directly.
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
```

Use it inside `safeCall`:

```dart
@override
Future<({List<Post> posts, bool hasMore})> getPosts({required int page}) =>
    safeCall(
      () => _withLocalFallback(
        remote: () async {
          final dtos = await remoteDataSource.getPosts(page: page);
          if (page == 1) await localDataSource.clearAll();
          await localDataSource.saveAll(dtos);
          return (
            posts: dtos.map((d) => d.toEntity()).toList(),
            hasMore: dtos.length >= 20,
          );
        },
        local: () async {
          final dtos = await localDataSource.getAll();
          return (posts: dtos.map((d) => d.toEntity()).toList(), hasMore: false);
        },
        tag: 'getPosts(page: $page)',
      ),
      tag: 'getPosts(page: $page)',
    );
```

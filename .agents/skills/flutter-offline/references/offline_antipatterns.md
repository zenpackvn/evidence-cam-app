# Offline Anti-Patterns

## 1. Checking connectivity with a one-shot bool instead of streaming

**DON'T** — do a one-shot check and cache the result:

```dart
class PostCubit extends Cubit<PostState> {
  PostCubit(this._connectivity) : super(const PostState.initial());
  final ConnectivityService _connectivity;

  Future<void> loadPosts() async {
    // One-shot check — stale the moment the network changes.
    final isOnline = await _connectivity.checkConnectivity();
    if (isOnline) {
      // fetch remote...
    } else {
      // read local...
    }
    // Never re-evaluates when connectivity returns.
  }
}
```

**DO** — subscribe to the connectivity stream and react to changes:

```dart
class PostCubit extends Cubit<PostState> {
  PostCubit(this._connectivity, this._repository)
      : super(const PostState.initial()) {
    _subscription = _connectivity.onStatusChanged.listen((status) {
      if (status == ConnectivityStatus.online) {
        _refreshFromRemote();
      }
    });
  }

  final ConnectivityService _connectivity;
  final PostRepository _repository;
  late final StreamSubscription<ConnectivityStatus> _subscription;

  Future<void> _refreshFromRemote() async {
    final posts = await _repository.getPosts();
    emit(PostState.loaded(posts));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
```

---

## 2. Not queuing failed operations for retry (just showing error)

**DON'T** — discard the operation on failure:

```dart
Future<void> createPost(Post post) async {
  try {
    await remoteSource.createPost(post.toDto());
  } catch (e) {
    // Data is lost — the user's work vanishes on a flaky connection.
    emit(PostState.error('Failed to create post. Try again.'));
  }
}
```

**DO** — save locally and enqueue for retry:

```dart
Future<void> createPost(Post post) async {
  // Optimistic local write — user sees the post immediately.
  await localSource.insert(post.toLocalModel());

  // Enqueue for background sync — survives app restarts.
  await syncQueue.enqueue(
    SyncOperation(
      id: post.id,
      type: 'create_post',
      payload: post.toJson(),
      createdAt: DateTime.now(),
    ),
  );

  emit(PostState.loaded(await localSource.getAll()));
}
```

---

## 3. Syncing everything on reconnect instead of using a prioritized queue

**DON'T** — blast the server with every cached entity at once:

```dart
void _onBackOnline() async {
  // Fetches ALL local records and pushes them regardless of
  // whether they changed. Hammers the server, wastes bandwidth,
  // and has no ordering guarantees.
  final allPosts = await localSource.getAll();
  for (final post in allPosts) {
    await remoteSource.upsertPost(post.toDto());
  }
  final allComments = await localCommentSource.getAll();
  for (final comment in allComments) {
    await remoteSource.upsertComment(comment.toDto());
  }
}
```

**DO** — process only queued, changed operations in FIFO order with backoff:

```dart
// SyncManager already handles this — just register typed handlers.
syncManager.registerHandler('create_post', (op) async {
  final dto = PostDto.fromJson(op.payload);
  await remoteSource.createPost(dto);
  return true;
});

syncManager.registerHandler('delete_comment', (op) async {
  await remoteSource.deleteComment(op.payload['id'] as String);
  return true;
});

// On reconnect, SyncManager processes only pending operations
// sequentially with exponential backoff on failure.
```

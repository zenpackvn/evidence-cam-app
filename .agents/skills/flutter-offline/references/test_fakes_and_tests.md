# Test Fakes & Unit Tests

## `test/fakes/fake_connectivity_service.dart`

```dart
import 'dart:async';

import 'package:app/src/core/connectivity/connectivity_service.dart';
import 'package:app/src/core/connectivity/connectivity_status.dart';

class FakeConnectivityService implements ConnectivityService {
  FakeConnectivityService([this._status = ConnectivityStatus.online]);

  ConnectivityStatus _status;
  final _controller = StreamController<ConnectivityStatus>.broadcast();

  @override
  ConnectivityStatus get currentStatus => _status;

  @override
  Stream<ConnectivityStatus> get onStatusChanged => _controller.stream;

  @override
  Future<bool> checkConnectivity() async =>
      _status == ConnectivityStatus.online;

  /// Call in tests to simulate connectivity changes.
  void setStatus(ConnectivityStatus status) {
    _status = status;
    _controller.add(status);
  }

  void goOffline() => setStatus(ConnectivityStatus.offline);
  void goOnline() => setStatus(ConnectivityStatus.online);

  @override
  void dispose() => _controller.close();
}
```

## `test/fakes/fake_sync_queue.dart`

```dart
import 'package:app/src/core/sync/sync_operation.dart';
import 'package:app/src/core/sync/sync_queue.dart';

class FakeSyncQueue implements SyncQueue {
  final _items = <String, SyncOperation>{};

  List<SyncOperation> get items => _items.values.toList();

  @override
  Future<void> enqueue(SyncOperation operation) async {
    _items[operation.id] = operation;
  }

  @override
  Future<void> dequeue(String id) async {
    _items.remove(id);
  }

  @override
  Future<List<SyncOperation>> getPending() async {
    final list = _items.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  @override
  Future<void> updateRetryCount(String id, int count) async {
    final existing = _items[id];
    if (existing != null) {
      _items[id] = existing.copyWith(retryCount: count);
    }
  }

  @override
  Future<void> clear() async => _items.clear();
}
```

---

## Unit Tests — offline-first repository

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/src/core/connectivity/connectivity_status.dart';
import 'package:app/src/core/error/failure.dart';
import 'package:app/src/core/logging/app_logger.dart';
import 'package:app/src/core/sync/sync_operation.dart';
import 'package:app/src/features/post/data/post_repository_impl.dart';
import 'package:app/src/features/post/data/post_local_data_source.dart';
import 'package:app/src/features/post/data/post_remote_data_source.dart';

import '../../fakes/fake_connectivity_service.dart';
import '../../fakes/fake_sync_queue.dart';

class _MockRemoteSource extends Mock implements PostRemoteDataSource {}

class _MockLocalSource extends Mock implements PostLocalDataSource {}

class _FakeLogger implements AppLogger {
  @override
  void debug(String m, {Object? error, StackTrace? stackTrace}) {}
  @override
  void info(String m, {Object? error, StackTrace? stackTrace}) {}
  @override
  void warn(String m, {Object? error, StackTrace? stackTrace}) {}
  @override
  void error(String m, {Object? error, StackTrace? stackTrace}) {}
}

void main() {
  late _MockRemoteSource remoteSource;
  late _MockLocalSource localSource;
  late FakeSyncQueue syncQueue;
  late FakeConnectivityService connectivity;
  late PostRepositoryImpl repository;

  setUp(() {
    remoteSource = _MockRemoteSource();
    localSource = _MockLocalSource();
    syncQueue = FakeSyncQueue();
    connectivity = FakeConnectivityService();
    repository = PostRepositoryImpl(
      remoteSource: remoteSource,
      localSource: localSource,
      syncQueue: syncQueue,
      connectivity: connectivity,
      logger: _FakeLogger(),
    );
  });

  setUpAll(() {
    registerFallbackValue(
      SyncOperation(
        id: '',
        type: '',
        payload: const {},
        createdAt: DateTime(2024),
      ),
    );
  });

  group('getPosts', () {
    test('returns remote data and caches locally when online', () async {
      final remoteDtos = [PostDto(id: '1', title: 'Remote')];
      when(() => remoteSource.fetchPosts())
          .thenAnswer((_) async => remoteDtos);
      when(() => localSource.saveAll(any())).thenAnswer((_) async {});
      when(() => localSource.getAll()).thenAnswer((_) async => []);

      final posts = await repository.getPosts();

      expect(posts.first.title, 'Remote');
      verify(() => localSource.saveAll(remoteDtos)).called(1);
    });

    test('returns local data when offline', () async {
      connectivity.goOffline();
      final localModels = [PostLocalModel(id: '1', title: 'Local')];
      when(() => localSource.getAll())
          .thenAnswer((_) async => localModels);

      final posts = await repository.getPosts();

      expect(posts.first.title, 'Local');
      verifyNever(() => remoteSource.fetchPosts());
    });

    test('falls back to local when remote fails', () async {
      final localModels = [PostLocalModel(id: '1', title: 'Cached')];
      when(() => localSource.getAll())
          .thenAnswer((_) async => localModels);
      when(() => remoteSource.fetchPosts())
          .thenThrow(const FailureException(NetworkFailure()));

      final posts = await repository.getPosts();

      expect(posts.first.title, 'Cached');
    });
  });

  group('createPost', () {
    test('saves locally and enqueues sync operation', () async {
      final post = Post(id: '1', title: 'New');
      when(() => localSource.insert(any())).thenAnswer((_) async {});

      await repository.createPost(post);

      verify(() => localSource.insert(any())).called(1);
      expect(syncQueue.items, hasLength(1));
      expect(syncQueue.items.first.type, 'create_post');
    });
  });
}
```

---

## Unit Tests — ConnectivityCubit

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/src/core/connectivity/connectivity_cubit.dart';
import 'package:app/src/core/connectivity/connectivity_status.dart';

import '../../fakes/fake_connectivity_service.dart';

void main() {
  late FakeConnectivityService service;

  setUp(() {
    service = FakeConnectivityService();
  });

  tearDown(() {
    service.dispose();
  });

  blocTest<ConnectivityCubit, ConnectivityStatus>(
    'emits [offline] when connectivity drops',
    build: () => ConnectivityCubit(service),
    act: (_) => service.goOffline(),
    expect: () => [ConnectivityStatus.offline],
  );

  blocTest<ConnectivityCubit, ConnectivityStatus>(
    'emits [offline, online] when connectivity drops then recovers',
    build: () => ConnectivityCubit(service),
    act: (_) {
      service.goOffline();
      service.goOnline();
    },
    expect: () => [ConnectivityStatus.offline, ConnectivityStatus.online],
  );

  blocTest<ConnectivityCubit, ConnectivityStatus>(
    'initial state reflects service current status',
    build: () {
      service.goOffline();
      return ConnectivityCubit(service);
    },
    verify: (cubit) {
      expect(cubit.state, ConnectivityStatus.offline);
    },
  );
}
```

---

## Unit Tests — SyncManager

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:app/src/core/logging/app_logger.dart';
import 'package:app/src/core/sync/sync_manager.dart';
import 'package:app/src/core/sync/sync_operation.dart';

import '../../fakes/fake_connectivity_service.dart';
import '../../fakes/fake_sync_queue.dart';

class _FakeLogger implements AppLogger {
  @override
  void debug(String m, {Object? error, StackTrace? stackTrace}) {}
  @override
  void info(String m, {Object? error, StackTrace? stackTrace}) {}
  @override
  void warn(String m, {Object? error, StackTrace? stackTrace}) {}
  @override
  void error(String m, {Object? error, StackTrace? stackTrace}) {}
}

void main() {
  late FakeConnectivityService connectivity;
  late FakeSyncQueue syncQueue;
  late SyncManager syncManager;

  setUp(() {
    connectivity = FakeConnectivityService();
    syncQueue = FakeSyncQueue();
    syncManager = SyncManager(
      connectivityService: connectivity,
      syncQueue: syncQueue,
      logger: _FakeLogger(),
      maxRetries: 3,
    );
  });

  tearDown(() {
    syncManager.dispose();
    connectivity.dispose();
  });

  test('processQueue dequeues operations when handler succeeds', () async {
    await syncQueue.enqueue(
      SyncOperation(
        id: '1',
        type: 'create_post',
        payload: const {'title': 'Test'},
        createdAt: DateTime.now(),
      ),
    );
    syncManager.registerHandler('create_post', (_) async => true);

    await syncManager.processQueue();

    expect(syncQueue.items, isEmpty);
  });

  test('processQueue does not run when offline', () async {
    connectivity.goOffline();
    await syncQueue.enqueue(
      SyncOperation(
        id: '1',
        type: 'create_post',
        payload: const {'title': 'Test'},
        createdAt: DateTime.now(),
      ),
    );
    syncManager.registerHandler('create_post', (_) async => true);

    await syncManager.processQueue();

    expect(syncQueue.items, hasLength(1));
  });

  test('operations are retried on failure', () async {
    var attempts = 0;
    await syncQueue.enqueue(
      SyncOperation(
        id: '1',
        type: 'create_post',
        payload: const {'title': 'Test'},
        createdAt: DateTime.now(),
      ),
    );
    syncManager.registerHandler('create_post', (_) async {
      attempts++;
      return attempts >= 2; // Succeed on second attempt
    });

    await syncManager.processQueue();

    expect(attempts, greaterThanOrEqualTo(2));
    expect(syncQueue.items, isEmpty);
  });
}
```

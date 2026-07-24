# Sync Manager

Processes the sync queue when connectivity returns, with exponential backoff and typed handler registration.

## `lib/src/core/sync/sync_manager.dart`

```dart
import 'dart:async';
import 'dart:math';

import '../connectivity/connectivity_service.dart';
import '../connectivity/connectivity_status.dart';
import '../logging/app_logger.dart';
import 'sync_operation.dart';
import 'sync_queue.dart';

/// Signature for a handler that processes a single sync operation.
/// Returns `true` on success, `false` on failure.
typedef SyncHandler = Future<bool> Function(SyncOperation operation);

class SyncManager {
  SyncManager({
    required ConnectivityService connectivityService,
    required SyncQueue syncQueue,
    required AppLogger logger,
    this.maxRetries = 5,
  })  : _connectivityService = connectivityService,
        _syncQueue = syncQueue,
        _logger = logger {
    _subscription =
        _connectivityService.onStatusChanged.listen(_onStatusChanged);
  }

  final ConnectivityService _connectivityService;
  final SyncQueue _syncQueue;
  final AppLogger _logger;
  final int maxRetries;

  late final StreamSubscription<ConnectivityStatus> _subscription;
  final _handlers = <String, SyncHandler>{};
  bool _processing = false;

  /// Register a handler for a specific operation type.
  void registerHandler(String type, SyncHandler handler) {
    _handlers[type] = handler;
  }

  /// Unregister a handler for a specific operation type.
  void unregisterHandler(String type) {
    _handlers.remove(type);
  }

  /// Manually trigger queue processing (e.g., on app resume).
  Future<void> processQueue() async {
    if (_processing) return;
    if (_connectivityService.currentStatus != ConnectivityStatus.online) return;

    _processing = true;
    try {
      final pending = await _syncQueue.getPending();
      for (final operation in pending) {
        await _processOperation(operation);
      }
    } finally {
      _processing = false;
    }
  }

  Future<void> _processOperation(SyncOperation operation) async {
    final handler = _handlers[operation.type];
    if (handler == null) {
      _logger.warn(
        'No sync handler registered for type: ${operation.type}',
      );
      return;
    }

    try {
      final success = await handler(operation);
      if (success) {
        await _syncQueue.dequeue(operation.id);
        _logger.debug('Synced operation: ${operation.id} (${operation.type})');
      } else {
        await _handleRetry(operation);
      }
    } catch (e, s) {
      _logger.error(
        'Sync failed for operation: ${operation.id}',
        error: e,
        stackTrace: s,
      );
      await _handleRetry(operation);
    }
  }

  Future<void> _handleRetry(SyncOperation operation) async {
    final nextRetry = operation.retryCount + 1;
    if (nextRetry >= maxRetries) {
      _logger.warn(
        'Max retries reached for operation: ${operation.id}. '
        'Removing from queue.',
      );
      await _syncQueue.dequeue(operation.id);
      return;
    }

    await _syncQueue.updateRetryCount(operation.id, nextRetry);

    // Exponential backoff: 1s, 2s, 4s, 8s, 16s ...
    final delay = Duration(seconds: pow(2, nextRetry).toInt());
    _logger.debug(
      'Retrying operation ${operation.id} in ${delay.inSeconds}s '
      '(attempt $nextRetry/$maxRetries)',
    );
    await Future<void>.delayed(delay);

    // Re-check connectivity before retrying
    if (_connectivityService.currentStatus == ConnectivityStatus.online) {
      final updated = operation.copyWith(retryCount: nextRetry);
      await _processOperation(updated);
    }
  }

  void _onStatusChanged(ConnectivityStatus status) {
    if (status == ConnectivityStatus.online) {
      processQueue();
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
```

## Registering sync handlers in a feature DI module

```dart
void registerPostSyncHandlers(GetIt getIt) {
  final syncManager = getIt<SyncManager>();
  final remoteSource = getIt<PostRemoteDataSource>();
  final localSource = getIt<PostLocalDataSource>();

  syncManager.registerHandler('create_post', (op) async {
    try {
      final post = PostDto.fromJson(op.payload);
      final created = await remoteSource.createPost(post);
      // Server wins: update local with server-assigned data
      await localSource.update(created.toLocalModel());
      return true;
    } catch (_) {
      return false;
    }
  });

  syncManager.registerHandler('update_post', (op) async {
    try {
      final post = PostDto.fromJson(op.payload);
      final updated = await remoteSource.updatePost(post);
      // Server wins: overwrite local with server response
      await localSource.update(updated.toLocalModel());
      return true;
    } catch (_) {
      return false;
    }
  });

  syncManager.registerHandler('delete_post', (op) async {
    try {
      final id = op.payload['id'] as String;
      await remoteSource.deletePost(id);
      return true;
    } catch (_) {
      return false;
    }
  });
}
```

## Notes

- Queue items are processed sequentially (FIFO by `createdAt`).
- Exponential backoff: `2^n` seconds (1s, 2s, 4s, 8s, 16s …).
- Operations are dropped after `maxRetries` (default 5).
- Default conflict resolution strategy is **server wins** — handler overwrites local with the server response.
- `SyncManager` is lazy — starts listening only when first accessed. Force creation at bootstrap if immediate queue processing is needed: `getIt<SyncManager>().processQueue()`.

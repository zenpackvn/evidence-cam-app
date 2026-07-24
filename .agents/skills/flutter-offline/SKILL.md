---
name: flutter-offline
description: Use this skill when implementing Flutter offline support — ConnectivityService, connectivity_plus wrapper, online/offline detection, sync queue, SyncQueue, SyncManager, SyncOperation, offline-first repository pattern, optimistic updates, local-first writes, conflict resolution, or any feature that needs to work without internet.
---

# Flutter Offline

Full reference: [`template.md`](references/template.md)

## Key rules

- `ConnectivityService` wraps `connectivity_plus`. **Never import `connectivity_plus`** outside `connectivity_service_impl.dart`.
- `ConnectivityService.currentStatus` is synchronous (last known). `onStatusChanged` is a broadcast stream.
- Offline-first repository pattern: check `connectivityService.currentStatus` at the start of each write operation.
  - **Online**: call remote → update local cache → return entity.
  - **Offline**: write to local with a temporary ID → enqueue `SyncOperation` → return optimistic entity.
- Remote failures (online path) fall back to local silently. **Extract this pattern into a private `_withLocalFallback()` helper** inside the repository — never duplicate the try/catch+warn block per method.
- `SyncQueue` stores `SyncOperation` records in the Drift DB. `SyncManager` processes them on reconnect.
- Temp IDs for offline-created records: use negative millisecond timestamps (`-DateTime.now().millisecondsSinceEpoch`). Replace with server ID after sync.
- `CacheFailure` is thrown when an entity is requested offline and local cache is empty.

## Files

```
lib/src/core/connectivity/
  connectivity_service.dart         ← interface
  connectivity_service_impl.dart    ← only import of connectivity_plus
  connectivity_status.dart          ← enum: online | offline
  connectivity_cubit.dart           ← emits online/offline UI state
lib/src/core/sync/
  sync_operation.dart               ← Equatable value object (id, type, payload, createdAt)
  sync_queue.dart                   ← interface + SyncQueueImpl (wraps DAO)
  sync_manager.dart                 ← processes pending ops on reconnect
```

## Co-load with

- `flutter-storage` — Drift DB backs `SyncQueue` and local cache
- `flutter-di` — `ConnectivityService`, `SyncQueue`, `SyncManager` registration

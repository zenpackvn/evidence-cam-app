# Template — Offline & Connectivity

Connectivity monitoring, offline-first patterns, sync queue, and optimistic updates. Only `connectivity_service_impl.dart` imports `package:connectivity_plus` — the wrapper rule applies.

## Reference Files

Load only the file(s) relevant to the task.

| Topic | File |
|---|---|
| `ConnectivityService` interface + impl + `ConnectivityStatus` enum | [connectivity_service.md](connectivity_service.md) |
| `SyncOperation` model + drift table + DAO + `SyncQueue` interface/impl | [sync_queue.md](sync_queue.md) |
| `SyncManager` — processes queue on reconnect with exponential backoff | [sync_manager.md](sync_manager.md) |
| Offline-first repository pattern + `_withLocalFallback` helper | [offline_first_repository.md](offline_first_repository.md) |
| `ConnectivityCubit` + `ConnectivityBanner` widget | [connectivity_ui.md](connectivity_ui.md) |
| DI registration order for connectivity + sync | [di_registration.md](di_registration.md) |
| `FakeConnectivityService`, `FakeSyncQueue`, and unit tests | [test_fakes_and_tests.md](test_fakes_and_tests.md) |
| Anti-patterns (one-shot checks, discarding failures, bulk syncs) | [offline_antipatterns.md](offline_antipatterns.md) |

---

## ⚠️ Common Mistakes

> These are the most frequent offline/connectivity bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Importing `connectivity_plus` outside the impl file** | Wrapper rule violated; feature code couples directly to the third-party package | Only `connectivity_service_impl.dart` may import `package:connectivity_plus`; all other code depends on `ConnectivityService` |
| 2 | **One-shot connectivity check instead of streaming** | UI shows stale status; cubit never reacts when the network comes back | Subscribe to `ConnectivityService.onStatusChanged` stream in the cubit and react to each `ConnectivityStatus` event |
| 3 | **Failed remote operations silently discarded** | User's write is lost on a flaky connection with no retry | On network failure, save locally and call `syncQueue.enqueue(SyncOperation(...))` — never discard a user action |
| 4 | **Bulk-syncing all local records on reconnect** | Server hammered with every cached entity; no ordering guarantees; duplicates created | Use `SyncManager` with registered typed handlers — it processes only pending `SyncQueue` operations in FIFO order with exponential backoff |
| 5 | **`SyncOperation` table missing from `@DriftDatabase` tables list** | `build_runner` generates code without `SyncOperations`; DAO methods throw at runtime | Add `SyncOperations` to the `@DriftDatabase(tables: [...])` annotation, then run `dart run build_runner build --delete-conflicting-outputs` |
| 6 | **Connectivity subscription not cancelled in cubit `close()`** | Stream listener lives beyond cubit lifetime; phantom state emissions after cubit disposal | Store the subscription in `StreamSubscription<ConnectivityStatus>?` and cancel it in the cubit's `close()` override |
| 7 | **Operations retried forever with no `maxRetries` limit** | Dead-letter operations accumulate; sync queue grows unbounded; repeated server errors | Set `maxRetries` (default 5) in `SyncManager`; drop operations that exceed the limit rather than retrying indefinitely |
| 8 | **No `ConnectivityBanner` — failing silently** | User queues offline writes without knowing they are offline; confusion when data appears later | Wrap the app shell with `ConnectivityBanner` from `connectivity_ui.md`; always show connectivity status when the user is offline |

---

## Quick Summary

- Only `connectivity_service_impl.dart` imports `package:connectivity_plus`.
- Always read from local storage first; sync remote data in the background.
- Optimistic updates: save locally immediately, enqueue for sync — the user sees instant feedback.
- Default conflict resolution is **server wins** — handler overwrites local with the server response.
- `SyncManager` processes queue items sequentially (FIFO) with exponential backoff (`2^n` seconds).
- Operations are dropped after `maxRetries` (default 5) to prevent infinite retry loops.
- Always show connectivity status to the user via `ConnectivityBanner` — never silently queue or fail.
- Use `FakeConnectivityService` + `FakeSyncQueue` to test offline/online transitions without real hardware.

## Cross-references

- [flutter-storage](../../../flutter-storage/references/template.md) — Drift DB backs `SyncQueue` and provides the local cache for offline-first repositories
- [flutter-di](../../../flutter-di/references/template.md) — `ConnectivityService`, `SyncQueue`, and `SyncManager` must be registered in the DI composition root
- [flutter-network](../../../flutter-network/references/template.md) — `CacheFailure` originates from the `Failure` hierarchy; remote calls use `DioClient` / `ApiClient`
- [flutter-base-classes](../../../flutter-base-classes/references/template.md) — `ConnectivityCubit` extends `BaseCubit` and offline-first repositories extend `BaseRepository`
- [flutter-common-widgets](../../../flutter-common-widgets/references/template.md) — `ConnectivityBanner` is an app-shell widget that surfaces online/offline status to the user

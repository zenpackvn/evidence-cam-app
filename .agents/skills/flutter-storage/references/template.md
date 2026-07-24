# Template — Storage

Wrapped storage following the wrapper rule. Each storage backend is hidden behind an app-owned interface. Only the `*_impl.dart` file imports the third-party package.

## Topics

| Topic | File |
|---|---|
| SecureStorage interface, impl, DI, test fake | [secure_storage.md](secure_storage.md) |
| KeyValueStore interface, impl, DI, test fake | [key_value_store.md](key_value_store.md) |
| Drift database, tables, DAOs, migration, tests | [drift_database.md](drift_database.md) |
| Package selection guide, patterns, when-to-pick table | [storage_patterns.md](storage_patterns.md) |
| Anti-patterns with code examples | [storage_anti_patterns.md](storage_anti_patterns.md) |

## ⚠️ Common Mistakes

> These are the most frequent storage bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Storing auth tokens in `SharedPreferences`** | Tokens are readable in plaintext on-device; fails security audit; sensitive data exposed on rooted/jailbroken devices | Use `SecureStorage.write('access_token', token)` for all credentials and PII; `SharedPreferences` via `KeyValueStore` is for non-sensitive settings only |
| 2 | **Importing a storage package outside its `*_impl.dart`** | A repository or cubit `import 'package:flutter_secure_storage/...'` — breaks the wrapper rule, makes the package un-swappable | Only `secure_storage_impl.dart` imports `flutter_secure_storage`; only `key_value_store_impl.dart` imports `shared_preferences`; only files under `core/database/` import `drift` |
| 3 | **Calling storage directly from cubits or widgets** | `SharedPreferences.getInstance()` called inside a cubit method; impossible to fake in tests | Depend on the app-owned interface (`KeyValueStore`, `SecureStorage`) injected via DI; cubits never touch storage packages directly |
| 4 | **Bumping `schemaVersion` without a migration** | Existing users' databases are corrupted or tables are silently dropped on upgrade | Every increment of `schemaVersion` must have a corresponding branch in `onUpgrade` using `m.addColumn(...)` or `m.createTable(...)`; never leave `onUpgrade` empty |
| 5 | **Running heavy DB operations on the main isolate** | UI jank or ANR during bulk inserts or large queries; `NativeDatabase` without `createInBackground` blocks the main thread | Always open the database via `NativeDatabase.createInBackground(file)`; wrap bulk writes in a single `db.transaction(...)` call |
| 6 | **Caching without TTL / expiry check** | Stale data served indefinitely after network errors; users see outdated content with no way to invalidate | Store `cachedAt` (drift's `currentDateAndTime` default), compare against `maxAge` on read, delete and return null if the entry is stale |
| 7 | **Repositories depending on `AppDatabase` directly instead of a DAO** | Repository imports `AppDatabase` and executes raw queries — bypasses the DAO abstraction, mixes query logic everywhere | Repositories depend only on the DAO (e.g., `CachedItemDao`); DAOs are the single place that writes drift table queries; register both via `getIt.registerLazySingleton` |
| 8 | **Forgetting to run codegen after changing drift tables** | `build_runner` output is stale; compile errors like `The getter 'myNewColumn' isn't defined` or missing generated mixins | After every change to a drift `Table` class or DAO, run `dart run build_runner build --delete-conflicting-outputs` before testing |

## Quick Summary

- **Never import storage packages outside `*_impl.dart`** — `SecureStorageImpl` is the only file that imports `flutter_secure_storage`; `KeyValueStoreImpl` is the only file that imports `shared_preferences`; files under `core/database/` are the only files that import `drift`.
- **Tokens and PII go in `SecureStorage`** — `SharedPreferences` is plaintext on disk. Never use it for auth tokens, API keys, or sensitive user data.
- **Repositories depend on DAOs, not the database** — blocs/cubits depend on repositories via DI. No direct storage calls from widgets or blocs.
- **Always use `drift`'s `NativeDatabase.createInBackground`** — database I/O runs on a background isolate, not the main isolate.
- **Wrap every schema change in a migration** — bumping `schemaVersion` without an `onUpgrade` handler corrupts or drops existing users' data.
- **Cache with TTL** — store `cachedAt` timestamp, evict stale entries before returning cached data.
- **Run codegen after every table change** — `dart run build_runner build --delete-conflicting-outputs`.

## Cross-references

- [flutter-di](../../flutter-di/references/template.md) — `SecureStorage`, `KeyValueStore`, and DAOs are all registered as `lazySingleton` in the composition root
- [flutter-offline](../../flutter-offline/references/template.md) — Drift `AppDatabase` is the offline cache backend for `SyncQueue` and cached entity DAOs
- [flutter-auth](../../flutter-auth/references/template.md) — `SecureStorage` is where `TokenManager` persists access and refresh tokens

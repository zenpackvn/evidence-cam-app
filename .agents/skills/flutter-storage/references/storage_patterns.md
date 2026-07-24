# Storage Patterns and Anti-Patterns

## Package guide

| Need | Package | Notes |
|---|---|---|
| Tokens, credentials, sensitive strings | `flutter_secure_storage` | Keychain (iOS) / EncryptedSharedPreferences (Android). Always use for auth tokens. |
| Simple key-value (settings, flags, preferences) | `shared_preferences` | Non-sensitive only. Wrapper: `KeyValueStore`. |
| Structured relational data, queries, migrations | `drift` | Type-safe SQLite with codegen. Joins, migrations, reactive queries. Default choice for SQLite. |
| Fast key-value / document store, no SQL | `hive` (or `hive_ce`) | Binary storage, very fast reads. Good for caching, local-only models. No migrations. |
| Document store with queries and indexes | `isar` | Powerful NoSQL with indexes and queries. Good for offline-first apps with complex filtering. |
| Offline-first with server sync | `brick_offline_first` | Built on `sqflite` + REST/GraphQL sync. Handles conflict resolution. |

**Default choice for SQLite is `drift`** — type-safe, migrations, reactive streams, well-maintained.

## When to pick what

| Scenario | Pick |
|---|---|
| Auth tokens, API keys, sensitive credentials | `flutter_secure_storage` via `SecureStorage` |
| User preferences, feature flags, simple settings | `shared_preferences` via `KeyValueStore` |
| Structured data with relations, queries, migrations | `drift` |
| Fast local cache, no relations, no migrations | `hive` / `hive_ce` |
| Offline-first with complex filtering/indexing | `isar` |

Always wrap. Never import the storage package outside the implementation file.

## Local Storage and Offline-First Patterns

- Default to `flutter_secure_storage` (tokens), `shared_preferences` (simple key-value), and `drift` (SQLite — structured/relational). Wrap each behind an app-owned interface.
- Keep storage reads/writes behind repositories, services, or data sources — never call directly from widgets or blocs.
- Decide whether remote, local, or merged data is the source of truth for each feature.
- Model cache freshness, empty cache, sync in progress, retry, and conflict states intentionally.
- When using optimistic updates, define rollback or reconciliation behavior up front.

## Pagination, Filtering, and Search Patterns

- Keep query, filter, sort, pagination cursor/page, and end-of-list state explicit.
- Reset pagination when query or filters change; prevent stale responses from appending into newer results.
- Debounce user-driven search when backend calls are expensive.
- Distinguish initial loading, loading more, empty, no more results, and retry states.
- Keep list item identity stable so pagination doesn't break selection or scroll state.

## Anti-Patterns

See [storage_anti_patterns.md](storage_anti_patterns.md) for code examples covering: tokens in SharedPreferences, direct storage access in cubits, main-isolate heavy queries, missing cache TTL, and repository depending on `AppDatabase` instead of a DAO.

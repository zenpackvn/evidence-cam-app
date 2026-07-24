---
name: flutter-storage
description: Use this skill when working on Flutter data persistence — SecureStorage (tokens, credentials), SharedPreferences (key-value non-sensitive), Drift (SQLite database, DAOs, tables, migrations), local database schema, caching, offline storage, key-value store, encrypted storage, or any local data layer.
---

# Flutter Storage

Full reference: [`template.md`](references/template.md)

## Key rules

- **Three storage tiers**, each behind an app-owned interface:
  1. `SecureStorage` — wraps `flutter_secure_storage`. Tokens, credentials, sensitive data only.
  2. `KeyValueStore` — wraps `shared_preferences`. Non-sensitive settings, flags, simple values.
  3. `AppDatabase` — Drift ORM over SQLite. Structured data, offline cache, sync queue.
- **Never import** `flutter_secure_storage`, `shared_preferences`, or `drift` outside their designated wrapper/impl files.
- Drift tables are defined in `app_database.dart` with `@DriftDatabase(tables: [...])`. DAOs are separate files per entity.
- DAO files annotated `@DriftAccessor(tables: [...])`. Each DAO exposes typed CRUD methods — never raw SQL in repository code.
- `AppDatabase` is a `LazyDatabase` backed by `sqlite3_flutter_libs`. Always created once as a singleton.
- Run `dart run build_runner build --delete-conflicting-outputs` after any Drift schema change.

## Files

```
lib/src/core/storage/
  secure_storage.dart            ← interface
  secure_storage_impl.dart       ← only import of flutter_secure_storage
  key_value_store.dart           ← interface
  key_value_store_impl.dart      ← only import of shared_preferences
lib/src/core/database/
  app_database.dart              ← @DriftDatabase, table definitions, LazyDatabase
  app_database.g.dart            ← generated
  daos/
    <entity>_dao.dart            ← @DriftAccessor, typed CRUD
    <entity>_dao.g.dart          ← generated
```

## Co-load with

- `flutter-di` — register as `lazySingleton`
- `flutter-offline` — Drift is the offline cache backend
- `flutter-auth` — `SecureStorage` stores tokens

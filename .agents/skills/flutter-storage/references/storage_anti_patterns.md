# Storage — Anti-Patterns

## 1. Storing sensitive data in SharedPreferences

```dart
// BAD: tokens are readable by anyone with device access
final prefs = await SharedPreferences.getInstance();
await prefs.setString('access_token', token);

// GOOD: encrypted at rest
final secureStorage = getIt<SecureStorage>();
await secureStorage.write('access_token', token);
```

## 2. Accessing storage directly in blocs/cubits

```dart
// BAD: direct import of shared_preferences in a cubit
class SettingsCubit extends Cubit<SettingsState> {
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('dark_mode') ?? false;
    emit(state.copyWith(isDark: isDark));
  }
}

// GOOD: depend on the app-owned interface via DI
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required KeyValueStore store})
      : _store = store,
        super(SettingsState.initial());

  final KeyValueStore _store;

  Future<void> loadTheme() async {
    final isDark = await _store.getBool('dark_mode') ?? false;
    emit(state.copyWith(isDark: isDark));
  }
}
```

## 3. Running heavy DB queries on the main isolate

```dart
// BAD: bulk insert on the main isolate freezes the UI
Future<void> importAll(List<Map<String, dynamic>> rows) async {
  for (final row in rows) {
    await dao.upsert(row['key'], jsonEncode(row));
  }
}

// GOOD: transaction + background isolate via NativeDatabase.createInBackground
Future<void> importAll(List<Map<String, dynamic>> rows) async {
  await db.transaction(() async {
    for (final row in rows) {
      await dao.upsert(row['key'] as String, jsonEncode(row));
    }
  });
}
```

## 4. No cache TTL or freshness policy

Caching data indefinitely without a TTL causes stale reads. Define a `cachedAt` timestamp on cached rows and treat cache as stale after a threshold (e.g. 15 minutes).

## 5. Repository depending on `AppDatabase` directly instead of a DAO

```dart
// BAD: repository imports AppDatabase and calls queries inline
class PostRepositoryImpl implements PostRepository {
  final AppDatabase _db;
  Future<List<Post>> getPosts() => _db.select(_db.posts).get(); // leaks schema
}

// GOOD: inject the DAO; repository never sees the full database object
class PostRepositoryImpl implements PostRepository {
  final PostDao _dao;
  Future<List<Post>> getPosts() => _dao.watchAll().first;
}
```

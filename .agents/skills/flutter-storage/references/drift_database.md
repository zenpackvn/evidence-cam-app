# SQLite Database (drift)

Only files under `core/database/` import `package:drift`. All feature DAOs and tables are defined here; repositories depend on the wrapper interface.

## `pubspec.yaml` additions

```yaml
dependencies:
  drift: 2.22.1
  sqlite3_flutter_libs: 0.5.28
  path_provider: 2.1.5
  path: 1.9.1

dev_dependencies:
  drift_dev: 2.22.1
  build_runner: 2.4.13   # already present
```

## `lib/src/core/database/app_database.dart`

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ── Tables ──

class CachedItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().withLength(min: 1, max: 255)();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {key},
      ];
}

// Add more tables here as features grow.

// ── Database ──

@DriftDatabase(tables: [CachedItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Add stepByStep migrations here as schema evolves.
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'app.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
```

Run codegen after editing tables:

```
dart run build_runner build --delete-conflicting-outputs
```

## `lib/src/core/database/daos/cached_item_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../app_database.dart';

part 'cached_item_dao.g.dart';

@DriftAccessor(tables: [CachedItems])
class CachedItemDao extends DatabaseAccessor<AppDatabase>
    with _$CachedItemDaoMixin {
  CachedItemDao(super.db);

  Future<CachedItem?> getByKey(String key) =>
      (select(cachedItems)..where((t) => t.key.equals(key)))
          .getSingleOrNull();

  Future<int> upsert(String key, String data) =>
      into(cachedItems).insertOnConflictUpdate(
        CachedItemsCompanion.insert(key: key, data: data),
      );

  Future<int> deleteByKey(String key) =>
      (delete(cachedItems)..where((t) => t.key.equals(key))).go();

  Future<int> clearAll() => delete(cachedItems).go();
}
```

## DI registration

```dart
getIt.registerLazySingleton<AppDatabase>(AppDatabase.new);
getIt.registerLazySingleton<CachedItemDao>(
  () => CachedItemDao(getIt<AppDatabase>()),
);
```

## Usage in a repository

The repository depends on the DAO (not the database directly):

```dart
class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({
    required this.apiClient,
    required this.cachedItemDao,
    required this.logger,
  });

  final ApiClient apiClient;
  final CachedItemDao cachedItemDao;
  final AppLogger logger;

  @override
  Future<List<Post>> fetchPosts() async {
    try {
      final dto = await apiClient.getPosts();
      await cachedItemDao.upsert('posts', jsonEncode(dto));
      return dto.map((d) => d.toDomain()).toList();
    } on FailureException {
      rethrow;
    } catch (e, s) {
      logger.warn('fetchPosts failed, trying cache', error: e, stackTrace: s);
      final cached = await cachedItemDao.getByKey('posts');
      if (cached != null) {
        final list = (jsonDecode(cached.data) as List).cast<Map<String, dynamic>>();
        return list.map((j) => PostDto.fromJson(j).toDomain()).toList();
      }
      throw const FailureException(NetworkFailure());
    }
  }
}
```

## Unit test setup

Use drift's in-memory database for tests — fast, isolated, no file system:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/src/core/database/app_database.dart';
import 'package:app/src/core/database/daos/cached_item_dao.dart';

void main() {
  late AppDatabase db;
  late CachedItemDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = CachedItemDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('upsert inserts a new item', () async {
    await dao.upsert('posts', '["hello"]');
    final result = await dao.getByKey('posts');
    expect(result, isNotNull);
    expect(result!.data, '["hello"]');
  });

  test('upsert overwrites existing item with same key', () async {
    await dao.upsert('posts', '["old"]');
    await dao.upsert('posts', '["new"]');
    final result = await dao.getByKey('posts');
    expect(result!.data, '["new"]');
  });

  test('getByKey returns null for missing key', () async {
    final result = await dao.getByKey('nonexistent');
    expect(result, isNull);
  });

  test('deleteByKey removes the item', () async {
    await dao.upsert('posts', '["data"]');
    await dao.deleteByKey('posts');
    final result = await dao.getByKey('posts');
    expect(result, isNull);
  });

  test('clearAll removes all items', () async {
    await dao.upsert('key1', 'a');
    await dao.upsert('key2', 'b');
    await dao.clearAll();
    expect(await dao.getByKey('key1'), isNull);
    expect(await dao.getByKey('key2'), isNull);
  });
}
```

## Anti-patterns

### DON'T bump `schemaVersion` without a migration

```dart
// BAD: schema version goes from 1 → 2 but onUpgrade does nothing
@override
int get schemaVersion => 2;

// DO: add explicit stepByStep migrations
@override
MigrationStrategy get migration => MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(cachedItems, cachedItems.expiresAt);
        }
      },
    );
```

### DON'T run heavy DB queries on the main isolate

```dart
// GOOD: runs on a background isolate; single transaction for bulk ops
Future<void> importAll(List<Map<String, dynamic>> rows) async {
  await db.transaction(() async {
    for (final row in rows) {
      await dao.upsert(row['key'] as String, jsonEncode(row));
    }
  });
}
```

### DON'T cache without expiry

```dart
// GOOD: TTL-based cache eviction
Future<String?> getCachedPosts({
  Duration maxAge = const Duration(hours: 1),
}) async {
  final item = await dao.getByKey('posts');
  if (item == null) return null;

  final age = DateTime.now().difference(item.cachedAt);
  if (age > maxAge) {
    await dao.deleteByKey('posts');
    return null;
  }
  return item.data;
}
```

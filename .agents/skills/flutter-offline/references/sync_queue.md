# Sync Queue (drift-backed)

Stores pending operations in the drift database. Provides FIFO ordering by `createdAt`.

## Folder structure

```text
lib/src/core/
  sync/
    sync_queue.dart       <- SyncQueue interface + SyncQueueImpl
    sync_manager.dart     <- Processes queue when online
    sync_operation.dart   <- Serializable pending operation model
  database/
    daos/
      sync_operation_dao.dart  <- Drift DAO
```

## `lib/src/core/sync/sync_operation.dart`

```dart
import 'package:equatable/equatable.dart';

class SyncOperation extends Equatable {
  const SyncOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
  });

  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;

  SyncOperation copyWith({int? retryCount}) {
    return SyncOperation(
      id: id,
      type: type,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      type: json['type'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, type, payload, createdAt, retryCount];
}
```

## Drift table — add to `app_database.dart`

```dart
class SyncOperations extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get payload => text()(); // JSON-encoded
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
```

Remember to add `SyncOperations` to the `@DriftDatabase(tables: [...])` annotation and run codegen:

```
dart run build_runner build --delete-conflicting-outputs
```

## `lib/src/core/database/daos/sync_operation_dao.dart`

```dart
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../sync/sync_operation.dart' as model;
import '../app_database.dart';

part 'sync_operation_dao.g.dart';

@DriftAccessor(tables: [SyncOperations])
class SyncOperationDao extends DatabaseAccessor<AppDatabase>
    with _$SyncOperationDaoMixin {
  SyncOperationDao(super.db);

  Future<void> insertOperation(model.SyncOperation op) =>
      into(syncOperations).insertOnConflictUpdate(
        SyncOperationsCompanion.insert(
          id: op.id,
          type: op.type,
          payload: jsonEncode(op.payload),
          createdAt: op.createdAt,
          retryCount: Value(op.retryCount),
        ),
      );

  Future<List<model.SyncOperation>> getAllPending() async {
    final rows = await (select(syncOperations)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows
        .map(
          (row) => model.SyncOperation(
            id: row.id,
            type: row.type,
            payload:
                Map<String, dynamic>.from(jsonDecode(row.payload) as Map),
            createdAt: row.createdAt,
            retryCount: row.retryCount,
          ),
        )
        .toList();
  }

  Future<void> deleteById(String id) =>
      (delete(syncOperations)..where((t) => t.id.equals(id))).go();

  Future<void> updateRetryCount(String id, int count) =>
      (update(syncOperations)..where((t) => t.id.equals(id))).write(
        SyncOperationsCompanion(retryCount: Value(count)),
      );

  Future<void> clearAll() => delete(syncOperations).go();
}
```

## `lib/src/core/sync/sync_queue.dart`

```dart
import '../database/daos/sync_operation_dao.dart';
import 'sync_operation.dart';

abstract interface class SyncQueue {
  Future<void> enqueue(SyncOperation operation);
  Future<void> dequeue(String id);
  Future<List<SyncOperation>> getPending();
  Future<void> updateRetryCount(String id, int count);
  Future<void> clear();
}

class SyncQueueImpl implements SyncQueue {
  SyncQueueImpl(this._dao);
  final SyncOperationDao _dao;

  @override
  Future<void> enqueue(SyncOperation operation) =>
      _dao.insertOperation(operation);

  @override
  Future<void> dequeue(String id) => _dao.deleteById(id);

  @override
  Future<List<SyncOperation>> getPending() => _dao.getAllPending();

  @override
  Future<void> updateRetryCount(String id, int count) =>
      _dao.updateRetryCount(id, count);

  @override
  Future<void> clear() => _dao.clearAll();
}
```

import 'package:database/database.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:rev_sync/rev_sync.dart';

/// ObjectBox-backed CRUD + sync helpers for stamps. Identity at this layer is
/// the string [StampEntity.uuid]; the integer `id` is an internal ObjectBox PK.
/// Implements [SyncLocalStore] so the generic sync engine can drive it.
abstract interface class StampsLocalDataSource
    implements SyncLocalStore<StampEntity> {
  /// All non-tombstoned stamps, newest-first.
  Future<List<StampEntity>> listVisible();

  /// Includes tombstoned (pendingDelete) rows.
  Future<List<StampEntity>> listAll();

  /// Inserts a new row in [SyncState.pendingCreate].
  Future<StampEntity> putNew(StampEntity entity);
}

@LazySingleton(as: StampsLocalDataSource)
class ObjectBoxStampsDataSource implements StampsLocalDataSource {
  ObjectBoxStampsDataSource(Store store) : _box = store.box<StampEntity>();

  final Box<StampEntity> _box;

  @override
  Future<List<StampEntity>> listVisible() async {
    final query = _box
        .query(StampEntity_.syncStateCode.notEquals(SyncState.pendingDelete.code))
        .order(StampEntity_.createdAt, flags: Order.descending)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<List<StampEntity>> listAll() async {
    final query = _box
        .query()
        .order(StampEntity_.createdAt, flags: Order.descending)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<StampEntity?> getByUuid(String uuid) async {
    final query = _box.query(StampEntity_.uuid.equals(uuid)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  @override
  Future<List<StampEntity>> listPending() async {
    // Only the active push-queue states — conflicted/failed rows await user
    // action and must not be re-pushed.
    final query = _box
        .query(
          StampEntity_.syncStateCode.oneOf([
            SyncState.pendingCreate.code,
            SyncState.pendingUpdate.code,
            SyncState.pendingDelete.code,
          ]),
        )
        .order(StampEntity_.updatedAt)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<StampEntity> putNew(StampEntity entity) async {
    _box.put(entity);
    return entity;
  }

  @override
  Future<void> put(StampEntity entity) async {
    _box.put(entity);
  }

  @override
  Future<void> hardDelete(StampEntity entity) async {
    _box.remove(entity.id);
  }
}

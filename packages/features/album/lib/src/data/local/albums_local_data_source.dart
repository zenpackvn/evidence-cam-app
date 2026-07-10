import 'package:database/database.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:rev_sync/rev_sync.dart';

/// ObjectBox-backed CRUD + sync helpers for albums. Identity is the string
/// [AlbumEntity.uuid]. Implements [SyncLocalStore] so the sync engine drives it.
abstract interface class AlbumsLocalDataSource
    implements SyncLocalStore<AlbumEntity> {
  Future<List<AlbumEntity>> listVisible();
  Future<List<AlbumEntity>> listAll();
  Future<AlbumEntity> putNew(AlbumEntity entity);
}

@LazySingleton(as: AlbumsLocalDataSource)
class ObjectBoxAlbumsDataSource implements AlbumsLocalDataSource {
  ObjectBoxAlbumsDataSource(Store store) : _box = store.box<AlbumEntity>();

  final Box<AlbumEntity> _box;

  @override
  Future<List<AlbumEntity>> listVisible() async {
    final query = _box
        .query(AlbumEntity_.syncStateCode.notEquals(SyncState.pendingDelete.code))
        .order(AlbumEntity_.createdAt, flags: Order.descending)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<List<AlbumEntity>> listAll() async {
    final query = _box
        .query()
        .order(AlbumEntity_.createdAt, flags: Order.descending)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<AlbumEntity?> getByUuid(String uuid) async {
    final query = _box.query(AlbumEntity_.uuid.equals(uuid)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  @override
  Future<List<AlbumEntity>> listPending() async {
    final query = _box
        .query(
          AlbumEntity_.syncStateCode.oneOf([
            SyncState.pendingCreate.code,
            SyncState.pendingUpdate.code,
            SyncState.pendingDelete.code,
          ]),
        )
        .order(AlbumEntity_.updatedAt)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<AlbumEntity> putNew(AlbumEntity entity) async {
    _box.put(entity);
    return entity;
  }

  @override
  Future<void> put(AlbumEntity entity) async {
    _box.put(entity);
  }

  @override
  Future<void> hardDelete(AlbumEntity entity) async {
    _box.remove(entity.id);
  }
}

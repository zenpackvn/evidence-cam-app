import 'package:architecture/architecture.dart';
import 'package:clock/clock.dart';
import 'package:database/database.dart';
import 'package:injectable/injectable.dart';
import 'package:rev_sync/rev_sync.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/album.dart';
import '../../domain/repositories/albums_repository.dart';
import '../../domain/services/albums_sync_controller.dart';
import '../local/album_entity_mapper.dart';
import '../local/albums_local_data_source.dart';

/// Offline-first albums: reads serve from the local ObjectBox store, writes
/// commit locally first (marking sync state) then kick a fire-and-forget sync.
@LazySingleton(as: AlbumsRepository)
class AlbumsRepositoryImpl implements AlbumsRepository {
  AlbumsRepositoryImpl(this._local, this._sync, this._uuid);

  final AlbumsLocalDataSource _local;
  final AlbumsSyncController _sync;
  final Uuid _uuid;

  @override
  Future<Result<List<Album>>> list() async {
    final result = await listLocal();
    _sync.sync().fire();
    return result;
  }

  @override
  Future<Result<List<Album>>> listLocal() async {
    final rows = await _local.listVisible();
    return Ok(rows.map((e) => e.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<Album>> get(String id) async {
    final row = await _local.getByUuid(id);
    if (row == null || row.syncState == SyncState.pendingDelete) {
      return const Err(NotFoundFailure('Album not found.'));
    }
    return Ok(row.toDomain());
  }

  @override
  Future<Result<Album>> create(AlbumInput input) async {
    final normalized = _normalize(input);
    final now = clock.now().toUtc();
    final entity = AlbumEntity(
      uuid: _uuid.v4(),
      name: normalized.name,
      stampIds: List.of(normalized.stampIds),
      createdAt: now,
      updatedAt: now,
      syncStateCode: SyncState.pendingCreate.code,
    );
    await _local.putNew(entity);
    _sync.sync().fire();
    return Ok(entity.toDomain());
  }

  @override
  Future<Result<Album>> update(String id, AlbumInput input) async {
    final existing = await _local.getByUuid(id);
    if (existing == null || existing.syncState == SyncState.pendingDelete) {
      return const Err(NotFoundFailure('Album not found.'));
    }
    existing.applyInput(_normalize(input), now: clock.now().toUtc());
    // pendingCreate stays pendingCreate (still needs the POST); anything else
    // becomes a pendingUpdate to (re)push.
    if (existing.syncState != SyncState.pendingCreate) {
      existing.syncState = SyncState.pendingUpdate;
    }
    await _local.put(existing);
    _sync.sync().fire();
    return Ok(existing.toDomain());
  }

  @override
  Future<Result<void>> delete(String id) async {
    final existing = await _local.getByUuid(id);
    if (existing == null || existing.syncState == SyncState.pendingDelete) {
      return const Err(NotFoundFailure('Album not found.'));
    }
    if (existing.syncState == SyncState.pendingCreate) {
      await _local.hardDelete(existing);
      return const Ok(null);
    }
    existing.syncState = SyncState.pendingDelete;
    existing.updatedAt = clock.now().toUtc();
    await _local.put(existing);
    _sync.sync().fire();
    return const Ok(null);
  }

  /// Trim the name + dedupe stamp ids so storage matches the server.
  AlbumInput _normalize(AlbumInput input) {
    final seen = <String>{};
    final stampIds = <String>[];
    for (final raw in input.stampIds) {
      final id = raw.trim();
      if (id.isEmpty || !seen.add(id)) continue;
      stampIds.add(id);
    }
    return AlbumInput(name: input.name.trim(), stampIds: stampIds);
  }
}

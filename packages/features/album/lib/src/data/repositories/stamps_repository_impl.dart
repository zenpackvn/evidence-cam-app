import 'package:architecture/architecture.dart';
import 'package:clock/clock.dart';
import 'package:database/database.dart';
import 'package:injectable/injectable.dart';
import 'package:rev_sync/rev_sync.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/stamp.dart';
import '../../domain/repositories/stamps_repository.dart';
import '../../domain/services/stamps_sync_controller.dart';
import '../local/stamp_entity_mapper.dart';
import '../local/stamps_local_data_source.dart';

/// Offline-first: reads serve from the local ObjectBox store, a save commits
/// locally first (pendingCreate) then kicks a fire-and-forget sync. Stamps are
/// immutable so there is no update path.
@LazySingleton(as: StampsRepository)
class StampsRepositoryImpl implements StampsRepository {
  StampsRepositoryImpl(this._local, this._sync, this._uuid);

  final StampsLocalDataSource _local;
  final StampsSyncController _sync;
  final Uuid _uuid;

  /// SM-022 BR-08: a stamp name is at most 30 characters.
  static const _maxNameLen = 30;

  @override
  Future<Result<List<Stamp>>> list() async {
    final result = await listLocal();
    _sync.sync().fire();
    return result;
  }

  @override
  Future<Result<List<Stamp>>> listLocal() async {
    final rows = await _local.listVisible();
    return Ok(rows.map((e) => e.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<Stamp>> get(String id) async {
    final row = await _local.getByUuid(id);
    if (row == null || row.syncState == SyncState.pendingDelete) {
      return const Err(NotFoundFailure('Stamp not found.'));
    }
    return Ok(row.toDomain());
  }

  @override
  Future<Result<Stamp>> save(StampInput input) async {
    // A stable id (saving a sample, SM-035 BR-03) is deduped locally: if it's
    // already in the album, saving again is a no-op, not a duplicate (AC-05).
    if (input.id != null) {
      final existing = await _local.getByUuid(input.id!);
      if (existing != null && existing.syncState != SyncState.pendingDelete) {
        return Ok(existing.toDomain());
      }
    }
    final now = clock.now().toUtc();
    final entity = StampEntity(
      uuid: input.id ?? _uuid.v4(),
      imageUrl: input.imageUrl.trim(),
      thumbUrl: input.thumbUrl?.trim(),
      name: input.name.trim(),
      source: input.source.wire,
      senderName: input.senderName?.trim(),
      senderUid: input.senderUid?.trim(),
      createdAt: now,
      updatedAt: now,
      syncStateCode: SyncState.pendingCreate.code,
    );
    await _local.putNew(entity);
    _sync.sync().fire();
    return Ok(entity.toDomain());
  }

  @override
  Future<Result<Stamp>> rename(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.runes.length > _maxNameLen) {
      return const Err(ValidationFailure('Tên tem tối đa 30 ký tự.'));
    }
    final existing = await _local.getByUuid(id);
    if (existing == null || existing.syncState == SyncState.pendingDelete) {
      return const Err(NotFoundFailure('Stamp not found.'));
    }
    existing.name = trimmed;
    existing.updatedAt = clock.now().toUtc();
    // A never-synced pendingCreate stays pendingCreate (the create carries the
    // name); an already-synced row becomes pendingUpdate to push a rename.
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
      return const Err(NotFoundFailure('Stamp not found.'));
    }
    // A never-synced pendingCreate can be dropped outright.
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
}

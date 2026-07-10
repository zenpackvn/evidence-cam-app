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
    final now = clock.now().toUtc();
    final entity = StampEntity(
      uuid: _uuid.v4(),
      imageUrl: input.imageUrl.trim(),
      thumbUrl: input.thumbUrl?.trim(),
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

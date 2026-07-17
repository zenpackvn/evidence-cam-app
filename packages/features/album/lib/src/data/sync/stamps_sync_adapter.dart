import 'package:database/database.dart';
import 'package:network/network.dart';
import 'package:rev_sync/rev_sync.dart';

import '../datasources/stamps_remote_data_source.dart';
import '../models/stamp_dto.dart';
import '../models/stamp_request.dart';

/// Bridges the stamps REST API to the generic sync engine. The only mutable
/// field is the user-set name (SM-022 BR-08), so [update] pushes a rename; the
/// create and delete paths and the delta pull mirror the collections adapter.
class StampsSyncAdapter implements SyncRemoteAdapter<StampEntity> {
  StampsSyncAdapter(this._remote);

  final StampsRemoteDataSource _remote;

  // 4xx codes worth retrying rather than giving up on.
  static const _retryable4xx = {401, 403, 408, 429};

  @override
  String get resource => 'stamps';

  @override
  Future<void> beforePush(StampEntity row) async {}

  @override
  Future<PushResult<StampEntity>> create(StampEntity row) async {
    try {
      final dto = await _remote.create(_requestFor(row));
      return PushApplied(_record(dto));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) return const PushSuperseded();
      _classify(e);
    }
  }

  @override
  Future<PushResult<StampEntity>> update(StampEntity row) async {
    // The only mutable field is the name (SM-022 BR-08); a local update is a
    // rename. Mirrors the collections update path.
    try {
      final dto = await _remote.rename(
        row.uuid,
        StampRenameRequest(name: row.name),
        _expectedRev(row),
      );
      return PushApplied(_record(dto));
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 404:
          return const PushGone();
        case 409:
          return const PushConflict();
        default:
          _classify(e);
      }
    }
  }

  @override
  Future<PushResult<StampEntity>> delete(StampEntity row) async {
    try {
      await _remote.delete(row.uuid, _expectedRev(row));
      return PushApplied(
        RemoteRecord<StampEntity>(
          uuid: row.uuid,
          rev: row.rev,
          updatedAt: row.updatedAt,
          deleted: true,
          build: () => row,
          apply: (_) {},
        ),
      );
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 404:
          return const PushGone();
        case 409:
          return const PushConflict();
        default:
          _classify(e);
      }
    }
  }

  @override
  Future<List<RemoteRecord<StampEntity>>> listSince(int cursor) async {
    final dtos = await _remote.list(since: cursor);
    return [for (final dto in dtos) _record(dto)];
  }

  int? _expectedRev(StampEntity row) => row.rev == 0 ? null : row.rev;

  StampRequest _requestFor(StampEntity row) => StampRequest(
    id: row.uuid,
    imageUrl: row.imageUrl,
    thumbUrl: row.thumbUrl ?? '',
    name: row.name,
    source: row.source,
    senderName: row.senderName ?? '',
    senderUid: row.senderUid ?? '',
  );

  RemoteRecord<StampEntity> _record(StampDto dto) {
    return RemoteRecord<StampEntity>(
      uuid: dto.id,
      rev: dto.rev,
      updatedAt: dto.createdAt,
      deleted: dto.deletedAt != null,
      build: () => _entityFromDto(dto),
      apply: (row) => _applyDto(row, dto),
    );
  }

  StampEntity _entityFromDto(StampDto dto) => StampEntity(
    uuid: dto.id,
    imageUrl: dto.imageUrl,
    thumbUrl: dto.thumbUrl.isEmpty ? null : dto.thumbUrl,
    name: dto.name,
    source: dto.source,
    senderName: dto.senderName.isEmpty ? null : dto.senderName,
    senderUid: dto.senderUid.isEmpty ? null : dto.senderUid,
    createdAt: dto.createdAt,
    updatedAt: dto.createdAt,
    serverUpdatedAt: dto.createdAt,
    rev: dto.rev,
    syncStateCode: SyncState.synced.code,
  );

  void _applyDto(StampEntity row, StampDto dto) {
    row
      ..imageUrl = dto.imageUrl
      ..thumbUrl = dto.thumbUrl.isEmpty ? null : dto.thumbUrl
      ..name = dto.name
      ..source = dto.source
      ..senderName = dto.senderName.isEmpty ? null : dto.senderName
      ..senderUid = dto.senderUid.isEmpty ? null : dto.senderUid
      ..serverUpdatedAt = dto.createdAt;
  }

  Never _classify(DioException error) {
    final code = error.response?.statusCode;
    if (code != null &&
        code >= 400 &&
        code < 500 &&
        !_retryable4xx.contains(code)) {
      throw SyncTerminalException('HTTP $code: ${error.message}');
    }
    throw SyncTransientException(error.message);
  }
}

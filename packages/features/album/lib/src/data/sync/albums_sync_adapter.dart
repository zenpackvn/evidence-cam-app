import 'package:database/database.dart';
import 'package:network/network.dart';
import 'package:rev_sync/rev_sync.dart';

import '../datasources/albums_remote_data_source.dart';
import '../models/album_dto.dart';
import '../models/album_request.dart';

/// Bridges the albums REST API to the generic sync engine: maps DTOs to
/// [RemoteRecord]s, sends the base revision for conflict detection, and
/// translates Dio errors into the engine's push outcomes.
class AlbumsSyncAdapter implements SyncRemoteAdapter<AlbumEntity> {
  AlbumsSyncAdapter(this._remote);

  final AlbumsRemoteDataSource _remote;

  static const _retryable4xx = {401, 403, 408, 429};

  @override
  String get resource => 'albums';

  @override
  Future<void> beforePush(AlbumEntity row) async {}

  @override
  Future<PushResult<AlbumEntity>> create(AlbumEntity row) async {
    try {
      final dto = await _remote.create(_requestFor(row, includeId: true));
      return PushApplied(_record(dto));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) return const PushSuperseded();
      _classify(e);
    }
  }

  @override
  Future<PushResult<AlbumEntity>> update(AlbumEntity row) async {
    try {
      final dto = await _remote.update(
        row.uuid,
        _requestFor(row, includeId: false),
        _expectedRev(row),
      );
      return PushApplied(_record(dto));
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 409:
          return const PushConflict();
        case 404:
          return const PushGone();
        default:
          _classify(e);
      }
    }
  }

  @override
  Future<PushResult<AlbumEntity>> delete(AlbumEntity row) async {
    try {
      await _remote.delete(row.uuid, _expectedRev(row));
      return PushApplied(
        RemoteRecord<AlbumEntity>(
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
  Future<List<RemoteRecord<AlbumEntity>>> listSince(int cursor) async {
    final dtos = await _remote.list(since: cursor);
    return [for (final dto in dtos) _record(dto)];
  }

  int? _expectedRev(AlbumEntity row) => row.rev == 0 ? null : row.rev;

  AlbumRequest _requestFor(AlbumEntity row, {required bool includeId}) {
    return AlbumRequest(
      id: includeId ? row.uuid : null,
      name: row.name,
      stampIds: row.stampIds,
    );
  }

  RemoteRecord<AlbumEntity> _record(AlbumDto dto) {
    return RemoteRecord<AlbumEntity>(
      uuid: dto.id,
      rev: dto.rev,
      updatedAt: dto.createdAt,
      deleted: dto.deletedAt != null,
      build: () => _entityFromDto(dto),
      apply: (row) => _applyDto(row, dto),
    );
  }

  AlbumEntity _entityFromDto(AlbumDto dto) => AlbumEntity(
    uuid: dto.id,
    name: dto.name,
    stampIds: List.of(dto.stampIds),
    createdAt: dto.createdAt,
    updatedAt: dto.createdAt,
    serverUpdatedAt: dto.createdAt,
    rev: dto.rev,
    syncStateCode: SyncState.synced.code,
  );

  void _applyDto(AlbumEntity row, AlbumDto dto) {
    row
      ..name = dto.name
      ..stampIds = List.of(dto.stampIds)
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

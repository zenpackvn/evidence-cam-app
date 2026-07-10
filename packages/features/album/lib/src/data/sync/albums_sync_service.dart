import 'package:database/database.dart';
import 'package:injectable/injectable.dart';
import 'package:rev_sync/rev_sync.dart';

import '../../domain/services/albums_sync_controller.dart';
import '../datasources/albums_remote_data_source.dart';
import '../local/albums_local_data_source.dart';
import 'albums_sync_adapter.dart';

/// Wires the albums feature onto the generic sync engine.
@LazySingleton(as: AlbumsSyncController)
class AlbumsSyncService implements AlbumsSyncController {
  AlbumsSyncService(
    AlbumsLocalDataSource local,
    AlbumsRemoteDataSource remote,
    ConnectivitySource connectivity,
    SyncCursorStore cursors,
  ) : _scheduler = SyncScheduler(
        OfflineCrudSync<AlbumEntity>(
          local,
          AlbumsSyncAdapter(remote),
          cursors,
        ).run,
        connectivity,
      );

  final SyncScheduler _scheduler;

  @override
  Stream<SyncStatus> get statusStream => _scheduler.statusStream;

  @override
  SyncStatus get statusNow => _scheduler.statusNow;

  @override
  Future<void> start() => _scheduler.start();

  @override
  Future<void> stop() => _scheduler.stop();

  @override
  Future<void> sync() => _scheduler.sync();
}

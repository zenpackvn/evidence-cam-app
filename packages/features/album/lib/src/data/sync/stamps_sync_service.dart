import 'package:database/database.dart';
import 'package:injectable/injectable.dart';
import 'package:rev_sync/rev_sync.dart';

import '../../domain/services/stamps_sync_controller.dart';
import '../datasources/stamps_remote_data_source.dart';
import '../local/stamps_local_data_source.dart';
import 'stamps_sync_adapter.dart';

/// Wires the stamps feature onto the generic sync engine: a [SyncScheduler]
/// driving an [OfflineCrudSync] built from the local store, the REST adapter,
/// and the shared delta cursor. All sync mechanics live in `package:rev_sync`.
@LazySingleton(as: StampsSyncController)
class StampsSyncService implements StampsSyncController {
  StampsSyncService(
    StampsLocalDataSource local,
    StampsRemoteDataSource remote,
    ConnectivitySource connectivity,
    SyncCursorStore cursors,
  ) : _scheduler = SyncScheduler(
        OfflineCrudSync<StampEntity>(
          local,
          StampsSyncAdapter(remote),
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

import 'package:rev_sync/rev_sync.dart';

export 'package:rev_sync/rev_sync.dart' show SyncStatus;

/// Controls the albums offline-first sync lifecycle. Started on sign-in,
/// stopped on sign-out; the repository triggers [sync] after each mutation.
abstract interface class AlbumsSyncController {
  Stream<SyncStatus> get statusStream;
  SyncStatus get statusNow;
  Future<void> start();
  Future<void> stop();
  Future<void> sync();
}

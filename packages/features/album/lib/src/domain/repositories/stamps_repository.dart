import 'package:architecture/architecture.dart';

import '../entities/stamp.dart';

/// Offline-first access to the user's stamps. Reads come from the local
/// ObjectBox store; a background sync reconciles with the server.
abstract interface class StampsRepository {
  /// All non-deleted stamps, newest-first, triggering a background sync.
  Future<Result<List<Stamp>>> list();

  /// Reads the local store without triggering a sync (post-sync re-reads).
  Future<Result<List<Stamp>>> listLocal();

  Future<Result<Stamp>> get(String id);

  /// Saves a rendered stamp. The server reserves a monthly quota slot for a
  /// self-created stamp (SM-011 BR-06); received stamps don't count.
  Future<Result<Stamp>> save(StampInput input);

  /// Renames a stamp (SM-022 BR-08). [name] is trimmed; an empty string clears
  /// the custom name. Commits locally then syncs.
  Future<Result<Stamp>> rename(String id, String name);

  Future<Result<void>> delete(String id);
}

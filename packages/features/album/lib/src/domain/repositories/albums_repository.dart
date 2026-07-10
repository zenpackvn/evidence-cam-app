import 'package:architecture/architecture.dart';

import '../entities/album.dart';

/// Offline-first access to the user's custom albums. Reads come from the local
/// ObjectBox store; a background sync reconciles with the server.
abstract interface class AlbumsRepository {
  Future<Result<List<Album>>> list();

  /// Reads the local store without triggering a sync (post-sync re-reads).
  Future<Result<List<Album>>> listLocal();

  Future<Result<Album>> get(String id);
  Future<Result<Album>> create(AlbumInput input);
  Future<Result<Album>> update(String id, AlbumInput input);
  Future<Result<void>> delete(String id);
}

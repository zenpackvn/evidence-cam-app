import 'package:path_provider/path_provider.dart';

import '../objectbox.g.dart';
import 'entities/activity_entity.dart';
import 'entities/album_entity.dart';
import 'entities/bookmark_entity.dart';
import 'entities/collection_entity.dart';
import 'entities/notification_entity.dart';
import 'entities/stamp_entity.dart';
import 'entities/sync_cursor_entity.dart';

/// Owns the lifecycle of the ObjectBox [Store]. There must be exactly one
/// store per database path per process — opening twice throws — so this is
/// constructed once during DI init (see the host app's `ObjectBoxModule`) and
/// held as a singleton.
class ObjectBox {
  ObjectBox._(this.store);

  final Store store;

  static Future<ObjectBox> open() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: '${docsDir.path}/objectbox');
    return ObjectBox._(store);
  }

  void close() => store.close();

  /// Wipes all locally-cached user data and sync cursors. Call this on account
  /// switch (a different uid signs in on this device) so the next sync pulls
  /// the newly-signed-in user's data from scratch, instead of leaking the
  /// previous user's rows or reusing their already-advanced cursor.
  void clearUserData() {
    store.box<StampEntity>().removeAll();
    store.box<AlbumEntity>().removeAll();
    store.box<CollectionEntity>().removeAll();
    store.box<BookmarkEntity>().removeAll();
    store.box<ActivityEntity>().removeAll();
    store.box<NotificationEntity>().removeAll();
    store.box<SyncCursorEntity>().removeAll();
  }
}

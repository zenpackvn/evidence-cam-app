import 'package:objectbox/objectbox.dart' hide SyncState;
import 'package:rev_sync/rev_sync.dart';

/// ObjectBox row for a custom album — a user-named group of stamp ids
/// (StampMail SM-022 BR-06). The built-in "All / Created / Received" albums are
/// derived from `stamps.source`, not stored as rows.
///
/// Mutable by necessity: ObjectBox writes back into instances during property
/// loading. Domain conversion lives in the album feature's data layer.
@Entity()
class AlbumEntity implements Syncable {
  AlbumEntity({
    this.id = 0,
    required this.uuid,
    required this.name,
    required this.stampIds,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    this.syncStateCode = 0,
    this.rev = 0,
  });

  @Id()
  int id;

  @override
  @Unique()
  String uuid;

  String name;

  /// Stable stamp uuids in this album. One stamp may live in many albums.
  List<String> stampIds;

  @Property(type: PropertyType.dateNanoUtc)
  DateTime createdAt;

  @override
  @Property(type: PropertyType.dateNanoUtc)
  DateTime updatedAt;

  @Property(type: PropertyType.dateNanoUtc)
  DateTime? serverUpdatedAt;

  @override
  int rev;

  int syncStateCode;

  @override
  @Transient()
  SyncState get syncState => SyncState.fromCode(syncStateCode);
  @override
  set syncState(SyncState value) => syncStateCode = value.code;
}

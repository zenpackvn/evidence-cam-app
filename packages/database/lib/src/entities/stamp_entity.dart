import 'package:objectbox/objectbox.dart' hide SyncState;
import 'package:rev_sync/rev_sync.dart';

/// ObjectBox row for a stamp — a finished, flattened stamp image the user
/// created or received in a letter (StampMail SM-022). Mutable by necessity:
/// ObjectBox writes back into instances during property loading, so this cannot
/// be a Freezed/sealed class.
///
/// Pure persistence model; domain conversion lives in the album feature's data
/// layer (`StampEntityMapper`). Mirrors the server `stamps` table.
@Entity()
class StampEntity implements Syncable {
  StampEntity({
    this.id = 0,
    required this.uuid,
    required this.imageUrl,
    this.thumbUrl,
    required this.source,
    this.senderName,
    this.senderUid,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    this.syncStateCode = 0,
    this.rev = 0,
  });

  /// ObjectBox primary key. Internal — never exposed to the domain layer.
  @Id()
  int id;

  /// Stable string ID shared with the server. Generated client-side at create
  /// time so the row has a meaningful id before the first sync.
  @override
  @Unique()
  String uuid;

  /// URL of the rendered stamp PNG (Cloudflare R2).
  String imageUrl;

  /// Smaller preview URL, when available.
  String? thumbUrl;

  /// `created` (made in the stamp creator) or `received` (saved from a letter).
  String source;

  /// Display name of the sender, set when [source] is `received`.
  String? senderName;

  /// UID of the sender, set when [source] is `received`.
  String? senderUid;

  /// Stored and read back as UTC.
  @Property(type: PropertyType.dateNanoUtc)
  DateTime createdAt;

  /// Local mutation time — bumped on any local change. The sync engine compares
  /// it before/after a push to detect a concurrent edit.
  @override
  @Property(type: PropertyType.dateNanoUtc)
  DateTime updatedAt;

  /// Server's `updatedAt` at the last successful pull/push. `null` until synced.
  @Property(type: PropertyType.dateNanoUtc)
  DateTime? serverUpdatedAt;

  /// Server revision this row was last reconciled to. Drives delta sync and
  /// conflict detection. 0 until first acknowledged by the server.
  @override
  int rev;

  /// Stored form of [syncState]. Use the [syncState] getter/setter instead.
  int syncStateCode;

  @override
  @Transient()
  SyncState get syncState => SyncState.fromCode(syncStateCode);
  @override
  set syncState(SyncState value) => syncStateCode = value.code;
}

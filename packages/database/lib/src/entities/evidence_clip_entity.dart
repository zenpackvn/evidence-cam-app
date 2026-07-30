import 'package:objectbox/objectbox.dart';

/// ObjectBox row for one recorded evidence clip awaiting (or having completed)
/// upload. This is the single source of truth for the offline upload queue —
/// it replaces the old hand-rolled `queue.json` file so a clip survives app
/// restarts and OS temp cleanup (FR-08/FR-09: "never lose the seller's
/// evidence").
///
/// Pure persistence model — mutable by necessity (ObjectBox writes back into
/// instances on load, so this cannot be a Freezed/sealed class). The clip's
/// bytes live on disk at [filePath]; only its metadata + upload state live here.
/// Conversion to/from the app-level `UploadTask` UI model lives in the app's
/// data layer (`ObjectBoxEvidenceClipStore`), keeping `feature/app → database`.
@Entity()
class EvidenceClipEntity {
  EvidenceClipEntity({
    this.id = 0,
    required this.taskId,
    required this.tracking,
    required this.type,
    required this.filePath,
    required this.createdAt,
    this.shopId,
    this.stateCode = 0,
    this.progress = 0,
    this.retryCount = 0,
    this.remoteUrl,
    this.errorMessage,
  });

  /// ObjectBox primary key. Internal — never exposed to the UI. 0 means "new";
  /// ObjectBox assigns it on first `put`.
  @Id()
  int id;

  /// Stable client-generated id for the clip (the queue's task id). Unique with
  /// replace-on-conflict, so persisting a task is a plain `box.put` (id 0) that
  /// upserts by [taskId] without tracking the internal [id].
  @Unique(onConflict: ConflictStrategy.replace)
  String taskId;

  /// Order tracking code this clip belongs to.
  String tracking;

  /// Video type label (e.g. "Đóng hàng").
  String type;

  /// Shop the clip belongs to; needed by the real backend uploader. Null on the
  /// offline path / older rows.
  String? shopId;

  /// Absolute path of the copied-into-app-documents clip file.
  String filePath;

  /// Stored and read back as UTC.
  @Property(type: PropertyType.dateNanoUtc)
  DateTime createdAt;

  /// Stored form of `EcUploadState.index` (waiting / uploading / done / error).
  /// An `uploading` row is reset to `waiting` on load so a kill mid-upload is
  /// retried, not left stuck.
  int stateCode;

  /// Last known upload progress 0..1. Transient — reset to 0 on load.
  double progress;

  /// How many times the upload has failed and been retried.
  int retryCount;

  /// Remote URL once uploaded; null while still local.
  String? remoteUrl;

  /// Human-readable reason the last upload attempt failed; null while
  /// waiting/uploading/done, or for rows persisted before this field existed.
  String? errorMessage;
}

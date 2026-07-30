/// Persistence backend for the evidence upload queue.
///
/// [EvidenceClipStore] is the seam `EcUploadQueue` writes its tasks through.
/// The app binds [ObjectBoxEvidenceClipStore] — the single source of truth in
/// ObjectBox (FR-08/FR-09), replacing the old hand-rolled `queue.json` file.
/// Tests bind [InMemoryEvidenceClipStore]. The queue keeps the authoritative
/// in-memory list; this layer only persists it so it survives app restarts.
library;

import 'package:database/database.dart';

import 'ec_upload_queue.dart' show EcUploadState, UploadTask;

/// Reads/writes the queue's persisted clips.
abstract interface class EvidenceClipStore {
  /// All persisted clips (order unspecified; the queue sorts as needed).
  Future<List<UploadTask>> loadAll();

  /// Upserts [task] by its id.
  Future<void> save(UploadTask task);

  /// Deletes the persisted clip with this id, if any.
  Future<void> remove(String id);
}

/// ObjectBox-backed store — the production single source of truth.
class ObjectBoxEvidenceClipStore implements EvidenceClipStore {
  ObjectBoxEvidenceClipStore(Store store)
    : _box = store.box<EvidenceClipEntity>();

  final Box<EvidenceClipEntity> _box;

  @override
  Future<List<UploadTask>> loadAll() async => [
    for (final row in _box.getAll()) taskFromEntity(row),
  ];

  @override
  Future<void> save(UploadTask task) async => _box.put(entityFromTask(task));

  @override
  Future<void> remove(String id) async {
    final query = _box.query(EvidenceClipEntity_.taskId.equals(id)).build();
    try {
      query.remove();
    } finally {
      query.close();
    }
  }
}

/// In-memory store for tests (and a safe default when no DB is wired). Stores
/// an independent snapshot per save, so — like real ObjectBox — a later
/// mutation doesn't "persist" unless [save] is called again.
class InMemoryEvidenceClipStore implements EvidenceClipStore {
  final Map<String, UploadTask> _byId = {};

  @override
  Future<List<UploadTask>> loadAll() async => _byId.values.toList();

  @override
  Future<void> save(UploadTask task) async =>
      _byId[task.id] = taskFromEntity(entityFromTask(task));

  @override
  Future<void> remove(String id) async => _byId.remove(id);
}

/// Maps a persisted row to the UI/queue model.
UploadTask taskFromEntity(EvidenceClipEntity e) => UploadTask(
  id: e.taskId,
  tracking: e.tracking,
  type: e.type,
  filePath: e.filePath,
  createdAt: e.createdAt,
  shopId: e.shopId,
  state: EcUploadState.values[e.stateCode],
  progress: e.progress,
  retryCount: e.retryCount,
  remoteUrl: e.remoteUrl,
  errorMessage: e.errorMessage,
);

/// Maps the UI/queue model to a persisted row. id 0 + replace-on-conflict on
/// `taskId` makes `box.put` a plain upsert.
EvidenceClipEntity entityFromTask(UploadTask t) => EvidenceClipEntity(
  taskId: t.id,
  tracking: t.tracking,
  type: t.type,
  filePath: t.filePath,
  createdAt: t.createdAt,
  shopId: t.shopId,
  stateCode: t.state.index,
  progress: t.progress,
  retryCount: t.retryCount,
  remoteUrl: t.remoteUrl,
  errorMessage: t.errorMessage,
);

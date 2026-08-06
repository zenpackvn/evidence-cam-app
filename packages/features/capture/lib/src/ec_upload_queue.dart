/// Offline-first upload queue for recorded evidence clips.
///
/// Every recording is copied into the app-documents dir and tracked in an
/// [EvidenceClipStore] (ObjectBox in the app) so it survives app restarts and
/// OS temp cleanup (FR-08/FR-09: "never lose the seller's evidence"). A
/// pluggable [EcEvidenceUploader] does the actual transport; without one (no
/// backend URL configured) clips simply wait.
library;

// The constructor uses public named params bound to private fields, which
// prefer_initializing_formals can't express (named params can't be private).
// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart' show CrashReporter;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'ec_evidence_store.dart';
import 'ec_evidence_uploader.dart';
import 'ec_video_faststart.dart' show evidenceFaststartPrefix;

enum EcUploadState { waiting, uploading, done, error, quotaWait, paused }

/// One queued clip and its upload progress.
class UploadTask {
  UploadTask({
    required this.id,
    required this.tracking,
    required this.type,
    required this.filePath,
    required this.createdAt,
    this.shopId,
    this.state = EcUploadState.waiting,
    this.progress = 0,
    this.retryCount = 0,
    this.remoteUrl,
    this.errorMessage,
    this.durationSeconds,
    this.samplesJson,
  });

  /// Parses a task from the legacy `queue.json` format, used only by the
  /// one-time migration into the store.
  factory UploadTask.fromJson(Map<String, dynamic> json) => UploadTask(
    id: json['id'] as String,
    tracking: json['tracking'] as String,
    type: json['type'] as String,
    filePath: json['filePath'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    shopId: json['shopId'] as String?,
    state: EcUploadState.values[json['state'] as int],
    progress: (json['progress'] as num).toDouble(),
    retryCount: json['retryCount'] as int,
    remoteUrl: json['remoteUrl'] as String?,
  );

  final String id;
  final String tracking;
  final String type;
  final String filePath;
  final DateTime createdAt;

  /// Shop the clip belongs to; needed by the real backend uploader. Older
  /// persisted tasks (and the offline path) may leave it null.
  final String? shopId;
  EcUploadState state;
  double progress;
  int retryCount;
  String? remoteUrl;

  /// Human-readable reason the last attempt failed; only set alongside
  /// [EcUploadState.error]. Cleared on retry.
  String? errorMessage;

  /// Recorded clip length in seconds, captured at stop time. Null for photos
  /// and for older persisted tasks.
  final int? durationSeconds;

  /// Điều kiện thiết bị lấy mẫu trong lúc quay, đã mã hoá JSON. Đi cùng clip
  /// qua hàng đợi vì clip offline có thể tới lúc upload sau nhiều giờ — lúc đó
  /// pin và mạng của máy đã khác hẳn lúc quay. Null cho ảnh và task cũ.
  final String? samplesJson;
}

class EcUploadQueue extends ChangeNotifier {
  // Private fields + public named params, so an initializing formal (which
  // can't be named and private) doesn't apply here.
  EcUploadQueue({
    EcEvidenceUploader? uploader,
    EvidenceClipStore? store,
    AnalyticsService? analytics,
    CrashReporter? crashReporter,
    @visibleForTesting Directory? directory,
    @visibleForTesting Directory? temporaryDirectory,
  }) : _uploader = uploader,
       _store = store ?? InMemoryEvidenceClipStore(),
       _analytics = analytics,
       _crashReporter = crashReporter,
       _dir = directory,
       _temp = temporaryDirectory;

  final EcEvidenceUploader? _uploader;
  final EvidenceClipStore _store;
  final AnalyticsService? _analytics;
  final CrashReporter? _crashReporter;
  final List<UploadTask> _tasks = [];
  bool _processing = false;
  Directory? _dir;
  Directory? _temp;

  /// Newest-first view of the queue.
  List<UploadTask> get tasks => List.unmodifiable(_tasks);

  /// Loads the persisted queue from the store and resumes processing. Call
  /// once. Any failure leaves an empty in-memory queue rather than crashing.
  Future<void> load() async {
    try {
      final loaded = await _store.loadAll();
      _tasks
        ..clear()
        // Drop entries whose clip file is gone.
        ..addAll(loaded.where((t) => File(t.filePath).existsSync()));
      await _importLegacyJson();
      // An upload interrupted by a kill is retried, not left stuck.
      for (final task in _tasks) {
        if (task.state == EcUploadState.uploading) {
          task
            ..state = EcUploadState.waiting
            ..progress = 0;
          await _store.save(task);
        }
      }
      _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // Strictly after the legacy import: `queue.json` lives in the evidence
      // dir, so sweeping first would delete the very file being migrated.
      await _sweepOrphans();
    } on Object {
      // No storage / corrupt data — run with an empty queue.
    }
    notifyListeners();
    unawaited(_process());
  }

  /// Copies [filePath] into the app-documents dir and enqueues it. [shopId]
  /// scopes the clip for the real backend uploader; omit it on the offline path.
  /// [durationSeconds] is the recorded clip length, known at stop time; omit
  /// for photos.
  Future<void> enqueue({
    required String tracking,
    required String type,
    required String filePath,
    String? shopId,
    int? durationSeconds,
    String? samplesJson,
    DateTime? capturedAt,
  }) async {
    final dir = await _evidenceDir();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    var stored = '${dir.path}/$id${_ext(filePath)}';
    var copied = false;
    try {
      await File(filePath).copy(stored);
      copied = true;
    } on Object {
      stored = filePath; // Fall back to the original path if the copy fails.
    }
    // The copy above is the durable one. Whatever we were handed is a
    // throwaway the OS never reliably reclaims, so drop it now that its
    // contents are safe — see [_deleteSourceIfTemporary].
    if (copied) await _deleteSourceIfTemporary(filePath);
    final task = UploadTask(
      id: id,
      tracking: tracking,
      type: type,
      filePath: stored,
      // Mốc BẤM QUAY, không phải giờ xếp hàng.
      //
      // Xếp hàng xảy ra sau khi đã quay xong, remux xong và nung chữ xong —
      // với clip 2 phút trên máy tầm trung là lệch 3–5 phút. Máy chủ lấy mốc
      // này làm đồng hồ chạy trên trang hồ sơ, nên nó đá nhau với chính chữ
      // app đã nung lên cùng khung hình đó. Hai đồng hồ lệch nhau trên một
      // khung là thứ đối phương chỉ vào đầu tiên khi tranh chấp.
      createdAt: capturedAt ?? DateTime.now(),
      shopId: shopId,
      durationSeconds: durationSeconds,
      samplesJson: samplesJson,
    );
    _tasks.insert(0, task);
    await _store.save(task);
    notifyListeners();
    unawaited(_process());
  }

  /// Moves an errored task back to waiting and kicks the processor.
  Future<void> retry(String id) async {
    final task = _byId(id);
    if (task == null || task.state == EcUploadState.uploading) return;
    task
      ..state = EcUploadState.waiting
      ..progress = 0
      ..errorMessage = null;
    await _store.save(task);
    notifyListeners();
    unawaited(_process());
  }

  /// Takes a not-yet-uploading task out of the queue's rotation. A currently
  /// uploading task can't be interrupted mid-request, so pausing it is a
  /// no-op until it finishes.
  Future<void> pause(String id) async {
    final task = _byId(id);
    if (task == null || task.state == EcUploadState.uploading) return;
    task.state = EcUploadState.paused;
    await _store.save(task);
    notifyListeners();
  }

  /// Puts a paused task back in the queue and kicks the processor.
  Future<void> resume(String id) async {
    final task = _byId(id);
    if (task == null || task.state != EcUploadState.paused) return;
    task.state = EcUploadState.waiting;
    await _store.save(task);
    notifyListeners();
    unawaited(_process());
  }

  /// Removes a task from the queue entirely and deletes its local copy. Safe
  /// to call on an in-flight upload — [_process] checks the task is still
  /// present before writing its result back.
  Future<void> delete(String id) async {
    final task = _byId(id);
    if (task == null) return;
    _tasks.remove(task);
    await _store.remove(id);
    notifyListeners();
    unawaited(_deleteLocalCopyQuietly(task.filePath));
  }

  Future<void> _deleteLocalCopyQuietly(String path) async {
    try {
      await File(path).delete();
    } on Object {
      // Already gone, or never existed — nothing left to clean up.
    }
  }

  /// Deletes a just-copied source file, but only when it sits in the OS temp
  /// dir.
  ///
  /// Everything the queue is handed from there is already a throwaway copy —
  /// the faststart remux, the camera's own temp clip, `image_picker`'s cache
  /// entry (its returned path never points at the user's original photo, see
  /// `_persistAvatarFile`). Anything *outside* temp could be a real user file,
  /// so it is left alone.
  Future<void> _deleteSourceIfTemporary(String path) async {
    final temp = await _temporaryDir();
    if (temp == null || !_isInside(temp, path)) return;
    await _deleteLocalCopyQuietly(path);
  }

  /// Reclaims clip files nothing references any more.
  ///
  /// Two leaks feed this: a crash between [enqueue]'s copy and its store write
  /// strands a file in the evidence dir, and a crash between the faststart
  /// remux and [enqueue] strands one in temp. Neither directory is enumerated
  /// anywhere else, so without this sweep they are never reclaimed. Runs at
  /// [load] — no recording is in flight then, so any remux left over is
  /// garbage by definition.
  Future<void> _sweepOrphans() async {
    final referenced = {for (final task in _tasks) task.filePath};
    try {
      final dir = await _evidenceDir();
      for (final entity in dir.listSync()) {
        if (entity is! File || referenced.contains(entity.path)) continue;
        await _deleteLocalCopyQuietly(entity.path);
      }
    } on Object {
      // Unreadable directory — nothing to reclaim.
    }
    try {
      final temp = await _temporaryDir();
      if (temp == null) return;
      for (final entity in temp.listSync()) {
        if (entity is! File) continue;
        final name = entity.path.split('/').last;
        if (!name.startsWith(evidenceFaststartPrefix)) continue;
        if (referenced.contains(entity.path)) continue;
        await _deleteLocalCopyQuietly(entity.path);
      }
    } on Object {
      // No temp dir available (e.g. a plain unit test) — nothing to reclaim.
    }
  }

  Future<Directory?> _temporaryDir() async {
    final dir = _temp;
    if (dir != null) return dir;
    try {
      return _temp = await getTemporaryDirectory();
    } on Object {
      return null; // No path_provider platform side — skip temp handling.
    }
  }

  static bool _isInside(Directory dir, String path) {
    final base = dir.path.endsWith('/') ? dir.path : '${dir.path}/';
    return path.startsWith(base);
  }

  Future<void> _process() async {
    if (_processing || _uploader == null) return;
    _processing = true;
    try {
      while (true) {
        final task = _firstWaiting();
        if (task == null) break;
        task
          ..state = EcUploadState.uploading
          ..progress = 0;
        await _store.save(task);
        notifyListeners();
        var succeeded = false;
        try {
          // Dio reports progress per ~64KB chunk — tens of calls/second for a
          // typical clip. Only notifying on an actual percent change (the
          // finest granularity the UI shows anyway) keeps every screen
          // listening to this queue (account tab, orders, the record screen
          // itself) from rebuilding many times a second during an upload.
          var lastPercent = -1;
          final url = await _uploader.upload(
            File(task.filePath),
            tracking: task.tracking,
            type: task.type,
            shopId: task.shopId,
            capturedAt: task.createdAt.millisecondsSinceEpoch,
            durationSeconds: task.durationSeconds,
            samplesJson: task.samplesJson,
            onProgress: (p) {
              task.progress = p;
              final percent = (p * 100).round();
              if (percent == lastPercent) return;
              lastPercent = percent;
              notifyListeners();
            },
          );
          task
            ..state = EcUploadState.done
            ..progress = 1
            ..remoteUrl = url;
          succeeded = true;
          unawaited(_analytics?.trackUploadCompleted());
          // Bytes đã nằm trên R2 và backend đã xác nhận, nên bản trên máy hết
          // giá trị. Một ca đóng hàng sinh hàng trăm clip; giữ lại là lấp đầy
          // bộ nhớ máy rồi chính việc quay bị chặn vì hết chỗ (FR-09).
          unawaited(_deleteLocalFile(task.filePath));
        } on Object catch (error, stack) {
          // Non-fatal: the task stays queued and retries, but the *reason*
          // must reach Crashlytics — this is the only path a real-world
          // upload failure (bad network, expired presign, R2 error) is
          // observable at all; nothing else in this flow logs it.
          unawaited(
            _crashReporter?.recordError(
              error,
              stack,
              reason: 'upload_failed: ${task.type}',
            ),
          );
          if (_isQuotaWait(error)) {
            task
              ..state = EcUploadState.quotaWait
              ..progress = 0
              // Giữ nguyên câu server trả về. Trước đây nhánh này vứt bỏ nó,
              // nên khi màn Quota báo còn thừa dung lượng mà clip vẫn bị từ
              // chối thì không có cách nào biết server tính theo tiêu chí gì
              // — người dùng chỉ thấy "chờ quota" chung chung.
              ..errorMessage = error.toString();
          } else {
            task
              ..state = EcUploadState.error
              ..retryCount += 1
              // error.toString() is deliberately the whole message shown to
              // the seller — ApiEvidenceUploader rewraps network failures
              // into an UploadFailureException with a message already safe
              // to display, rather than a raw DioException.
              ..errorMessage = error.toString();
            unawaited(_analytics?.trackUploadFailed());
          }
        }
        // Deleted mid-upload — don't resurrect it in the store/list.
        if (!_tasks.contains(task)) continue;
        if (succeeded) {
          // Done means it's fully uploaded — it now lives on the order's
          // evidence timeline (Vận đơn), so drop it from this queue instead
          // of leaving a permanent "done" entry here.
          _tasks.remove(task);
          await _store.remove(task.id);
          unawaited(_deleteLocalCopyQuietly(task.filePath));
        } else {
          await _store.save(task);
        }
        notifyListeners();
      }
    } finally {
      _processing = false;
    }
  }

  UploadTask? _firstWaiting() {
    for (final task in _tasks) {
      if (task.state == EcUploadState.waiting) return task;
    }
    return null;
  }

  UploadTask? _byId(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  /// One-time migration: import any pre-existing `queue.json` into the store,
  /// then delete it so it never re-imports. Keeps clips queued before the
  /// ObjectBox switch (FR-08/FR-09).
  Future<void> _importLegacyJson() async {
    try {
      final file = File('${(await _evidenceDir()).path}/queue.json');
      if (!file.existsSync()) return;
      final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
      final existing = {for (final t in _tasks) t.id};
      for (final map in raw.cast<Map<String, dynamic>>()) {
        final task = UploadTask.fromJson(map);
        if (existing.contains(task.id) || !File(task.filePath).existsSync()) {
          continue;
        }
        _tasks.add(task);
        await _store.save(task);
      }
      await file.delete();
    } on Object {
      // Corrupt legacy file — skip; nothing to migrate.
    }
  }

  Future<Directory> _evidenceDir() async {
    final dir = _dir;
    if (dir != null) return dir;
    final base = await getApplicationDocumentsDirectory();
    final evidence = Directory('${base.path}/evidence');
    if (!evidence.existsSync()) evidence.createSync(recursive: true);
    return _dir = evidence;
  }

  static String _ext(String path) {
    final dot = path.lastIndexOf('.');
    final slash = path.lastIndexOf('/');
    return dot > slash ? path.substring(dot) : '.mp4';
  }
}

/// Xoá bản clip trên máy sau khi backend đã xác nhận lưu xong.
///
/// Best-effort: file đã bị dọn sẵn, đường dẫn không còn hợp lệ, hay quyền ghi
/// bị từ chối đều không phải chuyện đáng làm hỏng một upload vốn đã thành
/// công — hệ điều hành sẽ dọn thư mục tạm sau. Chỉ chạy khi `state` đã là
/// `done`, nên không có đường nào mất clip chưa đẩy lên.
Future<void> _deleteLocalFile(String path) async {
  try {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  } on Object {
    // Xem chú thích trên.
  }
}

bool _isQuotaWait(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('quota_exceeded') ||
      text.contains('quota exceeded') ||
      text.contains('quota limit') ||
      text.contains('monthly quota');
}

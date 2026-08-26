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
import 'ec_preview_store.dart';
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
    this.ownerUid,
    this.videoTypeId,
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

  /// Nhãn loại video, để hiển thị trong hàng đợi.
  final String type;

  /// Id loại video trên máy chủ, chốt lúc bấm quay. Xem
  /// `EvidenceClipEntity.videoTypeId` — tên loại đổi được, id thì không.
  final String? videoTypeId;
  final String filePath;
  final DateTime createdAt;

  /// Shop the clip belongs to; needed by the real backend uploader. Older
  /// persisted tasks (and the offline path) may leave it null.
  final String? shopId;

  /// Tài khoản đã quay clip. Xem `EvidenceClipEntity.ownerUid`.
  final String? ownerUid;
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
    String? Function()? currentUid,
    @visibleForTesting Directory? directory,
    @visibleForTesting Directory? temporaryDirectory,
  }) : _currentUid = currentUid,
       _uploader = uploader,
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

  /// Hàng đợi CỦA TÀI KHOẢN ĐANG ĐĂNG NHẬP, mới nhất trước.
  ///
  /// Lọc theo người quay chứ không trả cả bảng: điện thoại dùng chung ca, A
  /// quay rồi đăng xuất, B đăng nhập — B mà thấy hàng chờ của A thì B tưởng đó
  /// là clip mình vừa quay, và con số trên chip ☁ nói dối về việc của chính B.
  ///
  /// Clip của A KHÔNG bị xoá, chỉ bị giấu: nó vẫn nằm trên đĩa và [_uploadableNow]
  /// vẫn chặn không cho tải nó lên dưới tài khoản B. A đăng nhập lại là thấy
  /// đủ và clip tự đi tiếp — bằng chứng chưa lên máy chủ thì không được biến
  /// mất vì một lượt đổi tài khoản.
  List<UploadTask> get tasks =>
      List.unmodifiable(_tasks.where(_belongsToCurrentUser));

  /// Hàng đợi CỦA MỘT SHOP.
  ///
  /// [tasks] lọc theo tài khoản, không theo shop — nên người có hai shop mở
  /// màn Hàng đợi ở shop A vẫn thấy clip vừa quay ở shop B, và con số trên
  /// icon hàng đợi cộng gộp cả hai. Người đóng gói đọc màn đó để biết "clip
  /// vừa quay lên chưa"; trộn shop khác vào là trả lời sai câu hỏi đó.
  List<UploadTask> tasksForShop(String? shopId) => shopId == null
      ? const []
      : List.unmodifiable(
          _tasks.where((t) => t.shopId == shopId && _belongsToCurrentUser(t)),
        );

  /// Số việc chưa xong của riêng [shopId] — con số trên icon hàng đợi.
  int pendingCountForShop(String? shopId) => tasksForShop(
    shopId,
  ).where((t) => t.state != EcUploadState.done).length;

  /// Xoá sạch hàng đợi CỦA MỘT SHOP, cùng ý nghĩa với [clearAll].
  ///
  /// Tách riêng vì màn Hàng đợi nay chỉ hiện việc của shop đang mở: nút "Xoá
  /// hết" ở đó mà quét cả hàng của shop khác thì nó xoá đúng những thứ người
  /// dùng không nhìn thấy và không hề định đụng tới.
  Future<void> clearShop(String? shopId) async {
    if (shopId == null) return;
    final mine = _tasks.where((t) => t.shopId == shopId).toList();
    if (mine.isEmpty) return;
    final ids = [for (final task in mine) task.id];
    final paths = [
      for (final task in mine)
        if (task.state != EcUploadState.done) absolutePathOf(task.filePath),
    ];
    _tasks.removeWhere((t) => t.shopId == shopId);
    notifyListeners();
    for (final id in ids) {
      await _store.remove(id);
    }
    for (final path in paths) {
      await _deleteLocalCopyQuietly(path);
    }
  }

  /// Tăng một sau mỗi clip lên máy chủ thành công.
  ///
  /// Màn hạn mức nghe cái này để hỏi lại `/api/quota`. Một `ValueNotifier`
  /// riêng chứ không phải `notifyListeners()` của cả hàng đợi: hàng đợi bắn
  /// tin ở mỗi phần trăm tiến độ, nghe nó là mỗi clip gọi mạng cả trăm lần.
  final ValueNotifier<int> uploadsCompleted = ValueNotifier<int>(0);

  @override
  void dispose() {
    uploadsCompleted.dispose();
    super.dispose();
  }

  /// Clip đã quay xong nhưng CHƯA nằm an toàn trên máy chủ — tức là những clip
  /// hiện chỉ tồn tại trên chính cái điện thoại này.
  ///
  /// Gồm cả `error` chứ không chỉ `quotaWait`: với người mất máy thì "kẹt vì
  /// hạn mức" và "kẹt vì lỗi mạng" mất mát y hệt nhau.
  Iterable<UploadTask> get strandedTasks => _tasks.where(
    (t) => t.state != EcUploadState.done && t.state != EcUploadState.uploading,
  );

  int get strandedCount => strandedTasks.length;

  /// Tổng dung lượng đang chiếm trên máy, byte. Đọc kích thước thật từ đĩa —
  /// đây là con số dùng để cảnh báo sắp đầy bộ nhớ, đoán thì vô nghĩa.
  int get strandedBytes {
    var total = 0;
    for (final task in strandedTasks) {
      try {
        total += File(absolutePathOf(task.filePath)).lengthSync();
      } on Object {
        // Tệp đã biến mất — không cộng gì, và [load] sẽ dọn hàng ở lần sau.
      }
    }
    return total;
  }

  /// Mốc quay của clip kẹt lâu nhất. Null khi không có clip nào kẹt.
  DateTime? get strandedOldestAt {
    DateTime? oldest;
    for (final task in strandedTasks) {
      if (oldest == null || task.createdAt.isBefore(oldest)) {
        oldest = task.createdAt;
      }
    }
    return oldest;
  }

  /// Loads the persisted queue from the store and resumes processing. Call
  /// once. Any failure leaves an empty in-memory queue rather than crashing.
  Future<void> load() async {
    try {
      final loaded = await _store.loadAll();
      // Đọc thư mục TRƯỚC khi lọc: [absolutePathOf] cần biết Documents nằm đâu,
      // và nếu không biết thì mọi đường dẫn tương đối đều "không tồn tại" —
      // tức là rụng sạch hàng đợi.
      await _evidenceDir();
      _tasks
        ..clear()
        // Drop entries whose clip file is gone — TRỪ hàng đã xong.
        //
        // Hàng đã xong là một cái biên nhận, không phải việc còn phải làm: clip
        // của nó nằm an toàn trên máy chủ và bản trên máy đã được xoá ngay sau
        // lượt tải lên. Lọc nó theo sự tồn tại của tệp thì mọi hàng đã xong đều
        // rụng ở lần mở app kế tiếp — đúng thứ danh sách này phải giữ lại.
        ..addAll(
          loaded.where(
            (t) =>
                t.state == EcUploadState.done ||
                File(absolutePathOf(t.filePath)).existsSync(),
          ),
        );
      // Có row trong kho nhưng KHÔNG row nào tìm thấy tệp = lỗi giải đường dẫn,
      // không phải hàng đợi rỗng. Ghi lại để [_sweepOrphans] không coi cả thư
      // mục là rác và xoá sạch bằng chứng vừa được khôi phục.
      // Chỉ đếm những hàng CẦN tệp. Hàng đã xong luôn được giữ lại dù tệp đã
      // xoá, nên tính cả chúng vào đây là cờ này không bao giờ bật nữa — và
      // [_sweepOrphans] sẽ coi cả thư mục bằng chứng là rác đúng lúc đường dẫn
      // hỏng, tức xoá sạch những clip chưa kịp lên.
      final needFile = loaded
          .where((t) => t.state != EcUploadState.done)
          .toList(growable: false);
      final lostEveryPath =
          needFile.isNotEmpty &&
          !_tasks.any((t) => t.state != EcUploadState.done);
      await _importLegacyJson();
      // Upload đứt giữa chừng, và clip bị đỗ vì hết hạn mức, đều được thử lại.
      //
      // `quotaWait` phải nằm ở đây: hạn mức mở lại khi chủ shop mua thêm lượt
      // hoặc sang tháng mới, và không có tín hiệu nào từ máy chủ báo cho máy
      // này biết. Mở app là dịp tự nhiên nhất để thử lại — thiếu nó thì clip
      // nằm chờ vĩnh viễn dù hạn mức đã thoáng từ lâu.
      for (final task in _tasks) {
        if (task.state == EcUploadState.uploading ||
            task.state == EcUploadState.quotaWait) {
          task
            ..state = EcUploadState.waiting
            ..progress = 0;
          await _store.save(task);
        }
      }
      _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // Strictly after the legacy import: `queue.json` lives in the evidence
      // dir, so sweeping first would delete the very file being migrated.
      await _sweepOrphans(skipEvidenceDir: lostEveryPath);
      // Bản xem tạm quá hạn. Thư mục riêng nên không dính vào hai cái hãm của
      // [_sweepOrphans] — ở đây không có bằng chứng nào để xoá nhầm, mọi tệp
      // đều đã nằm an toàn trên máy chủ trước khi được đưa vào.
      await ecSweepPreviews();
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
    String? videoTypeId,
    int? durationSeconds,
    String? samplesJson,
    DateTime? capturedAt,
    String? ownerUid,
  }) async {
    final dir = await _evidenceDir();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    // Lưu TÊN TỆP TRẦN — xem [absolutePathOf]. Đường dẫn tuyệt đối chết hàng
    // loạt khi iOS đổi UUID container lúc khôi phục máy.
    var stored = '$id${_ext(filePath)}';
    var copied = false;
    try {
      await File(filePath).copy('${dir.path}/$stored');
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
      // Xếp hàng xảy ra sau khi đã quay xong và remux xong — với clip 2 phút
      // trên máy tầm trung là lệch vài phút. Máy chủ lấy đúng mốc này làm gốc
      // cho dấu giờ nó nung lên khung hình, nên lấy nhầm giờ xếp hàng là cả
      // clip mang một mốc muộn hơn thực tế.
      createdAt: capturedAt ?? DateTime.now(),
      shopId: shopId,
      videoTypeId: videoTypeId,
      durationSeconds: durationSeconds,
      samplesJson: samplesJson,
      ownerUid: ownerUid,
    );
    _tasks.insert(0, task);
    // Đầy trần thì hàng mới vào, hàng đã xong cũ nhất ra.
    await _trimDoneHistory();
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
    unawaited(_deleteLocalCopyQuietly(absolutePathOf(task.filePath)));
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
  ///
  /// HAI CÁI HÃM, và cả hai đều để tránh đúng một thảm hoạ: dọn rác biến thành
  /// xoá sạch bằng chứng.
  ///
  /// - [skipEvidenceDir]: kho có row nhưng không row nào tìm thấy tệp. Đó là
  ///   lỗi giải đường dẫn, không phải rác — và những tệp "vô chủ" kia chính là
  ///   bằng chứng vừa được khôi phục.
  /// - `referenced.isEmpty`: một lượt dọn rác sắp xoá 100% thư mục thì đó là
  ///   tín hiệu có bug, không phải một lượt dọn dẹp. Chịu tốn vài MB rác còn
  ///   hơn xoá nhầm bản duy nhất của một clip bằng chứng.
  Future<void> _sweepOrphans({bool skipEvidenceDir = false}) async {
    final referenced = {
      for (final task in _tasks) absolutePathOf(task.filePath),
    };
    try {
      final dir = await _evidenceDir();
      final contents = dir.listSync().whereType<File>().toList();
      final wouldWipeAll =
          contents.isNotEmpty &&
          contents.every((f) => !referenced.contains(f.path));
      if (skipEvidenceDir || (referenced.isEmpty && wouldWipeAll)) {
        // Không xoá gì cả, nhưng phải kêu lên: im lặng bỏ qua thì lần regression
        // sau không ai biết đường dẫn đã hỏng.
        unawaited(
          _crashReporter?.recordError(
            StateError(
              'evidence_sweep_skipped: ${contents.length} tệp không có chủ, '
              'skipEvidenceDir=$skipEvidenceDir',
            ),
            StackTrace.current,
            reason: 'evidence_sweep_skipped',
          ),
        );
      } else {
        for (final entity in contents) {
          if (referenced.contains(entity.path)) continue;
          await _deleteLocalCopyQuietly(entity.path);
        }
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

  /// Chạy lại hàng đợi từ bên ngoài — dùng khi mạng trở lại.
  ///
  /// Hàng đợi không tự biết lúc nào có mạng: nó chỉ chạy khi mở app, khi có
  /// clip mới, hoặc khi người dùng bấm thử lại. Mất mạng một quãng dài rồi có
  /// lại mà người bán đã ngừng quay thì clip nằm im tới lần mở app sau. Bên
  /// nghe được sự kiện mạng gọi hàm này.
  ///
  /// Những task đang đỗ vì lỗi mạng nằm ở `error`, nên đưa chúng về `waiting`
  /// trước — nếu không thì lượt chạy này không thấy gì để làm.
  Future<void> kick() async {
    var revived = false;
    for (final task in _tasks) {
      if (task.state == EcUploadState.error) {
        task
          ..state = EcUploadState.waiting
          ..progress = 0
          ..errorMessage = null;
        await _store.save(task);
        revived = true;
      }
    }
    if (revived) notifyListeners();
    await _process();
  }

  Future<void> _process() async {
    if (_processing || _uploader == null) return;
    _processing = true;
    var hitQuotaWall = false;
    try {
      while (true) {
        if (hitQuotaWall) break;
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
            File(absolutePathOf(task.filePath)),
            tracking: task.tracking,
            type: task.type,
            shopId: task.shopId,
            videoTypeId: task.videoTypeId,
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
          // Máy chủ vừa ghi nhận thêm một video vào hạn mức tháng này. Đây là
          // tín hiệu DUY NHẤT app có để biết con số quota trên màn đã cũ —
          // không có nó thì màn hạn mức đứng im suốt phiên và người dùng thấy
          // "quay rồi mà không trừ".
          uploadsCompleted.value++;
          unawaited(_analytics?.trackUploadCompleted());
          // KHÔNG xoá ngay nữa: máy chủ giấu link phát suốt lúc còn đóng dấu,
          // nên đúng khoảnh khắc này là lúc bản trên máy có giá trị NHẤT — nó
          // là thứ duy nhất người bán xem lại được. Dời sang kho bản xem tạm,
          // ở đó có trần tuổi và bị dọn ngay khi máy chủ phát được.
          //
          // Vẫn giữ nguyên tinh thần cũ (FR-09: hết chỗ là chặn cả việc quay) —
          // chỉ đổi từ "xoá ngay" thành "xoá khi không cần nữa".
          //
          // PHẢI `await`: ngay dưới đây, nhánh `succeeded` gọi
          // `_deleteLocalCopyQuietly` trên đúng đường dẫn này. Thả nổi lượt dời
          // là mở ra cửa sổ mà lượt xoá chạy trước lượt dời — và thứ bị xoá là
          // bản duy nhất người bán xem lại được.
          await ecKeepPreview(
            url,
            absolutePathOf(task.filePath),
            tracking: task.tracking,
          );
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
            // Cả hàng đợi cùng chung một hạn mức: clip này bị từ chối thì clip
            // kế tiếp cũng thế. Dừng lượt quét ở đây thay vì nã 300 request
            // chắc chắn trả 403 — vừa đốt pin và data của người đóng gói, vừa
            // làm log máy chủ ngập.
            hitQuotaWall = true;
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
          // Hàng "đã xong" Ở LẠI danh sách cho tới khi NGƯỜI DÙNG xoá nó.
          //
          // Clip đã lên tới hồ sơ của đơn (Vận đơn) rồi, nên xét về việc thì
          // nó xong. Nhưng người đang đóng gói cần thấy mình đã quay được bao
          // nhiêu clip — mà danh sách tự rỗng đi sau mỗi lượt lọt thì trông y
          // như vừa bị xoá sạch, và họ quay lại lần nữa cho chắc.
          //
          // Ghi xuống kho lưu chứ không xoá khỏi đó: danh sách phải còn nguyên
          // sau khi tắt app. Chỉ dấu × của từng hàng, nút Xoá hết, hoặc trần
          // [queueDisplayLimit] mới lấy nó đi.
          await _store.save(task);
          await _trimDoneHistory();
          // Lưới đỡ: tệp đã được dời sang kho bản xem tạm ở trên nên đây thường
          // là no-op. Chỉ ăn thua khi lượt dời hỏng và tệp còn nằm lại.
          unawaited(_deleteLocalCopyQuietly(absolutePathOf(task.filePath)));
          // Một lượt upload lọt nghĩa là hạn mức VỪA chứng minh còn chỗ (chủ
          // shop mua thêm lượt, hoặc sang tháng). Thả những bản đang đỗ vào
          // lại vòng quay ngay — không thì chúng nằm chờ tới lần mở app sau,
          // trong khi chính máy này vừa upload được.
          await _releaseQuotaWaiting();
        } else {
          await _store.save(task);
        }
        notifyListeners();
      }
    } finally {
      _processing = false;
    }
  }

  /// Ai đang đăng nhập; `null` = không biết, khi đó không chặn gì.
  final String? Function()? _currentUid;

  /// Clip này có được tải lên dưới tài khoản đang đăng nhập không.
  ///
  /// Điện thoại dùng chung ca: A quay rồi đăng xuất, B đăng nhập. `created_by_uid`
  /// lấy từ token lúc presign chứ không phải từ người đã quay, nên nếu cứ tải
  /// thì clip của A lên hệ thống mang tên B — hoặc hỏng 404 khi B không thuộc
  /// shop đó. Cả hai đều phá chuỗi bằng chứng.
  ///
  /// Không khớp thì GIỮ NGUYÊN ở trạng thái chờ, không xoá và không báo lỗi:
  /// A đăng nhập lại là clip tự đi tiếp.
  bool _uploadableNow(UploadTask task) => _belongsToCurrentUser(task);

  /// Clip này có thuộc về tài khoản đang đăng nhập không.
  ///
  /// `null` ở một trong hai đầu = không biết → coi là CÓ: hàng lưu trước khi
  /// có trường `ownerUid`, và lúc app chưa đọc xong phiên đăng nhập. Đoán sai
  /// theo hướng giấu clip đi thì người bán tưởng bằng chứng của mình mất.
  bool _belongsToCurrentUser(UploadTask task) {
    final owner = task.ownerUid;
    if (owner == null) return true;
    final current = _currentUid?.call();
    if (current == null) return true;
    return owner == current;
  }

  /// Số hàng còn VIỆC PHẢI LÀM — không tính những hàng đã xong.
  ///
  /// Con số trên chip ☁ ở màn quay là "còn bao nhiêu clip chưa lên", nên phải
  /// đọc cái này chứ không đọc `tasks.length`: lịch sử đã xong nằm chung danh
  /// sách sẽ làm chip đếm cả những thứ không còn phải chờ.
  int get pendingCount => _tasks
      .where((t) => t.state != EcUploadState.done && _belongsToCurrentUser(t))
      .length;

  /// Trần số hàng giữ trong danh sách. Đầy thì hàng mới vào, hàng CŨ NHẤT ra.
  ///
  /// Một ca đóng hàng dài có thể qua vài trăm clip; giữ hết thì danh sách dài
  /// vô ích và mỗi lượt dựng lại nặng dần.
  static const queueDisplayLimit = 50;

  /// Cắt bớt danh sách về [queueDisplayLimit], bỏ những hàng ĐÃ XONG cũ nhất.
  ///
  /// Chỉ đụng tới hàng đã xong: hàng còn chờ, đang lên, lỗi hay đỗ vì hạn mức
  /// đều là việc chưa làm xong, và clip của chúng mới chỉ nằm trên máy này —
  /// đẩy chúng ra khỏi danh sách là người dùng mất dấu bằng chứng chưa được
  /// bảo vệ. Nếu 50 hàng đều là việc dở dang thì danh sách cứ dài hơn 50, và
  /// đó là điều đúng.
  Future<void> _trimDoneHistory() async {
    if (_tasks.length <= queueDisplayLimit) return;
    final done = _tasks
        .where((t) => t.state == EcUploadState.done)
        .toList(growable: false);
    var over = _tasks.length - queueDisplayLimit;
    // Duyệt NGƯỢC: `enqueue` chèn vào đầu danh sách nên đầu là hàng mới nhất,
    // và hàng cũ nhất nằm ở cuối. Duyệt xuôi là bỏ đúng những hàng vừa xong.
    for (final task in done.reversed) {
      if (over <= 0) break;
      _tasks.remove(task);
      // Xoá cả ở kho lưu, nếu không thì lần mở app sau nó sống lại và trần 50
      // chẳng còn nghĩa gì.
      await _store.remove(task.id);
      over -= 1;
    }
  }

  /// Xoá SẠCH hàng đợi — cả việc dở dang lẫn lịch sử đã xong.
  ///
  /// Kéo theo cả tệp trên máy của những clip chưa lên: để lại là rác chiếm chỗ
  /// mà không còn hàng nào trỏ tới. Bên gọi phải hỏi lại người dùng trước —
  /// clip chưa lên chỉ tồn tại trên chính máy này.
  Future<void> clearAll() async {
    final ids = [for (final task in _tasks) task.id];
    final paths = [
      for (final task in _tasks)
        if (task.state != EcUploadState.done) absolutePathOf(task.filePath),
    ];
    _tasks.clear();
    notifyListeners();
    for (final id in ids) {
      await _store.remove(id);
    }
    for (final path in paths) {
      await _deleteLocalCopyQuietly(path);
    }
  }

  /// Thả mọi clip đang đỗ vì hạn mức trở lại hàng chờ.
  ///
  /// Không gọi [_process] ở đây: hàm này chạy TRONG vòng lặp của [_process],
  /// và vòng lặp đó sẽ nhặt luôn những bản vừa được thả ở lượt kế tiếp.
  Future<int> _releaseQuotaWaiting() async {
    var released = 0;
    for (final task in _tasks) {
      if (task.state != EcUploadState.quotaWait) continue;
      task
        ..state = EcUploadState.waiting
        ..progress = 0
        ..errorMessage = null;
      await _store.save(task);
      released++;
    }
    if (released > 0) notifyListeners();
    return released;
  }

  /// Thử lại toàn bộ clip đang đỗ vì hạn mức. Dành cho tầng ngoài gọi khi có
  /// lý do tin rằng hạn mức đã mở lại — app quay lại foreground, hoặc màn Gói
  /// cước vừa đọc được `blocked = false`.
  ///
  /// Rẻ và an toàn khi gọi thừa: không có bản nào đỗ thì đây là no-op.
  Future<void> retryQuotaWaiting() async {
    if (await _releaseQuotaWaiting() == 0) return;
    unawaited(_process());
  }

  UploadTask? _firstWaiting() {
    for (final task in _tasks) {
      if (task.state == EcUploadState.waiting && _uploadableNow(task)) {
        return task;
      }
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

  /// Đường dẫn tuyệt đối thật sự của một clip.
  ///
  /// `task.filePath` lưu TÊN TỆP TRẦN, tương đối so với thư mục bằng chứng.
  /// Lưu đường dẫn tuyệt đối là một lỗi mất dữ liệu trên iOS: mã UUID của
  /// container đổi mỗi lần khôi phục từ sao lưu hoặc chuyển sang máy mới, nên
  /// mọi đường dẫn đã lưu chết cùng một lúc — trong khi chính các tệp thì vẫn
  /// được khôi phục nguyên vẹn. Trước đây hậu quả là `load()` rụng sạch hàng
  /// đợi rồi `_sweepOrphans()` xoá luôn những tệp vừa khôi phục.
  ///
  /// Neo theo THƯ MỤC BẰNG CHỨNG chứ không theo Documents: thư mục đó có thể
  /// được truyền vào (test, và bất kỳ ai gọi `EcUploadQueue(directory: …)`),
  /// nên "documents + /evidence/" là một giả định sai.
  ///
  /// Vẫn nhận giá trị tuyệt đối cũ. Nếu tệp còn ở đúng chỗ thì dùng luôn; nếu
  /// không thì dựng lại theo tên tệp trong thư mục bằng chứng hiện tại — đúng
  /// trường hợp iOS khôi phục máy.
  String absolutePathOf(String stored) {
    if (stored.isEmpty) return stored;
    final dir = _dir;
    if (!stored.contains('/')) {
      return dir == null ? stored : '${dir.path}/$stored';
    }
    if (File(stored).existsSync()) return stored;
    if (dir == null) return stored;
    final rebuilt = '${dir.path}/${stored.split('/').last}';
    return File(rebuilt).existsSync() ? rebuilt : stored;
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

/// Máy chủ từ chối vì hết hạn mức, chứ không phải một lỗi upload thường.
///
/// Ưu tiên KIỂU dữ liệu ([EcQuotaExceededException]). Nhánh so chuỗi phía dưới
/// chỉ còn để đỡ hai đường cũ: `StateError('quota_exceeded')` mà uploader ném
/// khi backend trả `quota_hold`, và bản app cũ chưa có kiểu này.
bool _isQuotaWait(Object error) {
  if (error is EcQuotaExceededException) return true;
  final text = error.toString().toLowerCase();
  return text.contains('quota_exceeded') ||
      text.contains('quota exceeded') ||
      text.contains('quota limit') ||
      text.contains('monthly quota');
}

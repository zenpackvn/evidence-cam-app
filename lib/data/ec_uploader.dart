import 'dart:io';

// Prefixed: this package and feature_capture both export an `UploadTask` —
// there, the queued-clip domain record; here, one HTTP transfer.
import 'package:background_downloader/background_downloader.dart' as bg;
import 'package:crypto/crypto.dart' show sha256;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ec_data/ec_data.dart';
import 'package:feature_capture/feature_capture.dart';
// `get_thumbnail_video` is the maintained fork of the abandoned
// `video_thumbnail` (same library name and API); the original's Gradle script
// still calls the removed `jcenter()` and cannot configure under Gradle 9.
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
// The R2 leg no longer goes through Dio (see [_backgroundPut]), but the
// `_api` calls around it still do, so their failures still arrive as
// [DioException]s that [_friendlyMessage] has to translate.
import 'package:network/network.dart' show DioException, DioExceptionType;

/// Escape hatch from the quota rollout: when true, a `quota_hold` response is
/// treated as success and the app never tells the seller their evidence is
/// over-quota. The clip is still fully uploaded to R2 either way — this only
/// skips the *reporting* — but a hold the seller never sees is a hold nobody
/// acts on, and the evidence sits uncounted until retention deletes it.
///
/// Back to `false` now that the backend releases holds again (quota.ts
/// `releaseHeldEvidence`): a held clip is picked up automatically once the plan
/// is upgraded or retention frees room, so the "chờ quota" state the queue
/// shows is temporary and actionable rather than a dead end.
const _ignoreQuotaHoldForTesting = false;

/// How long to wait for the backend to finalize an upload (`complete` /
/// `multipart/complete`) — this runs after every byte is already on R2, so it
/// has to assemble the object and write the evidence row, which can
/// legitimately take longer than the app's normal API timeout
/// (`API_TIMEOUT_SECONDS`, 10s in dev). Giving just these two calls a longer
/// budget avoids the client giving up on a request the backend is still
/// about to succeed on.
const _completeUploadTimeout = Duration(seconds: 45);

/// A network/server failure with a message already safe to show a seller —
/// [ApiEvidenceUploader.upload] rewraps every [DioException] into one of
/// these so the upload queue has something better than "Lỗi" to display.
/// Deliberately NOT thrown for the `StateError`s below (`quota_exceeded`,
/// `missing_part_etag`) — those are internal signals other code matches on
/// by their exact text, not user-facing failures.
class UploadFailureException implements Exception {
  const UploadFailureException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Máy chủ từ chối cấp chỗ upload vì shop vượt hạn mức video (backend:
/// `assertUploadAllowed` → 403 `video_quota_exceeded`).
///
/// Khớp theo MÃ LỖI trong body, không theo mã HTTP: 403 còn được dùng cho
/// `forbidden`, `owner_only`, `byos_not_in_plan` — đỗ clip lại vì một trong số
/// đó là giấu một lỗi phân quyền thật dưới nhãn "chờ hạn mức".
bool _isQuotaRefusal(DioException error) {
  if (error.response?.statusCode != 403) return false;
  final body = error.response?.data;
  final code = body is Map ? body['error'] : null;
  return code == 'video_quota_exceeded';
}

String _friendlyMessage(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Máy chủ phản hồi quá lâu, chưa rõ video đã lưu hay chưa — thử lại giúp kiểm tra.';
    case DioExceptionType.connectionError:
      return 'Mất kết nối mạng khi tải lên — kiểm tra mạng rồi thử lại.';
    case DioExceptionType.badResponse:
      final status = error.response?.statusCode;
      return 'Máy chủ báo lỗi${status != null ? ' (mã $status)' : ''} — thử lại sau.';
    case DioExceptionType.cancel:
      return 'Đã huỷ tải lên.';
    case DioExceptionType.badCertificate:
      return 'Lỗi chứng chỉ bảo mật kết nối — thử lại sau.';
    case DioExceptionType.unknown:
      return 'Lỗi kết nối không xác định — thử lại sau.';
  }
}

/// Same job as [_friendlyMessage] for the R2 leg, which no longer speaks Dio:
/// a status the server actually returned is worth naming, a dropped transfer
/// isn't.
String _friendlyPutMessage(R2PutException error) {
  final status = error.statusCode;
  if (status == null) {
    return 'Mất kết nối mạng khi tải lên — kiểm tra mạng rồi thử lại.';
  }
  return 'Máy chủ báo lỗi (mã $status) khi nhận video — thử lại sau.';
}

/// A byte slice of a clip, end-inclusive to match the HTTP `Range` header.
typedef R2ByteRange = ({int start, int endInclusive});

/// Extracts a poster frame from [videoPath], returning the JPEG's path or null
/// when no frame could be read. A seam so the upload path stays testable.
typedef ThumbnailExtractor = Future<String?> Function(String videoPath);

/// SHA-256 of [file] as lowercase hex — the evidence's fingerprint, recorded
/// with the row at upload time so anyone can later re-hash the stored object
/// and prove it is byte-for-byte what the phone sent.
///
/// Streams the file through the digest rather than reading it into memory: an
/// evidence clip can be hundreds of MB and this runs on a packing-station
/// phone. Returns null on any read error — a missing fingerprint must never
/// cost the upload.
///
/// Note this hashes the file **as uploaded**, i.e. after the faststart remux.
/// That is the artifact the fingerprint is supposed to anchor.
Future<String?> _fileSha256(File file) async {
  try {
    return (await sha256.bind(file.openRead()).first).toString();
  } on Object {
    return null;
  }
}

/// Longest edge of the generated poster, in pixels.
///
/// A timeline row renders it well under 200px wide, so 320 survives a 2x screen
/// with room to spare while keeping the file in the tens-of-KB range — the
/// whole point is that a list costs a rounding error instead of video bytes.
const _thumbnailMaxWidth = 320;

/// JPEG quality for the poster. 60 is visibly fine at thumbnail size and about
/// half the bytes of the default.
const _thumbnailQuality = 60;

/// Default [ThumbnailExtractor], backed by the platform's own frame reader
/// (Android `MediaMetadataRetriever` / iOS `AVAssetImageGenerator`).
///
/// Deliberately not ffmpeg: the bundled ffmpeg is the `base` build, which
/// carries no JPEG encoder, and pulling in the full build to encode one small
/// image would cost more app size than this plugin does.
Future<String?> _platformThumbnail(String videoPath) async {
  final thumbnail = await VideoThumbnail.thumbnailFile(
    video: videoPath,
    imageFormat: ImageFormat.JPEG,
    maxWidth: _thumbnailMaxWidth,
    quality: _thumbnailQuality,
  );
  return thumbnail.path;
}

/// One PUT of a clip (or one [R2ByteRange] of it) to a presigned R2 URL,
/// returning the response's `ETag` — multipart completion needs it.
///
/// A seam so tests can drive the R2 leg without a platform channel, and so the
/// transport can be swapped without touching the multipart session logic.
typedef R2Put =
    Future<String?> Function(
      String url,
      File file, {
      required String contentType,
      R2ByteRange? range,
      void Function(double progress)? onProgress,
    });

/// A failed presigned-R2 PUT.
///
/// [statusCode] is the server's HTTP status, or null when the request never got
/// a response at all (dropped connection, timeout) — the distinction
/// [_isRetryablePut] needs to tell a transient blip from a doomed request.
class R2PutException implements Exception {
  R2PutException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'R2PutException($statusCode): $message';
}

/// Uploads through `background_downloader`, so the bytes move on a native
/// `URLSession` / `WorkManager` task that keeps running while the app is
/// backgrounded — a plain foreground HTTP client stalls there instead.
Future<String?> _backgroundPut(
  String url,
  File file, {
  required String contentType,
  R2ByteRange? range,
  void Function(double progress)? onProgress,
}) async {
  final task = bg.UploadTask.fromFile(
    file: file,
    url: url,
    httpRequestMethod: 'PUT',
    post: 'binary',
    mimeType: contentType,
    headers: {
      // Client-side slicing instruction only: every platform strips `Range`
      // from an upload before sending, and reads just those bytes off disk.
      if (range != null) 'Range': 'bytes=${range.start}-${range.endInclusive}',
      // Empty string suppresses the header the plugin would otherwise invent;
      // a presigned URL signs a fixed header set, so don't send extras.
      'Content-Disposition': '',
    },
    updates: bg.Updates.statusAndProgress,
    // Retry classification stays app-side (see [_isRetryablePut]): this package
    // retries every failure alike, which would burn all four attempts on an
    // expired presigned URL that can never succeed.
    retries: 0,
  );
  final result = await bg.FileDownloader().upload(task, onProgress: onProgress);
  if (result.status != bg.TaskStatus.complete) {
    throw R2PutException(
      result.exception?.description ?? 'upload ${result.status.name}',
      statusCode: result.responseStatusCode,
    );
  }
  return result.responseHeaders?['etag'];
}

/// Real backend uploader following the EvidenceCam presigned-R2 flow:
///
/// 1. `findOrCreateOrder(shopId, tracking)` → the order id;
/// 2. `presignUpload(...)` → a one-time R2 `uploadUrl` + `evidenceId`;
/// 3. `PUT` the clip bytes straight to R2 (no auth header — the presigned URL
///    carries its own signature);
/// 4. `completeUpload(...)` to mark the evidence stored.
class ApiEvidenceUploader implements EcEvidenceUploader {
  ApiEvidenceUploader(
    this._api, {
    R2Put? put,
    ThumbnailExtractor? extractThumbnail,
    this.multipartThresholdBytes = 8 * 1024 * 1024,
    this.multipartPartSizeBytes = 5 * 1024 * 1024,
  }) : _put = put ?? _backgroundPut,
       _extractThumbnail = extractThumbnail ?? _platformThumbnail;

  final EcApi _api;
  final R2Put _put;
  final ThumbnailExtractor _extractThumbnail;
  final int multipartThresholdBytes;
  final int multipartPartSizeBytes;

  /// Cached after the first read — the physical device doesn't change
  /// mid-session, so there's no reason to hit the platform channel again
  /// for every clip.
  String? _deviceLabel;
  bool _deviceLabelRead = false;

  /// The recording phone's make/model (e.g. "samsung SM-M146B"), sent up with
  /// every upload so the evidence detail screen can show which device
  /// recorded a clip instead of "Không rõ thiết bị" — previously nothing
  /// populated this at all. Best-effort: a failure here shouldn't fail the
  /// upload itself.
  Future<String?> _readDeviceLabel() async {
    if (_deviceLabelRead) return _deviceLabel;
    _deviceLabelRead = true;
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        _deviceLabel = '${android.manufacturer} ${android.model}'.trim();
      } else if (Platform.isIOS) {
        final ios = await info.iosInfo;
        _deviceLabel = ios.modelName;
      }
    } on Object {
      _deviceLabel = null;
    }
    return _deviceLabel;
  }

  @override
  Future<String> upload(
    File file, {
    required String tracking,
    required String type,
    String? shopId,
    String? videoTypeId,
    int? capturedAt,
    int? durationSeconds,
    String? samplesJson,
    void Function(double progress)? onProgress,
  }) async {
    try {
      return await _uploadInner(
        file,
        tracking: tracking,
        type: type,
        shopId: shopId,
        videoTypeId: videoTypeId,
        capturedAt: capturedAt,
        durationSeconds: durationSeconds,
        samplesJson: samplesJson,
        onProgress: onProgress,
      );
    } on DioException catch (e, stack) {
      // Hết hạn mức KHÔNG phải một lỗi upload bình thường: thử lại ngay không
      // bao giờ ăn thua, và người dùng cần đọc đúng lý do chứ không phải "máy
      // chủ báo lỗi (mã 403)". Nhận diện trước khi bọc thành lỗi chung.
      if (_isQuotaRefusal(e)) {
        Error.throwWithStackTrace(
          const EcQuotaExceededException('video_quota_exceeded'),
          stack,
        );
      }
      Error.throwWithStackTrace(
        UploadFailureException(_friendlyMessage(e)),
        stack,
      );
    } on R2PutException catch (e, stack) {
      Error.throwWithStackTrace(
        UploadFailureException(_friendlyPutMessage(e)),
        stack,
      );
    }
  }

  Future<String> _uploadInner(
    File file, {
    required String tracking,
    required String type,
    String? shopId,
    String? videoTypeId,
    int? capturedAt,
    int? durationSeconds,
    String? samplesJson,
    void Function(double progress)? onProgress,
  }) async {
    if (shopId == null || shopId.isEmpty) {
      throw StateError('ApiEvidenceUploader.upload requires a shopId');
    }
    final captureTime = capturedAt ?? DateTime.now().millisecondsSinceEpoch;
    final order = await _api.findOrCreateOrder(
      shopId,
      tracking,
      capturedAt: captureTime,
    );
    final isPhoto = _isPhotoEvidence(file, type);
    final resolvedTypeId = isPhoto
        ? null
        : videoTypeId ?? await _videoTypeIdByName(shopId, type);
    final clipDuration = isPhoto ? null : durationSeconds;
    // Băm một lần ở đây thay vì lại ở bước complete: gửi kèm ngay từ presign
    // thì vân tay và bộ mẫu thiết bị bị chốt trong CÙNG một request, trước khi
    // byte nào tới server — khai mẫu đẹp rồi upload byte khác là hỏng checksum.
    // Tiện thể bỏ được một lượt đọc hết file.
    final fingerprint = await _fileSha256(file);
    final length = await file.length();
    if (length > multipartThresholdBytes) {
      return _uploadMultipart(
        file,
        shopId: shopId,
        orderId: order.id,
        kind: isPhoto ? 'photo' : 'video',
        capturedAt: captureTime,
        videoTypeId: resolvedTypeId,
        durationSeconds: clipDuration,
        samplesJson: samplesJson,
        sha256: fingerprint,
        length: length,
        isPhoto: isPhoto,
        onProgress: onProgress,
      );
    }

    final presign = await _api.presignUpload(
      shopId,
      order.id,
      kind: isPhoto ? 'photo' : 'video',
      capturedAt: captureTime,
      videoTypeId: resolvedTypeId,
      device: await _readDeviceLabel(),
      durationSeconds: clipDuration,
      samplesJson: samplesJson,
      sha256: fingerprint,
    );
    // presignUpload already created this evidence row server-side (needed to
    // hand back an evidenceId + presigned URL) — if the PUT itself fails, the
    // row is now a permanent orphan (a retry starts over via a fresh presign,
    // never revisiting this evidenceId), left forever at status 'error' and
    // counted in the order's error/evidence totals with nothing in the app
    // pointing back at it. Deleting it here is safe because nothing has been
    // marked done yet; scoped to just the PUT so a completeUpload failure
    // (which may have actually succeeded server-side) is never touched.
    // Poster first: it is tens of KB against a clip's tens of MB, so sending it
    // up front means the order's timeline can show this evidence within a
    // second of recording, while the video itself is still climbing.
    await _uploadThumbnailQuietly(
      file,
      presign.thumbUploadUrl,
      isPhoto: isPhoto,
    );
    try {
      await _putWithRetry(
        () => _put(
          presign.uploadUrl,
          file,
          contentType: _contentTypeFor(file, isPhoto: isPhoto),
          onProgress: onProgress,
        ),
      );
    } on Object {
      await _deleteEvidenceQuietly(shopId, order.id, presign.evidenceId);
      rethrow;
    }
    final status = await _api.completeUpload(
      shopId,
      order.id,
      presign.evidenceId,
      receiveTimeout: _completeUploadTimeout,
      sha256: fingerprint,
    );
    if (status == 'quota_hold' && !_ignoreQuotaHoldForTesting) {
      throw StateError('quota_exceeded');
    }
    return presign.key;
  }

  Future<String> _uploadMultipart(
    File file, {
    required String shopId,
    required String orderId,
    required String kind,
    required int capturedAt,
    required int length,
    required bool isPhoto,
    String? videoTypeId,
    int? durationSeconds,
    String? samplesJson,
    String? sha256,
    void Function(double progress)? onProgress,
  }) async {
    final partSize = multipartPartSizeBytes;
    final partCount = (length / partSize).ceil();
    final created = await _api.createMultipartUpload(
      shopId,
      orderId,
      kind: kind,
      capturedAt: capturedAt,
      videoTypeId: videoTypeId,
      device: await _readDeviceLabel(),
      durationSeconds: durationSeconds,
      samplesJson: samplesJson,
      sha256: sha256,
    );
    await _uploadThumbnailQuietly(
      file,
      created.thumbUploadUrl,
      isPhoto: isPhoto,
    );
    // Aborting deletes the multipart upload on R2 — only safe while nothing
    // has been "completed" yet. Once completeMultipartUpload has actually
    // been sent, the bytes may already be fully assembled server-side even
    // if the client never saw the response (e.g. it timed out waiting); this
    // is scoped so a failure there propagates without aborting a possibly
    // already-succeeded upload out from under itself.
    final uploaded = <UploadedPartDto>[];
    try {
      // Bytes from parts that have *fully* succeeded — the base every
      // in-flight part's progress is added to. Kept separate from the
      // current part's own sent-bytes so a retried part (fresh stream,
      // sent count restarts at 0) can't double-count or go backwards.
      var completedBytes = 0;
      for (var partNumber = 1; partNumber <= partCount; partNumber++) {
        final start = (partNumber - 1) * partSize;
        final end = start + partSize > length ? length : start + partSize;
        final partLength = end - start;
        final partBase = completedBytes;
        // Signed right before this part is sent, not for the whole file
        // upfront: a large clip on a slow connection can take longer to
        // upload than a presigned URL's TTL, and a URL signed minutes
        // before its part is actually PUT would arrive expired (a
        // non-retryable 403). Signing one part at a time keeps every URL's
        // age at "one part's transfer + retries", regardless of how long
        // earlier parts took.
        final partUrl = await _api.presignMultipartParts(
          shopId,
          orderId,
          created.evidenceId,
          uploadId: created.uploadId,
          partNumbers: [partNumber],
        );
        final etag = await _putWithRetry(
          () => _put(
            partUrl.single.uploadUrl,
            file,
            contentType: _contentTypeFor(file, isPhoto: isPhoto),
            range: (start: start, endInclusive: end - 1),
            onProgress: (fraction) =>
                onProgress?.call((partBase + fraction * partLength) / length),
          ),
        );
        completedBytes += partLength;
        if (etag == null || etag.isEmpty) throw StateError('missing_part_etag');
        // R2's raw HTTP response quotes the ETag per the S3/HTTP convention
        // (e.g. `"9bb58f26..."`), but the Workers R2 binding's own
        // `complete()` call expects the bare hash it would have gotten back
        // from its own uploadPart() — passing the quoted form through
        // verbatim makes R2 reject the completion, which the backend was
        // surfacing as an unconditional 500 on every single attempt.
        uploaded.add(
          UploadedPartDto(
            partNumber: partNumber,
            etag: etag.replaceAll('"', ''),
          ),
        );
      }
    } on Object {
      await _api.abortMultipartUpload(
        shopId,
        orderId,
        created.evidenceId,
        uploadId: created.uploadId,
      );
      await _deleteEvidenceQuietly(shopId, orderId, created.evidenceId);
      rethrow;
    }
    final status = await _api.completeMultipartUpload(
      shopId,
      orderId,
      created.evidenceId,
      uploadId: created.uploadId,
      parts: uploaded,
      receiveTimeout: _completeUploadTimeout,
      sha256: sha256,
    );
    if (status == 'quota_hold' && !_ignoreQuotaHoldForTesting) {
      throw StateError('quota_exceeded');
    }
    return created.key;
  }

  /// Extracts a poster frame from [file] and PUTs it to [thumbUploadUrl].
  ///
  /// Swallows every failure by design: a clip with no poster still shows in the
  /// timeline behind a generic icon, whereas failing the upload over a
  /// decorative image would lose evidence. `completeUpload` server-side checks
  /// whether the object actually landed and clears the key if it didn't, so a
  /// silent failure here can never produce a broken image.
  ///
  /// No-op for photos and against a backend that doesn't hand back a URL.
  Future<void> _uploadThumbnailQuietly(
    File file,
    String? thumbUploadUrl, {
    required bool isPhoto,
  }) async {
    if (isPhoto || thumbUploadUrl == null) return;
    String? thumbPath;
    try {
      thumbPath = await _extractThumbnail(file.path);
      if (thumbPath == null) return;
      await _put(thumbUploadUrl, File(thumbPath), contentType: 'image/jpeg');
    } on Object {
      // Poster is decoration; the clip is the evidence.
    } finally {
      if (thumbPath != null) {
        try {
          await File(thumbPath).delete();
        } on Object {
          // Temp file the OS will reap anyway.
        }
      }
    }
  }

  /// Best-effort cleanup of an evidence row that never finished uploading —
  /// only ever called for a failure known *not* to have reached the
  /// complete/multipart-complete call, so there's nothing real to lose.
  /// Swallows its own failure: the original upload error is what the queue
  /// needs to see, not a secondary cleanup problem.
  Future<void> _deleteEvidenceQuietly(
    String shopId,
    String orderId,
    String evidenceId,
  ) async {
    try {
      await _api.deleteEvidence(shopId, orderId, evidenceId);
    } on Object {
      // Leaves one orphaned row behind — better than masking the real error.
    }
  }

  /// Lưới đỡ cho clip xếp hàng TRƯỚC khi task mang theo `videoTypeId`.
  ///
  /// Tra theo tên là cách hỏng đã biết: clip nằm hàng chờ hàng giờ, quản lý đổi
  /// tên hoặc xoá loại trong lúc đó là lượt tra trượt, clip lên hệ thống không
  /// có loại và rơi khỏi bộ lọc theo loại vĩnh viễn, không báo gì. Đường chính
  /// giờ là id chốt lúc bấm quay; hàm này chỉ còn phục vụ những clip cũ đã nằm
  /// sẵn trong hàng đợi lúc bản này cài đè lên.
  Future<String?> _videoTypeIdByName(String shopId, String type) async {
    final key = _normalizeName(type);
    if (key.isEmpty) return null;
    try {
      final types = await _api.listVideoTypes(shopId);
      for (final t in types) {
        if (_normalizeName(t.name) == key) return t.id;
      }
    } on Object {
      // Preserve evidence upload even if type metadata cannot be fetched.
    }
    return null;
  }
}

/// Retries a single R2 PUT (whole file or one multipart part) on transient
/// network/server failures.
///
/// Retrying stays here rather than being delegated to the transport because
/// `background_downloader` retries every failure alike, which would burn all
/// four attempts on an expired presigned URL that can never succeed.
Future<String?> _putWithRetry(Future<String?> Function() attempt) async {
  const maxAttempts = 4;
  for (var attemptNumber = 1; ; attemptNumber++) {
    try {
      return await attempt();
    } on R2PutException catch (e) {
      if (attemptNumber >= maxAttempts || !_isRetryablePut(e)) rethrow;
      await Future<void>.delayed(_backoffFor(attemptNumber));
    }
  }
}

/// A dropped connection (no status at all) is worth another go; a rejection the
/// server actually spelled out is only retried when it invites one — 429 or a
/// 5xx. Notably *not* 403, the expired-signature case, where an identical retry
/// can never succeed.
bool _isRetryablePut(R2PutException e) {
  final status = e.statusCode;
  if (status == null) return true;
  return status == 429 || status >= 500;
}

/// Exponential backoff (300ms, 600ms, 1200ms, ...), matching the app's main
/// `RetryInterceptor` without the jitter — a single client retrying its own
/// PUT doesn't need jitter to avoid a thundering herd.
Duration _backoffFor(int attemptNumber) =>
    Duration(milliseconds: 300 * (1 << (attemptNumber - 1)));

String _normalizeName(String raw) =>
    raw.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

bool _isPhotoEvidence(File file, String type) {
  final label = _normalizeName(type);
  if (label == _normalizeName('Ảnh đính kèm')) return true;
  final path = file.path.toLowerCase();
  return path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.png') ||
      path.endsWith('.heic') ||
      path.endsWith('.webp');
}

String _contentTypeFor(File file, {required bool isPhoto}) {
  if (!isPhoto) return 'video/mp4';
  final path = file.path.toLowerCase();
  if (path.endsWith('.png')) return 'image/png';
  if (path.endsWith('.heic')) return 'image/heic';
  if (path.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ec_data/ec_data.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:network/network.dart'
    show
        BaseOptions,
        Dio,
        DioException,
        DioExceptionType,
        Headers,
        Options,
        Response;

/// TEMPORARY (per shop owner request while the backend's quota rollout is
/// still being tuned): treat a `quota_hold` response as success instead of
/// failing the upload. The clip is still fully uploaded to R2 at this point —
/// this only skips the app *reporting* the hold — but the backend may not
/// actually keep/serve evidence it flagged as over-quota, so this must be
/// flipped back to `false` once quota limits are ready to enforce again.
const _ignoreQuotaHoldForTesting = true;

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

/// Real backend uploader following the EvidenceCam presigned-R2 flow:
///
/// 1. `findOrCreateOrder(shopId, tracking)` → the order id;
/// 2. `presignUpload(...)` → a one-time R2 `uploadUrl` + `evidenceId`;
/// 3. `PUT` the clip bytes straight to R2 (a separate token-less Dio, since the
///    presigned URL carries its own signature);
/// 4. `completeUpload(...)` to mark the evidence stored.
class ApiEvidenceUploader implements EcEvidenceUploader {
  ApiEvidenceUploader(
    this._api, {
    Dio? r2Dio,
    this.multipartThresholdBytes = 8 * 1024 * 1024,
    this.multipartPartSizeBytes = 5 * 1024 * 1024,
  }) : _r2 =
           r2Dio ??
           Dio(
             BaseOptions(
               // Sending the clip's bytes can legitimately take minutes on a
               // slow connection, so only the connect/response legs get a
               // tight bound — a dead connection would otherwise hang this
               // PUT (and every queued clip behind it) forever with no error.
               connectTimeout: const Duration(seconds: 15),
               sendTimeout: const Duration(minutes: 5),
               receiveTimeout: const Duration(seconds: 30),
             ),
           );

  final EcApi _api;
  final Dio _r2;
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
    int? capturedAt,
    void Function(double progress)? onProgress,
  }) async {
    try {
      return await _uploadInner(
        file,
        tracking: tracking,
        type: type,
        shopId: shopId,
        capturedAt: capturedAt,
        onProgress: onProgress,
      );
    } on DioException catch (e, stack) {
      Error.throwWithStackTrace(UploadFailureException(_friendlyMessage(e)), stack);
    }
  }

  Future<String> _uploadInner(
    File file, {
    required String tracking,
    required String type,
    String? shopId,
    int? capturedAt,
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
    final videoTypeId = isPhoto ? null : await _videoTypeId(shopId, type);
    final length = await file.length();
    if (length > multipartThresholdBytes) {
      return _uploadMultipart(
        file,
        shopId: shopId,
        orderId: order.id,
        kind: isPhoto ? 'photo' : 'video',
        capturedAt: captureTime,
        videoTypeId: videoTypeId,
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
      videoTypeId: videoTypeId,
      device: await _readDeviceLabel(),
    );
    // presignUpload already created this evidence row server-side (needed to
    // hand back an evidenceId + presigned URL) — if the PUT itself fails, the
    // row is now a permanent orphan (a retry starts over via a fresh presign,
    // never revisiting this evidenceId), left forever at status 'error' and
    // counted in the order's error/evidence totals with nothing in the app
    // pointing back at it. Deleting it here is safe because nothing has been
    // marked done yet; scoped to just the PUT so a completeUpload failure
    // (which may have actually succeeded server-side) is never touched.
    try {
      await _putWithRetry(
        () => _r2.put<void>(
          presign.uploadUrl,
          data: file.openRead(),
          options: Options(
            headers: {
              Headers.contentLengthHeader: length,
              Headers.contentTypeHeader: _contentTypeFor(
                file,
                isPhoto: isPhoto,
              ),
            },
          ),
          onSendProgress: (sent, total) {
            if (total > 0) onProgress?.call(sent / total);
          },
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
    );
    // Aborting deletes the multipart upload on R2 — only safe while nothing
    // has been "completed" yet. Once completeMultipartUpload has actually
    // been sent, the bytes may already be fully assembled server-side even
    // if the client never saw the response (e.g. it timed out waiting); this
    // is scoped so a failure there propagates without aborting a possibly
    // already-succeeded upload out from under itself.
    final uploaded = <UploadedPartDto>[];
    try {
      final partNumbers = [for (var i = 1; i <= partCount; i++) i];
      final urls = await _api.presignMultipartParts(
        shopId,
        orderId,
        created.evidenceId,
        uploadId: created.uploadId,
        partNumbers: partNumbers,
      );
      // Bytes from parts that have *fully* succeeded — the base every
      // in-flight part's progress is added to. Kept separate from the
      // current part's own sent-bytes so a retried part (fresh stream,
      // sent count restarts at 0) can't double-count or go backwards.
      var completedBytes = 0;
      for (final part in urls) {
        final start = (part.partNumber - 1) * partSize;
        final end = start + partSize > length ? length : start + partSize;
        final partLength = end - start;
        final partBase = completedBytes;
        final res = await _putWithRetry(
          () => _r2.put<void>(
            part.uploadUrl,
            data: file.openRead(start, end),
            options: Options(
              headers: {
                Headers.contentLengthHeader: partLength,
                Headers.contentTypeHeader: _contentTypeFor(
                  file,
                  isPhoto: isPhoto,
                ),
              },
            ),
            onSendProgress: (sent, _) =>
                onProgress?.call((partBase + sent) / length),
          ),
        );
        completedBytes += partLength;
        final rawEtag = res.headers.value('etag');
        if (rawEtag == null || rawEtag.isEmpty) {
          throw StateError('missing_part_etag');
        }
        // R2's raw HTTP response quotes the ETag per the S3/HTTP convention
        // (e.g. `"9bb58f26..."`), but the Workers R2 binding's own
        // `complete()` call expects the bare hash it would have gotten back
        // from its own uploadPart() — passing the quoted form through
        // verbatim makes R2 reject the completion, which the backend was
        // surfacing as an unconditional 500 on every single attempt.
        final etag = rawEtag.replaceAll('"', '');
        uploaded.add(UploadedPartDto(partNumber: part.partNumber, etag: etag));
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
    );
    if (status == 'quota_hold' && !_ignoreQuotaHoldForTesting) {
      throw StateError('quota_exceeded');
    }
    return created.key;
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

  Future<String?> _videoTypeId(String shopId, String type) async {
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
/// network/server failures. [attempt] must open a *fresh* byte stream each
/// call — [File.openRead] does, but a re-dispatched `DioException` wouldn't
/// (its stream is already consumed), which is why this can't just be a Dio
/// `Interceptor` like the main API client's `RetryInterceptor`: a PUT body is
/// a one-shot file stream, not a replayable JSON payload.
Future<Response<void>> _putWithRetry(
  Future<Response<void>> Function() attempt,
) async {
  const maxAttempts = 4;
  for (var attemptNumber = 1; ; attemptNumber++) {
    try {
      return await attempt();
    } on DioException catch (e) {
      if (attemptNumber >= maxAttempts || !_isRetryablePutError(e)) rethrow;
      await Future<void>.delayed(_backoffFor(attemptNumber));
    }
  }
}

bool _isRetryablePutError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return true;
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode;
      return status != null && (status == 429 || status >= 500);
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return false;
  }
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

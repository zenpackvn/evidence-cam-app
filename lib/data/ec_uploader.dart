import 'dart:io';

import 'package:ec_data/ec_data.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:network/network.dart'
    show BaseOptions, Dio, Headers, Options;

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

  @override
  Future<String> upload(
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
    );
    await _r2.put<void>(
      presign.uploadUrl,
      data: file.openRead(),
      options: Options(
        headers: {
          Headers.contentLengthHeader: length,
          Headers.contentTypeHeader: _contentTypeFor(file, isPhoto: isPhoto),
        },
      ),
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );
    final status = await _api.completeUpload(
      shopId,
      order.id,
      presign.evidenceId,
    );
    if (status == 'quota_hold') throw StateError('quota_exceeded');
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
    );
    try {
      final partNumbers = [for (var i = 1; i <= partCount; i++) i];
      final urls = await _api.presignMultipartParts(
        shopId,
        orderId,
        created.evidenceId,
        uploadId: created.uploadId,
        partNumbers: partNumbers,
      );
      final uploaded = <UploadedPartDto>[];
      var sentTotal = 0;
      for (final part in urls) {
        final start = (part.partNumber - 1) * partSize;
        final end = start + partSize > length ? length : start + partSize;
        final partLength = end - start;
        var previousPartSent = 0;
        final res = await _r2.put<void>(
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
          onSendProgress: (sent, _) {
            sentTotal += sent - previousPartSent;
            previousPartSent = sent;
            onProgress?.call(sentTotal / length);
          },
        );
        final etag = res.headers.value('etag');
        if (etag == null || etag.isEmpty) throw StateError('missing_part_etag');
        uploaded.add(UploadedPartDto(partNumber: part.partNumber, etag: etag));
      }
      final status = await _api.completeMultipartUpload(
        shopId,
        orderId,
        created.evidenceId,
        uploadId: created.uploadId,
        parts: uploaded,
      );
      if (status == 'quota_hold') throw StateError('quota_exceeded');
      return created.key;
    } on Object {
      await _api.abortMultipartUpload(
        shopId,
        orderId,
        created.evidenceId,
        uploadId: created.uploadId,
      );
      rethrow;
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

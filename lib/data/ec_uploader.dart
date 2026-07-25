import 'dart:io';

import 'package:ec_data/ec_data.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:network/network.dart'
    show BaseOptions, Dio, FormData, Headers, MultipartFile, Options;

/// Real backend uploader following the EvidenceCam presigned-R2 flow:
///
/// 1. `findOrCreateOrder(shopId, tracking)` → the order id;
/// 2. `presignUpload(...)` → a one-time R2 `uploadUrl` + `evidenceId`;
/// 3. `PUT` the clip bytes straight to R2 (a separate token-less Dio, since the
///    presigned URL carries its own signature);
/// 4. `completeUpload(...)` to mark the evidence stored.
class ApiEvidenceUploader implements EcEvidenceUploader {
  ApiEvidenceUploader(this._api, {Dio? r2Dio}) : _r2 = r2Dio ?? Dio();

  final EcApi _api;
  final Dio _r2;

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
    final order = await _api.findOrCreateOrder(shopId, tracking);
    final presign = await _api.presignUpload(
      shopId,
      order.id,
      kind: 'video',
      capturedAt: capturedAt ?? DateTime.now().millisecondsSinceEpoch,
    );
    final length = await file.length();
    await _r2.put<void>(
      presign.uploadUrl,
      data: file.openRead(),
      options: Options(
        headers: {
          Headers.contentLengthHeader: length,
          Headers.contentTypeHeader: 'video/mp4',
        },
      ),
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );
    await _api.completeUpload(shopId, order.id, presign.evidenceId);
    return presign.key;
  }
}

/// Legacy multipart uploader (POST `<baseUrl>/api/evidence`). Kept for the
/// offline/dev path; the real product flow is [ApiEvidenceUploader].
class HttpEvidenceUploader implements EcEvidenceUploader {
  HttpEvidenceUploader({required String baseUrl, Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;

  @override
  Future<String> upload(
    File file, {
    required String tracking,
    required String type,
    String? shopId,
    int? capturedAt,
    void Function(double progress)? onProgress,
  }) async {
    final form = FormData.fromMap({
      'tracking': tracking,
      'type': type,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/evidence',
      data: form,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );
    final url = res.data?['url'];
    return url is String ? url : '';
  }
}

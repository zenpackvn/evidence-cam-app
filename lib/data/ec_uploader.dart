import 'dart:io';

import 'package:network/network.dart' show BaseOptions, Dio, FormData, MultipartFile;

/// Uploads a recorded evidence clip to the backend, reporting progress 0..1.
///
/// A seam so the queue can be tested with a fake and pointed at a real backend
/// once one exists.
// ignore: one_member_abstracts
abstract interface class EcEvidenceUploader {
  /// Uploads [file] for order [tracking] of the given [type]; returns the
  /// stored remote URL. Throws on any failure so the queue can mark it errored.
  Future<String> upload(
    File file, {
    required String tracking,
    required String type,
    void Function(double progress)? onProgress,
  });
}

/// Real multipart uploader hitting `<baseUrl>/api/evidence`. This is live
/// transport — it simply errors until the backend actually serves that route,
/// at which point recorded clips start uploading with no client change.
class HttpEvidenceUploader implements EcEvidenceUploader {
  HttpEvidenceUploader({required String baseUrl, Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;

  @override
  Future<String> upload(
    File file, {
    required String tracking,
    required String type,
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

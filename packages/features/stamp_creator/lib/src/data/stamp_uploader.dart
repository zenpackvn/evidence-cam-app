import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

/// Uploads a rendered stamp PNG to R2 via the backend's presign flow (SM-011,
/// TD-013, S0-2): ask the backend for a presigned PUT URL, upload the bytes
/// straight to R2 (not through the server), and return the public URL to store.
@lazySingleton
class StampUploader {
  StampUploader(this._dio);

  final Dio _dio;

  /// Runs the 3-hop upload and returns the public URL of the stored image.
  /// Throws [DioException] on any hop failure (quota 403, network, R2 error).
  Future<String> upload(Uint8List pngBytes) async {
    // 1. Presign.
    final presign = await _dio.post<Map<String, dynamic>>(
      '/api/sm/uploads/presign',
      data: {'kind': 'stamp', 'content_type': 'image/png'},
    );
    final body = presign.data;
    final uploadUrl = body?['upload_url'];
    final publicUrl = body?['public_url'];
    if (uploadUrl is! String || publicUrl is! String) {
      throw const FormatException('presign response missing url fields');
    }

    // 2. PUT the bytes straight to R2. A plain Dio avoids the auth interceptor
    //    attaching a bearer token to the R2 URL (the presigned URL is already
    //    authorized and an extra header would break the signature).
    await Dio().put<void>(
      uploadUrl,
      data: Stream.fromIterable([pngBytes]),
      options: Options(
        headers: {
          'Content-Type': 'image/png',
          'Content-Length': pngBytes.length,
        },
      ),
    );

    // 3. The caller persists publicUrl via StampsRepository.save.
    return publicUrl;
  }
}

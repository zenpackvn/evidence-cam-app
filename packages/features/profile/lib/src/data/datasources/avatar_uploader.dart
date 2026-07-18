import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

/// Uploads a cropped avatar PNG to R2 via the backend's presign flow (SM-024,
/// TD-013): ask the backend for a presigned PUT URL under the caller's avatar
/// prefix, upload the bytes straight to R2 (not through the server), and return
/// the public URL to store on the profile.
///
/// Deliberately a sibling of the stamp uploader rather than a shared type:
/// features do not import each other, and the only difference is the `kind`, so
/// duplicating a dozen lines is cheaper than promoting a shared abstraction for
/// a two-consumer case.
@lazySingleton
class AvatarUploader {
  AvatarUploader(this._dio);

  final Dio _dio;

  /// Runs the 3-hop upload and returns the public URL of the stored avatar.
  /// Throws [DioException] on any hop failure (network, R2 error).
  Future<String> upload(Uint8List pngBytes) async {
    // 1. Presign under the avatar prefix so the object lands at avatars/<uid>/…
    final presign = await _dio.post<Map<String, dynamic>>(
      '/api/sm/uploads/presign',
      data: {'kind': 'avatar', 'content_type': 'image/png'},
    );
    final body = presign.data;
    final uploadUrl = body?['upload_url'];
    final publicUrl = body?['public_url'];
    if (uploadUrl is! String || publicUrl is! String) {
      throw const FormatException('presign response missing url fields');
    }

    // 2. PUT the bytes straight to R2. A plain Dio avoids the auth interceptor
    //    attaching a bearer token to the R2 URL — the presigned URL is already
    //    authorized and an extra header would break the signature.
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

    // 3. The caller persists publicUrl via ProfileRepository.update.
    return publicUrl;
  }
}

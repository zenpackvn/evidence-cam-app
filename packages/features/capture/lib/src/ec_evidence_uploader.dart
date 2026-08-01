import 'dart:io';

/// Uploads a recorded evidence clip to the backend, reporting progress 0..1.
///
/// A seam so the offline queue can be tested with a fake and pointed at a real
/// backend. Concrete implementations (the presigned-R2 flow, the legacy
/// multipart POST) live in the app shell — they depend on the EC API client —
/// while this contract lives with the capture feature that produces clips.
// ignore: one_member_abstracts
abstract interface class EcEvidenceUploader {
  /// Uploads [file] for the order with tracking code [tracking] of the given
  /// video [type]; returns a stored remote id/URL. Throws on any failure so the
  /// queue can mark it errored.
  ///
  /// [shopId] and [capturedAt] are needed by the real backend flow (they scope
  /// the evidence to a shop/order); the legacy multipart uploader ignores them.
  /// [durationSeconds] is the recorded clip length, known at stop time; null
  /// for photos. [samplesJson] carries the device conditions sampled while
  /// recording (battery/network) — the backend stores them at presign time, so
  /// they must ride along with the bytes rather than be read at upload time:
  /// a clip queued offline uploads hours later, on a different battery and a
  /// different network.
  Future<String> upload(
    File file, {
    required String tracking,
    required String type,
    String? shopId,
    int? capturedAt,
    int? durationSeconds,
    String? samplesJson,
    void Function(double progress)? onProgress,
  });
}

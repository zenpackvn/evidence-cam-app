import 'package:shared_contracts/shared_contracts.dart';

/// How a stamp entered the user's collection (SM-022 BR-01).
enum StampSource {
  /// Made by the user in the stamp creator.
  created,

  /// Saved from a letter another user sent.
  received;

  static StampSource fromWire(String value) =>
      value == 'received' ? StampSource.received : StampSource.created;

  String get wire => name;
}

/// A finished, flattened stamp image in the user's collection. The editing
/// recipe is not kept — a stamp is the rendered PNG only; re-editing produces a
/// new stamp.
class Stamp {
  const Stamp({
    required this.id,
    required this.imageUrl,
    required this.source,
    required this.createdAt,
    this.thumbUrl,
    this.name = '',
    this.senderName,
    this.senderUid,
    this.isPendingSync = false,
  });

  final String id;
  final String imageUrl;
  final String? thumbUrl;

  /// User-set label (SM-022 BR-08). Empty means "no custom name" — the UI shows
  /// the creation date instead.
  final String name;

  final StampSource source;

  /// Sender's display name / uid, set when [source] is [StampSource.received].
  final String? senderName;
  final String? senderUid;

  final DateTime createdAt;

  /// `true` when the stamp has local changes not yet pushed to the server.
  final bool isPendingSync;

  /// Projection for cross-feature use (attaching to a letter, SM-014).
  StampRef toRef() =>
      StampRef(id: id, imageUrl: imageUrl, thumbUrl: thumbUrl, createdAt: createdAt);
}

/// The data needed to save a newly rendered stamp (SM-011). The image must
/// already be uploaded (presigned R2) so only its URL travels here.
class StampInput {
  const StampInput({
    required this.imageUrl,
    this.thumbUrl,
    this.source = StampSource.created,
    this.senderName,
    this.senderUid,
    this.id,
    this.name = '',
  });

  final String imageUrl;
  final String? thumbUrl;
  final StampSource source;
  final String? senderName;
  final String? senderUid;

  /// Optional stable id. When set (e.g. saving a sample stamp, SM-035 BR-03),
  /// it is reused so saving the same item twice is a no-op instead of a
  /// duplicate; when null the repository mints a fresh UUID.
  final String? id;

  /// Optional preset name (SM-022 BR-08 / SM-035 keeps samples unnamed).
  final String name;
}

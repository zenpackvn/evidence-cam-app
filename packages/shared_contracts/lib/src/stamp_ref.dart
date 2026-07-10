/// Lightweight projection of a stamp for cross-feature exchange, so the letters
/// feature can attach stamps owned by the album feature without depending on
/// the album's `Stamp` aggregate (SM-014).
///
/// A stamp is a rendered, flattened PNG — the editing recipe is not carried
/// here (nor persisted server-side); re-editing produces a new stamp.
class StampRef {
  const StampRef({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
    this.thumbUrl,
  });

  final String id;

  /// URL of the finished stamp PNG (Cloudflare R2, TD-013).
  final String imageUrl;

  /// Smaller preview URL, when available.
  final String? thumbUrl;

  /// When the stamp was created or received (SM-011 BR-08).
  final DateTime createdAt;

  /// The preview URL to show, preferring [thumbUrl] and falling back to the
  /// full [imageUrl].
  String get displayUrl => thumbUrl ?? imageUrl;
}

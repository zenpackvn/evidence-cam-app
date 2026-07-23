/// A StampMail-designed stamp from the sample catalog (SM-035). Read-only and
/// the same for every user; saving one copies it into the personal album
/// (SM-035 BR-03) with no source label (BR-01).
class SampleStamp {
  const SampleStamp({
    required this.id,
    required this.imageUrl,
    required this.thumbUrl,
    required this.theme,
    this.name = '',
    this.isNew = false,
  });

  final String id;

  /// Display name (SM-035): shown on the tile and detail, and carried onto the
  /// saved album stamp so it stays recognizable.
  final String name;

  final String imageUrl;
  final String thumbUrl;

  /// Catalog theme this stamp belongs to (SM-035 BR-02).
  final String theme;

  /// Shows a "Mới" badge for a while after release (BR-06).
  final bool isNew;
}

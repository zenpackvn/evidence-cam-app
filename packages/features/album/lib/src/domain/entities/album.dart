/// A user-named album grouping stamps by their stable ids (SM-022 BR-06). The
/// built-in All/Created/Received views are derived from stamp source, not
/// represented by this type.
class Album {
  const Album({
    required this.id,
    required this.name,
    required this.stampIds,
    required this.createdAt,
    required this.updatedAt,
    this.isPendingSync = false,
    this.isConflicted = false,
    this.isFailed = false,
  });

  final String id;
  final String name;

  /// Stable stamp uuids in this album; one stamp may live in many albums.
  final List<String> stampIds;

  final DateTime createdAt;
  final DateTime updatedAt;

  final bool isPendingSync;
  final bool isConflicted;
  final bool isFailed;

  int get stampCount => stampIds.length;
}

class AlbumInput {
  const AlbumInput({required this.name, this.stampIds = const []});

  final String name;
  final List<String> stampIds;
}

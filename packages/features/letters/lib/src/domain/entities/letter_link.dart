/// A one-time / 7-day share link for a letter (SM-016, TD-006). One link is
/// minted per recipient; the URL embeds [id].
class LetterLink {
  const LetterLink({
    required this.id,
    required this.letterId,
    required this.createdAt,
    required this.expiresAt,
    this.platform,
    this.openedBy,
    this.openedAt,
  });

  final String id;
  final String letterId;

  /// The social platform the sender picked, for stats only (SM-016 BR-04).
  final String? platform;

  final DateTime createdAt;
  final DateTime expiresAt;

  /// `null` until first opened; a uid or `"anonymous"` once opened.
  final String? openedBy;
  final DateTime? openedAt;

  bool get isOpened => openedBy != null;
  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  /// The shareable URL for this link, built from the app's letter-link base.
  String shareUrl(String base) => '${base.replaceAll(RegExp(r"/+$"), "")}/$id';
}

/// The delivery status shown in the sent box (SM-021).
enum SentStatus { pending, opened, expired }

/// A sent letter's link plus its derived status, for the sent box.
class SentLetter {
  const SentLetter({required this.link, required this.status});

  factory SentLetter.fromLink(LetterLink link) {
    final status = link.isOpened
        ? SentStatus.opened
        : (link.isExpired ? SentStatus.expired : SentStatus.pending);
    return SentLetter(link: link, status: status);
  }

  final LetterLink link;
  final SentStatus status;
}

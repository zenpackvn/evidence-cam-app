/// A letter in the signed-in user's inbox (SM-018): recorded server-side when
/// a link addressed to them was opened (A17).
class InboxEntry {
  const InboxEntry({
    required this.id,
    required this.letterId,
    required this.linkId,
    required this.senderUid,
    required this.openedAt,
    required this.read,
  });

  final String id;
  final String letterId;
  final String linkId;
  final String senderUid;
  final DateTime openedAt;
  final bool read;
}

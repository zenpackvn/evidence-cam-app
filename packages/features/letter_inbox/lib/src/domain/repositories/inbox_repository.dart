import '../entities/received_letter.dart';

/// Opens a received letter from its share link. Received letters are never
/// listed or stored for the recipient, and their stamps are never saved to the
/// recipient's album (SM-017 BR-05/BR-10) — a re-view goes through the original
/// link.
// A single-method port by design (the reveal flow only opens a link); the data
// layer swaps the Dio-backed impl for a fake in tests.
// ignore: one_member_abstracts
abstract interface class InboxRepository {
  /// Opens the link [linkId] as the given viewer (a uid, or null for
  /// anonymous). Returns the terminal outcome: opened / already-opened /
  /// expired / invalid (SM-017). Network errors throw.
  Future<OpenLetterOutcome> open(String linkId, {String? viewerUid});
}

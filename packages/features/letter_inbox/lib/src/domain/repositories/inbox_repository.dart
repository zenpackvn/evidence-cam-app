import '../entities/received_letter.dart';

/// Opens a received letter from its share link and saves its stamps. Received
/// letters are never listed or stored for the recipient (SM-017 BR-10) — a
/// re-view goes through the original link.
abstract interface class InboxRepository {
  /// Opens the link [linkId] as the given viewer (a uid, or null for
  /// anonymous). Returns the terminal outcome: opened / already-opened /
  /// expired / invalid (SM-017). Network errors throw.
  Future<OpenLetterOutcome> open(String linkId, {String? viewerUid});

  /// Saves the letter's stamps into the signed-in user's album as `received`
  /// stamps (SM-017 BR-05). Returns the number saved.
  Future<int> saveStamps(ReceivedLetter letter);
}

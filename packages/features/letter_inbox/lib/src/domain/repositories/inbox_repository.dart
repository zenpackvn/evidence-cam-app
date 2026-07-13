import 'package:architecture/architecture.dart';

import '../entities/inbox_entry.dart';
import '../entities/received_letter.dart';

/// Opens a received letter from its share link, lists received letters, and
/// saves their stamps.
abstract interface class InboxRepository {
  /// Opens the link [linkId] as the given viewer (a uid, or null for
  /// anonymous). Returns the terminal outcome: opened / already-opened /
  /// expired / invalid (SM-017). Network errors throw.
  Future<OpenLetterOutcome> open(String linkId, {String? viewerUid});

  /// Saves the letter's stamps into the signed-in user's album as `received`
  /// stamps (SM-017 BR-05). Returns the number saved.
  Future<int> saveStamps(ReceivedLetter letter);

  /// Lists the signed-in user's received letters, newest first (SM-018, A17).
  Future<Result<List<InboxEntry>>> list();

  /// How many received letters are still unread (SM-004 BR-01).
  Future<Result<int>> unreadCount();
}

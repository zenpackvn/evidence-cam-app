import 'package:architecture/architecture.dart';

import '../entities/letter.dart';
import '../entities/letter_content.dart';
import '../entities/letter_link.dart';

/// The locally-cached record of a letter this device composed: its body (for
/// re-viewing and deriving a title) and the ids of the stamps attached (so the
/// Home card can show the letter's stamp as its picture).
typedef CachedLetter = ({LetterContent content, List<String> stampIds});

/// Composing, sending, and tracking letters. Unlike stamps/albums this is not
/// offline-first — letters are created online and the share link must come from
/// the server (it mints the one-time token and reserves the monthly quota).
abstract interface class LettersRepository {
  /// Saves a composed letter (SM-013). Returns the persisted letter.
  Future<Result<Letter>> create(LetterInput input);

  /// Mints a one-time/7-day share link for [letterId] on [platform] (SM-016).
  /// The server reserves a monthly send-quota slot and credits +5 seals.
  Future<Result<LetterLink>> createLink(String letterId, {String? platform});

  /// Lists the caller's sent links with derived status (SM-021).
  Future<Result<List<SentLetter>>> sent();

  /// The locally-cached content of a letter this device composed, or null if
  /// it was not created here. The backend exposes no "read my letter by id"
  /// endpoint (only one-time link opens), so re-viewing a sent letter relies on
  /// the copy stashed at [create] time.
  Future<LetterContent?> cachedContent(String letterId);

  /// The full cached record (content + attached stamp ids), or null if the
  /// letter was not composed on this device.
  Future<CachedLetter?> cachedMeta(String letterId);
}

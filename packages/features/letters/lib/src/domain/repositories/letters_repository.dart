import 'package:architecture/architecture.dart';

import '../entities/letter.dart';
import '../entities/letter_link.dart';

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
}

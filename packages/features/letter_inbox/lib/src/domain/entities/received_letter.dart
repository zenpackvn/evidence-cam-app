import 'package:shared_contracts/shared_contracts.dart';

/// A letter opened from a share link, with its attached stamps resolved to
/// image URLs (SM-017). The recipient may be anonymous (web) or signed in.
class ReceivedLetter {
  const ReceivedLetter({
    required this.id,
    required this.text,
    required this.stamps,
    required this.createdAt,
    this.templateId = 'classic',
  });

  final String id;
  final String templateId;
  final String text;

  /// The stamps attached to the letter, ready to render or save to the album.
  final List<StampRef> stamps;

  final DateTime createdAt;
}

/// The outcome of opening a link (SM-017). A link is one-time and 7-day, so a
/// second open, an expired link, or an invalid id are distinct terminal states.
sealed class OpenLetterOutcome {
  const OpenLetterOutcome();
}

class LetterOpened extends OpenLetterOutcome {
  const LetterOpened(this.letter);
  final ReceivedLetter letter;
}

/// The link was already opened by someone else (SM-017 AC-03).
class LetterAlreadyOpened extends OpenLetterOutcome {
  const LetterAlreadyOpened();
}

/// The link passed its 7-day window (SM-017 AC-05).
class LetterExpired extends OpenLetterOutcome {
  const LetterExpired();
}

/// The link id doesn't exist.
class LetterInvalid extends OpenLetterOutcome {
  const LetterInvalid();
}

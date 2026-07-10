import 'letter_content.dart';

/// A composed letter with its attached stamps (SM-012..015). Up to 3 stamps may
/// be attached (SM-014 BR-03).
class Letter {
  const Letter({
    required this.id,
    required this.content,
    required this.stampIds,
    required this.createdAt,
  });

  final String id;
  final LetterContent content;

  /// Stable stamp uuids attached to this letter (max 3).
  final List<String> stampIds;

  final DateTime createdAt;
}

/// The data needed to compose and save a letter before sending.
class LetterInput {
  const LetterInput({required this.content, this.stampIds = const []});

  final LetterContent content;
  final List<String> stampIds;

  /// Max stamps attachable to one letter (SM-014 BR-03).
  static const maxStamps = 3;
}

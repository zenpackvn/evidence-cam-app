import 'package:flutter/foundation.dart';

import '../../domain/entities/letter_content.dart';
import '../../domain/entities/letter_link.dart';

/// Where the composer is in the send flow.
enum ComposerPhase { editing, sending, sent, error }

/// A stamp's placement on the letter: normalized centre (0..1 of the letter
/// area) and rotation in radians. Shared by "Đính tem" (where it is set) and
/// "Xem trước thư" (where it must render identically).
typedef StampPlacement = ({double dx, double dy, double rot});

/// The composer's state (SM-012..016): the draft content, the stamps attached
/// (≤3), and the send phase with the resulting share link when sent.
@immutable
class ComposerState {
  const ComposerState({
    required this.content,
    this.stampIds = const [],
    this.placements = const {},
    this.phase = ComposerPhase.editing,
    this.link,
    this.errorMessage,
  });

  ComposerState.initial(String templateId)
    : content = LetterContent(templateId: templateId, text: ''),
      stampIds = const [],
      placements = const {},
      phase = ComposerPhase.editing,
      link = null,
      errorMessage = null;

  final LetterContent content;
  final List<String> stampIds;

  /// Where each attached stamp sits on the letter (by stamp id). Set on the
  /// "Đính tem" screen and read back on the preview so both look the same.
  final Map<String, StampPlacement> placements;

  final ComposerPhase phase;

  /// The minted share link, set once [phase] is [ComposerPhase.sent].
  final LetterLink? link;

  /// Why the send failed, when [phase] is [ComposerPhase.error] — shown to the
  /// user so a failure isn't a silent dead button.
  final String? errorMessage;

  int get charCount => content.text.length;
  bool get canSend =>
      content.text.trim().isNotEmpty && phase == ComposerPhase.editing;

  ComposerState copyWith({
    LetterContent? content,
    List<String>? stampIds,
    Map<String, StampPlacement>? placements,
    ComposerPhase? phase,
    LetterLink? link,
    String? errorMessage,
  }) => ComposerState(
    content: content ?? this.content,
    stampIds: stampIds ?? this.stampIds,
    placements: placements ?? this.placements,
    phase: phase ?? this.phase,
    link: link ?? this.link,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

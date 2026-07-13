import 'package:flutter/foundation.dart';

import '../../domain/entities/letter_content.dart';
import '../../domain/entities/letter_link.dart';

/// Where the composer is in the send flow.
enum ComposerPhase { editing, sending, sent, error }

/// The composer's state (SM-012..016): the draft content, the stamps attached
/// (≤3), and the send phase with the resulting share link when sent.
@immutable
class ComposerState {
  const ComposerState({
    required this.content,
    this.stampIds = const [],
    this.phase = ComposerPhase.editing,
    this.link,
  });

  ComposerState.initial(String templateId)
    : content = LetterContent(templateId: templateId, text: ''),
      stampIds = const [],
      phase = ComposerPhase.editing,
      link = null;

  final LetterContent content;
  final List<String> stampIds;
  final ComposerPhase phase;

  /// The minted share link, set once [phase] is [ComposerPhase.sent].
  final LetterLink? link;

  int get charCount => content.text.length;
  bool get canSend =>
      content.text.trim().isNotEmpty && phase == ComposerPhase.editing;

  ComposerState copyWith({
    LetterContent? content,
    List<String>? stampIds,
    ComposerPhase? phase,
    LetterLink? link,
  }) => ComposerState(
    content: content ?? this.content,
    stampIds: stampIds ?? this.stampIds,
    phase: phase ?? this.phase,
    link: link ?? this.link,
  );
}

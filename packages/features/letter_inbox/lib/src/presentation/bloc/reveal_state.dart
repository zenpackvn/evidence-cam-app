import 'package:flutter/foundation.dart';

import '../../domain/entities/received_letter.dart';

/// The reveal screen's phase (SM-017): before opening, while opening, and the
/// four terminal outcomes of consuming a one-time link.
enum RevealPhase { intro, opening, opened, alreadyOpened, expired, invalid }

/// State for opening + reading a received letter (SM-017/019).
@immutable
class RevealState {
  const RevealState({
    this.phase = RevealPhase.intro,
    this.letter,
    this.senderName,
  });

  final RevealPhase phase;

  /// Set once the link opens successfully.
  final ReceivedLetter? letter;

  /// Sender display name for the header, if known from the link/deferred link.
  final String? senderName;

  bool get isOpen => phase == RevealPhase.opened && letter != null;

  RevealState copyWith({
    RevealPhase? phase,
    ReceivedLetter? letter,
    String? senderName,
  }) => RevealState(
    phase: phase ?? this.phase,
    letter: letter ?? this.letter,
    senderName: senderName ?? this.senderName,
  );
}

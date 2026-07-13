import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/received_letter.dart';
import '../../domain/repositories/inbox_repository.dart';
import 'reveal_state.dart';

/// Drives opening + reading a received letter (SM-017/019): consumes the
/// one-time link, classifies the outcome, and saves the letter's stamps to the
/// album on request. Constructed with the link id at open time (not injectable).
class RevealCubit extends Cubit<RevealState> {
  RevealCubit(this._inbox, {required this.linkId, this.viewerUid, String? senderName})
    : super(RevealState(senderName: senderName));

  final InboxRepository _inbox;
  final String linkId;

  /// The signed-in viewer's uid, or null for an anonymous (web) reader.
  final String? viewerUid;

  /// Consumes the link and moves to the matching terminal phase (SM-017).
  Future<void> open() async {
    if (state.phase != RevealPhase.intro) return;
    emit(state.copyWith(phase: RevealPhase.opening));
    final outcome = await _inbox.open(linkId, viewerUid: viewerUid);
    switch (outcome) {
      case LetterOpened(:final letter):
        emit(state.copyWith(phase: RevealPhase.opened, letter: letter));
      case LetterAlreadyOpened():
        emit(state.copyWith(phase: RevealPhase.alreadyOpened));
      case LetterExpired():
        emit(state.copyWith(phase: RevealPhase.expired));
      case LetterInvalid():
        emit(state.copyWith(phase: RevealPhase.invalid));
    }
  }

  /// Saves the opened letter's stamps into the viewer's album (SM-017 BR-05).
  Future<void> saveStamps() async {
    final letter = state.letter;
    if (letter == null || state.savingStamps || state.stampsSaved) return;
    emit(state.copyWith(savingStamps: true));
    await _inbox.saveStamps(letter);
    emit(state.copyWith(savingStamps: false, stampsSaved: true));
  }
}

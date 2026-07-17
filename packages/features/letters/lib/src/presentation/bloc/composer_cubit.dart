import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/letter.dart';
import '../../domain/repositories/letters_repository.dart';
import '../composer_catalog.dart';
import 'composer_state.dart';

/// Drives the letter composer (SM-012..016): it owns the immutable draft, edits
/// it (template / text / font / paper / attached stamps ≤3), and on send creates
/// the letter then mints a share link for the chosen platform.
class ComposerCubit extends Cubit<ComposerState> {
  ComposerCubit(this._letters, {String templateId = 'classic', this.replyToUid})
    : super(ComposerState.initial(templateId));

  final LettersRepository _letters;

  /// Set when composing a reply (SM-020) — threaded into the created letter so
  /// the server pushes "letter received" to the original sender (SM-026 D12).
  final String? replyToUid;

  // ── Editing ──────────────────────────────────────────────────────────────
  void selectTemplate(String templateId) => emit(
    state.copyWith(content: state.content.copyWith(templateId: templateId)),
  );

  void setText(String text) {
    final clipped = text.length > letterCharLimit
        ? text.substring(0, letterCharLimit)
        : text;
    emit(state.copyWith(content: state.content.copyWith(text: clipped)));
  }

  void selectFont(String fontFamily) => emit(
    state.copyWith(content: state.content.copyWith(fontFamily: fontFamily)),
  );

  void selectPaper(int paperColor) => emit(
    state.copyWith(content: state.content.copyWith(paperColor: paperColor)),
  );

  /// Toggles a stamp attachment, capping at [LetterInput.maxStamps] (SM-014
  /// BR-03).
  void toggleStamp(String stampId) {
    final current = state.stampIds;
    if (current.contains(stampId)) {
      emit(state.copyWith(stampIds: current.where((s) => s != stampId).toList()));
    } else if (current.length < LetterInput.maxStamps) {
      emit(state.copyWith(stampIds: [...current, stampId]));
    }
  }

  // ── Send (SM-016) ──────────────────────────────────────────────────────────
  /// Creates the letter then mints a one-time share link for [platform]. On
  /// success the state carries the link URL (phase = sent).
  Future<void> send({String? platform}) async {
    if (!state.canSend) return;
    emit(state.copyWith(phase: ComposerPhase.sending));

    final created = await _letters.create(
      LetterInput(
        content: state.content,
        stampIds: state.stampIds,
        replyToUid: replyToUid,
      ),
    );
    switch (created) {
      case Ok(:final value):
        final link = await _letters.createLink(value.id, platform: platform);
        switch (link) {
          case Ok(value: final l):
            emit(state.copyWith(phase: ComposerPhase.sent, link: l));
          case Err():
            emit(state.copyWith(phase: ComposerPhase.error));
        }
      case Err():
        emit(state.copyWith(phase: ComposerPhase.error));
    }
  }
}

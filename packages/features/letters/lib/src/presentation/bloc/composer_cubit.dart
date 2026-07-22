import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/letter.dart';
import '../../domain/entities/letter_content.dart';
import '../../domain/repositories/letters_repository.dart';
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

  /// SM-013 — the letter's short title, shown on the Home card.
  void setTitle(String title) =>
      emit(state.copyWith(content: state.content.copyWith(title: title)));

  /// SM-016 — who the letter is for (typed at send), shown as "Gửi đến …".
  void setRecipient(String recipient) => emit(
    state.copyWith(content: state.content.copyWith(recipient: recipient)),
  );

  /// Replaces the body with unformatted text, clipped to the limit (BR-04).
  /// Drops any recorded formatting — the rich editor calls [setRichBody].
  void setText(String text) =>
      emit(state.copyWith(content: state.content.withPlainBody(text)));

  /// Replaces the body with the editor's Delta (SM-013 BR-02 / BR-09). The
  /// plain-text fallback and the character limit are enforced by
  /// [LetterContent.withBody], so the two representations cannot drift.
  void setRichBody(DeltaOps delta) =>
      emit(state.copyWith(content: state.content.withBody(delta)));

  void selectFont(String fontFamily) => emit(
    state.copyWith(content: state.content.copyWith(fontFamily: fontFamily)),
  );

  void selectPaper(int paperColor) => emit(
    state.copyWith(content: state.content.copyWith(paperColor: paperColor)),
  );

  /// Sets ruled lines on the paper (SM-013 BR-08 / AC-07..08). Text is kept.
  void setRuled({required bool ruled}) => emit(
    state.copyWith(content: state.content.copyWith(ruled: ruled)),
  );

  /// Toggles a stamp attachment, capping at [LetterInput.maxStamps] (SM-014
  /// BR-03). Placement is kept in step: a default spot for a newly attached
  /// stamp, dropped when detached — so the preview can render the same layout.
  void toggleStamp(String stampId) {
    final current = state.stampIds;
    final placements = {...state.placements};
    if (current.contains(stampId)) {
      placements.remove(stampId);
      emit(
        state.copyWith(
          stampIds: current.where((s) => s != stampId).toList(),
          placements: placements,
        ),
      );
    } else if (current.length < LetterInput.maxStamps) {
      final i = current.length;
      placements[stampId] = (dx: 0.35 + i * 0.18, dy: 0.68, rot: 0);
      emit(
        state.copyWith(stampIds: [...current, stampId], placements: placements),
      );
    }
  }

  /// SM-014 — moves a stamp to a new normalized centre on the letter.
  void moveStamp(String stampId, double dx, double dy) {
    final rot = state.placements[stampId]?.rot ?? 0;
    emit(
      state.copyWith(
        placements: {
          ...state.placements,
          stampId: (dx: dx, dy: dy, rot: rot),
        },
      ),
    );
  }

  /// SM-014 — rotates a stamp a notch (double-tap on "Đính tem").
  void rotateStamp(String stampId) {
    final p = state.placements[stampId] ?? (dx: 0.5, dy: 0.6, rot: 0.0);
    emit(
      state.copyWith(
        placements: {
          ...state.placements,
          stampId: (dx: p.dx, dy: p.dy, rot: p.rot + 0.26),
        },
      ),
    );
  }

  // ── Send (SM-016) ──────────────────────────────────────────────────────────
  /// Creates the letter then mints a one-time share link for [platform]. On
  /// success the state carries the link URL (phase = sent).
  Future<void> send({String? platform}) async {
    // Empty letters aren't sent (TC-13). A send already in flight isn't
    // repeated — but a previous *error* can be retried (the button must not go
    // dead after one failure).
    if (state.content.text.trim().isEmpty) return;
    if (state.phase == ComposerPhase.sending) return;
    emit(state.copyWith(phase: ComposerPhase.sending));

    try {
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
            case Err(:final failure):
              emit(
                state.copyWith(
                  phase: ComposerPhase.error,
                  errorMessage: failure.message,
                ),
              );
          }
        case Err(:final failure):
          emit(
            state.copyWith(
              phase: ComposerPhase.error,
              errorMessage: failure.message,
            ),
          );
      }
    } on Object catch (e) {
      // Anything unexpected still ends the spinner instead of hanging.
      emit(
        state.copyWith(phase: ComposerPhase.error, errorMessage: e.toString()),
      );
    }
  }
}

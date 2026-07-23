import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network/network.dart';

import '../../data/stamp_uploader.dart';
import '../../domain/stamp_draft.dart';
import 'creator_state.dart';

/// Drives the create-a-stamp wizard: it owns the immutable [StampDraft] and the
/// current step, and applies every edit as a new draft (SM-005 BR-06: the source
/// is never mutated). The wizard steps it walks are filter → decorate → preview;
/// the source-pick step (SM-005) precedes it.
///
/// Not `@injectable` — it is constructed with the picked image path at wizard
/// entry. The host provides it via `BlocProvider`, passing the [StampUploader]
/// and [StampsRepository] resolved from DI.
class CreatorCubit extends Cubit<CreatorState> {
  CreatorCubit({
    required String imagePath,
    required this._uploader,
    required this._stamps,
    StampFrameStyle frameStyle = StampFrameStyle.none,
    bool isPremium = false,
  }) : super(
         CreatorState.initial(imagePath).copyWith(
           isPremium: isPremium,
           draft: StampDraft(imagePath: imagePath, frameStyle: frameStyle),
         ),
       );

  final StampUploader _uploader;
  final StampsRepository _stamps;

  /// Wraps the preview stamp in a RepaintBoundary so [save] can capture it to a
  /// PNG. The preview step attaches this key.
  final GlobalKey repaintKey = GlobalKey();

  /// Higher pixel ratio → a crisp stamp image regardless of screen density.
  static const double _capturePixelRatio = 3;

  // ── Navigation ─────────────────────────────────────────────────────────
  void next() {
    if (state.isLastStep) return;
    const steps = CreatorStep.values;
    final i = steps.indexOf(state.step);
    emit(state.copyWith(step: steps[i + 1]));
  }

  /// Steps back within the wizard. Returns false when already at the first
  /// wizard step (filter), so the host can pop back to the source picker.
  bool back() {
    const steps = CreatorStep.values;
    final i = steps.indexOf(state.step);
    if (i <= 1) {
      return false; // filter is index 1; source (0) is a separate screen
    }
    emit(state.copyWith(step: steps[i - 1]));
    return true;
  }

  // ── Filter step (SM-006) ─────────────────────────────────────────────────
  void selectFilter(String filterId) =>
      emit(state.copyWith(draft: state.draft.copyWith(filterId: filterId)));

  void setAdjustments(Adjustments adjustments) => emit(
    state.copyWith(draft: state.draft.copyWith(adjustments: adjustments)),
  );

  // ── Decorate step (SM-008/009) ───────────────────────────────────────────
  void addSticker(StickerPlacement sticker) => emit(
    state.copyWith(
      draft: state.draft.copyWith(stickers: [...state.draft.stickers, sticker]),
    ),
  );

  /// SM-008: repositions the sticker at [index] to a new normalized center as
  /// the user drags it around the canvas.
  void moveSticker(int index, double dx, double dy) {
    final stickers = [...state.draft.stickers];
    if (index < 0 || index >= stickers.length) return;
    stickers[index] = stickers[index].copyWith(
      dx: dx.clamp(0.0, 1.0),
      dy: dy.clamp(0.0, 1.0),
    );
    emit(state.copyWith(draft: state.draft.copyWith(stickers: stickers)));
  }

  void updateSticker(int index, StickerPlacement sticker) {
    final next = [...state.draft.stickers];
    if (index < 0 || index >= next.length) return;
    next[index] = sticker;
    emit(state.copyWith(draft: state.draft.copyWith(stickers: next)));
  }

  void removeSticker(int index) {
    final next = [...state.draft.stickers]..removeAt(index);
    emit(state.copyWith(draft: state.draft.copyWith(stickers: next)));
  }

  void selectBorder(String borderId) =>
      emit(state.copyWith(draft: state.draft.copyWith(borderId: borderId)));

  /// SM-005/SM-009 — the tem edge shown on every step of the wizard.
  void selectFrameStyle(StampFrameStyle frame) =>
      emit(state.copyWith(draft: state.draft.copyWith(frameStyle: frame)));

  /// SM-009 "Nền": sets the stamp's paper/background colour.
  void selectPaper(int color) =>
      emit(state.copyWith(draft: state.draft.copyWith(paperColor: color)));

  // ── Preview / hoàn thiện (SM-010) ────────────────────────────────────────
  /// Sets the stamp name shown on the finish form; persisted on save.
  void setStampName(String name) => emit(state.copyWith(name: name));

  /// Adds a tag (trimmed, ignoring blanks and duplicates).
  void addTag(String tag) {
    final t = tag.trim();
    if (t.isEmpty || state.tags.contains(t)) return;
    emit(state.copyWith(tags: [...state.tags, t]));
  }

  void removeTag(int index) {
    if (index < 0 || index >= state.tags.length) return;
    emit(state.copyWith(tags: [...state.tags]..removeAt(index)));
  }

  /// Sets the personal note attached to the stamp on the finish form.
  void setNote(String note) => emit(state.copyWith(note: note));

  // ── Save (SM-011) ────────────────────────────────────────────────────────
  /// Saves the stamp (SM-011, S0-2): render the composed stamp to PNG, upload it
  /// to R2 (3-hop presign→PUT), then persist the public URL through the stamps
  /// repository. On quota-reached (403) or any failure it surfaces an error and
  /// leaves the wizard so the user can retry / upgrade.
  Future<void> save() async {
    if (state.saving || state.saved) return;
    emit(state.copyWith(saving: true));
    try {
      final png = await _capturePng();
      final imageUrl = await _uploader.upload(png);
      final result = await _stamps.save(
        StampInput(imageUrl: imageUrl, name: state.name.trim()),
      );
      switch (result) {
        case Ok():
          emit(state.copyWith(saving: false, saved: true));
        case Err():
          emit(
            state.copyWith(
              saving: false,
              errorMessage: 'Không lưu được tem. Vui lòng thử lại.',
            ),
          );
      }
    } on DioException catch (e) {
      // Quota-reached (Free 30/month) surfaces as a 403; the wizard shows the
      // F02-S13 modal for it rather than an error snackbar.
      if (e.response?.statusCode == 403) {
        emit(state.copyWith(saving: false, quotaReached: true));
      } else {
        emit(
          state.copyWith(
            saving: false,
            errorMessage: 'Không lưu được tem. Vui lòng thử lại.',
          ),
        );
      }
    } on Object {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: 'Không lưu được tem. Vui lòng thử lại.',
        ),
      );
    }
  }

  /// Captures the RepaintBoundary at [repaintKey] to PNG bytes (SM-011). The
  /// Free watermark is part of the previewed widget, so it composites into the
  /// captured image rather than being an overlay.
  Future<Uint8List> _capturePng() async {
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('stamp preview not mounted');
    }
    final image = await boundary.toImage(pixelRatio: _capturePixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('failed to encode PNG');
    return data.buffer.asUint8List();
  }

  /// Clears the quota-reached flag once the wizard has shown its modal, so a
  /// later save attempt can trigger it again.
  void resetQuota() => emit(state.copyWith(quotaReached: false));
}

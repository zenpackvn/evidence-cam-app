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
    bool isPremium = false,
  }) : super(CreatorState.initial(imagePath).copyWith(isPremium: isPremium));

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
    if (i <= 1) return false; // filter is index 1; source (0) is a separate screen
    emit(state.copyWith(step: steps[i - 1]));
    return true;
  }

  // ── Filter step (SM-006) ─────────────────────────────────────────────────
  void selectFilter(String filterId) =>
      emit(state.copyWith(draft: state.draft.copyWith(filterId: filterId)));

  void setAdjustments(Adjustments adjustments) =>
      emit(state.copyWith(draft: state.draft.copyWith(adjustments: adjustments)));

  // ── Decorate step (SM-008/009) ───────────────────────────────────────────
  void addSticker(StickerPlacement sticker) => emit(
    state.copyWith(
      draft: state.draft.copyWith(stickers: [...state.draft.stickers, sticker]),
    ),
  );

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
      final result = await _stamps.save(StampInput(imageUrl: imageUrl));
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
      emit(state.copyWith(saving: false, errorMessage: _dioMessage(e)));
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
        repaintKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('stamp preview not mounted');
    }
    final image = await boundary.toImage(pixelRatio: _capturePixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('failed to encode PNG');
    return data.buffer.asUint8List();
  }

  // Quota-reached (BR: Free 30 stamps/month) surfaces as a 403 on presign/save.
  String _dioMessage(DioException e) => e.response?.statusCode == 403
      ? 'Bạn đã đạt giới hạn tem tháng này. Nâng cấp Premium để tạo thêm.'
      : 'Không lưu được tem. Vui lòng thử lại.';
}

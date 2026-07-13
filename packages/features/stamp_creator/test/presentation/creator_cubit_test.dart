import 'dart:typed_data';

import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:feature_stamp_creator/feature_stamp_creator.dart';
import 'package:feature_stamp_creator/src/data/stamp_uploader.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUploader implements StampUploader {
  @override
  Future<String> upload(Uint8List pngBytes) async => 'https://cdn/stamp.png';
}

class _FakeStamps implements StampsRepository {
  StampInput? saved;

  @override
  Future<Result<Stamp>> save(StampInput input) async {
    saved = input;
    return Ok(
      Stamp(
        id: 's1',
        imageUrl: input.imageUrl,
        source: StampSource.created,
        createdAt: DateTime(2026),
      ),
    );
  }

  @override
  Future<Result<List<Stamp>>> list() async => const Ok([]);
  @override
  Future<Result<List<Stamp>>> listLocal() async => const Ok([]);
  @override
  Future<Result<Stamp>> get(String id) async => const Err(NotFoundFailure());
  @override
  Future<Result<void>> delete(String id) async => const Ok(null);
}

void main() {
  CreatorCubit build({bool premium = false}) => CreatorCubit(
    imagePath: '/tmp/p.jpg',
    isPremium: premium,
    uploader: _FakeUploader(),
    stamps: _FakeStamps(),
  );

  test('opens on the filter step with the picked photo', () {
    final cubit = build();
    expect(cubit.state.step, CreatorStep.filter);
    expect(cubit.state.draft.imagePath, '/tmp/p.jpg');
    addTearDown(cubit.close);
  });

  test('next walks filter → decorate → preview and stops', () {
    final cubit = build();
    cubit.next();
    expect(cubit.state.step, CreatorStep.decorate);
    cubit.next();
    expect(cubit.state.step, CreatorStep.preview);
    cubit.next(); // already last — no-op
    expect(cubit.state.step, CreatorStep.preview);
    addTearDown(cubit.close);
  });

  test('back returns false at the filter step (host pops to picker)', () {
    final cubit = build();
    expect(cubit.back(), isFalse);
    expect(cubit.state.step, CreatorStep.filter);
    cubit.next(); // decorate
    expect(cubit.back(), isTrue);
    expect(cubit.state.step, CreatorStep.filter);
    addTearDown(cubit.close);
  });

  test('editing never mutates the original image path (immutability)', () {
    final cubit = build();
    final original = cubit.state.draft;
    cubit.selectFilter('sepia');
    cubit.addSticker(const StickerPlacement(glyph: '🌸', dx: 0.5, dy: 0.5));
    expect(cubit.state.draft.imagePath, original.imagePath);
    expect(cubit.state.draft.filterId, 'sepia');
    expect(cubit.state.draft.stickers, hasLength(1));
    // The original draft object is untouched.
    expect(original.filterId, StampDraft.kOriginalFilter);
    expect(original.stickers, isEmpty);
    addTearDown(cubit.close);
  });

  test('removeSticker drops the placement', () {
    final cubit = build();
    cubit.addSticker(const StickerPlacement(glyph: '⭐', dx: 0.3, dy: 0.3));
    cubit.addSticker(const StickerPlacement(glyph: '❤️', dx: 0.6, dy: 0.6));
    cubit.removeSticker(0);
    expect(cubit.state.draft.stickers, hasLength(1));
    expect(cubit.state.draft.stickers.single.glyph, '❤️');
    addTearDown(cubit.close);
  });

  test('save surfaces an error when the preview is not mounted', () async {
    // Without a mounted RepaintBoundary the capture fails; save must recover
    // (not throw) and surface an error rather than mark saved. The happy-path
    // capture is exercised by a widget test where the preview is on screen.
    final cubit = build();
    await cubit.save();
    expect(cubit.state.saving, isFalse);
    expect(cubit.state.saved, isFalse);
    expect(cubit.state.errorMessage, isNotNull);
    addTearDown(cubit.close);
  });
}

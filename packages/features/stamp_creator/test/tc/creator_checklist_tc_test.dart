// Unit/widget coverage for `product-spec/005..009 + 026` test-cases
// (photo → filter → decorate → border → save, monthly quota). TC ids map to
// the docs; camera/gallery journeys stay E2E per the docs.
import 'dart:typed_data';

import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:feature_stamp_creator/feature_stamp_creator.dart';
import 'package:feature_stamp_creator/src/data/stamp_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

class _FakeUploader implements StampUploader {
  _FakeUploader({this.quota403 = false});

  final bool quota403;

  @override
  Future<String> upload(Uint8List pngBytes) async {
    if (quota403) {
      throw DioException(
        requestOptions: RequestOptions(path: '/presign'),
        response: Response(
          requestOptions: RequestOptions(path: '/presign'),
          statusCode: 403,
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return 'https://cdn/stamp.png';
  }
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
  Future<Result<Stamp>> rename(String id, String name) async =>
      const Err(UnknownFailure());

  @override
  Future<Result<void>> delete(String id) async => const Ok(null);
}

CreatorCubit _build({
  bool premium = false,
  StampUploader? uploader,
  StampsRepository? stamps,
}) => CreatorCubit(
  imagePath: '/tmp/p.jpg',
  isPremium: premium,
  uploader: uploader ?? _FakeUploader(),
  stamps: stamps ?? _FakeStamps(),
);

/// Mounts the cubit's RepaintBoundary so `save()` can capture a PNG.
Future<void> _mountBoundary(WidgetTester tester, CreatorCubit cubit) async {
  await tester.pumpWidget(
    MaterialApp(
      home: RepaintBoundary(
        key: cubit.repaintKey,
        child: const ColoredBox(
          color: Colors.orange,
          child: SizedBox(width: 40, height: 48),
        ),
      ),
    ),
  );
}

void main() {
  // ── 006 · bộ lọc màu ─────────────────────────────────────────────────────
  group('Filter catalog (TC-06-xxx)', () {
    test('TC-06: đúng 16 bộ lọc — 8 miễn phí, 8 Premium, 4 nhóm', () {
      expect(stampFilters.length, 16);
      expect(stampFilters.where((f) => !f.premium).length, 8);
      expect(stampFilters.where((f) => f.premium).length, 8);
      expect(stampFilters.map((f) => f.category).toSet().length, 4);
    });

    test('TC-06: chọn bộ lọc cập nhật bản nháp ngay', () {
      final cubit = _build();
      final anyFilter = stampFilters[1].id;
      cubit.selectFilter(anyFilter);
      expect(cubit.state.draft.filterId, anyFilter);
      addTearDown(cubit.close);
    });

    test('filterById rơi về bộ lọc đầu khi id lạ (không crash)', () {
      expect(filterById('nope').id, stampFilters.first.id);
    });
  });

  // ── 007 · trang trí sticker ─────────────────────────────────────────────
  group('Stickers (TC-07-xxx)', () {
    test('TC-07: thêm/sửa/xoá sticker trên bản nháp', () {
      final cubit = _build();
      cubit.addSticker(
        const StickerPlacement(glyph: '🌸', dx: 0.5, dy: 0.5),
      );
      expect(cubit.state.draft.stickers, hasLength(1));

      cubit.updateSticker(
        0,
        const StickerPlacement(glyph: '🌸', dx: 0.8, dy: 0.2, scale: 1.4),
      );
      expect(cubit.state.draft.stickers.first.dx, 0.8);
      expect(cubit.state.draft.stickers.first.scale, 1.4);

      cubit.removeSticker(0);
      expect(cubit.state.draft.stickers, isEmpty);
      addTearDown(cubit.close);
    });
  });

  // ── 008 · viền khung tem ────────────────────────────────────────────────
  group('Borders (TC-08-xxx)', () {
    test('TC-08: 7 viền — 3 miễn phí, 4 Premium', () {
      expect(stampBorders.length, 7);
      expect(stampBorders.where((b) => !b.premium).length, 3);
      expect(stampBorders.where((b) => b.premium).length, 4);
    });

    test('TC-08: chọn viền cập nhật bản nháp', () {
      final cubit = _build();
      cubit.selectBorder('gold');
      expect(cubit.state.draft.borderId, 'gold');
      addTearDown(cubit.close);
    });
  });

  // ── 009 · lưu tem ───────────────────────────────────────────────────────
  group('Save (TC-09-xxx)', () {
    testWidgets('TC-09-001: lưu thành công → saved + đẩy đúng URL đã upload',
        (tester) async {
      final stamps = _FakeStamps();
      final cubit = _build(stamps: stamps);
      await _mountBoundary(tester, cubit);

      await tester.runAsync(cubit.save);

      expect(cubit.state.saved, isTrue);
      expect(cubit.state.errorMessage, isNull);
      expect(stamps.saved?.imageUrl, 'https://cdn/stamp.png');
      expect(stamps.saved?.source, StampSource.created);
      await cubit.close();
    });

    testWidgets('TC-09 double-tap: đang lưu thì lần bấm sau bị bỏ qua',
        (tester) async {
      final stamps = _FakeStamps();
      final cubit = _build(stamps: stamps);
      await _mountBoundary(tester, cubit);

      await tester.runAsync(() async {
        await Future.wait([cubit.save(), cubit.save()]);
      });

      expect(cubit.state.saved, isTrue);
      await cubit.close();
    });
  });

  // ── 026 · giới hạn tháng ────────────────────────────────────────────────
  group('Monthly quota (TC-26-xxx)', () {
    testWidgets('TC-26: 403 khi hết quota → thông báo nâng cấp Premium',
        (tester) async {
      final cubit = _build(uploader: _FakeUploader(quota403: true));
      await _mountBoundary(tester, cubit);

      await tester.runAsync(cubit.save);

      expect(cubit.state.saved, isFalse);
      expect(cubit.state.saving, isFalse);
      expect(
        cubit.state.errorMessage,
        'Bạn đã đạt giới hạn tem tháng này. Nâng cấp Premium để tạo thêm.',
      );
      await cubit.close();
    });
  });
}

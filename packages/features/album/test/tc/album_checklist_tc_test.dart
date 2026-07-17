// Unit coverage for `product-spec/020-album-suu-tap` test-cases (SM-022).
import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStamps implements StampsRepository {
  _FakeStamps({this.stamps = const [], this.fail = false});

  final List<Stamp> stamps;
  final bool fail;

  @override
  Future<Result<List<Stamp>>> list() async =>
      fail ? const Err(UnknownFailure()) : Ok(stamps);
  @override
  Future<Result<List<Stamp>>> listLocal() => list();
  @override
  Future<Result<Stamp>> get(String id) async => const Err(NotFoundFailure());
  @override
  Future<Result<Stamp>> save(StampInput input) async =>
      const Err(UnknownFailure());
  @override
  Future<Result<void>> delete(String id) async => const Ok(null);
}

Stamp _stamp(String id, {StampSource source = StampSource.created}) => Stamp(
  id: id,
  imageUrl: 'https://cdn/$id.png',
  source: source,
  createdAt: DateTime(2026, 7),
);

void main() {
  group('AlbumCubit (TC-20-xxx)', () {
    test('TC-20-001: tải album thành công — một danh sách phẳng các tem',
        () async {
      // SM-022 BR-01: the Album holds the user's own stamps + saved sample
      // stamps in one flat list. Received stamps are never in the Album
      // (SM-017 BR-05), so nothing here carries StampSource.received.
      final cubit = AlbumCubit(
        _FakeStamps(stamps: [_stamp('s1'), _stamp('s2')]),
      );
      await cubit.load();

      expect(cubit.state.loading, isFalse);
      expect(cubit.state.error, isFalse);
      expect(cubit.state.stamps, hasLength(2));
      expect(
        cubit.state.stamps.every((s) => s.source != StampSource.received),
        isTrue,
        reason: 'received stamps must never appear in the Album (BR-01)',
      );
    });

    test('TC-20 album trống → isEmpty (hiện trạng thái trống F02-S19)',
        () async {
      final cubit = AlbumCubit(_FakeStamps());
      await cubit.load();
      expect(cubit.state.isEmpty, isTrue);
    });

    test('TC-20 lỗi tải → error + có thể thử lại', () async {
      final cubit = AlbumCubit(_FakeStamps(fail: true));
      await cubit.load();
      expect(cubit.state.error, isTrue);
      expect(cubit.state.loading, isFalse);
    });
  });
}

// Unit coverage for `product-spec/020-album-suu-tap` test-cases (SM-022).
import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support.dart';

class _FakeStamps implements StampsRepository {
  _FakeStamps({this.stamps = const [], this.fail = false});

  final List<Stamp> stamps;
  final bool fail;

  /// Records the writes that actually reached the repository, so a test can
  /// assert an offline write never got there (SM-022 BR-11 / AC-10).
  final writes = <String>[];

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
  Future<Result<Stamp>> rename(String id, String name) async {
    writes.add('rename:$id');
    return const Err(NotFoundFailure());
  }

  @override
  Future<Result<void>> delete(String id) async {
    writes.add('delete:$id');
    return const Ok(null);
  }
}

Stamp _stamp(String id, {StampSource source = StampSource.created}) => Stamp(
  id: id,
  imageUrl: 'https://cdn/$id.png',
  source: source,
  createdAt: DateTime(2026, 7),
);

void main() {
  late FakeConnectivity connectivity;

  setUp(() => connectivity = FakeConnectivity());
  tearDown(() => connectivity.dispose());

  group('AlbumCubit (TC-20-xxx)', () {
    test(
      'TC-20-001: tải album thành công — một danh sách phẳng các tem',
      () async {
        // SM-022 BR-01: the Album holds the user's own stamps + saved sample
        // stamps in one flat list. Received stamps are never in the Album
        // (SM-017 BR-05), so nothing here carries StampSource.received.
        final cubit = AlbumCubit(
          _FakeStamps(stamps: [_stamp('s1'), _stamp('s2')]),
          connectivity,
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
      },
    );

    test(
      'TC-20 album trống → isEmpty (hiện trạng thái trống F02-S19)',
      () async {
        final cubit = AlbumCubit(_FakeStamps(), connectivity);
        await cubit.load();
        expect(cubit.state.isEmpty, isTrue);
      },
    );

    test('TC-20 lỗi tải → error + có thể thử lại', () async {
      final cubit = AlbumCubit(_FakeStamps(fail: true), connectivity);
      await cubit.load();
      expect(cubit.state.error, isTrue);
      expect(cubit.state.loading, isFalse);
    });

    test(
      'TC-20 AC-09: mất mạng → vẫn thấy tem đã tải + cờ ngoại tuyến',
      () async {
        connectivity.online = false;
        final cubit = AlbumCubit(
          _FakeStamps(stamps: [_stamp('s1'), _stamp('s2')]),
          connectivity,
        );

        await cubit.load();

        expect(cubit.state.stamps, hasLength(2));
        expect(cubit.state.error, isFalse);
        expect(cubit.state.isOffline, isTrue);
      },
    );

    test('TC-20 AC-10: mất mạng → đổi tên và xoá bị chặn', () async {
      connectivity.online = false;
      final repo = _FakeStamps(stamps: [_stamp('s1')]);
      final cubit = AlbumCubit(repo, connectivity);
      await cubit.load();

      await cubit.rename('s1', 'Tên mới');
      await cubit.delete('s1');

      expect(cubit.state.canMutate, isFalse);
      expect(repo.writes, isEmpty);
      expect(cubit.state.stamps, hasLength(1));
    });
  });
}

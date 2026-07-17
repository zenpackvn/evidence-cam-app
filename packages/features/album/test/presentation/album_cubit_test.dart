import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support.dart';

/// A hand-rolled fake (no mock framework, per repo convention).
class _FakeStampsRepository implements StampsRepository {
  _FakeStampsRepository({this.stamps = const [], this.fail = false});

  List<Stamp> stamps;
  bool fail;
  final deleted = <String>[];
  final renamed = <String, String>{};

  @override
  Future<Result<List<Stamp>>> list() async =>
      fail ? const Err(UnknownFailure()) : Ok(stamps);

  @override
  Future<Result<List<Stamp>>> listLocal() async => Ok(stamps);

  @override
  Future<Result<Stamp>> get(String id) async =>
      Ok(stamps.firstWhere((s) => s.id == id));

  @override
  Future<Result<Stamp>> save(StampInput input) async => const Err(UnknownFailure());

  @override
  Future<Result<Stamp>> rename(String id, String name) async {
    renamed[id] = name;
    final s = stamps.firstWhere((s) => s.id == id);
    return Ok(
      Stamp(
        id: s.id,
        imageUrl: s.imageUrl,
        name: name,
        source: s.source,
        createdAt: s.createdAt,
      ),
    );
  }

  @override
  Future<Result<void>> delete(String id) async {
    deleted.add(id);
    stamps = stamps.where((s) => s.id != id).toList();
    return const Ok(null);
  }
}

Stamp _stamp(String id) => Stamp(
  id: id,
  imageUrl: 'https://cdn/$id.png',
  source: StampSource.created,
  createdAt: DateTime(2026, 7, 10),
);

void main() {
  late FakeConnectivity connectivity;

  setUp(() => connectivity = FakeConnectivity());
  tearDown(() => connectivity.dispose());

  AlbumCubit build(_FakeStampsRepository repo) {
    final cubit = AlbumCubit(repo, connectivity);
    addTearDown(cubit.close);
    return cubit;
  }

  test('load emits the stamps and clears loading', () async {
    final cubit = build(
      _FakeStampsRepository(stamps: [_stamp('a'), _stamp('b')]),
    );
    await cubit.load();
    expect(cubit.state.loading, isFalse);
    expect(cubit.state.stamps, hasLength(2));
    expect(cubit.state.isEmpty, isFalse);
  });

  test('load with no stamps is the empty state', () async {
    final cubit = build(_FakeStampsRepository());
    await cubit.load();
    expect(cubit.state.isEmpty, isTrue);
  });

  test('load failure sets the error flag', () async {
    final cubit = build(_FakeStampsRepository(fail: true));
    await cubit.load();
    expect(cubit.state.error, isTrue);
    expect(cubit.state.loading, isFalse);
  });

  test('delete removes the stamp from state', () async {
    final repo = _FakeStampsRepository(stamps: [_stamp('a'), _stamp('b')]);
    final cubit = build(repo);
    await cubit.load();
    await cubit.delete('a');
    expect(cubit.state.stamps.map((s) => s.id), ['b']);
    expect(repo.deleted, ['a']);
  });

  test('rename updates the stamp name in state (BR-08 / AC-06)', () async {
    final repo = _FakeStampsRepository(stamps: [_stamp('a'), _stamp('b')]);
    final cubit = build(repo);
    await cubit.load();
    await cubit.rename('a', 'Tem biển');
    expect(repo.renamed['a'], 'Tem biển');
    expect(
      cubit.state.stamps.firstWhere((s) => s.id == 'a').name,
      'Tem biển',
    );
    // The other stamp is untouched.
    expect(cubit.state.stamps.firstWhere((s) => s.id == 'b').name, '');
  });

  test('setViewMode toggles grid/list (BR-04)', () async {
    final cubit = build(_FakeStampsRepository());
    expect(cubit.state.viewMode, AlbumViewMode.grid);
    cubit.setViewMode(AlbumViewMode.list);
    expect(cubit.state.viewMode, AlbumViewMode.list);
  });

  group('offline (BR-10 / BR-11)', () {
    test('load offline still lists the cached stamps and flags isOffline '
        '(BR-10 / AC-09)', () async {
      connectivity.online = false;
      final cubit = build(
        _FakeStampsRepository(stamps: [_stamp('a'), _stamp('b')]),
      );

      await cubit.load();

      expect(cubit.state.isOffline, isTrue);
      // BR-10: the list still renders from the local store.
      expect(cubit.state.stamps, hasLength(2));
      expect(cubit.state.error, isFalse);
      expect(cubit.state.canMutate, isFalse);
    });

    test('load online clears isOffline', () async {
      final cubit = build(_FakeStampsRepository(stamps: [_stamp('a')]));

      await cubit.load();

      expect(cubit.state.isOffline, isFalse);
      expect(cubit.state.canMutate, isTrue);
    });

    test('a connectivity drop flips isOffline without touching the list', () async {
      final cubit = build(_FakeStampsRepository(stamps: [_stamp('a')]));
      await cubit.load();
      expect(cubit.state.isOffline, isFalse);

      connectivity.goOffline();
      await pumpEventQueue();

      expect(cubit.state.isOffline, isTrue);
      expect(cubit.state.stamps, hasLength(1));
    });

    test('regaining the link clears isOffline and re-enables writes', () async {
      connectivity.online = false;
      final cubit = build(_FakeStampsRepository(stamps: [_stamp('a')]));
      await cubit.load();
      expect(cubit.state.canMutate, isFalse);

      connectivity.goOnline();
      await pumpEventQueue();

      expect(cubit.state.isOffline, isFalse);
      expect(cubit.state.canMutate, isTrue);
    });

    test('rename is refused while offline (BR-11 / AC-10)', () async {
      connectivity.online = false;
      final repo = _FakeStampsRepository(stamps: [_stamp('a')]);
      final cubit = build(repo);
      await cubit.load();

      await cubit.rename('a', 'Tem biển');

      // The repository is never reached and the name is unchanged.
      expect(repo.renamed, isEmpty);
      expect(cubit.state.stamps.single.name, '');
    });

    test('delete is refused while offline (BR-11 / AC-10)', () async {
      connectivity.online = false;
      final repo = _FakeStampsRepository(stamps: [_stamp('a'), _stamp('b')]);
      final cubit = build(repo);
      await cubit.load();

      await cubit.delete('a');

      expect(repo.deleted, isEmpty);
      expect(cubit.state.stamps, hasLength(2));
    });

    test('writes go through again once the link returns', () async {
      connectivity.online = false;
      final repo = _FakeStampsRepository(stamps: [_stamp('a')]);
      final cubit = build(repo);
      await cubit.load();
      await cubit.delete('a');
      expect(repo.deleted, isEmpty);

      connectivity.goOnline();
      await pumpEventQueue();
      await cubit.delete('a');

      expect(repo.deleted, ['a']);
    });
  });
}

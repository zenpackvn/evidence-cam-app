import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake (no mock framework, per repo convention).
class _FakeStampsRepository implements StampsRepository {
  _FakeStampsRepository({this.stamps = const [], this.fail = false});

  List<Stamp> stamps;
  bool fail;
  final deleted = <String>[];

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
  test('load emits the stamps and clears loading', () async {
    final cubit = AlbumCubit(
      _FakeStampsRepository(stamps: [_stamp('a'), _stamp('b')]),
    );
    await cubit.load();
    expect(cubit.state.loading, isFalse);
    expect(cubit.state.stamps, hasLength(2));
    expect(cubit.state.isEmpty, isFalse);
    addTearDown(cubit.close);
  });

  test('load with no stamps is the empty state', () async {
    final cubit = AlbumCubit(_FakeStampsRepository());
    await cubit.load();
    expect(cubit.state.isEmpty, isTrue);
    addTearDown(cubit.close);
  });

  test('load failure sets the error flag', () async {
    final cubit = AlbumCubit(_FakeStampsRepository(fail: true));
    await cubit.load();
    expect(cubit.state.error, isTrue);
    expect(cubit.state.loading, isFalse);
    addTearDown(cubit.close);
  });

  test('delete removes the stamp from state', () async {
    final repo = _FakeStampsRepository(stamps: [_stamp('a'), _stamp('b')]);
    final cubit = AlbumCubit(repo);
    await cubit.load();
    await cubit.delete('a');
    expect(cubit.state.stamps.map((s) => s.id), ['b']);
    expect(repo.deleted, ['a']);
    addTearDown(cubit.close);
  });
}

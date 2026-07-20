import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSamples implements SampleStampsRepository {
  _FakeSamples({this.items = const [], this.fail = false});

  final List<SampleStamp> items;
  final bool fail;

  @override
  Future<Result<List<SampleStamp>>> list({String? theme}) async =>
      fail ? const Err(UnknownFailure()) : Ok(items);
}

class _FakeStamps implements StampsRepository {
  final saved = <String>[];

  @override
  Future<Result<Stamp>> save(StampInput input) async {
    saved.add(input.id ?? '<minted>');
    return Ok(
      Stamp(
        id: input.id ?? 'x',
        imageUrl: input.imageUrl,
        source: input.source,
        createdAt: DateTime(2026, 7),
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
      const Err(NotFoundFailure());
  @override
  Future<Result<void>> delete(String id) async => const Ok(null);
}

SampleStamp _sample(String id, String theme, {bool isNew = false}) =>
    SampleStamp(
      id: id,
      imageUrl: 'https://cdn/$id.png',
      thumbUrl: 'https://cdn/${id}_t.png',
      theme: theme,
      isNew: isNew,
    );

void main() {
  test('load exposes the catalog and its distinct themes', () async {
    final cubit = SampleStampsCubit(
      _FakeSamples(
        items: [
          _sample('a', 'Sinh nhật'),
          _sample('b', 'Sinh nhật'),
          _sample('c', 'Bạn bè'),
        ],
      ),
      _FakeStamps(),
    );
    await cubit.load();
    expect(cubit.state.loading, isFalse);
    expect(cubit.state.all, hasLength(3));
    expect(cubit.state.themes, ['Sinh nhật', 'Bạn bè']);
    addTearDown(cubit.close);
  });

  test('selectTheme filters the visible list (AC-01)', () async {
    final cubit = SampleStampsCubit(
      _FakeSamples(
        items: [_sample('a', 'Sinh nhật'), _sample('c', 'Bạn bè')],
      ),
      _FakeStamps(),
    );
    await cubit.load();
    cubit.selectTheme('Sinh nhật');
    expect(cubit.state.visible.map((s) => s.id), ['a']);
    cubit.selectTheme(null);
    expect(cubit.state.visible, hasLength(2));
    addTearDown(cubit.close);
  });

  test('save uses the sample id and marks it saved (BR-03/AC-05)', () async {
    final stamps = _FakeStamps();
    final cubit = SampleStampsCubit(
      _FakeSamples(items: [_sample('a', 'Sinh nhật')]),
      stamps,
    );
    await cubit.load();
    await cubit.save(_sample('a', 'Sinh nhật'));
    expect(stamps.saved, ['a']);
    expect(cubit.state.savedIds, contains('a'));

    // Saving the same sample again is a no-op (no second save call).
    await cubit.save(_sample('a', 'Sinh nhật'));
    expect(stamps.saved, ['a']);
    addTearDown(cubit.close);
  });

  test('load failure sets the error flag', () async {
    final cubit = SampleStampsCubit(_FakeSamples(fail: true), _FakeStamps());
    await cubit.load();
    expect(cubit.state.error, isTrue);
    addTearDown(cubit.close);
  });
}

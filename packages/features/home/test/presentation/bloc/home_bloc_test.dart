import 'package:feature_home/feature_home.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';

import '../../support.dart';

void main() {
  late FakeConnectivity connectivity;

  setUp(() => connectivity = FakeConnectivity());
  tearDown(() => connectivity.dispose());

  group('HomeBloc', () {
    test('initial state is loading with empty data', () async {
      final bloc = HomeBloc(_StubLoader(HomeData.empty), connectivity);

      expect(bloc.state.isLoading, true);
      expect(bloc.state.data.isEmpty, true);

      await bloc.close();
    });

    test('maps loaded data into state', () async {
      final data = HomeData(
        recentStamps: [
          StampRef(
            id: 's1',
            imageUrl: 'https://cdn/s1.png',
            createdAt: DateTime.utc(2026, 5, 20),
          ),
        ],
        recentLetters: const [
          HomeLetterItem(
            id: 'l1',
            title: 'Thư gửi qua Zalo',
            meta: 'Đã mở · 20/05/2026',
            opened: true,
          ),
        ],
      );
      final bloc = HomeBloc(_StubLoader(data), connectivity)
        ..add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);

      expect(bloc.state.data.recentStamps.single.id, 's1');
      expect(bloc.state.data.recentLetters.single.opened, true);
      expect(bloc.state.data.isEmpty, false);
      expect(bloc.state.error, isNull);
      expect(bloc.state.isOffline, false);

      await bloc.close();
    });

    test('failure keeps previous data and sets error (BR-06)', () async {
      final bloc = HomeBloc(_ThrowingLoader(), connectivity)
        ..add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);

      expect(bloc.state.error, isNotNull);
      expect(bloc.state.data.isEmpty, true);

      await bloc.close();
    });
  });

  group('HomeBloc offline (BR-06 / BR-07)', () {
    test('the initial load offline still fills from the cache and flags '
        'isOffline (BR-06 / AC-05)', () async {
      connectivity.online = false;
      final bloc = HomeBloc(_StubLoader(_loaded()), connectivity)
        ..add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);

      // BR-06: the offline-first loader still fills the screen — no blank, no
      // full-page error.
      expect(bloc.state.data.isEmpty, false);
      expect(bloc.state.error, isNull);
      expect(bloc.state.isOffline, true);
      expect(bloc.state.canRefresh, false);

      await bloc.close();
    });

    test('a refresh offline is a no-op: data is kept, no error (AC-06)',
        () async {
      final loader = _CountingLoader(_loaded());
      final bloc = HomeBloc(loader, connectivity)
        ..add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);
      expect(loader.calls, 1);
      final loadedData = bloc.state.data;

      connectivity.goOffline();
      await bloc.stream.firstWhere((state) => state.isOffline);
      bloc.add(const HomeLoadRequested(isRefresh: true));
      await pumpEventQueue();

      // The loader was never reached again; the data is untouched.
      expect(loader.calls, 1);
      expect(bloc.state.data, same(loadedData));
      expect(bloc.state.error, isNull);
      expect(bloc.state.isOffline, true);
      expect(bloc.state.isLoading, false);

      await bloc.close();
    });

    test('a refresh online reloads as usual', () async {
      final loader = _CountingLoader(_loaded());
      final bloc = HomeBloc(loader, connectivity)
        ..add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);

      bloc.add(const HomeLoadRequested(isRefresh: true));
      await pumpEventQueue();

      expect(loader.calls, 2);
      expect(bloc.state.isOffline, false);

      await bloc.close();
    });

    test('a connectivity drop flips isOffline without losing the data '
        '(BR-06)', () async {
      final bloc = HomeBloc(_StubLoader(_loaded()), connectivity)
        ..add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);
      final loadedData = bloc.state.data;

      connectivity.goOffline();
      await bloc.stream.firstWhere((state) => state.isOffline);

      expect(bloc.state.isOffline, true);
      expect(bloc.state.data, same(loadedData));

      await bloc.close();
    });

    test('regaining the link clears isOffline and re-enables refresh',
        () async {
      connectivity.online = false;
      final bloc = HomeBloc(_StubLoader(_loaded()), connectivity)
        ..add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);
      expect(bloc.state.canRefresh, false);

      connectivity.goOnline();
      await bloc.stream.firstWhere((state) => !state.isOffline);

      expect(bloc.state.isOffline, false);
      expect(bloc.state.canRefresh, true);

      await bloc.close();
    });
  });
}

HomeData _loaded() => HomeData(
  recentStamps: [
    StampRef(
      id: 's1',
      imageUrl: 'https://cdn/s1.png',
      createdAt: DateTime.utc(2026, 5, 20),
    ),
  ],
);

class _StubLoader implements HomeDataLoader {
  _StubLoader(this.data);

  final HomeData data;

  @override
  Future<HomeData> load() async => data;
}

/// Counts loads so a test can assert an offline refresh never reached it.
class _CountingLoader implements HomeDataLoader {
  _CountingLoader(this.data);

  final HomeData data;
  int calls = 0;

  @override
  Future<HomeData> load() async {
    calls++;
    return data;
  }
}

class _ThrowingLoader implements HomeDataLoader {
  @override
  Future<HomeData> load() async => throw Exception('offline');
}

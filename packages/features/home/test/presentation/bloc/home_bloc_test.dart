import 'package:feature_home/feature_home.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';

void main() {
  group('HomeBloc', () {
    test('initial state is loading with empty data', () async {
      final bloc = HomeBloc(_StubLoader(HomeData.empty));

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
      final bloc = HomeBloc(_StubLoader(data))..add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);

      expect(bloc.state.data.recentStamps.single.id, 's1');
      expect(bloc.state.data.recentLetters.single.opened, true);
      expect(bloc.state.data.isEmpty, false);
      expect(bloc.state.error, isNull);

      await bloc.close();
    });

    test('failure keeps previous data and sets error (BR-06)', () async {
      final bloc = HomeBloc(_ThrowingLoader())..add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);

      expect(bloc.state.error, isNotNull);
      expect(bloc.state.data.isEmpty, true);

      await bloc.close();
    });
  });
}

class _StubLoader implements HomeDataLoader {
  _StubLoader(this.data);

  final HomeData data;

  @override
  Future<HomeData> load() async => data;
}

class _ThrowingLoader implements HomeDataLoader {
  @override
  Future<HomeData> load() async => throw Exception('offline');
}

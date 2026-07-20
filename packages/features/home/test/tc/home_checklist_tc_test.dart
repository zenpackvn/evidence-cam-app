// Unit/widget coverage for `product-spec/004-man-hinh-chinh` test-cases
// (SM-004: greeting, recent stamps/letters, empty invite).
import 'package:feature_home/feature_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rev_sync/rev_sync.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:shared_ui/shared_ui.dart';

import '../support.dart';

class _Loader implements HomeDataLoader {
  _Loader(this.data);
  final HomeData data;
  @override
  Future<HomeData> load() async => data;
}

class _ThrowingLoader implements HomeDataLoader {
  @override
  Future<HomeData> load() async => throw Exception('mạng rớt');
}

class _Session extends ChangeNotifier implements Session {
  _Session(this.currentUser);
  @override
  final AuthUser? currentUser;
  @override
  bool get isSigningOut => false;
  @override
  Future<void> restore() async {}
  @override
  void signOut() {}
  @override
  void clearSession() {}
}

HomeData _loaded() => HomeData(
  recentStamps: [
    StampRef(
      id: 's1',
      imageUrl: 'https://cdn/s1.png',
      createdAt: DateTime(2024, 5, 20),
      name: 'Tulip nở hồng',
    ),
  ],
  recentLetters: const [
    HomeLetterItem(
      id: 'l1',
      title: 'Cảm ơn mẹ yêu ❤️',
      meta: 'Gửi đến Mẹ  ·  20/05/2024',
      opened: true,
    ),
  ],
);

Widget _wrap(
  HomeDataLoader loader,
  ConnectivitySource connectivity, {
  String username = 'sunny',
}) {
  return MaterialApp(
    home: SessionScope(
      session: _Session(AuthUser(id: 'u1', username: username)),
      child: BlocProvider(
        create: (_) =>
            HomeBloc(loader, connectivity)..add(const HomeLoadRequested()),
        child: const HomeBody(),
      ),
    ),
  );
}

void main() {
  late FakeConnectivity connectivity;

  setUp(() => connectivity = FakeConnectivity());
  tearDown(() => connectivity.dispose());

  group('HomeBloc (TC-04-xxx)', () {
    test('TC-04: load thành công → data hiển thị, hết loading', () async {
      final bloc = HomeBloc(_Loader(_loaded()), connectivity)
        ..add(const HomeLoadRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.data.recentStamps, hasLength(1));
      await bloc.close();
    });

    test('TC-04 lỗi tải → error, không kẹt loading', () async {
      final bloc = HomeBloc(_ThrowingLoader(), connectivity)
        ..add(const HomeLoadRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.error, isNotNull);
      await bloc.close();
    });

    test(
      'TC-04 AC-05: mất mạng → giữ nội dung đã tải + cờ ngoại tuyến',
      () async {
        connectivity.online = false;
        final bloc = HomeBloc(_Loader(_loaded()), connectivity)
          ..add(const HomeLoadRequested());
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.data.recentStamps, hasLength(1));
        expect(bloc.state.error, isNull);
        expect(bloc.state.isOffline, isTrue);
        await bloc.close();
      },
    );

    test(
      'TC-04 AC-06: mất mạng → làm mới bị vô hiệu, dữ liệu không đổi',
      () async {
        connectivity.online = false;
        final bloc = HomeBloc(_Loader(_loaded()), connectivity)
          ..add(const HomeLoadRequested());
        await Future<void>.delayed(Duration.zero);
        final data = bloc.state.data;

        bloc.add(const HomeLoadRequested(isRefresh: true));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.canRefresh, isFalse);
        expect(bloc.state.data, same(data));
        expect(bloc.state.error, isNull);
        await bloc.close();
      },
    );
  });

  group('HomeBody (TC-04-xxx · F01-S15/S16)', () {
    testWidgets('TC-04: loaded — chào đúng tên, không có badge thư chưa đọc', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_Loader(_loaded()), connectivity));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Chào sunny 👋'), findsOneWidget);
      // SM-017 BR-10: thư nhận không lưu lại → không còn khái niệm chưa đọc.
      expect(find.byType(Badge), findsNothing);
      expect(find.text('Tem gần đây'), findsOneWidget);
      expect(find.text('Tulip nở hồng'), findsOneWidget);
      expect(find.text('Cảm ơn mẹ yêu ❤️'), findsOneWidget);
    });

    testWidgets('TC-04: empty — lời mời tạo tem đầu tiên (F01-S15)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_Loader(HomeData.empty), connectivity));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Bạn chưa có\nbức thư hay\ncon tem nào.'),
        findsOneWidget,
      );
      expect(find.text('Tạo tem đầu tiên'), findsOneWidget);
      expect(find.text('Chưa có thư nào'), findsOneWidget);
    });

    testWidgets(
      'TC-04: username rỗng → chào "bạn" (không crash — bug đã fix)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(_Loader(_loaded()), connectivity, username: ''),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Chào bạn 👋'), findsOneWidget);
      },
    );
  });
}

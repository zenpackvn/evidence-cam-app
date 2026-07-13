// Unit/widget coverage for `product-spec/004-man-hinh-chinh` test-cases
// (SM-004: greeting, unread badge, recent stamps/letters, empty invite).
import 'package:feature_home/feature_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:shared_ui/shared_ui.dart';

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
  unreadLetters: 3,
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

Widget _wrap(HomeDataLoader loader, {String username = 'sunny'}) {
  return MaterialApp(
    home: SessionScope(
      session: _Session(AuthUser(id: 'u1', username: username)),
      child: BlocProvider(
        create: (_) => HomeBloc(loader)..add(const HomeLoadRequested()),
        child: const HomeBody(),
      ),
    ),
  );
}

void main() {
  group('HomeBloc (TC-04-xxx)', () {
    test('TC-04: load thành công → data hiển thị, hết loading', () async {
      final bloc = HomeBloc(_Loader(_loaded()))
        ..add(const HomeLoadRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.data.unreadLetters, 3);
      await bloc.close();
    });

    test('TC-04 lỗi tải → error, không kẹt loading', () async {
      final bloc = HomeBloc(_ThrowingLoader())..add(const HomeLoadRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.error, isNotNull);
      await bloc.close();
    });
  });

  group('HomeBody (TC-04-xxx · F01-S15/S16)', () {
    testWidgets('TC-04: loaded — chào đúng tên + badge số thư chưa đọc',
        (tester) async {
      await tester.pumpWidget(_wrap(_Loader(_loaded())));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Chào sunny 👋'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Tem gần đây'), findsOneWidget);
      expect(find.text('Tulip nở hồng'), findsOneWidget);
      expect(find.text('Cảm ơn mẹ yêu ❤️'), findsOneWidget);
    });

    testWidgets('TC-04: empty — lời mời tạo tem đầu tiên (F01-S15)',
        (tester) async {
      await tester.pumpWidget(_wrap(_Loader(HomeData.empty)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Bạn chưa có\nbức thư hay\ncon tem nào.'), findsOneWidget);
      expect(find.text('Tạo tem đầu tiên'), findsOneWidget);
      expect(find.text('Chưa có thư nào'), findsOneWidget);
    });

    testWidgets('TC-04: username rỗng → chào "bạn" (không crash — bug đã fix)',
        (tester) async {
      await tester.pumpWidget(_wrap(_Loader(_loaded()), username: ''));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Chào bạn 👋'), findsOneWidget);
    });
  });
}

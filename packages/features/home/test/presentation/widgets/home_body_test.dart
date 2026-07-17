// Widget tests for the StampMail home dashboard (SM-004, F01-S15/S16): the
// empty-state hero invite and the loaded header/sections. Stamp cards render
// AppNetworkImage; the empty and letters-only branches avoid network fetches.

import 'dart:async';

import 'package:feature_home/feature_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../support.dart';

void main() {
  late FakeConnectivity connectivity;

  setUp(() => connectivity = FakeConnectivity());
  tearDown(() => connectivity.dispose());

  Future<void> pumpHome(
    WidgetTester tester, {
    required HomeData data,
    VoidCallback? onCreateStamp,
  }) async {
    final bloc = HomeBloc(_StubLoader(data), connectivity)
      ..add(const HomeLoadRequested());
    // Closed via unawaited fire-and-forget: awaiting Bloc.close() inside the
    // fake-async test zone (addTearDown) deadlocks — nothing pumps the
    // microtasks its stream-close futures need.
    addTearDown(() => unawaited(bloc.close()));

    await tester.pumpWidget(
      MaterialApp(
        home: SessionScope(
          session: FakeSession(
            currentUser: const AuthUser(id: 'u1', username: 'sunny'),
          ),
          child: BlocProvider.value(
            value: bloc,
            child: HomeBody(onCreateStamp: onCreateStamp),
          ),
        ),
      ),
    );
    // Two pumps: one for the load to complete (microtask), one to rebuild.
    await tester.pump();
    await tester.pump();
  }

  testWidgets('empty state shows greeting and first-stamp invite (BR-02)', (
    tester,
  ) async {
    var created = false;
    await pumpHome(
      tester,
      data: HomeData.empty,
      onCreateStamp: () => created = true,
    );

    expect(find.text('Chào sunny 👋'), findsOneWidget);
    expect(find.text('Tạo tem đầu tiên'), findsOneWidget);

    await tester.tap(find.text('Tạo tem đầu tiên'));
    expect(created, isTrue);
  });

  testWidgets('loaded state shows letter cards without any unread badge', (
    tester,
  ) async {
    const data = HomeData(
      recentLetters: [
        HomeLetterItem(
          id: 'l1',
          title: 'Thư gửi qua Zalo',
          meta: 'Đã mở · 20/05/2026',
          opened: true,
        ),
      ],
    );
    await pumpHome(tester, data: data);

    // SM-017 BR-10: no unread concept — the header has no badge.
    expect(find.byType(Badge), findsNothing);
    expect(find.text('Thư gửi qua Zalo'), findsOneWidget);
    expect(find.text('Tạo tem mới ✨'), findsOneWidget);
    expect(find.text('Tem gần đây'), findsOneWidget);
  });

  group('offline notice (BR-07 / AC-05)', () {
    const data = HomeData(
      recentLetters: [
        HomeLetterItem(
          id: 'l1',
          title: 'Thư gửi qua Zalo',
          meta: 'Đã mở · 20/05/2026',
          opened: true,
        ),
      ],
    );

    testWidgets('online shows no notice', (tester) async {
      await pumpHome(tester, data: data);

      expect(find.text(HomeBody.offlineLabel), findsNothing);
      expect(find.byType(OfflineBanner), findsNothing);
    });

    testWidgets('offline shows the notice above — not over — the loaded '
        'content (AC-05)', (tester) async {
      connectivity.online = false;
      await pumpHome(tester, data: data);

      expect(find.text(HomeBody.offlineLabel), findsOneWidget);
      // BR-06: the already-loaded content is still there.
      expect(find.text('Thư gửi qua Zalo'), findsOneWidget);
      expect(find.text('Tạo tem mới ✨'), findsOneWidget);

      // BR-07: the notice sits above the scroll area, obscuring nothing.
      final banner = tester.getRect(find.byType(OfflineBanner));
      final content = tester.getRect(find.text('Tạo tem mới ✨'));
      expect(banner.bottom, lessThanOrEqualTo(content.top));
    });

    testWidgets('the notice appears on a drop and clears on reconnect',
        (tester) async {
      await pumpHome(tester, data: data);
      expect(find.text(HomeBody.offlineLabel), findsNothing);

      connectivity.goOffline();
      await tester.pumpAndSettle();
      expect(find.text(HomeBody.offlineLabel), findsOneWidget);
      // BR-06: no blank screen, no full-page error.
      expect(find.text('Thư gửi qua Zalo'), findsOneWidget);

      connectivity.goOnline();
      await tester.pumpAndSettle();
      expect(find.text(HomeBody.offlineLabel), findsNothing);
    });

    testWidgets('offline, pull-to-refresh is disabled and keeps the data '
        '(AC-06)', (tester) async {
      connectivity.online = false;
      await pumpHome(tester, data: data);

      await tester.fling(find.text('Thư gửi qua Zalo'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      // The refresh gesture never engages: no spinner, notice still up, data
      // intact, and no full-page error.
      expect(find.byType(RefreshProgressIndicator), findsNothing);
      expect(find.text(HomeBody.offlineLabel), findsOneWidget);
      expect(find.text('Thư gửi qua Zalo'), findsOneWidget);
    });
  });
}

class _StubLoader implements HomeDataLoader {
  const _StubLoader(this.data);

  final HomeData data;

  @override
  Future<HomeData> load() async => data;
}

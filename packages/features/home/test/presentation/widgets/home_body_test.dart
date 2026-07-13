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
  Future<void> pumpHome(
    WidgetTester tester, {
    required HomeData data,
    VoidCallback? onCreateStamp,
  }) async {
    final bloc = HomeBloc(_StubLoader(data))..add(const HomeLoadRequested());
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

  testWidgets('loaded state shows unread badge and letter cards (BR-01)', (
    tester,
  ) async {
    const data = HomeData(
      unreadLetters: 3,
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

    expect(find.text('3'), findsOneWidget);
    expect(find.text('Thư gửi qua Zalo'), findsOneWidget);
    expect(find.text('Tạo tem mới ✨'), findsOneWidget);
    expect(find.text('Tem gần đây'), findsOneWidget);
  });
}

class _StubLoader implements HomeDataLoader {
  const _StubLoader(this.data);

  final HomeData data;

  @override
  Future<HomeData> load() async => data;
}

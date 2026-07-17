// Widget coverage for the Album's offline gating (SM-022 BR-10/BR-11,
// AC-09/AC-10): the "Đang xem ngoại tuyến" banner over the cached list, and
// the disabled rename/delete affordances on the stamp detail.

import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_ui/shared_ui.dart';

import '../support.dart';

// Empty imageUrl renders AppNetworkImage's error state synchronously — no
// network fetch, no pending timers — so the widget tests stay hermetic.
Stamp _stamp(String id, {String name = ''}) => Stamp(
  id: id,
  imageUrl: '',
  name: name,
  source: StampSource.created,
  createdAt: DateTime(2026, 7, 10),
);

class _FakeStamps implements StampsRepository {
  _FakeStamps({List<Stamp> stamps = const []}) : stamps = [...stamps];

  List<Stamp> stamps;

  @override
  Future<Result<List<Stamp>>> list() async => Ok(stamps);
  @override
  Future<Result<List<Stamp>>> listLocal() => list();
  @override
  Future<Result<Stamp>> get(String id) async => const Err(NotFoundFailure());
  @override
  Future<Result<Stamp>> save(StampInput input) async =>
      const Err(UnknownFailure());
  @override
  Future<Result<Stamp>> rename(String id, String name) async =>
      Ok(_stamp(id, name: name));
  @override
  Future<Result<void>> delete(String id) async {
    stamps = stamps.where((s) => s.id != id).toList();
    return const Ok(null);
  }
}

Widget _host(Widget child) => MaterialApp(theme: AppTheme.light(), home: child);

/// The stamp detail is laid out for a phone: the default 800x600 test surface
/// overflows its full-bleed stamp mat. Pin a realistic viewport instead.
void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  group('AlbumScreen offline banner (BR-10 / AC-09)', () {
    late FakeConnectivity connectivity;

    setUp(() {
      connectivity = FakeConnectivity();
      GetIt.instance.registerFactory<AlbumCubit>(
        () => AlbumCubit(
          _FakeStamps(stamps: [_stamp('a'), _stamp('b')]),
          connectivity,
        ),
      );
    });

    tearDown(() async {
      await GetIt.instance.reset();
      await connectivity.dispose();
    });

    testWidgets('offline shows the notice and still lists the cached stamps',
        (tester) async {
      connectivity.online = false;

      await tester.pumpWidget(_host(const AlbumScreen()));
      await tester.pumpAndSettle();

      expect(find.text(AlbumScreen.offlineLabel), findsOneWidget);
      expect(find.byType(OfflineBanner), findsOneWidget);
      // BR-10: the list is not replaced by the notice.
      expect(find.byType(AppNetworkImage), findsNWidgets(2));
    });

    testWidgets('online shows no notice', (tester) async {
      await tester.pumpWidget(_host(const AlbumScreen()));
      await tester.pumpAndSettle();

      expect(find.text(AlbumScreen.offlineLabel), findsNothing);
      expect(find.byType(AppNetworkImage), findsNWidgets(2));
    });

    testWidgets('the notice appears when the link drops and clears when it '
        'returns', (tester) async {
      await tester.pumpWidget(_host(const AlbumScreen()));
      await tester.pumpAndSettle();
      expect(find.text(AlbumScreen.offlineLabel), findsNothing);

      connectivity.goOffline();
      await tester.pumpAndSettle();
      expect(find.text(AlbumScreen.offlineLabel), findsOneWidget);

      connectivity.goOnline();
      await tester.pumpAndSettle();
      expect(find.text(AlbumScreen.offlineLabel), findsNothing);
    });

    testWidgets('offline, tapping delete on the detail reports the reconnect '
        'notice (AC-10)', (tester) async {
      _usePhoneViewport(tester);
      connectivity.online = false;

      await tester.pumpWidget(_host(const AlbumScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppNetworkImage).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Xoá con tem?'), findsNothing);
      expect(find.text(AlbumScreen.offlineActionMessage), findsOneWidget);
    });

    testWidgets('online, a rename from the detail updates the name there and '
        'in the list (AC-06)', (tester) async {
      _usePhoneViewport(tester);

      await tester.pumpWidget(_host(const AlbumScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppNetworkImage).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('10/07/2026').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Tem biển');
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      // The detail reflects the new name straight away.
      expect(find.text('Tem biển'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // ...and so does the list behind it (list mode surfaces stamp names).
      await tester.tap(find.byTooltip('Xem danh sách'));
      await tester.pumpAndSettle();
      expect(find.text('Tem biển'), findsOneWidget);
    });
  });

  group('StampDetailScreen write gating (BR-11 / AC-10)', () {
    testWidgets('offline, delete does not run and reports the block',
        (tester) async {
      _usePhoneViewport(tester);
      var deleted = false;
      var blocked = 0;

      await tester.pumpWidget(
        _host(StampDetailScreen(
          stamp: _stamp('a', name: 'Tem biển'),
          canMutate: false,
          onBack: () {},
          onDelete: () => deleted = true,
          onMutateBlocked: () => blocked++,
        )),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // No confirm dialog, no delete — just the reconnect notice.
      expect(find.text('Xoá con tem?'), findsNothing);
      expect(deleted, isFalse);
      expect(blocked, 1);
    });

    testWidgets('offline, rename does not run and reports the block',
        (tester) async {
      _usePhoneViewport(tester);
      String? renamed;
      var blocked = 0;

      await tester.pumpWidget(
        _host(StampDetailScreen(
          stamp: _stamp('a', name: 'Tem biển'),
          canMutate: false,
          onBack: () {},
          onRename: (name) => renamed = name,
          onMutateBlocked: () => blocked++,
        )),
      );

      await tester.tap(find.text('Tem biển'));
      await tester.pumpAndSettle();

      expect(find.text('Đổi tên tem'), findsNothing);
      expect(renamed, isNull);
      expect(blocked, 1);
    });

    testWidgets('online, delete opens the confirm dialog and never blocks',
        (tester) async {
      _usePhoneViewport(tester);
      var deleted = false;
      var blocked = 0;

      await tester.pumpWidget(
        _host(StampDetailScreen(
          stamp: _stamp('a', name: 'Tem biển'),
          onBack: () {},
          onDelete: () => deleted = true,
          onMutateBlocked: () => blocked++,
        )),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Xoá con tem?'), findsOneWidget);

      await tester.tap(find.text('Xoá'));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
      expect(blocked, 0);
    });

    testWidgets('online, rename opens the dialog and never blocks',
        (tester) async {
      _usePhoneViewport(tester);
      String? renamed;
      var blocked = 0;

      await tester.pumpWidget(
        _host(StampDetailScreen(
          stamp: _stamp('a', name: 'Tem biển'),
          onBack: () {},
          onRename: (name) => renamed = name,
          onMutateBlocked: () => blocked++,
        )),
      );

      await tester.tap(find.text('Tem biển'));
      await tester.pumpAndSettle();
      expect(find.text('Đổi tên tem'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Tên mới');
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      expect(renamed, 'Tên mới');
      expect(blocked, 0);
    });
  });
}

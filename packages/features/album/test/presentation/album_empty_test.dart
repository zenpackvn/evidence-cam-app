// SM-022 — the Album empty state (F02-S19 "Album — Empty"): when there are no
// stamps, show the illustration, the invite copy, and the "Tạo tem ngay" CTA.
import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../support.dart';

class _EmptyStamps implements StampsRepository {
  @override
  Future<Result<List<Stamp>>> list() async => const Ok([]);
  @override
  Future<Result<List<Stamp>>> listLocal() async => const Ok([]);
  @override
  Future<Result<Stamp>> get(String id) async => const Err(NotFoundFailure());
  @override
  Future<Result<Stamp>> save(StampInput input) async =>
      const Err(UnknownFailure());
  @override
  Future<Result<Stamp>> rename(String id, String name) async =>
      const Err(UnknownFailure());
  @override
  Future<Result<void>> delete(String id) async => const Ok(null);
}

void main() {
  late FakeConnectivity connectivity;

  setUp(() {
    connectivity = FakeConnectivity();
    GetIt.instance.registerFactory<AlbumCubit>(
      () => AlbumCubit(_EmptyStamps(), connectivity),
    );
  });

  tearDown(() async {
    await GetIt.instance.reset();
    await connectivity.dispose();
  });

  testWidgets('empty album shows the F02-S19 invite and CTA', (tester) async {
    var created = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: AlbumScreen(onCreate: () => created = true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Album của bạn đang trống'), findsOneWidget);
    expect(
      find.text('Tạo tem đầu tiên của bạn để bắt đầu sưu tầm nhé!'),
      findsOneWidget,
    );
    // The envelope illustration is present…
    expect(find.byType(Image), findsWidgets);

    // …and the CTA creates a stamp.
    await tester.tap(find.text('Tạo tem ngay'));
    expect(created, isTrue);
  });
}

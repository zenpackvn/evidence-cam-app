// SM-008/009 — the decorate step matches F02-S07: an elevated panel with three
// tabs (Sticker / Viền tem / Nền) over a tinted tool grid. The grids must lay
// out inside the fixed panel without overflow, and tapping "Nền" swatches sets
// the stamp paper colour.
import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:feature_stamp_creator/feature_stamp_creator.dart';
import 'package:feature_stamp_creator/src/data/stamp_uploader.dart';
import 'package:feature_stamp_creator/src/presentation/screens/decorate_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUploader implements StampUploader {
  @override
  Future<String> upload(Uint8List pngBytes) async => 'https://cdn/stamp.png';
}

class _FakeStamps implements StampsRepository {
  @override
  Future<Result<Stamp>> save(StampInput input) async =>
      const Err(UnknownFailure());
  @override
  Future<Result<List<Stamp>>> list() async => const Ok([]);
  @override
  Future<Result<List<Stamp>>> listLocal() async => const Ok([]);
  @override
  Future<Result<Stamp>> get(String id) async => const Err(NotFoundFailure());
  @override
  Future<Result<Stamp>> rename(String id, String name) async =>
      const Err(UnknownFailure());
  @override
  Future<Result<void>> delete(String id) async => const Ok(null);
}

Future<CreatorCubit> _pumpDecorate(WidgetTester tester) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final cubit = CreatorCubit(
    imagePath: '/tmp/nonexistent.jpg',
    isPremium: false,
    uploader: _FakeUploader(),
    stamps: _FakeStamps(),
  )..next(); // filter → decorate
  addTearDown(cubit.close);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: const SizedBox(height: 640, child: DecorateStep()),
        ),
      ),
    ),
  );
  await tester.pump();
  return cubit;
}

void main() {
  testWidgets('shows the three decorate tabs without overflow', (tester) async {
    await _pumpDecorate(tester);

    expect(find.text('Sticker'), findsOneWidget);
    expect(find.text('Viền tem'), findsOneWidget);
    expect(find.text('Nền'), findsOneWidget);
    // No RenderFlex overflow was thrown while laying out the panel/grid.
  });

  testWidgets('the Nền tab sets the stamp paper colour', (tester) async {
    final cubit = await _pumpDecorate(tester);
    expect(cubit.state.draft.paperColor, isNull);

    await tester.tap(find.text('Nền'));
    await tester.pump();
    // Tap the first paper swatch (top-left of the grid).
    await tester.tap(find.byType(InkWell).last);
    await tester.pump();

    expect(cubit.state.draft.paperColor, isNotNull);
  });
}

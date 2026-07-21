// SM-006 — the filter step's thumbnail row must fit the tool panel without
// overflow (the F02-S04 `thumbRow` is 70px tall with the label overlaid, not a
// box + label below), and the category chips carry the design labels.
import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:feature_stamp_creator/feature_stamp_creator.dart';
import 'package:feature_stamp_creator/src/data/stamp_uploader.dart';
import 'package:feature_stamp_creator/src/presentation/screens/filter_step.dart';
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

Future<CreatorCubit> _pumpFilterStep(WidgetTester tester) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final cubit = CreatorCubit(
    imagePath: '/tmp/nonexistent.jpg',
    isPremium: false,
    uploader: _FakeUploader(),
    stamps: _FakeStamps(),
  );
  addTearDown(cubit.close);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          // FilterStep uses Expanded, so it needs a bounded height like the
          // wizard body gives it. A RenderFlex overflow here fails the test.
          child: const SizedBox(height: 620, child: FilterStep()),
        ),
      ),
    ),
  );
  await tester.pump();
  return cubit;
}

void main() {
  testWidgets('renders the filter thumbnails without overflow', (tester) async {
    await _pumpFilterStep(tester);

    // The category chips use the design labels — the standalone "Gốc" tab
    // precedes the four groups (F02-S04 cats). Later chips (Tâm trạng / Mùa)
    // sit off-screen in the scrolling row, so they aren't asserted here.
    expect(find.text('Gốc'), findsWidgets);
    expect(find.text('Cổ điển'), findsOneWidget);
    expect(find.text('Retro/Vintage'), findsOneWidget);
    // …and the Classic category shows its filter thumbnails (label overlaid).
    expect(find.text('Đen trắng'), findsOneWidget);
    expect(find.text('Nâu cổ'), findsOneWidget);
    // No overflow error was thrown while laying the panel out.
  });

  testWidgets('the "Gốc" tab shows only the original', (tester) async {
    await _pumpFilterStep(tester);

    // Tapping the "Gốc" chip narrows the row to just the original — the classic
    // presets (e.g. "Đen trắng") drop away.
    await tester.tap(find.text('Gốc').first);
    await tester.pump();

    expect(find.text('Đen trắng'), findsNothing);
    expect(find.text('Nâu cổ'), findsNothing);
    expect(find.text('Gốc'), findsWidgets);
  });

  testWidgets('the "Chỉnh tay" tab shows the five adjust tools', (
    tester,
  ) async {
    await _pumpFilterStep(tester);

    await tester.tap(find.text('Chỉnh tay'));
    await tester.pump();

    // F02-S05 toolRow — five tool buttons, no overflow in the panel. (The
    // active tool's label — "Độ sáng" by default — also shows in the header.)
    expect(find.text('Độ sáng'), findsWidgets);
    expect(find.text('Tương phản'), findsOneWidget);
    expect(find.text('Ấm / Lạnh'), findsOneWidget);
    expect(find.text('Bão hòa'), findsOneWidget);
    expect(find.text('Độ nét'), findsOneWidget);
  });
}

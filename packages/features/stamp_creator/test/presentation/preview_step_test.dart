// SM-010 — the "Xem trước & hoàn thiện" (F02-S08) step shows the finished stamp
// above a finish form (name / tags / note). The form must render without
// overflow and feed edits back into the cubit.
import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:feature_album/feature_album.dart';
import 'package:feature_stamp_creator/feature_stamp_creator.dart';
import 'package:feature_stamp_creator/src/data/stamp_uploader.dart';
import 'package:feature_stamp_creator/src/presentation/screens/preview_step.dart';
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

Future<CreatorCubit> _pumpPreview(WidgetTester tester) async {
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
          // PreviewStep scrolls inside the wizard body's bounded height.
          child: const SizedBox(height: 620, child: PreviewStep()),
        ),
      ),
    ),
  );
  await tester.pump();
  return cubit;
}

void main() {
  testWidgets('renders the finish form fields', (tester) async {
    await _pumpPreview(tester);

    expect(find.text('Tên tem'), findsOneWidget);
    expect(find.text('Tags'), findsOneWidget);
    expect(find.text('Ghi chú'), findsOneWidget);
    // No overflow was thrown laying out the stamp + form.
  });

  testWidgets('typing the stamp name updates the cubit', (tester) async {
    final cubit = await _pumpPreview(tester);

    await tester.enterText(
      find.byType(TextField).first,
      'Bình minh Cappadocia',
    );
    await tester.pump();

    expect(cubit.state.name, 'Bình minh Cappadocia');
  });

  testWidgets('adding a tag through the dialog renders a chip', (tester) async {
    final cubit = await _pumpPreview(tester);

    // Open the "Thêm tag" dialog via the "+" button, type, and confirm. This
    // also guards against the dialog's controller being disposed while the
    // exit animation still references it.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'du lịch');
    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle();

    expect(cubit.state.tags, ['du lịch']);
    expect(find.text('du lịch'), findsOneWidget);
  });
}

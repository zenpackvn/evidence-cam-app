// SM-005 (F02-S11): the in-app "Chọn từ thư viện" flow guards on photo-library
// permission and an empty library before showing the grid.
import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:feature_stamp_creator/feature_stamp_creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGallery extends GalleryService {
  _FakeGallery({required this.granted});

  final bool granted;

  @override
  Future<bool> ensurePermission() async => granted;

  // GalleryImage wraps a plugin AssetEntity that can't be built in a unit test,
  // so the fake exercises the permission/empty branches with no images.
  @override
  Future<List<GalleryImage>> recentImages({int limit = 40}) async => const [];
}

Future<void> _pump(WidgetTester tester, GalleryService gallery) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: LibraryPickerFlow(gallery: gallery, onPicked: (_) {}),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('denied permission shows the access prompt', (tester) async {
    await _pump(tester, _FakeGallery(granted: false));

    expect(find.text('Chưa có quyền truy cập ảnh'), findsOneWidget);
    expect(find.text('Mở cài đặt'), findsOneWidget);
  });

  testWidgets('granted but empty library shows the empty state', (
    tester,
  ) async {
    await _pump(tester, _FakeGallery(granted: true));

    expect(find.text('Thư viện trống'), findsOneWidget);
  });
}

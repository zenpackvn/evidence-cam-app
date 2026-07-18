// Unit/widget coverage for `product-spec/002-ho-so-nguoi-dung` +
// `023-cai-dat-tai-khoan` test-cases (settings sub-screens, delete confirm).
import 'dart:typed_data';

import 'package:feature_profile/feature_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('LanguageScreen (TC-23 ngôn ngữ · F07-S08)', () {
    testWidgets('hiển thị 4 ngôn ngữ, chọn mới gọi onSelect', (tester) async {
      String? picked;
      await tester.pumpWidget(
        _wrap(LanguageScreen(selected: 'vi', onSelect: (c) => picked = c)),
      );
      await tester.pump();

      expect(find.text('Tiếng Việt'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('한국어'), findsOneWidget);
      expect(find.text('日本語'), findsOneWidget);

      await tester.tap(find.text('English'));
      expect(picked, 'en');
    });
  });

  group('NotificationSettingsScreen (TC-22/23 · F07-S12)', () {
    testWidgets('đã cấp quyền → pill "Đã cấp quyền" + 3 toggle bật', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const NotificationSettingsScreen()));
      await tester.pump();

      expect(find.text('Đã cấp quyền'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(3));
      expect(
        tester.widgetList<Switch>(find.byType(Switch)).every((s) => s.value),
        isTrue,
      );
    });

    testWidgets('tắt một toggle chỉ đổi đúng toggle đó', (tester) async {
      await tester.pumpWidget(_wrap(const NotificationSettingsScreen()));
      await tester.pump();

      await tester.tap(find.byType(Switch).first);
      await tester.pump();

      final values = tester
          .widgetList<Switch>(find.byType(Switch))
          .map((s) => s.value);
      expect(values.where((v) => v).length, 2);
    });
  });

  group('DeleteAccountScreen (TC-02/23 xoá tài khoản · F07-S13)', () {
    testWidgets('chưa tick "tôi hiểu" thì nút Xác nhận xoá bị vô hiệu', (
      tester,
    ) async {
      var confirmed = false;
      await tester.pumpWidget(
        _wrap(DeleteAccountScreen(onConfirm: () => confirmed = true)),
      );
      await tester.pump();

      expect(find.text('Tài khoản sẽ bị xoá vĩnh viễn'), findsOneWidget);
      await tester.ensureVisible(find.text('Xác nhận xoá'));
      await tester.tap(find.text('Xác nhận xoá'), warnIfMissed: false);
      expect(confirmed, isFalse);

      await tester.ensureVisible(
        find.textContaining('Tôi hiểu rằng thao tác này'),
      );
      await tester.tap(
        find.textContaining('Tôi hiểu rằng thao tác này'),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.ensureVisible(find.text('Xác nhận xoá'));
      await tester.tap(find.text('Xác nhận xoá'), warnIfMissed: false);
      expect(confirmed, isTrue);
    });

    testWidgets('nêu rõ xoá ngay lập tức, vĩnh viễn, không thể hoàn tác', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(DeleteAccountScreen(onConfirm: () {})));
      await tester.pump();

      // The copy must match the backend's immediate hard-delete — no promise of
      // a grace period the server does not honour.
      expect(find.textContaining('ngay lập tức'), findsWidgets);
      expect(find.textContaining('xoá vĩnh viễn'), findsWidgets);
      expect(find.textContaining('không thể hoàn tác'), findsWidgets);
      expect(find.textContaining('7 ngày'), findsNothing);
    });
  });

  group('CropAvatarScreen (TC-02 crop · F07-S04)', () {
    testWidgets('có tỉ lệ 1:1, nút Lưu chụp vùng crop thành PNG', (
      tester,
    ) async {
      Uint8List? saved;
      // Mount and settle in fake time…
      await tester.pumpWidget(
        _wrap(
          CropAvatarScreen(
            imagePath: '/tmp/nonexistent.png',
            onSave: (bytes) => saved = bytes,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Cắt ảnh theo tỉ lệ 1:1'), findsOneWidget);
      expect(find.text('Xoay'), findsOneWidget);

      // …but the capture itself is real async (RenderRepaintBoundary.toImage),
      // so trigger it and let it complete inside runAsync.
      await tester.runAsync(() async {
        await tester.tap(find.text('Lưu'));
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });

      // The frame captured to real PNG bytes, not a path. A missing source
      // image still captures (the error placeholder), so bytes are non-empty
      // and start with the PNG magic number.
      expect(saved, isNotNull);
      expect(saved!.length, greaterThan(8));
      expect(saved!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    });
  });
}

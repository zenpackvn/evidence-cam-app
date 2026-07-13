// Unit/widget coverage for `product-spec/002-ho-so-nguoi-dung` +
// `023-cai-dat-tai-khoan` test-cases (settings sub-screens, delete confirm).
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
    testWidgets('đã cấp quyền → pill "Đã cấp quyền" + 3 toggle bật',
        (tester) async {
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

      final values =
          tester.widgetList<Switch>(find.byType(Switch)).map((s) => s.value);
      expect(values.where((v) => v).length, 2);
    });
  });

  group('DeleteAccountScreen (TC-02/23 xoá tài khoản · F07-S13)', () {
    testWidgets('chưa tick "tôi hiểu" thì nút Xác nhận xoá bị vô hiệu',
        (tester) async {
      var confirmed = false;
      await tester.pumpWidget(
        _wrap(DeleteAccountScreen(onConfirm: () => confirmed = true)),
      );
      await tester.pump();

      expect(find.text('Tài khoản sẽ vào trạng thái chờ xoá'), findsOneWidget);
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

    testWidgets('nêu rõ chờ xoá 7 ngày và có thể huỷ bằng đăng nhập lại',
        (tester) async {
      await tester.pumpWidget(_wrap(DeleteAccountScreen(onConfirm: () {})));
      await tester.pump();

      expect(find.textContaining('7 ngày'), findsWidgets);
      expect(
        find.textContaining('đăng nhập lại'),
        findsWidgets,
      );
    });
  });

  group('CropAvatarScreen (TC-02 crop · F07-S04)', () {
    testWidgets('có tỉ lệ 1:1, nút Lưu trả về path', (tester) async {
      String? saved;
      await tester.pumpWidget(
        _wrap(
          CropAvatarScreen(
            imagePath: '/tmp/nonexistent.png',
            onSave: (p) => saved = p,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Cắt ảnh theo tỉ lệ 1:1'), findsOneWidget);
      expect(find.text('Xoay'), findsOneWidget);
      await tester.tap(find.text('Lưu'));
      expect(saved, '/tmp/nonexistent.png');
    });
  });
}

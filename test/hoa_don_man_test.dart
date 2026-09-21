import 'package:feature_account/feature_account.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:localization/localization.dart';

Widget _man(EcHoaDonScreen man) => CupertinoApp(
  locale: const Locale('vi'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: man,
);

void _khungCao(WidgetTester t) {
  t.view.physicalSize = const Size(430, 2200);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
}

void main() {
  // Thông tin xuất hoá đơn nằm ở TÀI KHOẢN, không ở cửa hàng: hoá đơn xuất cho
  // người trả tiền, mà gói cước tính theo tài khoản.
  testWidgets(
    'công ty thiếu mã số thuế thì KHÔNG gửi, và nói rõ vì sao',
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
    (t) async {
      _khungCao(t);
      var goi = 0;
      await t.pumpWidget(
        _man(
          EcHoaDonScreen(
            banDau: const EcHoaDon(),
            onLuu: (_) async {
              goi++;
              return null;
            },
          ),
        ),
      );

      await t.enterText(
        find.bySemanticsLabel('Tên đơn vị'),
        'Công ty TNHH ABC',
      );
      await t.tap(find.text('Lưu thông tin'));
      await t.pumpAndSettle();

      expect(goi, 0);
      expect(
        find.text('Công ty/hộ kinh doanh phải có mã số thuế.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'cá nhân KHÔNG bắt mã số thuế',
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
    (t) async {
      // Người mua lẻ ở Việt Nam thường không có MST cá nhân; bắt nhập là chặn
      // đúng nhóm khách nhỏ nhất.
      _khungCao(t);
      EcHoaDon? gui;
      await t.pumpWidget(
        _man(
          EcHoaDonScreen(
            banDau: const EcHoaDon(),
            onLuu: (v) async {
              gui = v;
              return null;
            },
          ),
        ),
      );

      await t.tap(find.text('Cá nhân'));
      await t.pumpAndSettle();
      await t.enterText(find.bySemanticsLabel('Họ và tên'), 'Nguyễn Văn A');
      await t.tap(find.text('Lưu thông tin'));
      await t.pumpAndSettle();

      expect(gui?.loai, 'individual');
      expect(gui?.ten, 'Nguyễn Văn A');
    },
  );

  testWidgets(
    'đổi loại đối tượng đổi luôn NHÃN của hai ô đầu',
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
    (t) async {
      // Cùng một ô nhưng nghĩa khác nhau: tên pháp nhân với họ tên người. Giữ
      // nguyên nhãn "Tên đơn vị" cho cá nhân là hỏi sai câu.
      _khungCao(t);
      await t.pumpWidget(
        _man(
          EcHoaDonScreen(banDau: const EcHoaDon(), onLuu: (_) async => null),
        ),
      );

      expect(find.text('Tên đơn vị'), findsOneWidget);
      expect(find.text('Mã số thuế'), findsOneWidget);

      await t.tap(find.text('Cá nhân'));
      await t.pumpAndSettle();

      expect(find.text('Họ và tên'), findsOneWidget);
      expect(find.text('Mã số thuế (nếu có)'), findsOneWidget);
    },
  );

  testWidgets(
    'mã số thuế chép từ giấy tờ có khoảng trắng vẫn nhận',
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
    (t) async {
      // Người ta chép MST từ giấy phép kinh doanh, và ở đó nó hay có dấu cách.
      // Từ chối vì một ký tự trắng là bắt họ tự đoán mình sai chỗ nào.
      _khungCao(t);
      EcHoaDon? gui;
      await t.pumpWidget(
        _man(
          EcHoaDonScreen(
            banDau: const EcHoaDon(),
            onLuu: (v) async {
              gui = v;
              return null;
            },
          ),
        ),
      );

      await t.enterText(find.bySemanticsLabel('Tên đơn vị'), 'ABC');
      await t.enterText(find.bySemanticsLabel('Mã số thuế'), '0312 345 678');
      await t.tap(find.text('Lưu thông tin'));
      await t.pumpAndSettle();

      expect(gui?.maSoThue, '0312345678');
    },
  );

  testWidgets(
    'mã số thuế sai định dạng thì chặn',
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
    (t) async {
      _khungCao(t);
      var goi = 0;
      await t.pumpWidget(
        _man(
          EcHoaDonScreen(
            banDau: const EcHoaDon(),
            onLuu: (_) async {
              goi++;
              return null;
            },
          ),
        ),
      );

      await t.enterText(find.bySemanticsLabel('Tên đơn vị'), 'ABC');
      await t.enterText(find.bySemanticsLabel('Mã số thuế'), '123');
      await t.tap(find.text('Lưu thông tin'));
      await t.pumpAndSettle();

      expect(goi, 0);
      expect(find.textContaining('10 chữ số'), findsOneWidget);
    },
  );

  testWidgets(
    'điền sẵn hồ sơ đã lưu, không bắt gõ lại',
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
    (t) async {
      _khungCao(t);
      await t.pumpWidget(
        _man(
          EcHoaDonScreen(
            banDau: const EcHoaDon(
              loai: 'individual',
              ten: 'Nguyễn Văn A',
              diaChi: '123 Lê Lợi',
            ),
            onLuu: (_) async => null,
          ),
        ),
      );

      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('123 Lê Lợi'), findsOneWidget);
      expect(find.text('Họ và tên'), findsOneWidget);
    },
  );

  testWidgets(
    'máy chủ từ chối thì HIỆN câu của máy chủ, không nuốt',
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
    (t) async {
      _khungCao(t);
      await t.pumpWidget(
        _man(
          EcHoaDonScreen(
            banDau: const EcHoaDon(),
            onLuu: (_) async => 'Máy chủ từ chối vì lý do X',
          ),
        ),
      );

      await t.enterText(find.bySemanticsLabel('Tên đơn vị'), 'ABC');
      await t.enterText(find.bySemanticsLabel('Mã số thuế'), '0312345678');
      await t.tap(find.text('Lưu thông tin'));
      await t.pumpAndSettle();

      expect(find.text('Máy chủ từ chối vì lý do X'), findsOneWidget);
    },
  );
}

import 'package:ec_ui/ec_ui.dart' show LucideIcons;
import 'package:evidence_cam/core/huong_dan/kho_shared_prefs.dart';
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
import 'package:storage/storage.dart';

Widget _boc(Widget con) => MaterialApp(
  locale: const Locale('vi'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: con,
);

void main() {
  group('ba màn giới thiệu', () {
    late int xong;

    Future<void> mo(WidgetTester t) async {
      xong = 0;
      await t.pumpWidget(_boc(EcGioiThieuScreen(onXong: () => xong++)));
      await t.pumpAndSettle();
    }

    testWidgets('mở ra ở trang một', (t) async {
      await mo(t);
      expect(find.text('Quay lúc đóng gói'), findsOneWidget);
      expect(find.text('Tiếp'), findsOneWidget);
      expect(find.text('Bắt đầu ngay'), findsNothing);
    });

    testWidgets('bấm Tiếp đi hết ba trang rồi mới ra nút Bắt đầu', (t) async {
      await mo(t);
      await t.tap(find.text('Tiếp'));
      await t.pumpAndSettle();
      expect(find.text('Gắn đúng vào mã vận đơn'), findsOneWidget);
      expect(find.text('Bắt đầu ngay'), findsNothing);

      await t.tap(find.text('Tiếp'));
      await t.pumpAndSettle();
      expect(find.text('Có bằng chứng khi bị khiếu nại'), findsOneWidget);
      // Trang cuối: nút đổi chữ, không còn "Tiếp" để bấm hụt.
      expect(find.text('Bắt đầu ngay'), findsOneWidget);
      expect(find.text('Tiếp'), findsNothing);
    });

    testWidgets('bấm Bắt đầu ở trang cuối thì báo xong', (t) async {
      await mo(t);
      await t.tap(find.text('Tiếp'));
      await t.pumpAndSettle();
      await t.tap(find.text('Tiếp'));
      await t.pumpAndSettle();
      await t.tap(find.text('Bắt đầu ngay'));
      await t.pumpAndSettle();
      expect(xong, 1);
    });

    testWidgets('BỎ QUA được ngay từ trang đầu', (t) async {
      // Người tải app phần lớn đã biết mình cần gì; giữ họ lại ba trang bắt
      // buộc là đổi chút thông tin lấy sự khó chịu ngay phút đầu.
      await mo(t);
      await t.tap(find.text('Bỏ qua'));
      await t.pumpAndSettle();
      expect(xong, 1);
    });

    testWidgets('tự lướt sang trang sau khi để yên 2 giây', (t) async {
      await mo(t);
      expect(find.text('Quay lúc đóng gói'), findsOneWidget);
      await t.pump(const Duration(seconds: 2));
      await t.pumpAndSettle();
      expect(find.text('Gắn đúng vào mã vận đơn'), findsOneWidget);
    });

    testWidgets('tới trang cuối thì DỪNG, không quay vòng về đầu', (t) async {
      // Vòng lặp vô tận ở màn giới thiệu là cái bẫy: người dùng không biết
      // mình đã xem hết chưa.
      await mo(t);
      for (var i = 0; i < 4; i++) {
        await t.pump(const Duration(seconds: 2));
        await t.pumpAndSettle();
      }
      expect(find.text('Có bằng chứng khi bị khiếu nại'), findsOneWidget);
      expect(find.text('Quay lúc đóng gói'), findsNothing);
    });

    testWidgets('người dùng tự vuốt thì TẮT tự lướt', (t) async {
      // Đang đọc dở mà bị giật sang trang khác thì đọc ra là app lỗi, và không
      // có cách lấy lại trang vừa mất ngoài vuốt ngược — rồi lại bị giật đi.
      await mo(t);
      await t.fling(find.byType(PageView), const Offset(-400, 0), 1200);
      await t.pumpAndSettle();
      expect(find.text('Gắn đúng vào mã vận đơn'), findsOneWidget);

      await t.pump(const Duration(seconds: 2));
      await t.pumpAndSettle();
      // Vẫn đứng nguyên trang hai: đồng hồ đã tắt hẳn.
      expect(find.text('Gắn đúng vào mã vận đơn'), findsOneWidget);
    });

    testWidgets('mũi tên CHỈ có ở trang cuối', (t) async {
      await mo(t);
      expect(find.byIcon(LucideIcons.arrowRight), findsNothing);
      await t.tap(find.text('Tiếp'));
      await t.pumpAndSettle();
      expect(find.byIcon(LucideIcons.arrowRight), findsNothing);
      await t.tap(find.text('Tiếp'));
      await t.pumpAndSettle();
      expect(find.byIcon(LucideIcons.arrowRight), findsOneWidget);
    });

    testWidgets('bấm Tiếp cũng tắt tự lướt — người dùng đang cầm lái', (
      t,
    ) async {
      await mo(t);
      await t.tap(find.text('Tiếp'));
      await t.pumpAndSettle();
      expect(find.text('Gắn đúng vào mã vận đơn'), findsOneWidget);
      await t.pump(const Duration(seconds: 2));
      await t.pumpAndSettle();
      expect(find.text('Gắn đúng vào mã vận đơn'), findsOneWidget);
    });

    testWidgets('vuốt ngược lại trang trước được', (t) async {
      await mo(t);
      await t.tap(find.text('Tiếp'));
      await t.pumpAndSettle();
      await t.fling(find.byType(PageView), const Offset(400, 0), 1200);
      await t.pumpAndSettle();
      expect(find.text('Quay lúc đóng gói'), findsOneWidget);
    });
  });

  group('nhớ đã xem giới thiệu', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('là cấp MÁY — đổi người đăng nhập không bắt xem lại', () async {
      // Giới thiệu chạy TRƯỚC lúc đăng nhập nên lúc đó chưa có ai để gắn vào.
      // Và nó nói về sản phẩm, không nói về tài khoản.
      var uid = 'nguoi-mot';
      final k = EcHuongDanKhoPrefs(prefs, () => uid);
      expect(k.daXemGioiThieu(), isFalse);
      await k.danhDauGioiThieu();
      expect(k.daXemGioiThieu(), isTrue);

      uid = 'nguoi-hai';
      expect(k.daXemGioiThieu(), isTrue);
    });

    test('quên hết hướng dẫn KHÔNG xoá dấu đã xem giới thiệu', () async {
      // Hai thứ khác nhau: "xem lại hướng dẫn màn" là chỉ lại cách dùng, không
      // phải bắt xem lại phần giới thiệu sản phẩm từ đầu.
      final k = EcHuongDanKhoPrefs(prefs, () => 'ai-do');
      await k.danhDauGioiThieu();
      await k.quenHet();
      expect(k.daXemGioiThieu(), isTrue);
    });
  });
}

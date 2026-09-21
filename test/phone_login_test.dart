import 'package:ec_data/ec_data.dart';
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

/// Bọc màn hình trong đúng bộ localization mà app thật dùng.
///
/// Thiếu delegate thì `context.l10n` ném ngay, và bài test hỏng vì lý do không
/// liên quan gì tới thứ nó định canh.
Widget _boc(Widget con) => MaterialApp(
  locale: const Locale('vi'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: con,
);

void main() {
  // Khoá riêng mỗi lượt mở. Pump lại cùng loại widget thì Flutter DÙNG LẠI
  // State cũ, nên màn vẫn đứng ở bước nhập mã của lượt trước và bài test tìm
  // không thấy nút của bước nhập số.
  var lan = 0;
  late List<({String phone, String channel})> daXin;
  late List<({String phone, String code})> daXacMinh;
  String? loiKhiGui;
  var maDung = '123456';

  setUp(() {
    lan = 0;
    daXin = [];
    daXacMinh = [];
    loiKhiGui = null;
    maDung = '123456';
  });

  Future<void> mo(WidgetTester t) async {
    await t.pumpWidget(
      _boc(
        EcPhoneLoginScreen(
          key: ValueKey('mo-${lan++}'),
          onSendCode: (phone, channel) async {
            if (loiKhiGui != null) throw EcOtpException(loiKhiGui!);
            daXin.add((phone: phone, channel: channel));
          },
          onVerify: (phone, code) async {
            if (code != maDung) throw const EcOtpException('sai_ma');
            daXacMinh.add((phone: phone, code: code));
          },
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  /// Gõ số rồi bấm nút của kênh chỉ định để sang bước nhập mã.
  Future<void> toiBuocMa(
    WidgetTester t, {
    String kenh = 'Gửi mã qua Zalo',
  }) async {
    await mo(t);
    await t.enterText(find.byType(TextField), '0912345678');
    await t.pump();
    await t.tap(find.text(kenh));
    await t.pump();
  }

  testWidgets('chưa đủ số thì hai nút gửi đều khoá', (t) async {
    await mo(t);
    await t.enterText(find.byType(TextField), '0912');
    await t.pump();
    await t.tap(find.text('Gửi mã qua Zalo'));
    await t.pump();
    expect(daXin, isEmpty);
  });

  testWidgets('nút Zalo gửi kênh zalo, nút SMS gửi kênh sms', (t) async {
    await toiBuocMa(t);
    expect(daXin.single.channel, 'zalo');

    daXin.clear();
    await toiBuocMa(t, kenh: 'Gửi mã qua SMS');
    expect(daXin.single.channel, 'sms');
  });

  testWidgets('gửi xong sang bước nhập mã và nói rõ gửi tới số nào', (t) async {
    await toiBuocMa(t);
    expect(find.text('Nhập mã xác nhận'), findsOneWidget);
    expect(find.textContaining('0912345678'), findsWidgets);
  });

  testWidgets('gửi qua Zalo thì nói rõ tin đến từ OA nào', (t) async {
    await toiBuocMa(t);
    expect(find.textContaining('Uniclove'), findsOneWidget);
  });

  testWidgets('gửi qua SMS thì KHÔNG nhắc tên OA Zalo', (t) async {
    await toiBuocMa(t, kenh: 'Gửi mã qua SMS');
    expect(find.textContaining('Uniclove'), findsNothing);
  });

  testWidgets('dán cả câu trong tin nhắn vẫn lấy đúng 6 chữ số', (t) async {
    await toiBuocMa(t);
    await t.enterText(find.byType(TextField), 'Ma cua ban la 123456');
    await t.pump();
    final o = t.widget<TextField>(find.byType(TextField));
    expect(o.controller!.text, '123456');
  });

  testWidgets('quá 6 chữ số thì cắt còn 6', (t) async {
    await toiBuocMa(t);
    await t.enterText(find.byType(TextField), '12345678');
    await t.pump();
    expect(
      t.widget<TextField>(find.byType(TextField)).controller!.text,
      '123456',
    );
  });

  testWidgets('đủ 6 số mới xác minh được', (t) async {
    await toiBuocMa(t);
    await t.enterText(find.byType(TextField), '123');
    await t.pump();
    await t.tap(find.text('Xác nhận'));
    await t.pump();
    expect(daXacMinh, isEmpty);

    await t.enterText(find.byType(TextField), '123456');
    await t.pump();
    await t.tap(find.text('Xác nhận'));
    await t.pumpAndSettle();
    expect(daXacMinh.single.code, '123456');
  });

  testWidgets('vừa gửi thì nút gửi lại đang đếm ngược', (t) async {
    await toiBuocMa(t);
    expect(find.textContaining('Gửi lại sau'), findsOneWidget);
  });

  testWidgets('mã sai thì báo đúng câu và XOÁ ô để gõ lại', (t) async {
    maDung = '999999';
    await toiBuocMa(t);
    await t.enterText(find.byType(TextField), '123456');
    await t.pump();
    await t.tap(find.text('Xác nhận'));
    await t.pumpAndSettle();
    expect(find.text('Mã không đúng. Kiểm tra lại tin nhắn.'), findsOneWidget);
    expect(t.widget<TextField>(find.byType(TextField)).controller!.text, '');
  });

  // Mỗi mã lỗi một bài riêng: gộp cả bốn vào một lượt thì các SnackBar chồng
  // lên nhau và bài test đọc nhầm câu của ca trước.
  for (final (ma, cau) in [
    ('too_soon', 'Vừa gửi rồi. Chờ một chút rồi thử lại.'),
    ('rate_limited', 'Xin mã quá nhiều lần. Thử lại sau ít phút.'),
    ('invalid_phone', 'Số điện thoại không hợp lệ'),
    (
      'not_configured',
      'Hệ thống chưa sẵn sàng gửi mã. Vui lòng dùng cách khác.',
    ),
  ]) {
    testWidgets('máy chủ trả $ma thì nói đúng câu của nó', (t) async {
      loiKhiGui = ma;
      await mo(t);
      await t.enterText(find.byType(TextField), '0912345678');
      await t.pump();
      await t.tap(find.text('Gửi mã qua Zalo'));
      await t.pumpAndSettle();
      expect(find.text(cau), findsOneWidget);
    });
  }

  testWidgets('gửi hỏng thì ở nguyên bước nhập số', (t) async {
    loiKhiGui = 'send_failed';
    await mo(t);
    await t.enterText(find.byType(TextField), '0912345678');
    await t.pump();
    await t.tap(find.text('Gửi mã qua Zalo'));
    await t.pumpAndSettle();
    expect(find.text('Gửi mã qua Zalo'), findsOneWidget);
    expect(find.text('Nhập mã xác nhận'), findsNothing);
  });
}

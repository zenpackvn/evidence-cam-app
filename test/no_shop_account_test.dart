import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

Widget _boc(Widget con) => MaterialApp(
  locale: const Locale('vi'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: con,
);

void main() {
  testWidgets('tài khoản chưa có cửa hàng vẫn BẤM được nút Tài khoản', (
    t,
  ) async {
    // Người vừa lập tài khoản chưa có shop nào thì đây là màn duy nhất họ thấy.
    // Nút Tài khoản không bấm được nghĩa là họ không vào được hồ sơ, không đổi
    // được ngôn ngữ, và không xoá được tài khoản — kẹt hoàn toàn.
    var mo = 0;
    await t.pumpWidget(_boc(EcNoShopScreen(onAccountTap: () => mo++)));
    await t.pumpAndSettle();

    // Nhắm ĐÚNG viên nút, không phải câu "Tài khoản của bạn chưa thuộc shop
    // nào" trong thân màn — chạm nhầm vào đó thì test đỏ vì lý do sai.
    final nhan = AppLocalizations.of(
      t.element(find.byType(EcNoShopScreen)),
    ).navAccount;
    final vien = find.text(nhan);
    expect(vien, findsOneWidget, reason: 'không thấy nút Tài khoản trên màn');
    await t.tap(vien, warnIfMissed: false);
    await t.pumpAndSettle();
    expect(mo, 1, reason: 'chạm vào nút Tài khoản nhưng callback không chạy');
  });
}

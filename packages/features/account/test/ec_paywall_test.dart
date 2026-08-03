import 'package:ec_ui/ec_ui.dart';
import 'package:feature_account/feature_account.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bộ 9 gói như RevenueCat trả về, giá đã định dạng sẵn bởi cửa hàng.
const _offers = <EcPaywallOffer>[
  EcPaywallOffer(
    planCode: 'basic',
    termKey: '1m',
    priceLabel: '169.000 ₫',
    priceAmount: 169000,
  ),
  EcPaywallOffer(
    planCode: 'saver',
    termKey: '1m',
    priceLabel: '319.000 ₫',
    priceAmount: 319000,
  ),
  EcPaywallOffer(
    planCode: 'premium',
    termKey: '1m',
    priceLabel: '459.000 ₫',
    priceAmount: 459000,
  ),
  EcPaywallOffer(
    planCode: 'basic',
    termKey: '6m',
    priceLabel: '939.000 ₫',
    priceAmount: 939000,
  ),
  EcPaywallOffer(
    planCode: 'saver',
    termKey: '6m',
    priceLabel: '1.749.000 ₫',
    priceAmount: 1749000,
  ),
  EcPaywallOffer(
    planCode: 'premium',
    termKey: '6m',
    priceLabel: '2.549.000 ₫',
    priceAmount: 2549000,
  ),
  EcPaywallOffer(
    planCode: 'basic',
    termKey: '12m',
    priceLabel: '1.799.000 ₫',
    priceAmount: 1799000,
  ),
  EcPaywallOffer(
    planCode: 'saver',
    termKey: '12m',
    priceLabel: '3.390.000 ₫',
    priceAmount: 3390000,
  ),
  EcPaywallOffer(
    planCode: 'premium',
    termKey: '12m',
    priceLabel: '4.849.000 ₫',
    priceAmount: 4849000,
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  List<EcPaywallOffer> offers = _offers,
  void Function(EcPaywallOffer)? onBuy,
  VoidCallback? onBack,
  VoidCallback? onTerms,
  VoidCallback? onPrivacy,
  VoidCallback? onSync,
  bool busy = false,
}) async {
  await tester.pumpWidget(
    CupertinoApp(
      home: EcPaywallScreen(
        offers: offers,
        onBuy: onBuy,
        onBack: onBack,
        onTerms: onTerms,
        onPrivacy: onPrivacy,
        onSync: onSync,
        busy: busy,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mở ra ở 6 tháng và chỉ hiện 3 gói của thời hạn đó', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('939.000 ₫'), findsOneWidget);
    expect(find.text('1.749.000 ₫'), findsOneWidget);
    expect(find.text('2.549.000 ₫'), findsOneWidget);
    // Không đổ phẳng cả 9 gói: giá của thời hạn khác không được xuất hiện.
    expect(find.text('169.000 ₫'), findsNothing);
    expect(find.text('4.849.000 ₫'), findsNothing);
  });

  testWidgets('đổi thời hạn thì đổi cả ba giá', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('12 tháng'));
    await tester.pumpAndSettle();
    expect(find.text('1.799.000 ₫'), findsOneWidget);
    expect(find.text('4.849.000 ₫'), findsOneWidget);
    expect(find.text('939.000 ₫'), findsNothing);
  });

  testWidgets('gói dài hiện giá quy đổi mỗi tháng, gói 1 tháng thì không', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('≈ 156.500đ/tháng'), findsOneWidget); // 939.000 / 6
    await tester.tap(find.text('1 tháng'));
    await tester.pumpAndSettle();
    expect(find.textContaining('/tháng'), findsNothing);
  });

  testWidgets('mua trả về đúng gói đang chọn', (tester) async {
    EcPaywallOffer? bought;
    await _pump(tester, onBuy: (o) => bought = o);
    await tester.tap(find.text('Cao cấp'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(bought?.planCode, 'premium');
    expect(bought?.termKey, '6m');
  });

  testWidgets('mặc định chọn gói giữa, mua ngay không cần chạm', (
    tester,
  ) async {
    EcPaywallOffer? bought;
    await _pump(tester, onBuy: (o) => bought = o);
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(bought?.planCode, 'saver');
  });

  testWidgets('đang xử lý thì khoá nút, không mua được hai lần', (
    tester,
  ) async {
    var calls = 0;
    await _pump(tester, onBuy: (_) => calls++, busy: true);
    await tester.tap(find.text('Đang xử lý…'));
    await tester.pumpAndSettle();
    expect(calls, 0);
  });

  testWidgets('không tải được bảng giá thì nói ra, không hiện màn trắng', (
    tester,
  ) async {
    await _pump(tester, offers: const []);
    expect(find.text('Chưa tải được bảng giá'), findsOneWidget);
    expect(find.text('Cơ bản'), findsNothing);
  });

  testWidgets('luôn có đường thoát khỏi paywall', (tester) async {
    // Paywall không lối ra vừa là lý do App Review từ chối, vừa là ngõ cụt với
    // người chỉ muốn xem giá. Trước đây `onBack` được khai nhưng không hề vẽ.
    var backed = false;
    await _pump(tester, onBack: () => backed = true);
    await tester.tap(find.byType(PenBackButton));
    await tester.pumpAndSettle();
    expect(backed, isTrue);
  });

  testWidgets('có link Điều khoản và Chính sách, bấm được', (tester) async {
    var terms = false;
    var privacy = false;
    await _pump(
      tester,
      onTerms: () => terms = true,
      onPrivacy: () => privacy = true,
    );
    // Hai link nằm cuối trang, phải cuộn tới — giống hệt trên máy thật.
    await tester.ensureVisible(find.text('Điều khoản sử dụng'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Điều khoản sử dụng'));
    await tester.tap(find.text('Chính sách quyền riêng tư'));
    await tester.pumpAndSettle();
    expect(terms, isTrue);
    expect(privacy, isTrue);
  });

  testWidgets('đường đồng bộ chỉ hiện khi mua được', (tester) async {
    // Không có cửa hàng thì đồng bộ không cứu được gì — để lại chỉ tạo nút chết.
    await _pump(tester);
    expect(find.textContaining('Đồng bộ lại'), findsNothing);

    var synced = false;
    await _pump(tester, onSync: () => synced = true);
    await tester.ensureVisible(find.textContaining('Đồng bộ lại'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Đồng bộ lại'));
    await tester.pumpAndSettle();
    expect(synced, isTrue);
  });

  testWidgets('KHÔNG dùng ngôn từ thuê bao ở bất kỳ đâu', (tester) async {
    await _pump(tester);
    final shown = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join(' | ');

    // Sản phẩm là mua đứt. Những chữ này vừa mô tả sai sản phẩm vừa là cớ để
    // App Review từ chối, nên chặn bằng test chứ không bằng trí nhớ.
    for (final banned in ['Đăng ký', 'Huỷ', 'Hủy', 'dùng thử']) {
      expect(
        shown.contains(banned),
        isFalse,
        reason: 'paywall mua đứt không được chứa "$banned"',
      );
    }

    // "gia hạn" chỉ được xuất hiện trong câu PHỦ ĐỊNH. Đó là thông tin bắt
    // buộc phải nói, không phải từ cấm — cấm thẳng sẽ xoá mất nó.
    // So không phân biệt hoa thường: câu này xuất hiện cả ở phụ đề (viết hoa)
    // lẫn trong khối lưu ý (giữa câu, viết thường).
    final lower = shown.toLowerCase();
    for (final match in 'gia hạn'.allMatches(lower)) {
      expect(
        lower.substring(0, match.start).endsWith('không tự động '),
        isTrue,
        reason: 'chỉ được nhắc "gia hạn" trong "Không tự động gia hạn"',
      );
    }
    expect(shown, contains('Không tự động gia hạn'));

    // Tương tự với "khôi phục": chỉ được nhắc ở dạng phủ định. Sản phẩm tiêu
    // hao KHÔNG khôi phục được, và Apple đòi nói rõ điều đó trước khi mua.
    for (final match in 'khôi phục'.allMatches(lower)) {
      expect(
        lower.substring(0, match.start).endsWith('không hỗ trợ '),
        isTrue,
        reason: 'chỉ được nhắc "khôi phục" ở dạng "không hỗ trợ khôi phục"',
      );
    }
    expect(shown, contains('không hỗ trợ khôi phục mua hàng'));
  });
}

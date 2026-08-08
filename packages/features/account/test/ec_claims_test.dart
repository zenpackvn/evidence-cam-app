import 'package:app_ui/app_ui.dart';
import 'package:feature_account/feature_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

/// Màn này đọc chữ qua `context.l10n`, nên harness phải cài delegate — thiếu
/// thì `AppLocalizations.of` trả null và màn ném ngay lúc dựng. Ghim `vi` vì
/// mọi kỳ vọng dưới đây viết theo tiếng Việt.
Future<void> _pump(WidgetTester tester, Widget screen) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: screen,
    ),
  );
}

const _spx1 = [
  EcClaimPickable(
    id: 'e1',
    label: 'Đóng hàng',
    time: '14:02',
    day: '07/08/2026',
  ),
  EcClaimPickable(
    id: 'e2',
    label: 'Trả hàng',
    time: '09:30',
    day: '06/08/2026',
  ),
];

const _spx2 = [
  EcClaimPickable(
    id: 'e3',
    label: 'Ảnh đính kèm',
    time: '11:11',
    day: '07/08/2026',
    isPhoto: true,
  ),
];

Future<void> _lookup(WidgetTester tester, String code) async {
  await tester.enterText(find.byType(EditableText), code);
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await tester.pumpAndSettle();
}

void main() {
  group('EcCreateClaimScreen', () {
    testWidgets('mỗi bằng chứng hiện giờ, nhãn và tiêu đề ngày', (
      tester,
    ) async {
      await _pump(
        tester,
        EcCreateClaimScreen(onSearch: (code) async => _spx1),
      );
      await _lookup(tester, 'SPX1');

      // Cùng thông tin dòng thời gian của một đơn: giờ ở cột trái, ngày làm
      // tiêu đề nhóm — không phải một dòng chữ trơn.
      expect(find.text('14:02'), findsOneWidget);
      expect(find.text('Đóng hàng'), findsOneWidget);
      expect(find.text('07/08/2026'), findsOneWidget);
      expect(find.text('06/08/2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('chạm vào cả thẻ là tick, và nút tạo đếm đúng', (tester) async {
      await _pump(
        tester,
        EcCreateClaimScreen(onSearch: (code) async => _spx1),
      );
      await _lookup(tester, 'SPX1');

      // Chưa tick gì thì chưa có nút tạo. Đối chiếu theo số đếm `(n)` chứ
      // không theo chữ "Tạo hồ sơ" — tiêu đề màn cũng mang chữ đó.
      expect(find.textContaining('(1)'), findsNothing);

      await tester.tap(find.text('Đóng hàng'));
      await tester.pumpAndSettle();
      expect(find.textContaining('(1)'), findsOneWidget);

      // Bỏ tick thì nút biến mất trở lại — số đếm đi xuống, không kẹt.
      await tester.tap(find.text('Đóng hàng'));
      await tester.pumpAndSettle();
      expect(find.textContaining('(1)'), findsNothing);
    });

    testWidgets('quét mã thứ hai không làm mất phần đã tick ở mã đầu', (
      tester,
    ) async {
      List<EcClaimOrderPicks>? created;
      await _pump(
        tester,
        EcCreateClaimScreen(
          onSearch: (code) async => code == 'SPX1' ? _spx1 : _spx2,
          onCreate: (batch) => created = batch,
        ),
      );

      await _lookup(tester, 'SPX1');
      await tester.tap(find.text('Đóng hàng'));
      await tester.pumpAndSettle();

      await _lookup(tester, 'SPX2');
      await tester.tap(find.text('Ảnh đính kèm'));
      await tester.pumpAndSettle();

      // Mã cũ vẫn nằm dưới mã mới, và cái đã tick ở đó vẫn còn.
      expect(find.text('SPX1'), findsOneWidget);
      expect(find.text('Đóng hàng'), findsOneWidget);

      await tester.tap(find.textContaining('(2)'));
      await tester.pumpAndSettle();

      expect(created, hasLength(2));
      expect(
        {for (final o in created!) o.orderCode: o.picked.single.id},
        {'SPX1': 'e1', 'SPX2': 'e3'},
      );
    });
  });
}

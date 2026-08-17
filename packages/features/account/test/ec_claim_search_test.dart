// Màn tạo hồ sơ khiếu nại: GÕ TAY một mã phải ra đúng cái quét mã ra.
//
// Người bán báo quét mã thì hiện đơn, còn nhập đúng mã đó bằng tay thì không
// hiện đơn nào. Hai đường đi qua cùng một hàm tra (`_lookup`), nên ca ở đây đo
// đường gõ tay tới tận nơi: gõ vào ô, bấm kính lúp, và xem nhóm mã có hiện ra
// không.

import 'package:ec_ui/ec_ui.dart' show LucideIcons;
import 'package:feature_account/feature_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
  await tester.pumpAndSettle();
}

const _hit = EcClaimLookup(
  code: '88081226000032',
  items: [
    EcClaimPickable(
      id: 'ev-1',
      label: 'Đóng hàng',
      time: '09:12',
      day: '17/08/2026',
      capturedAt: 1,
    ),
  ],
);

void main() {
  _searchFailureTests();

  testWidgets('gõ mã rồi bấm kính lúp thì hiện đơn', (tester) async {
    final asked = <String>[];
    await _pump(
      tester,
      EcCreateClaimScreen(
        onSearch: (q) async {
          asked.add(q);
          return const [_hit];
        },
      ),
    );

    await tester.enterText(
      find.byType(EditableText).last,
      '88081226000032',
    );
    await tester.tap(find.byIcon(LucideIcons.search));
    await tester.pumpAndSettle();

    expect(asked, ['88081226000032']);
    expect(find.text('88081226000032'), findsWidgets);
  });

  // Phím "tìm" trên bàn phím là đường thứ hai của cùng một việc.
  testWidgets('gõ mã rồi bấm phím tìm trên bàn phím thì hiện đơn', (
    tester,
  ) async {
    final asked = <String>[];
    await _pump(
      tester,
      EcCreateClaimScreen(
        onSearch: (q) async {
          asked.add(q);
          return const [_hit];
        },
      ),
    );

    await tester.enterText(
      find.byType(EditableText).last,
      '88081226000032',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(asked, ['88081226000032']);
    expect(find.text('88081226000032'), findsWidgets);
  });

  // Khoảng trắng thừa hai đầu là chuyện thường khi dán mã từ tin nhắn của sàn.
  testWidgets('mã dán kèm khoảng trắng vẫn tra được', (tester) async {
    final asked = <String>[];
    await _pump(
      tester,
      EcCreateClaimScreen(
        onSearch: (q) async {
          asked.add(q);
          return const [_hit];
        },
      ),
    );

    await tester.enterText(
      find.byType(EditableText).last,
      '  88081226000032  ',
    );
    await tester.tap(find.byIcon(LucideIcons.search));
    await tester.pumpAndSettle();

    expect(asked, ['88081226000032'], reason: 'gửi lên máy chủ cả khoảng trắng');
  });
}

// Lượt tra HỎNG khác hẳn tra xong không thấy đơn nào.
//
// Trước đây `_search` ở app shell nuốt mọi lỗi rồi trả danh sách rỗng, nên màn
// hình nói "không tìm thấy mã" trong khi thứ vừa xảy ra là mạng chết hoặc máy
// chủ 500. Hai câu đó dẫn người bán đi hai hướng khác hẳn: một cái bảo họ gõ
// lại mã họ vừa gõ đúng, cái kia bảo họ thử lại sau.
//
// Nguy hơn: đường tra gọi chi tiết từng đơn tìm được, nên MỘT lỗi ở đường chi
// tiết đơn cũng biến thành "mã không tồn tại" — đúng triệu chứng "quét thì ra,
// gõ tay thì không".
void _searchFailureTests() {
  testWidgets('lượt tra hỏng thì báo thử lại, không báo không tìm thấy', (
    tester,
  ) async {
    await _pump(
      tester,
      EcCreateClaimScreen(
        onSearch: (_) async => throw Exception('máy chủ 500'),
      ),
    );

    await tester.enterText(find.byType(EditableText).last, '88081226000032');
    await tester.tap(find.byIcon(LucideIcons.search));
    await tester.pumpAndSettle();

    expect(find.textContaining('Không tìm thấy'), findsNothing);
    expect(find.byIcon(LucideIcons.wifiOff), findsOneWidget);
  });

  testWidgets('tra xong không có đơn nào thì vẫn báo không tìm thấy', (
    tester,
  ) async {
    await _pump(
      tester,
      EcCreateClaimScreen(onSearch: (_) async => const []),
    );

    await tester.enterText(find.byType(EditableText).last, '99999999');
    await tester.tap(find.byIcon(LucideIcons.search));
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.searchX), findsOneWidget);
    expect(find.byIcon(LucideIcons.wifiOff), findsNothing);
  });
}

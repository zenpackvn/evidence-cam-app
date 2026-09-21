import 'package:feature_capture/feature_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:localization/localization.dart';

/// Tour dò đích THEO NHÃN CHỮ. Nhãn không có trên màn thì tour im lặng bỏ qua
/// — không lỗi, không cảnh báo, chỉ là không có hướng dẫn.
///
/// Đã xảy ra: màn ghi hình neo vào "Đơn tiếp theo", nhãn ấy chỉ hiện SAU khi
/// quay xong một đơn. Lần đầu vào màn — đúng lúc cần hướng dẫn nhất — tour
/// không chạy, và không có gì báo. Người dùng phải tự phát hiện.
///
/// Bài này kiểm ĐIỀU KIỆN TIÊN QUYẾT của tour: nhãn được neo phải thật sự có
/// mặt lúc vừa vào màn.
void main() {
  testWidgets(
    'nhãn neo của tour màn ghi hình CÓ MẶT ngay khi vào màn',
    // Khung quét có hiệu ứng chạy liên tục nên `pumpAndSettle` không bao giờ
    // dừng; dùng `pump` với thời lượng cố định.
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
    (t) async {
      await t.pumpWidget(
        const MaterialApp(
          locale: Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EcWaitBill2Screen(),
        ),
      );
      await t.pump(const Duration(milliseconds: 400));

      final l10n = AppLocalizations.of(
        t.element(find.byType(EcWaitBill2Screen)),
      );
      expect(
        find.text(l10n.captureFramePrompt),
        findsWidgets,
        reason: 'chặng 1 của tour neo vào nhãn này',
      );
      expect(
        find.text(l10n.tooltipEnterTracking),
        findsWidgets,
        reason: 'chặng 2 của tour neo vào nhãn này',
      );
    },
  );
}

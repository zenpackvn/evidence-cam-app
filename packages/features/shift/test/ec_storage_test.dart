import 'package:app_ui/app_ui.dart';
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/cupertino.dart' show CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

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

void main() {
  group('EcStorageScreen', () {
    // Nhân viên phải ĐỌC được tình trạng kho: kho hỏng là chuyện xảy ra giữa
    // ca đóng hàng và họ là người chịu đầu tiên. Nhưng không được thấy nút đổi
    // kho — máy chủ trả `owner_only` và một cái nút chắc chắn 403 chỉ khiến
    // người dùng bấm đi bấm lại rồi kết luận app hỏng.
    testWidgets('nhân viên xem được tình trạng nhưng không có nút đổi kho', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(
            kind: EcStorageKind.s3,
            label: 'my-bucket/evidencecam',
            byosAllowed: true,
            health: EcStorageHealth(total: 10, intact: 10),
          ),
        ),
      );

      expect(find.text('my-bucket/evidencecam'), findsOneWidget);
      expect(find.text('Kiểm tra lại kết nối'), findsNothing);
      expect(find.text('Thôi dùng kho riêng'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('chủ shop đang dùng kho riêng thấy kiểm tra lại + gỡ kho', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(
            kind: EcStorageKind.s3,
            canManage: true,
            byosAllowed: true,
          ),
        ),
      );

      expect(find.text('Kiểm tra lại kết nối'), findsOneWidget);
      expect(find.text('Thôi dùng kho riêng'), findsOneWidget);
      expect(find.text('Cắm kho S3'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    // Gói chưa mở kho riêng thì nói thẳng ra. Ẩn im lặng nghĩa là người bán đọc
    // bảng giá thấy có tính năng rồi đi tìm trong app mãi không ra.
    testWidgets('gói chưa mở kho riêng thì hiện lý do, không hiện nút', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(state: EcStorageState(canManage: true)),
      );

      expect(find.textContaining('chưa mở kho riêng'), findsOneWidget);
      expect(find.text('Cắm kho S3'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('chủ shop ở kho hệ thống, gói có mở, thì thấy hai lối cắm', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(canManage: true, byosAllowed: true),
        ),
      );

      expect(find.text('Cắm kho S3'), findsOneWidget);
      expect(find.text('Kết nối Google Drive'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Ba con số vấn đề chỉ hiện khi khác 0. Bảng lúc nào cũng có "0 lỗi" thì
    // mắt bỏ qua nó rất nhanh, và đúng hôm có lỗi thật cũng không ai thấy.
    testWidgets('chỉ hiện dòng sự cố khi thật sự có sự cố', (tester) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(
            kind: EcStorageKind.s3,
            health: EcStorageHealth(total: 10, intact: 10),
          ),
        ),
      );
      expect(find.text('Không truy cập được'), findsNothing);

      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(
            kind: EcStorageKind.s3,
            health: EcStorageHealth(total: 10, intact: 8, unreachable: 2),
          ),
        ),
      );
      expect(find.text('Không truy cập được'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Hai cam kết không giữ được ở mọi kho. Người bán phải biết TRƯỚC, không
    // phải lúc đang tranh chấp với sàn.
    testWidgets('cảnh báo khi kho không ký được link hoặc không khoá được', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(
            kind: EcStorageKind.gdrive,
            presignedDownload: false,
          ),
        ),
      );

      expect(find.textContaining('không ký được link tải'), findsOneWidget);
      expect(find.textContaining('không khoá được đối tượng'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Ba thứ bản web có mà app từng nhận dữ liệu rồi bỏ không vẽ: nhãn "đang
    // dùng", mốc rà gần nhất, và tài khoản Drive. Không vẽ thì chủ shop mở app
    // ra chỉ thấy ba cái thẻ, không biết kho có được rà bao giờ chưa.
    testWidgets('hiện nhãn đang dùng, mốc rà gần nhất và tài khoản Drive', (
      tester,
    ) async {
      await _pump(
        tester,
        EcStorageScreen(
          state: EcStorageState(
            kind: EcStorageKind.gdrive,
            driveEmail: 'shop@gmail.com',
            health: EcStorageHealth(
              total: 3,
              intact: 3,
              // 2026-01-02 03:04 giờ máy.
              lastCheckedAt: DateTime(2026, 1, 2, 3, 4).millisecondsSinceEpoch,
            ),
          ),
        ),
      );

      expect(find.text('Đang dùng'), findsOneWidget);
      expect(find.text('Rà gần nhất: 02/01/2026 03:04'), findsOneWidget);
      expect(find.text('shop@gmail.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Chưa rà lần nào phải NÓI RA. Một bảng toàn số 0 không kèm mốc thời gian
    // đọc y hệt một cái kho hoàn hảo.
    testWidgets('chưa rà lần nào thì nói thẳng, không để trống', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(kind: EcStorageKind.s3),
        ),
      );

      expect(find.text('Chưa rà lần nào.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('EcStorageConnectScreen', () {
    testWidgets('nút lưu chỉ mở khi đủ bốn ô bắt buộc', (tester) async {
      await _pump(
        tester,
        EcStorageConnectScreen(
          onSubmit:
              ({
                required endpoint,
                required bucket,
                required accessKeyId,
                required secretAccessKey,
                required region,
                required prefix,
              }) {},
        ),
      );

      final button = find.text('Kiểm tra và lưu');
      expect(button, findsOneWidget);

      await tester.enterText(
        find.byType(CupertinoTextField).at(0),
        'https://s3.test',
      );
      await tester.enterText(find.byType(CupertinoTextField).at(1), 'bucket');
      await tester.enterText(find.byType(CupertinoTextField).at(2), 'AKIA');
      await tester.pump();
      // Mới ba ô — vẫn thiếu secret key, vòng kiểm tra chắc chắn đỏ.
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byType(CupertinoTextField).at(3), 'secret');
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    // `hint` là câu duy nhất nói được khách thiếu quyền nào bên nhà cung cấp.
    // Nuốt nó đi là để họ ngồi đoán.
    testWidgets('hiện nguyên văn câu chỉ dẫn lỗi từ máy chủ', (tester) async {
      await _pump(
        tester,
        EcStorageConnectScreen(
          errorText: 'Thiếu quyền s3:DeleteObject trên prefix evidencecam/',
          onSubmit:
              ({
                required endpoint,
                required bucket,
                required accessKeyId,
                required secretAccessKey,
                required region,
                required prefix,
              }) {},
        ),
      );

      expect(
        find.text('Thiếu quyền s3:DeleteObject trên prefix evidencecam/'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

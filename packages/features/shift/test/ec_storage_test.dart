import 'package:app_ui/app_ui.dart';
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/cupertino.dart' show CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
      // Kho đã cắm rồi thì nút là "Đổi cấu hình", không phải "Cắm kho S3".
      expect(find.text('Đổi cấu hình'), findsOneWidget);
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

    /// Chọn kho rồi mới LƯU — chạm vào thẻ không được tự cắm kho.
    ///
    /// Bản trước chạm là chạy thẳng luồng cắm: quệt tay vào thẻ Drive là màn
    /// cấp quyền Google bật lên. Đổi nơi cất bằng chứng của cả cửa hàng không
    /// phải việc nên xảy ra sau một cú chạm nhầm.
    testWidgets('chạm vào thẻ chỉ chọn, không chạy luồng cắm kho', (
      tester,
    ) async {
      var connectS3 = 0;
      var picked = 0;
      await _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true, byosAllowed: true),
          onConnectS3: () => connectS3++,
          onPick: (_) => picked++,
        ),
      );

      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();

      expect(connectS3, 0, reason: 'chạm thẻ đã chạy luồng cắm kho');
      // `onPick` ghi lựa chọn xuống máy, nên nó cũng phải đợi tới lúc lưu.
      expect(picked, 0, reason: 'ghi lựa chọn khi người dùng chưa xác nhận');
    });

    // Drive là thẻ duy nhất chạm là chạy: mọi thứ nằm trong hộp thoại của
    // Google, nên bắt bấm thêm nút Lưu chỉ là một cú chạm thừa trước một màn
    // hình người dùng vẫn còn huỷ được.
    testWidgets('chạm thẻ Drive là mở hộp thoại Google ngay', (tester) async {
      var opened = 0;
      await _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true, byosAllowed: true),
          onConnectDrive: () async {
            opened++;
            return true;
          },
        ),
      );

      await tester.tap(find.text('Google Drive'));
      await tester.pumpAndSettle();

      expect(opened, 1);
    });

    // Huỷ ở hộp thoại Google thì dấu tích phải quay về kho đang thật sự dùng.
    // Đây là thứ khiến chạm-là-chạy an toàn: quệt nhầm không để lại dấu vết.
    testWidgets('huỷ hộp thoại Google thì dấu tích về Cloud Zenpack', (
      tester,
    ) async {
      await _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true, byosAllowed: true),
          onConnectDrive: () async => false,
        ),
      );

      await tester.tap(find.text('Google Drive'));
      await tester.pumpAndSettle();

      // Câu nói trước của Drive chỉ hiện khi thẻ Drive đang được chọn; nó biến
      // mất nghĩa là dấu tích đã rời khỏi Drive.
      expect(find.textContaining('mở màn cấp quyền của Google'), findsNothing);
      // Và nút Lưu tắt vì không còn thay đổi nào để lưu.
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Lưu lựa chọn kho'))
            .hasFlag(SemanticsFlag.isEnabled),
        isFalse,
      );
    });

    // Gói chưa mở kho riêng: chạm thẻ Drive KHÔNG được mở hộp thoại Google.
    testWidgets('gói chưa mở thì chạm Drive không mở hộp thoại', (
      tester,
    ) async {
      var opened = 0;
      await _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true),
          onConnectDrive: () async {
            opened++;
            return true;
          },
        ),
      );

      await tester.tap(find.text('Google Drive'));
      await tester.pumpAndSettle();

      expect(opened, 0);
    });

    // Lưu hỏng thì form PHẢI ở lại cùng thứ vừa gõ và lý do hỏng.
    //
    // Trước đây không: lưu xong `busy` tắt, kho vẫn như cũ vì máy chủ từ chối,
    // và nhánh "thao tác xong mà kho không đổi" cuốn phăng cả form lẫn sáu ô
    // ngay lúc câu lỗi hiện ra. Người dùng thấy thẻ đóng lại, không thấy gì
    // khác, và kết luận nút Lưu hỏng.
    testWidgets('lưu hỏng thì form ở lại kèm câu lỗi, không đóng sập', (
      tester,
    ) async {
      Future<void> pumpWith({required bool busy, String? error}) => _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true, byosAllowed: true),
          busy: busy,
          s3ErrorText: error,
          onSaveS3:
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

      await pumpWith(busy: false);
      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(CupertinoTextField).at(2),
        'my-bucket',
      );
      await tester.pumpAndSettle();

      // Đang gửi… — `pump` chứ không `pumpAndSettle`: nút Lưu lúc bận quay một
      // vòng xoay không bao giờ dừng, nên `pumpAndSettle` sẽ chờ tới hết giờ.
      await pumpWith(busy: true);
      await tester.pump();
      // …rồi máy chủ từ chối: hết bận, kèm câu lỗi.
      await pumpWith(busy: false, error: 'Thiếu quyền s3:PutObject');
      await tester.pumpAndSettle();

      expect(find.text('Endpoint'), findsOneWidget, reason: 'form đã đóng sập');
      expect(find.text('Thiếu quyền s3:PutObject'), findsOneWidget);
      expect(
        tester
            .widget<CupertinoTextField>(find.byType(CupertinoTextField).at(2))
            .controller
            ?.text,
        'my-bucket',
        reason: 'thứ vừa gõ bị xoá mất',
      );
    });

    // Chọn nhầm rồi đổi ý: Huỷ trả dấu tích về kho đang thật sự dùng, đóng
    // form và xoá trắng nó. Không có nút này thì người vừa chạm nhầm thẻ Drive
    // chỉ còn cách thoát khỏi màn rồi vào lại.
    testWidgets('bấm huỷ trả lựa chọn và form về như cũ', (tester) async {
      var cancelled = 0;
      await _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true, byosAllowed: true),
          onCancel: () => cancelled++,
          onSaveS3:
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

      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(CupertinoTextField).at(2),
        'my-bucket',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Hủy'));
      await tester.pumpAndSettle();

      expect(cancelled, 1);
      // Form đóng lại vì dấu tích đã về kho hệ thống.
      expect(find.text('Endpoint'), findsNothing);

      // Mở lại: sáu ô phải trắng, không còn thứ của lượt vừa bỏ.
      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CupertinoTextField>(find.byType(CupertinoTextField).at(2))
            .controller
            ?.text,
        isEmpty,
      );
    });

    // Chạm vào S3 là sổ ra nguyên form, không phải một dòng mô tả rồi bắt bấm
    // Lưu mới thấy ô nào cần điền.
    testWidgets('chọn S3 thì sổ nguyên form ngay trong thẻ', (tester) async {
      await _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true, byosAllowed: true),
          onSaveS3:
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

      expect(find.text('Endpoint'), findsNothing);

      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();

      for (final label in [
        'Endpoint',
        'Bucket',
        'Access key ID',
        'Secret access key',
        'Region',
        'Prefix',
      ]) {
        expect(find.text(label), findsOneWidget, reason: 'thiếu ô $label');
      }
    });

    // Nút Lưu gửi thẳng thứ vừa gõ. Đẩy sang một màn nữa để gõ lại đúng sáu ô
    // đó là bắt làm hai lần cho một việc.
    testWidgets('bấm lưu gửi thẳng giá trị trong form S3', (tester) async {
      String? sentBucket;
      String? sentRegion;
      await _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true, byosAllowed: true),
          onSaveS3:
              ({
                required endpoint,
                required bucket,
                required accessKeyId,
                required secretAccessKey,
                required region,
                required prefix,
              }) {
                sentBucket = bucket;
                sentRegion = region;
              },
        ),
      );

      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();

      // Nút Lưu còn tắt khi chưa đủ bốn ô bắt buộc.
      await tester.tap(find.bySemanticsLabel('Lưu lựa chọn kho'));
      await tester.pumpAndSettle();
      expect(sentBucket, isNull, reason: 'gửi đi khi form còn trống');

      // Thứ tự ô bám theo bản web: endpoint, region, bucket, prefix, key, secret.
      await tester.enterText(
        find.byType(CupertinoTextField).at(0),
        'https://s3.example.com',
      );
      await tester.enterText(
        find.byType(CupertinoTextField).at(2),
        'my-bucket',
      );
      await tester.enterText(find.byType(CupertinoTextField).at(4), 'AKIA123');
      await tester.enterText(find.byType(CupertinoTextField).at(5), 'secret');
      await tester.pumpAndSettle();
      // KHÔNG cuộn về nút: tiêu đề nằm ngoài vùng cuộn nên nút Lưu phải còn
      // nguyên trong khung nhìn sau khi điền hết form. Trước đây nó nằm ở
      // y = -68 và người dùng kết luận màn này không cho lưu.
      final saveRect = tester.getRect(
        find.bySemanticsLabel('Lưu lựa chọn kho'),
      );
      expect(
        saveRect.top,
        greaterThanOrEqualTo(0.0),
        reason: 'nút Lưu trôi khỏi màn hình: $saveRect',
      );
      await tester.tap(find.bySemanticsLabel('Lưu lựa chọn kho'));
      await tester.pumpAndSettle();

      expect(sentBucket, 'my-bucket');
      expect(sentRegion, 'auto', reason: 'region mặc định không đi theo');
    });

    // Câu `hint` của máy chủ ở lại cạnh mấy ô vừa gõ. Toast trôi mất trước khi
    // người ta kịp đọc xem thiếu quyền nào.
    testWidgets('lỗi máy chủ hiện nguyên văn ngay dưới form trong thẻ', (
      tester,
    ) async {
      await _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true, byosAllowed: true),
          s3ErrorText: 'Thiếu quyền s3:DeleteObject trên prefix',
          onSaveS3:
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

      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();

      expect(
        find.text('Thiếu quyền s3:DeleteObject trên prefix'),
        findsOneWidget,
      );
    });

    // Chạm là đọc được ngay. Trước đây phần mô tả chỉ mở ra cho kho ĐANG dùng,
    // nên muốn biết chọn Drive nghĩa là gì thì phải bấm Lưu rồi đi hết luồng
    // cấp quyền Google mới rõ — cam kết trước, đọc sau.
    testWidgets('chọn một kho chưa dùng thì mở phần nói trước ngay', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(canManage: true, byosAllowed: true),
        ),
      );

      final note = find.textContaining('mở màn cấp quyền của Google');
      expect(note, findsNothing, reason: 'chưa chọn đã mở phần nói trước');

      await tester.tap(find.text('Google Drive'));
      await tester.pumpAndSettle();

      expect(note, findsOneWidget);
      // Drive chắc chắn không ký được link tải — biết trước, nói trước.
      expect(find.textContaining('đi vòng qua máy chủ'), findsOneWidget);
    });

    // Chọn Cloud Zenpack trong lúc đang dùng kho riêng = sắp GỠ kho riêng. Câu
    // này phải đọc được TRƯỚC khi bấm Lưu, không phải trong hộp xác nhận hiện
    // ra sau đó.
    testWidgets('chọn kho hệ thống khi đang dùng kho riêng thì báo trước', (
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

      await tester.tap(find.text('Cloud Zenpack'));
      await tester.pumpAndSettle();

      expect(find.textContaining('sẽ gỡ kho riêng'), findsOneWidget);
    });

    // Gói chưa mở kho riêng: thẻ đã có dòng khoá của nó. Mô tả thêm một luồng
    // người dùng không đi được chỉ làm dòng khoá kia đọc như lời nói suông.
    testWidgets('gói chưa mở thì chọn Drive không hứa hẹn gì thêm', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(state: EcStorageState(canManage: true)),
      );

      await tester.tap(find.text('Google Drive'));
      await tester.pumpAndSettle();

      expect(find.textContaining('mở màn cấp quyền của Google'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('bấm lưu mới áp dụng lựa chọn vừa chọn', (tester) async {
      var connectS3 = 0;
      EcStorageKind? pickedKind;
      await _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true, byosAllowed: true),
          onConnectS3: () => connectS3++,
          onPick: (k) => pickedKind = k,
        ),
      );

      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Lưu lựa chọn kho'));
      await tester.pumpAndSettle();

      expect(connectS3, 1);
      expect(pickedKind, EcStorageKind.s3);
      expect(tester.takeException(), isNull);
    });

    // Nút lưu TẮT khi không có gì để lưu: một nút luôn sáng mà bấm vào không có
    // chuyện gì xảy ra thì lần sau người dùng không tin nó nữa.
    //
    // Ca này đo đúng cái nút bị tắt. Trong `_save()` còn một chốt `if (!_dirty)`
    // nữa — lớp thứ hai, và KHÔNG ca nào chạm tới được vì muốn tới đó thì nút
    // phải vừa sáng vừa không có thay đổi. Giữ nó làm lưới đỡ cho lần sửa sau,
    // nhưng đừng tin rằng nó đã được đo.
    testWidgets('không có thay đổi thì nút lưu tắt, bấm không chạy gì', (
      tester,
    ) async {
      var connectS3 = 0;
      await _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true, byosAllowed: true),
          onConnectS3: () => connectS3++,
        ),
      );

      await tester.tap(
        find.bySemanticsLabel('Lưu lựa chọn kho'),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(connectS3, 0);
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

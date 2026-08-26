import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

/// Sample queue rendered by these tests. It used to ship inside
/// `ec_flow3.dart` as `ecDefaultUploadItems`; no production caller ever
/// read it, so the made-up orders live here now.
const List<EcUploadItem> _sampleUploadItems = [
  EcUploadItem(
    code: 'SPXVN024567890',
    typeLabel: 'Đóng hàng đi',
    when: '17/08/2026 10:23',
    status: EcUploadStatus.uploading,
    progressPercent: 72,
  ),
  EcUploadItem(
    code: 'SPXVN098765432',
    typeLabel: 'Đóng hàng đi',
    when: '17/08/2026 10:28',
    status: EcUploadStatus.waiting,
  ),
  EcUploadItem(
    code: 'SPXVN011122233',
    typeLabel: 'Đơn vị vận chuyển',
    when: '17/08/2026 10:40',
    status: EcUploadStatus.done,
  ),
  EcUploadItem(
    code: 'SPXVN044556677',
    typeLabel: 'Trả hàng',
    when: '17/08/2026 10:55',
    status: EcUploadStatus.error,
    retryCount: 2,
  ),
  EcUploadItem(
    code: 'SPXVN055667788',
    typeLabel: 'Đóng hàng đi',
    when: '17/08/2026 11:02',
    status: EcUploadStatus.quotaWait,
  ),
];

/// Chữ của chrome lấy TỪ ĐIỂN, không ghim.
///
/// Ba khẳng định trong file này từng ghim chuỗi tiếng Việt và mục rữa khi nhãn
/// đổi — `EcManualEntryScreen` là ví dụ: tiêu đề đổi từ "Nhập tay mã vận đơn"
/// sang "Nhập mã vận đơn" và test đỏ, dù màn vẫn đúng. Đọc qua getter thì test
/// bám nguồn sự thật, và vẫn đỏ thật nếu màn gọi nhầm khoá.
late AppLocalizations vi;

Future<void> _pump(WidgetTester tester, Widget screen) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      home: screen,
    ),
  );
}

/// Assert on the tab bar itself rather than its labels: the design titles the
/// recording screens "Ghi hình", which is also a tab label.
void _expectCameraBottomTabsHidden() {
  expect(find.byType(PenTabBar), findsNothing);
  expect(find.text('Vận đơn'), findsNothing);
  expect(find.text('Tài khoản'), findsNothing);
}

void main() {
  setUpAll(() async {
    vi = await AppLocalizations.delegate.load(const Locale('vi'));
  });

  group('EcWaitBill2Screen', () {
    testWidgets('shows idle hint, upload chip and camera rail', (
      tester,
    ) async {
      await _pump(
        tester,
        EcWaitBill2Screen(
          onResolution: () {},
          onManualEntry: () {},
        ),
      );
      // The camera header is back button + upload chip only — no shop title.
      expect(find.text('Shop ABC'), findsNothing);
      expect(find.text('3'), findsOneWidget);
      // Hai dòng gợi ý lấy nguyên văn khung F3-01 (CenterHint > T và S).
      expect(find.text('Quét mã vận đơn'), findsOneWidget);
      expect(find.text('Đưa bill vào khung'), findsOneWidget);
      expect(find.text('Đóng hàng'), findsOneWidget);
      // Không còn chip "1x": mức zoom nay đổi bằng cử chỉ CHỤM trên khung ngắm
      // (`ec_record_route.dart`, onScaleUpdate), không phải một nhãn bấm được.
      // Chức năng còn nguyên, chỉ nhãn của bản mock là mất.
      expect(find.text('1x'), findsNothing);
      expect(find.text('720p'), findsOneWidget);
      expect(find.byIcon(LucideIcons.keyboard), findsOneWidget);
      // Idle — no stop button yet.
      expect(find.byIcon(LucideIcons.check), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping the upload chip fires onQueueTap', (tester) async {
      var taps = 0;
      await _pump(tester, EcWaitBill2Screen(onQueueTap: () => taps++));
      await tester.tap(find.byIcon(LucideIcons.cloudUpload));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('hides the bottom tab bar while inside camera screens', (
      tester,
    ) async {
      await _pump(tester, const EcWaitBill2Screen());
      _expectCameraBottomTabsHidden();

      await _pump(tester, const EcRecording2Screen(code: 'SPXVN024567890'));
      _expectCameraBottomTabsHidden();

      await _pump(tester, const EcNearLimitScreen(code: 'SPXVN024567890'));
      _expectCameraBottomTabsHidden();

      await _pump(
        tester,
        const EcReturnRecScreen(code: 'SPXVN088877766 (hoàn)'),
      );
      _expectCameraBottomTabsHidden();

      await _pump(
        tester,
        const EcCutoverBScreen(
          closedCode: 'SPXVN024567890',
          newCode: 'SPXVN098765432',
        ),
      );
      _expectCameraBottomTabsHidden();
      expect(tester.takeException(), isNull);
    });

    testWidgets('back and type chip callbacks fire', (tester) async {
      var backTapped = false;
      var typeTapped = false;
      await _pump(
        tester,
        EcWaitBill2Screen(
          onBack: () => backTapped = true,
          onPickType: () => typeTapped = true,
        ),
      );
      await tester.tap(find.byIcon(LucideIcons.chevronLeft));
      await tester.tap(find.text('Đóng hàng'));
      expect(backTapped, isTrue);
      expect(typeTapped, isTrue);
    });
  });

  group('EcRecording2Screen', () {
    testWidgets('shows mã vận đơn and REC dot', (tester) async {
      await _pump(tester, const EcRecording2Screen(code: 'SPXVN024567890'));
      expect(find.text('SPXVN024567890'), findsOneWidget);
      expect(find.text('REC'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stop button fires onStop', (tester) async {
      var stopped = false;
      await _pump(
        tester,
        EcRecording2Screen(
          code: 'SPXVN024567890',
          onStop: () => stopped = true,
        ),
      );
      await tester.tap(find.byTooltip('Dừng quay'));
      expect(stopped, isTrue);
    });
  });

  group('EcCutoverBScreen', () {
    testWidgets('shows closed order A summary and new order B badge', (
      tester,
    ) async {
      // queueCount lệch 3 có chủ ý — xưa là để phân biệt với vòng đếm ngược;
      // nay vòng đó đã bỏ (commit ac322915, đợt QA 01/08), nên con số duy nhất
      // trên màn là chip hàng đợi. Giữ 7 để khẳng định dưới nói được điều đó.
      await _pump(
        tester,
        const EcCutoverBScreen(
          closedCode: 'SPXVN024567890',
          newCode: 'SPXVN098765432',
          queueCount: 7,
        ),
      );
      // Khung F3-04: mã vừa chốt ở pill trên, xác nhận đã lưu, vòng đếm ngược,
      // rồi thẻ đơn kế tiếp. Cả bốn đều là thông tin, không phải trang trí —
      // thiếu cái nào là người quay mất một câu trả lời.
      expect(find.text('SPXVN024567890'), findsOneWidget);
      expect(find.text('Đã lưu video'), findsOneWidget);
      // Vòng đếm ngược đã bỏ khỏi màn này; chip hàng đợi là con số duy nhất.
      expect(find.text('3'), findsNothing);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Chuẩn bị ghi hình tiếp theo'), findsOneWidget);
      expect(find.text('Đơn tiếp theo'), findsOneWidget);
      expect(find.text('SPXVN098765432'), findsOneWidget);
      expect(find.text('Đóng hàng • 10:28'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('onStop fires from the stop button', (tester) async {
      var stopped = false;
      await _pump(
        tester,
        EcCutoverBScreen(
          closedCode: 'SPXVN024567890',
          newCode: 'SPXVN098765432',
          onStop: () => stopped = true,
        ),
      );
      await tester.tap(find.byTooltip('Dừng quay'));
      expect(stopped, isTrue);
    });
  });

  group('EcNearLimitScreen', () {
    testWidgets('shows the 15-minute warning banner', (tester) async {
      await _pump(tester, const EcNearLimitScreen(code: 'SPXVN024567890'));
      expect(
        find.text('Sắp chạm trần 2 phút — video sẽ tự chốt'),
        findsOneWidget,
      );
      expect(find.text('SPXVN024567890'), findsOneWidget);
      expect(find.text('14:12'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('EcReturnRecScreen', () {
    testWidgets('shows return code, duration and link note', (tester) async {
      await _pump(
        tester,
        const EcReturnRecScreen(code: 'SPXVN088877766 (hoàn)'),
      );
      expect(find.text('SPXVN088877766 (hoàn)'), findsOneWidget);
      expect(find.text('00:32'), findsOneWidget);
      expect(find.text('Tự liên kết về hồ sơ mã vận đơn gốc'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('EcUploadQueueScreen', () {
    testWidgets('renders the queue list and every status variant', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcUploadQueueScreen(items: _sampleUploadItems),
      );
      expect(find.text('Hàng đợi upload'), findsOneWidget);
      expect(find.text('72%'), findsOneWidget);
      expect(find.text('Chờ upload'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
      // Nhãn đổi từ "Chờ quota": clip chờ hạn mức vẫn nằm TRÊN MÁY, và câu cũ
      // đọc như máy chủ đang giữ hộ — đúng cái hiểu nhầm nguy hiểm nhất ở đây.
      expect(find.text('Chờ hạn mức · còn trên máy'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Mỗi dòng chỉ được nói trạng thái đúng một lần — trước đây vừa có dòng
    // chữ dưới meta vừa có icon bên phải.
    testWidgets('states are not spelled out twice per row', (tester) async {
      await _pump(
        tester,
        const EcUploadQueueScreen(items: _sampleUploadItems),
      );
      expect(find.text('Đang tải 72%'), findsNothing);
      expect(find.text('Đã upload'), findsNothing);
      expect(find.textContaining('Tất cả ('), findsNothing);
      expect(find.textContaining('video đang chờ'), findsNothing);
    });

    testWidgets('retry callback fires', (tester) async {
      EcUploadItem? retried;
      await _pump(
        tester,
        EcUploadQueueScreen(
          items: _sampleUploadItems,
          onRetry: (item) => retried = item,
        ),
      );
      await tester.tap(find.text('Thử lại'));
      expect(retried?.status, EcUploadStatus.error);
    });

    // Clip đã lên xong thì bấm thẳng vào hàng là xem lại được — không phải
    // thoát ra, vào Vận đơn, tìm đúng mã rồi mới mở.
    testWidgets('bấm vào hàng đã upload thì gọi onOpen', (tester) async {
      EcUploadItem? opened;
      await _pump(
        tester,
        EcUploadQueueScreen(
          items: const [
            EcUploadItem(
              code: 'SPXVN011122233',
              typeLabel: 'Đơn vị vận chuyển',
              when: '17/08/2026 10:40',
              status: EcUploadStatus.done,
              playable: true,
            ),
          ],
          onOpen: (item) => opened = item,
        ),
      );

      await tester.tap(find.text('SPXVN011122233'));
      expect(opened?.code, 'SPXVN011122233');
    });

    // Không có dấu hiệu nào thì không ai đoán được hàng này bấm vào được, và
    // tính năng coi như không tồn tại.
    testWidgets('hàng xem được có dấu phát, hàng chưa lên thì không', (
      tester,
    ) async {
      await _pump(
        tester,
        EcUploadQueueScreen(
          items: const [
            EcUploadItem(
              code: 'DA-LEN',
              typeLabel: 'Đóng hàng đi',
              when: '17/08/2026 10:40',
              status: EcUploadStatus.done,
              playable: true,
            ),
            EcUploadItem(
              code: 'DANG-LEN',
              typeLabel: 'Đóng hàng đi',
              when: '17/08/2026 10:41',
              status: EcUploadStatus.uploading,
              progressPercent: 30,
            ),
          ],
          onOpen: (_) {},
        ),
      );

      expect(find.byIcon(LucideIcons.circlePlay), findsOneWidget);
    });

    // Chưa lên xong thì thứ duy nhất tồn tại là tệp thô trên máy. Hàng đợi cố ý
    // không mời người dùng xem nó.
    testWidgets('hàng chưa upload xong bấm vào không mở gì', (tester) async {
      var opened = 0;
      await _pump(
        tester,
        EcUploadQueueScreen(
          items: _sampleUploadItems,
          onOpen: (_) => opened++,
        ),
      );

      await tester.tap(find.text('SPXVN024567890'));
      await tester.tap(find.text('SPXVN011122233'));
      expect(opened, 0);
    });

    // Người cầm máy thường không phải người trả tiền, và quy tắc chống dẫn dắt
    // của Apple (App Review 3.1) cấm mọi lối chỉ sang trang thanh toán trong
    // app. Hàng rào: thêm lại link "Nâng gói" vào băng hạn mức là test đỏ.
    testWidgets('băng hạn mức KHÔNG có lối dẫn sang thanh toán', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcUploadQueueScreen(items: _sampleUploadItems),
      );
      expect(find.text('Nâng gói'), findsNothing);
      expect(find.text('Nâng cấp'), findsNothing);
    });

    // Hiểu nhầm nguy hiểm nhất ở màn này là tưởng máy chủ đang giữ hộ clip.
    // Băng cảnh báo phải nói thẳng: chúng đang nằm trên chính cái máy này.
    testWidgets('băng hạn mức nói rõ clip đang nằm trên máy', (tester) async {
      await _pump(
        tester,
        const EcUploadQueueScreen(items: _sampleUploadItems),
      );
      expect(find.textContaining('TRÊN MÁY NÀY'), findsOneWidget);
      expect(
        find.textContaining('Đừng gỡ app hay xoá dữ liệu app'),
        findsOneWidget,
      );
    });

    // FR-02 — Nhân viên không được xóa bằng chứng. Vai trò được chuyển xuống
    // đây bằng cách bỏ trống `onDelete` (xem `_QueueRoute` ở lib/ec_app.dart),
    // nên hàng đợi phải giấu hẳn nút xóa chứ không chỉ vô hiệu hóa nó.
    testWidgets('hides the delete affordance when deleting is not allowed', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcUploadQueueScreen(items: _sampleUploadItems),
      );
      expect(find.bySemanticsLabel('Xóa'), findsNothing);

      await _pump(
        tester,
        EcUploadQueueScreen(
          items: _sampleUploadItems,
          onDelete: (_) {},
        ),
      );
      expect(find.bySemanticsLabel('Xóa'), findsWidgets);
    });
  });

  group('EcManualEntryScreen', () {
    testWidgets('shows the manual entry sheet', (tester) async {
      await _pump(tester, const EcManualEntryScreen());
      expect(find.text(vi.manualTrackingTitle), findsOneWidget);
      expect(find.text(vi.commonCancel), findsOneWidget);
      expect(find.text(vi.startRecording), findsOneWidget);
      // Phụ đề "Dùng khi bill mờ — không quá 10 giây" đã bỏ khỏi cả màn lẫn từ
      // điển; trước thay đổi này nó chỉ còn tồn tại trong chính dòng test cũ.
      expect(find.textContaining('Dùng khi bill mờ'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('submit fires onManualSubmit with the typed code', (
      tester,
    ) async {
      String? submitted;
      await _pump(
        tester,
        EcManualEntryScreen(onManualSubmit: (value) => submitted = value),
      );
      await tester.enterText(find.byType(EditableText), 'SPXVN000111222');
      await tester.tap(find.text('Bắt đầu quay'));
      expect(submitted, 'SPXVN000111222');
    });

    testWidgets('cancel fires onCancel', (tester) async {
      var cancelled = false;
      await _pump(
        tester,
        EcManualEntryScreen(onCancel: () => cancelled = true),
      );
      await tester.tap(find.text('Hủy'));
      expect(cancelled, isTrue);
    });
  });

  group('EcNoMatchScreen', () {
    testWidgets('shows the no-match dialog copy', (tester) async {
      await _pump(
        tester,
        const EcNoMatchScreen(
          returnCode: 'SPXVN099988877',
          shopName: 'Shop ABC',
        ),
      );
      expect(find.text('Mã hoàn không khớp'), findsOneWidget);
      expect(find.textContaining('SPXVN099988877'), findsOneWidget);
      expect(find.text('Nhập tay mã'), findsOneWidget);
      expect(find.text('Tạo vận đơn mới'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('create-new callback fires', (tester) async {
      var created = false;
      await _pump(
        tester,
        EcNoMatchScreen(
          returnCode: 'SPXVN099988877',
          shopName: 'Shop ABC',
          onCreateNew: () => created = true,
        ),
      );
      await tester.tap(find.text('Tạo vận đơn mới'));
      expect(created, isTrue);
    });
  });

  group('EcTypeSheetScreen', () {
    testWidgets('shows all built-in types locked, with current selection', (
      tester,
    ) async {
      await _pump(tester, const EcTypeSheetScreen());
      // Khung F3-09: tiêu đề đầy đủ, và loại được chia hai nhóm có đề mục.
      expect(find.text('Chọn loại video'), findsOneWidget);
      expect(find.text('Loại mặc định (bắt buộc)'), findsOneWidget);
      // Chưa có loại tùy chỉnh nào thì đề mục nhóm đó phải biến mất hẳn.
      expect(find.text('Loại tùy chỉnh của shop'), findsNothing);
      expect(find.text('Đóng hàng'), findsOneWidget);
      expect(find.text('Đơn vị vận chuyển'), findsOneWidget);
      expect(find.text('Trả hàng'), findsOneWidget);
      expect(find.byIcon(LucideIcons.lock), findsNWidgets(3));
      expect(find.byIcon(LucideIcons.check), findsOneWidget);
      expect(
        find.text('Quản lý loại video — mở Chi tiết shop'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('selecting a type and manage callbacks fire', (
      tester,
    ) async {
      String? selected;
      var managed = false;
      await _pump(
        tester,
        EcTypeSheetScreen(
          types: const [
            ...ecDefaultVideoTypes,
            EcVideoType(label: 'Cân hàng', icon: Icons.scale_outlined),
          ],
          onSelectType: (type) => selected = type.label,
          onManageTypes: () => managed = true,
        ),
      );
      await tester.tap(find.text('Cân hàng'));
      await tester.tap(find.text('Quản lý loại video — mở Chi tiết shop'));
      expect(selected, 'Cân hàng');
      expect(managed, isTrue);
    });
  });
}

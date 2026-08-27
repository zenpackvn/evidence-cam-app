import 'dart:ui' show Tristate;

import 'package:app_ui/app_ui.dart';
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/cupertino.dart' show CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

/// Màn đang cắm S3, đủ dữ liệu để bấm "Đổi cấu hình".
EcStorageScreen _editableS3Screen() => const EcStorageScreen(
  state: EcStorageState(
    kind: EcStorageKind.s3,
    configuredKind: EcStorageKind.s3,
    configuredKinds: {EcStorageKind.s3},
    label: 'my-bucket/evidencecam',
    canManage: true,
    byosAllowed: true,
    s3Endpoint: 'https://s3.example.com',
    s3Region: 'auto',
    s3Bucket: 'my-bucket',
    s3Prefix: 'evidencecam',
  ),
  onSaveS3: _noopS3,
  onTestS3: _noopS3,
);

/// Điền đủ sáu ô để `_s3.ready` bật — thứ đang soi là nút Lưu, không phải form.
Future<void> _fillS3(WidgetTester tester) async {
  final fields = find.byType(CupertinoTextField);
  const values = [
    'https://s3.example.com',
    'auto',
    'my-bucket',
    'evidencecam',
    'AKIAXXXX',
    'secret',
  ];
  for (
    var i = 0;
    i < values.length && i < tester.widgetList(fields).length;
    i++
  ) {
    await tester.enterText(fields.at(i), values[i]);
  }
  await tester.pump();
}

/// Nút Lưu có bấm được không, đọc qua nhãn semantics của nó.
bool _saveEnabled(WidgetTester tester) {
  final node = tester.getSemantics(find.bySemanticsLabel('Lưu lựa chọn kho'));
  return node.flagsCollection.isEnabled == Tristate.isTrue;
}

/// Không làm gì — mấy test dưới soi NÚT NÀO hiện ra và bấm được, không soi
/// việc nút làm.
void _noopS3({
  required String endpoint,
  required String bucket,
  required String accessKeyId,
  required String secretAccessKey,
  required String region,
  required String prefix,
}) {}

void main() {
  group('EcStorageScreen', () {
    // Một shop giữ được tài khoản của CẢ HAI kho riêng. Chọn kho này không xoá
    // kho kia — nên cả hai thẻ đều phải chạm được, và chọn lại thẻ đang có tài
    // khoản chỉ là bật công tắc chứ không phải nhập lại từ đầu.
    testWidgets('cắm cả hai kho: chọn kho kia là bật lại, không nhập lại', (
      tester,
    ) async {
      EcStorageKind? resumed;
      await _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(
            kind: EcStorageKind.gdrive,
            configuredKind: EcStorageKind.gdrive,
            configuredKinds: {EcStorageKind.gdrive, EcStorageKind.s3},
            label: 'ZenPack/video',
            canManage: true,
            byosAllowed: true,
          ),
          onResumeStorage: (kind) => resumed = kind,
          onSaveS3: _noopS3,
          onTestS3: _noopS3,
        ),
      );

      // Chọn thẻ S3 — đã có tài khoản nên KHÔNG mở form nhập lại.
      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();
      expect(
        find.byType(CupertinoTextField),
        findsNothing,
        reason: 'đã có tài khoản mà vẫn bắt nhập lại',
      );

      await tester.tap(find.bySemanticsLabel('Lưu lựa chọn kho'));
      await tester.pumpAndSettle();

      expect(resumed, EcStorageKind.s3);
    });

    // Đổi cấu hình mà chưa đổi gì thì không có gì để thử: một lượt gọi ra kho
    // khách chỉ để xác nhận điều đã biết.
    testWidgets('đổi cấu hình: chưa sửa gì thì chưa có nút Kiểm tra', (
      tester,
    ) async {
      await _pump(tester, _editableS3Screen());

      await tester.tap(find.text('Đổi cấu hình'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoTextField), findsWidgets);
      expect(find.bySemanticsLabel('Kiểm tra'), findsNothing);
    });

    // Sửa MỘT ô là đủ. Và không đòi gõ lại cặp khoá: khoá bí mật không bao giờ
    // rời máy chủ, nên bắt điền lại là bắt người bán đi tìm lại khoá chỉ để sửa
    // một chữ trong tên bucket.
    testWidgets('đổi cấu hình: sửa một ô là hiện Kiểm tra, không đòi khoá', (
      tester,
    ) async {
      await _pump(tester, _editableS3Screen());

      await tester.tap(find.text('Đổi cấu hình'));
      await tester.pumpAndSettle();

      // Ô thứ ba là Bucket — thứ tự bám bản web: endpoint, region, bucket…
      await tester.enterText(
        find.byType(CupertinoTextField).at(2),
        'bucket-moi',
      );
      await tester.pump();

      final test = find.bySemanticsLabel('Kiểm tra');
      expect(test, findsOneWidget);
      expect(
        tester.getSemantics(test).flagsCollection.isEnabled,
        Tristate.isTrue,
        reason: 'còn đòi gõ lại cặp khoá',
      );
    });

    // Drive đã có tài khoản thì chạm vào thẻ chỉ là CHỌN, không mở lại màn cấp
    // quyền của Google — tài khoản đang nằm sẵn trên máy chủ.
    testWidgets('Drive đã cắm: chạm thẻ không mở lại màn cấp quyền', (
      tester,
    ) async {
      var consentOpened = 0;
      await _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(
            kind: EcStorageKind.s3,
            configuredKind: EcStorageKind.s3,
            configuredKinds: {EcStorageKind.s3, EcStorageKind.gdrive},
            label: 'my-bucket/evidencecam',
            canManage: true,
            byosAllowed: true,
          ),
          onConnectDrive: () async {
            consentOpened++;
            return true;
          },
          onResumeStorage: (_) {},
          onSaveS3: _noopS3,
          onTestS3: _noopS3,
        ),
      );

      await tester.tap(find.text('Google Drive'));
      await tester.pumpAndSettle();

      expect(consentOpened, 0);
    });

    // Kiểm tra là CỬA duy nhất dẫn tới nút Lưu.
    //
    // Lưu là THAY cái kho đang giữ bằng chứng. Một cấu hình sai được lưu thì
    // clip quay sau đó không có chỗ nào nhận, mà người bán chỉ biết khi mở đơn
    // ra tìm video — bắt thử trước biến một hỏng-về-sau thành một câu-lỗi-ngay.
    testWidgets('cắm lần đầu: có nút Kiểm tra, Lưu khoá cho tới khi thử xanh', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(canManage: true, byosAllowed: true),
          onSaveS3: _noopS3,
          onTestS3: _noopS3,
        ),
      );

      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Kiểm tra'), findsOneWidget);
      expect(_saveEnabled(tester), isFalse);
    });

    // Bỏ trống cặp khoá chỉ có nghĩa khi máy chủ ĐANG giữ cặp khoá cũ để dùng
    // lại. Chưa cắm kho nào mà vẫn cho bấm Kiểm tra là gửi một cấu hình không
    // khoá ra mạng chỉ để nhận về đúng câu lỗi mà chính app đoán được từ trước.
    testWidgets('cắm lần đầu: chưa gõ khoá thì Kiểm tra vẫn khoá', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(canManage: true, byosAllowed: true),
          onSaveS3: _noopS3,
          onTestS3: _noopS3,
        ),
      );

      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();

      final fields = find.byType(CupertinoTextField);
      await tester.enterText(fields.at(0), 'https://s3.example.com');
      await tester.enterText(fields.at(2), 'my-bucket');
      await tester.pump();

      final test = find.bySemanticsLabel('Kiểm tra');
      expect(
        tester.getSemantics(test).flagsCollection.isEnabled,
        Tristate.isFalse,
        reason: 'chưa có khoá nào trên máy chủ để dùng lại',
      );

      await tester.enterText(fields.at(4), 'AKIAXXXX');
      await tester.enterText(fields.at(5), 'secret');
      await tester.pump();

      expect(
        tester.getSemantics(test).flagsCollection.isEnabled,
        Tristate.isTrue,
      );
    });

    // Luồng thật: điền ô → bấm Kiểm tra → máy chủ báo xanh → Lưu mở khoá.
    testWidgets('thử xanh rồi thì Lưu mở khoá', (tester) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(canManage: true, byosAllowed: true),
          onSaveS3: _noopS3,
          onTestS3: _noopS3,
        ),
      );
      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();
      await _fillS3(tester);
      expect(_saveEnabled(tester), isFalse, reason: 'chưa thử mà đã mở khoá');

      await tester.tap(find.bySemanticsLabel('Kiểm tra'));
      await tester.pump();
      // Máy chủ trả lời xanh: bên gọi bật cờ và dựng lại màn.
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(canManage: true, byosAllowed: true),
          s3TestPassed: true,
          onSaveS3: _noopS3,
          onTestS3: _noopS3,
        ),
      );
      await tester.pump();

      expect(_saveEnabled(tester), isTrue);
    });

    // Shop đã cắm S3 rồi tạm về Cloud Zenpack: "Đổi cấu hình" vẫn phải mở
    // được, mở ra có sẵn cấu hình cũ, và thử xanh thì lưu được — lưu ở đây
    // đồng thời là quay lại dùng S3.
    //
    // Trước đây hỏng cả ba: nút không kéo dấu tích sang thẻ S3 nên bấm vào
    // không có gì xảy ra, và `_prefillS3` bỏ qua khi kho đang dùng không phải
    // S3 nên form ra trắng.
    testWidgets('đang ở kho khác vẫn đổi được cấu hình S3 rồi lưu', (
      tester,
    ) async {
      const parked = EcStorageState(
        configuredKind: EcStorageKind.s3,
        configuredKinds: {EcStorageKind.s3},
        canManage: true,
        byosAllowed: true,
        s3Endpoint: 'https://s3.example.com',
        s3Region: 'auto',
        s3Bucket: 'my-bucket',
        s3Prefix: 'evidencecam',
        s3KeyMasked: '…abcd',
      );
      Future<void> pumpWith({bool busy = false, bool passed = false}) => _pump(
        tester,
        EcStorageScreen(
          state: parked,
          busy: busy,
          s3TestPassed: passed,
          onSaveS3: _noopS3,
          onTestS3: _noopS3,
        ),
      );

      await pumpWith();
      // KHÔNG chạm vào thẻ trước: bấm thẳng nút, đúng như người dùng làm.
      await tester.tap(find.text('Đổi cấu hình'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoTextField), findsNWidgets(6));
      final fields = find.byType(CupertinoTextField);
      expect(
        tester.widget<CupertinoTextField>(fields.at(0)).controller?.text,
        'https://s3.example.com',
      );
      expect(
        tester.widget<CupertinoTextField>(fields.at(2)).controller?.text,
        'my-bucket',
      );

      // Đổi bucket rồi thử: cặp khoá cũ máy chủ vẫn giữ nên không phải dán lại.
      await tester.enterText(fields.at(2), 'bucket-moi');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Kiểm tra'));
      await tester.pump();
      await pumpWith(busy: true);
      await pumpWith(passed: true);
      await tester.pump();

      expect(_saveEnabled(tester), isTrue);
      expect(tester.takeException(), isNull);
    });

    // Kho ĐANG LỖI thì nút Kiểm tra phải hiện dù chưa sửa gì.
    //
    // Đó đúng là lúc cần nó nhất: người dùng vừa sửa quyền bên phía nhà cung
    // cấp và muốn biết đã ăn chưa. Luật "chưa đổi gì thì không có gì để thử"
    // đúng với kho đang chạy, và sai hẳn với kho đang hỏng.
    testWidgets('kho đang lỗi thì Kiểm tra hiện sẵn, không đòi sửa bừa', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(
            kind: EcStorageKind.s3,
            configuredKind: EcStorageKind.s3,
            configuredKinds: {EcStorageKind.s3},
            label: 'evidencecam/video',
            ok: false,
            lastError: 's3_head_403',
            canManage: true,
            byosAllowed: true,
            s3Endpoint: 'https://s3-storage.example.vn',
            s3Region: 'us-east-1',
            s3Bucket: 'evidencecam',
            s3Prefix: 'video',
          ),
          onSaveS3: _noopS3,
          onTestS3: _noopS3,
        ),
      );
      await tester.tap(find.text('Đổi cấu hình'));
      await tester.pumpAndSettle();

      // Chưa gõ một ký tự nào.
      expect(find.bySemanticsLabel('Kiểm tra'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Khoá bí mật dài mấy chục ký tự và luôn được DÁN vào. Dán hụt một ký tự
    // thì máy chủ chỉ nói `SignatureDoesNotMatch` — câu không chỉ ra ô nào sai,
    // mà một hàng chấm tròn thì không soi lại được. Con mắt là đường duy nhất
    // để tự kiểm thứ vừa dán.
    // Bàn phím tiếng Việt gõ Telex biến `w` đứng một mình thành `ư`. Gõ tay
    // một khoá có chữ `W` là gửi đi một chuỗi khác thứ đang nhìn thấy, và kho
    // trả về `SignatureDoesNotMatch` — câu không hề nhắc tới bàn phím.
    testWidgets('ô khoá không nhận ký tự tiếng Việt', (tester) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(canManage: true, byosAllowed: true),
          onSaveS3: _noopS3,
          onTestS3: _noopS3,
        ),
      );

      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();

      final secret = find.byType(CupertinoTextField).at(5);
      await tester.enterText(secret, 'JIgkadGzR9PBaoIc9hƯMMQZLBw9Hd7dM');
      await tester.pump();

      expect(
        tester.widget<CupertinoTextField>(secret).controller!.text,
        'JIgkadGzR9PBaoIc9hMMQZLBw9Hd7dM',
        reason: 'ký tự có dấu phải bị chặn ngay ở ô, không đi ra máy chủ',
      );
    });

    testWidgets('ô khoá bí mật có con mắt để nhìn hoặc che lại', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(canManage: true, byosAllowed: true),
          onSaveS3: _noopS3,
          onTestS3: _noopS3,
        ),
      );
      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();

      // Sáu ô theo thứ tự endpoint · region · bucket · prefix · khoá · bí mật.
      bool secretHidden() => tester
          .widget<CupertinoTextField>(find.byType(CupertinoTextField).at(5))
          .obscureText;

      // Hình nói trạng thái ĐANG CÓ: che thì mắt gạch, hiện thì mắt mở.
      expect(secretHidden(), isTrue, reason: 'mở form ra là phải che sẵn');
      // Đúng MỘT con mắt: năm ô kia không có gì để giấu.
      expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);
      expect(find.byIcon(LucideIcons.eye), findsNothing);

      await tester.ensureVisible(find.byIcon(LucideIcons.eyeOff));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(LucideIcons.eyeOff));
      await tester.pump();
      expect(secretHidden(), isFalse);
      expect(find.byIcon(LucideIcons.eye), findsOneWidget);

      await tester.tap(find.byIcon(LucideIcons.eye));
      await tester.pump();
      expect(secretHidden(), isTrue);
      expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Thử XANH mà form vẫn phải ở lại.
    //
    // Bộ test cũ không dựng lại được lỗi này vì nó không mô phỏng `busy`: app
    // thật bật `busy` lúc gọi máy chủ rồi tắt khi có trả lời, và
    // `didUpdateWidget` đọc đúng cặp bật-tắt đó thành "thao tác xong mà kho
    // không đổi = người dùng huỷ" — nên một lượt thử THÀNH CÔNG đóng sập form
    // và cuốn theo sáu ô vừa gõ. Hậu quả người dùng thấy: thử được đúng một
    // lần, muốn thử lần nữa phải mở lại "Đổi cấu hình" và gõ lại từ đầu.
    testWidgets('thử xanh thì form ở lại, và thử lại được lần nữa', (
      tester,
    ) async {
      Future<void> pumpWith({bool busy = false, bool passed = false}) => _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true, byosAllowed: true),
          busy: busy,
          s3TestPassed: passed,
          onSaveS3: _noopS3,
          onTestS3: _noopS3,
        ),
      );

      await pumpWith();
      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();
      await _fillS3(tester);

      await tester.tap(find.bySemanticsLabel('Kiểm tra'));
      await tester.pump();
      // Máy chủ nhận lệnh (bận) rồi trả lời xanh (hết bận).
      await pumpWith(busy: true);
      await pumpWith(passed: true);
      await tester.pump();

      // Bàn phím phải thu lại: câu trả lời vẽ ngay dưới sáu ô, mà bàn phím che
      // đúng chỗ đó — bấm Kiểm tra xong nhìn màn hình không thấy gì đổi.
      expect(
        FocusManager.instance.primaryFocus?.context?.widget,
        isNot(isA<EditableText>()),
      );
      // Sáu ô còn nguyên, và câu trả lời nằm ngay cạnh chúng.
      expect(find.byType(CupertinoTextField), findsNWidgets(6));
      expect(
        find.text('Tài khoản này kết nối được. Bấm Lưu để dùng kho này.'),
        findsOneWidget,
      );
      expect(_saveEnabled(tester), isTrue);

      // Sửa tiếp một ký tự: câu trả lời cũ hết hiệu lực, Lưu khoá lại, và nút
      // Kiểm tra vẫn còn đó để thử bộ giá trị mới.
      await tester.enterText(
        find.byType(CupertinoTextField).at(2),
        'bucket-khac',
      );
      await tester.pump();
      expect(find.bySemanticsLabel('Kiểm tra'), findsOneWidget);
      expect(_saveEnabled(tester), isFalse);
      expect(
        find.text('Tài khoản này kết nối được. Bấm Lưu để dùng kho này.'),
        findsNothing,
      );

      await tester.tap(find.bySemanticsLabel('Kiểm tra'));
      await tester.pump();
      await pumpWith(busy: true);
      await pumpWith(passed: true);
      await tester.pump();
      expect(find.byType(CupertinoTextField), findsNWidgets(6));
      expect(_saveEnabled(tester), isTrue);
      expect(tester.takeException(), isNull);
    });

    // Thử ĐỎ thì form cũng ở lại — đã đúng từ trước, giữ lại để nhánh `_testing`
    // không vô tình cướp mất đường này.
    testWidgets('thử đỏ thì form ở lại cùng câu lỗi của máy chủ', (
      tester,
    ) async {
      Future<void> pumpWith({bool busy = false, String? error}) => _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true, byosAllowed: true),
          busy: busy,
          s3ErrorText: error,
          onSaveS3: _noopS3,
          onTestS3: _noopS3,
        ),
      );

      await pumpWith();
      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();
      await _fillS3(tester);
      await tester.tap(find.bySemanticsLabel('Kiểm tra'));
      await tester.pump();
      await pumpWith(busy: true);
      // Đúng chuỗi mà `_testS3` dựng: phán quyết một dòng, rồi tới lý do.
      await pumpWith(
        error:
            'Tài khoản này không kết nối được.\n'
            'AccessDenied: thiếu quyền s3:PutObject',
      );
      await tester.pump();

      expect(find.byType(CupertinoTextField), findsNWidgets(6));
      // Câu phán quyết đứng trước, lý do của nhà cung cấp đứng sau — bên gọi
      // ghép hai phần rồi mới đưa xuống (xem `_testS3` trong ec_app.dart).
      expect(
        find.text(
          'Tài khoản này không kết nối được.\n'
          'AccessDenied: thiếu quyền s3:PutObject',
        ),
        findsOneWidget,
      );
      expect(_saveEnabled(tester), isFalse);
      expect(find.bySemanticsLabel('Kiểm tra'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Thử xanh rồi đổi endpoint thì kết quả cũ không còn nói gì về bộ giá trị
    // đang nằm trên màn.
    testWidgets('sửa ô sau khi thử xanh thì Lưu khoá lại', (tester) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(canManage: true, byosAllowed: true),
          onSaveS3: _noopS3,
          onTestS3: _noopS3,
        ),
      );
      await tester.tap(find.text('Kho đám mây riêng (chuẩn S3)'));
      await tester.pumpAndSettle();
      await _fillS3(tester);
      await tester.tap(find.bySemanticsLabel('Kiểm tra'));
      await tester.pump();
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(canManage: true, byosAllowed: true),
          s3TestPassed: true,
          onSaveS3: _noopS3,
          onTestS3: _noopS3,
        ),
      );
      await tester.pump();
      expect(_saveEnabled(tester), isTrue);

      await tester.enterText(
        find.byType(CupertinoTextField).first,
        'https://doi-roi.example.com',
      );
      await tester.pump();

      expect(_saveEnabled(tester), isFalse);
    });

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

    testWidgets(
      'chủ shop đang dùng kho riêng thấy nút gỡ kho và đổi cấu hình',
      (
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

        expect(find.text('Thôi dùng kho riêng'), findsOneWidget);
        // Kho đã cắm rồi thì nút là "Đổi cấu hình", không phải "Cắm kho S3".
        expect(find.text('Đổi cấu hình'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    // Lý do khoá phải đọc được mà KHÔNG cần cuộn: nó nằm trên đầu ba thẻ.
    //
    // Trước đây nó ở đáy danh sách, dưới cả ba thẻ — ngoài khung nhìn trên
    // điện thoại. Người dùng thấy thẻ chạm được, dấu tích nhảy, nút Lưu không
    // bao giờ sáng, và không có gì trên màn nói vì sao.
    testWidgets('lý do khoá đứng trên ba thẻ, không nằm dưới đáy', (
      tester,
    ) async {
      Future<void> pumpWith(EcStorageState state) =>
          _pump(tester, EcStorageScreen(state: state));

      // Nhân viên: câu owner-only phải nằm CAO hơn thẻ đầu tiên.
      await pumpWith(const EcStorageState(byosAllowed: true));
      final ownerNote = find.textContaining('Chỉ chủ cửa hàng');
      expect(ownerNote, findsOneWidget);
      expect(
        tester.getTopLeft(ownerNote).dy,
        lessThan(tester.getTopLeft(find.text('Cloud Zenpack')).dy),
      );

      // Chủ shop nhưng gói chưa mở: đổi câu, vẫn đứng trên.
      await pumpWith(const EcStorageState(canManage: true));
      final planNote = find.textContaining('chưa mở kho riêng');
      expect(planNote, findsOneWidget);
      expect(
        tester.getTopLeft(planNote).dy,
        lessThan(tester.getTopLeft(find.text('Cloud Zenpack')).dy),
      );

      // Mở hết thì không có câu nào cả.
      await pumpWith(const EcStorageState(canManage: true, byosAllowed: true));
      expect(find.textContaining('Chỉ chủ cửa hàng'), findsNothing);
      expect(find.textContaining('chưa mở kho riêng'), findsNothing);
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

    // Thẻ Drive nói hết phần của nó NGAY LÚC VÀO MÀN, rồi chạm là mở Google.
    //
    // Hai vế đi với nhau: chạm vào Drive là màn Google bật lên ngay, nên nếu
    // phần mô tả chỉ mở khi thẻ được chọn thì nó chớp đúng một nhịp rồi bị che.
    testWidgets('thẻ Drive mở sẵn phần mô tả, rồi chạm là mở hộp thoại', (
      tester,
    ) async {
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

      // Chưa chạm gì: đã đọc được thẻ nói gì.
      expect(find.textContaining('Chưa cắm tài khoản nào'), findsOneWidget);
      expect(opened, 0);

      await tester.tap(find.text('Google Drive'));
      await tester.pumpAndSettle();
      expect(opened, 1);
    });

    // Huỷ ở hộp thoại Google thì dấu tích phải quay về kho đang thật sự dùng,
    // và KHÔNG được để lại dấu vết nào trong bộ nhớ máy.
    //
    // `onPick` ghi lựa chọn xuống máy. Bắn nó lúc mở hộp thoại — trước khi biết
    // người dùng có đồng ý không — thì bấm Huỷ xong lựa chọn "Drive" nằm lại:
    // thoát ra vào lại, màn hình đọc lựa chọn đó và vẽ thẻ Drive như kho đang
    // dùng, kèm nút "Đăng xuất khỏi Drive" cho một tài khoản chưa hề cắm.
    testWidgets('huỷ hộp thoại Google thì không ghi lựa chọn nào', (
      tester,
    ) async {
      var picked = 0;
      await _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true, byosAllowed: true),
          onConnectDrive: () async => false,
          onPick: (_) => picked++,
        ),
      );

      await tester.tap(find.text('Google Drive'));
      await tester.pumpAndSettle();

      expect(picked, 0, reason: 'ghi lựa chọn cho một lượt cắm đã bị huỷ');
      // Câu nói trước của Drive chỉ hiện khi thẻ Drive đang được chọn; nó biến
      // mất nghĩa là dấu tích đã rời khỏi Drive.
      expect(
        find.textContaining('bảng chọn tài khoản Google mở ra ngay'),
        findsNothing,
      );
      // Và nút Lưu tắt vì không còn thay đổi nào để lưu.
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Lưu lựa chọn kho'))
            .flagsCollection
            .isEnabled,
        Tristate.isFalse,
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

    // Gói chưa mở kho riêng: hai thẻ S3 và Drive KHÔNG chạm được.
    //
    // Trước đây chạm vẫn ăn — dấu tích nhảy sang, rồi nút Lưu không sáng và
    // người dùng tự đoán vì sao. Mời người ta bấm vào một thứ họ không dùng
    // được là tệ hơn không mời.
    testWidgets('gói chưa mở thì không chọn được S3 hay Drive', (tester) async {
      var picked = 0;
      await _pump(
        tester,
        EcStorageScreen(
          state: const EcStorageState(canManage: true),
          onPick: (_) => picked++,
        ),
      );

      for (final title in ['Kho đám mây riêng (chuẩn S3)', 'Google Drive']) {
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
      }

      // Dấu tích không nhúc nhích, và không có lượt ghi lựa chọn nào.
      expect(picked, 0);
      // Và lý do vì sao vẫn đọc được ngay trên thẻ.
      expect(find.textContaining('gói Chuyên nghiệp'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    // Hạ gói xuống mà kho riêng vẫn đang chạy: thẻ đó PHẢI còn chạm được, nếu
    // không thì shop kẹt với một cái kho họ không xem và không tháo ra được.
    // Máy chủ cũng cố ý không chặn hai việc ấy.
    testWidgets('gói đã hạ vẫn mở được thẻ của kho đang dùng', (tester) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(
            kind: EcStorageKind.gdrive,
            driveEmail: 'shop@gmail.com',
            canManage: true,
          ),
        ),
      );

      expect(find.text('shop@gmail.com'), findsOneWidget);
      expect(find.text('Đăng xuất khỏi Drive'), findsOneWidget);
      expect(tester.takeException(), isNull);
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

    // Phần mô tả của Drive mở SẴN, không đợi chạm.
    //
    // Trước đây nó chỉ mở cho kho đang dùng, nên muốn biết chọn Drive nghĩa là
    // gì thì phải bấm Lưu rồi đi hết luồng cấp quyền Google mới rõ — cam kết
    // trước, đọc sau. Rồi một bản nữa mở nó lúc chạm, mà chạm cũng chính là mở
    // màn Google, nên chữ chớp một nhịp rồi bị che.
    testWidgets('phần nói trước của Drive mở sẵn, không đợi chạm', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(canManage: true, byosAllowed: true),
        ),
      );

      expect(find.textContaining('Chưa cắm tài khoản nào'), findsOneWidget);
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

      expect(
        find.textContaining('bảng chọn tài khoản Google mở ra ngay'),
        findsNothing,
      );
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
      // Trên thẻ S3. Thẻ Drive cố ý KHÔNG vẽ hai câu này nữa — xem test dưới.
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(
            kind: EcStorageKind.s3,
            presignedDownload: false,
          ),
        ),
      );

      expect(find.textContaining('không ký được link tải'), findsOneWidget);
      expect(find.textContaining('không khoá được đối tượng'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Thẻ Drive chỉ giữ phần tài khoản đổ xuống.
    //
    // Bảng tình trạng, hai câu cảnh báo về cam kết và mốc rà gần nhất đều nói
    // về kho nói chung; với Drive thì thứ người ta mở thẻ ra để đọc chỉ có một
    // — đang cắm bằng tài khoản nào — và mọi dòng đứng trên nó chỉ đẩy câu trả
    // lời xuống dưới màn hình.
    testWidgets('thẻ Drive chỉ còn tài khoản, không bảng tình trạng', (
      tester,
    ) async {
      await _pump(
        tester,
        EcStorageScreen(
          state: EcStorageState(
            kind: EcStorageKind.gdrive,
            driveEmail: 'shop@gmail.com',
            presignedDownload: false,
            canManage: true,
            health: EcStorageHealth(
              total: 3,
              intact: 3,
              lastCheckedAt: DateTime(2026, 1, 2, 3, 4).millisecondsSinceEpoch,
            ),
          ),
        ),
      );

      // Kho đang dùng là Drive, tức thẻ Drive cũng đang được chọn: hiện đủ cả
      // tài khoản lẫn hai nút thao tác, không đợi cú chạm nào.
      expect(find.text('shop@gmail.com'), findsOneWidget);
      expect(find.text('Đăng xuất khỏi Drive'), findsOneWidget);
      expect(find.textContaining('Tình trạng kho'), findsNothing);
      expect(find.textContaining('Rà gần nhất'), findsNothing);
      expect(find.textContaining('không ký được link tải'), findsNothing);
      // Và cả dòng mô tả trên đầu thẻ cũng đã bỏ.
      expect(find.textContaining('không cần dán khoá'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    // Ba thứ bản web có mà app từng nhận dữ liệu rồi bỏ không vẽ: nhãn "đang
    // dùng", mốc rà gần nhất, và tài khoản Drive. Không vẽ thì chủ shop mở app
    // ra chỉ thấy ba cái thẻ, không biết kho có được rà bao giờ chưa.
    testWidgets('hiện nhãn đang dùng và mốc rà gần nhất', (tester) async {
      await _pump(
        tester,
        EcStorageScreen(
          state: EcStorageState(
            kind: EcStorageKind.s3,
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
      expect(tester.takeException(), isNull);
    });

    // Tài khoản Drive đang nằm chờ phải đọc được NGAY khi vào màn.
    //
    // Chủ shop đang ở Cloud Zenpack vẫn cần biết mình sắp bật lại tài khoản
    // nào. Trước đây thẻ chỉ mở một dòng chữ mô tả, còn email thì phải bấm Lưu
    // xong mới hiện — tức là cam kết trước, đọc sau. Rồi một bản nữa bắt chạm
    // một lần để đọc và chạm lần hai mới ra nút; giờ đọc được luôn, chạm một
    // lần là ra nút.
    testWidgets('kho đã cắm mà đang không dùng vẫn mở sẵn tài khoản', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(
            configuredKind: EcStorageKind.gdrive,
            driveEmail: 'shop@gmail.com',
            canManage: true,
            byosAllowed: true,
          ),
        ),
      );

      // Đang chỉ vào Cloud Zenpack: tài khoản vẫn đọc được, nhưng hai nút thao
      // tác thì không — chúng đổi nơi cất bằng chứng của cả cửa hàng, để nằm đó
      // lúc người dùng đang định rời khỏi Drive là mời bấm nhầm.
      expect(find.text('shop@gmail.com'), findsOneWidget);
      expect(find.text('Đăng xuất khỏi Drive'), findsNothing);

      // Chọn lại thẻ Drive thì hiện đủ. Nút gỡ nói bằng chữ của kho ĐÃ CẮM,
      // không phải kho đang dùng — lúc này kho đang dùng là Cloud Zenpack, mà
      // thứ nút đó gỡ là tài khoản Google.
      await tester.tap(find.text('Google Drive'));
      await tester.pumpAndSettle();
      expect(find.text('Đăng xuất khỏi Drive'), findsOneWidget);

      // Quay sang Cloud Zenpack thì hai nút ẩn lại, tài khoản vẫn còn.
      await tester.tap(find.text('Cloud Zenpack'));
      await tester.pumpAndSettle();
      expect(find.text('Đăng xuất khỏi Drive'), findsNothing);
      expect(find.text('shop@gmail.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Thẻ Drive nằm chờ trong lúc shop chạy S3: nó CÓ phần mở ra (tài khoản
    // Google vẫn đang cắm), nên thẻ kẻ một đường ngăn cách — và dưới đường kẻ
    // đó bắt buộc phải có chữ.
    //
    // Bản trước để trống đúng cảnh này: bảng tình trạng không vẽ cho Drive,
    // hàng email treo vào một chuỗi rỗng vì `driveEmail` đọc từ kho ĐANG DÙNG
    // (là S3), và hai nút thao tác chỉ hiện khi thẻ được chọn. Ba thứ cùng
    // vắng, chủ shop nhận đúng chữ "Google Drive" trên một vệt kẻ lơ lửng.
    testWidgets('thẻ Drive nằm chờ không để lại đường kẻ trống', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(
            kind: EcStorageKind.s3,
            configuredKind: EcStorageKind.s3,
            configuredKinds: {EcStorageKind.s3, EcStorageKind.gdrive},
            label: 'evidencecam/video',
            canManage: true,
            byosAllowed: true,
          ),
        ),
      );

      // Chưa đọc được email thì NÓI là chưa đọc được — bỏ trống đọc ra thành
      // "chưa cắm tài khoản nào", mà kho Drive kia vẫn đang giữ video thật.
      expect(find.text('Tài khoản Drive'), findsOneWidget);
      expect(find.text('Chưa đọc được tài khoản Google'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Máy chủ trả email cho hàng Drive thì thẻ đọc được ngay, không đợi ai chạm
    // và không cần Drive phải là kho đang dùng.
    testWidgets('đang dùng S3 vẫn đọc ra tài khoản Drive nằm chờ', (
      tester,
    ) async {
      await _pump(
        tester,
        const EcStorageScreen(
          state: EcStorageState(
            kind: EcStorageKind.s3,
            configuredKind: EcStorageKind.s3,
            configuredKinds: {EcStorageKind.s3, EcStorageKind.gdrive},
            driveEmail: 'shop@gmail.com',
            label: 'evidencecam/video',
            canManage: true,
            byosAllowed: true,
          ),
        ),
      );

      expect(find.text('shop@gmail.com'), findsOneWidget);
      expect(find.text('Chưa đọc được tài khoản Google'), findsNothing);
      // Hai nút thao tác của Drive vẫn nằm im cho tới khi thẻ được chọn.
      expect(find.text('Đăng xuất khỏi Drive'), findsNothing);
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

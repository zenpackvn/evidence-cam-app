import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart' show LucideIcons;
import 'package:feature_account/feature_account.dart';
import 'package:flutter/cupertino.dart' show CupertinoTextField;
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

/// Màn có đúng hai ô nhập, theo thứ tự người dùng gặp: **tên hồ sơ trước, tra
/// mã sau**. Thứ tự đó là một phần của yêu cầu — ô tên phải thấy ngay khi mở
/// màn — nên bám vào nó ở đây là đúng chỗ, và test "ô tên hiện ngay khi mở màn"
/// canh luôn chính thứ tự này.
Finder _nameField() => find.byType(EditableText).first;
Finder _searchField() => find.byType(EditableText).last;

Future<void> _lookup(WidgetTester tester, String code) async {
  await tester.enterText(_searchField(), code);
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
      String? createdTitle;
      await _pump(
        tester,
        EcCreateClaimScreen(
          onSearch: (code) async => code == 'SPX1' ? _spx1 : _spx2,
          onCreate: (batch, title) {
            created = batch;
            createdTitle = title;
          },
        ),
      );

      await _lookup(tester, 'SPX1');
      await tester.tap(find.text('Đóng hàng'));
      await tester.pumpAndSettle();

      await _lookup(tester, 'SPX2');
      await tester.tap(find.text('Ảnh đính kèm'));
      await tester.pumpAndSettle();

      // Mã cũ vẫn nằm dưới mã mới, và cái đã tick ở đó vẫn còn. Vẫn soi TRONG
      // danh sách: ô tên nằm ngoài nó, và một ngày nào đó ai đó gõ 'SPX1' vào
      // ô tên thì khẳng định tìm trần sẽ im lặng hỏng.
      expect(
        find.descendant(of: find.byType(ListView), matching: find.text('SPX1')),
        findsOneWidget,
      );
      expect(find.text('Đóng hàng'), findsOneWidget);

      await tester.enterText(_nameField(), 'Lô hoàn 8/8');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('(2)'));
      await tester.pumpAndSettle();

      expect(created, hasLength(2));
      expect(
        {for (final o in created!) o.orderCode: o.picked.single.id},
        {'SPX1': 'e1', 'SPX2': 'e3'},
      );
      // Tên là thứ người dùng gõ, KHÔNG điền hộ — giống web.
      expect(createdTitle, 'Lô hoàn 8/8');
    });

    // Trước bản vá này màn hình không có ô tên nào, `onCreate` không mang tên,
    // nên máy chủ từ chối MỌI hồ sơ tạo từ app (`claim_title_required`) và hồ
    // sơ nằm lại trong máy — im lặng, vì lỗi bị nuốt ở tầng dưới.
    // Ô tên phải thấy NGAY khi mở màn, trước cả ô tra mã. Bản trước giấu nó
    // xuống đáy và chỉ hiện sau khi đã tick được thứ gì — mở màn ra không thấy
    // ô tên nào, nên không ai biết hồ sơ cần đặt tên cho tới lúc đã làm xong
    // mọi việc khác.
    testWidgets('ô tên hiện ngay khi mở màn, kèm dấu bắt buộc', (tester) async {
      await _pump(
        tester,
        EcCreateClaimScreen(onSearch: (code) async => _spx1, onCreate: (_, _) {}),
      );

      expect(find.text('Tên hồ sơ'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
      // Hai ô nhập ngay từ đầu: ô tên rồi tới ô tra mã, theo đúng thứ tự đó.
      expect(find.byType(EditableText), findsNWidgets(2));
    });

    testWidgets('tên rỗng thì KHÔNG tạo được — tên là bắt buộc như web', (
      tester,
    ) async {
      var created = 0;
      await _pump(
        tester,
        EcCreateClaimScreen(
          onSearch: (code) async => _spx1,
          onCreate: (batch, title) => created++,
        ),
      );

      await _lookup(tester, 'SPX1');
      await tester.tap(find.text('Đóng hàng'));
      await tester.pumpAndSettle();

      // Xoá trắng ô tên rồi bấm tạo: không có gì xảy ra.
      await tester.enterText(_nameField(), '   ');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('(1)'));
      await tester.pumpAndSettle();
      expect(created, 0);

      // Gõ tên vào thì tạo được ngay, không phải làm lại từ đầu.
      await tester.enterText(_nameField(), 'Lô hoàn 8/8');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('(1)'));
      await tester.pumpAndSettle();
      expect(created, 1);
    });

    testWidgets('sửa được tên hồ sơ và tên đó đi theo lúc tạo', (tester) async {
      String? createdTitle;
      await _pump(
        tester,
        EcCreateClaimScreen(
          onSearch: (code) async => _spx1,
          onCreate: (batch, title) => createdTitle = title,
        ),
      );

      await _lookup(tester, 'SPX1');
      await tester.tap(find.text('Đóng hàng'));
      await tester.pumpAndSettle();

      await tester.enterText(_nameField(), 'Lô hoàn 8/8');
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('(1)'));
      await tester.pumpAndSettle();

      expect(createdTitle, 'Lô hoàn 8/8');
    });
  });

  group('EcClaimDetailScreen', _detailTests);
}

/// Màn chi tiết hồ sơ: một khối thông tin và một cái link, giống hệt web.
///
/// Bản trước dựng cả dòng thời gian bằng chứng kèm nút gỡ từng cái — tức vẫn
/// sửa được một hồ sơ đã phát đi cho sàn. Những test này canh đúng chỗ đó.
void _detailTests() {
  const detail = EcClaimDetailScreen(
    title: 'Lô hoàn 8/8',
    shopName: 'Shop A',
    channel: 'Shopee',
    trackings: ['SPXVN1', 'SPXVN2'],
    orderDateLabel: '07/08/2026 → 08/08/2026',
    videos: 3,
    photos: 1,
    createdAtLabel: '08/08/2026  10:30',
    url: 'https://zenpack.vn/c/abc123',
  );

  testWidgets('hiện đủ sáu dòng thông tin như bên web', (tester) async {
    await _pump(tester, detail);

    for (final label in [
      'Mã vận đơn',
      'Shop',
      'Kênh bán',
      'Ngày tạo đơn',
      'Bằng chứng',
      'Ngày tạo hồ sơ',
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'thiếu dòng "$label"');
    }
    // MỌI mã vận đơn, không phải chỉ mã đầu: hồ sơ gộp nhiều kiện là chuyện
    // thường, và giấu phần còn lại là giấu đúng thứ người đọc cần đối chiếu.
    expect(find.text('SPXVN1'), findsOneWidget);
    expect(find.text('SPXVN2'), findsOneWidget);
    expect(find.text('3 video · 1 ảnh'), findsOneWidget);
  });

  testWidgets('hiện link kèm nút chép và nút thu hồi', (tester) async {
    var copied = 0;
    var revoked = 0;
    await _pump(
      tester,
      EcClaimDetailScreen(
        title: detail.title,
        shopName: detail.shopName,
        channel: detail.channel,
        trackings: detail.trackings,
        orderDateLabel: detail.orderDateLabel,
        videos: detail.videos,
        photos: detail.photos,
        createdAtLabel: detail.createdAtLabel,
        url: detail.url,
        onCopy: () => copied++,
        onRevoke: () => revoked++,
      ),
    );

    expect(find.text('https://zenpack.vn/c/abc123'), findsOneWidget);
    expect(find.text('Thu hồi'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.copy));
    await tester.pumpAndSettle();
    expect(copied, 1);

    await tester.tap(find.text('Thu hồi'));
    await tester.pumpAndSettle();
    expect(revoked, 1);
  });

  // Hồ sơ là thứ ĐÃ CHỐT. Không một đường sửa nào được mọc lại ở đây: sửa được
  // nghĩa là không đối chứng được, và bản trước đã có đúng lỗi đó.
  testWidgets('KHÔNG có đường sửa nào', (tester) async {
    await _pump(tester, detail);

    expect(find.byIcon(LucideIcons.trash2), findsNothing);
    expect(find.byIcon(LucideIcons.plus), findsNothing);
    expect(find.byType(CupertinoTextField), findsNothing);
  });

  testWidgets('đã thu hồi: giấu link, đổi câu giải thích, mất nút', (
    tester,
  ) async {
    await _pump(
      tester,
      EcClaimDetailScreen(
        title: detail.title,
        shopName: detail.shopName,
        channel: detail.channel,
        trackings: detail.trackings,
        orderDateLabel: detail.orderDateLabel,
        videos: detail.videos,
        photos: detail.photos,
        createdAtLabel: detail.createdAtLabel,
        url: detail.url,
        revoked: true,
        onCopy: () {},
        onRevoke: () {},
      ),
    );

    expect(find.text('Đã thu hồi'), findsOneWidget);
    expect(find.textContaining('Link đã chết'), findsOneWidget);
    // Link chết thì KHÔNG đưa ra nữa — đưa ra là mời người ta gửi đi một link
    // mở lên báo lỗi.
    expect(find.text('https://zenpack.vn/c/abc123'), findsNothing);
    expect(find.text('Thu hồi'), findsNothing);
  });

  testWidgets('hồ sơ không tên vẫn mở được', (tester) async {
    await _pump(
      tester,
      const EcClaimDetailScreen(
        title: '   ',
        shopName: 'Shop A',
        channel: 'Shopee',
        trackings: ['SPXVN1'],
        orderDateLabel: '07/08/2026',
        videos: 1,
        photos: 0,
        createdAtLabel: '08/08/2026  10:30',
        url: 'https://zenpack.vn/c/abc123',
      ),
    );
    expect(find.text('Hồ sơ không đặt tên'), findsOneWidget);
  });
}

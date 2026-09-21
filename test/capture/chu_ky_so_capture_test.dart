@Tags(['golden'])
library;

import 'dart:convert';

import 'package:app_ui/app_ui.dart';
import 'package:feature_account/feature_account.dart';
import 'package:feature_orders/feature_orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:localization/localization.dart';

/// Hai màn CẦN THIẾT của chữ ký số trên app (design-spec/chu-ky-so-man-hinh.md):
/// A1 Chi tiết video, A3 Chi tiết hồ sơ khiếu nại. Dựng ở cỡ iPhone 11 rồi
/// ghi PNG để nhìn bằng mắt (`--update-goldens`), cùng cách với
/// `screens_capture_test.dart`.
Future<void> _cap(
  WidgetTester t,
  String name,
  Widget screen, {
  // Chi tiết video là tấm sheet cuộn được; kéo dài khung để thấy trọn hai
  // nút kiểm chứng ở cuối thay vì phải cuộn trong ảnh chụp.
  Size size = const Size(828, 1792),
}) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 2;
  addTearDown(() async {
    await t.pumpWidget(const SizedBox.shrink());
    await t.pump();
    t.view.reset();
  });
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      // Bọc Material: hai màn là khung Cupertino, đặt thẳng dưới MaterialApp
      // thì DefaultTextStyle rơi về kiểu "lỗi" của WidgetsApp (monospace, gạch
      // vàng). Trong app thật chúng nằm dưới lớp Material của router.
      home: Material(type: MaterialType.transparency, child: screen),
    ),
  );
  await t.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

/// Nạp MỌI phông trong FontManifest (Inter từ assets, phông biểu tượng
/// lucide từ package) để ảnh chụp đọc được — mặc định `flutter_test` thay
/// mọi phông bằng Ahem (ô đen), đủ để đo bố cục nhưng không đưa cho người
/// xem được. Cùng cách `golden_toolkit.loadAppFonts` làm, không thêm gói.
Future<void> _loadFonts() async {
  final manifest =
      jsonDecode(
            await rootBundle.loadString('FontManifest.json'),
          )
          as List<dynamic>;
  for (final entry in manifest) {
    final font = entry as Map<String, dynamic>;
    final family = font['family'] as String;
    final loader = FontLoader(family);
    for (final f in (font['fonts'] as List<dynamic>)) {
      final asset = (f as Map<String, dynamic>)['asset'] as String;
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
  // google_fonts đăng ký phông theo tên `Inter_<variant>` (regular / 600 /
  // bold…) và chỉ nạp KHI một TextStyle được tạo — muộn hơn lượt chụp. Nạp
  // trước cùng bộ tên đó từ assets, mỗi độ đậm trỏ về tệp gần nhất có sẵn.
  const files = {
    'Inter_regular': 'assets/google_fonts/Inter-Regular.ttf',
    'Inter_500': 'assets/google_fonts/Inter-Regular.ttf',
    'Inter_600': 'assets/google_fonts/Inter-SemiBold.ttf',
    'Inter_bold': 'assets/google_fonts/Inter-Bold.ttf',
    'Inter_700': 'assets/google_fonts/Inter-Bold.ttf',
    'Inter_800': 'assets/google_fonts/Inter-Bold.ttf',
    'Inter': 'assets/google_fonts/Inter-Regular.ttf',
    // Hai màn này vẽ trong khung Cupertino, nên DefaultTextStyle của chúng
    // là phông hệ thống iOS chứ không phải Inter của theme Material — trong
    // test nó là Ahem. Trỏ các tên đó về Inter để chữ hiện ra.
  };
  for (final e in files.entries) {
    final loader = FontLoader(e.key)..addFont(rootBundle.load(e.value));
    await loader.load();
  }
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  // setUpAll chứ không trong thân test: nạp trong thân test dưới FakeAsync
  // mất hơn mười phút cho cùng bộ phông (đo 2026-09-17).
  setUpAll(_loadFonts);
  LeakTesting.settings = LeakTesting.settings.withIgnored(
    notDisposed: {
      'ImageStreamCompleterHandle': null,
      'ImageInfo': null,
      'Image': null,
      '_CachedImage': null,
    },
  );

  testWidgets(
    'A1 chi tiết video đã ký',
    (t) => _cap(
      t,
      'chuky-a1-videodetail',
      EcVideoDetailScreen(
        video: const EcVideoDetail(
          title: 'Đóng hàng',
          duration: '01:14',
          recordedAt: '15/09/2026 · 14:03',
          recordedBy: 'Nguyễn Văn An',
          device: 'iPhone 15',
          uploadStatus: 'Đã tải lên',
          fileSize: '20,4 MB',
          storage: 'Kho ZenPack',
          mediaUrl: 'https://cdn.example.com/evidence/video-1.mp4',
          seal: EcSealLine(
            label: 'Đã khoá · 15/09/2026 · 14:04',
            signature: 'Chữ ký ZenPack · khoá k2',
            anchor: 'Đã có · mục #912.345',
            canVerify: true,
          ),
        ),
        showRecordedBy: true,
        onVerify: () {},
        onCopyVerifyLink: () {},
        onPlay: () {},
        onCopyLink: () {},
        onDownload: () {},
      ),
      size: const Size(828, 2500),
    ),
  );

  testWidgets(
    'A3 chi tiết hồ sơ khiếu nại 5/7 đã ký',
    (t) => _cap(
      t,
      'chuky-a3-claimdetail',
      EcClaimDetailScreen(
        title: 'Khách báo thiếu 1 hộp — đơn giao 14/9',
        shopName: 'Shop Minh Anh',
        channel: 'Shopee',
        trackings: const ['SPXVN058823411A', 'SPXVN058823412B'],
        orderDateLabel: '14/09/2026 → 15/09/2026',
        videos: 7,
        photos: 1,
        sealed: 5,
        anchored: 5,
        createdAtLabel: '16/09/2026  13:54',
        url: 'https://zenpack.vn/c/tWGghLNh4H3uGN07t7DEOFf8',
        onCopy: () {},
        onRevoke: () {},
      ),
    ),
  );
}

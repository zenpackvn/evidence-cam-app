import 'dart:io';

import 'package:ec_data/ec_data.dart';
import 'package:ec_ui/ec_ui.dart'
    show LucideIcons, PenBackButton, PenBox, PenColors, PenQrCard;
import 'package:evidence_cam/app/di/injection.dart';
import 'package:evidence_cam/ec_app.dart';
import 'package:feature_capture/feature_capture.dart' show debugPreviewDir;
import 'package:feature_shift/feature_shift.dart';
import 'package:flutter/cupertino.dart' show CupertinoAlertDialog;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:network/network.dart'
    show DioException, DioExceptionType, RequestOptions, Response;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:storage/storage.dart';

import 'ec_fakes.dart';

/// Real `path_provider` has no platform to answer its method channel in a
/// widget test, leaving `getApplicationDocumentsDirectory()` pending forever
/// instead of throwing — silently stalling anything that awaits it (the
/// edit-profile save flow, since it now persists the picked avatar into the
/// documents dir). A directory the OS actually gives back keeps that flow
/// real instead of relying on its failure-path fallback.
class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async =>
      Directory.systemTemp.createTempSync('ec_app_test_docs').path;
}

/// Kênh sự kiện của `connectivity_plus`, mở ngay khi app dựng.
const _connectivityChannel = MethodChannel(
  'dev.fluttercommunity.plus/connectivity_status',
);

void main() {
  // Không có bản cài plugin trong test thì `listen` trên kênh trên ném
  // MissingPluginException — và nó ném BẤT ĐỒNG BỘ, nên lỗi rơi vào bất kỳ
  // test nào tình cờ đang chạy lúc đó. Đó là lý do 'edit profile persists the
  // selected avatar url' đỏ vì một chuyện không liên quan gì tới avatar. Trả
  // lời rỗng là đủ để nó im.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_connectivityChannel, (call) async => null);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_connectivityChannel, null);
  });

  // Người ta sao chép link mời từ email kiểu gì cũng có: link thật, link đã
  // qua redirect của site, hoặc chỉ mỗi cái token. Bắt họ dán cho "đúng" là
  // bắt sai người — cả ba dạng đều phải nhận.
  group('ecInviteTokenOf', () {
    test('nhận link thật, link redirect và token trần', () {
      expect(
        ecInviteTokenOf('https://zenpack.vn/invite/abc123DEF'),
        'abc123DEF',
      );
      expect(
        ecInviteTokenOf('https://zenpack.vn/app#/invite/abc123DEF'),
        'abc123DEF',
      );
      expect(ecInviteTokenOf('abc123DEF'), 'abc123DEF');
    });

    test('từ chối thứ không phải lời mời', () {
      expect(ecInviteTokenOf('https://zenpack.vn/shops'), isNull);
      expect(ecInviteTokenOf('xin chào'), isNull);
      expect(ecInviteTokenOf('abc'), isNull);
    });
  });

  /// Cầu `EcSave`: trang web sai khiến app tải tệp.
  ///
  /// Đây là ranh giới tin cậy, không phải một lời gọi hàm. Bản trước chỉ kiểm
  /// hình dạng JSON rồi đưa chuỗi thẳng cho Dio — không scheme, không host —
  /// nên mọi đoạn JS chạy được trong khung đó đều tải được URL bất kỳ về máy
  /// người dùng.
  group('ecUrlTaiDuoc', () {
    const goc = 'https://api.zenpack.vn';

    test('nhận đúng ba dạng đường phát mà máy chủ dựng ra', () {
      for (final u in [
        'https://api.zenpack.vn/d/tok123/v/ev1',
        'https://api.zenpack.vn/d/tok123/p/ev1',
        'https://api.zenpack.vn/c/tok123/cat/ev1',
      ]) {
        expect(ecUrlTaiDuoc(u, gocApi: goc), u, reason: u);
      }
    });

    test('từ chối host khác — kể cả host trông giống', () {
      for (final u in [
        'https://evil.com/d/tok/v/ev1',
        'https://api.zenpack.vn.evil.com/d/tok/v/ev1',
        'https://api-zenpack.vn/d/tok/v/ev1',
        // Tiền tố khớp mà vẫn là tên miền khác.
        'https://api.zenpack.vnevil.com/d/tok/v/ev1',
      ]) {
        expect(ecUrlTaiDuoc(u, gocApi: goc), isNull, reason: u);
      }
    });

    test('từ chối mọi scheme không phải https', () {
      for (final u in [
        'http://api.zenpack.vn/d/tok/v/ev1',
        // Ca này CHỈ chốt scheme bắt được: đúng host, cổng 443 khai tường
        // minh nên khớp luôn, đường dẫn hợp lệ. Thiếu nó thì chốt scheme là
        // đồ trang trí — host và cổng đã chặn hết mấy ca kia rồi.
        'ftp://api.zenpack.vn:443/d/tok/v/ev1',
        'file:///etc/passwd',
        'data:text/html,<script>alert(1)</script>',
        'content://com.android.providers/x',
        'javascript:alert(1)',
      ]) {
        expect(ecUrlTaiDuoc(u, gocApi: goc), isNull, reason: u);
      }
    });

    /// Đúng host mà sai đường vẫn phải chặn: `/api/**` là mặt có xác thực, và
    /// một lượt tải do trang web sai khiến thì đi kèm phiên của người dùng.
    test('từ chối đường dẫn ngoài /d/ và /c/', () {
      for (final u in [
        'https://api.zenpack.vn/api/me',
        'https://api.zenpack.vn/seal/manifest/ev1',
        'https://api.zenpack.vn/',
        'https://api.zenpack.vn/dossier/tok',
      ]) {
        expect(ecUrlTaiDuoc(u, gocApi: goc), isNull, reason: u);
      }
    });

    test('rỗng, null và rác thì im lặng bỏ qua', () {
      expect(ecUrlTaiDuoc(null, gocApi: goc), isNull);
      expect(ecUrlTaiDuoc('', gocApi: goc), isNull);
      expect(ecUrlTaiDuoc('không phải url', gocApi: goc), isNull);
    });
  });

  /// Lớp thứ hai: khung mang cầu `EcSave` không được rời hai origin đã biết.
  group('ecDieuHuongDuoc', () {
    const trang = 'https://zenpack.vn/c/tok123';
    const goc = 'https://api.zenpack.vn';
    bool duoc(String u) => ecDieuHuongDuoc(u, trang: trang, gocApi: goc);

    test('cho đi trong trang hồ sơ và sang host API', () {
      expect(duoc('https://zenpack.vn/c/tok123'), isTrue);
      expect(duoc('https://zenpack.vn/seal/verify/ev1'), isTrue);
      expect(duoc('https://api.zenpack.vn/d/tok/v/ev1'), isTrue);
    });

    test('chặn mọi nơi khác', () {
      for (final u in [
        'https://evil.com/',
        'https://zenpack.vn.evil.com/c/tok',
        'http://zenpack.vn/c/tok123',
        'javascript:alert(1)',
        'about:blank',
        'rác',
      ]) {
        expect(duoc(u), isFalse, reason: u);
      }
    });
  });
  // Những thứ SỐNG BẰNG VÒNG ĐỜI ỨNG DỤNG, không phải của một màn: kho ảnh dùng
  // chung, notifier người dùng của `FakeEcAuth` (cố ý không bao giờ dispose —
  // xem `ec_auth.dart`), và bộ đếm bằng chứng của vỏ app.
  //
  // Trước đó mỗi test tự khai lại nhóm này, mỗi nơi một kiểu — 19 chỗ khai
  // `ValueNotifier<EcUser?>`, 14 chỗ khai `ImageStreamCompleterHandle`. Đặt một
  // lần ở đây thì mọi `withIgnored` của từng test dựng chồng lên nó, và một
  // singleton mới chỉ phải khai một chỗ.
  //
  // CHỈ nhóm này. Phần còn lại vẫn bị soi — chính nhờ vậy mà lượt rà 10/08 bắt
  // được một `CurvedAnimation` rò thật ở màn quay.
  LeakTesting.settings = LeakTesting.settings.withIgnored(
    notDisposed: {
      'ImageStreamCompleterHandle': null,
      'ImageInfo': null,
      'Image': null,
      '_CachedImage': null,
      'ValueNotifier<EcUser?>': null,
      'ValueNotifier<bool>': null,
      '_EvidenceCountOverrides': null,
      // `_claimStore` là biến top-level, một thể duy nhất cho cả app — hồ sơ
      // tạo ở tab Vận đơn phải hiện ngay ở tab Tài khoản. Không có ai để dispose.
      'EcClaimStore': null,
    },
  );
  PathProviderPlatform.instance = _FakePathProviderPlatform();
  // Kho bản xem tạm phải trỏ vào một thư mục CÓ SẴN.
  //
  // `_previewDir()` mặc định hỏi `getApplicationDocumentsDirectory()` rồi
  // `Directory.create()` nếu thư mục chưa có — I/O THẬT. Trong widget test,
  // `pump()` chạy trên đồng hồ giả và không đẩy được một lời gọi I/O thật tới
  // nơi, nên `ecPreviews()` treo vĩnh viễn. Nó nằm giữa `_load()` của màn chi
  // tiết đơn, không có `timeout`, nên cả màn đứng ở khung xương: 895 widget mà
  // KHÔNG một chữ nào, và không ngoại lệ nào để lần theo.
  //
  // `debugPreviewDir` là khe cắm chính `ec_preview_store.dart` mở ra cho test.
  // Tạo thư mục bằng `createTempSync` — đồng bộ, xong trước khi test chạy.
  debugPreviewDir = Directory.systemTemp.createTempSync('ec_app_test_preview');
  Future<void> pumpPhoneSizedApp(WidgetTester tester, Widget app) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    // The app follows the device language; pin it to Vietnamese so the UI
    // strings match these assertions deterministically (CI locale is en).
    tester.platformDispatcher.localeTestValue = const Locale('vi');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      PaintingBinding.instance.imageCache
        ..clear()
        ..clearLiveImages();
      tester.view.reset();
    });

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
  }

  /// Signs in and enters [shop] from the picker — a login always stops there
  /// now, so tests that want to be inside the app have to pick. Pass a null
  /// [shop] to stay on the picker.
  ///
  /// No phone step in between: the number is an optional support contact, so
  /// a social sign-in goes straight from the provider to the shop picker.
  Future<void> signInWithGoogle(
    WidgetTester tester, {
    String? shop = 'Shop ABC',
  }) async {
    await tester.tap(find.text('Bắt đầu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng nhập với Google'));
    await tester.pumpAndSettle();
    if (shop == null) return;
    await tester.tap(find.text(shop).first);
    await tester.pumpAndSettle();
  }

  /// Mở màn Tài khoản, từ trong một shop.
  ///
  /// Tài khoản KHÔNG còn là một tab ở thanh dưới. `b6e09d9a` (07/08) sắp lại
  /// điều hướng còn đúng ba tab thuộc về công việc trong shop — Vận đơn, Ghi
  /// hình, Khiếu nại — và đưa Tài khoản lên màn Chọn cửa hàng, nơi nó đúng chỗ
  /// hơn: hồ sơ, ngôn ngữ, gói cước đều không thuộc về một shop cụ thể.
  ///
  /// Bảy test trong file này còn bấm `find.text('Tài khoản').last` sau đợt đó,
  /// nên cả bảy ném `Bad state: No element` — bấm vào một tab đã bị bỏ.
  Future<void> openAccount(WidgetTester tester) async {
    await tester.tap(find.byType(PenBackButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tài khoản').last);
    await tester.pumpAndSettle();
  }

  /// Mở Chi tiết cửa hàng của shop đang xem, từ màn Vận đơn.
  ///
  /// Đường đi là TÊN SHOP trên header — hoặc bánh răng bên phải, cùng đích.
  ///
  /// Bản trước của hai test dùng nó đi vòng: quay lại màn Chọn cửa hàng, bấm
  /// "Quản lý cửa hàng", rồi chọn lại shop. Màn danh sách đó đã bị bỏ ở
  /// `b6e09d9a` (07/08) và bỏ có lý do: người dùng đang đứng trong đúng một
  /// shop rồi, bắt chọn lại chính nó là một bước thừa. Nên hai test đó đỏ vì
  /// đi theo một đường KHÔNG CÒN TỒN TẠI — mã đi đúng hướng, test đứng yên.
  Future<void> openShopDetail(
    WidgetTester tester, {
    String shop = 'Shop ABC',
  }) async {
    await tester.tap(find.text(shop).first);
    await tester.pumpAndSettle();
  }

  /// Hỏi CHÍNH widget tour xem nhãn nó neo có thật trên màn không.
  ///
  /// Tour dò đích theo NHÃN CHỮ. Nhãn sai — gõ nhầm, đổi chữ, hoặc trỏ vào thứ
  /// chỉ hiện sau một thao tác — thì tour im lặng bỏ qua: "không tìm thấy đích"
  /// vốn cũng là một đường hợp lệ (nút ẩn theo quyền), nên không có gì báo.
  /// Đó là cách màn ghi hình mất hướng dẫn mà không ai hay, cho tới khi người
  /// dùng báo. Bài này biến sự im lặng đó thành đỏ.
  final daRa = <EcMan>{};

  void kiemNeo(WidgetTester tester, EcMan man) {
    daRa.add(man);
    // Đòi ĐÚNG tour của màn này, không phải "có tour nào đó trong cây": màn
    // đẩy chồng lên vẫn giữ nguyên tour của màn dưới trong cây widget, nên
    // hỏi chung chung thì một màn quên nối tour vẫn xanh.
    final tours = tester
        .widgetList<EcChiDan>(find.byType(EcChiDan))
        .where((t) => t.man == man)
        .toList();
    expect(
      tours,
      isNotEmpty,
      reason: 'màn "${man.name}" chưa nối tour hướng dẫn',
    );
    for (final tour in tours) {
      for (final buoc in tour.buoc()) {
        final chu = buoc.chu;
        if (chu != null) {
          expect(
            find.text(chu),
            findsWidgets,
            reason:
                'màn "${man.name}": tour neo vào nhãn "$chu" nhưng nhãn đó KHÔNG '
                'trên màn lúc vừa vào — tour sẽ im lặng không chạy',
          );
          continue;
        }
        // Neo bằng khoá: khoá chưa gắn vào widget nào đang dựng thì tour cũng
        // hụt y như nhãn sai, chỉ khác là không có chữ nào để mà tìm.
        expect(
          buoc.neo?.currentContext,
          isNotNull,
          reason:
              'màn "${man.name}": chặng "${buoc.tieuDe}" neo bằng khoá nhưng khoá '
              'chưa gắn vào widget nào trên màn — tour sẽ im lặng không chạy',
        );
      }
    }
  }

  group('mọi tour hướng dẫn neo vào nhãn có thật trên màn', () {
    testWidgets(
      'Chọn cửa hàng → Vận đơn → Chi tiết shop → Khiếu nại → Tài khoản',
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (tester) async {
        await pumpPhoneSizedApp(
          tester,
          EcApp(auth: FakeEcAuth(), repo: const _DemoRepository()),
        );

        await signInWithGoogle(tester, shop: null);
        kiemNeo(tester, EcMan.shops);

        await tester.tap(find.text('Shop ABC').first);
        await tester.pumpAndSettle();
        kiemNeo(tester, EcMan.home);

        await openShopDetail(tester);
        kiemNeo(tester, EcMan.shopDetail);

        await tester.tap(find.byType(PenBackButton).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Khiếu nại').last);
        await tester.pumpAndSettle();
        kiemNeo(tester, EcMan.claims);

        // `openAccount` đi ra bằng nút lùi trên header, mà tab Khiếu nại
        // không có nút đó — về tab Vận đơn trước.
        await tester.tap(find.text('Vận đơn').last);
        await tester.pumpAndSettle();
        await openAccount(tester);
        kiemNeo(tester, EcMan.account);

        await tester.tap(find.text('Gói cước & dung lượng'));
        await tester.pumpAndSettle();
        kiemNeo(tester, EcMan.quota);
      },
    );

    // Người vừa lập tài khoản chưa có shop nào: đây là màn ĐẦU TIÊN họ thấy,
    // và là màn cần hướng dẫn nhất.
    testWidgets(
      'Chưa có cửa hàng → Tạo cửa hàng',
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (tester) async {
        await pumpPhoneSizedApp(
          tester,
          EcApp(auth: FakeEcAuth(), repo: const _EmptyRepository()),
        );

        await signInWithGoogle(tester, shop: null);
        kiemNeo(tester, EcMan.noShop);

        await tester.tap(find.text('Tạo shop mới (tên + sàn)'));
        await tester.pumpAndSettle();
        kiemNeo(tester, EcMan.createShop);
      },
    );

    testWidgets(
      'Chi tiết đơn, Chi tiết khiếu nại, Hàng đợi upload',
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (tester) async {
        await pumpPhoneSizedApp(
          tester,
          EcApp(auth: FakeEcAuth(), repo: const _DemoRepository()),
        );

        await signInWithGoogle(tester);

        await tester.tap(find.text('SPXVN024567890').first);
        await tester.pumpAndSettle();
        kiemNeo(tester, EcMan.order);

        await tester.tap(find.byType(PenBackButton).first);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(LucideIcons.cloudUpload).first);
        await tester.pumpAndSettle();
        kiemNeo(tester, EcMan.queue);
      },
    );

    testWidgets(
      'Chi tiết hồ sơ khiếu nại',
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (tester) async {
        await pumpPhoneSizedApp(
          tester,
          EcApp(auth: FakeEcAuth(), repo: _ServerClaimsRepository()),
        );

        await signInWithGoogle(tester);
        await tester.tap(find.text('Khiếu nại').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Hồ sơ tạo ở web').first);
        await tester.pumpAndSettle();
        kiemNeo(tester, EcMan.claimDetail);
      },
    );

    testWidgets(
      'Ghi hình',
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (tester) async {
        await pumpPhoneSizedApp(
          tester,
          EcApp(auth: FakeEcAuth(), repo: const _DemoRepository()),
        );

        await signInWithGoogle(tester);
        await tester.tap(find.text('Ghi hình').last);
        await tester.pump(const Duration(milliseconds: 600));
        // Bấm tab Ghi hình mở popup chọn loại TRƯỚC; chọn xong mới vào màn
        // quay, nên tour của màn quay chỉ tồn tại sau bước này.
        await tester.tap(find.text('Đóng hàng').last);
        // Khung quét chạy hiệu ứng liên tục nên `pumpAndSettle` không dừng.
        await tester.pump(const Duration(milliseconds: 600));
        kiemNeo(tester, EcMan.record);
      },
    );

    // Chốt cuối: bài rà tự nó cũng có thể bỏ sót màn. Thêm một màn vào
    // `EcMan` mà quên rà thì bài này đỏ, thay vì lặng lẽ không ai kiểm.
    test('rà đủ mọi màn trong EcMan', () {
      expect(
        EcMan.values.toSet().difference(daRa),
        isEmpty,
        reason: 'còn màn chưa được bài nào rà nhãn neo',
      );
    });

    // Nhãn neo phải là CHUỖI DỊCH, không phải chữ Việt gõ cứng: gõ cứng thì
    // máy đặt tiếng Anh dò hụt và tour im lặng không chạy — đúng cái đã xảy ra
    // với màn ghi hình, nhưng lần này với toàn bộ người dùng ngoài Việt Nam.
    testWidgets(
      'nhãn neo theo đúng thứ tiếng đang chọn (tiếng Anh)',
      experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        tester.platformDispatcher.localeTestValue = const Locale('en');
        addTearDown(tester.platformDispatcher.clearLocaleTestValue);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          EcApp(auth: FakeEcAuth(), repo: const _DemoRepository()),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sign in with Google'));
        await tester.pumpAndSettle();
        kiemNeo(tester, EcMan.shops);

        await tester.tap(find.text('Shop ABC').first);
        await tester.pumpAndSettle();
        kiemNeo(tester, EcMan.home);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets(
    'navigates Splash → Login → Shops → Home tab',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      // FakeEcAuth's user notifier is an app-lifetime singleton (never disposed
      // by design — see ec_auth.dart); the phone-setup step retains it long
      // enough for GC to surface it here.
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: const _DemoRepository()),
      );

      // Splash
      expect(find.text('ZenPack'), findsOneWidget);
      await signInWithGoogle(tester);

      // One-shop accounts auto-enter Home; the orders tab shows a sample order.
      expect(find.textContaining('SPXVN'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'loads live shops and shows an order-load retry instead of spinning forever',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      final repo = _OrderLoadFailingRepository();
      await pumpPhoneSizedApp(tester, EcApp(auth: FakeEcAuth(), repo: repo));

      await signInWithGoogle(tester, shop: 'Live Shop');

      expect(repo.ordersShopId, 'live-shop');
      expect(find.text('Không tải được đơn hàng'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'an unverified email account cannot sign in and can resend the mail',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': null,
        'ValueNotifier<EcUser?>': null,
        'ValueNotifier<bool>': null,
        'ValueNotifier<_OverlayEntryWidgetState?>': null,
        'OverlayEntry': null,
      },
    ),
    (tester) async {
      final auth = _UnverifiedAuth();
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: auth, repo: const _DemoRepository()),
      );

      await tester.tap(find.text('Bắt đầu'));
      await tester.pumpAndSettle();
      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'a@b.com');
      await tester.enterText(fields.at(1), 'dongGoi2026');
      await tester.tap(find.text('Đăng nhập').last);
      await tester.pumpAndSettle();

      // Blocked with the reason, and offered the link again.
      expect(find.text('Email chưa xác minh'), findsOneWidget);
      await tester.tap(find.text('Gửi lại email'));
      await tester.pumpAndSettle();

      expect(auth.verificationsSent, 1);
      // Signed back out, still on Login — no shop picker, no shell.
      expect(auth.currentUser, isNull);
      expect(find.text('Chọn phương thức đăng nhập'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'register saves the profile, signs out, then returns to login',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      final auth = _RecordingAuth();
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: auth, repo: const _EmptyRepository()),
      );

      await tester.tap(find.text('Bắt đầu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đăng ký'));
      await tester.pumpAndSettle();

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'Nguyễn Văn A');
      await tester.enterText(fields.at(1), 'a@b.com');
      await tester.enterText(fields.at(2), '0901234567');
      // Phải đạt chính sách mật khẩu (shared_contracts/password_policy.dart):
      // 'matkhau123' nằm trong danh sách phổ biến nên bị từ chối.
      await tester.enterText(fields.at(3), 'dongGoi2026');
      await tester.enterText(fields.at(4), 'dongGoi2026');
      await tester.tap(find.text('Tạo tài khoản'));
      await tester.pumpAndSettle();

      // The account + phone are still created through the seam...
      expect(auth.registeredEmail, 'a@b.com');
      expect(auth.updatedPhone, '0901234567');
      // ...and the verification mail goes out before the sign-out.
      expect(auth.verificationEmail, 'a@b.com');
      // Registration is confirmed rather than silently bouncing to Login.
      expect(find.text('Đã tạo tài khoản'), findsOneWidget);
      expect(
        find.textContaining('Đã gửi email xác minh tới a@b.com'),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(
          of: find.byType(CupertinoAlertDialog),
          matching: find.text('Đăng nhập'),
        ),
      );
      await tester.pumpAndSettle();

      // Only then do we land back on Login, signed out.
      expect(auth.currentUser, isNull);
      expect(find.text('Chọn phương thức đăng nhập'), findsOneWidget);
    },
  );

  testWidgets(
    'social sign-in never asks for a phone, even with none on file',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      // The demo account has no phone — the case that used to be bounced to a
      // phone-capture step. Email is the identity; the phone is an optional
      // support contact and must never sit between sign-in and the app.
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: const _DemoRepository()),
      );

      await tester.tap(find.text('Bắt đầu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đăng nhập với Google'));
      await tester.pumpAndSettle();

      // Straight to the shop picker: no phone step ('Tiếp tục'/'Bỏ qua').
      expect(find.text('Tiếp tục'), findsNothing);
      expect(find.text('Bỏ qua'), findsNothing);
      await tester.tap(find.text('Shop ABC'));
      await tester.pumpAndSettle();
      expect(find.textContaining('SPXVN'), findsWidgets);
    },
  );

  testWidgets(
    'tapping the shop name on a tab header opens shop detail',
    // Same app-lifetime singletons the other shell tests ignore, plus what the
    // pushed detail route keeps alive (its route notifier, the shop logos).
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': null,
        'ValueNotifier<EcUser?>': 1,
        'ValueNotifier<bool>': null,
        '_EvidenceCountOverrides': null,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: const _DemoRepository()),
      );

      await signInWithGoogle(tester);

      // Orders tab header — the shop name itself is the entry to F1-09.
      await tester.tap(find.text('Shop ABC'));
      await tester.pumpAndSettle();
      expect(find.text('CÀI ĐẶT SHOP'), findsOneWidget);
      expect(find.text('LOẠI VIDEO'), findsOneWidget);

      // And back out to the tab it was opened from.
      await tester.tap(find.byType(PenBackButton).first);
      await tester.pumpAndSettle();
      expect(find.textContaining('SPXVN'), findsWidgets);

      // Chỉ tab Vận đơn mang tên shop trên header, nên nó là lối vào DUY NHẤT
      // tới Chi tiết cửa hàng — chốt để không ai vô tình thêm lối thứ hai.
      //
      // Bản trước kiểm bằng tab "Tài khoản". Tab đó không còn: `b6e09d9a`
      // (07/08) sắp lại điều hướng còn ba tab — Vận đơn, Ghi hình, Khiếu nại —
      // và đưa Tài khoản về màn Chọn cửa hàng. Nên test đỏ vì bấm vào một tab
      // đã bị bỏ, không phải vì luật này sai.
      await tester.tap(find.text('Khiếu nại').last);
      await tester.pumpAndSettle();
      expect(find.text('Shop ABC'), findsNothing);
    },
  );

  testWidgets(
    'forgot password sends reset through auth and shows the sent state',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      final auth = _RecordingAuth();
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: auth, repo: const FakeEcRepository()),
      );

      await tester.tap(find.text('Bắt đầu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quên mật khẩu?'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).first, 'reset@b.com');
      await tester.tap(find.text('Gửi liên kết đặt lại'));
      await tester.pumpAndSettle();

      expect(auth.resetEmail, 'reset@b.com');
      expect(
        find.text('Đã gửi — kiểm tra hộp thư, kể cả mục spam'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'selecting a shop remembers it for the next entry',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      await getIt.reset();
      final memory = _MemoryStore();
      getIt.registerSingleton<KeyValueStore>(memory);
      addTearDown(getIt.reset);
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: const _TwoShopRepository()),
      );

      await signInWithGoogle(tester, shop: null);
      await tester.tap(find.text('Shop XYZ').first);
      await tester.pumpAndSettle();

      expect(memory.getString('shop.last_id'), 's2');
      expect(find.text('Shop XYZ'), findsOneWidget);
    },
  );

  testWidgets(
    'the language pick is remembered and beats the device locale',
    // Two app instances (the restart) and the confirmation toast's overlay
    // entry outlive the check; the auth notifier is an app-lifetime singleton.
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': null,
        'ValueNotifier<EcUser?>': null,
        'ValueNotifier<bool>': null,
        'ValueNotifier<_OverlayEntryWidgetState?>': null,
        'OverlayEntry': null,
        '_EvidenceCountOverrides': null,
      },
    ),
    (tester) async {
      await getIt.reset();
      final memory = _MemoryStore();
      getIt.registerSingleton<KeyValueStore>(memory);
      addTearDown(getIt.reset);
      // Device says English; the app starts there until a pick is stored.
      tester.platformDispatcher.localeTestValue = const Locale('en');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        PaintingBinding.instance.imageCache
          ..clear()
          ..clearLiveImages();
      });

      await tester.pumpWidget(
        EcApp(auth: FakeEcAuth(), repo: const _DemoRepository()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Get started'), findsOneWidget);

      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle();
      // Bản tiếng Anh của hai thay đổi đã gặp ở luồng tiếng Việt:
      //   - không còn bước nhập số điện thoại (số là liên hệ hỗ trợ tùy chọn),
      //   - "Account" không còn là tab dưới, nó nằm ở màn chọn shop.
      await tester.tap(find.text('Shop ABC'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PenBackButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Account').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tiếng Việt'));
      await tester.pumpAndSettle();

      expect(memory.getString('app.language'), 'vi');

      // A fresh app (restart) reads the stored pick, not the device locale.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        EcApp(auth: FakeEcAuth(), repo: const _DemoRepository()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bắt đầu'), findsOneWidget);
    },
  );

  testWidgets(
    'login stops on the shop picker even with a single shop',
    // Entering the shell after the pick keeps its app-lifetime singletons alive
    // past the check.
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': null,
        'ValueNotifier<EcUser?>': null,
        'ValueNotifier<bool>': null,
        '_EvidenceCountOverrides': null,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: const _DemoRepository()),
      );

      await signInWithGoogle(tester, shop: null);

      // The picker, not the shop: entering is the user's call.
      expect(find.text('Chọn cửa hàng'), findsOneWidget);
      expect(find.textContaining('SPXVN'), findsNothing);

      await tester.tap(find.text('Shop ABC'));
      await tester.pumpAndSettle();
      expect(find.textContaining('SPXVN'), findsWidgets);
    },
  );

  testWidgets(
    'a resumed session still opens the remembered shop straight away',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': null,
        'ValueNotifier<EcUser?>': null,
        'ValueNotifier<bool>': null,
        '_EvidenceCountOverrides': null,
      },
    ),
    (tester) async {
      await getIt.reset();
      final memory = _MemoryStore();
      getIt.registerSingleton<KeyValueStore>(memory);
      addTearDown(getIt.reset);
      // Signed in already (Firebase persists the session across restarts) and
      // 's2' was the last shop opened.
      final auth = FakeEcAuth();
      await auth.signInWithEmail('demo@evidencecam.app', 'x');
      await memory.setString('shop.last_id', 's2');

      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: auth, repo: const _TwoShopRepository()),
      );
      await tester.tap(find.text('Bắt đầu'));
      await tester.pumpAndSettle();

      // Straight past the picker into Shop XYZ.
      expect(find.text('Chọn cửa hàng'), findsNothing);
      expect(find.text('Shop XYZ'), findsOneWidget);
    },
  );

  testWidgets(
    'the shell uses the selected shop instead of screen defaults',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: const _TwoShopRepository()),
      );

      await signInWithGoogle(tester, shop: null);
      await tester.tap(find.text('Shop XYZ').first);
      await tester.pumpAndSettle();

      // The picked shop drives the shell, not the screen's design default.
      expect(find.text('Shop XYZ'), findsOneWidget);
      expect(find.text('Shop ABC'), findsNothing);
    },
  );

  // Sửa tên/ảnh trên web chỉ ghi vào D1 — Firebase Auth không hay biết. App
  // đọc `GET /api/me` nên thấy ngay; đọc `displayName` là đứng yên mãi.
  testWidgets(
    'account tab shows the name from the API, not the Firebase profile',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: const _WebNamedRepository()),
      );

      await signInWithGoogle(tester);
      await openAccount(tester);

      expect(find.text('Tên Đổi Trên Web'), findsOneWidget);
      expect(find.text('Người dùng Demo'), findsNothing);
    },
  );

  testWidgets(
    'edit profile saves name and phone through the repository',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      final repo = _ProfileRepository();
      await pumpPhoneSizedApp(tester, EcApp(auth: FakeEcAuth(), repo: repo));

      await signInWithGoogle(tester);
      await openAccount(tester);
      await tester.tap(find.text('Người dùng Demo'));
      await tester.pumpAndSettle();

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'Tên Mới');
      await tester.enterText(fields.at(1), '0987654321');
      await tester.tap(find.text('Lưu thay đổi'));
      await tester.pumpAndSettle();

      expect(repo.updatedName, 'Tên Mới');
      expect(repo.updatedPhone, '0987654321');
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'edit profile persists the selected avatar url through the repository',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
        // Ảnh đại diện vừa chọn nằm trong bộ nhớ đệm ảnh, và đệm SỐNG LÂU HƠN
        // cây widget — đó là việc của nó. Cùng lý do đã ghi ở
        // `screens_capture_test.dart`: dọn đệm là phá bối cảnh của test kế tiếp.
        'Image': null,
      },
    ),
    (tester) async {
      final repo = _ProfileRepository();
      await pumpPhoneSizedApp(
        tester,
        EcApp(
          auth: FakeEcAuth(),
          repo: repo,
          pickAvatarPath: () async => 'https://cdn.evidencecam.test/avatar.png',
        ),
      );

      await signInWithGoogle(tester);
      await openAccount(tester);
      await tester.tap(find.text('Người dùng Demo'));
      await tester.pumpAndSettle();
      // Nút đổi ảnh nay là CHỮ "Đổi ảnh đại diện", không còn icon máy ảnh —
      // xem `DUMP` màn Thông tin tài khoản.
      await tester.tap(find.text('Đổi ảnh đại diện'));
      await tester.pumpAndSettle();
      // Saving now copies the picked avatar into the documents dir before
      // persisting its path — real dart:io File I/O, which (unlike Timers)
      // pump/pumpAndSettle don't drive forward on their own; it needs the
      // real event loop that runAsync provides.
      await tester.runAsync(() async {
        await tester.tap(find.text('Lưu thay đổi'));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(repo.updatedAvatarUrl, 'https://cdn.evidencecam.test/avatar.png');
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    },
  );

  // Cấp quyền Google Drive xảy ra Ở NGOÀI app, trong trình duyệt. `launchUrl`
  // trả về ngay lúc trình duyệt mở, nên không có callback nào báo "xong rồi" —
  // chỉ có lúc app sáng lại. Thiếu hook đó thì cắm kho thành công mà màn hình
  // vẫn ghi "kho hệ thống", trông y hệt một lần cắm hỏng.
  testWidgets(
    'màn kho đọc lại trạng thái khi app sáng lại sau khi cấp quyền Drive',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': null,
        'ValueNotifier<EcUser?>': 1,
        'ValueNotifier<bool>': null,
        '_EvidenceCountOverrides': null,
      },
    ),
    (tester) async {
      final repo = _DriveConnectingRepository();
      await pumpPhoneSizedApp(tester, EcApp(auth: FakeEcAuth(), repo: repo));

      await signInWithGoogle(tester);
      await openShopDetail(tester);
      await tester.tap(find.text('Kho lưu trữ').last);
      await tester.pumpAndSettle();

      expect(find.text('Cloud Zenpack'), findsOneWidget);
      final readsBefore = repo.reads;

      // Người dùng sang trình duyệt cấp quyền — app xuống nền — rồi quay lại.
      // Đi đủ chuỗi trạng thái chứ không bắn thẳng `resumed`: đó mới là thứ hệ
      // điều hành thật sự gửi, và nó cũng chạy qua đúng những nhánh vòng đời
      // khác đang nghe cùng sự kiện.
      // `hidden` là bắt buộc ở cả hai chiều — Flutter assert thẳng nếu nhảy cóc
      // từ `inactive` sang `paused`.
      repo.connected = true;
      for (final state in const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(repo.reads, greaterThan(readsBefore));

      // Màn kho nay là BA thẻ lựa chọn luôn hiện cùng lúc, nên "thẻ Drive có
      // mặt" và "thẻ hệ thống biến mất" đều không còn nói lên điều gì — hai
      // khẳng định cũ ('Google Drive của bạn' / 'Cloud Zenpack' biến mất) mô
      // tả một màn không còn tồn tại. Chuỗi `storageDriveName` chúng bám vào
      // giờ là chuỗi mồ côi, không mã nào dùng.
      //
      // Thứ thật sự đổi sau khi cấp quyền là thẻ NÀO đang được chọn, và dấu
      // chọn là viền xanh (`PenColors.success`). Nên bám vào đúng cái đó.
      Finder selectedCardWith(String title) => find.ancestor(
        of: find.text(title),
        matching: find.byWidgetPredicate(
          (w) => w is PenBox && w.stroke == PenColors.success,
        ),
      );
      expect(selectedCardWith('Google Drive'), findsOneWidget);
      expect(selectedCardWith('Cloud Zenpack'), findsNothing);
    },
  );

  /// Danh sách hồ sơ khiếu nại đọc từ MÁY CHỦ, không đọc bản lưu trên máy.
  ///
  /// Đây là chính cái bug: hồ sơ tạo ở web không bao giờ hiện ra trên app, vì
  /// màn này chỉ vẽ `EcClaimStore` — một kho nằm trong máy, mà web thì không
  /// ghi vào đó được. Cùng một cửa hàng, hai nơi kể hai câu chuyện.
  testWidgets(
    'màn hồ sơ hiện cả hồ sơ tạo ở nơi khác, không chỉ hồ sơ tạo trên máy này',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: _ServerClaimsRepository()),
      );
      await signInWithGoogle(tester);
      await tester.tap(find.text('Khiếu nại').last);
      await tester.pumpAndSettle();

      expect(find.text('Hồ sơ tạo ở web'), findsOneWidget);
      // Số bằng chứng phải là số của MÁY CHỦ. Đếm từ bản trên máy thì hồ sơ này
      // ra 0, vì trên máy không có bản nào của nó.
      expect(find.textContaining('3 bằng chứng'), findsOneWidget);
    },
  );

  /// Hồ sơ đã thu hồi ở web phải TRÔNG như đã thu hồi trên app.
  ///
  /// Trước đây app không biết gì về việc thu hồi ở nơi khác, nên vẫn bày một
  /// nút chép — bấm vào là người bán gửi cho sàn một link 404 lần nữa.
  testWidgets(
    'hồ sơ đã thu hồi hiện nhãn và không còn nút chép',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: _ServerClaimsRepository()),
      );
      await signInWithGoogle(tester);
      await tester.tap(find.text('Khiếu nại').last);
      await tester.pumpAndSettle();

      expect(find.text('Đã thu hồi'), findsOneWidget);
      // Một hàng còn sống, một hàng đã thu hồi → đúng MỘT nút chép.
      expect(find.byIcon(LucideIcons.copy), findsOneWidget);
    },
  );

  /// Mất mạng thì lùi về bộ đệm trên máy và NÓI RA, không để màn trống.
  ///
  /// Người bán mở tab này giữa lúc đang cãi nhau với sàn; một danh sách rỗng
  /// đọc ra là "hồ sơ của tôi mất rồi", chứ không ai đoán là mạng chập.
  testWidgets(
    'đọc hỏng thì vẽ bản lưu tạm và nói rõ đó là bản tạm',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: _ClaimListFailingRepository()),
      );
      await signInWithGoogle(tester);
      await tester.tap(find.text('Khiếu nại').last);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Chưa nối được máy chủ'),
        findsOneWidget,
      );
    },
  );

  /// Nửa sau của cùng cái bug: BẤM VÀO một hồ sơ tạo ở nơi khác.
  ///
  /// Màn chi tiết tra `EcClaimStore` để đổi id-trên-máy sang id-máy-chủ, rồi bỏ
  /// cuộc khi không thấy — mà hồ sơ tạo ở web thì không có bản trên máy nào.
  /// Kết quả là một màn trắng: danh sách hiện đúng, bấm vào thì rỗng.
  testWidgets(
    'bấm vào hồ sơ tạo ở nơi khác thì mở được chi tiết, không ra màn trắng',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: _ServerClaimsRepository()),
      );
      await signInWithGoogle(tester);
      await tester.tap(find.text('Khiếu nại').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hồ sơ tạo ở web'));
      await tester.pumpAndSettle();

      // Màn chi tiết đọc từ máy chủ bằng đúng id đã bấm.
      expect(_ServerClaimsRepository.lastDetailId, 'claim-web-1');
      expect(find.text('Thông tin hồ sơ'), findsOneWidget);
    },
  );

  testWidgets(
    'quota screen shows remaining storage from the repository',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: _QuotaRepository()),
      );

      await signInWithGoogle(tester);
      await openAccount(tester);
      // Hàng dẫn vào màn hạn mức đổi tên thành 'Gói cước & dung lượng' khi gói
      // cước được gộp chung vào đó (khoá `accountPlanQuota`). Test của gói
      // feature_account đã theo tên mới; test tầng app thì không, vì nó ghim
      // chữ cứng thay vì đọc qua l10n.
      await tester.tap(find.text('Gói cước & dung lượng'));
      await tester.pumpAndSettle();

      // Hạn mức nay đếm SỐ VIDEO trong tháng, không còn tính bằng GB — đổi có
      // chủ đích để cùng trục với hạn mức thật của gói. Hai khẳng định cũ
      // ('12 GB / 60 GB', 'Đã dùng 80%') mô tả một màn không còn tồn tại.
      expect(find.text('Đã dùng 480 / 600 · 80%'), findsOneWidget);
      expect(find.text('120 còn lại'), findsOneWidget);
    },
  );

  testWidgets(
    'account tab re-reads the plan after coming back from quota',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': null,
        'ValueNotifier<EcUser?>': 1,
        'ValueNotifier<bool>': null,
        '_EvidenceCountOverrides': null,
      },
    ),
    (tester) async {
      // Gói đổi giữa chừng — đúng thứ xảy ra khi vừa thanh toán xong ở trang
      // quota; tab Tài khoản phải hỏi lại chứ không giữ nhãn gói đã cache.
      final repo = _UpgradingQuotaRepository();
      await pumpPhoneSizedApp(tester, EcApp(auth: FakeEcAuth(), repo: repo));

      await signInWithGoogle(tester);
      // Nhãn gói nay hiện ở màn Quota chứ không ở màn Tài khoản, nên phép thử
      // "không giữ nhãn đã cache" phải làm ở đúng màn có nhãn: vào Quota, ra,
      // vào lại — lần hai phải thấy gói MỚI.
      await openAccount(tester);
      await tester.tap(find.text('Gói cước & dung lượng'));
      await tester.pumpAndSettle();
      expect(find.text('Cơ bản'), findsWidgets);

      // Thanh toán xong ở ngoài: gói đổi mà màn đang mở chưa biết.
      repo.upgraded = true;

      await tester.tap(find.byType(PenBackButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gói cước & dung lượng'));
      await tester.pumpAndSettle();

      expect(find.text('Cao cấp'), findsWidgets);
    },
  );

  testWidgets(
    'tài khoản MỚI chưa có shop được tour chỉ vào từng nút',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      // Màn ĐẦU TIÊN của người vừa lập tài khoản là "Chưa có shop nào", không
      // phải màn chọn shop. Gắn hướng dẫn vào màn chọn shop mà bỏ màn này là
      // bỏ đúng người cần chỉ dẫn nhất — họ chưa từng thấy app bao giờ.
      final kho = EcHuongDanKhoTam();
      await kho.danhDauGioiThieu();
      await pumpPhoneSizedApp(
        tester,
        EcApp(
          auth: FakeEcAuth(),
          repo: const _EmptyRepository(),
          huongDan: kho,
        ),
      );
      // `shop: null`: kho rỗng nên không có shop nào để bấm vào.
      await signInWithGoogle(tester, shop: null);
      await tester.pumpAndSettle();

      expect(find.text('Chưa có shop nào'), findsWidgets);
      // Tour CHỈ VÀO TỪNG NÚT: chặng đầu nói về nút tạo cửa hàng, kèm số chặng.
      expect(find.text('Tạo cửa hàng trước'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);

      // Bấm Tiếp thì sang chặng hai — nút Tài khoản.
      await tester.tap(find.text('Tiếp'));
      await tester.pumpAndSettle();
      expect(find.text('Hồ sơ của bạn'), findsOneWidget);
      expect(find.text('2/2'), findsOneWidget);

      // Chặng cuối bấm "Đã hiểu" thì tour đóng, màn dùng được bình thường.
      await tester.tap(find.text('Đã hiểu'));
      await tester.pumpAndSettle();
      expect(find.text('Hồ sơ của bạn'), findsNothing);
    },
  );

  testWidgets(
    'vào màn chính lần đầu thì tour chỉ vào ô tìm mã',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      // Bài này đi qua TUYẾN thật, không dựng màn tay. Test dựng màn tay chỉ
      // chứng minh ô chèn vẽ được — nó không biết tuyến có truyền thẻ vào hay
      // không, mà quên truyền thì người dùng chẳng thấy gì và test vẫn xanh.
      // Đã xem giới thiệu: bài này soi hướng dẫn TỪNG MÀN, không phải ba màn
      // giới thiệu. Để nguyên thì app dừng ở giới thiệu và không tới được màn
      // đăng nhập.
      final kho = EcHuongDanKhoTam();
      await kho.danhDauGioiThieu();
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: const _DemoRepository(), huongDan: kho),
      );
      // `shop: null`: màn chọn cửa hàng có tour của RIÊNG nó, và lớp phủ của
      // tour chắn cú chạm vào thẻ shop. Phải đóng tour đó trước — đúng thứ
      // người dùng thật cũng phải làm.
      await signInWithGoogle(tester, shop: null);
      await tester.pumpAndSettle();
      expect(find.text('Đổi cửa hàng'), findsOneWidget);
      await tester.tap(find.text('Đã hiểu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Shop ABC').first);
      await tester.pumpAndSettle();

      // Màn Tổng quan: tour chỉ vào ô tìm mã vận đơn, hai chặng.
      expect(find.text('Tìm nhanh một đơn'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
    },
  );

  testWidgets(
    'xác thực lại hỏng thì KHÔNG xoá dữ liệu ở máy chủ',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      // Đây là kết cục tệ nhất của lỗi cũ: dữ liệu xoá sạch rồi Firebase mới
      // từ chối, nên người dùng đăng nhập lại được vào một tài khoản rỗng.
      final repo = _DeleteRecordingRepository();
      final auth = FakeEcAuth()
        ..loiXacThucLai = const EcAuthException('phiên đã cũ');
      await pumpPhoneSizedApp(tester, EcApp(auth: auth, repo: repo));

      await signInWithGoogle(tester);
      await openAccount(tester);
      // Hàng xoá nằm dưới nếp gấp của màn Tài khoản (dải cam cao hơn, hàng
      // cài đặt có ô biểu tượng — 18/09), phải cuộn tới trước khi bấm.
      await tester.ensureVisible(find.text('Xóa tài khoản'));
      await tester.tap(find.text('Xóa tài khoản'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pumpAndSettle();

      // Chỉ có lượt dò thử, KHÔNG có lượt xoá thật.
      expect(repo.calls, [(force: false, dryRun: true)]);
      // Và tài khoản Firebase vẫn còn: chỉ chạy tới bước xác thực rồi dừng.
      expect(auth.buocXoa, ['xac-thuc-lai']);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'xác thực lại chạy TRƯỚC khi xoá bất cứ thứ gì',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      final repo = _DeleteRecordingRepository();
      final auth = FakeEcAuth();
      await pumpPhoneSizedApp(tester, EcApp(auth: auth, repo: repo));

      await signInWithGoogle(tester);
      await openAccount(tester);
      // Hàng xoá nằm dưới nếp gấp của màn Tài khoản (dải cam cao hơn, hàng
      // cài đặt có ô biểu tượng — 18/09), phải cuộn tới trước khi bấm.
      await tester.ensureVisible(find.text('Xóa tài khoản'));
      await tester.tap(find.text('Xóa tài khoản'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pumpAndSettle();

      expect(repo.calls, [
        (force: false, dryRun: true),
        (force: true, dryRun: false),
      ]);
      // Thứ tự là bằng chứng: xác thực xong mới tới xoá Firebase.
      expect(auth.buocXoa, ['xac-thuc-lai', 'xoa-firebase']);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'delete account retries with force only after sent-dossier warning',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      final repo = _DeleteConflictRepository();
      await pumpPhoneSizedApp(tester, EcApp(auth: FakeEcAuth(), repo: repo));

      await signInWithGoogle(tester);
      await openAccount(tester);
      // Hàng xoá nằm dưới nếp gấp của màn Tài khoản (dải cam cao hơn, hàng
      // cài đặt có ô biểu tượng — 18/09), phải cuộn tới trước khi bấm.
      await tester.ensureVisible(find.text('Xóa tài khoản'));
      await tester.tap(find.text('Xóa tài khoản'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pumpAndSettle();

      expect(repo.deleteForces, [false]);
      // Copy comes from the ARB: the dossier "đã gửi sàn" state was cut on
      // 2026-07-28 (a dossier is only đang mở / đã thu hồi now). Matched on
      // the tail, which is unique to the screen's warning — the toast opens
      // with the same "hồ sơ khiếu nại đang mở" phrase.
      expect(
        find.textContaining('link chia sẻ sẽ ngừng hoạt động'),
        findsOneWidget,
      );

      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pumpAndSettle();

      expect(repo.deleteForces, [false, true, true]);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'sent-dossier conflict is read from the Worker 409 body, not toString',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      final repo = _DioConflictRepository();
      await pumpPhoneSizedApp(tester, EcApp(auth: FakeEcAuth(), repo: repo));

      await signInWithGoogle(tester);
      await openAccount(tester);
      // Hàng xoá nằm dưới nếp gấp của màn Tài khoản (dải cam cao hơn, hàng
      // cài đặt có ô biểu tượng — 18/09), phải cuộn tới trước khi bấm.
      await tester.ensureVisible(find.text('Xóa tài khoản'));
      await tester.tap(find.text('Xóa tài khoản'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pumpAndSettle();

      expect(repo.deleteForces, [false]);
      // Copy comes from the ARB: the dossier "đã gửi sàn" state was cut on
      // 2026-07-28 (a dossier is only đang mở / đã thu hồi now). Matched on
      // the tail, which is unique to the screen's warning — the toast opens
      // with the same "hồ sơ khiếu nại đang mở" phrase.
      expect(
        find.textContaining('link chia sẻ sẽ ngừng hoạt động'),
        findsOneWidget,
      );

      // Let the confirmation toast dismiss itself so its overlay doesn't leak.
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'social-only account creates a password from account settings',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      final auth = FakeEcAuth();
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: auth, repo: const _DemoRepository()),
      );

      await signInWithGoogle(tester);
      expect(auth.currentUser!.hasPassword, isFalse);
      await openAccount(tester);

      expect(find.text('Tạo mật khẩu'), findsOneWidget);
      await tester.tap(find.text('Tạo mật khẩu'));
      await tester.pumpAndSettle();
      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'dongGoi2026');
      await tester.enterText(fields.at(1), 'dongGoi2026');
      await tester.tap(find.text('Tạo mật khẩu').last);
      await tester.pumpAndSettle();

      expect(auth.currentUser!.hasPassword, isTrue);
      expect(find.text('Đã tạo mật khẩu'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'creating the first shop selects it and opens Home',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      final repo = _CreateShopRepository();
      await pumpPhoneSizedApp(tester, EcApp(auth: FakeEcAuth(), repo: repo));

      await signInWithGoogle(tester, shop: null);
      await tester.tap(find.text('Tạo shop mới (tên + sàn)'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).first, 'Shop Mới');
      await tester.tap(find.text('Khác'));
      await tester.tap(find.text('Tạo shop').last);
      await tester.pumpAndSettle();

      expect(repo.createdPlatform, 'other');
      expect(find.text('Shop Mới'), findsOneWidget);
      expect(find.text('Shop chưa có đơn nào'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    },
  );

  // ĐÃ XOÁ: 'shop detail resolution changes are saved through the repository'.
  //
  // Không phải test hỏng — nó kiểm một tính năng KHÔNG CÒN. `0da2b002` bỏ bộ
  // chọn "Độ phân giải quay" khỏi Chi tiết cửa hàng, thay bằng hai mức cố
  // định, và `updateResolution` nay không tồn tại ở bất kỳ đâu trong app lẫn
  // repository — chỉ còn cái field giả trong `_ManageableShopRepository`.
  //
  // Sửa nó cho xanh sẽ phải dựng lại một màn đã bị gỡ có chủ đích, nên xoá mới
  // là việc đúng.

  testWidgets(
    'shop detail sends a pending member invite by contact',
    // Reaching Shop Detail keeps app-lifetime singletons and the pushed
    // route's own notifiers alive past the check.
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': null,
        'ValueNotifier<EcUser?>': 1,
        'ValueNotifier<bool>': null,
        '_EvidenceCountOverrides': null,
      },
    ),
    (tester) async {
      final repo = _ManageableShopRepository();
      await pumpPhoneSizedApp(tester, EcApp(auth: FakeEcAuth(), repo: repo));

      await signInWithGoogle(tester);
      await openShopDetail(tester);
      await tester.tap(find.text('Mời thành viên'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).first, 'new@b.com');
      await tester.tap(find.text('Thêm'));
      // Bơm CÓ GIỚI HẠN chứ không `pumpAndSettle`: toast tự tắt sau ~2 giây, mà
      // `pumpAndSettle` chạy tới khi không còn khung nào được lên lịch — tức là
      // vượt qua luôn cả lúc toast còn sống. Khẳng định bên dưới rơi vào khoảng
      // sau khi nó đã biến mất.
      await tester.pumpAndSettle();

      expect(repo.invitedContact, 'new@b.com');
      expect(repo.invitedRole, 'staff');
      expect(find.text('Thêm thành viên'), findsNothing);
      expect(find.text('Chi tiết cửa hàng'), findsOneWidget);
      // Mời qua email KHÔNG được chìa mã QR ra nữa — hai đường mời là hai lựa
      // chọn, không phải một thao tác đẻ ra cả hai. Thứ báo việc đã xong là
      // câu "Đã gửi lời mời".
      expect(find.text('Đã gửi lời mời'), findsOneWidget);
      expect(find.byType(PenQrCard), findsNothing);

      // Bơm qua mốc toast tự tắt (1,4 giây) để nó kịp dọn `OverlayEntry` của
      // mình. `pumpAndSettle` dừng ngay khi không còn khung nào được lên lịch,
      // mà toast thì chờ bằng Timer — nên nếu không bơm thêm, bộ dò rò rỉ bắt
      // được một overlay chưa dispose và cả tệp test đỏ ở `tearDownAll`.
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'bấm Ghi hình hỏi loại TRƯỚC khi vào màn quay, và vẫn đổi được ở trong',
    // Reaching Shop Detail keeps app-lifetime singletons and the pushed
    // route's own notifiers alive past the check.
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': null,
        'ValueNotifier<EcUser?>': 1,
        'ValueNotifier<bool>': null,
        '_EvidenceCountOverrides': null,
        'CurvedAnimation': null,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: const _DemoRepository()),
      );

      await signInWithGoogle(tester);
      await tester.tap(find.text('Ghi hình').last);
      await tester.pump(const Duration(seconds: 1));

      // Bấm tab Ghi hình là hỏi loại NGAY, chưa vào màn quay: khung ngắm
      // hiện ra rồi mới bị hộp thoại phủ lên là thứ người dùng đọc thành "vào
      // nhầm chỗ".
      expect(find.text('Chọn loại video'), findsOneWidget);
      expect(find.text('Quét mã vận đơn'), findsNothing);

      await tester.tap(find.text('Trả hàng'));
      await tester.pump(const Duration(seconds: 1));

      // Bơm thêm vài nhịp TRƯỚC khi khẳng định "không hỏi lại": một
      // `pump` đơn chỉ dựng đúng một khung, mà sheet tự động của màn quay đi
      // qua một quãng chờ 200ms rồi mới đẩy route. Thiếu mấy nhịp này thì bài
      // xanh vì sheet chưa kịp hiện chứ không phải vì nó không hiện — đo bằng
      // đột biến: bỏ hẳn chốt "đã chọn rồi" mà bài vẫn xanh.
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }

      // Chọn xong mới vào màn quay, và mang theo đúng loại vừa chọn — không
      // hỏi lại lần nữa.
      expect(find.text('Quét mã vận đơn'), findsOneWidget);
      expect(find.text('Chọn loại video'), findsNothing);
      expect(find.text('Trả hàng'), findsOneWidget);

      // Vẫn đổi được loại từ trong màn quay: ô loại ở thanh dưới.
      await tester.tap(find.text('Trả hàng'));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Quản lý loại video — mở Chi tiết shop'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('CÀI ĐẶT SHOP'), findsOneWidget);
      expect(find.text('LOẠI VIDEO'), findsOneWidget);
    },
  );

  // Không chọn loại thì không quay: đứng nguyên màn đang đứng, chứ không đẩy
  // vào màn quay rồi bỏ đó — màn quay không có loại là không dựng camera, nên
  // người dùng nhìn thấy một khung ngắm trống không hiểu vì sao.
  testWidgets(
    'bấm back trong popup chọn loại thì ở nguyên tab Vận đơn',
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
    (tester) async {
      await pumpPhoneSizedApp(
        tester,
        EcApp(auth: FakeEcAuth(), repo: const _DemoRepository()),
      );

      await signInWithGoogle(tester);
      await tester.tap(find.text('Ghi hình').last);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Chọn loại video'), findsOneWidget);

      await tester.tap(find.byIcon(LucideIcons.chevronLeft).last);
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Chọn loại video'), findsNothing);
      expect(find.text('Quét mã vận đơn'), findsNothing);
      expect(find.text('SPXVN024567890'), findsWidgets);
    },
  );

  testWidgets(
    'evidence sheet picks up the play link when sealing finishes, '
    'without leaving the order',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': null,
        'ValueNotifier<EcUser?>': 1,
        'ValueNotifier<bool>': null,
        '_EvidenceCountOverrides': null,
      },
    ),
    (tester) async {
      final repo = _SealingRepository();
      await pumpPhoneSizedApp(tester, EcApp(auth: FakeEcAuth(), repo: repo));
      await signInWithGoogle(tester);

      // Bơm CÓ GIỚI HẠN, không `pumpAndSettle`: chỉ báo "đang đóng dấu" là một
      // hoạt ảnh LẶP VÔ HẠN, nên không bao giờ có khoảnh khắc không còn khung
      // nào được lên lịch — `pumpAndSettle` chạy tới hết trần rồi ném timeout.
      // Đó là lý do test này đỏ, không phải vì việc niêm phong hỏng.
      Future<void> settle() async {
        await tester.pump();
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      await tester.tap(find.textContaining('SPXVN').first);
      await settle();
      await tester.tap(find.text('Đóng hàng').first);
      await settle();

      // Máy chủ đang đóng dấu ⇒ chưa phát link ra (evidence_url.ts). 'Sao chép
      // link' là hàng DUY NHẤT gác sau `mediaUrl != null` (ec_flow2.dart:642),
      // nên nó chính là thứ test này mang tên — vắng lúc này, có lúc sau.
      expect(find.text('Đang đóng dấu thời gian…'), findsWidgets);
      expect(find.text('Sao chép link'), findsNothing);

      // Niêm phong xong trong lúc sheet vẫn mở. Không đụng vào điều hướng.
      repo.sealed = true;
      // Nhịp hỏi lại là 5 giây cho 12 lượt đầu (`_sealPollInterval`), nên bơm
      // 6 giây là sát mép: một lượt hỏi rơi đúng ở 5 giây rồi mới còn 1 giây để
      // dữ liệu về và màn dựng lại. Bơm rộng ra cho hai lượt.
      await tester.pump(const Duration(seconds: 6));
      await settle();
      await tester.pump(const Duration(seconds: 6));
      await settle();

      // Link đã về: hàng sao chép hiện ra, và chỉ báo "đang đóng dấu" tắt.
      expect(find.text('Sao chép link'), findsOneWidget);
      expect(find.text('Đang đóng dấu thời gian…'), findsNothing);
      // KHÔNG khẳng định 'Đã khoá · …' nữa: sheet chỉ vẽ dòng niêm phong khi nó
      // ĐANG chạy (`if (video.seal?.inProgress ?? false)` — ec_flow2.dart:575).
      // Niêm phong xong thì dòng đó biến mất hẳn, nhường chỗ cho các hàng thao
      // tác — nên khẳng định cũ mô tả một màn không còn tồn tại, chứ không phải
      // bắt được lỗi gì.
    },
  );
  // API trả bằng chứng theo `captured_at` TĂNG dần (`orders.ts`: ORDER BY
  // e.captured_at), nên nếu app giữ nguyên thứ tự đó thì clip vừa quay xong
  // nằm tận đáy đơn — đúng thứ người bán vừa làm lại là thứ họ phải cuộn xa
  // nhất mới thấy.
  //
  // Đo TOẠ ĐỘ thật chứ không đếm thứ tự trong cây widget: thứ người dùng phàn
  // nàn là cái gì nằm trên cái gì trên màn hình.
  testWidgets('trong một mã vận đơn, clip mới nhất nằm trên cùng', (
    tester,
  ) async {
    await pumpPhoneSizedApp(
      tester,
      EcApp(auth: FakeEcAuth(), repo: _TimelineOrderRepository()),
    );
    await signInWithGoogle(tester);

    await tester.tap(find.textContaining('SPXVN').first);
    await tester.pump();
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Ngày mới đứng trên ngày cũ.
    final newerDay = tester.getTopLeft(find.text('25/08/2026')).dy;
    final olderDay = tester.getTopLeft(find.text('24/08/2026')).dy;
    expect(newerDay, lessThan(olderDay));

    // Và trong cùng một ngày, giờ muộn hơn cũng đứng trên.
    final later = tester.getTopLeft(find.text('14:30')).dy;
    final earlier = tester.getTopLeft(find.text('10:00')).dy;
    expect(later, lessThan(earlier));

    // Clip mới nhất của cả đơn đứng trên mọi clip của ngày hôm trước.
    expect(tester.getTopLeft(find.text('09:15')).dy, lessThan(later));
  });
}

/// Một clip đi từ "đang đóng dấu" sang "đã niêm phong" giữa hai lần gọi API —
/// đúng nhịp mà backend giấu rồi trả lại `url`.
class _SealingRepository extends _DemoRepository {
  _SealingRepository();

  bool sealed = false;

  @override
  Future<OrderDetailDto> order(String shopId, String orderId) async =>
      OrderDetailDto(
        order: const OrderDto(
          id: 'o1',
          tracking: 'SPXVN024567890',
          createdAt: 3,
        ),
        evidence: [
          EvidenceDto(
            id: 'e1',
            kind: 'video',
            capturedAt: 3,
            uploadStatus: 'done',
            videoTypeId: 'default-pack',
            sealStatus: sealed ? 'sealed' : 'rendering',
            sealedAt: sealed ? 4 : null,
            url: sealed ? 'https://example.test/e1.mp4' : null,
          ),
        ],
      );
}

class _MemoryStore implements KeyValueStore {
  final _values = <String, Object>{};

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  Future<void> setString(String key, String value) async =>
      _values[key] = value;

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async => _values[key] = value;

  @override
  int? getInt(String key) => _values[key] as int?;

  @override
  Future<void> setInt(String key, int value) async => _values[key] = value;

  @override
  double? getDouble(String key) => _values[key] as double?;

  @override
  Future<void> setDouble(String key, double value) async =>
      _values[key] = value;

  @override
  bool containsKey(String key) => _values.containsKey(key);

  @override
  Future<void> remove(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();
}

/// Email/password account that never followed the verification link — what
/// Firebase reports until the mail is opened.
class _UnverifiedAuth extends FakeEcAuth {
  int verificationsSent = 0;

  @override
  Future<EcUser> signInWithEmail(String email, String password) async {
    final user = await super.signInWithEmail(email, password);
    return user.copyWith(emailVerified: false);
  }

  @override
  Future<void> sendEmailVerification() async => verificationsSent++;
}

class _RecordingAuth extends FakeEcAuth {
  String? registeredEmail;
  String? updatedPhone;
  String? resetEmail;
  String? verificationEmail;

  @override
  Future<EcUser> registerWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    registeredEmail = email;
    return super.registerWithEmail(
      email: email,
      password: password,
      name: name,
    );
  }

  @override
  Future<EcUser> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    updatedPhone = phone;
    return super.updateProfile(name: name, phone: phone, photoUrl: photoUrl);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    resetEmail = email;
  }

  @override
  Future<void> sendEmailVerification() async {
    verificationEmail = currentUser?.email;
  }
}

class _OrderLoadFailingRepository extends FakeEcRepository {
  String? ordersShopId;

  @override
  Future<List<ShopDto>> shops() async => const [
    ShopDto(
      id: 'live-shop',
      name: 'Live Shop',
      platform: 'shopee',
      resolution: '720p',
      role: 'owner',
    ),
  ];

  @override
  Future<OrderPageDto> orders(
    String shopId, {
    int page = 1,
    String? uploadState,
    int? fromTs,
    int? toTs,
    String? videoTypeId,
  }) async {
    ordersShopId = shopId;
    throw Exception('orders unavailable');
  }
}

class _EmptyRepository extends FakeEcRepository {
  const _EmptyRepository();
}

class _CreateShopRepository extends FakeEcRepository {
  String? createdPlatform;
  ShopDto? created;

  @override
  Future<List<ShopDto>> shops() async => [?created];

  @override
  Future<ShopDto> createShop({
    required String name,
    required String platform,
    String? resolution,
  }) async {
    createdPlatform = platform;
    return created = ShopDto(
      id: 'created-shop',
      name: name,
      platform: platform,
      resolution: resolution ?? '720p',
      role: 'owner',
    );
  }
}

/// Hồ sơ D1 mang tên khác với `displayName` của Firebase — đúng tình huống
/// người dùng vừa đổi tên bên bảng điều khiển web.
class _WebNamedRepository extends _DemoRepository {
  const _WebNamedRepository();

  @override
  Future<AccountDto> account() async => const AccountDto(
    uid: 'fake-uid',
    email: 'demo@evidencecam.app',
    name: 'Tên Đổi Trên Web',
  );
}

class _ProfileRepository extends _DemoRepository {
  String? updatedName;
  String? updatedPhone;
  String? updatedAvatarUrl;

  @override
  Future<AccountDto> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? theme,
    String? timezone,
    Map<String, Object?>? hoaDon,
  }) async {
    updatedName = name;
    updatedPhone = phone;
    updatedAvatarUrl = avatarUrl;
    return AccountDto(
      uid: 'fake-uid',
      email: 'demo@evidencecam.app',
      name: name,
      phone: phone,
      avatarUrl: avatarUrl,
    );
  }
}

class _QuotaRepository extends _DemoRepository {
  @override
  Future<QuotaDto> quota({String? shopId}) async => const QuotaDto(
    planCode: 'basic',
    usedVideos: 480,
    capVideos: 600,
    remainingVideos: 120,
    retentionDays: 25,
  );
}

/// Trả `basic` cho lần hỏi đầu, `premium` cho mọi lần sau — giả lập gói vừa
/// được kích hoạt trong lúc người dùng đang ở trang quota.
/// Gói nâng cấp giữa chừng — đúng thứ xảy ra khi vừa thanh toán xong.
///
/// Bản trước lật gói theo SỐ LƯỢT gọi (`_calls == 1 ? basic : premium`), với
/// giả định "lượt đầu tiên là của màn Quota". Giả định đó gãy khi điều hướng
/// đổi: nay phải đi qua màn Tài khoản, và chính màn đó đã tiêu mất lượt gọi
/// đầu — nên màn Quota không bao giờ còn thấy `basic`, và test đỏ mà không phải
/// vì tính năng hỏng.
///
/// Nay test tự nói KHI NÀO nâng gói, nên nó không còn phụ thuộc vào việc màn
/// nào hỏi trước.
class _UpgradingQuotaRepository extends _DemoRepository {
  bool upgraded = false;

  @override
  Future<QuotaDto> quota({String? shopId}) async {
    return QuotaDto(
      planCode: upgraded ? 'premium' : 'basic',
      usedVideos: 480,
      capVideos: 600,
      remainingVideos: 120,
      retentionDays: 25,
    );
  }
}

/// Ghi lại MỌI lượt gọi xoá tài khoản, kèm tham số — để soi cái gì đã chạy.
class _DeleteRecordingRepository extends _DemoRepository {
  final calls = <({bool force, bool dryRun})>[];

  @override
  Future<void> deleteAccount({bool force = false, bool dryRun = false}) async {
    calls.add((force: force, dryRun: dryRun));
  }
}

class _DeleteConflictRepository extends _DemoRepository {
  final deleteForces = <bool>[];

  @override
  Future<void> deleteAccount({bool force = false, bool dryRun = false}) async {
    deleteForces.add(force);
    if (!force) throw StateError('open_dossiers_exist');
    if (dryRun) return;
  }
}

class _DioConflictRepository extends _DemoRepository {
  final deleteForces = <bool>[];

  @override
  Future<void> deleteAccount({bool force = false, bool dryRun = false}) async {
    deleteForces.add(force);
    // Mirrors the live Worker: a 409 whose machine code lives in the JSON body
    // (`{ "error": "..." }`), not in the DioException's toString().
    if (!force) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/me'),
        type: DioExceptionType.badResponse,
        response: Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/api/me'),
          statusCode: 409,
          data: const {'error': 'open_dossiers_exist'},
        ),
      );
    }
    if (dryRun) return;
  }
}

class _TwoShopRepository extends FakeEcRepository {
  const _TwoShopRepository();

  @override
  Future<List<ShopDto>> shops() async => const [
    ShopDto(
      id: 's1',
      name: 'Shop ABC',
      platform: 'shopee',
      resolution: '720p',
      role: 'owner',
    ),
    ShopDto(
      id: 's2',
      name: 'Shop XYZ',
      platform: 'lazada',
      resolution: '480p',
      role: 'owner',
    ),
  ];
}

class _ManageableShopRepository extends _DemoRepository {
  String? updatedResolution;
  int? updatedClipSeconds;
  String? invitedContact;
  String? invitedRole;

  @override
  Future<List<MemberDto>> members(String shopId) async => const [
    MemberDto(accountUid: 'u1', role: 'manager', name: 'Nguyễn Văn A'),
  ];

  @override
  Future<List<VideoTypeDto>> videoTypes(String shopId) async => const [
    VideoTypeDto(id: 'default-pack', name: 'Đóng hàng', isDefault: true),
  ];

  /// Cụm cài đặt quay của lượt ghi gần nhất — bài test đọc để chắc màn hình
  /// gửi đúng thứ người dùng vừa gạt.
  Map<String, Object?>? updatedCaiDatQuay;

  @override
  Future<ShopDto> updateShop(
    String shopId, {
    String? name,
    String? platform,
    String? resolution,
    int? maxClipSeconds,
    Map<String, Object?>? caiDatQuay,
  }) async {
    updatedCaiDatQuay = caiDatQuay;
    updatedResolution = resolution;
    updatedClipSeconds = maxClipSeconds;
    return ShopDto(
      id: shopId,
      name: name ?? 'Shop ABC',
      platform: platform ?? 'shopee',
      resolution: resolution ?? '720p',
      role: 'owner',
    );
  }

  @override
  Future<ShopInviteDto> sendShopInvite(
    String shopId, {
    required String contact,
    required String role,
  }) async {
    invitedContact = contact;
    invitedRole = role;
    return ShopInviteDto(
      id: 'i1',
      shopId: shopId,
      contact: contact,
      role: role,
      status: 'pending',
      inviteToken: 'tok',
    );
  }
}

/// Kho đổi từ "hệ thống" sang Drive giữa hai lần đọc — đúng thứ xảy ra khi
/// người dùng rời app sang trình duyệt cấp quyền Google rồi quay lại.
class _DriveConnectingRepository extends _DemoRepository {
  _DriveConnectingRepository();

  bool connected = false;
  int reads = 0;

  @override
  Future<StorageStateDto> storage(String shopId) async {
    reads++;
    return StorageStateDto(
      byosAllowed: true,
      storage: connected
          ? const StorageViewDto(
              kind: StorageKind.gdrive,
              ok: true,
              label: 'truongpham0233@gmail.com',
            )
          : null,
    );
  }
}

class _DemoRepository extends FakeEcRepository {
  const _DemoRepository();

  @override
  Future<List<ShopDto>> shops() async => const [
    ShopDto(
      id: 's1',
      name: 'Shop ABC',
      platform: 'shopee',
      resolution: '720p',
      role: 'owner',
    ),
  ];

  @override
  Future<OrderPageDto> orders(
    String shopId, {
    int page = 1,
    String? uploadState,
    int? fromTs,
    int? toTs,
    String? videoTypeId,
  }) async => OrderPageDto(
    items: const [
      OrderSummaryDto(
        id: 'o1',
        tracking: 'SPXVN024567890',
        createdAt: 3,
        evidenceCount: 2,
      ),
    ],
    total: 1,
    page: page,
    pageSize: EcApi.ordersPageSize,
  );

  @override
  Future<List<VideoTypeDto>> videoTypes(String shopId) async => const [
    VideoTypeDto(id: 'default-pack', name: 'Đóng hàng', isDefault: true),
    VideoTypeDto(
      id: 'default-carrier',
      name: 'Đơn vị vận chuyển',
      isDefault: true,
    ),
    VideoTypeDto(id: 'default-return', name: 'Trả hàng', isDefault: true),
  ];
}

/// Hai hồ sơ CHỈ có trên máy chủ — không hồ sơ nào được tạo từ máy này.
///
/// Đúng hình dạng của cửa hàng vừa cài app trên điện thoại mới, hoặc của một
/// người bán vẫn tạo hồ sơ ở web.
class _ServerClaimsRepository extends _DemoRepository {
  /// Id mà màn chi tiết hỏi máy chủ. Đây là thứ cần đo: bản trước truyền id
  /// trên máy vào đây, mà máy chủ không biết id đó.
  static String? lastDetailId;

  @override
  Future<ClaimDetailDto> claimDetail(String shopId, String claimId) async {
    lastDetailId = claimId;
    return ClaimDetailDto(
      claim: ClaimDto(
        id: claimId,
        url: 'https://zenpack.vn/c/web1',
        title: 'Hồ sơ tạo ở web',
        orderCount: 2,
        evidenceCount: 3,
        // Đã thu hồi: buộc màn lùi về KHỐI THÔNG TIN thay vì nhúng trang công
        // khai — trang nhúng cần mạng thật, không dựng được trong widget test.
        revoked: true,
        createdAt: 1754000000000,
      ),
      url: 'https://zenpack.vn/c/web1',
      shopName: 'Shop ABC',
      platform: 'shopee',
      orders: const [],
      videos: 3,
      photos: 0,
    );
  }

  @override
  Future<List<ClaimDto>> listClaims(String shopId) async => const [
    ClaimDto(
      id: 'claim-web-1',
      url: 'https://zenpack.vn/c/web1',
      title: 'Hồ sơ tạo ở web',
      orderCount: 2,
      evidenceCount: 3,
      createdAt: 1754000000000,
    ),
    ClaimDto(
      id: 'claim-web-2',
      url: 'https://zenpack.vn/c/web2',
      title: 'Hồ sơ đã đóng',
      orderCount: 1,
      evidenceCount: 1,
      revoked: true,
      createdAt: 1754000000000,
    ),
  ];
}

/// Máy chủ không trả lời — đo nhánh lùi về bộ đệm trên máy.
class _ClaimListFailingRepository extends _DemoRepository {
  @override
  Future<List<ClaimDto>> listClaims(String shopId) async =>
      throw Exception('mạng hỏng');
}

/// Một đơn có ba clip trải hai ngày, trả về theo ĐÚNG chiều API thật: tăng dần
/// theo `captured_at`. Sắp xếp là việc của app.
class _TimelineOrderRepository extends _DemoRepository {
  static final _older = DateTime(2026, 8, 24, 10);
  static final _olderLater = DateTime(2026, 8, 24, 14, 30);
  static final _newest = DateTime(2026, 8, 25, 9, 15);

  EvidenceDto _clip(String id, DateTime at) => EvidenceDto(
    id: id,
    kind: 'video',
    capturedAt: at.millisecondsSinceEpoch,
    uploadStatus: 'done',
    videoTypeId: 'default-pack',
    sealStatus: 'sealed',
    sealedAt: at.millisecondsSinceEpoch,
    url: 'https://example.test/$id.mp4',
  );

  @override
  Future<OrderDetailDto> order(String shopId, String orderId) async =>
      OrderDetailDto(
        order: const OrderDto(
          id: 'o1',
          tracking: 'SPXVN024567890',
          createdAt: 3,
        ),
        evidence: [
          _clip('e-cu', _older),
          _clip('e-cu-muon', _olderLater),
          _clip('e-moi', _newest),
        ],
      );
}

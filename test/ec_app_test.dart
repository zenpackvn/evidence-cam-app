import 'dart:io';

import 'package:ec_data/ec_data.dart';
import 'package:ec_ui/ec_ui.dart'
    show LucideIcons, PenBackButton, PenBox, PenColors;
import 'package:evidence_cam/app/di/injection.dart';
import 'package:evidence_cam/ec_app.dart';
import 'package:feature_capture/feature_capture.dart' show debugPreviewDir;
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
      // Hộp thoại ĐÓNG là dấu hiệu quan sát được của một lời mời đã gửi.
      //
      // Bản trước chờ toast "Đã gửi lời mời". Chuỗi đó vẫn nằm trong từ điển
      // (`toastInviteSent`) nhưng KHÔNG mã nào còn gọi tới — toast đã bị bỏ, và
      // một khoá i18n mồ côi thì không có gì bắt được. Chờ nó là chờ mãi.
      expect(find.text('Thêm thành viên'), findsNothing);
      expect(find.text('Chi tiết cửa hàng'), findsOneWidget);
    },
  );

  testWidgets(
    'record type sheet can select a type and open shop detail management',
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

      await tester.tap(find.byIcon(LucideIcons.settings));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Trả hàng'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Trả hàng'), findsOneWidget);

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

  @override
  Future<ShopDto> updateShop(
    String shopId, {
    String? name,
    String? platform,
    String? resolution,
    int? maxClipSeconds,
  }) async {
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

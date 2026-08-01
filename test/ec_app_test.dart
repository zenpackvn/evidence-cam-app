import 'dart:io';

import 'package:ec_data/ec_data.dart';
import 'package:evidence_cam/app/di/injection.dart';
import 'package:evidence_cam/ec_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:network/network.dart'
    show DioException, DioExceptionType, RequestOptions, Response;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:storage/storage.dart';

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

void main() {
  PathProviderPlatform.instance = _FakePathProviderPlatform();
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

  Future<void> signInWithGoogleAndPhone(WidgetTester tester) async {
    await tester.tap(find.text('Bắt đầu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng nhập với Google'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, '0912345678');
    await tester.tap(find.text('Tiếp tục'));
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
      await pumpPhoneSizedApp(tester, const EcApp(repo: _DemoRepository()));

      // Splash
      expect(find.text('ZenPack'), findsOneWidget);
      await signInWithGoogleAndPhone(tester);

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
      await pumpPhoneSizedApp(tester, EcApp(repo: repo));

      await signInWithGoogleAndPhone(tester);

      expect(repo.ordersShopId, 'live-shop');
      expect(find.text('Không tải được đơn hàng'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
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
      // ...but we bounce back to Login (signed out) instead of entering the app.
      expect(auth.currentUser, isNull);
      expect(find.text('Chọn phương thức đăng nhập'), findsOneWidget);
    },
  );

  testWidgets(
    'social sign-in skips phone-setup when the account already has a phone',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(
        tester,
        const EcApp(repo: _PhoneOnFileRepository()),
      );

      await tester.tap(find.text('Bắt đầu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đăng nhập với Google'));
      await tester.pumpAndSettle();

      // No phone-setup step (no 'Tiếp tục'); it goes straight into the shop.
      expect(find.text('Tiếp tục'), findsNothing);
      expect(find.textContaining('SPXVN'), findsWidgets);
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
      await pumpPhoneSizedApp(tester, EcApp(auth: auth));

      await tester.tap(find.text('Bắt đầu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quên mật khẩu?'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).first, 'reset@b.com');
      await tester.tap(find.text('Gửi link đặt lại'));
      await tester.pumpAndSettle();

      expect(auth.resetEmail, 'reset@b.com');
      expect(
        find.text('Đã gửi — kiểm tra hộp thư (kể cả mục spam)'),
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
      await pumpPhoneSizedApp(tester, const EcApp(repo: _TwoShopRepository()));

      await signInWithGoogleAndPhone(tester);
      await tester.tap(find.text('Shop XYZ').first);
      await tester.pumpAndSettle();

      expect(memory.getString('shop.last_id'), 's2');
      expect(find.text('Shop XYZ'), findsOneWidget);
    },
  );

  testWidgets(
    'a single shop is selected automatically after login',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(tester, const EcApp(repo: _DemoRepository()));

      await signInWithGoogleAndPhone(tester);

      expect(find.textContaining('SPXVN'), findsWidgets);
      expect(find.text('Shop của bạn'), findsNothing);
    },
  );

  testWidgets(
    'account tab uses the selected shop instead of screen defaults',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(tester, const EcApp(repo: _TwoShopRepository()));

      await signInWithGoogleAndPhone(tester);
      await tester.tap(find.text('Shop XYZ').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tài khoản').last);
      await tester.pumpAndSettle();

      expect(find.text('Shop XYZ'), findsOneWidget);
      expect(find.text('Shop ABC'), findsNothing);
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
      await pumpPhoneSizedApp(tester, EcApp(repo: repo));

      await signInWithGoogleAndPhone(tester);
      await tester.tap(find.text('Tài khoản').last);
      await tester.pumpAndSettle();
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
      },
    ),
    (tester) async {
      final repo = _ProfileRepository();
      await pumpPhoneSizedApp(
        tester,
        EcApp(
          repo: repo,
          pickAvatarPath: () async => 'https://cdn.evidencecam.test/avatar.png',
        ),
      );

      await signInWithGoogleAndPhone(tester);
      await tester.tap(find.text('Tài khoản').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Người dùng Demo'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.camera_alt).last);
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

  testWidgets(
    'quota screen shows remaining storage from the repository',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(tester, EcApp(repo: _QuotaRepository()));

      await signInWithGoogleAndPhone(tester);
      await tester.tap(find.text('Tài khoản').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gói cước & Quota'));
      await tester.pumpAndSettle();

      expect(find.text('12 GB / 60 GB'), findsOneWidget);
      expect(find.text('Đã dùng 80%'), findsOneWidget);
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
      await pumpPhoneSizedApp(tester, EcApp(repo: repo));

      await signInWithGoogleAndPhone(tester);
      await tester.tap(find.text('Tài khoản').last);
      await tester.pumpAndSettle();
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
      await pumpPhoneSizedApp(tester, EcApp(repo: repo));

      await signInWithGoogleAndPhone(tester);
      await tester.tap(find.text('Tài khoản').last);
      await tester.pumpAndSettle();
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

      await signInWithGoogleAndPhone(tester);
      expect(auth.currentUser!.hasPassword, isFalse);
      await tester.tap(find.text('Tài khoản').last);
      await tester.pumpAndSettle();

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
      await pumpPhoneSizedApp(tester, EcApp(repo: repo));

      await signInWithGoogleAndPhone(tester);
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

  testWidgets(
    'shop detail resolution changes are saved through the repository',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      final repo = _ManageableShopRepository();
      await pumpPhoneSizedApp(tester, EcApp(repo: repo));

      await signInWithGoogleAndPhone(tester);
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quản lý cửa hàng'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Shop ABC'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Độ phân giải quay'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('480p'));
      await tester.pumpAndSettle();

      expect(repo.updatedResolution, '480p');
    },
  );

  testWidgets(
    'shop detail sends a pending member invite by contact',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      final repo = _ManageableShopRepository();
      await pumpPhoneSizedApp(tester, EcApp(repo: repo));

      await signInWithGoogleAndPhone(tester);
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quản lý cửa hàng'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Shop ABC'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thêm thành viên bằng email/SĐT'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).first, 'new@b.com');
      await tester.tap(find.text('Thêm'));
      await tester.pumpAndSettle();

      expect(repo.invitedContact, 'new@b.com');
      expect(repo.invitedRole, 'staff');
      expect(find.text('Đã gửi lời mời'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'record type sheet can select a type and open shop detail management',
    experimentalLeakTesting: LeakTesting.settings.withIgnored(
      notDisposed: {
        'ImageStreamCompleterHandle': 1,
        'ValueNotifier<EcUser?>': 1,
      },
    ),
    (tester) async {
      await pumpPhoneSizedApp(tester, const EcApp(repo: _DemoRepository()));

      await signInWithGoogleAndPhone(tester);
      await tester.tap(find.text('Ghi hình').last);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.settings_outlined));
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

class _RecordingAuth extends FakeEcAuth {
  String? registeredEmail;
  String? updatedPhone;
  String? resetEmail;

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
  Future<EcUser> updateProfile({String? name, String? phone}) async {
    updatedPhone = phone;
    return super.updateProfile(name: name, phone: phone);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    resetEmail = email;
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
    usedBytes: 48 * 1024 * 1024 * 1024,
    capBytes: 60 * 1024 * 1024 * 1024,
    remainingBytes: 12 * 1024 * 1024 * 1024,
    retentionDays: 25,
  );
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
    int? maxUploadBytes,
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

class _PhoneOnFileRepository extends _DemoRepository {
  const _PhoneOnFileRepository();

  @override
  Future<AccountDto> account() async => const AccountDto(
    uid: 'fake-uid',
    email: 'demo@evidencecam.app',
    phone: '0912345678',
  );
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

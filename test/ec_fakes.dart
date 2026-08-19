/// Test doubles for the auth and repository seams.
///
/// These used to live in `packages/ec_data/lib` and were bound by the app when
/// Firebase was off or `EC_API_URL` was empty — which meant a misconfigured
/// build shipped demo records instead of failing. They are test-only now: the
/// app requires a real auth and a real API origin.
library;

import 'package:ec_data/ec_data.dart';
import 'package:flutter/foundation.dart';

/// In-memory auth so the app runs before Firebase is configured.
class FakeEcAuth implements EcAuth {
  // ponytail: app-scoped singleton, lives for the process — never disposed.
  final ValueNotifier<EcUser?> _user = ValueNotifier<EcUser?>(null);
  String? _password;

  @override
  ValueListenable<EcUser?> get user => _user;

  @override
  EcUser? get currentUser => _user.value;

  EcUser _signedIn({
    String? email,
    List<String> providers = const ['password'],
  }) => EcUser(
    uid: 'fake-uid',
    email: email ?? 'demo@evidencecam.app',
    displayName: 'Người dùng Demo',
    providers: providers,
  );

  EcUser _require() {
    final u = _user.value;
    if (u == null) throw const EcAuthException('Chưa đăng nhập');
    return u;
  }

  @override
  Future<EcUser> signInWithEmail(String email, String password) async {
    _password = password;
    return _user.value = _signedIn(email: email);
  }

  @override
  Future<EcUser> registerWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    _password = password;
    // Như Firebase: tài khoản email/mật khẩu mới tạo chưa xác minh cho tới khi
    // bấm link trong mail.
    return _user.value = EcUser(
      uid: 'fake-uid',
      email: email,
      displayName: name,
      providers: const ['password'],
      emailVerified: false,
    );
  }

  @override
  Future<EcUser> signInWithGoogle() async {
    _password = null;
    return _user.value = _signedIn(providers: const ['google.com']);
  }

  @override
  Future<EcUser> signInWithApple() async {
    _password = null;
    return _user.value = _signedIn(providers: const ['apple.com']);
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> sendEmailVerification() async => _require();

  @override
  Future<void> signOut() async => _user.value = null;

  @override
  Future<EcUser> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async => _user.value = _require().copyWith(
    displayName: name,
    phone: phone,
    photoUrl: photoUrl,
  );

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _require();
    if (_password == null) {
      throw const EcAuthException('Tài khoản chưa có mật khẩu để đổi');
    }
    if (currentPassword != _password) {
      throw const EcAuthException('Mật khẩu hiện tại không đúng');
    }
    _password = newPassword;
  }

  @override
  Future<EcUser> createPassword({required String newPassword}) async {
    final u = _require();
    if (u.email == null) {
      throw const EcAuthException('Tài khoản không có email để tạo mật khẩu');
    }
    if (u.hasPassword) {
      throw const EcAuthException('Tài khoản đã có mật khẩu');
    }
    _password = newPassword;
    return _user.value = u.copyWith(providers: [...u.providers, 'password']);
  }

  @override
  Future<EcUser> linkProvider(EcAuthProvider provider) async {
    final u = _require();
    if (u.hasProvider(provider)) return u;
    return _user.value = u.copyWith(providers: [...u.providers, provider.id]);
  }

  @override
  Future<EcUser> unlinkProvider(EcAuthProvider provider) async {
    final u = _require();
    final rest = u.providers.where((p) => p != provider.id).toList();
    if (rest.isEmpty) {
      throw const EcAuthException(
        'Không thể gỡ phương thức đăng nhập cuối cùng',
      );
    }
    return _user.value = u.copyWith(providers: rest);
  }

  @override
  Future<void> deleteAccount() async {
    _password = null;
    _user.value = null;
  }

  @override
  Future<String?> idToken() async => _user.value == null ? null : 'fake-token';
}

/// Empty in-memory data source for tests and local runs without a backend URL.
class FakeEcRepository implements EcRepository {
  const FakeEcRepository();

  @override
  Future<List<ShopDto>> shops() async => const [];

  // Mã của vận đơn: bản giả không giữ trạng thái, nên gắn mã trả về đúng cái
  // vừa gắn và tra mã trả rỗng. Đủ cho màn hình dựng được; đường đi thật đã có
  // test riêng ở `packages/ec_data/test/ec_api_test.dart`.
  @override
  Future<List<OrderCodeDto>> orderCodes(String shopId, String orderId) async =>
      const [];

  @override
  Future<void> connectGdriveCode(String shopId, String code) async {}

  // Hồ sơ rỗng: đủ để màn chi tiết dựng được mà không cần máy chủ.
  @override
  Future<ClaimDetailDto> claimDetail(String shopId, String claimId) async =>
      ClaimDetailDto(
        claim: ClaimDto(id: claimId, url: ''),
        url: '',
        shopName: 'Shop',
        platform: 'shopee',
        orders: const [],
        videos: 0,
        photos: 0,
      );

  @override
  Future<OrderCodeDto> addOrderCode(
    String shopId,
    String orderId, {
    required String code,
    required String kind,
  }) async => OrderCodeDto(
    id: 'fake-code',
    orderId: orderId,
    kind: kind,
    raw: code,
    isPrimary: false,
  );

  @override
  Future<void> removeOrderCode(
    String shopId,
    String orderId,
    String codeId,
  ) async {}

  @override
  Future<List<OrderCodeDto>> lookupOrderCode(
    String shopId,
    String code,
  ) async => const [];

  @override
  Future<ShopDto> shop(String shopId) async => ShopDto(
    id: shopId,
    name: 'Shop',
    platform: 'shopee',
    resolution: '720p',
    role: 'owner',
  );

  // No backend → a demo account with no phone, which is a perfectly usable one.
  @override
  Future<AccountDto> account() async =>
      const AccountDto(uid: 'fake-uid', email: 'demo@evidencecam.app');

  @override
  Future<String> uploadAvatar(String filePath) async => filePath;

  @override
  Future<AccountDto> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async => AccountDto(
    uid: 'fake-uid',
    email: 'demo@evidencecam.app',
    name: name,
    phone: phone,
    avatarUrl: avatarUrl,
  );

  @override
  Future<ShopDto> createShop({
    required String name,
    required String platform,
    String? resolution,
  }) async => ShopDto(
    id: 's${DateTime.now().microsecondsSinceEpoch}',
    name: name,
    platform: platform,
    resolution: resolution ?? '720p',
    role: 'owner',
  );

  @override
  Future<ShopDto> updateShop(
    String shopId, {
    String? name,
    String? platform,
    String? resolution,
    int? maxClipSeconds,
  }) async => ShopDto(
    id: shopId,
    name: name ?? 'Shop',
    platform: platform ?? 'khac',
    resolution: resolution ?? '720p',
    role: 'owner',
    clipSeconds: maxClipSeconds ?? 300,
  );

  @override
  Future<List<MemberDto>> members(String shopId) async => const [
    MemberDto(accountUid: 'fake-uid', role: 'owner'),
  ];

  @override
  Future<ShopInviteDto> sendShopInvite(
    String shopId, {
    required String contact,
    required String role,
  }) async => ShopInviteDto(
    id: 'fake-invite',
    shopId: shopId,
    contact: contact,
    role: role,
    status: 'pending',
    inviteToken: 'fake-token',
  );

  @override
  Future<void> revokeShopInvite(String shopId, String inviteId) async {}

  @override
  Future<QrInviteDto> createQrInvite(String shopId) async => QrInviteDto(
    inviteId: 'fake-invite',
    token: 'fake-token',
    url: 'https://zenpack.vn/invite/fake-token',
    expiresAt: DateTime.now().millisecondsSinceEpoch + 600000,
  );

  @override
  Future<AcceptedInviteDto> acceptInvite(String token) async =>
      const AcceptedInviteDto(
        shopId: 'fake-shop',
        shopName: 'Shop ABC',
        role: 'staff',
        newlyJoined: true,
      );

  @override
  Future<void> removeMember(String shopId, String accountUid) async {}

  @override
  Future<List<VideoTypeDto>> videoTypes(String shopId) async => const [];

  @override
  Future<VideoTypeDto> addVideoType(
    String shopId,
    String name, {
    String? icon,
    String? color,
  }) async => VideoTypeDto(
    id: 'vt-new',
    name: name,
    isDefault: false,
    icon: icon,
    color: color,
  );

  @override
  Future<VideoTypeDto> renameVideoType(
    String shopId,
    String typeId,
    String name, {
    String? icon,
    String? color,
  }) async => VideoTypeDto(
    id: typeId,
    name: name,
    isDefault: false,
    icon: icon,
    color: color,
  );

  @override
  Future<void> deleteVideoType(String shopId, String typeId) async {}

  @override
  Future<ClaimDto> createClaim(
    String shopId,
    List<String> orderIds, {
    String? title,
    List<String>? evidenceIds,
  }) async =>
      const ClaimDto(id: 'claim-demo', url: 'https://zenpack.vn/c/demo');

  @override
  Future<List<ClaimDto>> listClaims(String shopId) async => const [];

  @override
  Future<void> revokeClaim(String shopId, String claimId) async {}

  @override
  Future<ShopDeletionPreviewDto> shopDeletionPreview(String shopId) async =>
      const ShopDeletionPreviewDto(orders: 12, videos: 34, members: 2);

  @override
  Future<void> deleteShop(String shopId, {bool force = false}) async {}

  // Bản mẫu luôn ở kho hệ thống, và `byosAllowed: false` — màn xem trước không
  // được chào một cái nút mà bản thật sẽ khoá theo gói.
  @override
  Future<StorageStateDto> storage(String shopId) async =>
      const StorageStateDto(health: StorageHealthDto(total: 42, intact: 42));

  @override
  Future<StorageValidateDto> saveS3Storage(
    String shopId, {
    required String endpoint,
    required String bucket,
    required String accessKeyId,
    required String secretAccessKey,
    String region = 'auto',
    String prefix = 'evidencecam',
  }) async => const StorageValidateDto(ok: true);

  @override
  Future<StorageValidateDto> testStorage(String shopId) async =>
      const StorageValidateDto(ok: true);

  @override
  Future<StorageValidateDto> validateS3Storage(
    String shopId, {
    required String endpoint,
    required String bucket,
    required String accessKeyId,
    required String secretAccessKey,
    String region = 'auto',
    String prefix = 'evidencecam',
  }) async => const StorageValidateDto(ok: true);

  @override
  Future<void> disconnectStorage(String shopId) async {}

  @override
  Future<void> reportQueueDepth(
    String shopId, {
    required int pending,
    int pendingBytes = 0,
    int? oldestAt,
  }) async {}

  @override
  Future<QuotaDto> quota({String? shopId}) async => const QuotaDto(
    planCode: 'basic',
    usedVideos: 214,
    capVideos: 1000,
    remainingVideos: 786,
    retentionDays: 30,
  );

  @override
  Future<OrderPageDto> orders(
    String shopId, {
    int page = 1,
    String? uploadState,
    int? fromTs,
    int? toTs,
    String? videoTypeId,
  }) async {
    return OrderPageDto(
      items: const [],
      total: 0,
      page: page,
      pageSize: EcApi.ordersPageSize,
    );
  }

  @override
  Future<List<OrderSummaryDto>> searchOrders(
    String shopId,
    String query,
  ) async {
    return const [];
  }

  @override
  Future<OrderDto> createOrder(String shopId, String tracking) async =>
      OrderDto(id: 'new', tracking: tracking, createdAt: 0);

  @override
  Future<OrderDetailDto> order(String shopId, String orderId) async =>
      OrderDetailDto(
        order: OrderDto(id: orderId, tracking: '', createdAt: 0),
        evidence: const [],
      );

  @override
  Future<DossierDto?> dossier(String shopId, String orderId) async => null;

  @override
  String verifyUrl(String evidenceId) => '';

  @override
  Future<void> deleteEvidence(
    String shopId,
    String orderId,
    String evidenceId,
  ) async {}

  @override
  Future<void> deleteAccount({bool force = false, bool dryRun = false}) async {}
}

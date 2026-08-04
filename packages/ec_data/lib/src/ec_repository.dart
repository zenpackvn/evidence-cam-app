import 'ec_api.dart';
import 'ec_models.dart';

/// The seam screens read through. Production binds [RemoteEcRepository] once
/// the Worker base URL is set; tests may bind [FakeEcRepository].
abstract interface class EcRepository {
  Future<List<ShopDto>> shops();

  /// Một shop kèm ngân sách clip mới nhất — màn Chi tiết cửa hàng đọc lại sau
  /// mỗi lần sửa cài đặt thay vì tin vào snapshot của route.
  Future<ShopDto> shop(String shopId);

  /// The signed-in account (`GET /api/me`). Name and the optional support phone
  /// live in D1, not Firebase Auth, so the profile screen reads them from here.
  /// The call also claims any shop invite addressed to this account's email.
  Future<AccountDto> account();

  Future<AccountDto> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  });
  Future<ShopDto> createShop({
    required String name,
    required String platform,
    String? resolution,
  });
  Future<ShopDto> updateShop(
    String shopId, {
    String? name,
    String? platform,
    String? resolution,
    int? maxClipSeconds,
    int? maxImageBytes,
    int? maxVideoBytes,
    int? maxUploadBytes,
  });
  Future<List<MemberDto>> members(String shopId);
  Future<void> addMember(
    String shopId, {
    required String accountUid,
    required String role,
  });
  Future<ShopInviteDto> sendShopInvite(
    String shopId, {
    required String contact,
    required String role,
  });
  Future<void> updateMemberRole(
    String shopId, {
    required String accountUid,
    required String role,
  });
  Future<void> removeMember(String shopId, String accountUid);
  Future<List<VideoTypeDto>> videoTypes(String shopId);
  Future<VideoTypeDto> addVideoType(
    String shopId,
    String name, {
    String? icon,
    String? color,
  });
  Future<VideoTypeDto> renameVideoType(
    String shopId,
    String typeId,
    String name, {
    String? icon,
    String? color,
  });
  Future<void> deleteVideoType(String shopId, String typeId);
  Future<QuotaDto> quota({String? shopId});

  /// Page [page] (1-based) of orders, newest first. [uploadState] /
  /// [fromTs]–[toTs] / [videoTypeId] are the "Vận đơn" tab's three filters; they are applied by
  /// the backend because the list is paged and a client-side filter would only
  /// ever see the rows already loaded.
  Future<OrderPageDto> orders(
    String shopId, {
    int page,
    String? uploadState,
    int? fromTs,
    int? toTs,
    String? videoTypeId,
  });
  Future<List<OrderSummaryDto>> searchOrders(String shopId, String query);
  Future<OrderDto> createOrder(String shopId, String tracking);
  Future<OrderDetailDto> order(String shopId, String orderId);

  /// FR-07: link hồ sơ khiếu nại của đơn, `null` khi chưa có. Chỉ đọc — link
  /// được tạo/thu hồi ở web admin.
  Future<DossierDto?> dossier(String shopId, String orderId);

  /// Gửi góp ý người dùng nhập trong app.
  Future<void> sendFeedback({
    required String message,
    String? platform,
    String? appVersion,
  });

  /// URL công khai của [shareToken].
  String dossierShareUrl(String shareToken);
  Future<void> deleteEvidence(String shopId, String orderId, String evidenceId);
  Future<void> deleteAccount({bool force, bool dryRun});
}

/// Live implementation — delegates straight to the typed [EcApi].
class RemoteEcRepository implements EcRepository {
  const RemoteEcRepository(this._api);

  final EcApi _api;

  @override
  Future<List<ShopDto>> shops() => _api.listShops();

  @override
  Future<ShopDto> shop(String shopId) => _api.getShop(shopId);

  @override
  Future<AccountDto> account() => _api.getMe();

  @override
  Future<AccountDto> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) => _api.updateProfile(name: name, phone: phone, avatarUrl: avatarUrl);

  @override
  Future<ShopDto> createShop({
    required String name,
    required String platform,
    String? resolution,
  }) => _api.createShop(name: name, platform: platform, resolution: resolution);

  @override
  Future<ShopDto> updateShop(
    String shopId, {
    String? name,
    String? platform,
    String? resolution,
    int? maxClipSeconds,
    int? maxImageBytes,
    int? maxVideoBytes,
    int? maxUploadBytes,
  }) => _api.updateShop(
    shopId,
    name: name,
    platform: platform,
    resolution: resolution,
    maxClipSeconds: maxClipSeconds,
    maxImageBytes: maxImageBytes,
    maxVideoBytes: maxVideoBytes,
    maxUploadBytes: maxUploadBytes,
  );

  @override
  Future<List<MemberDto>> members(String shopId) => _api.listMembers(shopId);

  @override
  Future<void> addMember(
    String shopId, {
    required String accountUid,
    required String role,
  }) => _api.addMember(shopId, accountUid: accountUid, role: role);

  @override
  Future<ShopInviteDto> sendShopInvite(
    String shopId, {
    required String contact,
    required String role,
  }) => _api.sendShopInvite(shopId, contact: contact, role: role);

  @override
  Future<void> updateMemberRole(
    String shopId, {
    required String accountUid,
    required String role,
  }) => _api.updateMemberRole(shopId, accountUid: accountUid, role: role);

  @override
  Future<void> removeMember(String shopId, String accountUid) =>
      _api.removeMember(shopId, accountUid);

  @override
  Future<List<VideoTypeDto>> videoTypes(String shopId) =>
      _api.listVideoTypes(shopId);

  @override
  Future<VideoTypeDto> addVideoType(
    String shopId,
    String name, {
    String? icon,
    String? color,
  }) => _api.addVideoType(shopId, name, icon: icon, color: color);

  @override
  Future<VideoTypeDto> renameVideoType(
    String shopId,
    String typeId,
    String name, {
    String? icon,
    String? color,
  }) => _api.renameVideoType(shopId, typeId, name, icon: icon, color: color);

  @override
  Future<void> deleteVideoType(String shopId, String typeId) =>
      _api.deleteVideoType(shopId, typeId);

  @override
  Future<QuotaDto> quota({String? shopId}) => _api.getQuota(shopId: shopId);

  @override
  Future<OrderPageDto> orders(
    String shopId, {
    int page = 1,
    String? uploadState,
    int? fromTs,
    int? toTs,
    String? videoTypeId,
  }) => _api.listOrders(
    shopId,
    page: page,
    uploadState: uploadState,
    fromTs: fromTs,
    toTs: toTs,
    videoTypeId: videoTypeId,
  );

  @override
  Future<List<OrderSummaryDto>> searchOrders(String shopId, String query) =>
      _api.searchOrders(shopId, query);

  @override
  Future<OrderDto> createOrder(String shopId, String tracking) =>
      _api.findOrCreateOrder(shopId, tracking);

  @override
  Future<OrderDetailDto> order(String shopId, String orderId) =>
      _api.getOrder(shopId, orderId);

  @override
  Future<DossierDto?> dossier(String shopId, String orderId) =>
      _api.getDossier(shopId, orderId);

  @override
  Future<void> sendFeedback({
    required String message,
    String? platform,
    String? appVersion,
  }) => _api.sendFeedback(
    message: message,
    platform: platform,
    appVersion: appVersion,
  );

  @override
  String dossierShareUrl(String shareToken) => _api.dossierShareUrl(shareToken);

  @override
  Future<void> deleteEvidence(
    String shopId,
    String orderId,
    String evidenceId,
  ) => _api.deleteEvidence(shopId, orderId, evidenceId);

  @override
  Future<void> deleteAccount({bool force = false, bool dryRun = false}) =>
      _api.deleteAccount(force: force, dryRun: dryRun);
}

/// Empty in-memory data source for tests and local runs without a backend URL.
class FakeEcRepository implements EcRepository {
  const FakeEcRepository();

  @override
  Future<List<ShopDto>> shops() async => const [];

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
    int? maxImageBytes,
    int? maxVideoBytes,
    int? maxUploadBytes,
  }) async => ShopDto(
    id: shopId,
    name: name ?? 'Shop',
    platform: platform ?? 'khac',
    resolution: resolution ?? '720p',
    role: 'owner',
    clipSeconds: maxClipSeconds ?? 120,
    uploadBytes: maxUploadBytes ?? 10000000,
  );

  @override
  Future<List<MemberDto>> members(String shopId) async => const [
    MemberDto(accountUid: 'fake-uid', role: 'owner'),
  ];

  @override
  Future<void> addMember(
    String shopId, {
    required String accountUid,
    required String role,
  }) async {}

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
  Future<void> updateMemberRole(
    String shopId, {
    required String accountUid,
    required String role,
  }) async {}

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
  Future<QuotaDto> quota({String? shopId}) async => const QuotaDto(
    planCode: 'basic',
    usedBytes: 12 * 1024 * 1024 * 1024,
    capBytes: 60 * 1024 * 1024 * 1024,
    remainingBytes: 48 * 1024 * 1024 * 1024,
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
  Future<void> sendFeedback({
    required String message,
    String? platform,
    String? appVersion,
  }) async {}

  @override
  String dossierShareUrl(String shareToken) => '';

  @override
  Future<void> deleteEvidence(
    String shopId,
    String orderId,
    String evidenceId,
  ) async {}

  @override
  Future<void> deleteAccount({bool force = false, bool dryRun = false}) async {}
}

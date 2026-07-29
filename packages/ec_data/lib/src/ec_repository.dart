import 'ec_api.dart';
import 'ec_models.dart';

/// The seam screens read through. Production binds [RemoteEcRepository] once
/// the Worker base URL is set; tests may bind [FakeEcRepository].
abstract interface class EcRepository {
  Future<List<ShopDto>> shops();

  /// The signed-in account (`GET /api/me`). Read after a social sign-in to tell
  /// whether the business phone is already on file (it lives in D1, not Firebase
  /// Auth) so a returning account skips the phone-setup step.
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
  Future<VideoTypeDto> addVideoType(String shopId, String name);
  Future<VideoTypeDto> renameVideoType(
    String shopId,
    String typeId,
    String name,
  );
  Future<void> deleteVideoType(String shopId, String typeId);
  Future<QuotaDto> quota({String? shopId});
  /// A page of orders, newest first. [uploadState] / [fromTs] / [videoTypeId]
  /// are the "Vận đơn" tab's three filters; they are applied by the backend
  /// because the list is paged and a client-side filter would only ever see
  /// the rows already loaded.
  Future<List<OrderSummaryDto>> orders(
    String shopId, {
    int? before,
    String? uploadState,
    int? fromTs,
    String? videoTypeId,
  });
  Future<List<OrderSummaryDto>> searchOrders(String shopId, String query);
  Future<OrderDto> createOrder(String shopId, String tracking);
  Future<OrderDetailDto> order(String shopId, String orderId);
  Future<DossierDto?> getDossier(String shopId, String orderId);
  Future<DossierDto> shareDossier(String shopId, String orderId);
  Future<void> revokeDossier(String shopId, String orderId);
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
  }) => _api.updateShop(
    shopId,
    name: name,
    platform: platform,
    resolution: resolution,
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
  Future<VideoTypeDto> addVideoType(String shopId, String name) =>
      _api.addVideoType(shopId, name);

  @override
  Future<VideoTypeDto> renameVideoType(
    String shopId,
    String typeId,
    String name,
  ) => _api.renameVideoType(shopId, typeId, name);

  @override
  Future<void> deleteVideoType(String shopId, String typeId) =>
      _api.deleteVideoType(shopId, typeId);

  @override
  Future<QuotaDto> quota({String? shopId}) => _api.getQuota(shopId: shopId);

  @override
  Future<List<OrderSummaryDto>> orders(
    String shopId, {
    int? before,
    String? uploadState,
    int? fromTs,
    String? videoTypeId,
  }) => _api.listOrders(
    shopId,
    before: before,
    uploadState: uploadState,
    fromTs: fromTs,
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
  Future<DossierDto?> getDossier(String shopId, String orderId) =>
      _api.getDossier(shopId, orderId);

  @override
  Future<DossierDto> shareDossier(String shopId, String orderId) =>
      _api.createDossier(shopId, orderId);

  @override
  Future<void> revokeDossier(String shopId, String orderId) =>
      _api.revokeDossier(shopId, orderId);

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

  // No backend → no phone on file, so social sign-ins land on phone-setup.
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
  }) async => ShopDto(
    id: shopId,
    name: name ?? 'Shop',
    platform: platform ?? 'khac',
    resolution: resolution ?? '720p',
    role: 'owner',
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
  Future<VideoTypeDto> addVideoType(String shopId, String name) async =>
      VideoTypeDto(id: 'vt-new', name: name, isDefault: false);

  @override
  Future<VideoTypeDto> renameVideoType(
    String shopId,
    String typeId,
    String name,
  ) async => VideoTypeDto(id: typeId, name: name, isDefault: false);

  @override
  Future<void> deleteVideoType(String shopId, String typeId) async {}

  @override
  Future<QuotaDto> quota({String? shopId}) async => const QuotaDto(
    planCode: 'basic',
    usedBytes: 12 * 1024 * 1024 * 1024,
    capBytes: 60 * 1024 * 1024 * 1024,
    remainingBytes: 48 * 1024 * 1024 * 1024,
    retentionDays: 25,
  );

  @override
  Future<List<OrderSummaryDto>> orders(
    String shopId, {
    int? before,
    String? uploadState,
    int? fromTs,
    String? videoTypeId,
  }) async {
    return const [];
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
  Future<DossierDto?> getDossier(String shopId, String orderId) async => null;

  @override
  Future<DossierDto> shareDossier(String shopId, String orderId) async =>
      const DossierDto(
        shareToken: '',
        revoked: false,
      );

  @override
  Future<void> revokeDossier(String shopId, String orderId) async {}

  @override
  Future<void> deleteEvidence(
    String shopId,
    String orderId,
    String evidenceId,
  ) async {}

  @override
  Future<void> deleteAccount({bool force = false, bool dryRun = false}) async {}
}

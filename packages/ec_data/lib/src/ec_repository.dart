import 'dart:io';

import 'ec_api.dart';
import 'ec_models.dart';

/// The seam screens read through. [RemoteEcRepository] is the only
/// implementation that ships; tests bind their own double
/// (`test/ec_fakes.dart`).
/// Ảnh đại diện vượt trần backend nhận.
///
/// Kiểu riêng chứ không phải một chuỗi lỗi: bên gọi cần nói được ảnh nặng bao
/// nhiêu và trần là bao nhiêu, chứ không chỉ "không lưu được".
class AvatarTooLargeException implements Exception {
  const AvatarTooLargeException(this.bytes, this.maxBytes);

  final int bytes;
  final int maxBytes;

  @override
  String toString() => 'AvatarTooLargeException($bytes > $maxBytes)';
}

abstract interface class EcRepository {
  Future<List<ShopDto>> shops();

  /// Một shop kèm ngân sách clip mới nhất — màn Chi tiết cửa hàng đọc lại sau
  /// mỗi lần sửa cài đặt thay vì tin vào snapshot của route.
  Future<ShopDto> shop(String shopId);

  /// The signed-in account (`GET /api/me`). Name and the optional support phone
  /// live in D1, not Firebase Auth, so the profile screen reads them from here.
  ///
  /// Lời gọi này KHÔNG nhận lời mời nào cả — dù email tài khoản trùng đúng địa
  /// chỉ được mời. Vào shop được mời phải qua [acceptInvite] với token trong
  /// link email.
  Future<AccountDto> account();

  /// Tải ảnh đại diện lên và trả về URL đọc công khai.
  Future<String> uploadAvatar(String filePath);

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
  });

  Future<List<MemberDto>> members(String shopId);
  Future<ShopInviteDto> sendShopInvite(
    String shopId, {
    required String contact,
    required String role,
  });

  /// Thu hồi lời mời còn treo. Hàng `pending` không có uid nên gỡ nó là việc
  /// của lời mời, không phải của [removeMember].
  Future<void> revokeShopInvite(String shopId, String inviteId);

  /// Mã QR mời: dùng một lần, sống 10 phút, chưa gắn với ai.
  Future<QrInviteDto> createQrInvite(String shopId);

  /// Nhận một lời mời bằng token trong link email hoặc trong mã QR.
  ///
  /// Đây là ĐƯỜNG DUY NHẤT để vào một shop mình được mời: máy chủ không tự
  /// ghép lời mời treo với tài khoản khi đăng nhập, kể cả khi email trùng
  /// khớp. Không gọi cái này thì shop không bao giờ xuất hiện.
  Future<AcceptedInviteDto> acceptInvite(String token);

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

  /// Gộp nhiều đơn thành một hồ sơ khiếu nại; trả link công khai zenpack.vn.
  /// [evidenceIds] giới hạn trang công khai xuống những clip đã tick. Bỏ
  /// trống = hiện đủ mọi bằng chứng của các đơn.
  Future<ClaimDto> createClaim(
    String shopId,
    List<String> orderIds, {
    String? title,
    List<String>? evidenceIds,
  });
  Future<List<ClaimDto>> listClaims(String shopId);

  /// Khối thông tin của một hồ sơ, cho màn chi tiết. Không kèm link từng clip.
  Future<ClaimDetailDto> claimDetail(String shopId, String claimId);
  Future<void> revokeClaim(String shopId, String claimId);

  /// Xoá cửa hàng này sẽ mất những gì. Chỉ chủ shop đọc được.
  Future<ShopDeletionPreviewDto> shopDeletionPreview(String shopId);

  /// Xoá HẲN cửa hàng. Ném khi còn hồ sơ khiếu nại đang mở, trừ khi [force].
  Future<void> deleteShop(String shopId, {bool force});

  /// Kho riêng của shop (BYOS, mục 5.1). Đọc được với mọi vai trò; đổi thì chỉ
  /// chủ shop — máy chủ chặn, `byosAllowed` chỉ để ẩn nút.
  Future<StorageStateDto> storage(String shopId);
  Future<StorageValidateDto> saveS3Storage(
    String shopId, {
    required String endpoint,
    required String bucket,
    required String accessKeyId,
    required String secretAccessKey,
    String region,
    String prefix,
  });
  Future<StorageValidateDto> testStorage(String shopId);

  /// Thử một cấu hình S3 mà KHÔNG lưu — nút "Kiểm tra" ở màn Kho lưu trữ.
  Future<StorageValidateDto> validateS3Storage(
    String shopId, {
    required String endpoint,
    required String bucket,
    required String accessKeyId,
    required String secretAccessKey,
    String region,
    String prefix,
  });
  Future<void> disconnectStorage(String shopId);

  /// Thôi dùng / dùng lại kho riêng, giữ nguyên cấu hình đã cắm.
  Future<void> setStorageActive(String shopId, {required bool active});

  /// Cắm Drive bằng mã uỷ quyền từ hộp thoại gốc, không qua trình duyệt.
  Future<void> connectGdriveCode(String shopId, String code);

  /// Link cấp quyền Drive, mở trong WebView của app (xem [EcApi.gdriveAuthUrl]).
  Future<String> gdriveAuthUrl(String shopId);

  /// Khai số clip chưa upload được đang nằm trên máy này (xem
  /// [EcApi.reportQueueDepth]). Nuốt lỗi ở tầng hiện thực: đây là báo cáo phụ
  /// trợ, hỏng thì không được làm gì khác hỏng theo.
  Future<void> reportQueueDepth(
    String shopId, {
    required int pending,
    int pendingBytes,
    int? oldestAt,
  });

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

  /// Mọi mã đang gắn vào một đơn.
  Future<List<OrderCodeDto>> orderCodes(String shopId, String orderId);

  /// Gắn thêm một mã (mã trả hàng, hoặc mã vận đơn thứ hai) vào đơn đang mở.
  Future<OrderCodeDto> addOrderCode(
    String shopId,
    String orderId, {
    required String code,
    required String kind,
  });

  /// Gỡ một mã khỏi đơn. Mã chính không gỡ được.
  Future<void> removeOrderCode(String shopId, String orderId, String codeId);

  /// Tra mã KHỚP TUYỆT ĐỐI — đường của máy quét, khác `searchOrders` tìm gần đúng.
  Future<List<OrderCodeDto>> lookupOrderCode(String shopId, String code);
  Future<OrderDto> createOrder(String shopId, String tracking);
  Future<OrderDetailDto> order(String shopId, String orderId);

  /// FR-07: link hồ sơ khiếu nại của đơn, `null` khi chưa có. Chỉ đọc — link
  /// được tạo/thu hồi ở web admin.
  Future<DossierDto?> dossier(String shopId, String orderId);

  /// Trang kiểm chứng công khai của một bằng chứng — không cần đăng nhập, và
  /// chính chỗ đó dẫn tiếp sang công cụ kiểm chứng của bên thứ ba.
  String verifyUrl(String evidenceId);
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
  Future<String> uploadAvatar(String filePath) async {
    final file = File(filePath);
    // Chặn tại chỗ thay vì để backend trả 413 — ảnh máy ảnh hiện đại vượt 2MB
    // là chuyện thường, và một mã lỗi HTTP thì không nói cho ai biết phải chọn
    // ảnh nhỏ hơn.
    final bytes = await file.length();
    if (bytes > EcApi.avatarMaxBytes) {
      throw AvatarTooLargeException(bytes, EcApi.avatarMaxBytes);
    }
    final account = await _api.uploadAvatar(file);
    final url = account.avatarUrl;
    // Máy chủ nhận ảnh mà không trả địa chỉ đọc là hợp đồng hỏng, không phải
    // "chưa có ảnh" — ném lên để bên gọi báo, thay vì ghi một URL rỗng đè lên
    // ảnh cũ.
    if (url == null || url.isEmpty) {
      throw StateError('PUT /api/me/avatar did not return an avatar_url');
    }
    return url;
  }

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
  }) => _api.updateShop(
    shopId,
    name: name,
    platform: platform,
    resolution: resolution,
    maxClipSeconds: maxClipSeconds,
  );

  @override
  Future<List<MemberDto>> members(String shopId) => _api.listMembers(shopId);

  @override
  Future<ShopInviteDto> sendShopInvite(
    String shopId, {
    required String contact,
    required String role,
  }) => _api.sendShopInvite(shopId, contact: contact, role: role);

  @override
  Future<void> revokeShopInvite(String shopId, String inviteId) =>
      _api.revokeShopInvite(shopId, inviteId);

  @override
  Future<QrInviteDto> createQrInvite(String shopId) =>
      _api.createQrInvite(shopId);

  @override
  Future<AcceptedInviteDto> acceptInvite(String token) =>
      _api.acceptInvite(token);

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
  Future<ClaimDto> createClaim(
    String shopId,
    List<String> orderIds, {
    String? title,
    List<String>? evidenceIds,
  }) => _api.createClaim(
    shopId,
    orderIds,
    title: title,
    evidenceIds: evidenceIds,
  );

  @override
  Future<List<ClaimDto>> listClaims(String shopId) => _api.listClaims(shopId);

  @override
  Future<ClaimDetailDto> claimDetail(String shopId, String claimId) =>
      _api.claimDetail(shopId, claimId);

  @override
  Future<void> revokeClaim(String shopId, String claimId) =>
      _api.revokeClaim(shopId, claimId);

  @override
  Future<ShopDeletionPreviewDto> shopDeletionPreview(String shopId) =>
      _api.shopDeletionPreview(shopId);

  @override
  Future<void> deleteShop(String shopId, {bool force = false}) =>
      _api.deleteShop(shopId, force: force);

  @override
  Future<StorageStateDto> storage(String shopId) => _api.getStorage(shopId);

  @override
  Future<StorageValidateDto> saveS3Storage(
    String shopId, {
    required String endpoint,
    required String bucket,
    required String accessKeyId,
    required String secretAccessKey,
    String region = 'auto',
    String prefix = 'evidencecam',
  }) => _api.saveS3Storage(
    shopId,
    endpoint: endpoint,
    bucket: bucket,
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region,
    prefix: prefix,
  );

  @override
  Future<StorageValidateDto> testStorage(String shopId) =>
      _api.testStorage(shopId);

  @override
  Future<StorageValidateDto> validateS3Storage(
    String shopId, {
    required String endpoint,
    required String bucket,
    required String accessKeyId,
    required String secretAccessKey,
    String region = 'auto',
    String prefix = 'evidencecam',
  }) => _api.validateS3Storage(
    shopId,
    endpoint: endpoint,
    bucket: bucket,
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region,
    prefix: prefix,
  );

  @override
  Future<void> disconnectStorage(String shopId) => _api.deleteStorage(shopId);

  @override
  Future<void> connectGdriveCode(String shopId, String code) =>
      _api.connectGdriveCode(shopId, code);

  @override
  Future<String> gdriveAuthUrl(String shopId) => _api.gdriveAuthUrl(shopId);

  @override
  Future<void> setStorageActive(String shopId, {required bool active}) =>
      _api.setStorageActive(shopId, active: active);

  @override
  @override
  Future<void> reportQueueDepth(
    String shopId, {
    required int pending,
    int pendingBytes = 0,
    int? oldestAt,
  }) async {
    try {
      await _api.reportQueueDepth(
        shopId,
        pending: pending,
        pendingBytes: pendingBytes,
        oldestAt: oldestAt,
      );
    } on Object {
      // Báo cáo phụ trợ: mất mạng hay 4xx đều không đáng làm hỏng thứ gì khác.
      // Lần đổi hàng đợi kế tiếp sẽ khai lại.
    }
  }

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
  Future<List<OrderCodeDto>> orderCodes(String shopId, String orderId) =>
      _api.orderCodes(shopId, orderId);

  @override
  Future<OrderCodeDto> addOrderCode(
    String shopId,
    String orderId, {
    required String code,
    required String kind,
  }) => _api.addOrderCode(shopId, orderId, code: code, kind: kind);

  @override
  Future<void> removeOrderCode(
    String shopId,
    String orderId,
    String codeId,
  ) => _api.removeOrderCode(shopId, orderId, codeId);

  @override
  Future<List<OrderCodeDto>> lookupOrderCode(String shopId, String code) =>
      _api.lookupOrderCode(shopId, code);

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
  String verifyUrl(String evidenceId) => _api.verifyUrl(evidenceId);

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

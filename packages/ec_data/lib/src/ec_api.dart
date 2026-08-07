import 'dart:convert';
import 'dart:io';

import 'package:network/network.dart' show Dio, Headers, Options, Response;

import 'ec_models.dart';

/// Typed client for the EvidenceCam Workers API. Paths mirror
/// `evidencecam-backend` exactly. The [Dio] passed in carries the auth token
/// (via the network package's `AuthTokenProvider`, Core-4) and the base URL —
/// so this class stays free of auth/config concerns.
///
/// Presentational screens wire to live data by calling the matching method here
/// once the Worker URL is set.
String _avatarContentTypeOf(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.heic')) return 'image/heic';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

class EcApi {
  const EcApi(this._dio);

  final Dio _dio;

  Future<T> _get<T>(
    String path,
    T Function(Map<String, dynamic>) parse, {
    Map<String, dynamic>? query,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: query,
    );
    return parse(res.data!);
  }

  Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic>) parse, {
    Map<String, dynamic>? query,
  }) async {
    final res = await _dio.get<List<dynamic>>(path, queryParameters: query);
    return res.data!.map((e) => parse(e as Map<String, dynamic>)).toList();
  }

  // --- account / quota (FR-15, FR-08) ---
  Future<AccountDto> getMe() => _get('/api/me', AccountDto.fromJson);

  Future<AccountDto> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/me',
      data: {'name': ?name, 'phone': ?phone, 'avatar_url': ?avatarUrl},
    );
    return AccountDto.fromJson(res.data!);
  }

  /// Có [shopId] → backend trả gói của CHỦ shop đó kèm `can_manage_plan=false`
  /// cho quản lý/nhân viên. Không truyền → gói của chính tài khoản đang đăng nhập.
  Future<QuotaDto> getQuota({String? shopId}) => _get(
    shopId == null
        ? '/api/quota'
        : '/api/quota?shop_id=${Uri.encodeQueryComponent(shopId)}',
    QuotaDto.fromJson,
  );

  // --- shops / members (FR-05) ---
  Future<List<ShopDto>> listShops() => _getList('/api/shops', ShopDto.fromJson);

  Future<ShopDto> createShop({
    required String name,
    required String platform,
    String? resolution,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops',
      data: {'name': name, 'platform': platform, 'resolution': ?resolution},
    );
    return ShopDto.fromJson(res.data!);
  }

  Future<ShopDto> updateShop(
    String shopId, {
    String? name,
    String? platform,
    String? resolution,
    int? maxClipSeconds,
    int? maxUploadBytes,
    int? maxImageBytes,
    int? maxVideoBytes,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/shops/$shopId',
      data: {
        'name': ?name,
        'platform': ?platform,
        'resolution': ?resolution,
        'max_clip_seconds': ?maxClipSeconds,
        'max_upload_bytes': ?maxUploadBytes,
        // Trần riêng cho ảnh và cho video. Trước đây chỉ có một trần chung,
        // nhưng ảnh đính kèm nhẹ hơn clip cả bậc — dùng chung một con số thì
        // hoặc ảnh được nới quá tay, hoặc video bị siết oan.
        'max_image_bytes': ?maxImageBytes,
        'max_video_bytes': ?maxVideoBytes,
      },
    );
    return ShopDto.fromJson(res.data!);
  }

  /// Xoá hẳn cửa hàng.
  ///
  /// ponytail: endpoint này backend CHƯA mở — hiện trả 404. Đường REST chuẩn
  /// cho tài nguyên đã có `GET/PATCH /api/shops/:id`, nên khi backend làm thì
  /// gần như chắc chắn là đường này. App bắt lỗi và nói rõ thay vì nuốt.
  Future<void> deleteShop(String shopId) =>
      _dio.delete<void>('/api/shops/$shopId');

  Future<ShopDto> getShop(String shopId) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/shops/$shopId');
    return ShopDto.fromJson(res.data!);
  }

  Future<List<MemberDto>> listMembers(String shopId) =>
      _getList('/api/shops/$shopId/members', MemberDto.fromJson);

  Future<ShopInviteDto> sendShopInvite(
    String shopId, {
    required String contact,
    required String role,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/invites',
      data: {'contact': contact, 'role': role},
    );
    return ShopInviteDto.fromJson(res.data!);
  }

  /// Thu hồi lời mời còn treo — link trong email chết ngay.
  Future<void> revokeShopInvite(String shopId, String inviteId) =>
      _dio.delete<void>('/api/shops/$shopId/invites/$inviteId');

  Future<void> updateMemberRole(
    String shopId, {
    required String accountUid,
    required String role,
  }) => _dio.patch<void>(
    '/api/shops/$shopId/members/$accountUid',
    data: {'role': role},
  );

  Future<void> removeMember(String shopId, String accountUid) =>
      _dio.delete<void>('/api/shops/$shopId/members/$accountUid');

  Future<List<VideoTypeDto>> listVideoTypes(String shopId) =>
      _getList('/api/shops/$shopId/video-types', VideoTypeDto.fromJson);

  Future<VideoTypeDto> addVideoType(
    String shopId,
    String name, {
    String? icon,
    String? color,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/video-types',
      data: {'name': name, 'icon': ?icon, 'color': ?color},
    );
    return VideoTypeDto.fromJson(res.data!);
  }

  /// Bỏ trống [icon]/[color] = giữ nguyên vẻ ngoài đang có (backend không
  /// coi field vắng mặt là lệnh xóa).
  Future<VideoTypeDto> renameVideoType(
    String shopId,
    String typeId,
    String name, {
    String? icon,
    String? color,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/shops/$shopId/video-types/$typeId',
      data: {'name': name, 'icon': ?icon, 'color': ?color},
    );
    return VideoTypeDto.fromJson(res.data!);
  }

  Future<void> deleteVideoType(String shopId, String typeId) =>
      _dio.delete<void>('/api/shops/$shopId/video-types/$typeId');

  // --- orders / search (FR-04, FR-01) ---
  /// Kích thước trang mặc định, khớp `PAGE_SIZE` của Worker. Chỉ dùng làm dự
  /// phòng khi phản hồi thiếu header `X-Page-Size`.
  static const ordersPageSize = 10;

  /// Lists page [page] (1-based) of orders, newest first.
  ///
  /// [uploadState] (`pending` | `error` | `done`), [fromTs] and [videoTypeId]
  /// map onto the backend's `upload_state` / `from` / `video_type_id` query
  /// params. Filtering has to happen server-side: the list is paged, so
  /// filtering only the loaded page would quietly hide matches still on the
  /// next one.
  ///
  /// Thân phản hồi chỉ là mảng đơn; tổng số đơn nằm ở header `X-Total-Count`
  /// (backend giữ nguyên thân mảng cho web admin đang cuộn vô hạn).
  Future<OrderPageDto> listOrders(
    String shopId, {
    int page = 1,
    String? uploadState,
    int? fromTs,
    int? toTs,
    String? videoTypeId,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/shops/$shopId/orders',
      queryParameters: {
        'page': page,
        'upload_state': ?uploadState,
        'from': ?fromTs,
        'to': ?toTs,
        'video_type_id': ?videoTypeId,
      },
    );
    final items = res.data!
        .map((e) => OrderSummaryDto.fromJson(e as Map<String, dynamic>))
        .toList();
    final pageSize = _header(res, 'x-page-size') ?? ordersPageSize;
    return OrderPageDto(
      items: items,
      // Thiếu header (proxy cắt, backend cũ) thì coi trang này là tất cả —
      // thà mất thanh phân trang còn hơn vẽ ra số trang bịa.
      total: _header(res, 'x-total-count') ?? items.length,
      // Backend cũ không gửi header này — cộng tạm trang đang xem còn hơn hiện
      // 0, dù nó chỉ là con số của trang.
      totalVideos:
          _header(res, 'x-total-videos') ??
          items.fold(0, (sum, o) => sum + o.videoCount),
      page: page,
      pageSize: pageSize,
    );
  }

  static int? _header(Response<dynamic> res, String name) =>
      int.tryParse(res.headers.value(name) ?? '');

  Future<List<OrderSummaryDto>> searchOrders(String shopId, String query) =>
      _getList(
        '/api/shops/$shopId/orders',
        OrderSummaryDto.fromJson,
        query: {'q': query},
      );

  Future<OrderDto> findOrCreateOrder(
    String shopId,
    String tracking, {
    int? capturedAt,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders',
      data: {'tracking': tracking, 'capturedAt': ?capturedAt},
    );
    return OrderDto.fromJson(res.data!);
  }

  /// Hồ sơ khiếu nại của đơn, `null` khi chưa ai tạo (backend trả thân `null`
  /// chứ không phải 404, nên phải nhận `dynamic` rồi tự kiểm tra).
  Future<DossierDto?> getDossier(String shopId, String orderId) async {
    final res = await _dio.get<dynamic>(
      '/api/shops/$shopId/orders/$orderId/dossier',
    );
    final body = res.data;
    if (body is! Map<String, dynamic>) return null;
    return DossierDto.fromJson(body);
  }

  /// Trang công khai backend phục vụ ở `/d/<token>` — cùng công thức web admin
  /// dùng, nên hai bên không thể sinh ra hai link khác nhau.
  String dossierShareUrl(String shareToken) =>
      '${_dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '')}/d/$shareToken';

  Future<OrderDetailDto> getOrder(String shopId, String orderId) =>
      _get('/api/shops/$shopId/orders/$orderId', OrderDetailDto.fromJson);

  // --- uploads (FR-03) ---

  /// Mẫu điều kiện thiết bị đi qua hàng đợi dưới dạng chuỗi JSON đã mã hoá; API
  /// gửi lên dưới dạng mảng thật. Chuỗi hỏng thì **bỏ hẳn trường đó** chứ không
  /// làm hỏng cả lần upload — mất mẫu là mất một thứ trang trí, mất clip là mất
  /// bằng chứng.
  static List<dynamic>? _decodeSamples(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is List && decoded.isNotEmpty ? decoded : null;
    } on Object {
      return null;
    }
  }

  /// Trần dung lượng ảnh đại diện backend nhận, khớp giới hạn web công bố.
  static const avatarMaxBytes = 2 * 1000 * 1000;

  /// Tải ảnh đại diện lên và trả về tài khoản đã cập nhật.
  ///
  /// Gửi **raw bytes** lên `PUT /api/me/avatar`, đúng như web: backend tự lưu
  /// R2 rồi trả account có `avatar_url` mới. Không có bước presign nào cả —
  /// `POST /api/account/avatar/presign` mà bản trước gọi không tồn tại, nên
  /// mọi lần đổi ảnh trên app ăn 404 và không bao giờ tới máy chủ.
  Future<AccountDto> uploadAvatar(File file) async {
    final bytes = await file.readAsBytes();
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/me/avatar',
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {Headers.contentLengthHeader: bytes.length},
        contentType: _avatarContentTypeOf(file.path),
      ),
    );
    return AccountDto.fromJson(res.data!);
  }

  Future<PresignDto> presignUpload(
    String shopId,
    String orderId, {
    required String kind,
    required int capturedAt,
    String? videoTypeId,
    String? device,
    int? durationSeconds,
    String? samplesJson,
    String? sha256,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders/$orderId/uploads/presign',
      data: {
        'kind': kind,
        'capturedAt': capturedAt,
        'clientNow': DateTime.now().millisecondsSinceEpoch,
        'videoTypeId': ?videoTypeId,
        'device': ?device,
        'durationSeconds': ?durationSeconds,
        'samples': ?_decodeSamples(samplesJson),
        'sha256': ?sha256,
      },
    );
    return PresignDto.fromJson(res.data!);
  }

  Future<MultipartUploadDto> createMultipartUpload(
    String shopId,
    String orderId, {
    required String kind,
    required int capturedAt,
    String? videoTypeId,
    String? device,
    int? durationSeconds,
    String? samplesJson,
    String? sha256,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders/$orderId/uploads/multipart',
      data: {
        'kind': kind,
        'capturedAt': capturedAt,
        'clientNow': DateTime.now().millisecondsSinceEpoch,
        'videoTypeId': ?videoTypeId,
        'device': ?device,
        'durationSeconds': ?durationSeconds,
        'samples': ?_decodeSamples(samplesJson),
        'sha256': ?sha256,
      },
    );
    return MultipartUploadDto.fromJson(res.data!);
  }

  Future<List<MultipartPartUrlDto>> presignMultipartParts(
    String shopId,
    String orderId,
    String evidenceId, {
    required String uploadId,
    required List<int> partNumbers,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders/$orderId/uploads/$evidenceId/multipart/parts',
      data: {'uploadId': uploadId, 'partNumbers': partNumbers},
    );
    final parts = res.data!['parts'] as List<dynamic>;
    return parts
        .map((e) => MultipartPartUrlDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> completeUpload(
    String shopId,
    String orderId,
    String evidenceId, {
    Duration? receiveTimeout,
    String? sha256,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders/$orderId/uploads/$evidenceId/complete',
      data: {'sha256': ?sha256},
      options: receiveTimeout == null
          ? null
          : Options(receiveTimeout: receiveTimeout),
    );
    return res.data!['status'] as String;
  }

  Future<String> completeMultipartUpload(
    String shopId,
    String orderId,
    String evidenceId, {
    required String uploadId,
    required List<UploadedPartDto> parts,
    Duration? receiveTimeout,
    String? sha256,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders/$orderId/uploads/$evidenceId/multipart/complete',
      data: {
        'uploadId': uploadId,
        'parts': parts.map((p) => p.toJson()).toList(),
        'sha256': ?sha256,
      },
      options: receiveTimeout == null
          ? null
          : Options(receiveTimeout: receiveTimeout),
    );
    return res.data!['status'] as String;
  }

  Future<void> abortMultipartUpload(
    String shopId,
    String orderId,
    String evidenceId, {
    required String uploadId,
  }) => _dio.post<void>(
    '/api/shops/$shopId/orders/$orderId/uploads/$evidenceId/multipart/abort',
    data: {'uploadId': uploadId},
  );

  Future<void> deleteEvidence(
    String shopId,
    String orderId,
    String evidenceId,
  ) => _dio.delete<void>(
    '/api/shops/$shopId/orders/$orderId/evidence/$evidenceId',
  );

  Future<String> exportCsv(String shopId, {int? from, int? to}) async {
    final res = await _dio.get<String>(
      '/api/shops/$shopId/export',
      queryParameters: {
        'from': ?from,
        'to': ?to,
      },
    );
    return res.data!;
  }

  Future<void> deleteAccount({bool force = false, bool dryRun = false}) =>
      _dio.delete<void>(
        '/api/me',
        queryParameters: {'force': force, 'dry_run': dryRun},
      );
}

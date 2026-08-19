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
    bool live = false,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: query,
      options: live ? _liveOptions : null,
    );
    return parse(res.data!);
  }

  /// Buộc đi hỏi máy chủ thay vì lấy bản đã lưu trong bộ đệm.
  ///
  /// Bộ đệm HTTP của app nằm trong RAM và giữ tới bảy ngày (xem
  /// `cacheInterceptor`), nên một lời hỏi lặp lại trong cùng phiên được trả
  /// bằng bản cũ. Với dữ liệu tĩnh thì đó là điều tốt; với thứ ĐANG đổi ngay
  /// lúc người dùng nhìn — trạng thái đóng dấu của clip — thì nó biến vòng hỏi
  /// lại 5 giây một lần thành vòng đọc đi đọc lại đúng một câu trả lời cũ, và
  /// người bán chỉ thấy "đã đóng dấu" sau khi khởi động lại app (lúc đó bộ đệm
  /// trong RAM mất theo tiến trình).
  ///
  /// `no-cache` là hỏi lại có điều kiện, không phải tải lại toàn bộ: còn ETag
  /// thì máy chủ trả 304 và thân phản hồi cũ được dùng lại.
  static final _liveOptions = Options(
    headers: const {'cache-control': 'no-cache'},
  );

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
  /// Khai số clip chưa upload được đang nằm trên máy này.
  ///
  /// Máy chủ KHÔNG tự biết con số này: khi shop vượt hạn mức, lượt upload bị từ
  /// chối ở bước presign, trước khi có hàng nào trong cơ sở dữ liệu. Không khai
  /// thì chủ shop nhìn bảng điều khiển thấy mọi thứ bình thường trong khi hàng
  /// trăm clip đang chất trên điện thoại nhân viên.
  ///
  /// Gửi `pending: 0` khi hàng đợi đã sạch — nếu không cảnh báo bên chủ shop
  /// sẽ không bao giờ tắt.
  Future<void> reportQueueDepth(
    String shopId, {
    required int pending,
    int pendingBytes = 0,
    int? oldestAt,
  }) async {
    await _dio.post<void>(
      '/api/shops/$shopId/queue-depth',
      data: {
        'pending': pending,
        'pending_bytes': pendingBytes,
        'oldest_at': oldestAt,
      },
    );
  }

  Future<QuotaDto> getQuota({String? shopId}) => _get(
    shopId == null
        ? '/api/quota'
        : '/api/quota?shop_id=${Uri.encodeQueryComponent(shopId)}',
    QuotaDto.fromJson,
  );

  /// Báo cáo của một cửa hàng — cùng endpoint web admin dùng.
  ///
  /// `tz_offset` đi kèm vì mốc ngày phải theo đồng hồ NGƯỜI XEM: một clip quay
  /// 8h sáng ở VN là của hôm đó, dù UTC vẫn đang là hôm trước. Dart trả offset
  /// ngược dấu với JS nên phải đổi dấu, không thì cả kỳ lệch đúng một ngày.
  ///
  /// [member] là uid cần soi riêng, hoặc `'me'`. Chỉ chủ shop dùng được — máy
  /// chủ ép nhân viên về chính họ, nên đây là bộ lọc hiển thị chứ KHÔNG phải
  /// cổng quyền.
  Future<ShopStatsDto> getShopStats(
    String shopId, {
    int? days,
    String? from,
    String? to,
    String? member,
  }) {
    final tzOffset = -DateTime.now().timeZoneOffset.inMinutes;
    final query = <String, String>{
      'tz_offset': '$tzOffset',
      'days': ?days?.toString(),
      'from': ?from,
      'to': ?to,
      'member': ?member,
    };
    final qs = query.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return _get('/api/shops/$shopId/stats?$qs', ShopStatsDto.fromJson);
  }

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
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/shops/$shopId',
      data: {
        'name': ?name,
        'platform': ?platform,
        'resolution': ?resolution,
        // Trần thời lượng là thứ DUY NHẤT còn đặt được. Mọi trần dung lượng
        // đã bỏ 2026-08-07 — gói cước tính theo số video.
        'max_clip_seconds': ?maxClipSeconds,
      },
    );
    return ShopDto.fromJson(res.data!);
  }

  /// Xoá hẳn cửa hàng.
  ///
  Future<ShopDto> getShop(String shopId) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/shops/$shopId');
    return ShopDto.fromJson(res.data!);
  }

  /// Gộp nhiều đơn thành một hồ sơ khiếu nại, trả về link công khai.
  ///
  /// Mọi thành viên gọi được: người đứng máy là người phát hiện đơn có vấn đề,
  /// và bắt họ chờ chủ shop mở laptop là đúng lúc bằng chứng còn nóng nhất thì
  /// không ai gửi được cho sàn.
  /// [evidenceIds] là những clip người bán ĐÃ TICK, gộp phẳng cho cả hồ sơ —
  /// id bằng chứng là duy nhất nên máy chủ tự gom về từng đơn. Bỏ trống thì
  /// trang công khai hiện ĐỦ mọi bằng chứng của các đơn, đúng hành vi cũ.
  Future<ClaimDto> createClaim(
    String shopId,
    List<String> orderIds, {
    String? title,
    List<String>? evidenceIds,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/claims',
      data: {
        'order_ids': orderIds,
        'title': ?title,
        'evidence_ids': ?evidenceIds,
      },
    );
    return ClaimDto.fromJson(res.data!);
  }

  Future<List<ClaimDto>> listClaims(String shopId) =>
      _getList('/api/shops/$shopId/claims', ClaimDto.fromJson);

  /// Thu hồi: link chết ngay, dữ liệu còn nguyên. Chủ shop hoặc quản lý.
  /// Khối thông tin của một hồ sơ. KHÔNG mang link từng clip — máy chủ cố ý
  /// không ký, xem [ClaimDetailDto].
  Future<ClaimDetailDto> claimDetail(String shopId, String claimId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/shops/$shopId/claims/$claimId',
    );
    return ClaimDetailDto.fromJson(res.data!);
  }

  Future<void> revokeClaim(String shopId, String claimId) =>
      _dio.delete<void>('/api/shops/$shopId/claims/$claimId');

  /// Xoá cửa hàng này sẽ mất những gì. Đọc thuần — dùng cho màn xác nhận.
  Future<ShopDeletionPreviewDto> shopDeletionPreview(String shopId) => _get(
    '/api/shops/$shopId/deletion-preview',
    ShopDeletionPreviewDto.fromJson,
  );

  /// Xoá HẲN cửa hàng. Không lùi lại được — khác `archive` ở đúng chỗ đó.
  ///
  /// Trả 409 `open_dossiers_exist` khi còn hồ sơ khiếu nại đang mở; gọi lại
  /// với [force] là ép. Chỉ chủ shop.
  Future<void> deleteShop(String shopId, {bool force = false}) =>
      _dio.delete<void>(
        '/api/shops/$shopId',
        queryParameters: force ? const {'force': 'true'} : null,
      );

  Future<List<MemberDto>> listMembers(String shopId) =>
      _getList('/api/shops/$shopId/members', MemberDto.fromJson);

  // --- kho riêng của shop, BYOS (mục 5.1) ---
  //
  // Cùng bộ endpoint web admin dùng. Kho là quyết định của chủ shop nhưng người
  // đứng máy phải ĐỌC được tình trạng: khi kho của khách hỏng, clip đọng ở vùng
  // chờ tạm và người duy nhất thấy điều đó ngay là người đang quay.

  /// Cấu hình kho + bảng tình trạng, một lời gọi.
  /// `storage == null` = shop đang dùng Cloud Zenpack.
  Future<StorageStateDto> getStorage(String shopId) =>
      _get('/api/shops/$shopId/storage', StorageStateDto.fromJson);

  /// Cắm kho S3. Máy chủ chạy vòng PUT→HEAD→GET→DELETE rồi mới lưu, nên
  /// `ok == false` nghĩa là KHÔNG có gì được ghi — hiện nguyên `hint` cho khách.
  ///
  /// Google Drive không đi đường này: nó cắm qua OAuth ([connectGdriveCode]).
  Future<StorageValidateDto> saveS3Storage(
    String shopId, {
    required String endpoint,
    required String bucket,
    required String accessKeyId,
    required String secretAccessKey,
    String region = 'auto',
    String prefix = 'evidencecam',
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/shops/$shopId/storage',
      data: {
        'kind': 's3',
        'config': {
          'endpoint': endpoint,
          'region': region,
          'bucket': bucket,
          'prefix': prefix,
          'accessKeyId': accessKeyId,
          'secretAccessKey': secretAccessKey,
        },
      },
    );
    return StorageValidateDto.fromJson(res.data!);
  }

  /// Chạy lại vòng kiểm tra trên cấu hình đã lưu — dùng sau khi khách vừa sửa
  /// quyền bên phía họ.
  Future<StorageValidateDto> testStorage(String shopId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/storage/test',
    );
    return StorageValidateDto.fromJson(res.data!);
  }

  /// Thôi dùng kho riêng. Video quay TỪ LÚC NÀY về kho hệ thống; video cũ nằm
  /// nguyên trong kho của khách và hệ thống mất đường tới chúng.
  Future<void> deleteStorage(String shopId) =>
      _dio.delete<void>('/api/shops/$shopId/storage');

  /// URL trang cấp quyền Google Drive, mở bằng trình duyệt.
  ///
  /// Đường này dùng cặp client của dự án `zenpack` — cặp đã có sẵn trên máy
  /// chủ. Nó là lối đi khi `gdrive_native` bằng false, tức khi máy chủ chưa có
  /// cặp client cùng dự án với client iOS để đổi mã native.
  Future<String> gdriveAuthUrl(String shopId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/shops/$shopId/storage/gdrive/auth-url',
    );
    return (res.data!['url'] as String?) ?? '';
  }

  /// Cắm Drive bằng mã uỷ quyền lấy từ hộp thoại Google của hệ điều hành.
  ///
  /// Chỉ gửi MÃ, không gửi token: máy chủ vẫn là nơi duy nhất đổi nó lấy refresh
  /// token. Ném khi máy chủ chưa cấu hình cặp client cho đường này
  /// (`native_not_configured`) — không còn đường lùi nào, bên gọi báo hỏng.
  Future<void> connectGdriveCode(String shopId, String code) => _dio.post<void>(
    '/api/shops/$shopId/storage/gdrive/code',
    data: {'code': code},
  );

  Future<void> addMember(
    String shopId, {
    required String accountUid,
    required String role,
  }) => _dio.post<void>(
    '/api/shops/$shopId/members',
    data: {'account_uid': accountUid, 'role': role},
  );

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

  /// Tạo mã QR mời. Dùng một lần, sống 10 phút — xem `createQrInvite` ở backend.
  Future<QrInviteDto> createQrInvite(String shopId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/invites/qr',
    );
    return QrInviteDto.fromJson(res.data!);
  }

  /// Nhận lời mời bằng token trong link email hoặc trong mã QR.
  ///
  /// Token CHÍNH LÀ bằng chứng sở hữu hộp thư, nên tài khoản đang đăng nhập
  /// vào được shop kể cả khi email của nó khác địa chỉ được mời. Gọi lại lần
  /// nữa vẫn trả 200 (`newly_joined: false`).
  ///
  /// KHÔNG nằm dưới `/api/shops/:id`: người quét chưa ở trong shop nào, nên
  /// route theo shop sẽ 403 đúng người đang cố vào.
  Future<AcceptedInviteDto> acceptInvite(String token) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/invites/$token/accept',
    );
    return AcceptedInviteDto.fromJson(res.data!);
  }

  /// Thu hồi lời mời còn treo — link trong email chết ngay.
  Future<void> revokeShopInvite(String shopId, String inviteId) =>
      _dio.delete<void>('/api/shops/$shopId/invites/$inviteId');

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
    // Cũng hỏi thẳng máy chủ như chi tiết đơn: danh sách này là chỗ người bán
    // kéo xuống để xem clip vừa quay đã lên chưa. Trả bản trong bộ đệm là biến
    // cử chỉ làm mới thành một cái không làm gì.
    final res = await _dio.get<List<dynamic>>(
      '/api/shops/$shopId/orders',
      queryParameters: {
        'page': page,
        'upload_state': ?uploadState,
        'from': ?fromTs,
        'to': ?toTs,
        'video_type_id': ?videoTypeId,
      },
      options: _liveOptions,
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

  /// Mọi mã đang gắn vào một đơn — mã chính đứng đầu, mã gắn thêm theo thứ tự
  /// thời gian.
  Future<List<OrderCodeDto>> orderCodes(String shopId, String orderId) =>
      _getList(
        '/api/shops/$shopId/orders/$orderId/codes',
        OrderCodeDto.fromJson,
      );

  /// Gắn thêm một mã vào đơn đang mở.
  ///
  /// Idempotent: gắn lại đúng mã đã có trên đơn này trả về bản ghi cũ — quét hai
  /// lần ở bàn đóng gói là chuyện thường. Mã đang thuộc đơn KHÁC thì máy chủ trả
  /// 409 chứ không lặng lẽ chuyển chủ: gộp nhầm hai kiện là hỏng bằng chứng của
  /// cả hai.
  Future<OrderCodeDto> addOrderCode(
    String shopId,
    String orderId, {
    required String code,
    required String kind,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders/$orderId/codes',
      data: {'code': code, 'kind': kind},
    );
    return OrderCodeDto.fromJson(res.data!);
  }

  /// Gỡ một mã khỏi đơn. Mã chính không gỡ được — máy chủ từ chối.
  Future<void> removeOrderCode(
    String shopId,
    String orderId,
    String codeId,
  ) => _dio.delete<void>(
    '/api/shops/$shopId/orders/$orderId/codes/$codeId',
  );

  /// Tra một mã KHỚP TUYỆT ĐỐI trong cửa hàng — đường của máy quét.
  ///
  /// Khác `searchOrders` (tìm gần đúng, cho người gõ tay): quét ra một chuỗi thì
  /// hoặc nó đúng là mã của một đơn, hoặc không phải. Tìm gần đúng ở đây sẽ trả
  /// về đơn khác và người dùng gắn clip vào nhầm kiện.
  Future<List<OrderCodeDto>> lookupOrderCode(String shopId, String code) =>
      _getList(
        '/api/shops/$shopId/order-codes',
        OrderCodeDto.fromJson,
        query: {'code': code},
      );

  Future<OrderDto> findOrCreateOrder(
    String shopId,
    String tracking, {
    int? capturedAt,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/orders',
      // `source` khai một lần ở đây cho MỌI đường tạo đơn của app — quét, gõ
      // tay, hay ghi bù. Máy chủ chỉ ghi lúc tạo mới, nên quét lại một đơn do
      // web tạo không biến nó thành `mobile`. App không hiện lại trường này:
      // ở đây đơn nào cũng `mobile`, cột đó chỉ có nghĩa trên console web.
      data: {
        'tracking': tracking,
        'capturedAt': ?capturedAt,
        'source': 'mobile',
      },
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

  /// Trang kiểm chứng công khai của một clip. Không cần đăng nhập — cả điểm của
  /// nó là người ngoài (nhân viên sàn) mở được, và họ đi tiếp sang công cụ của
  /// bên thứ ba từ đó.
  String verifyUrl(String evidenceId) =>
      '${_dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '')}/seal/verify/$evidenceId';

  /// Chi tiết đơn — luôn hỏi thẳng máy chủ.
  ///
  /// Đây là màn duy nhất theo dõi một thứ đang đổi trong lúc người dùng nhìn:
  /// clip vừa quay đi từ "đang tải lên" sang "đang đóng dấu" rồi "đã tải lên",
  /// và màn hỏi lại 5 giây một lần để bắt lúc đổi. Lấy bản trong bộ đệm là hỏi
  /// lại cho có.
  Future<OrderDetailDto> getOrder(String shopId, String orderId) => _get(
    '/api/shops/$shopId/orders/$orderId',
    OrderDetailDto.fromJson,
    live: true,
  );

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
  static const int avatarMaxBytes = 2 * 1000 * 1000;

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

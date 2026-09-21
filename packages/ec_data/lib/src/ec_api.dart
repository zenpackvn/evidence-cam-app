import 'dart:convert';
import 'dart:io';

import 'package:network/network.dart' show Dio, DioException, Options, Response;

import 'ec_auth.dart';
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
  if (lower.endsWith('.webp')) return 'image/webp';
  // KHÔNG khai `image/heic`: máy chủ chỉ nhận jpeg/png/webp và trả 400
  // `unsupported_image_type`. Khai một kiểu máy chủ từ chối là tự hứa một thứ
  // không có thật; rơi về jpeg thì ít nhất phần lớn ảnh iOS đi lọt, vì bước
  // thu nhỏ lúc chọn đã chuyển chúng sang JPEG.
  return 'image/jpeg';
}

class EcApi implements EcAuthMailApi {
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

  /// [timezone] có ba trạng thái, không phải hai: bỏ qua = không đụng tới,
  /// chuỗi rỗng = bỏ chọn và đọc giờ theo máy, tên vùng = dùng vùng đó. Truyền
  /// `null` là "không đụng tới", nên KHÔNG dùng nó để bỏ chọn được.
  Future<AccountDto> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? theme,
    String? timezone,
    Map<String, Object?>? hoaDon,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/me',
      data: {
        'name': ?name,
        'phone': ?phone,
        'avatar_url': ?avatarUrl,
        'theme': ?theme,
        'timezone': ?timezone,
        // Gửi cả cụm: sáu ô hợp thành MỘT hồ sơ, và máy chủ kiểm chúng cùng
        // nhau (công ty phải có mã số thuế). Gửi lẻ từng ô là để nó thấy một
        // trạng thái nửa vời chưa bao giờ tồn tại trên màn.
        ...?hoaDon,
      },
    );
    return AccountDto.fromJson(res.data!);
  }

  /// Khai máy này nhận thông báo đẩy.
  ///
  /// Gọi sau khi người dùng đã ĐỒNG Ý cho phép, và gọi lại mỗi lần token đổi
  /// (cài lại app, khôi phục máy, Google xoay vòng). Gửi lại token cũ là vô hại.
  Future<void> dangKyMayNhanThongBao(String token, String platform) async {
    await _dio.post<Map<String, dynamic>>(
      '/api/me/devices',
      data: {'token': token, 'platform': platform},
    );
  }

  /// Thôi nhận trên máy này. Gọi lúc đăng xuất — nếu không, người đăng nhập sau
  /// trên cùng máy vẫn nhận thông báo của người trước cho tới khi token đổi.
  Future<void> goMayNhanThongBao(String token) async {
    await _dio.delete<Map<String, dynamic>>(
      '/api/me/devices',
      data: {'token': token},
    );
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
    Map<String, Object?>? caiDatQuay,
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
        // Gửi cả cụm, không tách từng trường: bên gọi đã cầm nguyên bộ cài đặt
        // và chỉ đổi một ô, nên gửi cả cụm là một lượt ghi nguyên vẹn thay vì
        // 12 tham số mà quên một là mất một cài đặt.
        ...?caiDatQuay,
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

  /// Thử một cấu hình S3 mà KHÔNG lưu gì.
  ///
  /// Dò quyền bên nhà cung cấp thường mất vài lượt, và mỗi lượt thử không được
  /// phép thay cái kho đang chạy. Máy chủ có endpoint riêng cho việc này chính
  /// vì `PUT /storage` là kiểm-rồi-lưu nguyên khối, không tách ra được ở client.
  Future<StorageValidateDto> validateS3Storage(
    String shopId, {
    required String endpoint,
    required String bucket,
    required String accessKeyId,
    required String secretAccessKey,
    String region = 'auto',
    String prefix = 'evidencecam',
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/shops/$shopId/storage/validate',
      data: {
        'kind': 's3',
        'config': {
          'endpoint': endpoint,
          'bucket': bucket,
          'accessKeyId': accessKeyId,
          'secretAccessKey': secretAccessKey,
          'region': region,
          'prefix': prefix,
        },
      },
    );
    return StorageValidateDto.fromJson(res.data!);
  }

  /// Thôi dùng kho riêng. Video quay TỪ LÚC NÀY về kho hệ thống; video cũ nằm
  /// nguyên trong kho của khách và hệ thống mất đường tới chúng.

  /// Bật/tắt kho riêng mà KHÔNG xoá cấu hình.
  ///
  /// Đây là "chọn kho khác": shop về kho hệ thống, tài khoản đã cắm nằm yên.
  /// Xoá hẳn là [deleteStorage] — hai việc khác nhau, đừng gộp.
  /// [kind] là loại kho muốn BẬT. Shop giữ được tài khoản của cả S3 lẫn Drive,
  /// nên khi bật phải nói rõ bật cái nào — bỏ trống thì máy chủ bật lại cái vừa
  /// dùng gần nhất, có thể chính là cái người dùng vừa bỏ chọn. Không có nghĩa
  /// khi tắt: tắt là tắt hết, shop về kho hệ thống.
  Future<void> setStorageActive(
    String shopId, {
    required bool active,
    StorageKind? kind,
  }) => _dio.patch<void>(
    '/api/shops/$shopId/storage/active',
    data: {
      'active': active,
      if (active && kind != null && kind != StorageKind.system)
        'kind': kind.name,
    },
  );

  /// [kind] là loại kho cần gỡ. Bỏ trống thì máy chủ gỡ kho đang dùng — tài
  /// khoản của loại kia nằm nguyên, đó là điểm của việc tách theo loại.
  Future<void> deleteStorage(String shopId, {StorageKind? kind}) =>
      _dio.delete<void>(
        '/api/shops/$shopId/storage',
        queryParameters: {
          if (kind != null && kind != StorageKind.system) 'kind': kind.name,
        },
      );

  /// Mail xác minh địa chỉ, do MÁY CHỦ MÌNH gửi.
  ///
  /// Firebase đã khoá phần thân của mẫu xác thực trong Console, nên để nó gửi là
  /// gửi chữ mẫu của Google — và người dùng app sẽ nhận một lá thư khác hẳn thứ
  /// người dùng web nhận. Tuyến này lấy link từ chính Firebase rồi bọc vào mẫu
  /// đã duyệt của ZenPack.
  ///
  /// Địa chỉ lấy từ token, không gửi lên: nhận từ thân request là cho người ta
  /// tự chọn nạn nhân.
  @override
  Future<void> sendVerifyEmail() => _dio.post<void>('/api/auth/verify-email');

  /// Mail đặt lại mật khẩu. KHÔNG cần đăng nhập.
  ///
  /// Máy chủ luôn trả `{sent:true}` kể cả khi địa chỉ chưa có tài khoản — trả
  /// lời khác nhau sẽ biến tuyến công khai này thành máy dò xem ai có tài khoản.
  @override
  Future<void> sendPasswordReset(String email) =>
      _dio.post<void>('/auth/password-reset', data: {'email': email});

  /// Link ĐĂNG NHẬP bằng Google để mở trong WebView của chính app, hoặc `null`
  /// khi máy chủ chưa cấu hình đường này.
  ///
  /// Cùng khuôn với [gdriveAuthUrl] — mở trang của Google trong app, chặn lượt
  /// chuyển hướng cuối để lấy kết quả — nhưng là một luồng RIÊNG: khác
  /// `redirect_uri`, khác scope, và trả về một vé đăng nhập chứ không cắm kho
  /// nào cả. Không lời gọi nào ở đây chạm vào Drive.
  ///
  /// `null` (máy chủ trả 503) là câu trả lời QUAN TRỌNG: bên gọi phải giữ
  /// nguyên hộp thoại Google gốc thay vì mở một WebView chắc chắn hỏng. Nhờ nó,
  /// bản app này cài lên một máy chủ chưa deploy tuyến kia vẫn chạy y như cũ.
  Future<String?> googleLoginUrl() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/auth/google/url',
      options: Options(validateStatus: (code) => code == 200 || code == 503),
    );
    if (res.statusCode == 503) return null;
    return res.data!['url']! as String;
  }

  /// Xin mã OTP về số điện thoại, qua Zalo ZNS hoặc SMS brandname.
  ///
  /// `channel` là `'zalo'` hoặc `'sms'`. Máy chủ trả lời NHƯ NHAU dù số đã có
  /// tài khoản hay chưa — nên không đọc gì từ đây để đoán ra điều đó.
  ///
  /// Ném [EcOtpException] mang mã lỗi của máy chủ để màn hình nói đúng câu:
  /// `too_soon` (vừa gửi), `rate_limited` (quá nhiều), `invalid_phone`,
  /// `send_failed` (Zalo/SMS không nhận), `not_configured` (máy chủ thiếu cấu
  /// hình). Gộp hết thành một câu "có lỗi" là bắt người dùng đoán.
  Future<void> phoneOtpStart(String phone, String channel) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/auth/phone/start',
        data: {'phone': phone, 'channel': channel},
      );
    } on DioException catch (e) {
      throw EcOtpException(_maLoiOtp(e));
    }
  }

  /// Mã đúng → custom token của Firebase.
  ///
  /// Số chưa có tài khoản thì tài khoản được tạo ngay tại máy chủ, nên bên gọi
  /// không cần phân biệt đăng nhập với đăng ký.
  Future<String> phoneOtpVerify(String phone, String code) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/phone/verify',
        data: {'phone': phone, 'code': code},
      );
      return res.data!['token']! as String;
    } on DioException catch (e) {
      throw EcOtpException(_maLoiOtp(e));
    }
  }

  /// Mã lỗi trong thân trả về, hoặc `khong_ro` khi không đọc được.
  static String _maLoiOtp(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is String) return data['error'] as String;
    return 'khong_ro';
  }

  /// Vé từ lượt chuyển hướng cuối → custom token của Firebase.
  ///
  /// POST chứ không GET, và vé nằm trong THÂN: vé không được rơi vào lịch sử
  /// WebView hay log truy cập. Hạn của nó là 2 phút, nên gọi ngay khi WebView
  /// đóng chứ đừng giữ lại.
  Future<String> googleLoginSession(String ticket) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/google/session',
      data: {'ticket': ticket},
    );
    return res.data!['token']! as String;
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

  /// Link cấp quyền Drive để mở trong WebView của chính app.
  ///
  /// Đường thứ hai, dùng khi máy chủ chưa có cặp `GOOGLE_APP_*` cho đường hộp
  /// thoại gốc ([connectGdriveCode] trả `native_not_configured`). Nó dùng cặp
  /// client của luồng trình duyệt — cặp ĐÃ cấu hình sẵn trên prod — nên chạy
  /// được ngay mà không phải đặt thêm secret nào.
  ///
  /// Mở link này TRONG APP, không đẩy sang trình duyệt ngoài: rời app rồi bắt
  /// người dùng tự quay về là chỗ luồng cũ đã gãy. Cắm xong Google chuyển
  /// hướng về `/oauth/gdrive/callback`, máy chủ đổi mã rồi 302 tiếp về một URL
  /// mang `gdrive=ok` — đó là tín hiệu để đóng WebView.
  Future<String> gdriveAuthUrl(String shopId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/shops/$shopId/storage/gdrive/auth-url',
    );
    return res.data!['url']! as String;
  }

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
  /// Gửi thẳng `Uint8List`, KHÔNG bọc trong `Stream`.
  ///
  /// `Stream.fromIterable` chỉ nghe được MỘT lần. `RetryInterceptor` thử lại
  /// bằng chính `RequestOptions` cũ, nên lượt thử thứ hai đọc lại một luồng đã
  /// tiêu thụ và chết với `Bad state: Stream has already been listened to` —
  /// tức một lỗi mạng tạm thời (429/5xx) biến thành lỗi vĩnh viễn, và ảnh đại
  /// diện kẹt lại trên máy thay vì lên tài khoản.
  ///
  /// Dio dựng lại luồng gửi từ `Uint8List` ở MỖI lượt fetch, và tự đặt
  /// `Content-Length` — nên không cần khai tay header đó nữa.
  Future<AccountDto> uploadAvatar(File file) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/me/avatar',
      data: await file.readAsBytes(),
      options: Options(contentType: _avatarContentTypeOf(file.path)),
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

/// Lỗi của luồng OTP, mang MÃ máy chủ trả về thay vì một câu đã dịch sẵn.
///
/// Giữ mã chứ không giữ câu: câu phải dịch theo ngôn ngữ đang chọn, mà tầng dữ
/// liệu không biết ngôn ngữ — nó là việc của màn hình.
class EcOtpException implements Exception {
  const EcOtpException(this.ma);

  final String ma;

  @override
  String toString() => 'EcOtpException($ma)';
}

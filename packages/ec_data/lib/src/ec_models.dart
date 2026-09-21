/// DTOs for the EvidenceCam Workers API (`evidencecam-backend`). Hand-written
/// `fromJson` (no codegen) — the field names mirror the D1 schema / service
/// responses exactly. Kept separate from the presentational screen models so
/// the API surface can evolve independently.
library;

/// Trần thời lượng clip, giây — bản sao của `kFixedClipSeconds`
/// (shared_contracts/clip_budget.dart). Lặp lại ở đây vì `ec_data` cố ý không
/// phụ thuộc `shared_contracts`; đổi một chỗ thì đổi cả hai.
const _kFixedClipSeconds = 300;

int _int(Object? v, [int fallback = 0]) => (v as num?)?.toInt() ?? fallback;
int? _intN(Object? v) => (v as num?)?.toInt();

class AccountDto {
  const AccountDto({
    required this.uid,
    this.email,
    this.name,
    this.phone,
    this.avatarUrl,
    this.theme = 'system',
    this.timezone,
    this.invoiceKind = 'company',
    this.invoiceName,
    this.invoiceTaxCode,
    this.invoiceAddress,
    this.invoiceEmail,
    this.invoiceNote,
    this.entitlement,
  });

  factory AccountDto.fromJson(Map<String, dynamic> j) => AccountDto(
    uid: j['uid'] as String,
    email: j['email'] as String?,
    name: j['name'] as String?,
    phone: j['phone'] as String?,
    avatarUrl: j['avatar_url'] as String?,
    theme: (j['theme'] as String?) ?? 'system',
    timezone: j['timezone'] as String?,
    invoiceKind: (j['invoice_kind'] as String?) ?? 'company',
    invoiceName: j['invoice_name'] as String?,
    invoiceTaxCode: j['invoice_tax_code'] as String?,
    invoiceAddress: j['invoice_address'] as String?,
    invoiceEmail: j['invoice_email'] as String?,
    invoiceNote: j['invoice_note'] as String?,
    entitlement: j['entitlement'] is Map<String, dynamic>
        ? EntitlementDto.fromJson(j['entitlement'] as Map<String, dynamic>)
        : null,
  );

  final String uid;
  final String? email;
  final String? name;
  final String? phone;
  final String? avatarUrl;

  /// Giao diện sáng/tối: `'system'` | `'light'` | `'dark'`.
  ///
  /// Ở MÁY CHỦ chứ không ở máy: đổi trên điện thoại thì mở web cũng thấy giao
  /// diện đó. Bản cũ của web nhớ trong cookie nên mỗi máy một kiểu.
  final String theme;

  /// Tên vùng IANA để ĐỌC giờ trên màn hình. `null` = theo máy.
  ///
  /// Chỉ đổi giờ hiển thị. Mốc cắt ngày của báo cáo và giờ ghi trong thư vẫn
  /// theo giờ Việt Nam.
  final String? timezone;

  /// Thông tin xuất hoá đơn, ở TÀI KHOẢN chứ không ở cửa hàng: hoá đơn xuất
  /// cho người TRẢ TIỀN, mà gói cước tính theo tài khoản.
  ///
  /// 'company' = Công ty / Hộ kinh doanh, 'individual' = Cá nhân.
  final String invoiceKind;
  final String? invoiceName;
  final String? invoiceTaxCode;
  final String? invoiceAddress;
  final String? invoiceEmail;
  final String? invoiceNote;

  /// Quyền dùng đang có hiệu lực, do backend tổng hợp từ mọi đường thanh toán.
  /// `null` khi backend chưa trả trường này.
  final EntitlementDto? entitlement;
}

/// Quyền dùng của tài khoản, đọc từ `GET /api/me`.
///
/// Web hỏi đúng chỗ này để biết một lượt thanh toán đã được ghi nhận chưa
/// (`#/pay/:plan` poll 5 giây một lần), nên app dùng cùng nguồn.
class EntitlementDto {
  const EntitlementDto({
    required this.planCode,
    this.status,
    this.currentPeriodEnd,
  });

  factory EntitlementDto.fromJson(Map<String, dynamic> j) => EntitlementDto(
    planCode: (j['plan_code'] as String?) ?? 'free',
    status: j['status'] as String?,
    currentPeriodEnd: _intN(j['current_period_end']),
  );

  final String planCode;

  /// `active` · `trialing` · `expired` …
  final String? status;

  /// Gói có hiệu lực tới lúc nào, epoch ms. `null` ở gói miễn phí và khi
  /// backend không trả trường này.
  ///
  /// Đây là thứ DUY NHẤT đổi khi người dùng gia hạn đúng gói đang dùng — mã
  /// gói thì không. Chờ mã gói đổi là lượt gia hạn nào cũng hết giờ rồi báo
  /// "đang xử lý", đọc ra như thất bại và mời họ trả tiền lần nữa.
  final int? currentPeriodEnd;

  /// Chuỗi đại diện một trạng thái quyền dùng, để so trước/sau khi thanh toán.
  ///
  /// Gộp cả ba trường vì mỗi lượt mua chỉ đổi một số trong đó: nâng gói đổi
  /// [planCode], gia hạn đổi [currentPeriodEnd], kích hoạt lại đổi [status].
  /// Backend không trả [currentPeriodEnd] thì chuỗi này rơi về đúng phép so
  /// theo mã gói như trước — không tốt hơn, nhưng cũng không tệ hơn.
  String get signature => '$planCode|$status|$currentPeriodEnd';
}

class ShopDto {
  const ShopDto({
    required this.id,
    required this.name,
    required this.platform,
    required this.resolution,
    required this.role,
    this.ownerName,
    this.ownerEmail,
    this.clipSeconds = _kFixedClipSeconds,
    this.planMaxClipSeconds = _kFixedClipSeconds,
    this.caiDatQuayJson = const {},
  });

  factory ShopDto.fromJson(Map<String, dynamic> j) => ShopDto(
    id: j['id'] as String,
    name: j['name'] as String,
    platform: j['platform'] as String,
    resolution: (j['resolution'] as String?) ?? '720p',
    role: (j['role'] as String?) ?? 'owner',
    ownerName: j['owner_name'] as String?,
    ownerEmail: j['owner_email'] as String?,
    clipSeconds: _int(j['effective_clip_seconds'], _kFixedClipSeconds),
    planMaxClipSeconds: _int(j['plan_max_clip_seconds'], _kFixedClipSeconds),
    caiDatQuayJson: j,
  );

  final String id;
  final String name;
  final String platform;
  final String resolution;

  /// Cài đặt quay của CỬA HÀNG này, ở dạng THÔ như máy chủ trả về.
  ///
  /// Không dựng thành `EcCaiDatQuay` ngay ở đây: kiểu đó nằm ở
  /// `shared_contracts`, mà `ec_data` cố ý không phụ thuộc gói ấy — cùng lý do
  /// đã khiến `_kFixedClipSeconds` phải chép lại ở trên. Tầng app dựng kiểu từ
  /// map này (xem `EcCaiDatQuay.fromJson`).
  final Map<String, dynamic> caiDatQuayJson;

  /// owner | manager | staff
  final String role;

  /// Tên chủ cửa hàng, chỉ có ở `GET /shops/:id`.
  ///
  /// Đây là đường DUY NHẤT để nhân viên biết mình đang làm cho ai: danh sách
  /// thành viên chỉ chủ shop gọi được. `null` khi máy chủ chưa trả trường này
  /// hoặc chủ shop chưa đặt tên.
  final String? ownerName;

  /// Email chủ cửa hàng, cùng phạm vi với [ownerName]. Đường liên lạc khi kho
  /// hỏng giữa ca — một cái tên thì không gọi được cho ai.
  final String? ownerEmail;

  /// Ngân sách clip (FR-17/FR-18). Backend đã kẹp [clipSeconds] vào khoảng
  /// [1 phút, 5 phút], nên app dùng thẳng.
  ///
  /// Các trường dung lượng (`max_image_bytes`, `max_video_bytes`,
  /// `effective_upload_bytes`) và `recommended_clip_seconds` đã bỏ 2026-08-07 —
  /// backend không còn gửi, gói cước tính theo số video.
  final int clipSeconds;
  final int planMaxClipSeconds;
}

class MemberDto {
  const MemberDto({
    required this.role,
    this.accountUid,
    this.name,
    this.email,
    this.status = 'active',
    this.inviteContact,
    this.inviteId,
    this.inviteStatus,
  });

  /// `account_uid` phải NHẬN NULL.
  ///
  /// Ép `as String` ở đây từng làm chết cả danh sách chỉ vì một dòng: `.map()`
  /// ném ra ngoài, màn chi tiết cửa hàng mất sạch thành viên — kể cả dòng chủ
  /// shop hoàn toàn bình thường, nên nhìn ra y như mất quyền sở hữu. Hàng
  /// `pending` (đã mời, chưa đăng ký) chính là trường hợp không có uid.
  factory MemberDto.fromJson(Map<String, dynamic> j) => MemberDto(
    role: j['role'] as String,
    accountUid: j['account_uid'] as String?,
    name: j['name'] as String?,
    email: j['email'] as String?,
    status: (j['status'] as String?) ?? 'active',
    inviteContact: j['invite_contact'] as String?,
    inviteId: j['invite_id'] as String?,
    inviteStatus: j['invite_status'] as String?,
  );

  /// `null` ở hàng `status == 'pending'` — lời mời chưa khớp tài khoản nào,
  /// nên chưa có uid. Backend cố tình trả những hàng này để người mời thấy
  /// đã mời ai.
  final String? accountUid;
  final String role;
  final String? name;
  final String? email;

  /// `active` = đã trong shop; `pending` = mới có lời mời.
  final String status;

  /// Email/SĐT đã được mời. Chỉ có ở hàng `pending`.
  final String? inviteContact;

  /// Chỉ có ở hàng `pending`: id để gọi `DELETE /shops/:id/invites/:inviteId`.
  /// Hàng pending không có uid nên đây là khóa duy nhất định danh được nó.
  final String? inviteId;

  /// `sent` = đã gửi mail, chưa ai nhận · `accepted` = đã nhận · `null` = không
  /// qua lời mời nào (chủ shop, hoặc người được thêm thẳng).
  final String? inviteStatus;
}

/// Kết quả nhận một lời mời: shop vừa vào, cùng vai trò được cấp.
class AcceptedInviteDto {
  const AcceptedInviteDto({
    required this.shopId,
    required this.shopName,
    required this.role,
    required this.newlyJoined,
  });

  factory AcceptedInviteDto.fromJson(Map<String, dynamic> j) =>
      AcceptedInviteDto(
        shopId: j['shop_id'] as String,
        shopName: j['shop_name'] as String,
        role: j['role'] as String,
        newlyJoined: j['newly_joined'] as bool? ?? false,
      );

  final String shopId;
  final String shopName;
  final String role;

  /// `false` khi lời mời đã được nhận từ trước — bấm lại link cũ không phải
  /// lỗi, chỉ là không có gì mới.
  final bool newlyJoined;
}

class ShopInviteDto {
  const ShopInviteDto({
    required this.id,
    required this.shopId,
    required this.contact,
    required this.role,
    required this.status,
    required this.inviteToken,
  });

  factory ShopInviteDto.fromJson(Map<String, dynamic> j) => ShopInviteDto(
    id: j['id'] as String,
    shopId: j['shop_id'] as String,
    contact: j['contact'] as String,
    role: j['role'] as String,
    status: j['status'] as String,
    inviteToken: j['invite_token'] as String,
  );

  final String id;
  final String shopId;
  final String contact;
  final String role;
  final String status;
  final String inviteToken;
}

/// Lời mời KHÔNG có người nhận, để vẽ thành mã QR.
///
/// Khác [ShopInviteDto] ở chỗ nó chưa mời ai: không có `contact`, và cũng
/// không có email nào được gửi đi. Ai quét mã trước thì người đó vào shop —
/// nên nó dùng một lần và sống 10 phút, không phải 14 ngày.
class QrInviteDto {
  const QrInviteDto({
    required this.inviteId,
    required this.token,
    required this.url,
    required this.expiresAt,
  });

  factory QrInviteDto.fromJson(Map<String, dynamic> j) => QrInviteDto(
    inviteId: j['invite_id'] as String,
    token: j['token'] as String,
    url: j['url'] as String,
    expiresAt: _int(j['expires_at']),
  );

  final String inviteId;
  final String token;

  /// Chuỗi đem đi vẽ mã. Cùng dạng link với email mời, nên camera hệ thống
  /// quét cũng ra (mở web) — không bắt người kia phải mở app mới quét được.
  final String url;
  final int expiresAt;
}

class OrderDto {
  const OrderDto({
    required this.id,
    required this.tracking,
    required this.createdAt,
  });

  factory OrderDto.fromJson(Map<String, dynamic> j) => OrderDto(
    id: j['id'] as String,
    tracking: j['tracking_raw'] as String,
    createdAt: _int(j['created_at']),
  );

  final String id;
  final String tracking;
  final int createdAt;
}

/// Một mã gắn vào vận đơn.
///
/// Một kiện hàng thường mang nhiều mã: mã vận đơn sàn cấp lúc gửi, rồi mã trả
/// hàng khi khách hoàn. Không gắn chúng vào cùng một đơn thì clip trả hàng đẻ ra
/// một đơn thứ hai, và bằng chứng của cùng một kiện bị chẻ đôi — đúng lúc cần
/// gộp lại để gửi sàn.
class OrderCodeDto {
  const OrderCodeDto({
    required this.id,
    required this.orderId,
    required this.kind,
    required this.raw,
    required this.isPrimary,
  });

  factory OrderCodeDto.fromJson(Map<String, dynamic> j) => OrderCodeDto(
    id: j['id'] as String,
    orderId: j['order_id'] as String,
    kind: j['kind'] as String,
    raw: j['raw'] as String,
    isPrimary: _int(j['is_primary']) == 1,
  );

  final String id;
  final String orderId;

  /// `shipping` = mã vận đơn · `return` = mã trả hàng do sàn cấp.
  final String kind;

  /// Mã như người dùng quét, giữ nguyên hoa-thường.
  final String raw;

  /// Mã chính của đơn. Backend không cho gỡ mã chính, nên UI cũng không được
  /// mời người dùng thử.
  final bool isPrimary;
}

class OrderSummaryDto {
  const OrderSummaryDto({
    required this.id,
    required this.tracking,
    required this.createdAt,
    required this.evidenceCount,
    int? videoCount,
    this.lastCapturedAt,
    this.latestType,
    this.errorCount = 0,
    this.pendingCount = 0,
    this.latestThumbUrl,
  }) : videoCount = videoCount ?? evidenceCount;

  factory OrderSummaryDto.fromJson(Map<String, dynamic> j) => OrderSummaryDto(
    id: j['id'] as String,
    tracking: j['tracking_raw'] as String,
    createdAt: _int(j['created_at']),
    evidenceCount: _int(j['evidence_count']),
    // Backend cũ chưa có trường này — rơi về `evidence_count` để bản app mới
    // chạy được với server chưa deploy, dù con số vẫn đếm rộng như trước.
    videoCount: _intN(j['video_count']),
    lastCapturedAt: _intN(j['last_captured_at']),
    latestType: j['latest_type'] as String?,
    errorCount: _int(j['error_count']),
    pendingCount: _int(j['pending_count']),
    latestThumbUrl: j['latest_thumb_url'] as String?,
  );

  final String id;
  final String tracking;
  final int createdAt;

  /// Mọi bản ghi bằng chứng từng có của đơn — kể cả ảnh, clip hỏng và clip đã
  /// xoá. Dùng để biết đơn còn dữ liệu gì không, KHÔNG dùng làm số video.
  final int evidenceCount;

  /// Video còn tồn tại — con số "N video" hiện trên dòng. Nhỏ hơn
  /// [evidenceCount] khi đơn có ảnh đính kèm, clip upload hỏng, hết hạn lưu
  /// trữ hoặc đã bị xoá.
  final int videoCount;
  final int? lastCapturedAt;
  final String? latestType;
  final int errorCount;
  final int pendingCount;

  /// Presigned GET của poster clip mới nhất — ảnh overview cho mỗi dòng ở
  /// F2-01 (technical-spec: danh sách chỉ tải thumbnail, byte video để dành
  /// cho lúc bấm Xem). `null` khi đơn chưa có clip nào lên xong, hoặc khi
  /// backend chưa trả trường `latest_thumb_url`.
  final String? latestThumbUrl;
}

/// Một trang của danh sách vận đơn (F2-01). [total] là tổng số đơn khớp bộ
/// lọc, không phải số đơn trong trang — thanh phân trang cần nó để biết có
/// bao nhiêu trang và hiện "1–10 / 128".
class OrderPageDto {
  const OrderPageDto({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    this.totalVideos = 0,
  });

  final List<OrderSummaryDto> items;
  final int total;

  /// Tổng video của **mọi** đơn khớp bộ lọc, không riêng trang này — thẻ
  /// "Video đã quay" phải lấy từ đây. Cộng `videoCount` của các dòng đang hiện
  /// chỉ ra con số của một trang (tối đa 10 đơn), không phải của cả shop.
  final int totalVideos;

  /// 1-based, đúng trang vừa yêu cầu.
  final int page;
  final int pageSize;

  int get pageCount => total <= 0 ? 1 : (total + pageSize - 1) ~/ pageSize;

  /// Số thứ tự (1-based) của đơn đầu/cuối trang này, cho nhãn "1–10 / 128".
  int get firstIndex => items.isEmpty ? 0 : (page - 1) * pageSize + 1;
  int get lastIndex => items.isEmpty ? 0 : firstIndex + items.length - 1;
}

/// FR-07: hồ sơ khiếu nại chia sẻ được của một đơn. App chỉ **đọc** — link
/// được tạo/thu hồi ở web admin, nên ở đây không có method tạo.
class DossierDto {
  const DossierDto({
    required this.id,
    required this.orderId,
    required this.shareToken,
    required this.revoked,
  });

  factory DossierDto.fromJson(Map<String, dynamic> j) => DossierDto(
    id: j['id'] as String,
    orderId: j['order_id'] as String,
    shareToken: j['share_token'] as String,
    revoked: _int(j['revoked']) == 1,
  );

  final String id;
  final String orderId;
  final String shareToken;

  /// Link đã bị thu hồi thì token vẫn còn trong DB nhưng trang công khai trả
  /// 410 — đừng đưa cho người dùng đi chia sẻ.
  final bool revoked;
}

class EvidenceDto {
  const EvidenceDto({
    required this.id,
    required this.kind,
    required this.capturedAt,
    required this.uploadStatus,
    this.videoTypeId,
    this.createdByUid,
    this.recordedBy,
    this.device,
    this.r2Key,
    this.thumbUrl,
    this.sha256,
    this.url,
    this.shareUrl,
    this.storageKind,
    this.relayStatus,
    this.retentionExpiresAt,
    this.durationSeconds,
    this.clockSkewMs,
    this.sealStatus,
    this.sealedAt,
    this.displaySha256,
    this.timeCheck,
    this.otsStatus,
    this.otsBlockHeight,
    this.keyId,
  });

  factory EvidenceDto.fromJson(Map<String, dynamic> j) => EvidenceDto(
    id: j['id'] as String,
    kind: j['kind'] as String,
    capturedAt: _int(j['captured_at']),
    uploadStatus: j['upload_status'] as String,
    videoTypeId: j['video_type_id'] as String?,
    createdByUid: j['created_by_uid'] as String?,
    recordedBy: j['recorded_by'] as String?,
    device: j['device'] as String?,
    r2Key: j['r2_key'] as String?,
    url: j['url'] as String?,
    shareUrl: j['share_url'] as String?,
    storageKind: j['storage_kind'] as String?,
    relayStatus: j['relay_status'] as String?,
    thumbUrl: j['thumb_url'] as String?,
    sha256: j['sha256'] as String?,
    retentionExpiresAt: _intN(j['retention_expires_at']),
    durationSeconds: _intN(j['duration_seconds']),
    clockSkewMs: _intN(j['clock_skew_ms']),
    sealStatus: j['seal_status'] as String?,
    sealedAt: _intN(j['sealed_at']),
    displaySha256: j['display_sha256'] as String?,
    timeCheck: j['time_check'] as String?,
    otsStatus: j['ots_status'] as String?,
    otsBlockHeight: _intN(j['ots_block_height']),
    keyId: j['key_id'] as String?,
  );

  final String id;
  final String kind;
  final int capturedAt;
  final String uploadStatus;
  final String? videoTypeId;
  final String? createdByUid;

  /// Tên người quay, do máy chủ tra sẵn từ tài khoản.
  ///
  /// `null` khi tài khoản chưa đặt tên. Trước đây app tự đổi `createdByUid`
  /// sang tên bằng danh sách thành viên — mà tuyến đó chỉ chủ shop gọi được,
  /// nên với nhân viên mọi clip đều hiện "Không rõ".
  final String? recordedBy;
  final String? device;

  /// When this evidence's R2 object is swept by the retention cron
  /// (`retention.ts`), or when it's next eligible if not yet swept. Null while
  /// retention hasn't been computed for it yet.
  final int? retentionExpiresAt;
  final String? r2Key;
  final String? url;

  /// Trang tệp trên Google Drive của shop, để NGƯỜI ĐỌC mở.
  ///
  /// Khác [url] — thứ trình phát dùng. `null` với kho hệ thống và kho S3.
  final String? shareUrl;

  /// Kho đang GIỮ clip này: `gdrive`, `s3`, hoặc `null` = Cloud ZenPack.
  ///
  /// `null` cũng đúng với clip của shop cắm kho riêng nhưng CHƯA đẩy sang được
  /// — lúc đó byte vẫn nằm ở vùng chờ của ZenPack, và nói "Google Drive" là
  /// nói sai về chỗ bằng chứng đang nằm.
  final String? storageKind;

  /// Chặng đẩy clip sang kho riêng của shop: `pending` · `relayed` · `failed`,
  /// hoặc `null` khi shop không cắm kho riêng.
  ///
  /// Cần đọc CÙNG [storageKind] mới ra câu đúng: máy chủ chỉ ghi [storageKind]
  /// sau khi đẩy xong, nên một clip đang trên đường sang kho riêng có
  /// `storageKind == null` y hệt một clip của shop dùng kho hệ thống — hai
  /// chuyện khác hẳn nhau.
  final String? relayStatus;

  /// Poster frame for this clip — a few dozen KB, so a timeline can show every
  /// entry without pulling a single video byte. Null for photos (their own
  /// preview), for expired evidence, and when frame extraction failed.
  final String? thumbUrl;

  /// SHA-256 (lowercase hex) of the uploaded bytes, computed on the recording
  /// phone and recorded once at upload time. Re-hashing the stored object and
  /// getting this value back proves it has not been altered since.
  final String? sha256;

  /// Recorded clip length in seconds; null for photos and older evidence
  /// captured before this field existed.
  final int? durationSeconds;

  /// How far the recording phone's clock was from server time when this
  /// evidence was uploaded (positive = phone ahead), in ms. Null for evidence
  /// uploaded by a client that predates the measurement.
  ///
  /// [capturedAt] is a phone-clock reading, so it is only as trustworthy as
  /// this number is small — see [hasUntrustedClock].
  final int? clockSkewMs;

  /// True when the phone's clock was off by more than [kClockSkewToleranceMs],
  /// i.e. [capturedAt] should not be presented as the authoritative packing
  /// time without a caveat.
  ///
  /// Derived, never stored: the tolerance is a policy that can change, and a
  /// persisted flag would freeze old rows at whatever it used to be.
  bool get hasUntrustedClock =>
      clockSkewMs != null && clockSkewMs!.abs() > kClockSkewToleranceMs;

  /// Where this clip is in the sealing chain: `pending`, `rendering`, `sealed`,
  /// `hash_mismatch`, `render_failed` — or null for clips recorded before
  /// sealing existed, which will never carry a stamp.
  final String? sealStatus;

  /// When the manifest was signed. This is the "Thời gian ký" the detail sheet
  /// shows; it is a server clock reading, unlike [capturedAt].
  final int? sealedAt;

  /// SHA-256 of the stamped copy — the one actually stored. Differs from
  /// [sha256], which fingerprints the raw bytes this phone uploaded.
  final String? displaySha256;

  /// `TIME_OK` or `TIME_DRIFT`.
  final String? timeCheck;

  /// How far the clip's proof has got into a public timestamp ledger:
  /// `none`, `pending` (calendar took it, Bitcoin has not sealed a block yet —
  /// hours), or `confirmed`. Only `confirmed` may be shown as anchored: the
  /// third-party verification page reports the same three states, and claiming
  /// more than it does is the one way this feature loses in front of a reviewer.
  final String? otsStatus;

  /// Khoá đã ký hồ sơ niêm phong (`k1`, `k2`…). `null` = chưa có hồ sơ ký.
  /// Chỉ mã khoá — chữ ký và vân tay ở trang Kiểm chứng, không ở app.
  final String? keyId;

  /// Block number the proof landed in. Only set once [otsStatus] is
  /// `confirmed` — it is the number a seller can read back to a marketplace.
  final int? otsBlockHeight;

  /// The stored object is still the raw upload — the renderer has not written
  /// the stamped copy over it yet.
  ///
  /// While this is true the server withholds [url] on purpose, so that nobody
  /// walks away with a file that looks like evidence but carries no timestamp.
  /// Only the two in-flight states count: a null [sealStatus] means the clip
  /// predates sealing and is never going to change, and the two failure states
  /// still have to play — that file is the user's only copy.
  bool get isSealing => sealStatus == 'pending' || sealStatus == 'rendering';

  /// Clip đã niêm phong xong và ĐANG được đẩy sang kho riêng của shop.
  ///
  /// Chặng này nằm SAU chặng nung dấu và là chặng cuối đổi dữ liệu của một
  /// clip: `storage_kind`, `object_ref` và `share_url` chỉ có mặt khi nó xong.
  /// Màn nào bám theo `isSealing` để nạp lại mà bỏ qua nó thì dừng hỏi đúng
  /// một nhịp trước khi những trường kia xuất hiện.
  bool get isMovingToOwnStorage => relayStatus == 'pending';
}

/// Device-clock error we treat as normal drift rather than a wrong clock.
///
/// 2 minutes: comfortably above the seconds of round-trip and NTP jitter a
/// healthy phone shows, far below the timezone- or date-sized mistakes that
/// actually misdate evidence.
const int kClockSkewToleranceMs = 2 * 60 * 1000;

class OrderDetailDto {
  const OrderDetailDto({
    required this.order,
    required this.evidence,
    this.shopStorageKind,
  });

  factory OrderDetailDto.fromJson(Map<String, dynamic> j) => OrderDetailDto(
    order: OrderDto.fromJson(j['order'] as Map<String, dynamic>),
    evidence: (j['evidence'] as List)
        .map((e) => EvidenceDto.fromJson(e as Map<String, dynamic>))
        .toList(),
    shopStorageKind: j['shop_storage_kind'] as String?,
  );

  final OrderDto order;
  final List<EvidenceDto> evidence;

  /// Kho riêng shop ĐANG CHỌN: `s3` · `gdrive` · `null` (kho hệ thống).
  ///
  /// Khác [EvidenceDto.storageKind] của từng clip: cột kia chỉ có giá trị SAU
  /// khi clip đã sang kho riêng, nên trước đó màn hình không có gì để gọi tên
  /// kho ngoài "Cloud ZenPack" — sai với người vừa chọn kho riêng.
  ///
  /// `null` cũng là câu trả lời của một máy chủ CŨ chưa gửi trường này; bên gọi
  /// giữ nguyên cách cũ khi thiếu nó.
  final String? shopStorageKind;
}

/// Một dòng của bảng "Dung lượng theo loại".
/// Số video đã quay theo từng loại. Chỉ còn ĐẾM — cột dung lượng đã bỏ
/// 2026-08-07 cùng lượt với quota theo byte.
class QuotaTypeUsageDto {
  const QuotaTypeUsageDto({required this.type, required this.videoCount});

  factory QuotaTypeUsageDto.fromJson(Map<String, dynamic> j) =>
      QuotaTypeUsageDto(
        type: (j['type'] as String?) ?? (j['name'] as String?) ?? '',
        videoCount: _int(j['video_count']),
      );

  final String type;
  final int videoCount;
}

/// Mốc cảnh báo hạn mức video. `blocked` = đã vượt 110%, không quay mới được.
///
/// Tên phải khớp `QuotaWarnLevel` của backend TỪNG CHỮ:
/// `'w90' | 'w100' | 'blocked'`. Bản trước đọc `w80`/`w95` — hai mốc máy chủ
/// chưa bao giờ gửi — nên `w90` rơi vào nhánh mặc định và thành `none`. Không
/// có gì đổ, không có cảnh báo nào: mốc 90% chỉ lặng lẽ không tồn tại. Console
/// web đọc đúng ba tên này, nên app là bên duy nhất lệch.
enum QuotaWarnLevel { none, w90, w100, blocked }

/// Giá trị lạ về `none` chứ không ném: máy chủ thêm một mốc mới không được
/// phép làm màn gói cước của người dùng trắng xoá. Đổi lại, `ec_api_test` chốt
/// đủ ba tên thật, nên lệch hợp đồng thì đỏ ở CI chứ không im lặng ngoài đời.
QuotaWarnLevel _warnLevel(Object? raw) => switch (raw) {
  'w90' => QuotaWarnLevel.w90,
  'w100' => QuotaWarnLevel.w100,
  'blocked' => QuotaWarnLevel.blocked,
  _ => QuotaWarnLevel.none,
};

/// Mức dùng của gói — trục là SỐ VIDEO trong tháng dương lịch (giờ VN).
///
/// Trước 2026-08-07 lớp này đọc `used_bytes`/`cap_bytes` (thanh dung lượng) và
/// `video_count`/`by_type` — hai trường sau backend CHƯA BAO GIỜ gửi, nên màn
/// Gói cước luôn hiện 0 video. Nay đọc đúng những trường backend thật sự trả,
/// và mọi trần dung lượng đã bị gỡ khỏi trục tính tiền.
class QuotaDto {
  const QuotaDto({
    required this.planCode,
    required this.usedVideos,
    required this.capVideos,
    required this.remainingVideos,
    this.topupVideos = 0,
    this.blockAtVideos = 0,
    this.blocked = false,
    this.warnLevel = QuotaWarnLevel.none,
    this.retentionDays = 30,
    this.canManagePlan = true,
    this.byType = const [],
  });

  factory QuotaDto.fromJson(Map<String, dynamic> j) => QuotaDto(
    planCode: (j['plan_code'] as String?) ?? 'free',
    usedVideos: _int(j['used_videos']),
    capVideos: _int(j['cap_videos']),
    remainingVideos: _int(j['remaining_videos']),
    topupVideos: _int(j['topup_videos']),
    blockAtVideos: _int(j['block_at_videos']),
    blocked: (j['blocked'] as bool?) ?? false,
    warnLevel: _warnLevel(j['warn_level']),
    retentionDays: _intN(j['retention_days']) ?? 30,
    canManagePlan: (j['can_manage_plan'] as bool?) ?? true,
    byType: [
      for (final e in (j['by_type'] as List<dynamic>? ?? const []))
        QuotaTypeUsageDto.fromJson(e as Map<String, dynamic>),
    ],
  );

  /// Lượt mua thêm còn lại — trả trước, không mất theo tháng.
  final int topupVideos;

  /// Mốc bị chặn quay mới = trần gói × 1,1 + lượt mua thêm.
  final int blockAtVideos;

  /// Đã vượt mốc chặn. Video ĐÃ QUAY vẫn tra cứu và gửi cho sàn bình thường —
  /// chặn chỉ áp cho việc quay mới.
  final bool blocked;
  final QuotaWarnLevel warnLevel;

  /// Bảng chia theo loại video, do backend tính trên TOÀN BỘ clip của shop.
  /// Rỗng thì màn Gói cước lùi về đếm trên hàng đợi của riêng máy này.
  final List<QuotaTypeUsageDto> byType;

  final String planCode;

  /// Video đã tính vào gói trong tháng này, và trần của gói. Đếm lại từ đầu
  /// mỗi tháng, không cộng dồn.
  final int usedVideos;
  final int capVideos;
  final int remainingVideos;
  final int retentionDays;

  /// Chỉ chủ shop mới đổi được gói — gói cước gắn với tài khoản trả tiền.
  /// Nhân viên xem được gói đang chi phối ca làm nhưng không mua.
  final bool canManagePlan;
}

class PresignDto {
  const PresignDto({
    required this.evidenceId,
    required this.key,
    required this.uploadUrl,
    this.thumbUploadUrl,
  });

  factory PresignDto.fromJson(Map<String, dynamic> j) => PresignDto(
    evidenceId: j['evidenceId'] as String,
    key: j['key'] as String,
    uploadUrl: j['uploadUrl'] as String,
    thumbUploadUrl: j['thumbUploadUrl'] as String?,
  );

  final String evidenceId;
  final String key;
  final String uploadUrl;

  /// Where to PUT the poster frame extracted from this clip. Null for photos
  /// (their own preview) and for a backend that predates posters.
  final String? thumbUploadUrl;
}

class MultipartUploadDto {
  const MultipartUploadDto({
    required this.evidenceId,
    required this.key,
    required this.uploadId,
    this.thumbUploadUrl,
  });

  factory MultipartUploadDto.fromJson(Map<String, dynamic> j) =>
      MultipartUploadDto(
        evidenceId: j['evidenceId'] as String,
        key: j['key'] as String,
        uploadId: j['uploadId'] as String,
        thumbUploadUrl: j['thumbUploadUrl'] as String?,
      );

  final String evidenceId;
  final String key;
  final String uploadId;

  /// See [PresignDto.thumbUploadUrl] — a poster is small enough to never need
  /// multipart, so it is a plain PUT even on this path.
  final String? thumbUploadUrl;
}

class MultipartPartUrlDto {
  const MultipartPartUrlDto({
    required this.partNumber,
    required this.uploadUrl,
  });

  factory MultipartPartUrlDto.fromJson(Map<String, dynamic> j) =>
      MultipartPartUrlDto(
        partNumber: _int(j['partNumber']),
        uploadUrl: j['uploadUrl'] as String,
      );

  final int partNumber;
  final String uploadUrl;
}

class UploadedPartDto {
  const UploadedPartDto({required this.partNumber, required this.etag});

  Map<String, dynamic> toJson() => {'partNumber': partNumber, 'etag': etag};

  final int partNumber;
  final String etag;
}

class VideoTypeDto {
  const VideoTypeDto({
    required this.id,
    required this.name,
    required this.isDefault,
    this.icon,
    this.color,
  });

  factory VideoTypeDto.fromJson(Map<String, dynamic> j) => VideoTypeDto(
    id: j['id'] as String,
    name: j['name'] as String,
    isDefault: _int(j['is_default']) == 1,
    icon: j['icon'] as String?,
    color: j['color'] as String?,
  );

  final String id;
  final String name;
  final bool isDefault;

  /// Khóa icon người tạo chọn. `null` với 3 loại mặc định và với loại tạo
  /// trước khi màn chọn icon được nối dây — client rơi về icon mặc định.
  final String? icon;

  /// `#RRGGBB` người tạo chọn; `null` = dùng màu mặc định.
  final String? color;
}

// ── Kho riêng của shop (BYOS, mục 5.1) ───────────────────────────────────────

/// Loại kho shop đang dùng. Không có cấu hình = [system].
enum StorageKind { system, s3, gdrive }

/// Cam kết nào hứa được với kho đang cắm.
///
/// Nguồn sự thật là máy chủ, không phải trí nhớ: mỗi nhà cung cấp thiếu một
/// thứ khác nhau (Drive không ký được URL, vài nơi không có object lock), và
/// hứa nhầm một cam kết chuỗi bằng chứng thì hỏng đúng lúc cần nhất.
class StorageCapabilitiesDto {
  const StorageCapabilitiesDto({
    required this.presignedDownload,
    required this.objectLock,
  });

  factory StorageCapabilitiesDto.fromJson(Map<String, dynamic> j) =>
      StorageCapabilitiesDto(
        presignedDownload: (j['presignedDownload'] as bool?) ?? false,
        objectLock: (j['objectLock'] as bool?) ?? false,
      );

  /// False (Google Drive) = video phải đi vòng qua máy chủ, chậm hơn hẳn.
  final bool presignedDownload;

  /// Cơ sở DUY NHẤT để hứa "bằng chứng không thể xoá". Đừng hứa khi false.
  final bool objectLock;
}

/// Kho đang cắm, đã che secret. Máy chủ KHÔNG bao giờ trả khoá bí mật.
class StorageViewDto {
  const StorageViewDto({
    required this.kind,
    required this.ok,
    this.label = '',
    this.email,
    this.lastError,
    this.lastCheckedAt,
    this.capabilities,
    this.s3,
  });

  factory StorageViewDto.fromJson(Map<String, dynamic> j) {
    final config = j['config'];
    return StorageViewDto(
      kind: (j['kind'] as String?) == 'gdrive'
          ? StorageKind.gdrive
          : StorageKind.s3,
      ok: (j['status'] as String?) != 'error',
      label: config is Map<String, dynamic> ? _storageLabel(config) : '',
      email: config is Map<String, dynamic> ? config['email'] as String? : null,
      lastError: j['last_error'] as String?,
      lastCheckedAt: _intN(j['last_checked_at']),
      s3: config is Map<String, dynamic> && (j['kind'] as String?) != 'gdrive'
          ? S3ConfigViewDto.fromJson(config)
          : null,
      capabilities: j['capabilities'] is Map<String, dynamic>
          ? StorageCapabilitiesDto.fromJson(
              j['capabilities'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final StorageKind kind;
  final bool ok;

  /// Dòng nhận diện kho, đọc được bằng mắt: `bucket/prefix` với S3, tên thư
  /// mục với Drive. Đủ để chủ shop biết mình đang cắm đúng chỗ hay không.
  final String label;

  /// Tài khoản Google đang giữ kho Drive. `null` với S3 — chỉ Drive mới có
  /// khái niệm "cắm bằng tài khoản nào".
  final String? email;
  final String? lastError;
  final int? lastCheckedAt;
  final StorageCapabilitiesDto? capabilities;

  /// Cấu hình S3 đã che bí mật, `null` khi kho không phải S3.
  final S3ConfigViewDto? s3;
}

String _storageLabel(Map<String, dynamic> config) {
  final bucket = config['bucket'] as String?;
  if (bucket != null && bucket.isNotEmpty) {
    final prefix = config['prefix'] as String?;
    return prefix == null || prefix.isEmpty ? bucket : '$bucket/$prefix';
  }
  return (config['folderName'] as String?) ??
      (config['folderId'] as String?) ??
      '';
}

/// Bảng tình trạng kho (mục 5.3).
class StorageHealthDto {
  const StorageHealthDto({
    this.total = 0,
    this.intact = 0,
    this.unreachable = 0,
    this.mismatched = 0,
    this.unchecked = 0,
    this.pendingRelay = 0,
    this.lastCheckedAt,
  });

  factory StorageHealthDto.fromJson(Map<String, dynamic> j) => StorageHealthDto(
    total: _int(j['total']),
    intact: _int(j['intact']),
    unreachable: _int(j['unreachable']),
    mismatched: _int(j['mismatched']),
    unchecked: _int(j['unchecked']),
    pendingRelay: _int(j['pending_relay']),
    lastCheckedAt: _intN(j['last_checked_at']),
  );

  final int total;
  final int intact;

  /// Không mở được ở kho của shop — bằng chứng coi như đã mất tới khi khách sửa.
  final int unreachable;

  /// Sai lệch so với hồ sơ niêm phong: tệp đã bị sửa sau khi hệ thống nhận.
  final int mismatched;
  final int unchecked;

  /// Còn nằm ở vùng chờ tạm vì kho đang có sự cố. Chưa mất, nhưng chưa về nhà.
  final int pendingRelay;
  final int? lastCheckedAt;

  /// Có gì cần chủ shop xử lý ngay không.
  bool get hasProblems => unreachable > 0 || mismatched > 0 || pendingRelay > 0;
}

class StorageStateDto {
  const StorageStateDto({
    this.storage,
    this.storages = const [],
    this.health = const StorageHealthDto(),
    this.storageActive = true,
    this.byosAllowed = false,
    this.gdriveNative = false,
  });

  factory StorageStateDto.fromJson(Map<String, dynamic> j) => StorageStateDto(
    storage: j['storage'] is Map<String, dynamic>
        ? StorageViewDto.fromJson(j['storage'] as Map<String, dynamic>)
        : null,
    storages: [
      if (j['storages'] case final List<dynamic> raw)
        for (final item in raw)
          if (item is Map<String, dynamic>) StorageViewDto.fromJson(item),
    ],
    health: j['health'] is Map<String, dynamic>
        ? StorageHealthDto.fromJson(j['health'] as Map<String, dynamic>)
        : const StorageHealthDto(),
    // Mặc định TRUE: backend cũ không có cờ này, và ở đó hễ có `storage` là kho
    // đang được dùng. Đoán "false" sẽ làm mọi shop đang chạy kho riêng đột ngột
    // hiện thành Cloud Zenpack.
    storageActive: (j['storage_active'] as bool?) ?? true,
    byosAllowed: (j['byos_allowed'] as bool?) ?? false,
    // Mặc định FALSE khi máy chủ chưa trả trường này: bản backend cũ không có
    // cặp client native, nên đoán "có" là đẩy người dùng vào đúng cái ngõ cụt
    // mà cờ này sinh ra để tránh.
    gdriveNative: (j['gdrive_native'] as bool?) ?? false,
  );

  /// Null = đang dùng Cloud Zenpack (mặc định).
  final StorageViewDto? storage;

  /// MỌI kho shop đang giữ cấu hình, kể cả cái đang tắt — một phần tử mỗi loại.
  ///
  /// Rỗng với bản máy chủ cũ chưa trả trường này; lúc đó [storage] một mình là
  /// tất cả những gì biết được, và màn hình rơi về đúng hành vi trước đây.
  final List<StorageViewDto> storages;
  final StorageHealthDto health;

  /// Kho riêng có ĐANG được dùng không. `storage != null` mà cờ này `false` =
  /// đã chọn kho khác nhưng chưa đăng xuất.
  final bool storageActive;

  /// Gói hiện tại có được cắm kho riêng không. Ẩn nút theo cờ NÀY, đừng tự suy
  /// từ mã gói ở client — quy tắc phân gói chỉ sống ở một chỗ.
  final bool byosAllowed;

  /// Máy chủ có đổi được `serverAuthCode` từ hộp thoại Google của điện thoại
  /// không.
  ///
  /// False = phải đi luồng trình duyệt. Biết TRƯỚC khi hiện bất cứ màn Google
  /// nào mới có nghĩa: phát hiện sau khi người dùng đã cấp quyền xong thì lần
  /// cấp quyền thứ hai ở trình duyệt là hỏi lại đúng câu họ vừa đồng ý.
  final bool gdriveNative;

  /// Kho ĐANG dùng. Thôi dùng kho riêng thì về hệ thống, dù cấu hình còn đó.
  StorageKind get kind => storageActive
      ? (storage?.kind ?? StorageKind.system)
      : StorageKind.system;

  /// Loại kho đã cắm — dùng để chọn chữ cho hộp thoại gỡ kho, vì gỡ một tài
  /// khoản Google và gỡ một cái bucket S3 là hai câu khác nhau.
  StorageKind? get configuredKind => storage?.kind;

  /// MỌI loại kho shop đang giữ cấu hình.
  ///
  /// Rơi về [configuredKind] khi máy chủ chưa trả `storages` — bản cũ chỉ giữ
  /// được một cấu hình nên tập hợp đó cũng chỉ có một phần tử, và màn hình vẽ ra
  /// đúng như trước.
  Set<StorageKind> get configuredKinds => storages.isEmpty
      ? {?configuredKind}
      : {for (final view in storages) view.kind};

  /// Cấu hình của MỘT loại kho, kể cả khi shop đang dùng loại khác.
  ///
  /// Đọc tài khoản Drive từ [storage] là đọc đúng một nửa sự thật: [storage] là
  /// kho ĐANG DÙNG, nên shop chạy S3 mà vẫn giữ tài khoản Drive thì nó là hàng
  /// S3 và `email` ở đó luôn null — trong khi tài khoản Google vẫn còn nguyên
  /// trong cơ sở dữ liệu, và [storages] đang mang nó.
  StorageViewDto? viewFor(StorageKind kind) {
    for (final view in storages) {
      if (view.kind == kind) return view;
    }
    // Backend cũ chưa trả `storages`, và ở đó một shop chỉ giữ được một cấu
    // hình — [storage] một mình là tất cả những gì biết được.
    return storage?.kind == kind ? storage : null;
  }
}

/// Cấu hình S3 máy chủ trả về — đã che bí mật.
///
/// Bốn trường đầu về nguyên vẹn nên điền lại được vào form. Khoá thì không:
/// `accessKeyId` chỉ còn bốn ký tự cuối và `secretAccessKey` không bao giờ rời
/// máy chủ. Nên sửa cấu hình vẫn phải dán lại cặp khoá — điền sẵn một chuỗi đã
/// bị che vào ô rồi gửi đi là gửi rác.
class S3ConfigViewDto {
  const S3ConfigViewDto({
    this.endpoint = '',
    this.region = '',
    this.bucket = '',
    this.prefix = '',
    this.accessKeyIdMasked = '',
  });

  factory S3ConfigViewDto.fromJson(Map<String, dynamic> j) => S3ConfigViewDto(
    endpoint: (j['endpoint'] as String?) ?? '',
    region: (j['region'] as String?) ?? '',
    bucket: (j['bucket'] as String?) ?? '',
    prefix: (j['prefix'] as String?) ?? '',
    accessKeyIdMasked: (j['accessKeyId'] as String?) ?? '',
  );

  final String endpoint;
  final String region;
  final String bucket;
  final String prefix;

  /// Dạng `…abcd` — đủ để khách nhận ra đã dán khoá nào, không đủ để dùng.
  final String accessKeyIdMasked;
}

/// Kết quả vòng kiểm tra PUT→HEAD→GET→DELETE.
/// Một bước trong vòng thử kho: PUT → HEAD → GET → DELETE.
///
/// [detail] là câu lỗi NGUYÊN VĂN nhà cung cấp trả về (`AccessDenied`,
/// `NoSuchBucket`, `SignatureDoesNotMatch`…). Đây là thứ duy nhất nói đúng
/// chuyện gì đã xảy ra, nên nó phải đi tới tận mắt người đang điền form — họ là
/// người có quyền sửa IAM bên phía họ, không phải mình.
class StorageProbeStepDto {
  const StorageProbeStepDto({
    required this.step,
    required this.ok,
    this.detail,
  });

  factory StorageProbeStepDto.fromJson(Map<String, dynamic> j) =>
      StorageProbeStepDto(
        step: (j['step'] as String?) ?? '',
        ok: (j['ok'] as bool?) ?? false,
        detail: j['detail'] as String?,
      );

  /// `put` | `head` | `get` | `delete`.
  final String step;
  final bool ok;
  final String? detail;
}

class StorageValidateDto {
  const StorageValidateDto({
    required this.ok,
    this.hint,
    this.failedStep,
    this.steps = const [],
  });

  factory StorageValidateDto.fromJson(Map<String, dynamic> j) {
    final raw = j['steps'];
    final steps = <StorageProbeStepDto>[
      if (raw is List)
        for (final s in raw)
          if (s is Map<String, dynamic>) StorageProbeStepDto.fromJson(s),
    ];
    return StorageValidateDto(
      ok: (j['ok'] as bool?) ?? false,
      hint: j['hint'] as String?,
      failedStep: steps.where((s) => !s.ok).firstOrNull?.step,
      steps: steps,
    );
  }

  /// False nghĩa là máy chủ CHƯA lưu gì cả.
  final bool ok;

  /// Thiếu quyền gì, sửa thế nào. Hiện nguyên văn — đây là câu duy nhất giúp
  /// khách tự sửa được cấu hình IAM bên phía họ.
  final String? hint;

  /// Bước đầu tiên hỏng (`put`/`head`/`get`/`delete`), để chỉ đúng quyền thiếu.
  final String? failedStep;

  /// CẢ vòng thử, kể cả những bước xanh.
  ///
  /// Giữ nguyên chứ không rút gọn còn mỗi bước hỏng đầu tiên: "PUT xanh, GET
  /// đỏ" và "PUT đỏ" là hai vấn đề khác hẳn nhau — cái đầu là thiếu quyền đọc,
  /// cái sau là sai khoá hoặc sai tên bucket — và bản trước gộp cả hai thành
  /// một câu duy nhất không nói gì.
  final List<StorageProbeStepDto> steps;
}

/// Số hiện trên màn xác nhận xoá cửa hàng.
///
/// Xoá cửa hàng là thao tác duy nhất trong sản phẩm không lùi lại được, nên
/// màn xác nhận phải nói bằng số thật — "bạn chắc chứ?" thì ai cũng bấm qua.
class ShopDeletionPreviewDto {
  const ShopDeletionPreviewDto({
    this.orders = 0,
    this.videos = 0,
    this.photos = 0,
    this.members = 0,
    this.openDossiers = 0,
    this.bytes = 0,
  });

  factory ShopDeletionPreviewDto.fromJson(Map<String, dynamic> j) =>
      ShopDeletionPreviewDto(
        orders: _int(j['orders']),
        videos: _int(j['videos']),
        photos: _int(j['photos']),
        members: _int(j['members']),
        openDossiers: _int(j['open_dossiers']),
        bytes: _int(j['bytes']),
      );

  final int orders;
  final int videos;
  final int photos;
  final int members;

  /// > 0 thì máy chủ trả 409 trừ khi ép — link của chúng đã ở chỗ nhân viên sàn.
  final int openDossiers;
  final int bytes;
}

/// Hồ sơ khiếu nại gộp nhiều đơn, theo bản của máy chủ.
/// Một mã vận đơn trong hồ sơ, kèm mốc tạo đơn để xếp theo thời gian.
class ClaimOrderRefDto {
  const ClaimOrderRefDto({
    required this.orderId,
    required this.tracking,
    required this.createdAt,
  });

  factory ClaimOrderRefDto.fromJson(Map<String, dynamic> j) => ClaimOrderRefDto(
    orderId: (j['order_id'] as String?) ?? '',
    tracking: (j['tracking_raw'] as String?) ?? '',
    createdAt: _int(j['created_at']),
  );

  final String orderId;
  final String tracking;
  final int createdAt;
}

/// Hồ sơ nhìn từ phía người quản lý: MỘT KHỐI THÔNG TIN, không phải thư viện
/// video.
///
/// Máy chủ cố ý không ký link cho từng clip ở tuyến này (services/claims.ts) —
/// muốn xem video thì vào chi tiết đơn. Nên DTO này cũng chỉ mang thứ khối
/// thông tin cần: mã vận đơn, cửa hàng, sàn, ngày tháng, và số đếm bằng chứng.
class ClaimDetailDto {
  const ClaimDetailDto({
    required this.claim,
    required this.url,
    required this.shopName,
    required this.platform,
    required this.orders,
    required this.videos,
    required this.photos,
    this.sealed,
    this.anchored,
  });

  factory ClaimDetailDto.fromJson(Map<String, dynamic> j) {
    final shop = (j['shop'] as Map<String, dynamic>?) ?? const {};
    final evidence = (j['evidence'] as Map<String, dynamic>?) ?? const {};
    return ClaimDetailDto(
      claim: ClaimDto.fromJson(
        (j['claim'] as Map<String, dynamic>?) ?? const {},
      ),
      url: (j['url'] as String?) ?? '',
      shopName: (shop['name'] as String?) ?? '',
      platform: (shop['platform'] as String?) ?? '',
      orders: [
        for (final o in (j['orders'] as List<dynamic>? ?? const []))
          ClaimOrderRefDto.fromJson(o as Map<String, dynamic>),
      ],
      videos: _int(evidence['videos']),
      photos: _int(evidence['photos']),
      sealed: _intN(evidence['sealed']),
      anchored: _intN(evidence['anchored']),
    );
  }

  final ClaimDto claim;
  final String url;
  final String shopName;
  final String platform;

  /// Xếp theo thời điểm tạo đơn, cũ trước — đúng thứ tự máy chủ trả.
  final List<ClaimOrderRefDto> orders;
  final int videos;
  final int photos;

  /// Trong số [videos]: đã ký, và đã có chứng thực độc lập. `null` = máy chủ
  /// cũ chưa trả — màn im lặng, không hiện "0/7" sai.
  final int? sealed;
  final int? anchored;
}

class ClaimDto {
  const ClaimDto({
    required this.id,
    required this.url,
    this.title,
    this.orderCount = 0,
    this.evidenceCount = 0,
    this.revoked = false,
    this.createdAt = 0,
  });

  factory ClaimDto.fromJson(Map<String, dynamic> j) => ClaimDto(
    id: (j['id'] as String?) ?? '',
    url: (j['url'] as String?) ?? '',
    title: j['title'] as String?,
    orderCount: _int(j['order_count']),
    evidenceCount: _int(j['evidence_count']),
    revoked: _int(j['revoked']) == 1,
    createdAt: _int(j['created_at']),
  );

  final String id;

  /// Link công khai đầy đủ trên zenpack.vn. Dùng nguyên chuỗi này — đừng ghép
  /// lại từ token, vì mỗi client ghép một kiểu và cái sai chỉ lộ ra sau khi
  /// người bán đã gửi link cho sàn.
  final String url;
  final String? title;
  final int orderCount;

  /// Số bằng chứng hồ sơ đang mang, theo đúng luật của trang công khai. Máy chủ
  /// đếm chứ không phải máy này: hồ sơ tạo trên web hoặc trên máy khác thì máy
  /// đang mở không có gì để đếm.
  final int evidenceCount;

  /// Đã thu hồi — link chết, dữ liệu còn.
  final bool revoked;
  final int createdAt;
}

/// Báo cáo của một cửa hàng trong một kỳ — CÙNG một endpoint mà web admin
/// dùng (`GET /api/shops/:id/stats`), không phải bản rút gọn riêng cho máy.
///
/// Phạm vi do máy chủ quyết, không phải máy này: nhân viên luôn nhận số của
/// chính họ, và [byMember]/[health] về null. Đừng tự lọc thêm ở client — hai
/// nơi cùng quyết một luật quyền là hai nơi sẽ lệch nhau.
class ShopStatsDto {
  const ShopStatsDto({
    required this.rangeDays,
    required this.from,
    required this.to,
    this.memberUid,
    this.orders = 0,
    this.videos = 0,
    this.pendingUploads = 0,
    this.ordersWithoutEvidence = 0,
    this.videosStored = 0,
    this.coverageOrders = 0,
    this.coverageWithEvidence = 0,
    this.byMember,
    this.health,
  });

  factory ShopStatsDto.fromJson(Map<String, dynamic> j) {
    final coverage = j['coverage'] as Map<String, dynamic>? ?? const {};
    final members = j['by_member'] as List<dynamic>?;
    final health = j['evidence_health'] as Map<String, dynamic>?;
    return ShopStatsDto(
      rangeDays: _int(j['range_days']),
      from: _int(j['from']),
      to: _int(j['to']),
      memberUid: j['member_uid'] as String?,
      orders: _current(j['orders']),
      videos: _current(j['videos']),
      pendingUploads: _current(j['pending_uploads']),
      ordersWithoutEvidence: _int(j['orders_without_evidence']),
      videosStored: _int(j['videos_stored']),
      coverageOrders: _int(coverage['orders']),
      coverageWithEvidence: _int(coverage['with_evidence']),
      byMember: members == null
          ? null
          : [
              for (final e in members)
                MemberStatDto.fromJson(e as Map<String, dynamic>),
            ],
      health: health == null ? null : EvidenceHealthDto.fromJson(health),
    );
  }

  /// Các thẻ số liệu về dưới dạng `{current, previous}`; màn hình chỉ vẽ kỳ
  /// đang xem, nên lấy thẳng `current` thay vì giữ cả hai rồi quên dùng.
  static int _current(Object? v) =>
      _int((v as Map<String, dynamic>?)?['current']);

  final int rangeDays;
  final int from;
  final int to;

  /// uid mà mọi con số đang bị giới hạn theo; null = cả cửa hàng.
  final String? memberUid;

  final int orders;
  final int videos;
  final int pendingUploads;
  final int ordersWithoutEvidence;
  final int videosStored;

  /// Bao nhiêu đơn của kỳ có ít nhất một video — tử số và mẫu số đi cùng nhau
  /// để không ai ghép nhầm với một tổng khác.
  final int coverageOrders;
  final int coverageWithEvidence;

  /// null = người xem không phải chủ shop, hoặc đang soi riêng một người.
  final List<MemberStatDto>? byMember;
  final EvidenceHealthDto? health;
}

/// Một người trong bảng "theo nhân viên". [videos] là của kỳ đang xem;
/// [pending] và [errors] là việc đang tồn của mọi thời điểm — clip kẹt từ
/// tháng trước vẫn đang nằm trong máy người này.
class MemberStatDto {
  const MemberStatDto({
    required this.uid,
    required this.role,
    this.name,
    this.email,
    this.videos = 0,
    this.pending = 0,
    this.errors = 0,
    this.lastVideoAt,
  });

  factory MemberStatDto.fromJson(Map<String, dynamic> j) => MemberStatDto(
    uid: (j['uid'] as String?) ?? '',
    role: (j['role'] as String?) ?? 'staff',
    name: j['name'] as String?,
    email: j['email'] as String?,
    videos: _int(j['videos']),
    pending: _int(j['pending']),
    errors: _int(j['errors']),
    lastVideoAt: _intN(j['last_video_at']),
  );

  final String uid;
  final String role;
  final String? name;
  final String? email;
  final int videos;
  final int pending;
  final int errors;

  /// null = chưa quay lần nào — người này chưa thực sự dùng app.
  final int? lastVideoAt;
}

/// Sức khỏe niêm phong của toàn bộ clip đã lên cloud, không theo kỳ.
class EvidenceHealthDto {
  const EvidenceHealthDto({
    this.sealed = 0,
    this.mismatch = 0,
    this.renderFailed = 0,
    this.inProgress = 0,
    this.legacy = 0,
    this.auditBroken = 0,
  });

  factory EvidenceHealthDto.fromJson(Map<String, dynamic> j) =>
      EvidenceHealthDto(
        sealed: _int(j['sealed']),
        mismatch: _int(j['mismatch']),
        renderFailed: _int(j['render_failed']),
        inProgress: _int(j['in_progress']),
        legacy: _int(j['legacy']),
        auditBroken: _int(j['audit_broken']),
      );

  final int sealed;

  /// Dấu không khớp — clip còn đó nhưng không tự chứng minh được.
  final int mismatch;
  final int renderFailed;
  final int inProgress;

  /// Clip quay trước khi có niêm phong: vĩnh viễn không có dấu.
  final int legacy;
  final int auditBroken;
}

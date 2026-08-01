/// DTOs for the EvidenceCam Workers API (`evidencecam-backend`). Hand-written
/// `fromJson` (no codegen) — the field names mirror the D1 schema / service
/// responses exactly. Kept separate from the presentational screen models so
/// the API surface can evolve independently.
library;

int _int(Object? v, [int fallback = 0]) => (v as num?)?.toInt() ?? fallback;
int? _intN(Object? v) => (v as num?)?.toInt();

class AccountDto {
  const AccountDto({
    required this.uid,
    this.email,
    this.name,
    this.phone,
    this.avatarUrl,
  });

  factory AccountDto.fromJson(Map<String, dynamic> j) => AccountDto(
    uid: j['uid'] as String,
    email: j['email'] as String?,
    name: j['name'] as String?,
    phone: j['phone'] as String?,
    avatarUrl: j['avatar_url'] as String?,
  );

  final String uid;
  final String? email;
  final String? name;
  final String? phone;
  final String? avatarUrl;
}

class ShopDto {
  const ShopDto({
    required this.id,
    required this.name,
    required this.platform,
    required this.resolution,
    required this.role,
    this.clipSeconds = 120,
    this.recommendedClipSeconds = 120,
    this.planMaxClipSeconds = 900,
    this.maxImageBytes = 10000000,
    this.maxVideoBytes = 30000000,
    this.uploadBytes = 10000000,
    this.platformLimitsVerified = true,
  });

  factory ShopDto.fromJson(Map<String, dynamic> j) => ShopDto(
    id: j['id'] as String,
    name: j['name'] as String,
    platform: j['platform'] as String,
    resolution: (j['resolution'] as String?) ?? '720p',
    role: (j['role'] as String?) ?? 'owner',
    clipSeconds: _int(j['effective_clip_seconds'], 120),
    recommendedClipSeconds: _int(j['recommended_clip_seconds'], 120),
    planMaxClipSeconds: _int(j['plan_max_clip_seconds'], 900),
    maxImageBytes: _int(j['max_image_bytes'], 10000000),
    maxVideoBytes: _int(j['max_video_bytes'], 30000000),
    uploadBytes: _int(j['effective_upload_bytes'], 10000000),
    platformLimitsVerified: (j['platform_limits_verified'] as bool?) ?? true,
  );

  final String id;
  final String name;
  final String platform;
  final String resolution;

  /// owner | manager | staff
  final String role;

  /// Ngân sách clip (FR-17/FR-18). Backend đã kẹp [clipSeconds] vào trần gói,
  /// nên app dùng thẳng, không tính lại.
  final int clipSeconds;
  final int recommendedClipSeconds;
  final int planMaxClipSeconds;
  final int maxImageBytes;
  final int maxVideoBytes;

  /// Trần dung lượng một tệp bằng chứng đang áp dụng (FR-21).
  final int uploadBytes;
  final bool platformLimitsVerified;
}

class MemberDto {
  const MemberDto({
    required this.accountUid,
    required this.role,
    this.name,
    this.email,
  });

  factory MemberDto.fromJson(Map<String, dynamic> j) => MemberDto(
    accountUid: j['account_uid'] as String,
    role: j['role'] as String,
    name: j['name'] as String?,
    email: j['email'] as String?,
  );

  final String accountUid;
  final String role;
  final String? name;
  final String? email;
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

class OrderSummaryDto {
  const OrderSummaryDto({
    required this.id,
    required this.tracking,
    required this.createdAt,
    required this.evidenceCount,
    this.lastCapturedAt,
    this.latestType,
    this.errorCount = 0,
    this.pendingCount = 0,
  });

  factory OrderSummaryDto.fromJson(Map<String, dynamic> j) => OrderSummaryDto(
    id: j['id'] as String,
    tracking: j['tracking_raw'] as String,
    createdAt: _int(j['created_at']),
    evidenceCount: _int(j['evidence_count']),
    lastCapturedAt: _intN(j['last_captured_at']),
    latestType: j['latest_type'] as String?,
    errorCount: _int(j['error_count']),
    pendingCount: _int(j['pending_count']),
  );

  final String id;
  final String tracking;
  final int createdAt;
  final int evidenceCount;
  final int? lastCapturedAt;
  final String? latestType;
  final int errorCount;
  final int pendingCount;
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
  });

  final List<OrderSummaryDto> items;
  final int total;

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
    this.device,
    this.r2Key,
    this.thumbUrl,
    this.sha256,
    this.url,
    this.retentionExpiresAt,
    this.durationSeconds,
    this.clockSkewMs,
  });

  factory EvidenceDto.fromJson(Map<String, dynamic> j) => EvidenceDto(
    id: j['id'] as String,
    kind: j['kind'] as String,
    capturedAt: _int(j['captured_at']),
    uploadStatus: j['upload_status'] as String,
    videoTypeId: j['video_type_id'] as String?,
    createdByUid: j['created_by_uid'] as String?,
    device: j['device'] as String?,
    r2Key: j['r2_key'] as String?,
    url: j['url'] as String?,
    thumbUrl: j['thumb_url'] as String?,
    sha256: j['sha256'] as String?,
    retentionExpiresAt: _intN(j['retention_expires_at']),
    durationSeconds: _intN(j['duration_seconds']),
    clockSkewMs: _intN(j['clock_skew_ms']),
  );

  final String id;
  final String kind;
  final int capturedAt;
  final String uploadStatus;
  final String? videoTypeId;
  final String? createdByUid;
  final String? device;

  /// When this evidence's R2 object is swept by the retention cron
  /// (`retention.ts`), or when it's next eligible if not yet swept. Null while
  /// retention hasn't been computed for it yet.
  final int? retentionExpiresAt;
  final String? r2Key;
  final String? url;

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
}

/// Device-clock error we treat as normal drift rather than a wrong clock.
///
/// 2 minutes: comfortably above the seconds of round-trip and NTP jitter a
/// healthy phone shows, far below the timezone- or date-sized mistakes that
/// actually misdate evidence.
const int kClockSkewToleranceMs = 2 * 60 * 1000;

class OrderDetailDto {
  const OrderDetailDto({required this.order, required this.evidence});

  factory OrderDetailDto.fromJson(Map<String, dynamic> j) => OrderDetailDto(
    order: OrderDto.fromJson(j['order'] as Map<String, dynamic>),
    evidence: (j['evidence'] as List)
        .map((e) => EvidenceDto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final OrderDto order;
  final List<EvidenceDto> evidence;
}

class QuotaDto {
  const QuotaDto({
    required this.planCode,
    required this.usedBytes,
    required this.capBytes,
    required this.remainingBytes,
    this.retentionDays = 30,
    this.canManagePlan = true,
  });

  factory QuotaDto.fromJson(Map<String, dynamic> j) => QuotaDto(
    planCode: (j['plan_code'] as String?) ?? 'free',
    usedBytes: _int(j['used_bytes']),
    capBytes: _int(j['cap_bytes']),
    remainingBytes: _int(j['remaining_bytes']),
    retentionDays: _intN(j['retention_days']) ?? 30,
    canManagePlan: (j['can_manage_plan'] as bool?) ?? true,
  );

  final String planCode;
  final int usedBytes;
  final int capBytes;
  final int remainingBytes;
  final int retentionDays;

  /// Chỉ chủ shop mới đổi được gói — gói cước gắn với tài khoản trả tiền.
  /// Quản lý/nhân viên xem được gói đang chi phối ca làm nhưng không mua.
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

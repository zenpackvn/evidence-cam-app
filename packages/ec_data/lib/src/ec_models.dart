/// DTOs for the EvidenceCam Workers API (`evidencecam-backend`). Hand-written
/// `fromJson` (no codegen) — the field names mirror the D1 schema / service
/// responses exactly. Kept separate from the presentational screen models so
/// the API surface can evolve independently.
library;

int _int(Object? v) => (v as num?)?.toInt() ?? 0;
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
  });

  factory ShopDto.fromJson(Map<String, dynamic> j) => ShopDto(
    id: j['id'] as String,
    name: j['name'] as String,
    platform: j['platform'] as String,
    resolution: (j['resolution'] as String?) ?? '720p',
    role: (j['role'] as String?) ?? 'owner',
  );

  final String id;
  final String name;
  final String platform;
  final String resolution;

  /// owner | manager | staff
  final String role;
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
    this.url,
    this.retentionExpiresAt,
    this.durationSeconds,
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
    retentionExpiresAt: _intN(j['retention_expires_at']),
    durationSeconds: _intN(j['duration_seconds']),
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

  /// Recorded clip length in seconds; null for photos and older evidence
  /// captured before this field existed.
  final int? durationSeconds;
}

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
    this.retentionDays = 20,
    this.canManagePlan = true,
  });

  factory QuotaDto.fromJson(Map<String, dynamic> j) => QuotaDto(
    planCode: (j['plan_code'] as String?) ?? 'free',
    usedBytes: _int(j['used_bytes']),
    capBytes: _int(j['cap_bytes']),
    remainingBytes: _int(j['remaining_bytes']),
    retentionDays: _intN(j['retention_days']) ?? 20,
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
  });

  factory PresignDto.fromJson(Map<String, dynamic> j) => PresignDto(
    evidenceId: j['evidenceId'] as String,
    key: j['key'] as String,
    uploadUrl: j['uploadUrl'] as String,
  );

  final String evidenceId;
  final String key;
  final String uploadUrl;
}

class MultipartUploadDto {
  const MultipartUploadDto({
    required this.evidenceId,
    required this.key,
    required this.uploadId,
  });

  factory MultipartUploadDto.fromJson(Map<String, dynamic> j) =>
      MultipartUploadDto(
        evidenceId: j['evidenceId'] as String,
        key: j['key'] as String,
        uploadId: j['uploadId'] as String,
      );

  final String evidenceId;
  final String key;
  final String uploadId;
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
  });

  factory VideoTypeDto.fromJson(Map<String, dynamic> j) => VideoTypeDto(
    id: j['id'] as String,
    name: j['name'] as String,
    isDefault: _int(j['is_default']) == 1,
  );

  final String id;
  final String name;
  final bool isDefault;
}

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
  });

  factory OrderSummaryDto.fromJson(Map<String, dynamic> j) => OrderSummaryDto(
    id: j['id'] as String,
    tracking: j['tracking_raw'] as String,
    createdAt: _int(j['created_at']),
    evidenceCount: _int(j['evidence_count']),
    lastCapturedAt: _intN(j['last_captured_at']),
  );

  final String id;
  final String tracking;
  final int createdAt;
  final int evidenceCount;
  final int? lastCapturedAt;
}

class EvidenceDto {
  const EvidenceDto({
    required this.id,
    required this.kind,
    required this.capturedAt,
    required this.uploadStatus,
    this.videoTypeId,
    this.r2Key,
  });

  factory EvidenceDto.fromJson(Map<String, dynamic> j) => EvidenceDto(
    id: j['id'] as String,
    kind: j['kind'] as String,
    capturedAt: _int(j['captured_at']),
    uploadStatus: j['upload_status'] as String,
    videoTypeId: j['video_type_id'] as String?,
    r2Key: j['r2_key'] as String?,
  );

  final String id;
  final String kind;
  final int capturedAt;
  final String uploadStatus;
  final String? videoTypeId;
  final String? r2Key;
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
    required this.used,
    required this.cap,
    required this.remaining,
    required this.periodEnd,
  });

  factory QuotaDto.fromJson(Map<String, dynamic> j) => QuotaDto(
    used: _int(j['used']),
    cap: _int(j['cap']),
    remaining: _int(j['remaining']),
    periodEnd: _int(j['period_end']),
  );

  final int used;
  final int cap;
  final int remaining;
  final int periodEnd;
}

class DossierDto {
  const DossierDto({
    required this.shareToken,
    required this.revoked,
    required this.status,
  });

  factory DossierDto.fromJson(Map<String, dynamic> j) => DossierDto(
    shareToken: j['share_token'] as String,
    revoked: _int(j['revoked']) == 1,
    status: (j['status'] as String?) ?? 'draft',
  );

  final String shareToken;
  final bool revoked;
  final String status;
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

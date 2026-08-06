/// Hồ sơ khiếu nại: tập bằng chứng người bán đã chọn để gửi cho sàn.
///
/// Thuần Dart, JSON vào/ra — mô hình này đi qua hai feature (trang vận đơn tạo
/// nó, tab Tài khoản hiển thị nó) nên nằm ở đây thay vì thuộc về một bên.
///
/// **Chưa có gì ở phía máy chủ.** Backend chưa mở endpoint gộp bằng chứng, nên
/// hồ sơ hiện chỉ sống trên máy này (xem `EcClaimStore` ở app shell). Khi
/// endpoint có thật thì đây là hình dạng để ánh xạ sang, không phải thứ phải
/// vứt đi.
library;

/// Một hồ sơ, gộp bằng chứng của một hoặc nhiều mã vận đơn.
class EcClaimDossier {
  const EcClaimDossier({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.orders,
  });

  factory EcClaimDossier.fromJson(Map<String, dynamic> j) => EcClaimDossier(
    id: j['id'] as String,
    shopId: (j['shop_id'] as String?) ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (j['created_at'] as num?)?.toInt() ?? 0,
    ),
    orders: [
      for (final o in (j['orders'] as List<dynamic>? ?? const []))
        EcClaimOrder.fromJson(o as Map<String, dynamic>),
    ],
  );

  /// Sinh ở máy, không phải id của server.
  final String id;
  final String shopId;

  /// Lúc bấm tạo hồ sơ — thứ hiện trên dòng cha.
  final DateTime createdAt;

  final List<EcClaimOrder> orders;

  /// Tổng số bằng chứng trong hồ sơ, cho nhãn tóm tắt ở dòng cha.
  int get evidenceCount =>
      orders.fold(0, (total, o) => total + o.evidence.length);

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop_id': shopId,
    'created_at': createdAt.millisecondsSinceEpoch,
    'orders': [for (final o in orders) o.toJson()],
  };

  EcClaimDossier copyWith({List<EcClaimOrder>? orders}) => EcClaimDossier(
    id: id,
    shopId: shopId,
    createdAt: createdAt,
    orders: orders ?? this.orders,
  );
}

/// Phần của một mã vận đơn trong hồ sơ.
class EcClaimOrder {
  const EcClaimOrder({
    required this.tracking,
    required this.evidence,
    this.orderId,
  });

  factory EcClaimOrder.fromJson(Map<String, dynamic> j) => EcClaimOrder(
    tracking: (j['tracking'] as String?) ?? '',
    orderId: j['order_id'] as String?,
    evidence: [
      for (final e in (j['evidence'] as List<dynamic>? ?? const []))
        EcClaimEvidence.fromJson(e as Map<String, dynamic>),
    ],
  );

  final String tracking;

  /// Id đơn trên server, để mở lại màn chi tiết đơn từ hồ sơ. Có thể null ở
  /// hồ sơ tạo trước khi trường này được lưu.
  final String? orderId;

  final List<EcClaimEvidence> evidence;

  Map<String, dynamic> toJson() => {
    'tracking': tracking,
    'order_id': ?orderId,
    'evidence': [for (final e in evidence) e.toJson()],
  };

  EcClaimOrder copyWith({List<EcClaimEvidence>? evidence}) => EcClaimOrder(
    tracking: tracking,
    orderId: orderId,
    evidence: evidence ?? this.evidence,
  );
}

/// Một bằng chứng đã chọn, chụp lại đủ để hiện ra và sao chép mà không phải
/// hỏi lại server.
///
/// Chụp lại chứ không giữ id rồi tra sau: bằng chứng có thể hết hạn lưu trữ
/// hoặc bị xoá, mà hồ sơ khiếu nại thì phải nói được nó ĐÃ gồm những gì.
class EcClaimEvidence {
  const EcClaimEvidence({
    required this.id,
    required this.label,
    required this.time,
    this.isPhoto = false,
    this.url,
    this.thumbUrl,
    this.addedLater = false,
  });

  factory EcClaimEvidence.fromJson(Map<String, dynamic> j) => EcClaimEvidence(
    id: (j['id'] as String?) ?? '',
    label: (j['label'] as String?) ?? '',
    time: (j['time'] as String?) ?? '',
    isPhoto: (j['is_photo'] as bool?) ?? false,
    url: j['url'] as String?,
    thumbUrl: j['thumb_url'] as String?,
    addedLater: (j['added_later'] as bool?) ?? false,
  );

  final String id;

  /// Nhãn loại đã dịch sẵn lúc tạo hồ sơ ("Đóng hàng", "Ảnh đính kèm"…).
  final String label;

  /// Giờ quay, dạng `HH:mm`.
  final String time;

  final bool isPhoto;

  /// Link tải. Với ảnh người dùng đính thêm sau ([addedLater]) thì đây là
  /// đường dẫn file trên máy cho tới khi nó tải lên xong.
  final String? url;

  final String? thumbUrl;

  /// Người dùng đính thêm SAU khi hồ sơ đã tạo, không phải thứ họ tick lúc đầu.
  final bool addedLater;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'time': time,
    'is_photo': isPhoto,
    'url': ?url,
    'thumb_url': ?thumbUrl,
    'added_later': addedLater,
  };
}

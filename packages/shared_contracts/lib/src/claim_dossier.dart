/// Hồ sơ khiếu nại: tập bằng chứng người bán đã chọn để gửi cho sàn.
///
/// Thuần Dart, JSON vào/ra — mô hình này đi qua hai feature (trang vận đơn tạo
/// nó, tab Tài khoản hiển thị nó) nên nằm ở đây thay vì thuộc về một bên.
///
/// **Nội dung nằm trên máy, link nằm trên máy chủ.** Máy chủ đã có endpoint gộp
/// (`POST /api/shops/:id/claims`) và giữ link công khai, nhưng chưa có đường
/// đọc lại nội dung hồ sơ khi đã đăng nhập — nên danh sách và chi tiết vẫn đọc
/// từ `EcClaimStore` ở app shell. Cặp `claimId` + `shareUrl` là sợi dây duy
/// nhất nối bản trên máy với bản trên máy chủ.
library;

/// Một hồ sơ, gộp bằng chứng của một hoặc nhiều mã vận đơn.
class EcClaimDossier {
  const EcClaimDossier({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.orders,
    this.claimId,
    this.shareUrl,
  });

  factory EcClaimDossier.fromJson(Map<String, dynamic> j) => EcClaimDossier(
    id: j['id'] as String,
    shopId: (j['shop_id'] as String?) ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (j['created_at'] as num?)?.toInt() ?? 0,
    ),
    claimId: j['claim_id'] as String?,
    shareUrl: j['share_url'] as String?,
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

  /// Id hồ sơ TRÊN MÁY CHỦ — thứ duy nhất thu hồi link được.
  ///
  /// `null` cùng lúc với [shareUrl]: hồ sơ chưa bao giờ lên tới máy chủ. Xoá
  /// một hồ sơ như thế là chuyện nội bộ của máy này; xoá một hồ sơ CÓ id thì
  /// phải thu hồi trước, nếu không link vẫn phát cho sàn xem trong khi người
  /// bán tưởng mình vừa gỡ nó xuống.
  final String? claimId;

  /// Link công khai của hồ sơ trên zenpack.vn, do máy chủ cấp.
  ///
  /// `null` = hồ sơ chỉ tồn tại trên máy này: hoặc nó được tạo trước khi máy
  /// chủ mở endpoint gộp, hoặc lượt gửi lên hỏng (mất mạng) và hàng đợi chưa
  /// thử lại. Màn hồ sơ phải nói thẳng điều đó ra — im lặng là để người bán
  /// tưởng bằng chứng khiếu nại của họ đã an toàn trên máy chủ.
  final String? shareUrl;

  /// Tổng số bằng chứng trong hồ sơ, cho nhãn tóm tắt ở dòng cha.
  int get evidenceCount =>
      orders.fold(0, (total, o) => total + o.evidence.length);

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop_id': shopId,
    'created_at': createdAt.millisecondsSinceEpoch,
    if (claimId != null) 'claim_id': claimId,
    if (shareUrl != null) 'share_url': shareUrl,
    'orders': [for (final o in orders) o.toJson()],
  };

  /// [clearLink] cho phép đặt link về `null`. Không có nó thì `null` truyền
  /// vào chỉ có nghĩa "giữ nguyên", và một hồ sơ vừa bị thu hồi link sẽ mãi
  /// mang cái link đã chết.
  EcClaimDossier copyWith({
    List<EcClaimOrder>? orders,
    String? claimId,
    String? shareUrl,
    bool clearLink = false,
  }) => EcClaimDossier(
    id: id,
    shopId: shopId,
    createdAt: createdAt,
    orders: orders ?? this.orders,
    claimId: clearLink ? claimId : (claimId ?? this.claimId),
    shareUrl: clearLink ? shareUrl : (shareUrl ?? this.shareUrl),
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
    this.capturedAt,
    this.addedBy,
  });

  factory EcClaimEvidence.fromJson(Map<String, dynamic> j) => EcClaimEvidence(
    id: (j['id'] as String?) ?? '',
    label: (j['label'] as String?) ?? '',
    time: (j['time'] as String?) ?? '',
    isPhoto: (j['is_photo'] as bool?) ?? false,
    url: j['url'] as String?,
    thumbUrl: j['thumb_url'] as String?,
    addedLater: (j['added_later'] as bool?) ?? false,
    capturedAt: (j['captured_at'] as num?)?.toInt(),
    addedBy: j['added_by'] as String?,
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

  /// Tên tài khoản đã đính ảnh này vào hồ sơ. Chỉ có ở ảnh [addedLater]: ảnh
  /// đó chưa lên máy chủ nên không có hồ sơ bằng chứng nào để tra người chụp,
  /// và người đính CHÍNH LÀ người chụp — ghi lại ngay lúc đính là cách duy
  /// nhất còn biết được về sau.
  final String? addedBy;

  /// Lúc quay/chụp, epoch ms. Dùng để hiện NGÀY ở dòng mã vận đơn — [time] chỉ
  /// có `HH:mm`, mà một hồ sơ gộp nhiều đơn thì các đơn có thể ở khác ngày.
  ///
  /// `null` ở hồ sơ tạo trước khi trường này tồn tại; lúc đó dòng mã đơn chỉ
  /// hiện mã, không bịa ra một ngày nào.
  final int? capturedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'time': time,
    'is_photo': isPhoto,
    'url': ?url,
    'thumb_url': ?thumbUrl,
    'added_later': addedLater,
    'captured_at': ?capturedAt,
    'added_by': ?addedBy,
  };
}

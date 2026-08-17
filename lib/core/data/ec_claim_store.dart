/// Kho hồ sơ khiếu nại trên MÁY NÀY — bộ đệm, không phải bản gốc.
///
/// Bản gốc nằm trên máy chủ (`/api/shops/:id/claims`) và màn danh sách đọc từ
/// đó, cùng đúng nguồn web admin đọc. Kho này còn lại hai việc:
///
/// 1. **Hồ sơ tạo lúc mất mạng** — lượt gửi lên hỏng thì hồ sơ vẫn nằm đây với
///    `claimId == null`. Chúng CHƯA có link, và màn danh sách bật một dòng nói
///    thẳng điều đó: gỡ app là mất, đổi máy là không thấy, web không biết gì.
///    Im lặng ở đây là để người bán tưởng bằng chứng của họ đã an toàn.
/// 2. **Neo cho màn chi tiết** — màn đó mở theo id của bản trên máy, nên hồ sơ
///    tạo ở web hay máy khác được dựng một bản rỗng mang `claimId` khi người
///    dùng bấm vào; nội dung thì đọc từ máy chủ.
///
/// Hồ sơ tạo lúc mất mạng KHÔNG tự gửi lại. Gửi lại mà lượt POST trước thật ra
/// đã thành công (chỉ mất câu trả lời) là đẻ ra hồ sơ thứ hai với một link
/// thứ hai — muốn tự động thì máy chủ phải nhận khoá chống trùng trước đã.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:storage/storage.dart';

/// Đọc/ghi hồ sơ khiếu nại của một tài khoản, nhóm theo shop.
///
/// `ChangeNotifier` để màn danh sách tự vẽ lại sau khi tạo hoặc đính thêm ảnh
/// mà không phải đẩy kết quả ngược qua nhiều lớp route.
class EcClaimStore extends ChangeNotifier {
  EcClaimStore(this._memory);

  /// Có thể null: `KeyValueStore` lấy qua service locator có khi chưa đăng ký
  /// (test widget, bootstrap hỏng). Lúc đó [_cache] vẫn chạy nên trong phiên
  /// hiện tại mọi thứ hoạt động bình thường, chỉ là không sống qua lần mở sau.
  final KeyValueStore? _memory;

  static const _keyPrefix = 'claims.dossiers.';

  static String _key(String shopId) => '$_keyPrefix$shopId';

  /// Bản trong bộ nhớ tiến trình, luôn có mặt.
  ///
  /// Cùng lý do với `_avatarCache`/`_sizeCapCache` ở `ec_app.dart`: thiếu lớp
  /// này thì khi `KeyValueStore` chưa đăng ký, hồ sơ vừa tạo biến mất ngay lúc
  /// màn danh sách dựng lại — không lỗi, không dấu vết.
  final Map<String, List<EcClaimDossier>> _cache = {};

  /// Hồ sơ của [shopId], mới nhất trước.
  List<EcClaimDossier> forShop(String shopId) {
    final cached = _cache[shopId];
    if (cached != null) return List.unmodifiable(cached);
    final loaded = _read(shopId);
    _cache[shopId] = loaded;
    return List.unmodifiable(loaded);
  }

  EcClaimDossier? byId(String shopId, String dossierId) {
    for (final d in forShop(shopId)) {
      if (d.id == dossierId) return d;
    }
    return null;
  }

  /// Dữ liệu hỏng thì trả rỗng chứ KHÔNG ném: một chuỗi JSON lỗi không được
  /// làm chết cả tab Tài khoản.
  List<EcClaimDossier> _read(String shopId) {
    final raw = _memory?.getString(_key(shopId));
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return [
        for (final e in decoded)
          if (e is Map<String, dynamic>) EcClaimDossier.fromJson(e),
      ];
    } on Object {
      return [];
    }
  }

  Future<void> _write(String shopId, List<EcClaimDossier> list) async {
    _cache[shopId] = list;
    notifyListeners();
    await _memory?.setString(
      _key(shopId),
      jsonEncode([for (final d in list) d.toJson()]),
    );
  }

  /// Thêm một hồ sơ mới lên đầu danh sách.
  Future<void> add(EcClaimDossier dossier) =>
      _write(dossier.shopId, [dossier, ...forShop(dossier.shopId)]);

  Future<void> remove(String shopId, String dossierId) => _write(shopId, [
    for (final d in forShop(shopId))
      if (d.id != dossierId) d,
  ]);

  /// Gỡ một bằng chứng khỏi hồ sơ.
  ///
  /// Chỉ gỡ khỏi HỒ SƠ — clip/ảnh trong đơn hàng còn nguyên. Bỏ nhầm một cái
  /// vào hồ sơ thì phải lấy ra được mà không mất bằng chứng gốc.
  ///
  /// Mã đơn nào rỗng sạch thì biến mất khỏi hồ sơ luôn: một mã vận đơn không
  /// còn gì bên dưới chỉ là một tiêu đề trống.
  Future<void> removeEvidence(
    String shopId,
    String dossierId,
    String tracking,
    String evidenceId,
  ) {
    if (byId(shopId, dossierId) == null) return Future<void>.value();
    return _write(shopId, [
      for (final d in forShop(shopId))
        if (d.id != dossierId)
          d
        else
          d.copyWith(orders: _withoutEvidence(d, tracking, evidenceId)),
    ]);
  }

  static List<EcClaimOrder> _withoutEvidence(
    EcClaimDossier dossier,
    String tracking,
    String evidenceId,
  ) {
    final out = <EcClaimOrder>[];
    for (final o in dossier.orders) {
      if (o.tracking != tracking) {
        out.add(o);
        continue;
      }
      final left = [
        for (final e in o.evidence)
          if (e.id != evidenceId) e,
      ];
      if (left.isNotEmpty) out.add(o.copyWith(evidence: left));
    }
    return out;
  }

  /// Đính thêm một bằng chứng vào đúng mã vận đơn trong hồ sơ.
  ///
  /// Không tìm thấy hồ sơ hoặc mã đơn thì không làm gì — người dùng có thể đã
  /// xoá hồ sơ ở tab khác trong lúc bộ chọn ảnh đang mở.
  Future<void> attachEvidence(
    String shopId,
    String dossierId,
    String tracking,
    EcClaimEvidence evidence,
  ) {
    final dossier = byId(shopId, dossierId);
    if (dossier == null) return Future<void>.value();
    return _write(shopId, [
      for (final d in forShop(shopId))
        if (d.id != dossierId)
          d
        else
          d.copyWith(
            orders: [
              for (final o in d.orders)
                if (o.tracking != tracking)
                  o
                else
                  o.copyWith(evidence: [...o.evidence, evidence]),
            ],
          ),
    ]);
  }
}

/// Bản tóm tắt dạng chữ của một hồ sơ, để dán vào khung chat CSKH của sàn.
///
/// Chưa có link gộp nào để sao chép — backend chưa mở endpoint — nên thứ sao
/// chép được là chính nội dung hồ sơ: mã đơn, từng bằng chứng, và link tải của
/// nó. Đọc được bằng mắt và dán được vào bất cứ đâu.
String ecClaimSummaryText(EcClaimDossier dossier, {required String title}) {
  final at = dossier.createdAt;
  String two(int n) => n.toString().padLeft(2, '0');
  final stamp =
      '${two(at.day)}/${two(at.month)}/${at.year} '
      '${two(at.hour)}:${two(at.minute)}';
  final lines = <String>['$title — $stamp', ''];
  for (final order in dossier.orders) {
    lines.add(order.tracking);
    for (final e in order.evidence) {
      final url = e.url;
      lines.add(
        '  • ${e.label}  ${e.time}${url == null || url.isEmpty ? '' : '  $url'}',
      );
    }
    lines.add('');
  }
  return lines.join('\n').trimRight();
}

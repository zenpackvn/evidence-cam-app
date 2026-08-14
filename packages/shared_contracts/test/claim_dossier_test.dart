import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';

void main() {
  group('tên hồ sơ', _titleRoundTripTests);
  group('EcClaimDossier', () {
    // `claimId` là thứ duy nhất thu hồi link được. Nó đi qua JSON để nằm trong
    // `EcClaimStore`, nên rơi ở vòng này thì nút "Xóa hồ sơ" lặng lẽ chỉ xoá
    // bản trên máy trong khi link công khai vẫn phát bằng chứng cho sàn xem —
    // không lỗi, không dấu vết.
    test('claimId và shareUrl sống sót qua vòng JSON của kho trên máy', () {
      final dossier = EcClaimDossier(
        id: '1700000000000',
        shopId: 'shop_1',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
        claimId: 'clm_server',
        shareUrl: 'https://zenpack.vn/c/abc123',
        orders: const [
          EcClaimOrder(
            tracking: 'SPX123',
            evidence: [
              EcClaimEvidence(id: 'ev_1', label: 'Đóng hàng', time: '09:30'),
            ],
          ),
        ],
      );

      final restored = EcClaimDossier.fromJson(dossier.toJson());

      expect(restored.claimId, 'clm_server');
      expect(restored.shareUrl, 'https://zenpack.vn/c/abc123');
      expect(restored.evidenceCount, 1);
    });

    // Hồ sơ tạo lúc mất mạng: không có gì trên máy chủ để thu hồi, và màn xoá
    // đọc đúng chỗ này để chọn câu xác nhận không nhắc tới link.
    test('hồ sơ chỉ có trên máy thì claimId là null', () {
      final local = EcClaimDossier(
        id: '2',
        shopId: 'shop_1',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        orders: const [],
      );

      expect(EcClaimDossier.fromJson(local.toJson()).claimId, isNull);
    });
  });
}

void _titleRoundTripTests() {
  // Tên hồ sơ phải SỐNG SÓT qua vòng lưu–đọc trên máy.
  //
  // Đã trượt đúng chỗ này một lần: `toJson` ghi `title` nhưng `fromJson` không
  // đọc, nên tên hiện đúng cho tới khi app khởi động lại rồi biến mất — danh
  // sách hồ sơ lùi hết về ngày giờ mà không có lỗi nào để lần theo.
  test('tên đi qua toJson → fromJson mà không mất', () {
    final before = EcClaimDossier(
      id: 'd1',
      shopId: 's1',
      createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
      title: 'Lô hoàn 8/8',
      orders: const [],
    );
    final after = EcClaimDossier.fromJson(before.toJson());
    expect(after.title, 'Lô hoàn 8/8');
  });

  // Hồ sơ lưu TRƯỚC khi có trường này: JSON cũ không có khoá `title`. Phải đọc
  // được thành chuỗi rỗng chứ không ném — ném thì cả danh sách hồ sơ trắng.
  test('JSON cũ không có khoá title vẫn đọc được', () {
    final old = {
      'id': 'd0',
      'shop_id': 's1',
      'created_at': 1000,
      'orders': <dynamic>[],
    };
    expect(EcClaimDossier.fromJson(old).title, '');
  });

  test('copyWith giữ nguyên tên', () {
    final d = EcClaimDossier(
      id: 'd1',
      shopId: 's1',
      createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
      title: 'Lô hoàn 8/8',
      orders: const [],
    );
    expect(d.copyWith(shareUrl: 'https://x').title, 'Lô hoàn 8/8');
  });
}

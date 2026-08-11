import 'package:flutter_test/flutter_test.dart';
import 'package:shared_contracts/shared_contracts.dart';

void main() {
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

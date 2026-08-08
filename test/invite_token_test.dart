import 'package:evidence_cam/ec_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ecInviteTokenOf', () {
    test('lấy token ra khỏi link mời', () {
      expect(
        ecInviteTokenOf('https://zenpack.vn/invite/abc-123_XY'),
        'abc-123_XY',
      );
    });

    test('nhận cả link đã qua redirect sang fragment', () {
      expect(ecInviteTokenOf('https://zenpack.vn/app#/invite/tok'), 'tok');
    });

    test('nhận token trần — người sao chép tay từ email', () {
      expect(ecInviteTokenOf('abc123XYZ'), 'abc123XYZ');
    });

    // Ca thật sự đáng test: quét nhầm mã QR trên bill vận đơn thì phải KHÔNG
    // có gì xảy ra, chứ không phải gọi accept với một chuỗi rác rồi hiện
    // "không tham gia được".
    test('trả null với mã vận đơn ngắn và chuỗi có khoảng trắng', () {
      expect(ecInviteTokenOf('SPX12'), isNull);
      expect(ecInviteTokenOf('mã vận đơn SPXVN123456789'), isNull);
      expect(ecInviteTokenOf(''), isNull);
    });
  });
}

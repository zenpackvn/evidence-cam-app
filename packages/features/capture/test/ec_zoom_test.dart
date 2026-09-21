import 'package:feature_capture/feature_capture.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hai phép tính của zoom.
///
/// Chỗ dễ sai mà khó thấy: một bước zoom chốt cứng thì sai ở CẢ HAI đầu dải,
/// và cái sai đó chỉ lộ ra trên tay người dùng máy khác.
void main() {
  group('bước zoom', () {
    // Dải rộng (máy có ống tele): chốt bước nhỏ thì phải bấm bốn mươi lăm lần.
    test('dải rộng thì bước lớn — mười nhịp là hết đường', () {
      expect(ecBuocZoom(1, 11), closeTo(1.0, 1e-9));
    });

    // Dải hẹp (webcam): chốt bước lớn thì hai lần bấm là hết.
    test('dải hẹp thì bước nhỏ, vẫn mười nhịp', () {
      expect(ecBuocZoom(1, 3), closeTo(0.2, 1e-9));
    });

    // Sàn 0.2x: dải cực hẹp mà chia mười thì mỗi nhịp không thấy hình đổi, và
    // người dùng kết luận nút hỏng.
    test('dải cực hẹp vẫn có sàn 0.2x, không nhỏ hơn', () {
      expect(ecBuocZoom(1, 1.1), 0.2);
      expect(ecBuocZoom(1, 1), 0.2);
    });

    test('bước luôn dương', () {
      for (final cao in [1.0, 1.05, 2.0, 5.0, 20.0]) {
        expect(ecBuocZoom(1, cao), greaterThan(0));
      }
    });
  });

  group('nhãn zoom', () {
    // `1.0x` đọc như một con số đang chờ nhập tiếp; `1x` là một mức đã chốt.
    test('bỏ đuôi .0', () {
      expect(ecNhanZoom(1), '1x');
      expect(ecNhanZoom(2), '2x');
      expect(ecNhanZoom(10), '10x');
    });

    test('giữ một chữ số thập phân khi có', () {
      expect(ecNhanZoom(1.8), '1.8x');
      expect(ecNhanZoom(2.5), '2.5x');
    });

    // Một chữ số là đủ: `1.83x` không giúp gì cho việc soi thùng hàng, mà làm
    // nhãn nhảy số liên tục khi kéo cử chỉ chụm.
    test('làm tròn về một chữ số, không in dãy dài', () {
      expect(ecNhanZoom(1.8333333), '1.8x');
      expect(ecNhanZoom(1.96), '2x');
    });
  });

  group('máy có zoom được không', () {
    test('một mức duy nhất thì KHÔNG', () {
      expect(ecZoomDuoc(1, 1), isFalse);
    });

    test('có dải thì CÓ', () {
      expect(ecZoomDuoc(1, 2), isTrue);
    });

    // Chưa dựng camera thì cả hai bằng mặc định 1 — lúc ấy phải là "không",
    // nếu không cột nút hiện lên rồi biến mất khi camera lên.
    test('chưa biết dải thì coi như không zoom được', () {
      expect(ecZoomDuoc(1, 1), isFalse);
    });
  });
}

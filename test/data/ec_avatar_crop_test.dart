import 'package:evidence_cam/data/ec_avatar_crop.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sai số cho phép khi so toạ độ: mọi phép ở đây đi qua một lượt nghịch đảo ma
/// trận, nên chờ bằng nhau tuyệt đối là chờ một thứ dấu phẩy động không hứa.
void _expectRect(Rect actual, Rect expected) {
  expect(actual.left, closeTo(expected.left, 0.01));
  expect(actual.top, closeTo(expected.top, 0.01));
  expect(actual.right, closeTo(expected.right, 0.01));
  expect(actual.bottom, closeTo(expected.bottom, 0.01));
}

void main() {
  group('phủ kín khung', () {
    // Ảnh NGANG: cạnh ngắn là chiều cao, nên nó quyết hệ số phóng và phần thừa
    // rơi vào hai bên trái phải — đúng phần người dùng kéo qua kéo lại.
    test('ảnh ngang lấy hệ số theo chiều cao', () {
      const source = Size(2000, 1000);
      expect(ecAvatarCoverScale(source, 300), closeTo(0.3, 1e-9));
      expect(ecAvatarCoverSize(source, 300), const Size(600, 300));
    });

    test('ảnh dọc lấy hệ số theo chiều rộng', () {
      const source = Size(1000, 2000);
      expect(ecAvatarCoverScale(source, 300), closeTo(0.3, 1e-9));
      expect(ecAvatarCoverSize(source, 300), const Size(300, 600));
    });

    test('ảnh vuông thì vừa khít, không thừa chiều nào', () {
      expect(ecAvatarCoverSize(const Size(800, 800), 400), const Size(400, 400));
    });
  });

  group('vùng ảnh gốc trong khung', () {
    // Chưa kéo gì: khung phải ăn đúng phần GIỮA của ảnh, và cạnh ngắn phải lọt
    // trọn vẹn. Đây là điều kiện để mở màn cắt ra không thấy ảnh nhảy.
    test('ma trận khởi đầu ăn đúng ô vuông giữa ảnh ngang', () {
      const source = Size(2000, 1000);
      const viewport = 300.0;
      final rect = ecAvatarSourceRect(
        source: source,
        viewport: viewport,
        matrix: ecAvatarInitialMatrix(source, viewport),
      );
      // Ô vuông 1000×1000 nằm chính giữa chiều ngang 2000.
      _expectRect(rect, const Rect.fromLTWH(500, 0, 1000, 1000));
    });

    test('ma trận khởi đầu ăn đúng ô vuông giữa ảnh dọc', () {
      const source = Size(1000, 2000);
      const viewport = 300.0;
      final rect = ecAvatarSourceRect(
        source: source,
        viewport: viewport,
        matrix: ecAvatarInitialMatrix(source, viewport),
      );
      _expectRect(rect, const Rect.fromLTWH(0, 500, 1000, 1000));
    });

    // Phóng gấp đôi = khung chỉ còn ăn một nửa cạnh, và vẫn quanh tâm cũ.
    test('phóng gấp đôi thì vùng cắt nhỏ đi một nửa mỗi cạnh', () {
      const source = Size(1000, 1000);
      const viewport = 400.0;
      final zoomed = ecAvatarInitialMatrix(source, viewport)
        ..scaleByDouble(2, 2, 1, 1);
      final rect = ecAvatarSourceRect(
        source: source,
        viewport: viewport,
        matrix: zoomed,
      );
      expect(rect.width, closeTo(500, 0.01));
      expect(rect.height, closeTo(500, 0.01));
    });

    // Kéo lệch hẳn ra ngoài mép: kết quả PHẢI bị kẹp lại trong lòng ảnh, nếu
    // không `drawImageRect` sẽ vẽ ra một dải trong suốt ở rìa ảnh đại diện.
    test('kéo quá biên vẫn cho vùng nằm trọn trong ảnh', () {
      const source = Size(1000, 1000);
      const viewport = 400.0;
      final dragged = ecAvatarInitialMatrix(source, viewport)
        ..translateByDouble(5000, 5000, 0, 1);
      final rect = ecAvatarSourceRect(
        source: source,
        viewport: viewport,
        matrix: dragged,
      );
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(source.width));
      expect(rect.bottom, lessThanOrEqualTo(source.height));
    });
  });

  group('ghi tệp đã cắt', () {
    test('đọc ảnh hỏng thì trả null, KHÔNG rơi về ảnh chưa cắt', () async {
      final path = await ecWriteCroppedAvatar(
        sourcePath: 'khong-quan-trong.jpg',
        sourceRect: const Rect.fromLTWH(0, 0, 100, 100),
        readBytes: (_) async => throw const FormatException('ảnh hỏng'),
        writeBytes: (_, _) async => 'khong-bao-gio-toi-day',
      );
      // Rơi về ảnh chưa cắt là gửi lên một tấm có thể vượt trần 2 MB, và người
      // dùng nhận một lỗi chẳng liên quan gì tới việc họ vừa làm.
      expect(path, isNull);
    });
  });
}

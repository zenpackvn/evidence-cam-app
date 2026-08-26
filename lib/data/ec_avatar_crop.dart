/// Cắt ảnh đại diện theo khung người dùng tự kéo — phần thuần tính toán.
///
/// Tách khỏi widget để thử được bằng unit test: mọi phép ở đây chỉ là hình học
/// trên `Size`/`Rect`/`Matrix4`, không chạm cây widget và không chạm đĩa (trừ
/// [ecWriteCroppedAvatar], hàm duy nhất có việc với tệp).
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' show MatrixUtils;
import 'package:flutter/widgets.dart' show Matrix4, Offset, Rect, Size;

/// Hệ số phóng để ảnh PHỦ KÍN khung vuông cạnh [viewport].
///
/// Lấy cạnh lớn hơn trong hai tỉ lệ, đúng nghĩa `BoxFit.cover`: cạnh ngắn của
/// ảnh vừa khít khung, cạnh dài tràn ra ngoài và chính là phần người dùng kéo
/// qua kéo lại.
double ecAvatarCoverScale(Size source, double viewport) => math.max(
  viewport / source.width,
  viewport / source.height,
);

/// Kích thước ảnh sau khi phủ kín khung.
Size ecAvatarCoverSize(Size source, double viewport) {
  final scale = ecAvatarCoverScale(source, viewport);
  return Size(source.width * scale, source.height * scale);
}

/// Ma trận khởi đầu: ảnh phủ kín khung và canh GIỮA.
///
/// Mở màn cắt ra phải thấy đúng khung mà thẻ ảnh đại diện đang vẽ (`BoxFit.
/// cover`, canh giữa). Bắt đầu ở một khung khác là ảnh nhảy một cái ngay khi
/// màn mở, và người dùng đọc đó là app tự ý đổi ảnh của họ.
Matrix4 ecAvatarInitialMatrix(Size source, double viewport) {
  final cover = ecAvatarCoverSize(source, viewport);
  return Matrix4.identity()..translateByDouble(
    (viewport - cover.width) / 2,
    (viewport - cover.height) / 2,
    0,
    1,
  );
}

/// Vùng của ảnh GỐC (đơn vị pixel nguồn) đang lọt trong khung cắt.
///
/// [matrix] là `TransformationController.value` của `InteractiveViewer`. Nó chỉ
/// mang tịnh tiến và phóng đều — không xoay, không lệch — nên nghịch đảo luôn
/// tồn tại và bốn góc khung chiếu ngược về vẫn là một hình chữ nhật thẳng.
///
/// Con của viewer được đặt đúng cỡ "phủ kín", nên toạ độ trong con bằng toạ độ
/// nguồn nhân [ecAvatarCoverScale] — chia lại là về pixel gốc.
///
/// Kết quả luôn được kẹp trong lòng ảnh: `InteractiveViewer` đã chặn kéo quá
/// biên, nhưng sai số dấu phẩy động vẫn đẩy ra ngoài được vài phần nghìn pixel,
/// và `drawImageRect` với vùng nguồn thò ra ngoài sẽ vẽ ra viền trong suốt.
Rect ecAvatarSourceRect({
  required Size source,
  required double viewport,
  required Matrix4 matrix,
}) {
  final inverse = Matrix4.inverted(matrix);
  final topLeft = MatrixUtils.transformPoint(inverse, Offset.zero);
  final bottomRight = MatrixUtils.transformPoint(
    inverse,
    Offset(viewport, viewport),
  );
  final scale = ecAvatarCoverScale(source, viewport);
  final rect = Rect.fromPoints(topLeft / scale, bottomRight / scale);
  return rect.intersect(Offset.zero & source);
}

/// Cắt [sourceRect] khỏi ảnh ở [sourcePath] và ghi ra một tệp PNG vuông.
///
/// Trả `null` khi giải mã hoặc mã hoá hỏng. KHÔNG rơi về ảnh chưa cắt: ảnh chưa
/// cắt có thể vượt trần 2 MB của `uploadAvatar`, và lúc đó người dùng vừa mất
/// công kéo khung vừa nhận một lỗi không liên quan.
///
/// [maxSide] chốt ở 512 vì chỗ to nhất app vẽ ảnh đại diện là 124 px — gấp bốn
/// lần đã thừa cho màn hình 3x, mà PNG vuông 512 chỉ chừng 200–400 KB.
Future<String?> ecWriteCroppedAvatar({
  required String sourcePath,
  required Rect sourceRect,
  required Future<Uint8List> Function(String path) readBytes,
  required Future<String> Function(String name, Uint8List bytes) writeBytes,
  int maxSide = 512,
}) async {
  ui.Image? decoded;
  ui.Image? cropped;
  try {
    final codec = await ui.instantiateImageCodec(await readBytes(sourcePath));
    decoded = (await codec.getNextFrame()).image;

    // Cạnh đầu ra không bao giờ PHÓNG TO phần đã cắt: kéo sát vào một góc nhỏ
    // rồi phóng lên 512 chỉ tạo ra một tấm mờ nặng hơn bản gốc của nó.
    final side = math.min(maxSide, sourceRect.shortestSide.round());
    if (side <= 0) return null;

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawImageRect(
      decoded,
      sourceRect,
      Rect.fromLTWH(0, 0, side.toDouble(), side.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
    cropped = await recorder.endRecording().toImage(side, side);

    final data = await cropped.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) return null;
    return writeBytes('avatar_crop.png', data.buffer.asUint8List());
  } on Object {
    return null;
  } finally {
    decoded?.dispose();
    cropped?.dispose();
  }
}

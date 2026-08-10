/// On-device barcode detection over the recording camera's image stream.
///
/// Converts each [CameraImage] to an MLKit [InputImage] and returns the first
/// non-empty barcode value. Frames are dropped while a previous frame is still
/// being processed, so the scanner never queues up behind the camera.
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:app_platform/app_platform.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// Ô ngắm trên màn hình, quy về đúng những gì cần để dựng lại nó trong toạ độ
/// khung hình camera.
///
/// [viewport] là vùng đang vẽ preview (điểm ảnh logic), [frame] là ô người
/// dùng nhìn thấy và phải đưa mã vào, cùng hệ toạ độ với [viewport].
///
/// Phải có cả hai chứ không phải mỗi tỉ lệ: preview vẽ bằng `BoxFit.cover` nên
/// khung hình bị cắt bớt trước khi lên màn, và bị cắt lệch nhau ở hai trục.
/// Lấy một tỉ lệ của bề rộng màn rồi áp thẳng vào bề rộng LẪN bề cao của khung
/// hình — cách cũ — cho ra một vùng nhận cao gấp đôi ô thật, và đó là lý do mã
/// nằm trên hoặc dưới ô vẫn được nhận.
class EcScanWindow {
  const EcScanWindow({required this.viewport, required this.frame});

  final Size viewport;
  final Rect frame;
}

class BillScanner {
  BillScanner() : _scanner = BarcodeScanner();

  final BarcodeScanner _scanner;
  bool _busy = false;

  /// Camera image format to request so frames convert cleanly to MLKit:
  /// NV21 on Android, BGRA8888 on iOS.
  static ImageFormatGroup get imageFormatGroup =>
      Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888;

  /// Returns the first barcode value found in [image], or `null` when there is
  /// none, the frame can't be converted, or a previous frame is still in flight.
  ///
  /// [deviceOrientation] is the phone's current physical orientation — the
  /// record screen now follows however it's held (see `ec_record_route.dart`),
  /// so the sensor orientation alone is no longer enough to compute the
  /// correct frame rotation for MLKit.
  ///
  /// [window], khi có, loại bỏ mã mà tâm của nó rơi ra ngoài ô ngắm trên màn.
  /// Màn nào vẽ ô ngắm thì phải truyền — người dùng đã được bảo "đưa mã vào
  /// khung", nhận một mã nằm ngoài khung là làm sai lời mình vừa dặn.
  Future<String?> scan(
    CameraImage image,
    CameraDescription camera, {
    DeviceOrientation deviceOrientation = DeviceOrientation.portraitUp,
    EcScanWindow? window,
  }) async {
    if (_busy) return null;
    _busy = true;
    try {
      final input = _toInputImage(image, camera, deviceOrientation);
      if (input == null) return null;
      final barcodes = await _scanner.processImage(input);
      final metadata = input.metadata;
      final gate = window != null && metadata != null;
      for (final barcode in barcodes) {
        final raw = barcode.rawValue?.trim();
        if (raw == null || raw.isEmpty) continue;
        if (gate &&
            !_isInFrame(barcode.boundingBox, image, metadata, window)) {
          continue;
        }
        return raw;
      }
      return null;
    } on Object {
      return null;
    } finally {
      _busy = false;
    }
  }

  /// Mã có nằm trong ô ngắm không.
  ///
  /// Đo bằng KHOẢNG CÁCH TỚI TÂM chứ không dựng lại ô ngắm thành một hình chữ
  /// nhật trong toạ độ khung hình, vì hai nền tảng trả toạ độ mã theo hai hệ
  /// khác nhau:
  ///
  /// * Android đưa `rotationDegrees` xuống MLKit nên hộp bao về theo đúng
  ///   hướng người dùng đang nhìn.
  /// * iOS thì KHÔNG: `MLKVisionImage+FlutterPlugin.m` dựng `UIImage` thẳng từ
  ///   bộ đệm và bỏ qua rotation trong metadata, nên hộp bao về theo hệ của bộ
  ///   đệm gốc — hai trục đảo so với màn hình khi máy xoay 90°/270°. Dựng ô
  ///   ngắm theo hướng nhìn rồi so với hộp bao theo hệ bộ đệm là gần như không
  ///   mã nào lọt, và triệu chứng đúng là "đưa vào khung mà không nhận".
  ///
  /// Ô ngắm ở cả hai màn đều căn giữa, nên khoảng cách tới tâm là đủ để tả nó,
  /// mà đại lượng ấy chỉ đổi chỗ hai trục khi xoay — xử lý được bằng một phép
  /// hoán vị thay vì cả một chuỗi phép biến đổi dễ sai.
  static bool _isInFrame(
    Rect box,
    CameraImage image,
    InputImageMetadata meta,
    EcScanWindow window,
  ) {
    final swap =
        meta.rotation == InputImageRotation.rotation90deg ||
        meta.rotation == InputImageRotation.rotation270deg;
    // Cỡ khung hình theo hướng NGƯỜI DÙNG NHÌN THẤY.
    final viewW = (swap ? image.height : image.width).toDouble();
    final viewH = (swap ? image.width : image.height).toDouble();
    // `BoxFit.cover` phóng bằng hệ số lớn hơn trong hai trục rồi cắt đều hai
    // bên trục còn lại; đảo lại phép đó là ra ô ngắm rộng bao nhiêu phần khung
    // hình.
    final scale = math.max(
      window.viewport.width / viewW,
      window.viewport.height / viewH,
    );
    if (!scale.isFinite || scale <= 0) return true;
    // Nới 10%: người quay được bảo "đưa mã vào khung", nên mã chạm mép khung
    // phải tính là trong khung. Chặt đúng từng điểm ảnh chỉ tạo ra những lượt
    // giơ đi giơ lại mà không hiểu vì sao máy không nhận.
    const slack = 1.1;
    final halfX = window.frame.width / scale / 2 / viewW * slack;
    final halfY = window.frame.height / scale / 2 / viewH * slack;
    final boxW = (Platform.isAndroid ? viewW : image.width.toDouble());
    final boxH = (Platform.isAndroid ? viewH : image.height.toDouble());
    if (boxW <= 0 || boxH <= 0) return true;
    final offX = (box.center.dx - boxW / 2).abs() / boxW;
    final offY = (box.center.dy - boxH / 2).abs() / boxH;
    // iOS + xoay 90°/270°: hai trục của bộ đệm đảo so với hướng nhìn.
    final transposed = !Platform.isAndroid && swap;
    return transposed
        ? offX <= halfY && offY <= halfX
        : offX <= halfX && offY <= halfY;
  }

  Future<void> dispose() => _scanner.close();

  InputImage? _toInputImage(
    CameraImage image,
    CameraDescription camera,
    DeviceOrientation deviceOrientation,
  ) {
    final rotation = InputImageRotationValue.fromRawValue(
      _rotationDegrees(camera, deviceOrientation),
    );
    final rawFormat = image.format.raw;
    if (rawFormat is! int) return null;
    final format = InputImageFormatValue.fromRawValue(rawFormat);
    if (rotation == null || format == null || image.planes.isEmpty) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  /// The rotation MLKit needs to read the frame upright, combining the
  /// camera's fixed sensor mounting with how the phone is held right now —
  /// the standard MLKit `camera` example formula.
  static int _rotationDegrees(
    CameraDescription camera,
    DeviceOrientation deviceOrientation,
  ) {
    const angleByOrientation = {
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };
    final deviceAngle = angleByOrientation[deviceOrientation] ?? 0;
    return camera.lensDirection == CameraLensDirection.front
        ? (camera.sensorOrientation + deviceAngle) % 360
        : (camera.sensorOrientation - deviceAngle + 360) % 360;
  }
}

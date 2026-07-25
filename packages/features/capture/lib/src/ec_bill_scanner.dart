/// On-device barcode detection over the recording camera's image stream.
///
/// Converts each [CameraImage] to an MLKit [InputImage] and returns the first
/// non-empty barcode value. Frames are dropped while a previous frame is still
/// being processed, so the scanner never queues up behind the camera.
library;

import 'dart:io';
import 'dart:ui' show Size;

import 'package:app_platform/app_platform.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

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
  Future<String?> scan(CameraImage image, CameraDescription camera) async {
    if (_busy) return null;
    _busy = true;
    try {
      final input = _toInputImage(image, camera);
      if (input == null) return null;
      final barcodes = await _scanner.processImage(input);
      for (final barcode in barcodes) {
        final raw = barcode.rawValue?.trim();
        if (raw != null && raw.isNotEmpty) return raw;
      }
      return null;
    } on Object {
      return null;
    } finally {
      _busy = false;
    }
  }

  Future<void> dispose() => _scanner.close();

  InputImage? _toInputImage(CameraImage image, CameraDescription camera) {
    // ponytail: use the sensor orientation directly — correct for the fixed
    // portrait "camera looks down at the packing table" UI. Add full
    // device-orientation mapping only if landscape recording is ever needed.
    final rotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
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
}

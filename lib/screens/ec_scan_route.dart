/// Full-screen barcode/QR scanner used from the order-search bar (FR-04).
///
/// Opens the back camera, streams frames to `BillScanner`, and returns the
/// first tracking code found via `onDetected`. Falls back to a message when no
/// camera is available (e.g. iOS Simulator) so the caller can type the code.
library;

import 'dart:async';

import 'package:app_platform/app_platform.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation;

class EcBarcodeScanRoute extends StatefulWidget {
  const EcBarcodeScanRoute({
    required this.onDetected,
    this.onCancel,
    this.camera,
    super.key,
  });

  /// Called once with the first scanned code; the caller pops the route.
  final ValueChanged<String> onDetected;

  /// Called when the user taps the close button.
  final VoidCallback? onCancel;

  /// Injectable camera wrapper for tests; production uses [CameraService].
  @visibleForTesting
  final CameraService? camera;

  @override
  State<EcBarcodeScanRoute> createState() => _EcBarcodeScanRouteState();
}

class _EcBarcodeScanRouteState extends State<EcBarcodeScanRoute> {
  late final CameraService _camera = widget.camera ?? CameraService();
  final BillScanner _scanner = BillScanner();

  bool _initializing = true;
  bool _done = false;
  String? _error;
  List<CameraDescription> _cameras = const [];
  int _index = 0;
  int _frameCount = 0;

  /// Side length of the square scan frame, in logical pixels.
  static const _frameSize = 260.0;

  /// Screen width as of the last build — used to translate [_frameSize] into
  /// the fraction of the camera frame [BillScanner] should require a code's
  /// center to fall within. Set from `build()`, since `_onFrame` (the image
  /// stream callback) has no `BuildContext` of its own.
  double _screenWidth = 1;

  /// Góc phải xoay texture camera để khung ngắm đứng đúng.
  ///
  /// Cùng lý do và cùng nguồn số với màn quay: trên Android, khung hình tới
  /// Flutter theo hướng nào là tuỳ đường đi trong CameraX của máy đó, nên phải
  /// HỎI chứ không chốt cứng (xem [ecPreviewQuarterTurns]). `null` = chưa có
  /// câu trả lời, lúc đó chưa vẽ lớp camera.
  int? _previewQuarterTurns;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void dispose() {
    unawaited(_scanner.dispose());
    unawaited(_camera.dispose());
    super.dispose();
  }

  Future<void> _setup() async {
    try {
      final cameras = await _camera.getAvailableCameras();
      if (cameras.isEmpty) {
        _fail('Thiết bị không có camera — hãy nhập mã bằng tay.');
        return;
      }
      var index = cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (index < 0) index = 0;
      await _camera.initialize(
        description: cameras[index],
        resolutionPreset: ResolutionPreset.medium,
        imageFormatGroup: BillScanner.imageFormatGroup,
      );
      if (!mounted) {
        unawaited(_camera.dispose());
        return;
      }
      final turns = await ecPreviewQuarterTurns(cameras[index]);
      if (!mounted) {
        unawaited(_camera.dispose());
        return;
      }
      setState(() {
        _cameras = cameras;
        _index = index;
        _previewQuarterTurns = turns;
        _initializing = false;
      });
      await _camera.controller?.startImageStream(_onFrame);
    } on Object catch (e) {
      _fail('Không mở được camera: $e');
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_done || _cameras.isEmpty) return;
    // ponytail: skip every other frame to throttle ML detection (30fps → 15fps)
    _frameCount++;
    if (_frameCount % 2 != 0) return;
    // A 1D barcode's scan line has to roughly line up with the bars — unlike
    // a QR code's finder patterns, which read fine at any rotation — so this
    // needs the phone's live orientation, not a fixed portraitUp assumption.
    final code = await _scanner.scan(
      image,
      _cameras[_index],
      deviceOrientation:
          _camera.controller?.value.deviceOrientation ??
          DeviceOrientation.portraitUp,
      centerRegionFraction: _frameSize / _screenWidth,
    );
    if (code == null || _done || !mounted) return;
    _done = true;
    widget.onDetected(code);
  }

  void _fail(String message) {
    if (mounted) {
      setState(() {
        _error = message;
        _initializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _camera.controller;
    final quarterTurns = _previewQuarterTurns;
    final ready =
        !_initializing &&
        controller != null &&
        quarterTurns != null &&
        _error == null;
    _screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (ready)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.previewSize?.height ?? 1,
                  height: controller.value.previewSize?.width ?? 1,
                  // Texture TRẦN + một góc chốt sẵn, KHÔNG dùng `CameraPreview`.
                  //
                  // `CameraPreview` tự xoay khung theo cảm biến, và phép xoay
                  // ấy chốt từ lúc dựng camera nên không biết đường đi khung
                  // hình đã đổi — kết quả là nó xoay thêm một lần nữa lên khung
                  // vốn đã đứng, và khung ngắm nằm ngang. Xoay bằng con số hỏi
                  // được từ chính pipeline thì đúng ở mọi đường đi.
                  child: RotatedBox(
                    quarterTurns: quarterTurns,
                    child: Texture(textureId: controller.cameraId),
                  ),
                ),
              ),
            ),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            )
          else ...[
            // Dims everything outside the center square so it's visually
            // clear that only a code inside the frame will be accepted —
            // matches the center-region gate passed to BillScanner.scan.
            const Positioned.fill(
              child: CustomPaint(
                painter: _ScanMaskPainter(frameSize: _frameSize),
              ),
            ),
            Center(
              child: Container(
                width: _frameSize,
                height: _frameSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 64,
              child: Center(
                child: Text(
                  'Đưa mã vận đơn vào khung',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: widget.onCancel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a translucent overlay covering the full scan screen except for a
/// centered square hole, so only the framed area reads as "active".
class _ScanMaskPainter extends CustomPainter {
  const _ScanMaskPainter({required this.frameSize});

  final double frameSize;

  @override
  void paint(Canvas canvas, Size size) {
    final hole = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: frameSize,
      height: frameSize,
    );
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(hole, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: 0.6));
  }

  @override
  bool shouldRepaint(covariant _ScanMaskPainter oldDelegate) =>
      oldDelegate.frameSize != frameSize;
}

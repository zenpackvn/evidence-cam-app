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
        resolutionPreset: ResolutionPreset.high,
        imageFormatGroup: BillScanner.imageFormatGroup,
      );
      if (!mounted) {
        unawaited(_camera.dispose());
        return;
      }
      setState(() {
        _cameras = cameras;
        _index = index;
        _initializing = false;
      });
      await _camera.controller?.startImageStream(_onFrame);
    } on Object catch (e) {
      _fail('Không mở được camera: $e');
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_done || _cameras.isEmpty) return;
    final code = await _scanner.scan(image, _cameras[_index]);
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
    final ready = !_initializing && controller != null && _error == null;
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
                  child: CameraPreview(controller),
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
          else
            const Align(
              alignment: Alignment(0, 0.4),
              child: Text(
                'Đưa mã vận đơn vào khung',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
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

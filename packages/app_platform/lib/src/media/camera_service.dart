import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:injectable/injectable.dart';

typedef AvailableCamerasLoader = Future<List<CameraDescription>> Function();
typedef CameraControllerFactory =
    CameraController Function({
      required CameraDescription description,
      required ResolutionPreset resolutionPreset,
      bool enableAudio,
      ImageFormatGroup? imageFormatGroup,
    });

/// Exception thrown when a camera operation is attempted before the camera is initialized.
class CameraNotInitializedException implements Exception {
  CameraNotInitializedException([this.message = 'Camera is not initialized.']);

  final String message;

  @override
  String toString() => 'CameraNotInitializedException: $message';
}

/// App-level wrapper around the `camera` package.
///
/// Encapsulates camera initialization, lifecycle management, photo/video capture,
/// and camera configuration settings (flash, zoom, stabilization).
@lazySingleton
class CameraService {
  CameraService()
    : this.custom(
        availableCameras,
        ({
          required description,
          required resolutionPreset,
          enableAudio = true,
          imageFormatGroup,
        }) => CameraController(
          description,
          resolutionPreset,
          enableAudio: enableAudio,
          imageFormatGroup: imageFormatGroup,
        ),
      );

  @visibleForTesting
  CameraService.custom(
    this._availableCameras,
    this._controllerFactory,
  );

  final AvailableCamerasLoader _availableCameras;
  final CameraControllerFactory _controllerFactory;

  CameraController? _controller;

  /// Exposes the active [CameraController] instance.
  ///
  /// Returns `null` if the camera is not initialized.
  CameraController? get controller => _controller;

  /// Returns whether the camera controller exists and is fully initialized.
  bool get isInitialized =>
      _controller != null && _controller!.value.isInitialized;

  /// Returns whether the camera is currently recording video.
  bool get isRecordingVideo =>
      _controller != null && _controller!.value.isRecordingVideo;

  /// Whether the camera is currently streaming image frames (for scanning).
  bool get isStreamingImages =>
      _controller != null && _controller!.value.isStreamingImages;

  /// Starts streaming camera frames to [onAvailable] for on-device scanning.
  ///
  /// Throws a [CameraNotInitializedException] if the controller is not
  /// initialized.
  Future<void> startImageStream(onLatestImageAvailable onAvailable) async {
    final activeController = _ensureInitialized();
    await activeController.startImageStream(onAvailable);
  }

  /// Stops the idle frame stream. No-op when not currently streaming.
  Future<void> stopImageStream() async {
    final activeController = _controller;
    if (activeController != null && activeController.value.isStreamingImages) {
      await activeController.stopImageStream();
    }
  }

  /// Retrieves a list of available cameras on the device.
  Future<List<CameraDescription>> getAvailableCameras() {
    return _availableCameras();
  }

  /// Initializes a camera with the specified [description] and [resolutionPreset].
  ///
  /// If a controller was previously active, it will be automatically disposed.
  Future<void> initialize({
    required CameraDescription description,
    ResolutionPreset resolutionPreset = ResolutionPreset.medium,
    bool enableAudio = true,
    ImageFormatGroup? imageFormatGroup,
  }) async {
    await dispose();

    final controller = _controllerFactory(
      description: description,
      resolutionPreset: resolutionPreset,
      enableAudio: enableAudio,
      imageFormatGroup: imageFormatGroup,
    );

    _controller = controller;
    await controller.initialize();
  }

  /// Disposes of the active [CameraController], releasing the camera hardware resource.
  ///
  /// The field is cleared *before* awaiting `dispose()`: the await yields, and
  /// a widget rebuild landing in that window would otherwise still read a
  /// disposed controller off [controller] and blow up inside
  /// `CameraPreview.buildPreview()`. Clearing first makes the getter report
  /// "no camera" for the whole teardown, which callers already handle.
  Future<void> dispose() async {
    final controller = _controller;
    if (controller != null) {
      _controller = null;
      await controller.dispose();
    }
  }

  /// Captures an image and returns the resulting [XFile].
  ///
  /// Throws a [CameraNotInitializedException] if the controller is not initialized.
  Future<XFile> takePicture() async {
    final activeController = _ensureInitialized();
    return activeController.takePicture();
  }

  /// Starts video recording.
  ///
  /// Pass [onAvailable] to also receive camera frames while recording (the
  /// plugin streams them alongside the clip on iOS and CameraX-capable Android
  /// devices) — used for hands-free bill detection mid-recording. Throws a
  /// [CameraNotInitializedException] if the controller is not initialized; may
  /// throw on Android hardware that can't stream and record concurrently, in
  /// which case the caller should retry without [onAvailable].
  Future<void> startVideoRecording({
    onLatestImageAvailable? onAvailable,
  }) async {
    final activeController = _ensureInitialized();
    await activeController.startVideoRecording(onAvailable: onAvailable);
  }

  /// Stops the current video recording and returns the captured [XFile].
  ///
  /// Throws a [CameraNotInitializedException] if the controller is not initialized.
  Future<XFile> stopVideoRecording() async {
    final activeController = _ensureInitialized();
    return activeController.stopVideoRecording();
  }

  /// Pauses the current video recording.
  ///
  /// Throws a [CameraNotInitializedException] if the controller is not initialized.
  Future<void> pauseVideoRecording() async {
    final activeController = _ensureInitialized();
    await activeController.pauseVideoRecording();
  }

  /// Resumes the current video recording.
  ///
  /// Throws a [CameraNotInitializedException] if the controller is not initialized.
  Future<void> resumeVideoRecording() async {
    final activeController = _ensureInitialized();
    await activeController.resumeVideoRecording();
  }

  /// Updates the camera flash mode.
  ///
  /// Throws a [CameraNotInitializedException] if the controller is not initialized.
  Future<void> setFlashMode(FlashMode mode) async {
    final activeController = _ensureInitialized();
    await activeController.setFlashMode(mode);
  }

  /// Updates the camera zoom level.
  ///
  /// Throws a [CameraNotInitializedException] if the controller is not initialized.
  Future<void> setZoomLevel(double zoom) async {
    final activeController = _ensureInitialized();
    await activeController.setZoomLevel(zoom);
  }

  /// Retrieves the minimum zoom level supported by the camera hardware.
  ///
  /// Throws a [CameraNotInitializedException] if the controller is not initialized.
  Future<double> getMinZoomLevel() async {
    final activeController = _ensureInitialized();
    return activeController.getMinZoomLevel();
  }

  /// Retrieves the maximum zoom level supported by the camera hardware.
  ///
  /// Throws a [CameraNotInitializedException] if the controller is not initialized.
  Future<double> getMaxZoomLevel() async {
    final activeController = _ensureInitialized();
    return activeController.getMaxZoomLevel();
  }

  /// Configures exposure mode.
  ///
  /// Throws a [CameraNotInitializedException] if the controller is not initialized.
  Future<void> setExposureMode(ExposureMode mode) async {
    final activeController = _ensureInitialized();
    await activeController.setExposureMode(mode);
  }

  /// Sets exposure offset.
  ///
  /// Throws a [CameraNotInitializedException] if the controller is not initialized.
  Future<void> setExposureOffset(double offset) async {
    final activeController = _ensureInitialized();
    await activeController.setExposureOffset(offset);
  }

  /// Configures focus mode.
  ///
  /// Throws a [CameraNotInitializedException] if the controller is not initialized.
  Future<void> setFocusMode(FocusMode mode) async {
    final activeController = _ensureInitialized();
    await activeController.setFocusMode(mode);
  }

  /// Sets video stabilization mode (added in camera version 0.12.0).
  ///
  /// Throws a [CameraNotInitializedException] if the controller is not initialized.
  Future<void> setVideoStabilizationMode(VideoStabilizationMode mode) async {
    final activeController = _ensureInitialized();
    await activeController.setVideoStabilizationMode(mode);
  }

  /// Pins the capture orientation to [orientation] regardless of the live
  /// sensor reading.
  ///
  /// This matters beyond the recorded file's rotation: `CameraController`
  /// computes `recordingOrientation` — what `CameraPreview` rotates by while
  /// `isRecordingVideo` is true — from `lockedCaptureOrientation` if set,
  /// otherwise from the current `deviceOrientation` at the exact instant
  /// `startVideoRecording()` is called. A phone resting flat gives a noisy,
  /// sometimes-landscape sensor reading at that instant, so an unlocked
  /// camera can visibly snap to landscape right as recording starts even
  /// though it was sitting still. Locking beforehand removes the sensor from
  /// that decision entirely.
  ///
  /// Throws a [CameraNotInitializedException] if the controller is not initialized.
  Future<void> lockCaptureOrientation(DeviceOrientation orientation) async {
    final activeController = _ensureInitialized();
    await activeController.lockCaptureOrientation(orientation);
  }

  CameraController _ensureInitialized() {
    final activeController = _controller;
    if (activeController == null || !activeController.value.isInitialized) {
      throw CameraNotInitializedException();
    }
    return activeController;
  }
}

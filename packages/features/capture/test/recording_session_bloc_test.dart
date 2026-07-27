import 'package:app_platform/app_platform.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeCamera camera;
  late List<String> saved;

  setUp(() {
    camera = _FakeCamera();
    saved = <String>[];
  });

  RecordingSessionBloc build({
    Duration maxRecording = const Duration(minutes: 15),
  }) {
    return RecordingSessionBloc(
      camera: camera,
      scanner: _FakeScanner(),
      onClipSaved: (path, tracking, type) => saved.add(path),
      maxRecording: maxRecording,
    );
  }

  // Adds init, lets it settle, then runs [more].
  Future<void> Function(RecordingSessionBloc) initThen(
    void Function(RecordingSessionBloc) more,
  ) => (bloc) async {
    bloc.add(const RecordingInitRequested());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    more(bloc);
  };

  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'opens the camera and goes idle',
    build: build,
    act: (bloc) => bloc.add(const RecordingInitRequested()),
    wait: const Duration(milliseconds: 40),
    verify: (bloc) {
      expect(bloc.state.status, RecordingStatus.idle);
      expect(bloc.state.cameraCount, 1);
    },
  );

  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'goes to error when the device has no camera',
    build: () => RecordingSessionBloc(
      camera: _FakeCamera(cameras: const []),
      scanner: _FakeScanner(),
      onClipSaved: (_, _, _) {},
    ),
    act: (bloc) => bloc.add(const RecordingInitRequested()),
    wait: const Duration(milliseconds: 40),
    verify: (bloc) {
      expect(bloc.state.status, RecordingStatus.error);
      expect(bloc.state.errorMessage, isNotNull);
    },
  );

  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'a manual code starts recording that order',
    build: build,
    act: initThen((b) => b.add(const RecordingManualCodeSubmitted('SPX1'))),
    wait: const Duration(milliseconds: 40),
    verify: (bloc) {
      // bloc_test closes the bloc (disposing the camera) before verify, so the
      // final state — not the live camera flag — is what proves recording began.
      expect(bloc.state.status, RecordingStatus.recording);
      expect(bloc.state.code, 'SPX1');
      expect(saved, isEmpty);
    },
  );

  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'stop finalizes the clip and returns to idle',
    build: build,
    act: (bloc) async {
      bloc.add(const RecordingInitRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const RecordingManualCodeSubmitted('SPX1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const RecordingStopRequested());
    },
    wait: const Duration(milliseconds: 40),
    verify: (bloc) {
      expect(bloc.state.status, RecordingStatus.idle);
      expect(saved, hasLength(1));
      expect(camera.stopCount, 1);
    },
  );

  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'a different bill mid-clip cuts over to the new order (SC-2)',
    build: build,
    act: (bloc) async {
      bloc.add(const RecordingInitRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const RecordingManualCodeSubmitted('A'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const RecordingFrameScanned('B'));
    },
    wait: const Duration(milliseconds: 40),
    verify: (bloc) {
      expect(bloc.state.status, RecordingStatus.recording);
      expect(bloc.state.code, 'B');
      // The first clip (order A) was saved; B is still recording.
      expect(saved, hasLength(1));
      expect(camera.stopCount, 1);
    },
  );

  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'the end-QR finalizes the clip and returns to idle',
    build: build,
    act: (bloc) async {
      bloc.add(const RecordingInitRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const RecordingManualCodeSubmitted('A'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const RecordingFrameScanned(kEndSessionQr));
    },
    wait: const Duration(milliseconds: 40),
    verify: (bloc) {
      expect(bloc.state.status, RecordingStatus.idle);
      expect(saved, hasLength(1));
    },
  );

  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'the hard cap auto-closes the clip',
    build: () => build(maxRecording: const Duration(seconds: 2)),
    act: (bloc) async {
      bloc.add(const RecordingInitRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const RecordingManualCodeSubmitted('A'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc
        ..add(const RecordingTicked())
        ..add(const RecordingTicked());
    },
    wait: const Duration(milliseconds: 60),
    verify: (bloc) {
      expect(bloc.state.status, RecordingStatus.idle);
      expect(saved, hasLength(1));
    },
  );

  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'backgrounding finalizes the in-progress clip then releases the camera',
    build: build,
    act: (bloc) async {
      bloc.add(const RecordingInitRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const RecordingManualCodeSubmitted('A'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const RecordingBackgrounded());
    },
    wait: const Duration(milliseconds: 40),
    verify: (bloc) {
      // The in-progress clip was finalized (stopped + saved) on background,
      // before the camera was released (FR-08/FR-09).
      expect(saved, hasLength(1));
      expect(camera.stopCount, 1);
    },
  );

  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'falls back to plain recording when the hardware rejects stream+record',
    build: () => RecordingSessionBloc(
      camera: _FakeCamera()..failStartWithScan = true,
      scanner: _FakeScanner(),
      onClipSaved: (_, _, _) {},
    ),
    act: initThen((b) => b.add(const RecordingManualCodeSubmitted('A'))),
    wait: const Duration(milliseconds: 40),
    verify: (bloc) => expect(bloc.state.status, RecordingStatus.recording),
  );

  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'changing the video type updates the label',
    build: build,
    act: initThen((b) => b.add(const RecordingTypeChanged('Trả hàng'))),
    wait: const Duration(milliseconds: 40),
    verify: (bloc) => expect(bloc.state.typeLabel, 'Trả hàng'),
  );

  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'ignores video type changes while recording',
    build: build,
    act: (bloc) async {
      bloc.add(const RecordingInitRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const RecordingManualCodeSubmitted('SPX1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const RecordingTypeChanged('Trả hàng'));
    },
    wait: const Duration(milliseconds: 40),
    verify: (bloc) => expect(bloc.state.typeLabel, 'Đóng hàng'),
  );
}

/// A [CameraService] with no hardware — tracks recording/streaming/dispose so
/// the bloc's state machine can be driven deterministically.
class _FakeCamera extends CameraService {
  _FakeCamera({this.cameras = const [_back]})
    : super.custom(
        () async => cameras,
        ({
          required description,
          required resolutionPreset,
          enableAudio = true,
          imageFormatGroup,
        }) => throw UnimplementedError(),
      );

  static const _back = CameraDescription(
    name: 'back',
    lensDirection: CameraLensDirection.back,
    sensorOrientation: 90,
  );

  final List<CameraDescription> cameras;
  bool _initialized = false;
  bool recording = false;
  bool streaming = false;
  bool disposed = false;
  int stopCount = 0;

  /// When true, `startVideoRecording(onAvailable: ...)` throws (as some Android
  /// hardware does), so the bloc must retry without the frame stream.
  bool failStartWithScan = false;

  @override
  Future<List<CameraDescription>> getAvailableCameras() async => cameras;

  @override
  Future<void> initialize({
    required CameraDescription description,
    ResolutionPreset resolutionPreset = ResolutionPreset.medium,
    bool enableAudio = true,
    ImageFormatGroup? imageFormatGroup,
  }) async {
    _initialized = true;
    disposed = false;
  }

  @override
  bool get isInitialized => _initialized && !disposed;

  @override
  bool get isRecordingVideo => recording;

  @override
  bool get isStreamingImages => streaming;

  @override
  Future<void> startImageStream(onLatestImageAvailable onAvailable) async {
    streaming = true;
  }

  @override
  Future<void> stopImageStream() async {
    streaming = false;
  }

  @override
  Future<void> startVideoRecording({
    onLatestImageAvailable? onAvailable,
  }) async {
    if (onAvailable != null && failStartWithScan) {
      throw Exception('no concurrent stream+record');
    }
    recording = true;
    streaming = false;
  }

  @override
  Future<XFile> stopVideoRecording() async {
    recording = false;
    stopCount++;
    return XFile('/tmp/clip$stopCount.mp4');
  }

  @override
  Future<double> getMinZoomLevel() async => 1;

  @override
  Future<double> getMaxZoomLevel() async => 4;

  @override
  Future<void> setZoomLevel(double zoom) async {}

  @override
  Future<void> dispose() async {
    disposed = true;
    recording = false;
    streaming = false;
  }
}

/// A [BillScanner] that never touches MLKit — the bloc tests drive events
/// directly, so scanning is never invoked; only clean disposal matters.
class _FakeScanner extends BillScanner {
  @override
  Future<void> dispose() async {}
}

import 'package:app_platform/app_platform.dart';
import 'package:evidence_cam/screens/ec_record_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

void main() {
  testWidgets(
    'degrades to the idle screen when no camera is available',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EcRecordRoute(),
        ),
      );
      // The test environment has no camera plugin, so setup fails; let the
      // async failure land in the error/idle state.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // No exception escaped, and the idle "wait for bill" screen is shown
      // (recording never started).
      expect(tester.takeException(), isNull);
      expect(find.text('Đưa bill vào khung để bắt đầu'), findsOneWidget);
    },
  );

  testWidgets(
    'saves the in-progress clip when the app is backgrounded (FR-08/FR-09)',
    (tester) async {
      final camera = _FakeRecordingCamera();
      String? savedPath;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EcRecordRoute(
            camera: camera,
            onSaved: (path, tracking, type, durationSeconds) =>
                savedPath = path,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // App goes to the background while a recording is in progress.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The clip was finalized and handed off (to the upload queue) rather than
      // dropped, and only then was the camera released.
      expect(savedPath, '/tmp/clip.mp4');
      expect(camera.stopped, isTrue);
      expect(camera.disposed, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'does not start recording when manual code creation is rejected',
    (tester) async {
      final camera = _FakeRecordingCamera(initiallyRecording: false);
      var requested = false;
      var saved = false;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EcRecordRoute(
            camera: camera,
            onRequestCode: () async => 'SPXVN999',
            onConfirmManualCode: (code) async {
              requested = code == 'SPXVN999';
              return false;
            },
            onSaved: (_, _, _, _) => saved = true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byTooltip('Nhập mã vận đơn'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(requested, isTrue);
      expect(camera.started, isFalse);
      expect(saved, isFalse);
      expect(find.text('Đưa bill vào khung để bắt đầu'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('finalizes the in-progress clip before leaving record', (
    tester,
  ) async {
    final camera = _FakeRecordingCamera(initiallyRecording: false);
    var left = false;
    String? savedPath;
    String? savedTracking;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EcRecordRoute(
          camera: camera,
          onRequestCode: () async => 'SPXVN001',
          onBack: () => left = true,
          onSaved: (path, tracking, _, _) {
            savedPath = path;
            savedTracking = tracking;
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byTooltip('Nhập mã vận đơn'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('REC'), findsOneWidget);

    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(left, isTrue);
    expect(savedPath, '/tmp/clip.mp4');
    expect(savedTracking, 'SPXVN001');
    expect(camera.stopped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not open the type picker while recording', (tester) async {
    final camera = _FakeRecordingCamera(initiallyRecording: false);
    var typeRequests = 0;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EcRecordRoute(
          camera: camera,
          onRequestCode: () async => 'SPXVN001',
          onRequestType: () async {
            typeRequests++;
            return 'Trả hàng';
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byTooltip('Nhập mã vận đơn'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byTooltip('Cài đặt loại video'), findsNothing);
    expect(find.byTooltip('Nhập mã vận đơn'), findsNothing);
    expect(typeRequests, 0);
    expect(find.text('Đóng hàng'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

/// A [CameraService] that pretends to be mid-recording without any hardware.
/// [controller] stays null, so the route renders its loading preview — enough
/// to exercise the background-save path.
class _FakeRecordingCamera extends CameraService {
  _FakeRecordingCamera({this.initiallyRecording = true})
    : super.custom(
        () async => const <CameraDescription>[_desc],
        ({
          required description,
          required resolutionPreset,
          enableAudio = true,
          imageFormatGroup,
        }) => throw UnimplementedError(),
      );

  static const _desc = CameraDescription(
    name: 'fake',
    lensDirection: CameraLensDirection.back,
    sensorOrientation: 0,
  );

  bool stopped = false;
  bool started = false;
  bool disposed = false;
  final bool initiallyRecording;

  @override
  Future<List<CameraDescription>> getAvailableCameras() async => const [_desc];

  @override
  Future<void> initialize({
    required CameraDescription description,
    ResolutionPreset resolutionPreset = ResolutionPreset.medium,
    bool enableAudio = true,
    ImageFormatGroup? imageFormatGroup,
  }) async {}

  @override
  CameraController? get controller => null;

  @override
  bool get isInitialized => !disposed;

  @override
  bool get isRecordingVideo =>
      (started || initiallyRecording) && !stopped && !disposed;

  @override
  Future<double> getMinZoomLevel() async => 1;

  @override
  Future<double> getMaxZoomLevel() async => 1;

  @override
  Future<void> startVideoRecording({
    onLatestImageAvailable? onAvailable,
  }) async {
    started = true;
  }

  @override
  Future<XFile> stopVideoRecording() async {
    stopped = true;
    return XFile('/tmp/clip.mp4');
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

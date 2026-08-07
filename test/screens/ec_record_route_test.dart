import 'package:app_platform/app_platform.dart';
import 'package:evidence_cam/screens/ec_record_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

void main() {
  // `RecordingSessionBloc` hỏi dung lượng trống khi dựng camera; kênh
  // `disk_space_plus` không có bản cài trong test nên lời gọi treo, khoá luôn
  // mutex camera của bloc. Trả sẵn một con số để init chạy tới nơi.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('disk_space_plus'),
          (call) async => 4096.0,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('disk_space_plus'),
          null,
        );
  });

  // NGUYÊN TẮC BẤT DI BẤT DỊCH: hệ thống không bao giờ từ chối ghi hình.
  //
  // Hạn mức chặn ở ranh giới UPLOAD (backend trả 403 lúc xin presign), không
  // phải ở ranh giới ghi hình. Clip vẫn được quay và nằm lại hàng đợi trên máy.
  // Test này là hàng rào: cắm lại một cái gate quota vào màn quay là test đỏ.
  testWidgets('màn quay KHÔNG có hàng rào hạn mức nào', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EcRecordRoute(onRequestType: _picksType),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Đã hết hạn mức video'), findsNothing);
  });

  testWidgets(
    'degrades to the idle screen when no camera is available',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EcRecordRoute(onRequestType: _picksType),
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
            onSaved: (path, tracking, type, durationSeconds, _, _) =>
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
            onRequestType: _picksType,
            onConfirmManualCode: (code) async {
              requested = code == 'SPXVN999';
              return false;
            },
            onSaved: (_, _, _, _, _, _) => saved = true,
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
          onRequestType: _picksType,
          onBack: () => left = true,
          onSaved: (path, tracking, _, _, _, _) {
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

  // Rời tab rồi vào lại là một lượt quay mới: phải hỏi loại video lần nữa thay
  // vì im lặng dùng lại loại của lượt trước.
  testWidgets('re-entering the record tab asks for the type again', (
    tester,
  ) async {
    final camera = _FakeRecordingCamera(initiallyRecording: false);
    final active = ValueNotifier(true);
    addTearDown(active.dispose);
    var typeRequests = 0;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EcRecordRoute(
          camera: camera,
          isActive: active,
          onRequestType: (_, {mandatory = false}) async {
            typeRequests++;
            return 'Trả hàng';
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(typeRequests, 1);

    active.value = false;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    active.value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(typeRequests, 2);
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
          onRequestType: (_, {mandatory = false}) async {
            typeRequests++;
            return 'Đóng hàng';
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Lần hỏi bắt buộc lúc vào màn là đường duy nhất camera lên được; mốc so
    // sánh là con số sau nó, không phải 0.
    final afterEntry = typeRequests;

    await tester.tap(find.byTooltip('Nhập mã vận đơn'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byTooltip('Cài đặt loại video'), findsNothing);
    expect(find.byTooltip('Nhập mã vận đơn'), findsNothing);
    expect(typeRequests, afterEntry);
    expect(find.text('Đóng hàng'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Apple rejected the old flow for shoving the user into Settings the moment
  // they tapped "Don't Allow". These three pin the replacement down.
  testWidgets('explains before asking, and only asks on Tiếp tục', (
    tester,
  ) async {
    var requests = 0;
    var typeRequests = 0;
    final permissions = _permissions(
      status: PermissionStatus.denied,
      onRequest: () {
        requests++;
        return PermissionStatus.granted;
      },
    );

    await tester.pumpWidget(
      _hostingRecordRoute(
        EcRecordRoute(
          permissions: permissions,
          camera: _FakeRecordingCamera(initiallyRecording: false),
          onRequestType: (_, {mandatory = false}) async {
            typeRequests++;
            return null;
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Nothing was asked yet — the OS prompt waits behind the explanation, and
    // the type sheet stays shut until the camera is actually usable.
    expect(requests, 0);
    expect(typeRequests, 0);
    expect(find.text('Cần quyền camera'), findsOneWidget);

    await tester.tap(find.text('Tiếp tục'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(requests, 1);
    expect(find.text('Cần quyền camera'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a fresh denial keeps the user in the app, no Settings', (
    tester,
  ) async {
    var settingsOpened = 0;
    final permissions = _permissions(
      status: PermissionStatus.denied,
      onRequest: () => PermissionStatus.permanentlyDenied,
      onOpenSettings: () => settingsOpened++,
    );

    await tester.pumpWidget(
      _hostingRecordRoute(EcRecordRoute(permissions: permissions)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Tiếp tục'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Chưa thể quay video'), findsOneWidget);
    expect(find.text('Để sau'), findsOneWidget);
    // The two things Apple objected to: no jump to Settings, and no invitation
    // to go there in the same breath as the refusal.
    expect(settingsOpened, 0);
    expect(find.text('Mở Cài đặt'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('coming back to the tab is what offers Settings', (tester) async {
    var settingsOpened = 0;
    final permissions = _permissions(
      status: PermissionStatus.permanentlyDenied,
      onRequest: () => PermissionStatus.permanentlyDenied,
      onOpenSettings: () => settingsOpened++,
    );

    await tester.pumpWidget(
      _hostingRecordRoute(EcRecordRoute(permissions: permissions)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Already refused for good: re-asking would be a no-op, so the screen goes
    // straight to the blocked state — and now Settings is on offer, on tap.
    expect(find.text('Chưa thể quay video'), findsOneWidget);
    expect(settingsOpened, 0);
    await tester.tap(find.text('Mở Cài đặt'));
    await tester.pump();
    expect(settingsOpened, 1);
    expect(tester.takeException(), isNull);
  });
}

/// Chọn một loại video ngay khi sheet bắt buộc bật lên lúc vào màn.
///
/// Camera chỉ dựng sau khi loại đã được chọn thật, nên test nào cần tới khung
/// ngắm đều phải trả về một loại — bỏ qua sheet là ở lại màn chờ.
Future<String?> _picksType(BuildContext _, {bool mandatory = false}) async =>
    'Đóng hàng';

/// Wraps a route in the minimum app scaffolding its Vietnamese copy needs.
Widget _hostingRecordRoute(Widget route) => MaterialApp(
  locale: const Locale('vi'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: route,
);

/// A [PermissionService] whose camera answers are scripted: [status] is what a
/// plain read returns, [onRequest] what the OS prompt would answer.
///
/// The prompt's answer sticks, like the real thing — a granted request has to
/// leave later reads granted, or the screen bounces back to the explanation.
PermissionService _permissions({
  required PermissionStatus status,
  required PermissionStatus Function() onRequest,
  VoidCallback? onOpenSettings,
}) {
  var current = status;
  return PermissionService.custom(
    () async => PermissionStatus.denied,
    () async => PermissionStatus.denied,
    () async => false,
    () async {
      onOpenSettings?.call();
      return true;
    },
    cameraStatus: () async => current,
    requestCamera: () async => current = onRequest(),
  );
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

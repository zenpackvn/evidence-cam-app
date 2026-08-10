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
    // Trước khi camera lăn, bloc CHỜ tiếng bíp rồi CHỜ câu "Đã bắt đầu quay"
    // nói dứt — cố ý, vì khởi động camera giành mất phiên âm thanh và cắt ngang
    // câu đang phát. Hai lời gọi đó có trần 2s và 2.5s.
    //
    // Không có bản cài trong test thì cả hai chạy hết trần, tức là phải bơm hơn
    // 4.5 giây thời gian giả mới thấy trạng thái ĐANG QUAY. Các test ở đây bơm
    // ~1.1 giây, nên chúng chụp đúng lúc màn còn ở bước quét — và đỏ với lý do
    // hoàn toàn không liên quan tới thứ chúng đang đo.
    //
    // Trả lời ngay ở đây thì bỏ được cả hai lần chờ.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          (call) async => 1,
        );
    // Tiếng bíp qua `audioplayers`. Từ 10/08 bloc không CHỜ câu nói nữa
    // (`unawaited(speaking)` — camera lăn sớm hơn, đúng về hiệu năng), nên lượt
    // bíp chạy nền: không có bản cài trả lời thì nó chạy hết trần 2 giây, và
    // test kết thúc trước đó để lại một Timer treo — `flutter_test` bắt ngay
    // bằng "A Timer is still pending even after the widget tree was disposed".
    //
    // Trả lời ở đây thì lượt bíp xong tức thì và cái timeout bị huỷ theo. Sửa
    // một chỗ, khỏi phải bơm thêm thời gian ở bảy test.
    for (final name in const [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(name), (call) async => 1);
    }
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('disk_space_plus'),
          null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), null);
    for (final name in const [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(name), null);
    }
  });

  // NGUYÊN TẮC BẤT DI BẤT DỊCH: hệ thống không bao giờ từ chối ghi hình.
  //
  // Hạn mức chặn ở ranh giới UPLOAD (backend trả 403 lúc xin presign), không
  // phải ở ranh giới ghi hình. Clip vẫn được quay và nằm lại hàng đợi trên máy.
  // Test này là hàng rào: cắm lại một cái gate quota vào màn quay là test đỏ.
  testWidgets('màn quay KHÔNG có hàng rào hạn mức nào', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EcRecordRoute(
          voiceAnnouncer: _SilentVoice(),
          captureTone: CaptureToneService.silent(),
          onRequestType: _picksType,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Đã hết hạn mức video'), findsNothing);
    await _settleRecordingStart(tester);
  });

  testWidgets(
    'degrades to the idle screen when no camera is available',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EcRecordRoute(
            voiceAnnouncer: _SilentVoice(),
            captureTone: CaptureToneService.silent(),
            onRequestType: _picksType,
          ),
        ),
      );
      // The test environment has no camera plugin, so setup fails; let the
      // async failure land in the error/idle state.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // No exception escaped, and the idle "wait for bill" screen is shown
      // (recording never started).
      expect(tester.takeException(), isNull);
      expect(find.text('Đưa bill vào khung'), findsOneWidget);
      await _settleRecordingStart(tester);
    },
  );

  testWidgets(
    'saves the in-progress clip when the app is backgrounded (FR-08/FR-09)',
    (tester) async {
      // `initiallyRecording: false` + quay thật, thay vì để bản giả tự nhận là
      // đang quay: `_beginRecording` có cửa `if (_camera.isRecordingVideo)
      // return`, nên một camera tự nhận đang quay lại NGĂN lượt quay khởi động,
      // và bloc đứng ở idle — không có clip nào để mà lưu khi xuống nền.
      final camera = _FakeRecordingCamera(initiallyRecording: false);
      String? savedPath;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EcRecordRoute(
            voiceAnnouncer: _SilentVoice(),
            captureTone: CaptureToneService.silent(),
            camera: camera,
            // BẮT BUỘC phải có: vào màn quay nay là xin quyền → hỏi LOẠI VIDEO
            // → mới dựng camera. Thiếu hook này thì luồng đứng ở bước hỏi loại,
            // không bao giờ vào trạng thái đang quay — và test "lưu clip khi bị
            // đưa xuống nền" hoá ra chẳng có clip nào đang quay để mà lưu.
            onRequestType: _picksType,
            onRequestCode: () async => 'SPXVN042',
            onSaved: (path, tracking, type, durationSeconds, _, _) =>
                savedPath = path,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byTooltip('Nhập mã vận đơn'));
      await _settleRecordingStart(tester);
      // Đối chứng: có đang quay thật thì phần dưới mới đo được cái gì.
      expect(find.text('REC'), findsOneWidget);

      // `inactive` = có thứ che lên app nhưng app CHƯA bị treo: chuông cuộc
      // gọi, banner tin nhắn, trung tâm điều khiển. Phiên ghi vẫn sống nên chỉ
      // TẠM DỪNG — chốt clip ở đây là cắt vụn bằng chứng vì một cái banner.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(savedPath, isNull);
      expect(camera.disposed, isFalse);

      // `paused` = xuống nền thật. iOS thu hồi phiên ghi, nên phải chốt VÀ lưu
      // ngay tại đây — giữ file mở qua mốc này là mất trắng cả clip, không phải
      // mất phần đuôi. Đây mới là ranh giới mà FR-08/FR-09 nói tới.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The clip was finalized and handed off (to the upload queue) rather than
      // dropped, and only then was the camera released.
      expect(savedPath, '/tmp/clip.mp4');
      expect(camera.stopped, isTrue);
      expect(camera.disposed, isTrue);
      expect(tester.takeException(), isNull);
      await _settleRecordingStart(tester);
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
            voiceAnnouncer: _SilentVoice(),
            captureTone: CaptureToneService.silent(),
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
      expect(find.text('Đưa bill vào khung'), findsOneWidget);
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
          voiceAnnouncer: _SilentVoice(),
          captureTone: CaptureToneService.silent(),
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
    await _settleRecordingStart(tester);
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
          voiceAnnouncer: _SilentVoice(),
          captureTone: CaptureToneService.silent(),
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
          voiceAnnouncer: _SilentVoice(),
          captureTone: CaptureToneService.silent(),
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
    await _settleRecordingStart(tester);

    expect(find.byTooltip('Cài đặt loại video'), findsNothing);
    expect(find.byTooltip('Nhập mã vận đơn'), findsNothing);
    expect(typeRequests, afterEntry);
    expect(find.text('Đóng hàng'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _settleRecordingStart(tester);
    await _settleRecordingStart(tester);
    await _settleRecordingStart(tester);
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
          voiceAnnouncer: _SilentVoice(),
          captureTone: CaptureToneService.silent(),
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
      _hostingRecordRoute(
        EcRecordRoute(
          voiceAnnouncer: _SilentVoice(),
          captureTone: CaptureToneService.silent(),
          permissions: permissions,
        ),
      ),
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
      _hostingRecordRoute(
        EcRecordRoute(
          voiceAnnouncer: _SilentVoice(),
          captureTone: CaptureToneService.silent(),
          permissions: permissions,
        ),
      ),
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
    await _settleRecordingStart(tester);
  });
}

/// Chọn một loại video ngay khi sheet bắt buộc bật lên lúc vào màn.
///
/// Camera chỉ dựng sau khi loại đã được chọn thật, nên test nào cần tới khung
/// ngắm đều phải trả về một loại — bỏ qua sheet là ở lại màn chờ.
/// Bơm qua hai lần CHỜ trước khi camera lăn: tiếng bíp (trần 2 giây) và câu
/// "Đã bắt đầu quay" (trần 2.5 giây). Bloc `await` cả hai một cách CỐ Ý — khởi
/// động camera giành mất phiên âm thanh của hệ điều hành nên câu nói phải dứt
/// trước, nếu không người quay chỉ nghe tút rồi im.
///
/// Trong test không có bản cài cho `audioplayers`, nên lời gọi bíp chạy hết
/// trần. Bơm 1.1 giây như bản cũ là chụp đúng lúc màn CÒN Ở BƯỚC QUÉT — test đỏ
/// vì một lý do không liên quan gì tới thứ nó đang đo.
Future<void> _settleRecordingStart(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

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

/// Bản đọc CÂM cho test.
///
/// `VoiceAnnouncerService` thật bật `awaitSpeakCompletion(true)` — cố ý, để câu
/// nói dứt hẳn rồi camera mới lăn, không thì tiếng loa lọt vào chính clip bằng
/// chứng. Nhưng nghĩa là `speak` chỉ xong khi NỀN TẢNG gọi callback báo đã đọc
/// hết, mà kênh giả trong test chỉ trả lời lời gọi chứ không bao giờ gửi
/// callback đó. Future treo, và cái `.timeout(2500ms)` bọc ngoài nằm lại thành
/// một Timer chưa xong.
///
/// Trước 10/08 chuyện đó vô hại vì bloc `await` câu nói, nên test cứ chờ cùng.
/// Commit perf bỏ `await` đi (`unawaited(speaking)` — camera lăn sớm hơn), nên
/// nay test kết thúc TRƯỚC lượt nói và `flutter_test` bắt ngay: "A Timer is
/// still pending even after the widget tree was disposed".
class _SilentVoice extends VoiceAnnouncerService {
  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> prepare() async {}
}

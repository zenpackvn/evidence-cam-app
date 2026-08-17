import 'package:app_platform/app_platform.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // VoiceAnnouncerService builds a FlutterTts, which sets a method-call
  // handler — that asserts unless a binding exists.
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeCamera camera;
  late List<String> saved;
  late _RecordingVoice voice;
  late List<List<DeviceSample>> savedSamples;
  late List<DateTime> savedStarts;
  DateTime? _askedAt;
  late bool verifyStarted;
  late bool verifyFinished;

  setUp(() {
    camera = _FakeCamera();
    saved = <String>[];
    voice = _RecordingVoice()..watching = camera;
    savedSamples = <List<DeviceSample>>[];
    savedStarts = <DateTime>[];
    verifyStarted = false;
    verifyFinished = false;
  });

  RecordingSessionBloc build({
    Duration maxRecording = const Duration(minutes: 15),
    DeviceConditionSource? deviceConditions,
    Future<bool> Function(String code)? verifyReturnCode,
  }) {
    return RecordingSessionBloc(
      camera: camera,
      scanner: _FakeScanner(),
      // Bắt buộc, không phải cho gọn: bản thường dựng
      // `AudioPlayer(playerId: 'capture_tone')` — một id CỐ ĐỊNH — và
      // `beep()`/`dispose()` đều `await` xuống plugin. Trong test không có
      // plugin nào trả lời, nên từ bloc THỨ HAI trở đi mỗi test treo đủ 30
      // giây rồi bị giết. Đó là toàn bộ nhóm 11 test đỏ của B-11, và 5,5 phút
      // mỗi lượt CI chỉ để ngồi chờ.
      captureTone: CaptureToneService.silent(),
      onClipSaved: (path, tracking, type, durationSeconds, samples, startedAt) {
        saved.add(path);
        savedSamples.add(samples);
        savedStarts.add(startedAt);
      },
      deviceConditions: deviceConditions,
      voiceAnnouncer: voice,
      maxRecording: maxRecording,
      verifyReturnCode: verifyReturnCode,
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

  /// Câu "Đã bắt đầu quay" phải nói SAU khi camera đã lăn thật.
  ///
  /// Người bán đóng gói bằng hai tay và không nhìn màn hình — câu nói CHÍNH LÀ
  /// hiệu lệnh. Nói trước khi máy quay là bảo họ bắt đầu thao tác vào khoảng
  /// thời gian không được ghi lại, và thứ mất đi thường là cảnh đưa mã vận đơn
  /// lên trước ống kính: đúng khung hình mà cả hồ sơ dựa vào.
  ///
  /// Máy thật mất hàng trăm mili-giây tới hơn một giây để lăn, nên bản giả ở
  /// đây cố ý chậm — trả về tức thì thì lỗi thứ tự tàng hình.
  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'câu "Đã bắt đầu quay" chỉ phát khi camera đã thật sự lăn',
    build: () {
      camera.startLatency = const Duration(milliseconds: 120);
      return build();
    },
    act: initThen((bloc) => bloc.add(const RecordingCodeScanned('SPX1'))),
    wait: const Duration(milliseconds: 400),
    verify: (bloc) {
      expect(voice.spoken, contains('Đã bắt đầu quay'));
      expect(
        voice.recordingWhenSpoken['Đã bắt đầu quay'],
        isTrue,
        reason: 'máy báo đã quay trong khi camera chưa lăn',
      );
    },
  );

  /// Mốc bắt đầu clip phải là lúc camera LĂN, không phải lúc ta ra lệnh cho nó.
  ///
  /// Mốc này là gốc thời gian mà dấu nung trên video đếm từ đó. Đặt sớm hơn
  /// khung hình đầu tiên bao nhiêu thì đồng hồ in trên mọi khung hình sai bấy
  /// nhiêu — trên một tài liệu mà cả giá trị nằm ở chỗ giờ giấc đứng vững
  /// trước bên tranh chấp.
  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'mốc bắt đầu clip lấy lúc camera đã lăn, không phải lúc ra lệnh',
    build: () {
      camera.startLatency = const Duration(milliseconds: 150);
      return build();
    },
    act: initThen((bloc) async {
      final askedAt = DateTime.now();
      bloc.add(const RecordingCodeScanned('SPX1'));
      await Future<void>.delayed(const Duration(milliseconds: 400));
      bloc.add(const RecordingStopRequested());
      // Giữ lại mốc ra lệnh để so ở `verify`.
      _askedAt = askedAt;
    }),
    wait: const Duration(milliseconds: 600),
    verify: (bloc) {
      expect(savedStarts, hasLength(1));
      final lag = savedStarts.single.difference(_askedAt!);
      // Phải trễ hơn lúc ra lệnh ít nhất bằng độ trễ phần cứng giả lập.
      expect(
        lag,
        greaterThanOrEqualTo(const Duration(milliseconds: 150)),
        reason: 'mốc đặt trước khi camera lăn nên sớm hơn khung hình đầu',
      );
    },
  );

  /// Clip "Trả hàng" không được chờ mạng rồi mới quay.
  ///
  /// Bước đối chiếu mã là hai lượt gọi mạng (tìm đơn, tạo đơn nếu chưa có).
  /// Trên mạng di động ở bàn đóng gói, chờ chúng xong nghĩa là quét mã rồi phải
  /// đứng im một hai giây trước khi máy ghi hình — và cảnh mở kiện trong khoảng
  /// đó mất luôn. Cảnh mở kiện là thứ duy nhất không quay lại được.
  ///
  /// Chờ cũng chẳng mua được quyết định nào: bước đó LUÔN cho quay.
  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'clip trả hàng lăn ngay, không chờ lượt đối chiếu mã xong',
    build: () => build(
      verifyReturnCode: (code) async {
        verifyStarted = true;
        await Future<void>.delayed(const Duration(milliseconds: 500));
        verifyFinished = true;
        return true;
      },
    ),
    act: initThen((bloc) {
      bloc
        ..add(const RecordingTypeChanged('Trả hàng'))
        ..add(const RecordingCodeScanned('SPX-RET'));
    }),
    // Ngắn hơn 500ms của lượt đối chiếu: nếu quay còn chờ nó thì tới đây vẫn
    // chưa lăn.
    wait: const Duration(milliseconds: 150),
    verify: (bloc) {
      // Đo bằng TRẠNG THÁI bloc chứ không bằng `camera.recording`: `blocTest`
      // đóng bloc trước khi `verify` chạy, mà `close()` gọi `camera.dispose()`
      // và bản giả đặt `recording = false` ở đó. Đọc cờ ấy ở đây là đọc dấu vết
      // của lượt dọn, không phải của lượt quay.
      //
      // `RecordingStatus.recording` chỉ được phát SAU khi `startVideoRecording`
      // đã hoàn tất, nên nó là bằng chứng đủ mạnh.
      expect(
        bloc.state.status,
        RecordingStatus.recording,
        reason: 'quay còn chờ lượt gọi mạng',
      );
      // Lượt đối chiếu đã bắt đầu nhưng CHƯA xong — tức là quay không hề chờ nó.
      expect(verifyStarted, isTrue);
      expect(
        verifyFinished,
        isFalse,
        reason:
            'lượt đối chiếu xong trước cả mốc đo, ca này không chứng minh gì',
      );
    },
  );

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
      captureTone: CaptureToneService.silent(),
      onClipSaved: (_, _, _, _, _, _) {},
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

  // ĐANG SKIP vì một bug có sẵn, KHÔNG phải vì phần lấy mẫu hỏng: trong môi
  // trường test, ghi hình không bao giờ khởi động được, nên mọi test đi qua
  // RecordingManualCodeSubmitted đều timeout 30s — 11/16 test của file này đã
  // đỏ y hệt trước khi có phần lấy mẫu. Gỡ skip ngay khi bug đó được sửa; hình
  // dạng dữ liệu trên dây đã có test riêng chạy xanh ở device_samples_test.dart.
  group(
    'device-condition sampling',
    () {
      blocTest<RecordingSessionBloc, RecordingSessionState>(
        'samples device conditions on the clip clock and hands them to the save',
        build: () => build(deviceConditions: _FakeConditions()),
        act: (bloc) async {
          bloc.add(const RecordingInitRequested());
          await Future<void>.delayed(const Duration(milliseconds: 20));
          bloc.add(const RecordingManualCodeSubmitted('A'));
          await Future<void>.delayed(const Duration(milliseconds: 20));
          // Nhịp 1 giây; mẫu lấy ở các giây chẵn.
          for (var i = 0; i < 4; i++) {
            bloc.add(const RecordingTicked());
            await Future<void>.delayed(const Duration(milliseconds: 10));
          }
          bloc.add(const RecordingBackgrounded());
        },
        wait: const Duration(milliseconds: 60),
        verify: (bloc) {
          expect(savedSamples, hasLength(1));
          final samples = savedSamples.single;
          expect(samples, isNotEmpty);
          // t_ms phải TĂNG NGHIÊM NGẶT — backend từ chối cả bộ nếu không, và
          // clip đó vĩnh viễn mất pin/mạng.
          for (var i = 1; i < samples.length; i++) {
            expect(samples[i].tMs, greaterThan(samples[i - 1].tMs));
          }
          expect(samples.first.battery, 77);
          expect(samples.first.net, NetKind.mobile);
        },
      );

      blocTest<RecordingSessionBloc, RecordingSessionState>(
        'a clip still records and saves when no condition source is wired',
        build: build,
        act: (bloc) async {
          bloc.add(const RecordingInitRequested());
          await Future<void>.delayed(const Duration(milliseconds: 20));
          bloc.add(const RecordingManualCodeSubmitted('A'));
          await Future<void>.delayed(const Duration(milliseconds: 20));
          bloc.add(const RecordingTicked());
          bloc.add(const RecordingTicked());
          await Future<void>.delayed(const Duration(milliseconds: 20));
          bloc.add(const RecordingBackgrounded());
        },
        wait: const Duration(milliseconds: 60),
        verify: (bloc) {
          // Mất mẫu là mất một thứ trang trí; mất clip là mất bằng chứng.
          expect(saved, hasLength(1));
          expect(savedSamples.single, isEmpty);
        },
      );
    },
  );

  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'falls back to plain recording when the hardware rejects stream+record',
    build: () => RecordingSessionBloc(
      camera: _FakeCamera()..failStartWithScan = true,
      scanner: _FakeScanner(),
      captureTone: CaptureToneService.silent(),
      onClipSaved: (_, _, _, _, _, _) {},
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

  blocTest<RecordingSessionBloc, RecordingSessionState>(
    'the hard cap really stops the camera and announces it exactly once',
    // A 3s cap keeps the test fast; the tick loop is the same one that runs
    // at 15'. The one-minute warning lead is longer than the whole clip here,
    // so the near-limit line is spoken on the first tick.
    build: () => build(maxRecording: const Duration(seconds: 3)),
    act: (bloc) async {
      bloc.add(const RecordingInitRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const RecordingManualCodeSubmitted('SPX1'));
      await Future<void>.delayed(const Duration(seconds: 4));
    },
    wait: const Duration(milliseconds: 200),
    verify: (bloc) {
      expect(bloc.state.status, RecordingStatus.idle);
      // The camera was actually told to stop — the reported stop and the real
      // one must not diverge.
      expect(camera.recording, isFalse);
      expect(camera.stopCount, 1);
      expect(saved, hasLength(1));
      expect(voice.spoken.where((s) => s == 'Đã dừng quay'), hasLength(1));
      // Trần 3 GIÂY nên `_maxRecording.inMinutes` bằng 0, và bloc cố ý đọc câu
      // ngắn thay vì "Sắp chạm trần 0 phút". Khẳng định cũ tìm chuỗi dài, nên
      // nó sai với chính trần mà test này chọn — và chưa bao giờ chạy tới đây
      // để lộ ra, vì test treo ở chỗ khác suốt (xem `captureTone` ở trên).
      expect(
        voice.spoken.where((s) => s == 'Video sắp tự chốt'),
        hasLength(1),
      );
    },
  );

  group('idleScanMayStart', () {
    final now = DateTime(2026, 7, 31, 12);

    test('blocks the bill whose clip just closed while it is still framed', () {
      expect(
        idleScanMayStart(
          'SPX1',
          justClosedCode: 'spx1',
          blockedUntil: now.add(const Duration(seconds: 5)),
          now: now,
        ),
        isFalse,
      );
    });

    test('lets a different order start immediately (A→B hand-off)', () {
      expect(
        idleScanMayStart(
          'SPX2',
          justClosedCode: 'spx1',
          blockedUntil: now.add(const Duration(seconds: 5)),
          now: now,
        ),
        isTrue,
      );
    });

    test('re-arms the same order once the block has lapsed', () {
      expect(
        idleScanMayStart(
          'SPX1',
          justClosedCode: 'spx1',
          blockedUntil: now.subtract(const Duration(seconds: 1)),
          now: now,
        ),
        isTrue,
      );
    });

    test('allows anything when nothing has closed yet', () {
      expect(
        idleScanMayStart(
          'SPX1',
          justClosedCode: null,
          blockedUntil: null,
          now: now,
        ),
        isTrue,
      );
    });
  });
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

  /// Máy thật mất một khoảng để thật sự lăn — trên iPhone 11 đo được hàng trăm
  /// mili-giây, trên Android CameraX còn lâu hơn. Bản giả trả về tức thì thì
  /// mọi lỗi về THỨ TỰ đều tàng hình, vì mọi thứ xảy ra trong cùng một nhịp.
  Duration startLatency = Duration.zero;

  @override
  Future<void> startVideoRecording({
    onLatestImageAvailable? onAvailable,
  }) async {
    if (onAvailable != null && failStartWithScan) {
      throw Exception('no concurrent stream+record');
    }
    if (startLatency > Duration.zero) await Future<void>.delayed(startLatency);
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

/// Records what would have been spoken instead of reaching the TTS engine.
class _RecordingVoice extends VoiceAnnouncerService {
  final List<String> spoken = <String>[];

  /// Camera đã lăn hay chưa TẠI THỜI ĐIỂM từng câu được nói.
  ///
  /// Cần cái này chứ không chỉ cần danh sách câu: lỗi ở đây là THỨ TỰ, không
  /// phải nội dung. Câu "Đã bắt đầu quay" vẫn phát đúng chữ, chỉ là phát lúc
  /// máy chưa quay — và người bán nghe xong là bắt đầu thao tác.
  final Map<String, bool> recordingWhenSpoken = <String, bool>{};

  _FakeCamera? watching;

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
    recordingWhenSpoken[text] = watching?.recording ?? false;
  }
}

/// Nguồn điều kiện thiết bị giả: pin tụt dần, đang dùng di động.
class _FakeConditions implements DeviceConditionSource {
  int _level = 77;

  @override
  Future<({int? battery, bool charging, NetKind net})> read() async =>
      (battery: _level--, charging: false, net: NetKind.mobile);
}

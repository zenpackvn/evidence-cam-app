// Cả tệp này sống bằng nội tạng của camera_android_camerax: nó ghim
// VideoCapture vào lifecycle CameraX để chữa cú ngoặt preview trên Android.
// Các thành viên cần dùng (`recording`, `videoCapture`, `cameraSelector`, …)
// plugin đánh @visibleForTesting, không có đường công khai thay thế.
// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:camera_android_camerax/camera_android_camerax.dart';
// camera_android_camerax không export CameraX bindings qua public API; ghim
// vào video pipeline của nó buộc phải với vào src/.
// ignore: implementation_imports
import 'package:camera_android_camerax/src/camerax_library.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';

/// Bản CameraX gắn `VideoCapture` vào lifecycle NGAY LÚC DỰNG CAMERA và không
/// gỡ ra khi dừng quay.
///
/// Đây là chỗ Android khác iOS, và là toàn bộ lý do preview ngoặt ngang một
/// nhịp mỗi lần bấm quay hoặc dừng.
///
/// Gắn sẵn từ đầu là nửa thứ hai của bản vá, và là nửa quyết định. Bind
/// `VideoCapture` không chỉ dựng lại capture session — nó đổi luôn HÌNH DẠNG
/// đường đi của khung hình: CameraX chuyển sang chia sẻ một luồng cho cả
/// preview lẫn bản ghi, và luồng chia sẻ ấy đi qua surface processor, thứ tự
/// nắn khung về đúng hướng trước khi giao cho Flutter. Nên cùng một máy có hai
/// chế độ giao khung khác nhau, cần hai góc xoay khác nhau, và mọi cách chốt
/// một con số đều sai ở một trong hai đầu. Gắn sẵn từ lúc dựng camera thì chỉ
/// còn MỘT chế độ từ khung hình đầu tiên tới lúc đóng camera: bấm quay không
/// đổi gì, dừng quay không đổi gì, không còn khoảnh khắc nào để lệch.
///
/// `camera_avfoundation` gắn output quay vào capture session ngay lúc dựng
/// session, nên bấm quay không đụng gì tới session — preview chạy liên tục.
/// `camera_android_camerax` thì bind `VideoCapture` trong `startVideoCapturing`
/// và **gỡ ra** ở dòng cuối `stopVideoRecording`. Mỗi lần bind/unbind là một
/// lần CameraX dựng lại capture session, và lúc dựng lại nó đọc hướng màn hình
/// để tính target rotation — máy chống xuống bàn nhìn xuống thì hướng ấy đọc
/// ra landscape, nên khung hình ngoặt ngang rồi tự về.
///
/// Gắn lại từ bên ngoài không cứu được: lúc ta gắn thì session đã dựng lại
/// xong và cú ngoặt đã lên màn hình. Phải chặn ngay chính lời gọi ấy.
///
/// Thân hàm dưới đây chép từ `AndroidCameraCameraX.stopVideoRecording`
/// (camera_android_camerax 0.7.4+2), **bỏ đúng một dòng**:
/// `await _unbindUseCaseFromLifecycle(videoCapture!)`. Mọi trường nó động tới
/// đều là trường công khai của lớp cha. Giữ use case nằm trong lifecycle không
/// rò rỉ gì — `dispose()` của controller vẫn gỡ sạch như thường.
///
/// Khi nâng `camera_android_camerax`, đối chiếu lại hàm gốc: nếu upstream đổi
/// cách chốt bản ghi thì bản chép này phải đi theo.
class EcPinnedCameraX extends AndroidCameraCameraX {
  /// Surface producer của máy này có tự nắn khung camera không.
  ///
  /// Hỏi native một lần rồi nhớ: câu trả lời là thuộc tính của backend đồ hoạ
  /// trên máy, không đổi giữa các lần dựng camera.
  bool? _handlesCropAndRotation;

  /// Số phần tư vòng xoay THEO CHIỀU KIM ĐỒNG HỒ mà texture trần cần, để
  /// preview đứng đúng trên màn khoá dọc.
  ///
  /// Có hai loại máy Android, và chúng cần hai giá trị khác nhau:
  ///
  /// - Producer **tự nắn** (Impeller `SurfaceProducer.handlesCropAndRotation()`
  ///   trả `true`): texture giao ra đã đứng sẵn → `0`.
  /// - Producer **giao nguyên** khung theo cảm biến (Galaxy M14 nằm nhóm này):
  ///   texture nằm ngang đúng bằng góc cảm biến → phải xoay bù lại đúng góc ấy.
  ///
  /// Đây chính là phép tính plugin làm trong `ImageReaderRotatedPreview` cho
  /// trường hợp màn khoá dọc — chỉ khác là ta chốt một lần thay vì nghe cảm
  /// biến, vì màn quay này khoá `portraitUp` cả cửa sổ lẫn khung quay. Camera
  /// trước (`sensorOrientation` 270) ra `3`, camera sau (90) ra `1`, nên lật
  /// camera vẫn đúng mà không cần biết mặt nào đang bật.
  ///
  /// Trên iOS (và mọi nền không phải CameraX) trả `0`: texture ở đó vốn đã đứng.
  ///
  /// Câu hỏi thứ hai — `VideoCapture` đã nằm trong lifecycle chưa — hỏi THẲNG
  /// `ProcessCameraProvider` chứ không suy ra từ "đang quay hay không". Hai thứ
  /// đó KHÔNG trùng nhau: sau [initializeCamera] thì đã bind dù chưa quay, và
  /// sau khi dừng quay thì vẫn còn bind. Suy từ trạng thái quay là đúng được
  /// một nửa số nhịp, và nửa còn lại là preview nằm ngang.
  Future<int> previewQuarterTurns(CameraDescription description) async {
    final handled = _handlesCropAndRotation ??=
        await preview?.surfaceProducerHandlesCropAndRotation() ?? true;
    if (handled) return 0;
    if (await _videoCaptureIsBound()) return 0;
    return (description.sensorOrientation ~/ 90) % 4;
  }

  Future<bool> _videoCaptureIsBound() async {
    final useCase = videoCapture;
    final provider = processCameraProvider;
    if (useCase == null || provider == null) return false;
    try {
      return await provider.isBound(useCase);
    } on Object {
      return false;
    }
  }

  /// Gắn `VideoCapture` ngay sau khi lớp cha gắn preview/chụp/phân tích.
  ///
  /// Bản gốc để dành tới `startVideoCapturing` mới gắn ("Video capture is bound
  /// at first use instead of here") — và đúng cú gắn muộn ấy là thứ đổi đường
  /// đi khung hình giữa lúc người ta đang nhìn màn hình. Gắn ở đây thì cú đổi
  /// rơi vào lúc camera còn chưa giao khung nào.
  ///
  /// Hỏng thì bỏ qua trong im lặng: máy nào không cho bind bốn use case cùng
  /// lúc sẽ quay lại đúng hành vi gốc (gắn muộn), và [previewQuarterTurns] đọc
  /// trạng thái bind thật nên vẫn ra góc đúng cho máy đó.
  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    await super.initializeCamera(cameraId, imageFormatGroup: imageFormatGroup);
    final useCase = videoCapture;
    final provider = processCameraProvider;
    final selector = cameraSelector;
    if (useCase == null || provider == null || selector == null) return;
    try {
      if (await provider.isBound(useCase)) return;
      camera = await provider.bindToLifecycle(selector, <UseCase>[useCase]);
    } on Object {
      // Giữ nguyên hành vi gốc trên máy không kham nổi tổ hợp use case này.
    }
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) async {
    if (recording == null) {
      throw CameraException(
        'videoRecordingFailed',
        'Attempting to stop a video recording while no recording is in '
            'progress.',
      );
    }

    await recording!.close();
    var event = await videoRecordingEventStreamQueue.next;
    while (event is! VideoRecordEventFinalize) {
      event = await videoRecordingEventStreamQueue.next;
    }
    recording = null;
    pendingRecording = null;

    if (videoOutputPath == null) {
      throw CameraException(
        'INVALID_PATH',
        'The platform did not return a path while reporting success. The '
            'platform should always return a valid path or report an error.',
      );
    }

    // ĐÂY là dòng bị bỏ so với bản gốc:
    //   await _unbindUseCaseFromLifecycle(videoCapture!);

    final videoFile = XFile(videoOutputPath!);
    cameraEventStreamController.add(
      VideoRecordedEvent(cameraId, videoFile, null),
    );
    return videoFile;
  }
}

/// Cài [EcPinnedCameraX] làm bản CameraX mà app dùng.
///
/// Gọi một lần lúc khởi động, sau `ensureInitialized()` (plugin đã tự đăng ký
/// bản gốc ở đó) và trước khi màn quay dựng controller đầu tiên.
///
/// Trên iOS không làm gì: bản `camera_avfoundation` vốn đã không có lỗi này.
void ecInstallPinnedCameraX() {
  if (CameraPlatform.instance is! AndroidCameraCameraX) return;
  CameraPlatform.instance = EcPinnedCameraX();
}

/// Góc phải xoay texture camera của [description] để preview đứng đúng.
///
/// Xem [EcPinnedCameraX.previewQuarterTurns] để biết vì sao con số này không
/// thể là hằng số chép cứng. Nền không phải CameraX (iOS) trả `0`.
Future<int> ecPreviewQuarterTurns(CameraDescription description) async {
  final platform = CameraPlatform.instance;
  if (platform is! EcPinnedCameraX) return 0;
  return platform.previewQuarterTurns(description);
}

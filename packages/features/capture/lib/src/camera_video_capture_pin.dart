import 'package:camera_android_camerax/camera_android_camerax.dart';
// ignore: implementation_imports
import 'package:camera_android_camerax/src/camerax_library.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:cross_file/cross_file.dart';

/// Bản CameraX KHÔNG gỡ `VideoCapture` khỏi lifecycle khi dừng quay.
///
/// Đây là chỗ Android khác iOS, và là toàn bộ lý do preview ngoặt ngang một
/// nhịp mỗi lần bấm quay hoặc dừng.
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

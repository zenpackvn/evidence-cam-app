import 'dart:async';

import 'package:app_platform/app_platform.dart';
import 'package:evidence_cam/screens/ec_scan_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:localization/localization.dart';

/// Màn quét mã phải có ĐƯỜNG THỨ HAI: chọn một ảnh có sẵn.
///
/// Người đóng gói thường đã có ảnh tem trong máy — họ chụp lô hàng lúc nhận,
/// hoặc sàn gửi ảnh tem qua chat. Giơ camera vào một tấm ảnh đang hiện trên màn
/// hình máy khác thì lóa, vân sọc và gần như không ra mã.

/// Camera GIẢ đứng mãi ở bước liệt kê thiết bị.
///
/// Cố ý: đó là cảnh camera đang khởi động, và lớp phủ (ô ngắm, dòng gợi ý, nút
/// chọn ảnh) phải hiện ngay từ lúc ấy. Bắt người dùng chờ camera lên xong mới
/// thấy đường thoát là bắt họ chờ đúng thứ vừa làm họ bế tắc.
class _CameraDungIm extends CameraService {
  @override
  Future<List<CameraDescription>> getAvailableCameras() =>
      Completer<List<CameraDescription>>().future;

  @override
  Future<void> dispose() async {}
}

/// Thư viện ảnh GIẢ: người dùng mở lên rồi bấm Huỷ.
class _AnhHuy implements ImagePickerService {
  int soLanMo = 0;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    soLanMo++;
    return null;
  }

  @override
  Future<List<XFile>> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool requestFullMetadata = true,
  }) async => const [];

  @override
  Future<XFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async => null;
}

Widget _man({
  required ValueChanged<String> onDetected,
  ImagePickerService? picker,
}) => MaterialApp(
  locale: const Locale('vi'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: EcBarcodeScanRoute(
    onDetected: onDetected,
    camera: _CameraDungIm(),
    picker: picker,
  ),
);

void main() {
  testWidgets(
    'màn quét bày nút chọn ảnh ngay khi camera còn đang lên',
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
    (t) async {
      await t.pumpWidget(_man(onDetected: (_) {}));
      await t.pump();

      final vi = await AppLocalizations.delegate.load(const Locale('vi'));
      expect(find.text(vi.scanPickImage), findsOneWidget);
      // Dòng gợi ý cũ vẫn còn — thêm đường mới không được cắt đường cũ.
      expect(find.text('Đưa mã vận đơn vào khung'), findsOneWidget);
    },
  );

  testWidgets(
    'bấm chọn ảnh mà không chọn được thì KHÔNG trả về mã nào',
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
    (t) async {
      // Người dùng mở thư viện rồi bấm Huỷ. Màn phải im lặng và TRẢ LẠI nút,
      // KHÔNG được bắn một mã rỗng đi tiếp: mã rỗng là bắt đầu quay một đơn
      // không có mã.
      final maDaTra = <String>[];
      final anh = _AnhHuy();
      await t.pumpWidget(_man(onDetected: maDaTra.add, picker: anh));
      await t.pump();

      final vi = await AppLocalizations.delegate.load(const Locale('vi'));
      await t.tap(find.text(vi.scanPickImage));
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));

      expect(anh.soLanMo, 1, reason: 'bấm nút mà không mở thư viện ảnh');
      expect(maDaTra, isEmpty);
      // Nút phải BẤM LẠI ĐƯỢC: khoá vĩnh viễn sau một lượt hỏng là một màn hình
      // chết mà không nói lý do.
      final nut = t.widget<TextButton>(
        find.ancestor(
          of: find.text(vi.scanPickImage),
          matching: find.byType(TextButton),
        ),
      );
      expect(nut.onPressed, isNotNull);
    },
  );
}

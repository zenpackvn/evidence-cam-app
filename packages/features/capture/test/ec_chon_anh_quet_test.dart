import 'package:app_platform/app_platform.dart';
import 'package:feature_capture/feature_capture.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:flutter_test/flutter_test.dart';

/// Chọn ảnh có sẵn rồi đọc mã trong đó.
///
/// Ba kết cục, và cái đáng canh nhất là ranh giới giữa "người dùng bấm Huỷ" và
/// "ảnh không có mã": gộp hai cái đó làm một là màn hình báo lỗi cho người vừa
/// chủ động thoát ra — một câu sai, ngay sau một thao tác họ cố ý làm.

class _PickerGia implements ImagePickerService {
  _PickerGia({this.tra, this.nem = false});

  /// Đường dẫn ảnh giả trả về; `null` = người dùng bấm Huỷ.
  final String? tra;

  /// Thư viện ảnh ném — thiếu quyền, hoặc hệ điều hành từ chối mở.
  final bool nem;

  int soLanGoi = 0;
  ImageSource? nguonDaXin;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    soLanGoi++;
    nguonDaXin = source;
    if (nem) throw StateError('thư viện ảnh từ chối');
    return tra == null ? null : XFile(tra!);
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

class _ScannerGia implements BillScanner {
  _ScannerGia(this.ma);

  /// Mã đọc được từ ảnh; `null` = ảnh không có mã nào.
  final String? ma;

  String? duongDaNhan;

  @override
  Future<String?> quetTuAnh(String duongTep) async {
    duongDaNhan = duongTep;
    return ma;
  }

  @override
  Future<String?> scan(
    CameraImage image,
    CameraDescription camera, {
    DeviceOrientation deviceOrientation = DeviceOrientation.portraitUp,
    EcScanWindow? window,
  }) async => null;

  @override
  Future<void> dispose() async {}
}

void main() {
  test('ảnh có mã thì trả về mã, kèm đúng đường dẫn đã chọn', () async {
    final picker = _PickerGia(tra: '/tmp/tem.jpg');
    final scanner = _ScannerGia('SPXVN046231897410');

    final ket = await ecChonAnhVaQuet(scanner: scanner, picker: picker);

    expect(ket.ketQua, EcKetQuaChonAnh.thayMa);
    expect(ket.ma, 'SPXVN046231897410');
    expect(scanner.duongDaNhan, '/tmp/tem.jpg');
  });

  test('lấy ảnh từ THƯ VIỆN, không mở lại camera', () async {
    // Mở camera ở đây là bày ra đúng thứ người dùng vừa bỏ qua: họ đang đứng
    // trong màn quét — camera đã ở ngay trước mặt và không đọc ra mã.
    final picker = _PickerGia(tra: '/tmp/a.jpg');

    await ecChonAnhVaQuet(scanner: _ScannerGia('X'), picker: picker);

    expect(picker.nguonDaXin, ImageSource.gallery);
  });

  test('người dùng bấm Huỷ thì im lặng, KHÔNG phải lỗi ảnh', () async {
    final ket = await ecChonAnhVaQuet(
      scanner: _ScannerGia('không-bao-giờ-tới'),
      picker: _PickerGia(),
    );

    expect(ket.ketQua, EcKetQuaChonAnh.huy);
    expect(ket.ma, isNull);
  });

  test('ảnh không có mã thì nói rõ là ảnh, không im lặng', () async {
    final ket = await ecChonAnhVaQuet(
      scanner: _ScannerGia(null),
      picker: _PickerGia(tra: '/tmp/anh-trong.jpg'),
    );

    expect(ket.ketQua, EcKetQuaChonAnh.khongThayMa);
  });

  test('mã rỗng cũng là không có mã', () async {
    // MLKit trả chuỗi rỗng cho vài loại mã hỏng. Đưa chuỗi rỗng đi tiếp là
    // bắt đầu quay một đơn không có mã.
    final ket = await ecChonAnhVaQuet(
      scanner: _ScannerGia(''),
      picker: _PickerGia(tra: '/tmp/x.jpg'),
    );

    expect(ket.ketQua, EcKetQuaChonAnh.khongThayMa);
  });

  test('thư viện ảnh ném thì coi như Huỷ, không đổ lỗi cho tấm ảnh', () async {
    // Thiếu quyền hoặc hệ điều hành từ chối mở. Người dùng chưa kịp chọn ảnh
    // nào, nên "ảnh này không có mã" là một câu nói về thứ không tồn tại.
    final ket = await ecChonAnhVaQuet(
      scanner: _ScannerGia('X'),
      picker: _PickerGia(nem: true),
    );

    expect(ket.ketQua, EcKetQuaChonAnh.huy);
  });

  test('chỉ mở thư viện MỘT lần cho mỗi lượt gọi', () async {
    final picker = _PickerGia(tra: '/tmp/a.jpg');

    await ecChonAnhVaQuet(scanner: _ScannerGia('X'), picker: picker);

    expect(picker.soLanGoi, 1);
  });
}

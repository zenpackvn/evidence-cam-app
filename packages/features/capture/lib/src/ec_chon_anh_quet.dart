/// Chọn một tấm ảnh có sẵn rồi đọc mã trong đó.
///
/// Vì sao cần, bên cạnh camera: người đóng gói thường ĐÃ có ảnh tem — họ chụp
/// lô hàng lúc nhận, hoặc sàn gửi ảnh tem qua chat. Giơ camera vào một tấm ảnh
/// đang hiện trên màn hình máy khác thì lóa, mờ vân sọc và gần như không ra mã.
/// Đọc thẳng từ tệp bỏ hẳn chặng đó.
///
/// Cùng một hàm cho MỌI màn có quét. Hai bản sao của luồng này sẽ lệch nhau ở
/// đúng chỗ khó thấy nhất — một bên xử lý "người dùng bấm huỷ", bên kia quên.
library;

import 'package:app_platform/app_platform.dart';

import 'ec_bill_scanner.dart';

/// Ba kết cục, và cả ba đều phải NÓI RA được.
///
/// Gộp `huy` với `khongThayMa` làm một là màn hình báo "ảnh không có mã" cho
/// người vừa bấm nút Huỷ — một câu sai, ngay sau một thao tác họ chủ động làm.
enum EcKetQuaChonAnh { huy, khongThayMa, thayMa }

class EcChonAnhQuet {
  const EcChonAnhQuet(this.ketQua, [this.ma]);

  final EcKetQuaChonAnh ketQua;

  /// Chỉ có khi [ketQua] là [EcKetQuaChonAnh.thayMa].
  final String? ma;
}

/// Mở thư viện ảnh, đọc mã trong tấm được chọn.
///
/// [picker] và [scanner] truyền vào từ ngoài để đo được: cả hai đều gọi xuống
/// nền tảng, và một bộ đo phải dựng được cảnh "người dùng huỷ" lẫn cảnh "ảnh
/// không có mã" mà không cần thư viện ảnh thật.
Future<EcChonAnhQuet> ecChonAnhVaQuet({
  required BillScanner scanner,
  ImagePickerService? picker,
}) async {
  final chon = picker ?? ImagePickerService(ImagePicker());
  final XFile? anh;
  try {
    anh = await chon.pickImage(source: ImageSource.gallery);
  } on Object {
    // Thiếu quyền, hoặc thư viện ảnh từ chối mở. Với người dùng thì đó là "bấm
    // xong không có gì" — nên trả về `huy` để màn hình im lặng đúng như khi họ
    // tự bấm Huỷ, thay vì đổ lỗi cho tấm ảnh họ chưa kịp chọn.
    return const EcChonAnhQuet(EcKetQuaChonAnh.huy);
  }
  if (anh == null) return const EcChonAnhQuet(EcKetQuaChonAnh.huy);

  final ma = await scanner.quetTuAnh(anh.path);
  if (ma == null || ma.isEmpty) {
    return const EcChonAnhQuet(EcKetQuaChonAnh.khongThayMa);
  }
  return EcChonAnhQuet(EcKetQuaChonAnh.thayMa, ma);
}

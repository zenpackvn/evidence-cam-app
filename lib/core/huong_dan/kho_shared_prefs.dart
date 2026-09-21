import 'package:feature_shift/feature_shift.dart';
import 'package:storage/storage.dart';

/// Nhớ "đã xem hướng dẫn màn nào" trong SharedPreferences, THEO TỪNG NGƯỜI.
///
/// Khoá gắn uid chứ không phải một khoá chung cho cả máy: điện thoại đóng gói
/// thường dùng chung theo ca, và với khoá chung thì chỉ người đăng nhập đầu
/// tiên trên máy đó thấy hướng dẫn — mọi người vào sau không bao giờ thấy, mà
/// không có gì báo cho ai biết.
///
/// KHÔNG gắn theo cửa hàng: hướng dẫn nói về MÀN, không nói về cửa hàng. Bắt
/// cùng một người đọc lại cùng nội dung mỗi lần đổi cửa hàng chỉ gây phiền.
///
/// Đọc đồng bộ được vì [SharedPreferences] giữ sẵn bản sao trong bộ nhớ — thẻ
/// hướng dẫn phải quyết định hiện hay không ngay ở khung hình đầu, nếu chờ
/// `await` thì nó nhấp nháy hiện rồi biến mất.
class EcHuongDanKhoPrefs implements EcHuongDanKho {
  EcHuongDanKhoPrefs(this._prefs, this._uid);

  final SharedPreferences _prefs;

  /// uid của người đang đăng nhập. Rỗng khi chưa đăng nhập — lúc đó chưa có ai
  /// để phân biệt, và cũng chưa màn nào có hướng dẫn.
  final String Function() _uid;

  String _khoa(EcMan man) {
    final uid = _uid();
    return uid.isEmpty ? 'ec_hd_${man.name}' : 'ec_hd_${man.name}:$uid';
  }

  @override
  bool daXem(EcMan man) => _prefs.getBool(_khoa(man)) ?? false;

  @override
  Future<void> danhDau(EcMan man) => _prefs.setBool(_khoa(man), true);

  /// Khoá cấp MÁY — cố ý không có uid, xem [EcHuongDanKho.daXemGioiThieu].
  static const _khoaGioiThieu = 'ec_gioi_thieu_xong';

  @override
  bool daXemGioiThieu() => _prefs.getBool(_khoaGioiThieu) ?? false;

  @override
  Future<void> danhDauGioiThieu() => _prefs.setBool(_khoaGioiThieu, true);

  @override
  Future<void> quenHet() async {
    for (final man in EcMan.values) {
      await _prefs.remove(_khoa(man));
    }
  }
}

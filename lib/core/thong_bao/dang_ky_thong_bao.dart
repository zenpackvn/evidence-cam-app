import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_platform/app_platform.dart';
import 'package:ec_data/ec_data.dart';
import 'package:flutter/foundation.dart';

/// Nối token FCM của máy này lên máy chủ, và gỡ ra khi đăng xuất.
///
/// Token sinh ra TRÊN MÁY và máy chủ không có cách nào tự biết. Không có lớp
/// này thì phần bắn thông báo ở backend chạy đúng nhưng không có địa chỉ nào
/// để bắn tới — im lặng, không lỗi, và chỉ phát hiện được bằng cách chờ một
/// thông báo không bao giờ tới.
///
/// Token cũng ĐỔI theo thời gian (cài lại app, khôi phục máy, Google xoay
/// vòng), nên phải nghe dòng đổi token chứ không chỉ đọc một lần lúc đăng nhập.
class EcDangKyThongBao {
  EcDangKyThongBao(this._repo, this._messaging);

  final EcRepository _repo;
  final FirebaseMessagingService? _messaging;

  StreamSubscription<String?>? _nghe;

  /// Token đã gửi lên gần nhất. Giữ lại để lúc đăng xuất còn biết gỡ cái nào —
  /// hỏi lại `getToken()` ở thời điểm đó thì đã có thể là token khác.
  String? _tokenDaGui;

  String get _nen => kIsWeb
      ? 'web'
      : Platform.isIOS || Platform.isMacOS
      ? 'ios'
      : 'android';

  /// Gọi sau khi đăng nhập xong.
  ///
  /// Chỉ đăng ký khi người dùng ĐÃ cho phép thông báo — không tự bật hộp thoại
  /// hỏi quyền ở đây. Việc hỏi thuộc về [xinPhepVaDangKy], gọi từ chỗ đã giải
  /// thích cho người dùng vì sao.
  Future<void> noiKhiDangNhap() async {
    final m = _messaging;
    if (m == null) return;
    _nghe ??= m.onTokenRefresh.listen(_gui);
    if (!await m.daChoPhep()) return;
    await _gui(await m.getToken());
  }

  /// Hỏi quyền rồi đăng ký. Trả `true` nếu người dùng đồng ý.
  Future<bool> xinPhepVaDangKy() async {
    final m = _messaging;
    if (m == null) return false;
    _nghe ??= m.onTokenRefresh.listen(_gui);
    final duoc = await m.xinQuyen();
    if (duoc) await _gui(await m.getToken());
    return duoc;
  }

  Future<bool> daChoPhep() async => await _messaging?.daChoPhep() ?? false;

  Future<void> _gui(String? token) async {
    if (token == null || token.isEmpty) return;
    if (token == _tokenDaGui) return;
    try {
      await _repo.dangKyMayNhanThongBao(token, _nen);
      _tokenDaGui = token;
    } on Object catch (error) {
      // Nuốt lỗi có chủ ý: không đăng ký được thì người dùng mất thông báo,
      // nhưng làm hỏng lượt đăng nhập vì chuyện đó thì họ mất cả app.
      debugPrint('dang_ky_thong_bao_that_bai: $error');
    }
  }

  /// Gọi TRƯỚC khi đăng xuất, lúc còn token để gọi API.
  ///
  /// Không gỡ thì người đăng nhập sau trên cùng máy vẫn nhận thông báo của
  /// người trước — máy chủ vẫn thấy token đó thuộc tài khoản cũ.
  Future<void> goKhiDangXuat() async {
    // Hỏi lại máy nếu chưa từng gửi token nào trong phiên này: lượt đăng xuất
    // có thể xảy ra ở một màn khác màn đã đăng ký (đăng xuất từ tab Tài khoản,
    // từ màn chọn shop, từ lối khôi phục phiên), và ở đó `_tokenDaGui` còn
    // rỗng. Không hỏi lại thì token cũ nằm mãi trên máy chủ.
    final token = _tokenDaGui ?? await _messaging?.getToken();
    _tokenDaGui = null;
    await _nghe?.cancel();
    _nghe = null;
    if (token == null || token.isEmpty) return;
    try {
      await _repo.goMayNhanThongBao(token);
    } on Object catch (error) {
      debugPrint('go_thong_bao_that_bai: $error');
    }
  }
}

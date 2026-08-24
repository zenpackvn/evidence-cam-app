import 'dart:developer' as developer;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Remembers the last sign-in email + password so the login form can prefill
/// them (product decision: remember the password too, not just the email).
///
/// The password lives only in platform-encrypted storage (iOS Keychain /
/// Android Keystore) via [FlutterSecureStorage] — never in shared preferences.
///
/// **Mọi thao tác ở đây đều CỐ GẮNG-HẾT-SỨC, không bao giờ ném.**
///
/// Kho khoá của hệ điều hành hỏng được, và hỏng thật: gỡ rồi cài lại app trên
/// Android để lại đám giá trị đã mã hoá mà khoá giải chúng đã bị huỷ theo, nên
/// mọi lượt đọc trả `Error::Km(UNKNOWN_ERROR)`. Đó là chuyện của một tiện ích
/// điền hộ — không phải chuyện của việc đăng nhập.
///
/// Trước đây lượt `save()` nằm chung `try` với lượt đăng nhập ở màn Login, nên
/// Keystore hỏng làm cả lượt đăng nhập ĐÃ THÀNH CÔNG bị báo là thất bại: người
/// dùng thấy toast lỗi và đứng nguyên ở màn đăng nhập, dù phiên đã mở. Nuốt lỗi
/// ở đây chặn đứng cả họ hàng lỗi đó, thay vì vá từng chỗ gọi.
class CredentialStore {
  const CredentialStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _emailKey = 'auth.saved_email';
  static const _passwordKey = 'auth.saved_password';

  /// The remembered credentials, or null if nothing has been saved yet — or if
  /// the platform keystore refuses to read them.
  Future<({String email, String password})?> read() async {
    try {
      final email = await _storage.read(key: _emailKey);
      final password = await _storage.read(key: _passwordKey);
      if (email == null && password == null) return null;
      return (email: email ?? '', password: password ?? '');
    } on Object catch (error) {
      _log('đọc', error);
      return null;
    }
  }

  Future<void> save({required String email, required String password}) async {
    try {
      await Future.wait([
        _storage.write(key: _emailKey, value: email),
        _storage.write(key: _passwordKey, value: password),
      ]);
    } on Object catch (error) {
      _log('ghi', error);
    }
  }

  /// Forgets the saved credentials — e.g. after deleting the account so a gone
  /// account's password is never prefilled.
  Future<void> clear() async {
    try {
      await Future.wait([
        _storage.delete(key: _emailKey),
        _storage.delete(key: _passwordKey),
      ]);
    } on Object catch (error) {
      _log('xoá', error);
    }
  }

  /// Ghi lại chứ không im hẳn: kho khoá hỏng là thứ đáng biết khi đọc log máy
  /// thật, chỉ là không đáng chặn người dùng.
  void _log(String what, Object error) => developer.log(
    'credentials: $what keychain hỏng (${error.runtimeType})',
    name: 'zenpack.storage',
    level: 900,
    error: error,
  );
}

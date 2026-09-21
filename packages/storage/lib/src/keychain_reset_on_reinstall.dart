import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'key_value_store.dart';

/// Wipes platform secure storage (the iOS Keychain) the first time the app
/// runs after a fresh install.
///
/// On iOS the Keychain survives app uninstalls, so secure-storage entries —
/// auth tokens — written by a previous install leak into a freshly reinstalled
/// app and present a stale, unusable session. The [KeyValueStore]
/// (NSUserDefaults / SharedPreferences) *is* cleared on uninstall, so the
/// absence of [_installedFlagKey] reliably marks the first run after an
/// install: at that point we clear secure storage and set the flag, making
/// every later launch a no-op.
@lazySingleton
class KeychainResetOnReinstall {
  KeychainResetOnReinstall(this._store, this._secureStorage);

  final KeyValueStore _store;
  final FlutterSecureStorage _secureStorage;

  static const _installedFlagKey = 'app.installed';

  /// Clears secure storage if this is the first run after an install.
  ///
  /// Await this during bootstrap *before* any secure-storage read (e.g. session
  /// restore). The wipe runs before the flag is set, so a failure part-way
  /// through is retried on the next launch rather than leaving stale data
  /// behind. Safe on every platform: where an uninstall clears prefs and
  /// secure storage together (Android), the wipe is a harmless no-op on empty
  /// storage.
  /// `true` khi đây là LẦN CHẠY ĐẦU sau một lượt cài mới.
  ///
  /// Trả về `bool` chứ không phải `void` vì bên gọi còn việc phải làm mà gói
  /// này không làm hộ được: Firebase Auth cất phiên đăng nhập trong mục
  /// Keychain RIÊNG của nó, mà [FlutterSecureStorage.deleteAll] không với tới.
  /// Nên xoá xong ở đây mà không đăng xuất Firebase thì app cài lại vẫn mở ra
  /// ở trạng thái đã đăng nhập — đúng lỗi người dùng gặp ngày 08/09/2026.
  ///
  /// Gói này KHÔNG tự gọi Firebase: nó là gói lưu trữ, kéo `firebase_auth` vào
  /// đây là buộc mọi thứ dùng nó phải mang theo cả Firebase. Bên gọi
  /// (`main.dart`) có sẵn cả hai thứ và là chỗ đúng để nối chúng lại.
  Future<bool> run() async {
    if (_store.getBool(_installedFlagKey) ?? false) return false;
    await _secureStorage.deleteAll();
    await _store.setBool(_installedFlagKey, true);
    return true;
  }
}

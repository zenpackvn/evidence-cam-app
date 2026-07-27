import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Remembers the last sign-in email + password so the login form can prefill
/// them (product decision: remember the password too, not just the email).
///
/// The password lives only in platform-encrypted storage (iOS Keychain /
/// Android Keystore) via [FlutterSecureStorage] — never in shared preferences.
class CredentialStore {
  const CredentialStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _emailKey = 'auth.saved_email';
  static const _passwordKey = 'auth.saved_password';

  /// The remembered credentials, or null if nothing has been saved yet.
  Future<({String email, String password})?> read() async {
    final email = await _storage.read(key: _emailKey);
    final password = await _storage.read(key: _passwordKey);
    if (email == null && password == null) return null;
    return (email: email ?? '', password: password ?? '');
  }

  Future<void> save({required String email, required String password}) =>
      Future.wait([
        _storage.write(key: _emailKey, value: email),
        _storage.write(key: _passwordKey, value: password),
      ]);

  /// Forgets the saved credentials — e.g. after deleting the account so a gone
  /// account's password is never prefilled.
  Future<void> clear() => Future.wait([
    _storage.delete(key: _emailKey),
    _storage.delete(key: _passwordKey),
  ]);
}

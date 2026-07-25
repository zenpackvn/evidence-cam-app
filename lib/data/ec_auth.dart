/// Authentication seam (FR-15). The app binds [FakeEcAuth] today (login always
/// succeeds, no Firebase) so the journey runs; dropping the Firebase config
/// files in and binding `FirebaseEcAuth` (in `ec_auth_firebase.dart`) makes it
/// real — no screen or router changes.
library;

import 'package:flutter/foundation.dart';

/// A signed-in user. [providers] holds Firebase provider ids
/// (`password` / `google.com` / `apple.com`) so the login-methods screen can
/// show what is linked; [phone] is the editable profile phone.
class EcUser {
  const EcUser({
    required this.uid,
    this.email,
    this.displayName,
    this.phone,
    this.providers = const [],
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? phone;
  final List<String> providers;

  /// Whether [provider] is currently linked to this account.
  bool hasProvider(EcAuthProvider provider) => providers.contains(provider.id);

  /// Whether the account has an email/password credential.
  bool get hasPassword => providers.contains('password');

  EcUser copyWith({
    String? displayName,
    String? phone,
    List<String>? providers,
  }) => EcUser(
    uid: uid,
    email: email,
    displayName: displayName ?? this.displayName,
    phone: phone ?? this.phone,
    providers: providers ?? this.providers,
  );
}

/// Federated sign-in providers that can be linked to the email identity.
enum EcAuthProvider {
  /// Google — Firebase id `google.com`.
  google('google.com'),

  /// Apple — Firebase id `apple.com`.
  apple('apple.com');

  const EcAuthProvider(this.id);

  /// The Firebase provider id.
  final String id;
}

/// Thrown when an auth operation fails a business rule (e.g. wrong current
/// password, unlinking the last provider). Carries a user-facing [message].
class EcAuthException implements Exception {
  const EcAuthException(this.message);
  final String message;
  @override
  String toString() => 'EcAuthException: $message';
}

abstract interface class EcAuth {
  /// Current user as a listenable so screens react to profile / link changes.
  ValueListenable<EcUser?> get user;

  EcUser? get currentUser;

  Future<EcUser> signInWithEmail(String email, String password);
  Future<EcUser> registerWithEmail({
    required String email,
    required String password,
    String? name,
  });
  Future<EcUser> signInWithGoogle();
  Future<EcUser> signInWithApple();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();

  /// Update the display name and/or phone of the current user.
  Future<EcUser> updateProfile({String? name, String? phone});

  /// Change the password, re-checking [currentPassword] first.
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Link a federated provider to the current account.
  Future<EcUser> linkProvider(EcAuthProvider provider);

  /// Unlink a federated provider (never the last remaining credential).
  Future<EcUser> unlinkProvider(EcAuthProvider provider);

  /// Permanently delete the current account.
  Future<void> deleteAccount();

  /// Fresh bearer token for the API (network's AuthTokenProvider binds to this).
  Future<String?> idToken();
}

/// In-memory auth so the app runs before Firebase is configured.
class FakeEcAuth implements EcAuth {
  // ponytail: app-scoped singleton, lives for the process — never disposed.
  final ValueNotifier<EcUser?> _user = ValueNotifier<EcUser?>(null);
  String? _password;

  @override
  ValueListenable<EcUser?> get user => _user;

  @override
  EcUser? get currentUser => _user.value;

  EcUser _signedIn({
    String? email,
    List<String> providers = const ['password'],
  }) => EcUser(
    uid: 'fake-uid',
    email: email ?? 'demo@evidencecam.app',
    displayName: 'Người dùng Demo',
    providers: providers,
  );

  EcUser _require() {
    final u = _user.value;
    if (u == null) throw const EcAuthException('Chưa đăng nhập');
    return u;
  }

  @override
  Future<EcUser> signInWithEmail(String email, String password) async {
    _password = password;
    return _user.value = _signedIn(email: email);
  }

  @override
  Future<EcUser> registerWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    _password = password;
    return _user.value = EcUser(
      uid: 'fake-uid',
      email: email,
      displayName: name,
      providers: const ['password'],
    );
  }

  @override
  Future<EcUser> signInWithGoogle() async {
    _password = null;
    return _user.value = _signedIn(providers: const ['google.com']);
  }

  @override
  Future<EcUser> signInWithApple() async {
    _password = null;
    return _user.value = _signedIn(providers: const ['apple.com']);
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async => _user.value = null;

  @override
  Future<EcUser> updateProfile({String? name, String? phone}) async =>
      _user.value = _require().copyWith(displayName: name, phone: phone);

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _require();
    if (_password == null) {
      throw const EcAuthException('Tài khoản chưa có mật khẩu để đổi');
    }
    if (currentPassword != _password) {
      throw const EcAuthException('Mật khẩu hiện tại không đúng');
    }
    _password = newPassword;
  }

  @override
  Future<EcUser> linkProvider(EcAuthProvider provider) async {
    final u = _require();
    if (u.hasProvider(provider)) return u;
    return _user.value = u.copyWith(providers: [...u.providers, provider.id]);
  }

  @override
  Future<EcUser> unlinkProvider(EcAuthProvider provider) async {
    final u = _require();
    final rest = u.providers.where((p) => p != provider.id).toList();
    if (rest.isEmpty) {
      throw const EcAuthException(
        'Không thể gỡ phương thức đăng nhập cuối cùng',
      );
    }
    return _user.value = u.copyWith(providers: rest);
  }

  @override
  Future<void> deleteAccount() async {
    _password = null;
    _user.value = null;
  }

  @override
  Future<String?> idToken() async => _user.value == null ? null : 'fake-token';
}

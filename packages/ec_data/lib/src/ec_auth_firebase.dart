import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'ec_auth.dart';

/// Real Firebase implementation of [EcAuth] (FR-15) — email/password, Google and
/// Apple, all linking to one account by email. Compiles today; it authenticates
/// once `google-services.json` / `GoogleService-Info.plist` for project
/// `zenpack-e42d1` are present and `Firebase.initializeApp()` has run.
///
/// To go live: `runApp(EcApp(auth: FirebaseEcAuth(), repo: buildRepository()))`
/// after initializing Firebase in `main`.
class FirebaseEcAuth implements EcAuth {
  FirebaseEcAuth([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance {
    _user = ValueNotifier<EcUser?>(_map(_auth.currentUser));
    // ponytail: app-scoped singleton, lives for the process — the subscription
    // and notifier are never disposed. Cancel/dispose if this is ever recreated
    // per-screen.
    _auth.userChanges().listen((u) => _user.value = _map(u));
  }

  final FirebaseAuth _auth;
  late final ValueNotifier<EcUser?> _user;

  EcUser? _map(User? u) => u == null
      ? null
      : EcUser(
          uid: u.uid,
          email: u.email,
          displayName: u.displayName,
          phone: u.phoneNumber,
          providers: u.providerData.map((i) => i.providerId).toList(),
          emailVerified: u.emailVerified,
        );

  User _requireUser() {
    final u = _auth.currentUser;
    if (u == null) throw const EcAuthException('Chưa đăng nhập');
    return u;
  }

  @override
  ValueListenable<EcUser?> get user => _user;

  @override
  EcUser? get currentUser => _map(_auth.currentUser);

  @override
  Future<EcUser> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _map(cred.user)!;
    } on FirebaseAuthException catch (error) {
      throw _authException(error);
    }
  }

  @override
  Future<EcUser> registerWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (name != null) await cred.user?.updateDisplayName(name);
      return _map(cred.user)!;
    } on FirebaseAuthException catch (error) {
      throw _authException(error);
    }
  }

  @override
  Future<EcUser> signInWithGoogle() async {
    try {
      final cred = await _auth.signInWithCredential(await _googleCredential());
      return _map(cred.user)!;
    } on Object catch (error) {
      throw _socialException(error);
    }
  }

  @override
  Future<EcUser> signInWithApple() async {
    try {
      final cred = await _auth.signInWithCredential(await _appleCredential());
      return _map(cred.user)!;
    } on Object catch (error) {
      throw _socialException(error);
    }
  }

  Future<AuthCredential> _googleCredential() async {
    final google = GoogleSignIn.instance;
    await google.initialize();
    final account = await google.authenticate();
    return GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
    );
  }

  Future<AuthCredential> _appleCredential() async {
    final apple = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    return OAuthProvider('apple.com').credential(
      idToken: apple.identityToken,
      accessToken: apple.authorizationCode,
    );
  }

  Future<AuthCredential> _credentialFor(EcAuthProvider provider) =>
      provider == EcAuthProvider.google
      ? _googleCredential()
      : _appleCredential();

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw _authException(error);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _requireUser();
      if (user.emailVerified) return;
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw _authException(error);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<EcUser> updateProfile({String? name, String? phone}) async {
    final u = _requireUser();
    if (name != null) await u.updateDisplayName(name);
    // ponytail: business phone lives in D1 (tech-spec §7), not Firebase Auth —
    // wire to the profile endpoint when it lands; ignored here.
    await u.reload();
    return _map(_auth.currentUser)!;
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final u = _requireUser();
    final email = u.email;
    if (email == null) {
      throw const EcAuthException('Tài khoản không có email để xác thực');
    }
    try {
      await u.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: currentPassword),
      );
      await u.updatePassword(newPassword);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'wrong-password' ||
          error.code == 'invalid-credential') {
        throw const EcAuthException('Mật khẩu hiện tại không đúng.');
      }
      throw _authException(error);
    }
  }

  @override
  Future<EcUser> createPassword({required String newPassword}) async {
    final u = _requireUser();
    final email = u.email;
    if (email == null) {
      throw const EcAuthException('Tài khoản không có email để tạo mật khẩu');
    }
    if (u.providerData.any((p) => p.providerId == 'password')) {
      throw const EcAuthException('Tài khoản đã có mật khẩu');
    }
    try {
      final cred = await u.linkWithCredential(
        EmailAuthProvider.credential(email: email, password: newPassword),
      );
      return _map(cred.user)!;
    } on FirebaseAuthException catch (error) {
      throw _authException(error);
    }
  }

  @override
  Future<EcUser> linkProvider(EcAuthProvider provider) async {
    try {
      final cred = await _requireUser().linkWithCredential(
        await _credentialFor(provider),
      );
      return _map(cred.user)!;
    } on Object catch (error) {
      throw _socialException(error);
    }
  }

  @override
  Future<EcUser> unlinkProvider(EcAuthProvider provider) async {
    try {
      final u = await _requireUser().unlink(provider.id);
      return _map(u)!;
    } on FirebaseAuthException catch (error) {
      throw _authException(error);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _requireUser().delete();
    } on FirebaseAuthException catch (error) {
      throw _authException(error);
    }
  }

  @override
  Future<String?> idToken() =>
      _auth.currentUser?.getIdToken() ?? Future<String?>.value();
}

EcAuthException _authException(FirebaseAuthException error) {
  final message = switch (error.code) {
    'account-exists-with-different-credential' =>
      'Email này đã đăng ký bằng phương thức khác. Hãy đăng nhập bằng phương thức hiện có rồi liên kết tài khoản trong mục Tài khoản.',
    'email-already-in-use' =>
      'Email này đã có tài khoản. Vui lòng đăng nhập hoặc dùng Quên mật khẩu.',
    'wrong-password' ||
    'invalid-credential' ||
    'invalid-login-credentials' => 'Email hoặc mật khẩu không đúng.',
    'user-not-found' => 'Không tìm thấy tài khoản với email này.',
    'user-disabled' => 'Tài khoản đã bị khoá, vui lòng liên hệ hỗ trợ.',
    'invalid-email' => 'Email không hợp lệ.',
    'weak-password' => 'Mật khẩu quá yếu, cần ít nhất 6 ký tự.',
    'too-many-requests' =>
      'Bạn đã thử quá nhiều lần, vui lòng đợi ít phút rồi thử lại.',
    'requires-recent-login' =>
      'Vui lòng đăng nhập lại rồi thử lại thao tác này.',
    'credential-already-in-use' =>
      'Phương thức này đã liên kết với một tài khoản khác.',
    'provider-already-linked' => 'Phương thức này đã được liên kết.',
    'no-such-provider' => 'Tài khoản chưa liên kết phương thức này.',
    'network-request-failed' => 'Không có kết nối mạng, vui lòng thử lại.',
    // ponytail: never surface error.message — it's technical English like
    // "[firebase_auth/...]". Unmapped codes get a clean generic line.
    _ => 'Không thực hiện được, vui lòng thử lại.',
  };
  return EcAuthException(message);
}

/// Normalizes a federated (Google/Apple) sign-in/link failure: Firebase errors
/// map by code, a user cancellation becomes [EcAuthCancelled] (silent), an
/// already-friendly [EcAuthException] passes through, and anything else gets a
/// clean generic line instead of a raw provider-exception string.
Exception _socialException(Object error) {
  if (error is EcAuthException) return error;
  if (error is FirebaseAuthException) return _authException(error);
  if (_isSignInCancellation(error)) return const EcAuthCancelled();
  return const EcAuthException('Không thực hiện được, vui lòng thử lại.');
}

bool _isSignInCancellation(Object error) {
  if (error is GoogleSignInException) {
    return error.code == GoogleSignInExceptionCode.canceled;
  }
  if (error is SignInWithAppleAuthorizationException) {
    return error.code == AuthorizationErrorCode.canceled;
  }
  return false;
}

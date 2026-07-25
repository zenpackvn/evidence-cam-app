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
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _map(cred.user)!;
  }

  @override
  Future<EcUser> registerWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (name != null) await cred.user?.updateDisplayName(name);
    return _map(cred.user)!;
  }

  @override
  Future<EcUser> signInWithGoogle() async {
    final cred = await _auth.signInWithCredential(await _googleCredential());
    return _map(cred.user)!;
  }

  @override
  Future<EcUser> signInWithApple() async {
    final cred = await _auth.signInWithCredential(await _appleCredential());
    return _map(cred.user)!;
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
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

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
    await u.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: email, password: currentPassword),
    );
    await u.updatePassword(newPassword);
  }

  @override
  Future<EcUser> linkProvider(EcAuthProvider provider) async {
    final cred = await _requireUser().linkWithCredential(
      await _credentialFor(provider),
    );
    return _map(cred.user)!;
  }

  @override
  Future<EcUser> unlinkProvider(EcAuthProvider provider) async {
    final u = await _requireUser().unlink(provider.id);
    return _map(u)!;
  }

  @override
  Future<void> deleteAccount() => _requireUser().delete();

  @override
  Future<String?> idToken() =>
      _auth.currentUser?.getIdToken() ?? Future<String?>.value();
}

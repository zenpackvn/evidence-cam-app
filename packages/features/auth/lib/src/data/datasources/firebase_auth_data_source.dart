import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

/// Thin wrapper over FirebaseAuth + Google Sign-In (SM-000 BR-01).
///
/// Owns the provider mechanics (email/password, Google) and exposes the current
/// user's ID token for the network layer. Higher layers depend on this, not on
/// `firebase_auth` directly, so the Firebase surface stays in one place.
@lazySingleton
class FirebaseAuthDataSource {
  FirebaseAuthDataSource();

  /// Resolved lazily on each use, NOT cached in the constructor: this singleton
  /// may be created (via AuthRepository → AuthBloc) before
  /// `Firebase.initializeApp()` runs, and caching `FirebaseAuth.instance` then
  /// would bind to an unconfigured app ("No app has been configured yet").
  FirebaseAuth get _auth => FirebaseAuth.instance;
  GoogleSignIn get _google => GoogleSignIn.instance;

  bool _googleInitialized = false;

  User? get currentUser => _auth.currentUser;

  /// Fresh ID token for the signed-in user, or null when signed out. Firebase
  /// caches it and only refreshes when near expiry; pass [forceRefresh] after a
  /// 401 to mint a new one.
  Future<String?> idToken({bool forceRefresh = false}) =>
      _auth.currentUser?.getIdToken(forceRefresh) ?? Future.value();

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> registerWithEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  /// Interactive Google sign-in (google_sign_in v7 API).
  Future<UserCredential> signInWithGoogle() async {
    if (!_googleInitialized) {
      await _google.initialize();
      _googleInitialized = true;
    }
    final account = await _google.authenticate();
    final auth = account.authentication;
    final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
    return _auth.signInWithCredential(credential);
  }

  /// Reauthenticates with the current password, then sets a new one (BR-12).
  Future<void> changePassword(String current, String next) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(code: 'no-current-user');
    }
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: current,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(next);
  }

  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  Future<void> deleteAccount() => _auth.currentUser?.delete() ?? Future.value();
}

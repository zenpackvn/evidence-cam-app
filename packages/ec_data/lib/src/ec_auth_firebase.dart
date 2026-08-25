import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'ec_auth.dart';

import 'ec_google_signin.dart';

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

  /// Gửi mail xác thực qua máy chủ mình thay vì để Firebase gửi.
  ///
  /// Firebase đã khoá phần thân của mẫu xác thực trong Console, nên để nó gửi là
  /// gửi chữ mẫu của Google — người dùng app sẽ nhận một lá thư khác hẳn thứ
  /// người dùng web nhận, dù cả hai cùng một hệ thống.
  ///
  /// GÁN SAU khi dựng, không nhận qua hàm dựng: `EcApi` cần chính đối tượng này
  /// để gắn `Authorization`, nên hai bên phụ thuộc vòng. Vắng nó thì lớp này rơi
  /// hẳn về Firebase — đúng hành vi cũ, và là mặc định trong test.
  EcAuthMailApi? mailApi;

  late final ValueNotifier<EcUser?> _user;

  EcUser? _map(User? u) => u == null
      ? null
      : EcUser(
          uid: u.uid,
          email: u.email,
          displayName: u.displayName,
          phone: u.phoneNumber,
          photoUrl: u.photoURL,
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
    // Qua [ensureGoogleSignInReady] chứ không tự gọi `initialize()`: singleton
    // này chỉ chịu được đúng một lượt khởi tạo, và lượt cắm Google Drive cũng
    // cần chính nó.
    await ensureGoogleSignInReady();
    final account = await GoogleSignIn.instance.authenticate();
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

  /// Máy chủ mình trước, Firebase là ĐƯỜNG LÙI.
  ///
  /// Rơi về khi máy chủ chưa cấu hình (503) hoặc gọi hỏng: mail chữ Google vẫn
  /// hơn hẳn không có mail nào, vì người quên mật khẩu là người đang không vào
  /// được tài khoản.
  @override
  Future<void> sendPasswordReset(String email) async {
    if (mailApi != null) {
      try {
        await mailApi!.sendPasswordReset(email);
        return;
      } on Object {
        // Đường lùi.
      }
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw _authException(error);
    }
  }

  @override
  /// Máy chủ mình trước, Firebase là ĐƯỜNG LÙI — cùng lẽ với
  /// [sendPasswordReset].
  Future<void> sendEmailVerification() async {
    final user = _requireUser();
    if (user.emailVerified) return;
    if (mailApi != null) {
      try {
        await mailApi!.sendVerifyEmail();
        return;
      } on Object {
        // Đường lùi.
      }
    }
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw _authException(error);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<EcUser> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    final u = _requireUser();
    if (name != null) await u.updateDisplayName(name);
    // Ảnh đại diện nằm trên Firebase Auth như tên: nhờ vậy nó theo tài khoản,
    // đăng nhập máy nào cũng có. `photoUrl` phải là URL đọc công khai —
    // `updatePhotoURL` không nhận đường dẫn file trên máy.
    if (photoUrl != null) await u.updatePhotoURL(photoUrl);
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
/// clean line that at least says WHICH kind of thing went wrong.
///
/// Mọi lượt hỏng không phải "người dùng bấm Huỷ" đều được ghi log kèm mã và
/// mô tả gốc. Trước đây tất cả đổ chung vào một câu "vui lòng thử lại" và
/// không ghi lại gì: một máy ký bằng keystore chưa đăng ký SHA-1 trên Firebase
/// hỏng y hệt một máy mất mạng, nhìn từ ngoài không tài nào phân biệt được.
Exception _socialException(Object error) {
  if (error is EcAuthException) return error;
  if (error is FirebaseAuthException) return _authException(error);
  if (_isSignInCancellation(error)) return const EcAuthCancelled();
  _logSocialFailure(error);
  if (error is GoogleSignInException) return _googleException(error);
  return const EcAuthException('Không thực hiện được, vui lòng thử lại.');
}

void _logSocialFailure(Object error) {
  final detail = error is GoogleSignInException
      ? '${error.code.name}: ${error.description}'
      : '$error';
  developer.log(
    'auth: lượt đăng nhập mạng xã hội hỏng — $detail',
    name: 'zenpack.auth',
    level: 1000,
    error: error,
  );
}

/// Câu tiếng Việt cho một lượt Google hỏng, tách theo mã để người dùng biết
/// việc cần làm thay vì chỉ biết "hỏng rồi".
EcAuthException _googleException(GoogleSignInException error) {
  // Trên Android, "không tìm được thông tin đăng nhập nào" là mã `unknownError`
  // kèm mô tả bắt đầu bằng 'No credential available' — xem
  // `google_sign_in_android`, nhánh `GetCredentialFailureType.noCredential`.
  // Máy chưa thêm tài khoản Google rơi vào đúng đây.
  if (error.code == GoogleSignInExceptionCode.unknownError &&
      (error.description ?? '').startsWith('No credential available')) {
    return const EcAuthException(
      'Máy chưa có tài khoản Google nào dùng được. Hãy thêm tài khoản Google '
      'trong Cài đặt rồi thử lại.',
    );
  }
  // Lượt hỏng của Play services đội lốt `canceled` — xem
  // [_isSignInCancellation]. Kèm luôn mã trạng thái GMS vào câu báo: đó là thứ
  // DUY NHẤT bộ phận hỗ trợ bám được để biết máy này hỏng vì gì, mà người dùng
  // thì không có cách nào đọc log ra để đọc cho họ nghe.
  final gmsStatus = googleServicesStatusCode(error);
  if (error.code == GoogleSignInExceptionCode.canceled && gmsStatus != null) {
    return EcAuthException(
      'Google chưa cấp được quyền đăng nhập cho ứng dụng (mã $gmsStatus). Vui '
      'lòng thử lại; nếu vẫn vậy, báo bộ phận hỗ trợ kèm mã này.',
    );
  }
  return switch (error.code) {
    // Sai cấu hình phía bản cài: SHA-1 của keystore chưa đăng ký trên Firebase,
    // thiếu `serverClientId`, hoặc máy không có Play services dùng được. Không
    // có thao tác nào của người dùng cứu được, nên nói thẳng là báo hỗ trợ.
    GoogleSignInExceptionCode.clientConfigurationError ||
    GoogleSignInExceptionCode.providerConfigurationError =>
      const EcAuthException(
        'Đăng nhập bằng Google chưa dùng được trên bản cài này. Vui lòng cập '
        'nhật ứng dụng và Google Play services, hoặc báo bộ phận hỗ trợ.',
      ),
    GoogleSignInExceptionCode.interrupted ||
    GoogleSignInExceptionCode.uiUnavailable => const EcAuthException(
      'Không mở được hộp thoại Google, vui lòng thử lại.',
    ),
    _ => const EcAuthException('Không thực hiện được, vui lòng thử lại.'),
  };
}

bool _isSignInCancellation(Object error) {
  // Một mã `canceled` từ Google KHÔNG chắc là người dùng bấm huỷ — xem
  // [isGoogleSignInCancellation].
  if (error is GoogleSignInException) {
    return isGoogleSignInCancellation(error);
  }
  if (error is SignInWithAppleAuthorizationException) {
    return error.code == AuthorizationErrorCode.canceled;
  }
  return false;
}

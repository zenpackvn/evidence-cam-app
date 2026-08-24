/// Authentication seam (FR-15). The app binds `FirebaseEcAuth` (in
/// `ec_auth_firebase.dart`) — the only implementation that ships. Tests bind
/// their own double (`test/ec_fakes.dart`); there is no in-app fallback, so a
/// build without Firebase config fails loudly instead of faking a session.
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
    this.photoUrl,
    this.providers = const [],
    this.emailVerified = true,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? phone;

  /// URL đọc công khai của ảnh đại diện, lấy từ Firebase Auth. Nhờ nằm ở đó
  /// nên ảnh theo tài khoản chứ không theo máy.
  final String? photoUrl;
  final List<String> providers;

  /// Whether the email address has been confirmed through the verification
  /// link. Federated sign-ins (Google/Apple) are verified by the provider;
  /// only fresh email/password accounts start out false. Defaults to true so a
  /// backend that cannot tell never locks anyone out.
  final bool emailVerified;

  /// Whether [provider] is currently linked to this account.
  bool hasProvider(EcAuthProvider provider) => providers.contains(provider.id);

  /// Whether the account has an email/password credential.
  bool get hasPassword => providers.contains('password');

  EcUser copyWith({
    String? displayName,
    String? phone,
    String? photoUrl,
    List<String>? providers,
    bool? emailVerified,
  }) => EcUser(
    uid: uid,
    email: email,
    displayName: displayName ?? this.displayName,
    phone: phone ?? this.phone,
    photoUrl: photoUrl ?? this.photoUrl,
    providers: providers ?? this.providers,
    emailVerified: emailVerified ?? this.emailVerified,
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

/// Thrown when the user backs out of a federated sign-in (taps cancel/back on
/// the Google/Apple sheet). Carries no message — the UI ignores it silently
/// rather than showing a spurious error toast.
class EcAuthCancelled implements Exception {
  const EcAuthCancelled();
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

  /// Send the address-verification email to the signed-in user. Called right
  /// after registration, while the freshly created account is still signed in.
  Future<void> sendEmailVerification();

  Future<void> signOut();

  /// Update the display name and/or phone of the current user.
  Future<EcUser> updateProfile({String? name, String? phone, String? photoUrl});

  /// Change the password, re-checking [currentPassword] first.
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Add the first email/password credential to a social-only account.
  Future<EcUser> createPassword({required String newPassword});

  /// Link a federated provider to the current account.
  Future<EcUser> linkProvider(EcAuthProvider provider);

  /// Unlink a federated provider (never the last remaining credential).
  Future<EcUser> unlinkProvider(EcAuthProvider provider);

  /// Permanently delete the current account.
  Future<void> deleteAccount();

  /// Fresh bearer token for the API (network's AuthTokenProvider binds to this).
  Future<String?> idToken();
}

/// Đúng hai việc mà lớp xác thực cần từ máy chủ của mình.
///
/// Giao diện hẹp thay vì nhận cả `EcApi`: lớp xác thực không có lý do gì để với
/// tới vận đơn hay kho lưu trữ, và một phụ thuộc rộng là thứ sẽ bị dùng rộng.
abstract class EcAuthMailApi {
  Future<void> sendVerifyEmail();
  Future<void> sendPasswordReset(String email);
}

import 'package:architecture/architecture.dart';
import 'package:shared_contracts/shared_contracts.dart';

abstract interface class AuthRepository {
  /// Signs in with email + password (Firebase), then loads the StampMail
  /// profile. [username] carries the email for the email/password provider.
  Future<Result<AuthUser>> signIn({
    required String username,
    required String password,
  });

  Future<Result<AuthUser>> register({
    required String username,
    required String password,
  });

  /// Interactive Google sign-in, then loads the StampMail profile.
  Future<Result<AuthUser>> signInWithGoogle();

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Result<void>> signOut();

  /// Permanently deletes the current account on the server and clears the
  /// local session. Unlike [signOut], the local session is only cleared when
  /// the server confirms the deletion, so a failure leaves the user signed in.
  Future<Result<void>> deleteAccount();

  /// Loads any persisted session and attempts to refresh its access token.
  /// Returns `Ok(user)` if a valid session can be restored, otherwise `Err`.
  Future<Result<AuthUser>> restoreSession();

  /// Emails the signed-in user a verification link (SM-001 BR-02). Each send
  /// invalidates the previous link.
  Future<Result<void>> sendEmailVerification();

  /// Whether the signed-in user's email is verified (fresh from the server).
  Future<Result<bool>> checkEmailVerified();

  /// Emails a password-reset link (SM-001 BR-12). Never reveals whether the
  /// email exists — an unknown address still resolves `Ok`.
  Future<Result<void>> sendPasswordReset(String email);

  AuthUser? get currentUser;
}

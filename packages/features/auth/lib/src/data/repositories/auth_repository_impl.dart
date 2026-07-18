import 'package:architecture/architecture.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';
import 'package:shared_contracts/shared_contracts.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/firebase_auth_data_source.dart';
import '../datasources/sm_user_data_source.dart';

/// Firebase-backed auth (SM-000): the provider mechanics live in
/// [FirebaseAuthDataSource]; after a successful sign-in the StampMail profile is
/// loaded from the backend ([SmUserDataSource]) — the backend auto-provisions a
/// Free profile on first call. The bearer token for `/api/sm/*` comes from
/// Firebase via the network [AuthTokenProvider], so no tokens are persisted
/// here; only the resolved [AuthUser] is cached locally for a synchronous
/// `currentUser`.
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._firebase,
    this._smUser,
    this._local,
    this._tokenProvider,
  ) {
    // Point the network interceptor at Firebase's ID token. One-way binding
    // (network → Firebase) so the network package stays firebase-free.
    _tokenProvider.bind(_firebase.idToken);
  }

  final FirebaseAuthDataSource _firebase;
  final SmUserDataSource _smUser;
  final AuthLocalDataSource _local;
  final AuthTokenProvider _tokenProvider;

  @override
  AuthUser? get currentUser => _local.currentUser;

  @override
  Future<Result<AuthUser>> signIn({
    required String username,
    required String password,
  }) => _afterSignIn(() => _firebase.signInWithEmail(username, password));

  @override
  Future<Result<AuthUser>> register({
    required String username,
    required String password,
  }) => _afterSignIn(() async {
    final cred = await _firebase.registerWithEmail(username, password);
    // SM-001 BR-02: email sign-ups get a verification link right away. Best
    // effort — the waiting screen offers resend if this send fails.
    try {
      await _firebase.sendEmailVerification();
    } on FirebaseAuthException {
      // ignore: resend is available on the waiting screen.
    }
    return cred;
  });

  @override
  Future<Result<AuthUser>> signInWithGoogle() =>
      _afterSignIn(_firebase.signInWithGoogle);

  /// Runs a Firebase sign-in action, then loads + caches the profile. Maps
  /// Firebase and network errors to domain failures.
  Future<Result<AuthUser>> _afterSignIn(
    Future<Object?> Function() action,
  ) async {
    try {
      await action();
      final user = await _smUser.me();
      await _local.cacheUser(user);
      return Ok(user);
    } on FirebaseAuthException catch (e) {
      return Err(_mapFirebaseError(e));
    } on Object {
      return const Err(UnknownFailure('Sign-in failed. Please try again.'));
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _firebase.changePassword(currentPassword, newPassword);
      return const Ok(null);
    } on FirebaseAuthException catch (e) {
      return Err(_mapFirebaseError(e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    await _firebase.signOut();
    await _local.clearSession();
    return const Ok(null);
  }

  @override
  Future<Result<void>> signOutAllDevices() async {
    // Revoke first: only once the server confirms every session is gone may the
    // local one be dropped. The reverse order would sign this device out and
    // leave the user unable to tell that the others are still logged in.
    try {
      await _smUser.revokeSessions();
    } on DioException catch (e) {
      return Err(_mapRevokeError(e));
    }
    await _firebase.signOut();
    await _local.clearSession();
    return const Ok(null);
  }

  /// Maps a failed revoke. The endpoint takes no input and needs only the
  /// caller's token, so there is nothing the user can correct — the only
  /// distinction worth drawing is "you're offline" from "the server refused".
  Failure _mapRevokeError(DioException e) {
    const offline = {
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
    };
    if (offline.contains(e.type)) {
      return const UnknownFailure(
        'Không có kết nối. Chưa đăng xuất được thiết bị nào.',
      );
    }
    if (e.response?.statusCode == 401) {
      return const NoSessionFailure();
    }
    return const UnknownFailure(
      'Không đăng xuất được các thiết bị. Vui lòng thử lại.',
    );
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _firebase.deleteAccount();
      await _local.clearSession();
      return const Ok(null);
    } on FirebaseAuthException catch (e) {
      return Err(_mapFirebaseError(e));
    }
  }

  @override
  Future<Result<AuthUser>> restoreSession() async {
    await _local.load();
    if (_firebase.currentUser == null) {
      await _local.clearSession();
      return const Err(NoSessionFailure());
    }
    // Signed-in Firebase user: refresh the cached profile. On a network error
    // fall back to the cached user so offline launches keep the session.
    try {
      final user = await _smUser.me();
      await _local.cacheUser(user);
      return Ok(user);
    } on Object {
      final cached = _local.currentUser;
      return cached != null ? Ok(cached) : const Err(NoSessionFailure());
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      await _firebase.sendEmailVerification();
      return const Ok(null);
    } on FirebaseAuthException catch (e) {
      return Err(_mapFirebaseError(e));
    }
  }

  @override
  Future<Result<bool>> checkEmailVerified() async {
    try {
      return Ok(await _firebase.reloadEmailVerified());
    } on FirebaseAuthException catch (e) {
      return Err(_mapFirebaseError(e));
    }
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) async {
    try {
      await _firebase.sendPasswordResetEmail(email);
      return const Ok(null);
    } on FirebaseAuthException catch (e) {
      // BR-12: never reveal whether the email exists.
      if (e.code == 'user-not-found') return const Ok(null);
      return Err(_mapFirebaseError(e));
    }
  }

  Failure _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-email':
        return const InvalidCredentialsFailure(
          'Email hoặc mật khẩu không đúng.',
        );
      case 'email-already-in-use':
        return const InvalidCredentialsFailure('Email này đã được đăng ký.');
      case 'weak-password':
        return const InvalidCredentialsFailure(
          'Mật khẩu quá yếu (tối thiểu 6 ký tự).',
        );
      case 'network-request-failed':
        return const UnknownFailure('Không có kết nối mạng.');
      default:
        return UnknownFailure(e.message ?? 'Đăng nhập thất bại.');
    }
  }
}

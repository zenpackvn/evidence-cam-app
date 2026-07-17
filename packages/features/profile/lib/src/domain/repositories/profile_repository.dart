import 'package:architecture/architecture.dart';

import '../entities/user_profile.dart';

/// SM-024 BR-09 / AC-11: shown when a save is attempted with no connection.
/// Nothing is sent, and the form keeps what the user typed.
const String offlineSaveMessage =
    'Không có kết nối. Vui lòng thử lại khi có mạng.';

/// Reads and edits the signed-in user's own profile (SM-024).
abstract class ProfileRepository {
  /// Loads the caller's profile from `/api/sm/me`.
  Future<Result<UserProfile>> me();

  /// Applies a partial edit (BR-02, BR-03, BR-06) and returns the stored
  /// profile.
  ///
  /// Failures use the shared vocabulary, mapped so the caller can route each to
  /// the right place:
  /// - [PermissionFailure] — the BR-03 username allowance is spent (AC-04);
  ///   only a username change can produce it, so it belongs on that field;
  /// - [ValidationFailure] — a value was refused (a taken username, §5, or a
  ///   value the server rejected);
  /// - [UnknownFailure] with [offlineSaveMessage] — offline (BR-09 / AC-11);
  /// - [NotFoundFailure] — the profile is gone.
  Future<Result<UserProfile>> update(ProfileEdit edit);
}

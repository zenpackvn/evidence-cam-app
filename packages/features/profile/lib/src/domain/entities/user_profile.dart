import 'birth_date.dart';

/// The signed-in user's own profile (SM-024), as served by `/api/sm/me`.
///
/// Profiles are fully private: every field here belongs to the account owner
/// and is never shown to anyone else (BR-04).
class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    this.displayName = '',
    this.birthDate,
    this.usernameChangesLeft = 0,
    this.avatarUrl = '',
    this.isPremium = false,
    this.stampsCreated = 0,
    this.lettersSent = 0,
  });

  final String id;
  final String username;

  /// SM-024 BR-02: freely editable, at most 30 characters. Empty means the UI
  /// falls back to the username.
  final String displayName;

  /// SM-024 BR-06: `null` when the user has none set.
  final BirthDate? birthDate;

  /// SM-024 BR-03: how many username changes remain. 0 locks the field for
  /// good (AC-04).
  final int usernameChangesLeft;

  final String avatarUrl;
  final bool isPremium;

  /// SM-024 BR-04: owner-only activity stats.
  final int stampsCreated;
  final int lettersSent;

  /// Whether the username may still be changed (BR-03).
  bool get canChangeUsername => usernameChangesLeft > 0;

  /// The name to show, falling back to the username when no display name is set.
  String get effectiveName => displayName.isEmpty ? username : displayName;

  UserProfile copyWith({
    String? displayName,
    BirthDate? birthDate,
    bool clearBirthDate = false,
    String? username,
    int? usernameChangesLeft,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      usernameChangesLeft: usernameChangesLeft ?? this.usernameChangesLeft,
      avatarUrl: avatarUrl,
      isPremium: isPremium,
      stampsCreated: stampsCreated,
      lettersSent: lettersSent,
    );
  }
}

/// A partial profile edit (SM-024, `PATCH /api/sm/me`).
///
/// A `null` field is left untouched by the server — that is what separates an
/// unedited field from one the user deliberately emptied. Clearing the birthday
/// is therefore its own flag ([clearBirthDate], AC-07) rather than a null
/// [birthDate].
class ProfileEdit {
  const ProfileEdit({
    this.displayName,
    this.birthDate,
    this.clearBirthDate = false,
    this.username,
  });

  final String? displayName;
  final BirthDate? birthDate;
  final bool clearBirthDate;
  final String? username;
}

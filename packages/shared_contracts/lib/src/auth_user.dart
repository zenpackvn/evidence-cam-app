/// Authenticated user identity exposed to the presentation layer.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    this.stampsCreated = 0,
    this.lettersSent = 0,
  });

  final String id;
  final String username;

  /// Owner-only activity stats from `/api/sm/me` (SM-024 BR-04): total stamps
  /// created and letters sent. Profiles are fully private, so these never
  /// come from anyone else's profile.
  final int stampsCreated;
  final int lettersSent;
}

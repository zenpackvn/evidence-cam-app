import 'package:flutter/foundation.dart';

/// The identity shown in app chrome (the Home greeting): the account's profile
/// display name and avatar. Lives here so Home can show what Profile edits
/// without the two features depending on each other.
@immutable
class ProfileHeader {
  const ProfileHeader({this.displayName, this.avatarUrl});

  factory ProfileHeader.fromJson(Map<String, dynamic> json) => ProfileHeader(
    displayName: json['display_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
  );

  final String? displayName;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
    'display_name': displayName,
    'avatar_url': avatarUrl,
  };
}

/// App-wide, listenable holder of the current account's [ProfileHeader].
///
/// A process-wide singleton so Profile (the writer) and Home (the reader) share
/// one instance without a cross-feature import. Persistence is delegated to
/// [persist] — wired by the app shell to SharedPreferences keyed by uid — so
/// this stays free of any storage dependency and the edit survives a re-login.
class ProfileHeaderStore extends ChangeNotifier {
  ProfileHeaderStore._();

  static final ProfileHeaderStore instance = ProfileHeaderStore._();

  ProfileHeader? _value;
  ProfileHeader? get value => _value;

  /// Persist hook set by the app shell; invoked on every [update] with the uid
  /// so each account's header is stored separately.
  void Function(String uid, ProfileHeader header)? persist;

  /// A local profile edit: update the in-memory value, persist it, and notify.
  void update(String uid, ProfileHeader header) {
    _value = header;
    persist?.call(uid, header);
    notifyListeners();
  }

  /// Sets the value without persisting — used to restore an account's saved
  /// header on sign-in, or to clear it (null) on sign-out.
  void restore(ProfileHeader? header) {
    _value = header;
    notifyListeners();
  }
}

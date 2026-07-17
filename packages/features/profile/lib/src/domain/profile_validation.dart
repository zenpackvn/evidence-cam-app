/// Client-side profile validation (SM-024 BR-02, BR-03, BR-06).
///
/// These mirror the server's rules so the form can report a problem at the
/// offending field before a round-trip (§5: "báo lỗi ngay tại ô nhập"). The
/// server re-validates regardless — this is UX, not enforcement.
library;

import 'entities/user_profile.dart';

/// SM-024 BR-02: the display name is capped at thirty characters.
const int displayNameMaxLength = 30;

/// SM-000 BR-04: username length bounds, still enforced on a change.
const int usernameMinLength = 3;
const int usernameMaxLength = 30;

/// SM-024 BR-06: the earliest plausible birth year.
const int minBirthYear = 1900;

/// Validates the display name (BR-02). Returns the error to show under the
/// field, or `null` when it is acceptable. An empty name is allowed — the
/// profile falls back to the username.
String? validateDisplayName(String value) {
  if (value.trim().characters > displayNameMaxLength) {
    return 'Tên hiển thị tối đa $displayNameMaxLength ký tự';
  }
  return null;
}

/// Validates a username the user wants to switch to (BR-03 + SM-000 BR-04).
/// [profile] supplies the remaining allowance; re-submitting the name you
/// already have is always fine and spends nothing.
String? validateUsername(String value, UserProfile profile) {
  final name = value.trim();
  if (name == profile.username) return null;
  if (!profile.canChangeUsername) {
    return 'Bạn đã hết lượt đổi tên người dùng';
  }
  final length = name.characters;
  if (length < usernameMinLength || length > usernameMaxLength) {
    return 'Tên người dùng phải từ $usernameMinLength đến $usernameMaxLength ký tự';
  }
  return null;
}

/// Validates a birthday (BR-06). [day] and [month] are required together;
/// [year] is optional. All three empty means "no birthday", which is valid —
/// the field is optional and may be cleared at any time (AC-07).
///
/// Returns the error to show under the birthday field, or `null` when valid.
String? validateBirthDate({int? day, int? month, int? year, int? currentYear}) {
  if (day == null && month == null && year == null) return null;
  if (day == null || month == null) {
    return 'Vui lòng nhập cả ngày và tháng sinh';
  }
  if (month < 1 || month > 12) return 'Tháng sinh không hợp lệ';
  final thisYear = currentYear ?? DateTime.now().year;
  if (year != null && (year < minBirthYear || year > thisYear)) {
    return 'Năm sinh không hợp lệ';
  }
  // With no year given, check the day against a leap year so 29/02 stays valid.
  if (day < 1 || day > _daysInMonth(year ?? _leapProbeYear, month)) {
    return 'Ngày sinh không hợp lệ';
  }
  return null;
}

/// A leap year, used to validate a day/month pair when the user omitted the
/// year (BR-06) so 29 February is accepted.
const int _leapProbeYear = 2000;

/// Day 0 of the next month is the last day of this one.
int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

extension on String {
  /// Length in user-perceived characters, so a Vietnamese name is not
  /// over-counted by its code units.
  int get characters => runes.length;
}

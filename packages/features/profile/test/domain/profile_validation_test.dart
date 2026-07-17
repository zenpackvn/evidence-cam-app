// Unit tests for the client-side profile rules (SM-024 BR-02, BR-03, BR-06).
// These mirror the server so the form can flag a problem at the field itself
// (§5) before a round-trip.

import 'package:feature_profile/feature_profile.dart';
// The validators are feature-internal; the tests reach them through the
// package's src path the same way the form does.
import 'package:feature_profile/src/domain/profile_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const profile = UserProfile(
    id: 'u1',
    username: 'alice',
    usernameChangesLeft: 1,
  );

  group('validateDisplayName (BR-02)', () {
    test('accepts a name within thirty characters', () {
      expect(validateDisplayName('Alice Nguyễn'), isNull);
    });

    test('accepts an empty name — the profile falls back to the username', () {
      expect(validateDisplayName(''), isNull);
    });

    test('accepts exactly thirty characters', () {
      expect(validateDisplayName('ế' * 30), isNull);
    });

    test('rejects thirty-one characters', () {
      expect(validateDisplayName('a' * 31), 'Tên hiển thị tối đa 30 ký tự');
    });

    test('counts multi-byte characters as one each', () {
      expect(validateDisplayName('ế' * 31), isNotNull);
    });

    test('ignores surrounding whitespace when measuring', () {
      expect(validateDisplayName('  ${'a' * 30}  '), isNull);
    });
  });

  group('validateUsername (BR-03)', () {
    test('accepts a valid new name while a change remains', () {
      expect(validateUsername('alice2', profile), isNull);
    });

    test('AC-04: refuses any change once the allowance is spent', () {
      const locked = UserProfile(
        id: 'u1',
        username: 'alice',
        usernameChangesLeft: 0,
      );
      expect(
        validateUsername('alice2', locked),
        'Bạn đã hết lượt đổi tên người dùng',
      );
    });

    test('re-submitting the current name is fine even when locked', () {
      const locked = UserProfile(
        id: 'u1',
        username: 'alice',
        usernameChangesLeft: 0,
      );
      expect(validateUsername('alice', locked), isNull);
    });

    test('rejects a name shorter than three characters', () {
      expect(validateUsername('ab', profile), isNotNull);
    });

    test('rejects a name longer than thirty characters', () {
      expect(validateUsername('a' * 31, profile), isNotNull);
    });
  });

  group('validateBirthDate (BR-06)', () {
    test('accepts day, month and year', () {
      expect(validateBirthDate(day: 3, month: 4, year: 1990), isNull);
    });

    test('accepts day and month with no year — the year is optional', () {
      expect(validateBirthDate(day: 3, month: 4), isNull);
    });

    test('AC-07: accepts an entirely empty birthday', () {
      expect(validateBirthDate(), isNull);
    });

    test('accepts 29 February when no year is given', () {
      expect(validateBirthDate(day: 29, month: 2), isNull);
    });

    test('requires the month when a day is given', () {
      expect(
        validateBirthDate(day: 3),
        'Vui lòng nhập cả ngày và tháng sinh',
      );
    });

    test('requires the day when a month is given', () {
      expect(validateBirthDate(month: 4), isNotNull);
    });

    test('requires day and month when only a year is given', () {
      expect(validateBirthDate(year: 1990), isNotNull);
    });

    test('rejects an out-of-range month', () {
      expect(validateBirthDate(day: 1, month: 13), 'Tháng sinh không hợp lệ');
      expect(validateBirthDate(day: 1, month: 0), isNotNull);
    });

    test('rejects a day the month does not have', () {
      expect(validateBirthDate(day: 31, month: 4), 'Ngày sinh không hợp lệ');
      expect(validateBirthDate(day: 0, month: 1), isNotNull);
    });

    test('rejects 29 February in a non-leap year', () {
      expect(validateBirthDate(day: 29, month: 2, year: 1999), isNotNull);
    });

    test('rejects an implausible year', () {
      expect(
        validateBirthDate(day: 1, month: 1, year: 1899),
        'Năm sinh không hợp lệ',
      );
      expect(
        validateBirthDate(day: 1, month: 1, year: 2030, currentYear: 2026),
        isNotNull,
      );
    });
  });
}

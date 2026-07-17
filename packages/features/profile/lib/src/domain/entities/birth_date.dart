import 'package:flutter/foundation.dart';

/// A user's optional birthday (SM-024 BR-06).
///
/// [day] and [month] are required together; [year] is optional — the user may
/// give only a day and month. The value is owner-only: it is read from and
/// written to `/api/sm/me`, and never appears on anyone else's profile.
@immutable
class BirthDate {
  const BirthDate({required this.day, required this.month, this.year});

  final int day;
  final int month;

  /// `null` when the user chose not to give a year (BR-06).
  final int? year;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BirthDate &&
          other.day == day &&
          other.month == month &&
          other.year == year;

  @override
  int get hashCode => Object.hash(day, month, year);

  @override
  String toString() => 'BirthDate($day/$month/${year ?? '—'})';
}

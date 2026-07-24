# Extension Methods

Extension methods add behavior to types you don't own without subclassing.

## `BuildContext` extensions

```dart
// lib/src/core/extensions/build_context_x.dart
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isMobile => MediaQuery.sizeOf(this).width < 600;
  bool get isTablet => MediaQuery.sizeOf(this).width >= 600;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
```

## `String` extensions

```dart
// lib/src/core/extensions/string_x.dart
extension StringX on String {
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');
  bool get isValidEmail => RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  String truncate(int maxLength, {String ellipsis = '...'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';
}
```

## `DateTime` extensions

```dart
// lib/src/core/extensions/date_time_x.dart
import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String get formatted => DateFormat('MMM d, y').format(this);
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30)  return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0)   return '${diff.inDays}d ago';
    if (diff.inHours > 0)  return '${diff.inHours}h ago';
    return 'just now';
  }
  bool get isToday     => DateUtils.isSameDay(this, DateTime.now());
  bool get isYesterday => DateUtils.isSameDay(this, DateTime.now().subtract(const Duration(days: 1)));
}
```

## Nullable extensions

```dart
// lib/src/core/extensions/nullable_x.dart
extension NullableX<T> on T? {
  T orDefault(T fallback) => this ?? fallback;
  R? mapOrNull<R>(R Function(T) transform) => this == null ? null : transform(this as T);
}
```

## Rules

- Name extension files with the `_x` suffix (e.g. `build_context_x.dart`, `string_x.dart`).
- Prefer extensions over static utility function files (`utils.dart`) — attach behavior directly to the relevant type.
- Keep extensions focused: one file per extended type.

part of 'locale_bloc.dart';

/// The active app language. Defaults to English; the user can switch to any
/// language with a bundled translation.
@immutable
class LocaleState {
  const LocaleState(this.locale);

  /// The app's default language when nothing is persisted. Change this to the
  /// locale your app ships first.
  static const defaultLocale = Locale('en');

  final Locale locale;

  @override
  bool operator ==(Object other) =>
      other is LocaleState && other.locale == locale;

  @override
  int get hashCode => locale.hashCode;
}

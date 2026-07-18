part of 'locale_bloc.dart';

/// The active app language. StampMail defaults to Vietnamese; the user can
/// switch to any language with a bundled translation.
@immutable
class LocaleState {
  const LocaleState(this.locale);

  /// The app's default language when nothing is persisted. Vietnamese, since
  /// StampMail ships Vietnamese-first.
  static const defaultLocale = Locale('vi');

  final Locale locale;

  @override
  bool operator ==(Object other) =>
      other is LocaleState && other.locale == locale;

  @override
  int get hashCode => locale.hashCode;
}

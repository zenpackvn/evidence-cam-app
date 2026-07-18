part of 'locale_bloc.dart';

sealed class LocaleEvent {
  const LocaleEvent();
}

/// The user picked a language in the settings picker. [code] is a language
/// code ('vi', 'en', …); an unsupported one is ignored by the bloc.
final class LocaleChanged extends LocaleEvent {
  const LocaleChanged(this.code);

  final String code;
}

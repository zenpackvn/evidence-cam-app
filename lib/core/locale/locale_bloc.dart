import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:localization/localization.dart';
// SharedPreferences is re-exported by the storage package, which the app
// already depends on; import it from there rather than adding a direct dep.
import 'package:storage/storage.dart';

part 'locale_event.dart';
part 'locale_state.dart';

const _kLocaleKey = 'app.locale';

/// App-wide selected language.
///
/// Mirrors `ThemeBloc`: an app-level preference persisted to
/// [SharedPreferences] and read back synchronously at startup so the first
/// frame is already in the chosen language. Lives in the app shell rather than
/// a package so it registers in the app's own DI graph — it needs no place in
/// `externalPackageModulesBefore`.
///
/// Only languages with a bundled translation (`AppLocalizations.supportedLocales`)
/// are honoured; a request for any other is ignored, which is what lets a
/// language picker show rows that quietly no-op until those translations exist.
@lazySingleton
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc(this._prefs) : super(_readInitial(_prefs)) {
    on<LocaleChanged>(_onChanged);
  }

  final SharedPreferences _prefs;

  static bool _isSupported(String code) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == code);

  static LocaleState _readInitial(SharedPreferences prefs) {
    final code = prefs.getString(_kLocaleKey);
    if (code != null && _isSupported(code)) {
      return LocaleState(Locale(code));
    }
    return const LocaleState(LocaleState.defaultLocale);
  }

  Future<void> _onChanged(
    LocaleChanged event,
    Emitter<LocaleState> emit,
  ) async {
    // Silently ignore a language we cannot render, rather than switching to a
    // locale with no translations and showing the fallback everywhere.
    if (!_isSupported(event.code) || event.code == state.locale.languageCode) {
      return;
    }
    emit(LocaleState(Locale(event.code)));
    await _prefs.setString(_kLocaleKey, event.code);
  }
}

// Design-review entrypoint: every StampMail screen with fake data, one entry
// per frame in `pencil-new.pen`, no Firebase / backend / DI bootstrap.
//
//   fvm flutter run -t lib/preview_all.dart
//
// The gallery lists all 57 design frames grouped by flow; implemented screens
// open with believable fake state (empty/loaded/error/quota/locked variants
// via the entries' switches), missing ones are flagged ✗ with a note.
import 'package:app_ui/app_ui.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/localization.dart';
import 'package:shared_ui/shared_ui.dart';

import 'preview/preview_fakes.dart';
import 'preview/preview_gallery.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerPreviewFakes();
  runApp(_PreviewApp(authBloc: buildPreviewAuthBloc()));
}

class _PreviewApp extends StatelessWidget {
  const _PreviewApp({required this.authBloc});

  final AuthBloc authBloc;

  static final _themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authBloc,
      child: SessionScope(
        session: FakeSession(),
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: _themeMode,
          builder: (context, mode, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: mode,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('vi'), Locale('en')],
            locale: const Locale('vi'),
            home: GalleryHome(themeMode: _themeMode),
          ),
        ),
      ),
    );
  }
}

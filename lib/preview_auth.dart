// Standalone preview entrypoint for the StampMail auth screens.
//
// Renders the five auth screens in a swipeable pager using the real StampMail
// theme, with no Firebase bootstrap or DI — purely for reviewing the UI:
//
//   fvm flutter run -d chrome -t lib/preview_auth.dart
//
// Not shipped; excluded from the app's normal entrypoints.
import 'package:app_ui/app_ui.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const _Pager()),
        ...authRoutes,
      ],
    );
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi'), Locale('en')],
      locale: const Locale('vi'),
      routerConfig: router,
    );
  }
}

class _Pager extends StatelessWidget {
  const _Pager();

  @override
  Widget build(BuildContext context) {
    const screens = <Widget>[
      LoginScreen(),
      RegisterScreen(),
      ForgotPasswordScreen(),
      VerifyEmailScreen(email: 'hello@stampmail.com'),
      ChooseUsernameScreen(),
    ];
    return PageView(children: screens);
  }
}

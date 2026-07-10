// Standalone preview entrypoint for the whole StampMail Flow 1 (onboarding +
// auth), for reviewing the UI with no Firebase bootstrap or DI:
//
//   fvm flutter run -d chrome -t lib/preview_flow1.dart
//
// Routes: /splash /onboarding /login /register /forgot-password
//         /verify-email /choose-username
import 'package:app_ui/app_ui.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_onboarding/feature_onboarding.dart';
import 'package:feature_splash/feature_splash.dart';
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
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (_, _) => const SplashContent()),
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => OnboardingScreen(onDone: () {}),
        ),
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

// Verifies the Android back behavior of the app shell. StatefulShellRoute keeps
// no cross-branch history, so AppShell owns it: back on a secondary branch
// returns to Home, and back on Home requires a confirming second press within a
// short window before leaving the app (SystemNavigator.pop).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter_template/app/widgets/app_shell.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

GoRouter _buildRouter() {
  StatefulShellBranch branch(String path, String screen) => StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (_, _) => Text(screen))],
  );

  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          branch('/', 'home-screen'),
          branch('/letters', 'letters-screen'),
          branch('/album', 'album-screen'),
          branch('/profile', 'profile-screen'),
        ],
      ),
    ],
  );
}

Future<void> _pumpShell(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: _buildRouter(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // Records platform-channel calls so we can assert whether the app asked to
  // close via SystemNavigator.pop.
  late List<String> systemCalls;

  setUp(() {
    systemCalls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          systemCalls.add(call.method);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('back on a secondary branch returns to Home without exiting', (
    tester,
  ) async {
    await _pumpShell(tester);

    await tester.tap(find.text('Album'));
    await tester.pumpAndSettle();
    expect(find.text('album-screen'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('home-screen'), findsOneWidget);
    expect(find.text('album-screen'), findsNothing);
    expect(systemCalls, isNot(contains('SystemNavigator.pop')));
  });

  testWidgets('first back on Home warns instead of exiting', (tester) async {
    await _pumpShell(tester);

    await tester.binding.handlePopRoute();
    await tester.pump(); // let the SnackBar frame in

    expect(find.text('Press back again to exit'), findsOneWidget);
    expect(systemCalls, isNot(contains('SystemNavigator.pop')));
  });

  testWidgets('second back on Home within the window exits the app', (
    tester,
  ) async {
    await _pumpShell(tester);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(systemCalls, contains('SystemNavigator.pop'));
  });

  testWidgets('a slow second back re-warns instead of exiting', (tester) async {
    await _pumpShell(tester);

    await tester.binding.handlePopRoute();
    await tester.pump();
    // Let the 2s confirm window lapse before the next press.
    await tester.pump(const Duration(seconds: 3));

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(systemCalls, isNot(contains('SystemNavigator.pop')));
    expect(find.text('Press back again to exit'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/e2e_app.dart';

/// Real login journey against the real backend + Firebase (no mocks).
///
/// Requires: backend running on the dev API URL with real Firebase/R2 wired,
/// and the account below existing in the `stampmail-dev` Firebase project.
/// Drives the actual widgets: type email/password → tap Sign in → assert the
/// app leaves the login screen (auth succeeded + redirect fired).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const email = 'test1783783163@stampmail.dev';
  const password = 'test123456';

  testWidgets('signs in with a real account and leaves the login screen', (
    tester,
  ) async {
    await E2eApp.bootstrap();
    await E2eApp.pumpApp(tester);
    await tester.pump();
    await E2eApp.settle(tester);
    // Splash has a 2s minimum; step outside the test zone so its timer fires.
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(seconds: 3)),
    );
    await E2eApp.settle(tester);

    // Land on login.
    await E2eApp.pumpUntil(tester, find.text('Sign in'));
    expect(find.text('Sign in'), findsWidgets, reason: 'should be on login');

    // Fill the form.
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), password);
    await E2eApp.settle(tester);

    // Tap Sign in.
    await tester.tap(find.text('Sign in').first);

    // Real Firebase sign-in + /api/sm/me round-trip; give it a generous budget.
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(seconds: 6)),
    );
    await E2eApp.settle(tester);
    await E2eApp.pumpUntil(
      tester,
      find.byType(TextFormField),
      maxTries: 40,
    );

    // Success = we're no longer on the login form (redirected to
    // choose-username / home). The login title should be gone.
    expect(
      find.text('Welcome back! 👋'),
      findsNothing,
      reason: 'still on login screen — sign-in or redirect did not complete',
    );
  });
}

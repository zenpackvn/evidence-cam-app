// Widget tests for the production SM-024 profile screen (StampMailProfileScreen).
// Covers the plan badge / Premium-expiry (BR-10, AC-12) and the Free upgrade
// shortcut (BR-11, AC-13). The screen reads the signed-in user via SessionScope,
// so the harness wraps it in a FakeSession the same way profile_screen_test does.

import 'package:feature_profile/feature_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../support.dart';

void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    required bool isPremium,
    DateTime? premiumExpiry,
    VoidCallback? onUpgrade,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SessionScope(
          session: FakeSession(currentUser: testUser),
          child: StampMailProfileScreen(
            isPremium: isPremium,
            premiumExpiry: premiumExpiry,
            onEditProfile: () {},
            onOpenSettings: () {},
            onUpgrade: onUpgrade ?? () {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('StampMailProfileScreen — plan status (SM-024 BR-10/BR-11)', () {
    testWidgets(
      'AC-12: Premium shows the "Premium" badge with its expiry date and no '
      'upgrade button',
      (tester) async {
        await pumpProfile(
          tester,
          isPremium: true,
          premiumExpiry: DateTime(2026, 12, 31),
        );

        expect(find.text('Premium'), findsOneWidget);
        expect(find.text('Hết hạn 31/12/2026'), findsOneWidget);
        // BR-11: Premium users never see the upgrade shortcut — they get the
        // "Quản lý gói" manage card instead.
        expect(find.text('Nâng cấp Premium'), findsNothing);
        expect(find.text('Quản lý gói'), findsOneWidget);
      },
    );

    testWidgets('Premium without a known expiry still renders the badge', (
      tester,
    ) async {
      await pumpProfile(tester, isPremium: true);

      expect(find.text('Premium'), findsOneWidget);
      expect(find.textContaining('Hết hạn'), findsNothing);
    });

    testWidgets(
      'AC-13: Free shows the "Miễn phí" label and the upgrade button, no expiry',
      (tester) async {
        var upgraded = false;
        await pumpProfile(
          tester,
          isPremium: false,
          onUpgrade: () => upgraded = true,
        );

        expect(find.text('Miễn phí'), findsOneWidget);
        expect(find.textContaining('Hết hạn'), findsNothing);

        final upgradeButton = find.text('Nâng cấp Premium');
        expect(upgradeButton, findsOneWidget);

        await tester.ensureVisible(upgradeButton);
        await tester.tap(upgradeButton);
        expect(upgraded, isTrue);
      },
    );
  });
}

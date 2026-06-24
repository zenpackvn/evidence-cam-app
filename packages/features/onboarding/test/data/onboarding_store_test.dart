import 'package:feature_onboarding/feature_onboarding.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late OnboardingStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    store = OnboardingStore(prefs);
  });

  test('hasSeenOnboarding is false when no value stored', () {
    expect(store.hasSeenOnboarding, isFalse);
  });

  test('hasSeenOnboarding is true after markSeen', () async {
    await store.markSeen();
    expect(store.hasSeenOnboarding, isTrue);
  });

  test('hasSeenOnboarding persists across instances', () async {
    await store.markSeen();
    final store2 = OnboardingStore(prefs);
    expect(store2.hasSeenOnboarding, isTrue);
  });
}

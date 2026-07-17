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

  test('lastStep is 0 when nothing saved', () {
    expect(store.lastStep, 0);
  });

  test('saveStep persists the resume position across instances', () async {
    await store.saveStep(2);
    final store2 = OnboardingStore(prefs);
    expect(store2.lastStep, 2);
  });

  test('markSeen clears the saved resume position', () async {
    await store.saveStep(2);
    await store.markSeen();
    expect(store.lastStep, 0);
    expect(store.hasSeenOnboarding, isTrue);
  });
}

import 'package:injectable/injectable.dart';
import 'package:storage/storage.dart';

/// Persists whether the user has completed the first-launch onboarding.
///
/// Backed by [SharedPreferences] (a single bool) — onboarding state is not
/// sensitive and must survive restarts but not reinstalls, which is exactly
/// what shared prefs give. The app shell reads [hasSeenOnboarding] at startup
/// to decide whether to route into the onboarding flow.
@lazySingleton
class OnboardingStore {
  OnboardingStore(this._prefs);

  static const _seenKey = 'onboarding_seen';

  final SharedPreferences _prefs;

  bool get hasSeenOnboarding => _prefs.getBool(_seenKey) ?? false;

  Future<void> markSeen() => _prefs.setBool(_seenKey, true);
}

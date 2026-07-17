import 'package:injectable/injectable.dart';
import 'package:storage/storage.dart';

/// Persists first-launch onboarding state.
///
/// Backed by [SharedPreferences] — onboarding state is not sensitive and must
/// survive restarts but not reinstalls, which is exactly what shared prefs
/// give. Two things are stored:
///
/// - [hasSeenOnboarding] (a bool): whether the flow was ever completed/skipped.
///   The app shell reads it at startup to decide whether to route into the
///   onboarding flow (SM-003 BR-01).
/// - [lastStep] (an int): the page the user was on when they last left the flow,
///   so an interrupted onboarding resumes where it stopped rather than restarting
///   from the first slide (SM-003 §5 — "thoát app giữa chừng").
@lazySingleton
class OnboardingStore {
  OnboardingStore(this._prefs);

  static const _seenKey = 'onboarding_seen';
  static const _stepKey = 'onboarding_step';

  final SharedPreferences _prefs;

  bool get hasSeenOnboarding => _prefs.getBool(_seenKey) ?? false;

  /// The last onboarding page the user viewed (0-based), or 0 if none saved.
  int get lastStep => _prefs.getInt(_stepKey) ?? 0;

  /// Records the page currently being viewed so the flow can resume there.
  Future<void> saveStep(int step) => _prefs.setInt(_stepKey, step);

  /// Marks onboarding as seen and clears any saved resume position.
  Future<void> markSeen() async {
    await _prefs.setBool(_seenKey, true);
    await _prefs.remove(_stepKey);
  }
}

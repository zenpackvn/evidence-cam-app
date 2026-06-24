/// Onboarding feature: a first-launch intro shown once.
///
/// The host app reads `OnboardingStore.hasSeenOnboarding` at startup to decide
/// whether to route to `OnboardingScreen`, passing an `onDone` callback that
/// calls `OnboardingStore.markSeen()` and navigates onward. The screen itself
/// is navigation- and DI-agnostic (it only takes `onDone`), so it stays easy to
/// test and reuse.
library;

export 'src/data/onboarding_store.dart';
export 'src/di.module.dart' show FeatureOnboardingPackageModule;
export 'src/presentation/onboarding_routes.dart';
export 'src/presentation/screens/onboarding_screen.dart';
export 'src/presentation/widgets/onboarding_step.dart';

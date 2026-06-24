import 'package:injectable/injectable.dart';

/// Code-generation anchor for the feature_onboarding micro-package.
///
/// Running `build_runner` here generates `di.module.dart` containing
/// `FeatureOnboardingPackageModule`, which the host app wires via
/// `externalPackageModulesBefore`.
@InjectableInit.microPackage()
void initOnboardingFeature() {}

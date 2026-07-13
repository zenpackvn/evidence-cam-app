import 'package:injectable/injectable.dart';

/// Code-generation anchor for the feature_stamp_creator micro-package.
///
/// Running `build_runner` here generates `di.module.dart` containing
/// `FeatureStampCreatorPackageModule`, which the host app wires via
/// `externalPackageModulesBefore`.
@InjectableInit.microPackage()
void initStampCreatorFeature() {}

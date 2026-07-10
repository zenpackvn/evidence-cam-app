import 'package:injectable/injectable.dart';

/// Code-generation anchor for the feature_album micro-package.
///
/// Running `build_runner` here generates `di.module.dart` containing
/// `FeatureAlbumPackageModule`, which the host app wires via
/// `externalPackageModulesBefore`.
@InjectableInit.microPackage()
void initAlbumFeature() {}

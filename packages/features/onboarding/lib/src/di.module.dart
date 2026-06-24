// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:feature_onboarding/src/data/onboarding_store.dart' as _i534;
import 'package:injectable/injectable.dart' as _i526;
import 'package:storage/storage.dart' as _i431;

class FeatureOnboardingPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.lazySingleton<_i534.OnboardingStore>(
        () => _i534.OnboardingStore(gh<_i431.SharedPreferences>()));
  }
}

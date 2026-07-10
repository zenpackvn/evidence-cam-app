// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:feature_rewards/src/data/datasources/rewards_remote_data_source.dart'
    as _i15;
import 'package:feature_rewards/src/data/datasources/rewards_remote_module.dart'
    as _i628;
import 'package:feature_rewards/src/data/repositories/rewards_repository_impl.dart'
    as _i778;
import 'package:feature_rewards/src/domain/repositories/rewards_repository.dart'
    as _i870;
import 'package:injectable/injectable.dart' as _i526;
import 'package:network/network.dart' as _i372;

class FeatureRewardsPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final rewardsRemoteModule = _$RewardsRemoteModule();
    gh.lazySingleton<_i15.RewardsRemoteDataSource>(() =>
        rewardsRemoteModule.provideRewardsRemoteDataSource(gh<_i372.Dio>()));
    gh.lazySingleton<_i870.RewardsRepository>(
        () => _i778.RewardsRepositoryImpl(gh<_i15.RewardsRemoteDataSource>()));
  }
}

class _$RewardsRemoteModule extends _i628.RewardsRemoteModule {}

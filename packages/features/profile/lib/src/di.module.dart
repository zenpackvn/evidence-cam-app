// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:analytics/analytics.dart' as _i548;
import 'package:feature_profile/src/data/datasources/profile_remote_data_source.dart'
    as _i569;
import 'package:feature_profile/src/data/datasources/profile_remote_module.dart'
    as _i261;
import 'package:feature_profile/src/data/repositories/profile_repository_impl.dart'
    as _i111;
import 'package:feature_profile/src/domain/repositories/profile_repository.dart'
    as _i795;
import 'package:feature_profile/src/presentation/bloc/edit_profile_cubit.dart'
    as _i519;
import 'package:feature_profile/src/presentation/bloc/profile_bloc.dart'
    as _i56;
import 'package:injectable/injectable.dart' as _i526;
import 'package:network/network.dart' as _i372;

class FeatureProfilePackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final profileRemoteModule = _$ProfileRemoteModule();
    gh.lazySingleton<_i569.ProfileRemoteDataSource>(() =>
        profileRemoteModule.provideProfileRemoteDataSource(gh<_i372.Dio>()));
    gh.factory<_i56.ProfileBloc>(
        () => _i56.ProfileBloc(gh<_i548.AnalyticsService>()));
    gh.lazySingleton<_i795.ProfileRepository>(
        () => _i111.ProfileRepositoryImpl(gh<_i569.ProfileRemoteDataSource>()));
    gh.factory<_i519.EditProfileCubit>(
        () => _i519.EditProfileCubit(gh<_i795.ProfileRepository>()));
  }
}

class _$ProfileRemoteModule extends _i261.ProfileRemoteModule {}

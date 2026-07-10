// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:feature_premium/src/data/datasources/entitlement_remote_data_source.dart'
    as _i222;
import 'package:feature_premium/src/data/datasources/entitlement_remote_module.dart'
    as _i322;
import 'package:feature_premium/src/data/entitlement_reader_impl.dart' as _i23;
import 'package:injectable/injectable.dart' as _i526;
import 'package:network/network.dart' as _i372;
import 'package:shared_contracts/shared_contracts.dart' as _i856;

class FeaturePremiumPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final entitlementRemoteModule = _$EntitlementRemoteModule();
    gh.lazySingleton<_i222.EntitlementRemoteDataSource>(() =>
        entitlementRemoteModule
            .provideEntitlementRemoteDataSource(gh<_i372.Dio>()));
    gh.lazySingleton<_i856.EntitlementReader>(() =>
        _i23.EntitlementReaderImpl(gh<_i222.EntitlementRemoteDataSource>()));
  }
}

class _$EntitlementRemoteModule extends _i322.EntitlementRemoteModule {}

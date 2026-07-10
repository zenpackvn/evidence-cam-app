// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:feature_letters/src/data/datasources/letters_remote_data_source.dart'
    as _i711;
import 'package:feature_letters/src/data/datasources/letters_remote_module.dart'
    as _i53;
import 'package:feature_letters/src/data/repositories/letters_repository_impl.dart'
    as _i98;
import 'package:feature_letters/src/domain/repositories/letters_repository.dart'
    as _i384;
import 'package:injectable/injectable.dart' as _i526;
import 'package:network/network.dart' as _i372;
import 'package:uuid/uuid.dart' as _i706;

class FeatureLettersPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final lettersRemoteModule = _$LettersRemoteModule();
    gh.lazySingleton<_i711.LettersRemoteDataSource>(() =>
        lettersRemoteModule.provideLettersRemoteDataSource(gh<_i372.Dio>()));
    gh.lazySingleton<_i384.LettersRepository>(() => _i98.LettersRepositoryImpl(
          gh<_i711.LettersRemoteDataSource>(),
          gh<_i706.Uuid>(),
        ));
  }
}

class _$LettersRemoteModule extends _i53.LettersRemoteModule {}

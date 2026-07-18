// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:feature_letter_inbox/src/data/datasources/inbox_remote_data_source.dart'
    as _i432;
import 'package:feature_letter_inbox/src/data/datasources/inbox_remote_module.dart'
    as _i617;
import 'package:feature_letter_inbox/src/data/repositories/inbox_repository_impl.dart'
    as _i917;
import 'package:feature_letter_inbox/src/domain/repositories/inbox_repository.dart'
    as _i972;
import 'package:injectable/injectable.dart' as _i526;
import 'package:network/network.dart' as _i372;

class FeatureLetterInboxPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final inboxRemoteModule = _$InboxRemoteModule();
    gh.lazySingleton<_i432.InboxRemoteDataSource>(
      () => inboxRemoteModule.provideInboxRemoteDataSource(gh<_i372.Dio>()),
    );
    gh.lazySingleton<_i972.InboxRepository>(
      () => _i917.InboxRepositoryImpl(gh<_i432.InboxRemoteDataSource>()),
    );
  }
}

class _$InboxRemoteModule extends _i617.InboxRemoteModule {}

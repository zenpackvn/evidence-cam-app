// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:database/database.dart' as _i252;
import 'package:feature_album/src/data/datasources/albums_remote_data_source.dart'
    as _i121;
import 'package:feature_album/src/data/datasources/albums_remote_module.dart'
    as _i542;
import 'package:feature_album/src/data/datasources/sample_stamps_remote_data_source.dart'
    as _i656;
import 'package:feature_album/src/data/datasources/sample_stamps_remote_module.dart'
    as _i345;
import 'package:feature_album/src/data/datasources/stamps_remote_data_source.dart'
    as _i244;
import 'package:feature_album/src/data/datasources/stamps_remote_module.dart'
    as _i817;
import 'package:feature_album/src/data/local/albums_local_data_source.dart'
    as _i750;
import 'package:feature_album/src/data/local/stamps_local_data_source.dart'
    as _i591;
import 'package:feature_album/src/data/repositories/albums_repository_impl.dart'
    as _i659;
import 'package:feature_album/src/data/repositories/sample_stamps_repository_impl.dart'
    as _i911;
import 'package:feature_album/src/data/repositories/stamps_repository_impl.dart'
    as _i749;
import 'package:feature_album/src/data/sync/albums_sync_service.dart' as _i825;
import 'package:feature_album/src/data/sync/stamps_sync_service.dart' as _i639;
import 'package:feature_album/src/domain/repositories/albums_repository.dart'
    as _i526;
import 'package:feature_album/src/domain/repositories/sample_stamps_repository.dart'
    as _i1053;
import 'package:feature_album/src/domain/repositories/stamps_repository.dart'
    as _i815;
import 'package:feature_album/src/domain/services/albums_sync_controller.dart'
    as _i669;
import 'package:feature_album/src/domain/services/stamps_sync_controller.dart'
    as _i875;
import 'package:feature_album/src/presentation/bloc/album_cubit.dart' as _i257;
import 'package:feature_album/src/presentation/bloc/sample_stamps_cubit.dart'
    as _i606;
import 'package:injectable/injectable.dart' as _i526;
import 'package:network/network.dart' as _i372;
import 'package:rev_sync/rev_sync.dart' as _i520;
import 'package:uuid/uuid.dart' as _i706;

class FeatureAlbumPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final albumsRemoteModule = _$AlbumsRemoteModule();
    final sampleStampsRemoteModule = _$SampleStampsRemoteModule();
    final stampsRemoteModule = _$StampsRemoteModule();
    gh.lazySingleton<_i750.AlbumsLocalDataSource>(
        () => _i750.ObjectBoxAlbumsDataSource(gh<_i252.Store>()));
    gh.lazySingleton<_i121.AlbumsRemoteDataSource>(() =>
        albumsRemoteModule.provideAlbumsRemoteDataSource(gh<_i372.Dio>()));
    gh.lazySingleton<_i656.SampleStampsRemoteDataSource>(() =>
        sampleStampsRemoteModule
            .provideSampleStampsRemoteDataSource(gh<_i372.Dio>()));
    gh.lazySingleton<_i244.StampsRemoteDataSource>(() =>
        stampsRemoteModule.provideStampsRemoteDataSource(gh<_i372.Dio>()));
    gh.lazySingleton<_i591.StampsLocalDataSource>(
        () => _i591.ObjectBoxStampsDataSource(gh<_i252.Store>()));
    gh.lazySingleton<_i1053.SampleStampsRepository>(() =>
        _i911.SampleStampsRepositoryImpl(
            gh<_i656.SampleStampsRemoteDataSource>()));
    gh.lazySingleton<_i875.StampsSyncController>(() => _i639.StampsSyncService(
          gh<_i591.StampsLocalDataSource>(),
          gh<_i244.StampsRemoteDataSource>(),
          gh<_i520.ConnectivitySource>(),
          gh<_i520.SyncCursorStore>(),
        ));
    gh.lazySingleton<_i669.AlbumsSyncController>(() => _i825.AlbumsSyncService(
          gh<_i750.AlbumsLocalDataSource>(),
          gh<_i121.AlbumsRemoteDataSource>(),
          gh<_i520.ConnectivitySource>(),
          gh<_i520.SyncCursorStore>(),
        ));
    gh.lazySingleton<_i526.AlbumsRepository>(() => _i659.AlbumsRepositoryImpl(
          gh<_i750.AlbumsLocalDataSource>(),
          gh<_i669.AlbumsSyncController>(),
          gh<_i706.Uuid>(),
        ));
    gh.lazySingleton<_i815.StampsRepository>(() => _i749.StampsRepositoryImpl(
          gh<_i591.StampsLocalDataSource>(),
          gh<_i875.StampsSyncController>(),
          gh<_i706.Uuid>(),
        ));
    gh.factory<_i606.SampleStampsCubit>(() => _i606.SampleStampsCubit(
          gh<_i1053.SampleStampsRepository>(),
          gh<_i815.StampsRepository>(),
        ));
    gh.factory<_i257.AlbumCubit>(() => _i257.AlbumCubit(
          gh<_i815.StampsRepository>(),
          gh<_i520.ConnectivitySource>(),
        ));
  }
}

class _$AlbumsRemoteModule extends _i542.AlbumsRemoteModule {}

class _$SampleStampsRemoteModule extends _i345.SampleStampsRemoteModule {}

class _$StampsRemoteModule extends _i817.StampsRemoteModule {}

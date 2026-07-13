/// StampMail Album feature: the user's stamp collection (created + received),
/// offline-first over ObjectBox with delta sync to the Go backend (SM-022).
///
/// The host app wires `FeatureAlbumPackageModule` via
/// `externalPackageModulesBefore` and drives background sync through
/// `StampsSyncController`. The `Stamp` entity and `StampsRepository` are
/// exported so the stamp creator and letters features can save/attach stamps;
/// data internals stay private.
library;

export 'src/di.module.dart' show FeatureAlbumPackageModule;
export 'src/domain/entities/album.dart';
export 'src/domain/entities/stamp.dart';
export 'src/domain/repositories/albums_repository.dart';
export 'src/domain/repositories/stamps_repository.dart';
export 'src/domain/services/albums_sync_controller.dart';
export 'src/domain/services/stamps_sync_controller.dart';
export 'src/presentation/bloc/album_cubit.dart';
export 'src/presentation/bloc/album_state.dart';
export 'src/presentation/screens/album_screen.dart';
export 'src/presentation/screens/stamp_detail_screen.dart';

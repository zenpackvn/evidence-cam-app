import 'package:feature_album/feature_album.dart';
// fst:feature:_infra:start
import 'package:go_router/go_router.dart';
// fst:feature:_infra:end

// fst:feature:_infra:start
import 'di/injection.dart';
// fst:feature:_infra:end
import 'feature_module.dart';

/// All optional features enabled in this project.
///
/// StampMail only: the template's demo features (bookmarks / collections /
/// notifications) are unwired so no demo data syncs or routes mount. Their
/// packages remain in the workspace until the final cleanup pass (B4).
const List<FeatureModule> enabledFeatures = [
  _AlbumModule(),
  // fst:enabled-features — `fst add-feature` inserts new modules above this line
];

/// StampMail album: offline-first stamp collection + custom albums. No
/// app-level routes yet (presentation added separately); drives both the stamp
/// and album background sync.
final class _AlbumModule extends FeatureModule {
  const _AlbumModule();

  @override
  FeatureSyncController get syncController {
    final stamps = getIt<StampsSyncController>();
    final albums = getIt<AlbumsSyncController>();
    return _FeatureSync(
      onStart: () async {
        await stamps.start();
        await albums.start();
      },
      onStop: () async {
        await stamps.stop();
        await albums.stop();
      },
    );
  }

  @override
  Iterable<RouteBase> get routes => const <RouteBase>[];
}

// fst:feature-module-classes — `fst add-feature` inserts new module classes above

// fst:feature:_infra:start
/// Adapts any feature's sync controller to [FeatureSyncController] without a
/// bespoke wrapper class per feature. The controllers don't implement the
/// interface directly so feature packages stay unaware of the app's lifecycle.
final class _FeatureSync implements FeatureSyncController {
  const _FeatureSync({required this.onStart, required this.onStop});

  final Future<void> Function() onStart;
  final Future<void> Function() onStop;

  @override
  Future<void> start() => onStart();

  @override
  Future<void> stop() => onStop();
}

// fst:feature:_infra:end

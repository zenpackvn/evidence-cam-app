import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart';
import 'package:config/config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:storage/storage.dart';
import 'package:sync_connectivity_plus/sync_connectivity_plus.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

/// Async because core database modules use `@preResolve` to open native
/// resources before any consumer is constructed. Must be awaited from `main`.
///
/// Ordering: `storage` provides the `AuthTokenStore` + `FlutterSecureStorage`
/// that `network` builds the authenticated `Dio` on, so it is listed before
/// `network`. Only infra modules remain — EvidenceCam's own features
/// (`feature_capture` and the presentation packages) are constructed by the app
/// shell, not through injectable package modules.
@InjectableInit(
  externalPackageModulesBefore: [
    ExternalModule(AnalyticsPackageModule),
    ExternalModule(ConfigPackageModule),
    ExternalModule(StoragePackageModule),
    ExternalModule(NetworkPackageModule),
    ExternalModule(AppPlatformPackageModule),
    ExternalModule(SyncConnectivityPlusPackageModule),
    ExternalModule(SharedContractsPackageModule),
  ],
)
Future<void> configureDependencies() async {
  await getIt.init();
}

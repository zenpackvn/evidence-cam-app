# DI Registration

Add to `service_locator.dart` between Storage and Network (or after Network, before feature modules).

## Registration snippet

```dart
import '../connectivity/connectivity_service.dart';
import '../connectivity/connectivity_service_impl.dart';
import '../connectivity/connectivity_cubit.dart';
import '../database/daos/sync_operation_dao.dart';
import '../sync/sync_queue.dart';
import '../sync/sync_manager.dart';

// ── Connectivity ──
getIt.registerLazySingleton<ConnectivityService>(
  ConnectivityServiceImpl.new,
);

// ── Sync ──
getIt.registerLazySingleton<SyncOperationDao>(
  () => SyncOperationDao(getIt<AppDatabase>()),
);
getIt.registerLazySingleton<SyncQueue>(
  () => SyncQueueImpl(getIt<SyncOperationDao>()),
);
getIt.registerLazySingleton<SyncManager>(
  () => SyncManager(
    connectivityService: getIt<ConnectivityService>(),
    syncQueue: getIt<SyncQueue>(),
    logger: getIt<AppLogger>(),
  ),
);

// ── Connectivity Cubit (global — survives navigation) ──
getIt.registerSingleton<ConnectivityCubit>(
  ConnectivityCubit(getIt<ConnectivityService>()),
);
```

## Registration order

1. `AppConfig` (singleton)
2. `AppLogger` (lazy singleton)
3. `SecureStorage` / `KeyValueStore` (lazy singleton)
4. `AppDatabase` + DAOs (lazy singletons)
5. **`ConnectivityService`** (lazy singleton)
6. **`SyncQueue`** (lazy singleton)
7. Interceptors + `Dio` + `ApiClient` (lazy singletons)
8. **`SyncManager`** (lazy singleton)
9. **`ConnectivityCubit`** (singleton)
10. Feature modules (register sync handlers here)

`SyncManager` is lazy — it starts listening to connectivity changes only when first accessed. Force creation at startup if you want immediate queue processing:

```dart
// At the end of configureDependencies():
getIt<SyncManager>().processQueue();
```

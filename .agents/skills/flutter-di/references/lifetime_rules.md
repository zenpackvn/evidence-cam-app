# Lifetime Rules

| Lifetime | Use for |
|---|---|
| `registerSingleton` | Pre-resolved instances (e.g. `AppConfig` built in `main`). |
| `registerLazySingleton` | Stateless or shared-state infrastructure: logger, Dio, API client, storage wrappers, repositories. |
| `registerFactory` | Anything with per-use state: blocs, cubits, controllers, use cases. |
| `registerSingletonAsync` | Services whose construction is inherently async (prefer pre-resolving and registering the result as a sync singleton when possible). |

**Blocs and cubits are always factories.** Registering them as singletons causes state to leak across screens.

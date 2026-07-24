# Template — Network

Dio client, interceptors, Retrofit API client, and error mapping. Only files under `core/network/` import `package:dio`, `package:dio_smart_retry`, and `package:retrofit`.

## Reference Files

Load only the file(s) relevant to the task.

| Topic | File |
|---|---|
| `Failure` sealed hierarchy + `FailureException` + pubspec additions | [failure_hierarchy.md](failure_hierarchy.md) |
| Auth, logging, error, and retry interceptors | [interceptors.md](interceptors.md) |
| `buildDio` — configures the shared Dio instance | [dio_client.md](dio_client.md) |
| `ApiClient` (Retrofit) + DTO/JSON serialization rules | [api_client_and_dtos.md](api_client_and_dtos.md) |
| Anti-patterns (6 common mistakes) | [network_antipatterns.md](network_antipatterns.md) |

---

## ⚠️ Common Mistakes

> These are the most frequent network bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Catching `DioException` in cubits or widgets** | Status-code branching (`e.response?.statusCode == 401`) spread across the UI layer; new error types silently missed | Catch only `FailureException` in cubits; the `ErrorInterceptor` maps every `DioException` to a typed `Failure` before it leaves `core/network/` |
| 2 | **Importing `package:dio` outside `core/network/`** | A repository or cubit `import 'package:dio/dio.dart'` — direct coupling to the transport layer | Only files under `lib/src/core/network/` (interceptors, `dio_client.dart`, Retrofit-generated code) may import `package:dio` |
| 3 | **Hardcoded base URL** | Switching environments (dev/staging/prod) requires editing source code; wrong URL ships in production builds | Read `baseUrl` from `AppConfig.instance.apiBaseUrl` which is populated from `EnvConfig` per flavor; never write a literal URL string |
| 4 | **Creating a new `Dio` instance per request** | Each call has no interceptors, no auth header, no retry, no timeout — requests fail silently or bypass auth | Inject the shared `ApiClient` (Retrofit) via DI; `buildDio` configures the single `Dio` instance with all interceptors at startup |
| 5 | **Returning `Map<String, dynamic>` from repositories** | Raw JSON maps leak into domain and presentation layers; no type safety; impossible to mock cleanly | Retrofit endpoints return typed DTOs (`Future<PostDto>`); repositories call `dto.toEntity()` and return domain types; `Map` never crosses the data boundary |
| 6 | **Writing manual `fromJson`/`toJson` instead of using codegen** | Hand-written serialization diverges from the API contract; null fields cause runtime cast errors | Annotate every DTO with `@JsonSerializable()` and run `dart run build_runner build --delete-conflicting-outputs`; never write `fromJson` by hand |
| 7 | **Wrong interceptor order** | Retried requests skip logging; error mapping fires before retry, so retry sees a `FailureException` instead of a raw `DioException` and never retries | Add interceptors in `buildDio` in this exact order: **retry → logging → error**; retry must be first so re-attempts pass through logging |
| 8 | **Not cancelling in-flight requests on cubit close** | Stale response emitted after the user navigates away; `emit()` called on a closed cubit, causing a `StateError` | Store a `CancelToken` on the cubit, cancel it in `close()`, pass it through the repository to `ApiClient`; catch `FailureException` with `UnknownFailure` (cancel maps to that) and ignore it |

## Quick Summary

- Only `core/network/` files import `package:dio`, `package:retrofit`, `package:dio_smart_retry`.
- Repositories throw `FailureException(Failure)` — cubits catch `FailureException`, never `DioException`.
- Retrofit endpoints must return DTO types (`Future<PostDto>`), never `Map<String, dynamic>`.
- DTOs use `@JsonSerializable()` codegen — never write manual `fromJson`/`toJson`.
- Map DTOs to domain entities at the repository boundary via `dto.toEntity()`.
- Interceptor order: **retry → logging → error** (retry re-attempts go through logging).
- `baseUrl` always comes from `AppConfig` — never hardcoded.
- After changing DTOs or endpoints: `dart run build_runner build --delete-conflicting-outputs`.

## Cross-references

- [flutter-di](../../../flutter-di/references/template.md) — `DioClient` and `ApiClient` must be registered in the DI composition root
- [flutter-base-classes](../../../flutter-base-classes/references/template.md) — `BaseRepository.safeCall` wraps API calls and `BaseDto` is the DTO base type
- [flutter-auth](../../../flutter-auth/references/template.md) — `AuthInterceptor` handles token refresh; depends on `TokenManager` from the auth layer
- [flutter-flavors](../../../flutter-flavors/references/template.md) — `AppConfig.instance.apiBaseUrl` and `AppConfig.enableLogging` supply per-flavor network configuration

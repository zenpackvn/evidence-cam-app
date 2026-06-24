import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// Builds the HTTP cache interceptor.
///
/// Honors server cache directives (ETag / `Cache-Control`): a cached entry is
/// revalidated with `If-None-Match` and a 304 serves the stored body, so
/// repeated GETs avoid re-downloading unchanged responses. When the server
/// sends no directives the `CachePolicy.request` policy still caches up to
/// [maxStale], and on a network failure a not-yet-stale entry is served
/// (`hitCacheOnNetworkFailure`), which covers the "intermittent connectivity"
/// path for idempotent reads.
///
/// The default store is in-memory: it speeds up a session but does not survive
/// an app restart. For cross-launch persistence, swap `MemCacheStore` for a
/// disk store (e.g. `http_cache_hive_store`) — see docs/system-design-coverage.
// ponytail: in-memory store covers the base; add a disk store when offline
// persistence across launches is actually needed.
DioCacheInterceptor cacheInterceptor({
  Duration maxStale = const Duration(days: 7),
}) {
  final options = CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.request,
    hitCacheOnNetworkFailure: true,
    maxStale: maxStale,
    priority: CachePriority.normal,
  );
  return DioCacheInterceptor(options: options);
}

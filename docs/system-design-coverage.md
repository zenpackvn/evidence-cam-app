# Mobile System Design Coverage

This template is mapped against the **53 Mobile System Design Concepts**
([systemdesign.one](https://newsletter.systemdesign.one/p/mobile-system-design) /
[shefali.dev](https://shefali.dev/mobile-system-design-concepts/)).

Legend: ✅ built · 🟡 partial · 📄 doc-only (add per app — see "How to add")

## Status map

### Networking & real-time
| Concept | Status | Where |
|---|---|---|
| Client-server (REST) | ✅ | `network` (Dio + retrofit datasources) |
| WebSockets / persistent conn | 📄 | per app |
| Push notifications (APNs/FCM) | ✅ | `app_platform/notifications` |
| Polling / long-poll / SSE | 📄 | per app |
| REST vs GraphQL vs gRPC | ✅ REST | gRPC/GraphQL per app |
| Network resilience (backoff+jitter) | ✅ | `network/retry_interceptor.dart` |
| Idempotency (safe retries) | ✅ | `network/idempotency_interceptor.dart` (+ retry's method gating) |
| Request batching / payload opt | 📄 | per app |
| Resumable / chunked uploads | 📄 | per app (`/api/upload` is single-shot) |
| Intermittent connectivity | ✅ | `sync_connectivity_plus` + HTTP cache serve-on-failure |

### Caching & offline
| Concept | Status | Where |
|---|---|---|
| On-device caching (mem/disk) | ✅ | ObjectBox + secure/shared prefs |
| HTTP caching (ETag/Cache-Control) | ✅ | `network/cache_interceptor.dart` |
| Offline-first | ✅ | per-feature delta-sync services/adapters |
| CDN strategy / media opt | 📄 | server-side |
| Cache invalidation | ✅ | sync cursor (data) + HTTP revalidation (responses) |

### Storage & data
| Concept | Status | Where |
|---|---|---|
| Local DB schema | ✅ | `database` (ObjectBox entities) |
| Schema migration | ✅+📄 | auto-additive; see [Schema migration](#schema-migration) |
| Pagination (cursor) | ✅ | backend `/api/activity/feed` + `ActivityFeedScreen` |
| Data modeling for mobile | ✅ | DTO/freezed → domain split |

### Performance, security, conflict
| Concept | Status | Where |
|---|---|---|
| Conflict resolution | ✅ | sync adapters (base revision + `serverUpdatedAt`) |
| Certificate pinning | ✅ | `network/certificate_pinning.dart` (`CERT_SHA256_PINS`) |
| Encryption at rest | 🟡 | secure_storage for tokens; DB encryption per app |
| Code obfuscation | ✅ | `--obfuscate` in both Fastfiles |
| Rendering performance | ✅ | very_good_analysis lints + skeletons |
| App startup trace | 📄 | per app (Firebase Performance is wired) |
| Isolate / compute | 📄 | per app (`compute()` for heavy parse) |
| Image caching / compression | ✅/📄 | `app_network_image` (cached); compression per app |
| Rate-limit / debounce client | 📄 | per app |
| Background tasks | 📄 | per app (`workmanager`) |

### Architecture & release
| Concept | Status | Where |
|---|---|---|
| Modular architecture | ✅ | pub workspace + boundary tests |
| Feature flags / Remote Config | ✅ | `config/remote_config_service.dart` |
| App versioning / backward-compat | 🟡 | server-side; client gated by force-update |
| Force-update / min-version | ✅ | `lib/app/widgets/force_update_gate.dart` |
| Staged rollout / A/B | ✅ | `config/experiment_bucketing.dart` |
| Expand–contract API migration | 📄 | server-side pattern |
| Deep linking | ✅ | see [Deep linking setup](#deep-linking-setup) |
| Navigation architecture | ✅ | go_router (typed) |
| Permissions model | ✅ | `app_platform/permissions` |
| Accessibility (a11y) | ✅+📄 | see [Accessibility](#accessibility) |
| i18n / l10n | ✅ | ARB en/vi (`localization`) |
| Graceful degradation | ✅ | skeleton + error views |
| Crash-free rate as SLI | ✅ | Crashlytics (dashboard per app) |

---

## How to use the added pieces

### Pagination
Cursor pagination reference: backend `GET /api/activity/feed?cursor=&limit=`
(keyset on `(created_at, id)`, opaque base64 cursor) →
`NotificationsRemoteDataSource.activityFeed` → `ActivityFeedRepository` →
`ActivityFeedScreen` (`infinite_scroll_pagination` v5 `PagingController`).
Copy this shape for any server-owned list too large to fully sync. Keyset
(not OFFSET) keeps each page O(limit) at any depth.

### HTTP caching
`cacheInterceptor()` is registered in `network_module.dart` after auth. It
honors ETag/`Cache-Control` and serves a not-yet-stale entry on network
failure. The store is **in-memory** (per session). For cross-launch
persistence, swap `MemCacheStore` for a disk store (`http_cache_hive_store`)
in `cache_interceptor.dart`.

### Force-update
Set `min_supported_version` (e.g. `"1.8.0"`) in Firebase Remote Config. Any
client whose `package_info_plus` version is below it gets a blocking gate.
Empty (default) = no forced update. Logic: `force_update_gate.dart`.

### Certificate pinning
Off by default (empty `CERT_SHA256_PINS`) so dev against a tunnel/self-signed
server works. For prod, pass the leaf cert's SHA-256:

```sh
openssl s_client -connect api.example.com:443 </dev/null 2>/dev/null \
  | openssl x509 -outform der | openssl dgst -sha256
# then: --dart-define=CERT_SHA256_PINS=<hex>,<backup-hex>
```

Pin a backup (next cert) too, or a reissue locks users out. To survive
rotation without app updates, switch to SPKI pinning of an intermediate.

### Idempotency
`IdempotencyInterceptor` adds a stable `Idempotency-Key` to POST/PATCH (reused
across retries of the same request). The **server must honor it**: store the
key, replay the original response on a repeat. Without server support the
header is harmless but inert.

### A/B bucketing / staged rollout
```dart
if (isInRollout(userId, remoteConfig.getInt('feature_x_rollout'), salt: 'x')) {
  // show feature_x
}
```
Deterministic (same user → same bucket), monotonic (ramping % never drops a
user), and per-`salt` so experiments are independent. Ramp by editing the
Remote Config int — no release.

### Deep linking setup
Already wired: Android `autoVerify` intent-filter
(`AndroidManifest.xml`), iOS `FlutterDeepLinkingEnabled` (Info.plist) +
Associated Domains (`Runner*.entitlements`), cold-start URI capture and
post-auth replay (`router.dart` `resolveSplashRedirect` + `DeepLinkState`),
and real param routes (`/bookmarks/:id`, `/collections/:id`).

To activate for a real domain:
1. Replace `yourdomain.com` in `AndroidManifest.xml` and the three
   `ios/Runner/*.entitlements` files with your domain.
2. Host `https://<domain>/.well-known/assetlinks.json` (Android) and
   `https://<domain>/.well-known/apple-app-site-association` (iOS, no
   extension, `application/json`).
3. Test: `adb shell am start -a android.intent.action.VIEW -d "https://<domain>/bookmarks/123"`.

### Accessibility
Shared widgets label their non-text controls for screen readers
(`AppButton` and `AppLoading` name their spinners; `AppNetworkImage` takes a
`semanticLabel` and `ExcludeSemantics` for decorative images). Tests assert
WCAG tap-target and labeled-tappable guidelines
(`app_ui/test/widgets/accessibility_test.dart`). When adding widgets:
- Give every tappable an accessible name (text child or `Semantics(label:)`).
- Mark decorative images `ExcludeSemantics`.
- Keep tap targets ≥ 48dp (Android) / 44pt (iOS).
- Don't hard-code text sizes that break Dynamic Type.

### Schema migration
ObjectBox migrates **additive** changes automatically: adding an entity, or a
new property to an existing entity, just works on next open — no migration
code. What needs care:
- **Renaming** a property/entity: annotate with `@Property(uid: …)` /
  `@Entity(uid: …)` and use `dart run build_runner build` UID prompts, or
  ObjectBox treats it as drop+add (data loss).
- **Changing a property's type** or **backfilling**: read old data, transform,
  write back in a one-shot migration step at startup (gate on a stored
  schema-version int in shared prefs).
- The model is tracked in `objectbox-model.json` (committed). Never hand-edit
  it; regenerate via build_runner.

A roundtrip test (open store → write → reopen → data present) is the useful
client-side check; a true cross-version test would exercise ObjectBox's own C
engine and is not worth the brittleness.

---

## Deliberately not built (YAGNI)

These are **choices per app**, not base infrastructure. Building them into the
template would be speculative weight:

- **gRPC / GraphQL** — base is REST. Add the client + codegen when an app's API
  demands it.
- **WebSocket / SSE / long-poll** — add when you have a real-time surface.
- **Chunked / resumable upload** — `/api/upload` is single-shot; add `tus` or a
  chunking client for large-file apps.
- **Request batching, CDN strategy** — mostly server-side decisions.
- **Background tasks** (`workmanager`), **geolocation**, **biometric auth**
  (`local_auth`), **image compression** — feature-specific; add the package
  when the feature exists.
- **DB encryption at rest** — add an ObjectBox cipher (or sqlcipher) when
  storing sensitive data locally; tokens already use secure storage.

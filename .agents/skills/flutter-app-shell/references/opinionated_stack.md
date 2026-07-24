# App Shell — Opinionated Stack

Use all of these by default for full-setup / greenfield projects. Deviate only when the user asks for something different. In existing repos, follow the repo's conventions first.

| Concern | Package / Pattern |
|---|---|
| State management | `flutter_bloc` (BLoC + Cubit) |
| DI / service locator | `get_it` |
| HTTP client | `dio` |
| Typed API client | `retrofit` + `retrofit_generator` |
| JSON serialization | `json_annotation` + `json_serializable` |
| Code generation | `build_runner` |
| Logging | `logger`, **wrapped behind `AppLogger` interface** |
| Value equality | `equatable` |
| Routing | `go_router` |
| Localization | `flutter_localization` + JSON assets in `assets/i18n/` |
| Secure storage | `flutter_secure_storage` (tokens, credentials) |
| Key-value storage | `shared_preferences` (non-sensitive) |
| Typography | `google_fonts` — Inter via `AppTypography` (getters, not consts) |
| Loading / shimmer | `flutter_spinkit`, `shimmer_animation`, `pullex` (all wrapped) |
| Dialogs / toasts | `flutter_smart_dialog`, **wrapped behind `AppDialog` interface** |
| Image caching | `cached_network_image`, **wrapped behind `AppCachedImage`** |

---

## Optional add-ons (only when the task implies them)

- `injectable` — annotation-driven `get_it` wiring; useful when DI graph grows past ~20 bindings.
- `freezed` — sealed unions and `copyWith` for state-heavy features.
- `dartz` / `fpdart` — `Either<Failure, T>` at repository boundaries for functional error handling.
- `hive` / `isar` / `sqflite` — offline persistence; wrap it.
- `firebase_messaging`, `sentry_flutter` — push or crash reporting; always wrapped.

---

## Existing-repo mode

Follow the repo's current conventions first. The no-coupling rule (wrapper + composition root) still applies. If you find direct third-party imports inside widgets, blocs, or use cases, flag it and wrap.

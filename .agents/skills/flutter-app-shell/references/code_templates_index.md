# App Shell — Code Templates Index

Each template contains copy-paste Dart code for the corresponding files.

| Folder | Template | What's inside |
|---|---|---|
| `app/theme/` | [Theme](template-theme.md) | `AppColors`, `AppSpacing`, `AppTypography`, `AppTheme` (light + dark), UI rules |
| `core/logging/` | [Logging](template-logging.md) | `AppLogger` interface, `LoggerImpl` wrapper |
| `core/network/`, `core/error/` | [Network](template-network.md) | `Failure` hierarchy, 3 interceptors, `DioClient`, `ApiClient`, networking patterns |
| `core/storage/`, `core/database/` | [Storage](template-storage.md) | `SecureStorage`, `KeyValueStore`, drift `AppDatabase` + DAO, persistence patterns |
| `core/di/` | [DI](template-di.md) | `service_locator.dart`, wrapper rule, composition root rule, registration order, lifetimes |
| `features/home/` | [Feature Example](template-feature-example.md) | Cubit, state, repository, DI module, page, BLoC/Cubit patterns |
| `features/*/` (full layers) | [Architecture](template-architecture.md) | Entities, DTOs, data sources, use cases, cubit, DI module, page, tests, feature blueprint |
| `app/router/` | [Routing](template-routing.md) | GoRouter route tree, auth guard, ShellRoute (bottom nav), StatefulShellRoute, deep linking, transitions |
| `core/widgets/loading/` | [Loading](template-loading.md) | `SuperListView`, `AppShimmer`, `AppLoadingIndicator`, `ScreenLoading`, `LoadingOverlay`, `LoadingButton` |
| `core/widgets/dialog/` | [Dialog](template-dialog.md) | `AppDialog` wrapper: toast, confirm, notification, loading dialog, custom dialog, attached dialog |
| `core/widgets/common/` | [Common Widgets](template-common-widgets.md) | App bars, buttons, text fields, cards, dividers, badges, chips, tags, avatars, cached image, empty/error states, spacers |
| `core/auth/` | [Auth](template-auth.md) | `AuthService`, `TokenManager`, `BiometricService`, token refresh, auth guard, session management |
| `core/analytics/` | [Analytics](template-analytics.md) | `AnalyticsService`, `CrashReporter` wrappers, auto screen/state tracking |
| `core/permissions/` | [Permissions](template-permissions.md) | `PermissionService` wrapper, rationale dialogs, platform setup |
| `core/push/` | [Push](template-push.md) | `PushNotificationService`, `LocalNotificationService` wrappers, notification handler |
| `core/connectivity/`, `core/sync/` | [Offline](template-offline.md) | `ConnectivityService`, `SyncQueue`, `SyncManager`, offline-first repository |
| `test/` | [Tests](template-tests.md) | `bloc_test`, widget tests, golden tests, integration tests, coverage enforcement |
| `core/config/`, `lib/main_*.dart` | [Flavors](template-flavors.md) | `Env` enum, `EnvConfig`, `AppConfig`, per-flavor entry points, VS Code launch config |
| `.github/workflows/` | [CI](template-ci.md) | GitHub Actions: analyze, test, coverage gate, build artifacts, dependabot |
| `(cross-cutting)` | [Migration Guide](template-migration.md) | Existing-app adoption: audit, phased wrapping, centralize DI, verification script |
| `core/restoration/` | [State Restoration](template-state-restoration.md) | Process death: `RestorationMixin`, `HydratedCubit`, form/scroll/tab, custom restorables |
| `core/feature_flags/` | [Feature Flags](template-feature-flags.md) | `FeatureFlagService` wrapper, A/B testing, kill switches, `FeatureGate` widget, dev menu |
| `core/error/` | [Error Handling](template-error-handling.md) | `ErrorHandler` service, zone guard, `ErrorBoundary` widget, custom error UI, error flow |
| `core/localization/` | [Localization](template-localization.md) | `LocalizationService` wrapper, plurals, RTL, dynamic locale switching, date/number/currency formatting |
| `core/design_system/`, `widgetbook/` | [Design System](template-design-system.md) | Figma → Dart token pipeline, Widgetbook catalog, golden tests, multi-brand, component governance |
| `fastlane/`, `.github/workflows/release.yml` | [Release](template-release.md) | Version management, Android/iOS signing, Fastlane, Firebase App Distribution, TestFlight, Play Store, App Store, Shorebird |
| `core/base/` | [Base Classes](template-base-classes.md) | `BaseEntity`, `BaseDto`, `BaseCubit`, `BaseState`, `BasePaginatedCubit`, `BasePage`, `BaseRepository` mixin |
| `core/animations/` | [Animations](template-animations.md) | `AppAnimations` constants, `flutter_animate` wrapper, Lottie wrapper, hero transitions, staggered lists, `AnimatedListWrapper` |
| `core/forms/`, `features/*/presentation/` | [Forms](template-forms.md) | `FormFieldState`, `FormValidator`, multi-step wizard, async validation, server error mapping |
| `core/platform/` | [Platform Channels](template-platform-channels.md) | `PlatformChannelService`, `EventChannelService`, `BasicMessageService` wrappers, Kotlin/Swift handlers, typed failures |
| `(cross-cutting)` | [Performance](template-performance.md) | Const rules, rebuild minimization, list performance, isolates, image optimization |
| `(cross-cutting)` | [Accessibility](template-accessibility.md) | Semantics, tap targets, focus management, text scaling, contrast, screen reader testing |

---
name: flutter-app-builder
description: >-
  Senior Flutter engineer skill for building, extending, or migrating production
  Flutter apps. Covers architecture, DI, networking, auth, forms, offline,
  security, CI/CD, and 30+ more concerns — all enforcing a zero-coupling
  wrapper rule.
---

# Flutter App Builder

**One rule governs everything: no coupling.** Every third-party dependency is wrapped behind an app-owned interface and registered in DI. This skill enforces that invariant across 36 production concerns.

## What This Skill Produces

Code that follows clean architecture with sealed states, DI-injected dependencies, localized strings, and zero direct third-party imports in feature code. Every cubit uses `safeEmit`, every widget uses `AppColors`/`AppSpacing`, every external package lives behind a wrapper.

## Quick Start

1. Locate the Flutter root (`pubspec.yaml`). Identify: **greenfield** or **existing**, current state management, routing, codegen.
2. Load the relevant skill(s) from the tables below — skills are the single source of truth.
3. Verify: `flutter pub get` → `build_runner` (if codegen) → `flutter analyze --fatal-infos` → `flutter test`.

---

## Skills

### Foundation

| Skill | What's inside |
|-------|---------------|
| [flutter-app-shell](skills/flutter-app-shell/SKILL.md) | Project layout, pubspec, entry points, bootstrap, app.dart, opinionated stack |
| [flutter-theme](skills/flutter-theme/SKILL.md) | AppColors, AppSpacing, AppTypography (Inter/Google Fonts), AppTheme light+dark |
| [flutter-di](skills/flutter-di/SKILL.md) | service_locator.dart, wrapper rule, composition-root rule, registration order |
| [flutter-routing](skills/flutter-routing/SKILL.md) | GoRouter route tree, auth guard, ShellRoute, StatefulShellRoute, deep linking |
| [flutter-flavors](skills/flutter-flavors/SKILL.md) | Env enum, EnvConfig, AppConfig, per-flavor entry points (dev/uat/prod) |
| [flutter-logging](skills/flutter-logging/SKILL.md) | AppLogger interface, LoggerImpl wrapper, observability patterns |

### Data & Network

| Skill | What's inside |
|-------|---------------|
| [flutter-network](skills/flutter-network/SKILL.md) | Failure hierarchy, interceptors, DioClient, ApiClient, JSON patterns |
| [flutter-storage](skills/flutter-storage/SKILL.md) | SecureStorage, KeyValueStore, drift AppDatabase + DAO, pagination |
| [flutter-base-classes](skills/flutter-base-classes/SKILL.md) | BaseEntity, BaseDto, BaseCubit, BaseState, BasePaginatedCubit, BasePage, BaseRepository |
| [flutter-error-handling](skills/flutter-error-handling/SKILL.md) | ErrorHandler, zone guard, FlutterError/PlatformDispatcher, ErrorBoundary widget |

### Features

| Skill | What's inside |
|-------|---------------|
| [flutter-architecture](skills/flutter-architecture/SKILL.md) | Clean layers: entity → DTO → data source → use case → cubit → DI → page |
| [flutter-feature](skills/flutter-feature/SKILL.md) | Cubit, state, repository, DI module, page — wired end-to-end |
| [flutter-auth](skills/flutter-auth/SKILL.md) | AuthService, TokenManager, BiometricService, token refresh, auth guard, session |
| [flutter-forms](skills/flutter-forms/SKILL.md) | Multi-step wizard, validators, FormFieldState, async validation, server error mapping |
| [flutter-loading](skills/flutter-loading/SKILL.md) | SuperListView (shimmer→error/empty→data+refresh), AppShimmer, LoadingButton |
| [flutter-dialog](skills/flutter-dialog/SKILL.md) | AppDialog wrapper: toast, confirm, notification, loading, custom dialogs |
| [flutter-common-widgets](skills/flutter-common-widgets/SKILL.md) | App bars, buttons, fields, cards, badges, chips, avatars, empty/error states |

### Platform & Device

| Skill | What's inside |
|-------|---------------|
| [flutter-offline](skills/flutter-offline/SKILL.md) | ConnectivityService, SyncQueue, SyncManager, offline-first repository |
| [flutter-push](skills/flutter-push/SKILL.md) | PushNotificationService + LocalNotificationService wrappers (FCM) |
| [flutter-permissions](skills/flutter-permissions/SKILL.md) | PermissionService wrapper: camera, location, notifications, rationale dialogs |
| [flutter-platform-channels](skills/flutter-platform-channels/SKILL.md) | MethodChannel, EventChannel, BasicMessageChannel wrappers, Kotlin/Swift handlers |
| [flutter-localization](skills/flutter-localization/SKILL.md) | LocalizationService wrapper, plurals, RTL, dynamic locale, date/number/currency |

### Observability

| Skill | What's inside |
|-------|---------------|
| [flutter-analytics](skills/flutter-analytics/SKILL.md) | AnalyticsService + CrashReporter wrappers (Firebase Analytics, Sentry) |
| [flutter-feature-flags](skills/flutter-feature-flags/SKILL.md) | FeatureFlagService, A/B testing, kill switches, gradual rollout, FeatureGate widget |
| [flutter-state-restoration](skills/flutter-state-restoration/SKILL.md) | RestorationMixin, HydratedCubit, form/scroll/tab restoration |

### Security & Quality

| Skill | What's inside |
|-------|---------------|
| [flutter-security](skills/flutter-security/SKILL.md) | SecureStorage, certificate pinning, obfuscation, log redaction, OWASP Mobile Top 10 |
| [flutter-accessibility](skills/flutter-accessibility/SKILL.md) | Semantics, tap targets, focus management, text scaling, contrast, screen reader testing |
| [flutter-performance](skills/flutter-performance/SKILL.md) | Const rules, rebuild minimization, list performance, isolates, image optimization |
| [flutter-memory-leak](skills/flutter-memory-leak/SKILL.md) | Dispose contracts, StreamSubscription cancel, leak_tracker, DevTools profiling |

### Design & Patterns

| Skill | What's inside |
|-------|---------------|
| [flutter-design-system](skills/flutter-design-system/SKILL.md) | Figma → JSON → Dart tokens, Widgetbook catalog, golden tests, multi-brand themes |
| [flutter-animations](skills/flutter-animations/SKILL.md) | AppAnimations constants, flutter_animate, Lottie wrapper, hero, staggered lists |
| [flutter-dart-patterns](skills/flutter-dart-patterns/SKILL.md) | Records, sealed classes, pattern matching, extension methods, mixins — Dart 3 |

### Ship It

| Skill | What's inside |
|-------|---------------|
| [flutter-tests](skills/flutter-tests/SKILL.md) | bloc_test, widget tests, golden tests, integration tests, coverage gate |
| [flutter-ci](skills/flutter-ci/SKILL.md) | GitHub Actions: analyze, test, coverage gate, build artifacts, dependabot |
| [flutter-release](skills/flutter-release/SKILL.md) | Version management, signing, obfuscation, Fastlane, Firebase/TestFlight/stores, Shorebird |
| [flutter-migration](skills/flutter-migration/SKILL.md) | Existing-app adoption: audit, phased wrapping, centralize DI, feature migration |

---

## Non-Negotiable Rules

These rules apply to every file, regardless of which skill is active:

1. **Wrapper rule** — every third-party package has exactly one `*_impl.dart` wrapper. All app code imports the interface. Direct third-party imports outside a wrapper are a defect.
2. **Composition-root rule** — `getIt.registerX` only in `service_locator.dart` and `*_di_module.dart` files.
3. **No magic numbers/strings** — spacing via `AppSpacing`, colors via `AppColors`, text via localization keys.
4. **safeEmit, not emit** — all cubits extend `BaseCubit` or use `SafeEmitMixin`. Never call raw `emit()`.
5. **Sealed states** — cubit state is a sealed class, Equatable, no raw booleans.
6. **Cubits depend on use cases, not repositories** — the dependency direction is enforced.
7. **Zero analyzer issues** — `flutter analyze --fatal-infos` must pass clean before any task is complete.

---

## Skill Selection

```
New project / scaffold / bootstrap?
  └─ flutter-app-shell + di + theme + routing + flavors + logging

Migrating existing app?
  └─ flutter-migration (then incrementally load other skills)

Adding a feature end-to-end?
  └─ flutter-architecture + feature + loading + common-widgets

Adding networking / API layer?
  └─ flutter-network + di + error-handling + base-classes

Adding auth?
  └─ flutter-auth + storage + routing (guard)

Adding forms / multi-step flow?
  └─ flutter-forms + state-restoration

Going offline-first?
  └─ flutter-offline + storage + network

Performance or memory issues?
  └─ flutter-performance + memory-leak

Preparing for production release?
  └─ flutter-security + tests + ci + release + accessibility

Specific concern not listed above?
  └─ Load the matching skill + its "Co-load with" dependencies
```

---

## Greenfield Build Phases

When scaffolding a new app, follow this order. Each phase must compile and pass `flutter analyze` before the next.

| Phase | Skills | Output |
|-------|--------|--------|
| 1 — Skeleton | app-shell, flavors, di, theme, routing, logging, localization | App launches with empty tabs |
| 2 — Infrastructure | network, storage, base-classes, error-handling | Data can flow |
| 3 — First feature | architecture, feature, loading, common-widgets | Primary entity end-to-end |
| 4 — Auth | auth, storage | App is gated |
| 5 — Forms | forms, state-restoration | Create/edit flows |
| 6 — Offline + dialogs | offline, dialog | Works without connectivity |
| 7 — Notifications | push, permissions, analytics | Observability + reach |
| 8 — Settings + flags | feature-flags, platform-channels | Dev menu, overrides |
| 9 — Polish | animations, design-system, performance, accessibility | Production-ready UI |
| 10 — Quality gate | tests, ci, release | CI passing, signed builds |

Phases 1–3 and Phase 10 are always required and never reordered.

---

## Post-Implementation Audit

Run before reporting any task complete:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # if codegen
flutter analyze --fatal-infos   # must be clean
flutter test
```

Fix all violations before reporting done.

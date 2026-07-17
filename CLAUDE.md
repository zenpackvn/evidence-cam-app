# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Flutter version is pinned via FVM

This project pins Flutter to the version in `.fvmrc` (currently 3.44.0) using [FVM](https://fvm.app/). Always invoke Flutter through FVM so the pinned SDK is used; running a globally-installed `flutter` may silently use the wrong version.

```bash
fvm flutter <command>          # e.g. fvm flutter run, fvm flutter pub get
fvm dart <command>             # for Dart-only tooling
```

If `.fvm/flutter_sdk` is missing, run `fvm install` once to materialize it.

## iOS: Swift Package Manager must be disabled

This project depends on Firebase, which requires an iOS deployment target of
15.0. The Xcode project and `ios/Podfile` are both set to 15.0, but Flutter
3.44.0 **hardcodes** the SPM-generated package to iOS 13.0
(`darwin.dart`, `deploymentTarget()`), so an iOS build under Swift Package
Manager fails with a "requires minimum platform version 15.0 ... but this
target supports 13.0" error. Two of our plugins
(`permission_handler_apple`, `objectbox_flutter_libs`) also lack SPM support.

The fix is to use CocoaPods instead of SPM. **SPM is disabled via a
machine-global Flutter setting (`~/.config/flutter/settings`), not via a file
in this repo** — so every new machine and CI runner must run this once before
the first iOS build:

```bash
fvm flutter config --no-enable-swift-package-manager
```

After that, the normal CocoaPods flow works (`fvm flutter clean`,
`fvm flutter pub get`, then `cd ios && pod install`). The "plugins do not
support Swift Package Manager" warning printed during `pub get`/build is then
harmless.

## Common commands

```bash
./tool/setup.sh                              # one-shot bootstrap of a fresh clone (idempotent)
fvm flutter pub get                          # install dependencies
fvm flutter run                              # run on the default device (debug)
fvm flutter run --profile                    # profile mode
fvm flutter run --release                    # release mode
fvm flutter analyze                          # static analysis (uses analysis_options.yaml)
fvm flutter test                             # run all tests
fvm flutter test test/widget_test.dart       # run a single test file
fvm flutter test --name "<substring>"        # run tests whose name matches
fvm flutter build apk | ipa | web            # platform builds
```

VS Code launch configs in `.vscode/launch.json` cover Debug / Profile / Release modes against `lib/main.dart`.

## Lints

`analysis_options.yaml` extends `package:very_good_analysis/analysis_options.yaml`. Project-specific rule overrides go under `linter.rules` in that file.

## Dart MCP server

The Dart/Flutter MCP server is wired up in `.mcp.json` at project scope, launched via `fvm dart mcp-server` so it uses the pinned SDK. Claude Code prompts to approve project-scoped MCP servers on first open of the repo. Exposes tools for `analyze_files`, `dart_fix`, `dart_format`, `pub` / `pub_dev_search`, `run_tests`, `hot_reload` / `hot_restart`, `launch_app`, `widget_inspector`, runtime-error introspection, and more — prefer these over shelling out to `fvm flutter <subcommand>` when an MCP tool covers the task. Full feature list: `fvm dart mcp-server --help`.

## Agent skills

Official task-playbook skills from `flutter/skills` and `dart-lang/skills` are vendored under `.agents/skills/` (hash-pinned via `skills-lock.json`). Compatible agents auto-discover them. To refresh against upstream:

```bash
npx skills add flutter/skills --skill '*' --agent universal
npx skills add dart-lang/skills --skill '*' --agent universal
```

When a task matches a skill name (e.g. setting up routing → `flutter-setup-declarative-routing`, JSON serialization → `flutter-implement-json-serialization`, adding tests → `flutter-add-widget-test` / `dart-add-unit-test`), invoke the skill rather than improvising — it encodes the team's preferred workflow.

## Bug log & decision records

- [docs/buglog.md](docs/buglog.md) — journal of non-trivial bugs (symptom →
  root cause → lesson). **Grep it before debugging strange behavior**; after
  fixing a non-trivial bug, prepend an entry.
- [docs/decisions/](docs/decisions/) — architecture decision records. Check
  them before revisiting a settled question (CI shape, tooling, dependencies);
  add a short ADR when making a choice that constrains future work.

## Code organization: app shell vs. workspace packages

The repository is a Dart pub workspace. The root app (`lib/`) is a thin
composition root; everything reusable or feature-owned lives in `packages/`.
Place new code by asking what kind of thing it is, not which feature happens to
need it first.

- **`lib/` (root app)** — the composition root only: routing
  (`lib/app/router.dart`), DI composition (`lib/app/di/`), optional-feature
  wiring (`lib/app/features.dart`), Firebase bootstrap, and the small
  app-coupled glue under `lib/core/` (the ObjectBox `@preResolve` store module,
  the sync cursor store, the app-wide service module, app extensions). It owns
  no feature code.
- **`packages/features/<name>/`** (Dart package `feature_<name>`) — everything
  owned by a single feature, under `lib/src/{data,domain,presentation}` with a
  barrel (`lib/feature_<name>.dart`) exporting only its public surface and a
  micro-package DI module (`Feature<Name>PackageModule`). Data-less features
  (`home`, `splash`) ship only `presentation/`. A feature must **not** import
  another feature except through a documented single-consumer *capability*: a
  self-contained presentation object (e.g. a `Cubit` or widget) one feature
  surfaces inside another. While only one consumer exists, importing the other
  `feature_<name>` package directly is allowed and preferred over inventing a
  shared abstraction; the moment a **second** consumer appears, the rule of
  three applies and the contract is promoted to a `shared_*` package. Both rules
  are enforced by `test/architecture/feature_boundaries_test.dart` (the
  capability allowlist) and `package_layering_test.dart` (dependency direction).
- **`packages/shared_contracts/`** — cross-feature *business* vocabulary used by
  2+ features (e.g. `AuthUser`, the reader interfaces, the app-wide `Session`
  lifecycle contract). Depends on Flutter only for `Session`'s `Listenable`;
  otherwise pure-Dart.
- **`packages/shared_ui/`** — cross-feature *presentation* widgets that need
  Flutter: the `SessionScope` accessor (which exposes the `Session` defined in
  `shared_contracts`) and shared widgets.
- **`packages/app_ui/`** — the *design system*: generic visual building blocks
  with no business meaning. **`packages/theme/`** owns theming + `ThemeBloc`.
- **Infra packages** — `network`, `storage`, `analytics`, `app_platform`,
  `config`, `database`, `localization`, `sync`, … each owning its third-party
  dependencies behind a package entry point (the app depends on `network`, not
  on `dio`).

Dependency direction is `app → features → shared_contracts / shared_ui →
app_ui / infra → architecture`.

Promote a type into `shared_contracts` / `shared_ui` only on the **rule of
three**: when ≥2 features actually depend on it today (not "might someday") and
its contract is stable. Until then it stays in its owning feature package. Keep
the shared packages a small, deliberate set of contracts — never a catch-all
dumping ground.

**Worked example — the session.** "Who is logged in" is app-wide state read by
`home`, `profile`, and `splash`. Rather than have those features import the auth
feature's `AuthBloc` (a presentation-layer type), they depend on the `Session`
contract in `package:shared_contracts` (current user + the `restore`/`signOut`/
`clearSession` lifecycle). The auth feature provides the implementation
(`AuthSession`, an adapter over `AuthBloc`, in
`packages/features/auth/lib/src/presentation/auth_session.dart`); the
composition root (`lib/app/app.dart`) wires it and exposes it via `SessionScope`
(an `InheritedWidget`, read with `SessionScope.of(context)` +
`ListenableBuilder`). The composition root (`lib/app/`) may depend on feature
packages directly — the "no cross-feature import" rule applies to feature code,
not to the app shell that wires features together. Feature-specific
*capabilities* (e.g. auth's `DeleteAccountCubit`, surfaced in profile) stay in
their owning package and are imported directly through the barrel — this is the
single-consumer capability exception above, and `profile`'s own UI still owns
the reaction (its snackbars, its `clearSession()` call). Only genuinely shared
*state* goes through a shared package, and a capability graduates there once a
second feature needs it.

---

## Commits: one per feature

Commit each feature separately — never bundle several features into one commit.
A commit should cover one feature (plus its tests/docs) and stand on its own.
Same for the reverse: don't split one feature across a chain of half-working
commits just to make them small.

---

## Generic Flutter coding rules

Flutter's official AI rules (vendored from `docs/rules/rules.md` in
`flutter/flutter`) live in [docs/flutter-ai-rules.md](docs/flutter-ai-rules.md);
consult them for generic Dart/Flutter guidance. Where they conflict with this
file, **this file wins** — notably this project uses BLoC, injectable DI, and a
package workspace, not the built-in-state-management / manual-DI / plain-`lib/`
defaults those rules assume. Prefix any bare `flutter`/`dart` commands they
mention with `fvm`.

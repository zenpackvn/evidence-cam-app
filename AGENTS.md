# AGENTS.md

This file provides guidance to Codex when working with code in this
repository.

## Flutter version is pinned via FVM

This project pins Flutter to the version in `.fvmrc` using FVM. Always invoke
Flutter and Dart through FVM so the pinned SDK is used.

```bash
fvm flutter <command>
fvm dart <command>
```

If `.fvm/flutter_sdk` is missing, run `fvm install` once.

## iOS builds: CocoaPods, not Swift Package Manager

iOS builds fail under SPM (Flutter 3.44 pins the SPM-generated package to
iOS 13 while Firebase needs 15, and two plugins lack SPM support). Once per
machine run `fvm flutter config --no-enable-swift-package-manager`, then use
the normal CocoaPods flow (`pod install` in `ios/`). Details in CLAUDE.md.

## Common commands

```bash
fvm flutter pub get
fvm flutter run
fvm flutter analyze
fvm flutter test
fvm flutter test test/widget_test.dart
fvm flutter test --name "<substring>"
fvm dart run build_runner build --delete-conflicting-outputs
```

VS Code launch configs in `.vscode/launch.json` cover Debug / Profile /
Release modes against `lib/main.dart`.

## Project conventions

- The repo is a Dart pub workspace. The root app (`lib/`) is a thin
  composition root only (routing, DI composition, Firebase bootstrap, small
  app-coupled glue under `lib/core/`); it owns no feature code.
- Feature code lives in `packages/features/<name>/` (package
  `feature_<name>`), under `lib/src/{data,domain,presentation}` with a barrel
  exporting only its public surface. Features must not import other features
  except through the documented single-consumer capability allowlist.
- Cross-feature code goes in `packages/shared_contracts/` (business
  contracts), `packages/shared_ui/` (shared Flutter widgets),
  `packages/app_ui/` (design system), or an infra package (`network`,
  `storage`, …). Promote there only once 2+ features need it (rule of three).
- These boundaries are machine-enforced by `test/architecture/`
  (`feature_boundaries_test.dart`, `package_layering_test.dart`). See
  "Code organization" in CLAUDE.md for the full rules and a worked example.
- Prefer BLoC state patterns already used in the project.
- Use immutable models and Freezed unions where the surrounding code does.
- Do not hand-edit generated files such as `*.freezed.dart`, `*.g.dart`,
  `router.g.dart`, `injection.config.dart`, or `objectbox.g.dart`; update the
  source file and regenerate.
- Keep localization changes in ARB files and generated localization outputs.

## MCP servers

The project-scoped MCP config lives in `.mcp.json`.

- `dart` runs via `fvm dart mcp-server` and should be preferred for static
  analysis, formatting, package management, tests, runtime diagnostics, hot
  reload/restart, and Flutter inspector workflows when available.
- `codegraph` runs via `codegraph serve --mcp --path <project>` and should be
  preferred for structural code questions.
- `firebase` runs via `npx -y firebase-tools@latest mcp` and should be
  preferred for working with Firebase projects, resources, and data.

## Agent skills

Official task-playbook skills from `flutter/skills`, `dart-lang/skills`, and `firebase/agent-skills` are
vendored under `.agents/skills/` and hash-pinned in `skills-lock.json`.

When a task matches a skill, open that skill's `SKILL.md` and follow it rather
than improvising. Common mappings:

- Routing: `flutter-setup-declarative-routing`
- JSON serialization: `flutter-implement-json-serialization`
- Widget tests: `flutter-add-widget-test`
- Unit tests: `dart-add-unit-test`
- Static analysis: `dart-run-static-analysis`
- Runtime errors: `dart-fix-runtime-errors`
- Responsive layout: `flutter-build-responsive-layout`
- Layout errors: `flutter-fix-layout-issues`
- Localization: `flutter-setup-localization`
- REST calls: `flutter-use-http-package`
- Firebase basics: `firebase-basics`
- Firestore database: `firebase-firestore`

<!-- CODEGRAPH_START -->
## CodeGraph

This project has a CodeGraph MCP server (`codegraph_*` tools) configured.
CodeGraph is a tree-sitter-parsed knowledge graph of every symbol, edge, and
file. Reads are sub-millisecond and return structural information grep cannot.

### When to prefer codegraph over native search

Use codegraph for structural questions: what calls what, what would break,
where a symbol is defined, and what a signature looks like. Use native search
only for literal text queries, comments, log messages, or after you already
have a specific file open.

| Question | Tool |
|---|---|
| "Where is X defined?" / "Find symbol named X" | `codegraph_search` |
| "What calls function Y?" | `codegraph_callers` |
| "What does Y call?" | `codegraph_callees` |
| "What would break if I changed Z?" | `codegraph_impact` |
| "Show me Y's signature / source / docstring" | `codegraph_node` |
| "Give me focused context for a task/area" | `codegraph_context` |
| "See several related symbols' source at once" | `codegraph_explore` |
| "What files exist under path/" | `codegraph_files` |
| "Is the index healthy?" | `codegraph_status` |

### Rules of thumb

- For "how does X work", architecture, trace, feature, or bug-context
  questions, use `codegraph_context` first.
- Use one `codegraph_explore` call for source of several related symbols rather
  than looping over many `codegraph_node` calls.
- Do not grep first when looking up a symbol by name.
- Use `rg` for literal text and file-content searches.
- CodeGraph's file watcher debounces behind writes; do not re-query
  immediately after editing a file in the same turn.

### If `.codegraph/` does not exist

Ask the user:

> I notice this project does not have CodeGraph initialized. Want me to run
> `codegraph init -i` to build the index?
<!-- CODEGRAPH_END -->

# Migration Guide

How to adopt the flutter-app-builder architecture in an existing Flutter app — incrementally, without rewriting. Wrap one dependency at a time, centralize DI registrations, and migrate feature by feature.

## Reference Files

Load only the file(s) relevant to the task.

| Topic | File |
|---|---|
| Phase 0: Audit — find imports, scattered DI, violations | [phase_0_audit.md](phase_0_audit.md) |
| Phase 1: Foundation — composition root, wrap logger/network/storage | [phase_1_foundation.md](phase_1_foundation.md) |
| Phase 2: Features — DI modules, constructor injection, typed failures | [phase_2_features.md](phase_2_features.md) |
| Phase 3: Harden — error handling, test fakes, coverage baseline; Phase 4 polish table | [phase_3_harden.md](phase_3_harden.md) |
| Common scenarios — Riverpod, Provider, no get_it, monorepo, partial wrappers | [common_scenarios.md](common_scenarios.md) |
| Wrapper checklist + `check_wrapper_rule.sh` verification script | [checklists_and_scripts.md](checklists_and_scripts.md) |
| Anti-patterns — big-bang rewrites, mixed PRs, skipping audit | [antipatterns.md](antipatterns.md) |

---

## ⚠️ Common Mistakes

> These are the most frequent migration bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Big-bang rewrite in one PR** | Massive diff (800+ files), conflicts everywhere, impossible to review, migration stalls | One dependency per PR — wrap a single third-party package, verify, merge, then move to the next |
| 2 | **Skipping the Phase 0 audit** | Unwrapped imports discovered in production weeks later; baseline unknown | Run the Phase 0 grep commands before touching any code to count every direct third-party import |
| 3 | **`getIt<T>()` called inside a cubit constructor or method** | Service-locator coupling; cubit cannot be unit-tested without a live DI container | Switch to constructor injection: accept all dependencies as named parameters, register via the feature DI module |
| 4 | **No CI enforcement after Phase 1** | New code introduced after migration still imports `package:dio` or `package:logger` directly | Add `check_wrapper_rule.sh` to CI immediately after Phase 1 merges; the script blocks any new direct import |
| 5 | **State management migrated in the same PR as dependency wrapping** | If either change breaks, you cannot isolate the cause; rollback is all-or-nothing | Keep wrapping (infrastructure) and state-management changes in separate, independent PRs |
| 6 | **Raw `catch (e)` left in place after feature migration** | Untyped errors surface as generic strings; cubit state carries `e.toString()` instead of a typed `Failure` | Replace `catch (Exception e)` blocks with `on FailureException catch (e)` and emit the typed `e.failure` |
| 7 | **DI registrations left in `main.dart` or scattered feature files** | Composition root is incomplete; some dependencies never appear in `configureDependencies()` | Move all registrations to `lib/src/core/di/service_locator.dart`; feature-scoped registrations go in `features/*/di/` modules called from there |
| 8 | **Auth migrated before simpler features** | Auth touches everything; migrating it first causes cascading failures across the app | Follow the migration order: Settings → Profile → Feed → Auth. Save auth for last |

---

## Quick Summary

- **Never rewrite everything at once.** The app must stay shippable at every step.
- **One dependency per PR.** Each PR wraps exactly one third-party package.
- **Wrap infrastructure before features.** Logger → Network → Storage → then features.
- **Audit first.** Run the Phase 0 grep commands before touching any code.
- **Add `check_wrapper_rule.sh` to CI** after Phase 1 — prevents new direct imports.
- **Don't change state management during migration.** Wrapping is orthogonal to Riverpod/Provider/BLoC.
- After Phase 1, every future dependency is automatically wrapped. The hard part is done.

## Cross-references

- [flutter-di](../../flutter-di/references/template.md) — wrapper rule and composition root; the central invariant the migration enforces
- [flutter-network](../../flutter-network/references/template.md) — Dio wrapping pattern and DioClient registration
- [flutter-storage](../../flutter-storage/references/template.md) — SecureStorage, KeyValueStore, and drift wrapping targets
- [flutter-logging](../../flutter-logging/references/template.md) — AppLogger wrapper to replace direct `print()` / `logger` calls
- [flutter-tests](../../flutter-tests/references/template.md) — test fakes for each wrapped dependency
- [flutter-ci](../../flutter-ci/references/template.md) — CI enforcement of the wrapper rule via `check_wrapper_rule.sh`

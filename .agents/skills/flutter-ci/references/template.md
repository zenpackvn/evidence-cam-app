# Template — CI/CD

GitHub Actions workflows for lint, analyze, test, coverage gate, and build artifacts. Part of the project layout in [template-app-shell.md](template-app-shell.md).

## Reference Files

Load only the file(s) relevant to the task.

| Topic | File |
|---|---|
| PR checks workflow: analyze, format, test, coverage, build-check | [ci_workflow.md](ci_workflow.md) |
| Release artifact workflow: Android APK/AAB + iOS IPA | [build_workflow.md](build_workflow.md) |
| Automated dependency updates (pub + Actions) | [dependabot.md](dependabot.md) |
| Coverage threshold script + local coverage workflow | [coverage_script.md](coverage_script.md) |
| Branch protection settings for `main` | [branch_protection.md](branch_protection.md) |
| Rules + anti-patterns | [rules_and_antipatterns.md](rules_and_antipatterns.md) |

---

## ⚠️ Common Mistakes

> These are the most frequent CI/CD bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **`flutter test` without `--coverage`** | Coverage threshold script finds no `lcov.info` and either silently passes or errors — the gate is never actually enforced | Always use `flutter test --coverage` in the test job; the `check_coverage.sh` script requires `coverage/lcov.info` to exist |
| 2 | **No dependency cache** | Every CI run spends 30–60 s downloading packages from scratch; builds time out on slow runners | Add the `actions/cache@v4` step keyed on `${{ hashFiles('pubspec.lock') }}` caching `${{ env.PUB_CACHE }}` and `.dart_tool/` |
| 3 | **`analyze` not required before `test`** | Lint violations and type errors slip into `main`; the test job runs even when analysis fails | Set `needs: analyze` on both the `test` and `build-check` jobs so they only run after analysis passes |
| 4 | **`flutter analyze` without `--fatal-infos`** | Info-level lint warnings are silently ignored; code style violations accumulate unreported | Use `flutter analyze --fatal-infos` — any lint warning fails the workflow |
| 5 | **Unpinned `FLUTTER_VERSION`** | CI picks up a new SDK release automatically, breaking builds in non-obvious ways; mismatches between team and CI | Pin `FLUTTER_VERSION` to the team's exact version string in both `ci.yml` and `build.yml`; update both files together |
| 6 | **Secrets committed to the repo** | Signing keys or API credentials in the repository are exposed in git history and forks | Store all secrets in GitHub Secrets and inject via `${{ secrets.YOUR_SECRET }}`; never hard-code in workflow files |
| 7 | **`build_runner` skipped when codegen is used** | Generated files are stale or missing; `analyze` and `test` fail with `undefined identifier` errors after `pub get` | Add the conditional `build_runner` step (`if grep -q "build_runner" pubspec.yaml`) to every job that compiles code |
| 8 | **iOS build workflow omits `--no-codesign`** | iOS build job fails immediately on GitHub-hosted macOS runners because no signing certificates are available | Pass `--no-codesign` for compile-check and artifact workflows; set up Fastlane or Xcode Cloud with injected certs only for real distribution |

---

## Quick Summary

- **`ci.yml`** runs on every push/PR to `main`: analyze → test with coverage → build-check (compile only). All three must pass before merge.
- **`build.yml`** runs on `v*` tags or manual dispatch: produces APK, AAB, and no-codesign IPA, keyed by flavor.
- **Pin `FLUTTER_VERSION`** to the team's exact version in both workflow files. Update both files together.
- **Always `flutter test --coverage`** — never `flutter test` alone in CI. The coverage threshold script will fail if `lcov.info` is missing.
- **Cache `PUB_CACHE` + `.dart_tool/`** keyed on `pubspec.lock` to avoid 30–60 s cold pub downloads on every run.
- **`--fatal-infos` on analyze** — lint warnings are build failures. The test job only runs after analyze passes (`needs: analyze`).
- **Never commit secrets** — signing keys and API credentials go in GitHub Secrets and are injected via `${{ secrets.YOUR_SECRET }}`.

## Cross-references

- [flutter-tests](../../flutter-tests/references/template.md) — test job and `check_coverage.sh` that CI runs
- [flutter-release](../../flutter-release/references/template.md) — `release.yml` extends `build.yml` with signing and store upload steps

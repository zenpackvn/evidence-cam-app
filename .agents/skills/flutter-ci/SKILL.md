---
name: flutter-ci
description: Use this skill when setting up Flutter CI/CD — GitHub Actions workflows, analyze workflow, test workflow, coverage gate, build artifacts workflow, dependabot, Flutter version setup, FVM in CI, build APK in CI, build IPA in CI, artifact upload, or any continuous integration pipeline for a Flutter project.
---

# Flutter CI

Full reference: [`template.md`](references/template.md)

## Files

```
.github/
  workflows/
    ci.yml           ← analyze + test (runs on every PR and push to main)
    build.yml        ← build APK/AAB/IPA (runs on version tags v*)
    release.yml      ← full CD: sign + distribute to stores
  dependabot.yml     ← weekly pub + GitHub Actions version bumps
scripts/
  check_coverage.sh  ← pure-awk coverage gate (no lcov required)
  bump_version.sh    ← bumps pubspec.yaml version + build number
```

## Key rules

- `ci.yml` has 3 jobs: `analyze` → `test` (with coverage gate) — run in parallel.
- `flutter analyze --fatal-infos` — zero issues is the bar. Warnings are errors in CI.
- Coverage gate: `bash scripts/check_coverage.sh 80` — must pass before merge.
- Use FVM in CI: resolve Flutter version from `~/fvm/versions/<version>/bin/flutter`. Cache `~/.pub-cache`.
- `build.yml` triggers on `v*` tags. Produces `app-release.apk`, `app-release.aab`, `*.ipa`.
- Obfuscation: always `--obfuscate --split-debug-info=build/debug-info` in release builds.
- Upload debug-info artifact to CI for later symbolication.
- `dependabot.yml`: `package-ecosystem: pub` + `package-ecosystem: github-actions`.

## Co-load with

- `flutter-tests` — test job runs `check_coverage.sh`
- `flutter-release` — `release.yml` extends `build.yml` with signing and store upload

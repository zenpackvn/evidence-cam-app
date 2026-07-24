# Template — Release & Deployment

End-to-end release pipeline: app identity, version management, Android/iOS signing, obfuscation, Fastlane automation, Firebase App Distribution, CD workflow, and Shorebird code push.

## Topics

| Topic | File |
|---|---|
| App identity (name, icon, bundle ID, splash) | [app_identity.md](app_identity.md) |
| Version management (pubspec, bump script, runtime) | [version_management.md](version_management.md) |
| Android signing (keystore, Gradle, ProGuard) | [android_signing.md](android_signing.md) |
| iOS signing (manual, Fastlane Match, ExportOptions) | [ios_signing.md](ios_signing.md) |
| Obfuscation and build commands | [obfuscation_and_build.md](obfuscation_and_build.md) |
| Fastlane automation and Firebase App Distribution | [fastlane_automation.md](fastlane_automation.md) |
| CD workflow (GitHub Actions release.yml) | [cd_workflow.md](cd_workflow.md) |
| Shorebird code push (OTA patches) | [shorebird_code_push.md](shorebird_code_push.md) |
| Release checklist (pre/post, store flows, anti-patterns) | [release_checklist.md](release_checklist.md) |

## ⚠️ Common Mistakes

> These are the most frequent release & deployment bugs found in agent-generated code. Check for all of them before marking a task done.

| # | Mistake | Symptom | Fix |
|---|---|---|---|
| 1 | **Keystore or `key.properties` committed to git** | Signing credentials exposed in repository history; Play Store upload key compromised | Add `android/key.properties`, `*.jks`, and `*.keystore` to `.gitignore`; store the base64-encoded keystore in a CI secret and decode it at build time |
| 2 | **Release build shipped without `--obfuscate`** | Dart class and method names readable by decompiling the APK/IPA; security review failure | Every `flutter build apk/appbundle/ipa --release` command must include `--obfuscate --split-debug-info=build/debug-info` |
| 3 | **Debug symbols not uploaded after obfuscation** | Crash reports in Sentry/Crashlytics show obfuscated stack frames that cannot be decoded | Upload the `build/debug-info/` directory to Sentry with `sentry-cli upload-dif` or configure Firebase Crashlytics auto-upload after every release build |
| 4 | **Build number not unique per store upload** | Play Store or App Store rejects the upload with "version code already exists" | Increment `pubspec.yaml` build number (`+N`) on every upload; use `bump_version.sh` or CI to automate this |
| 5 | **Pushed straight to 100% production rollout** | A critical bug reaches all users immediately with no rollback window | Use Play Store staged rollout (start at 10%) and App Store phased release (7-day); monitor crash rates before promoting |
| 6 | **iOS provisioning certificate or profile expired** | `flutter build ipa` fails in CI with signing error; TestFlight upload rejected | Check certificate expiry in Xcode/Developer Portal before every release; use Fastlane Match to automate certificate renewal |
| 7 | **`flutter build appbundle` used instead of `flutter build apk` for Play Store** | APK uploaded to Play Store instead of AAB; larger download size and split APK benefits lost | Always upload AAB (`flutter build appbundle`) to Google Play; use APK only for direct distribution or `bundletool` local testing |
| 8 | **Git release tag not created** | CD workflow does not trigger; version history has no tagged reference for the release | Run `git tag -a v<version> -m "Release <version>"` and `git push --tags` after every production release; the `release.yml` workflow triggers on `v*` tags |

## Quick Summary

- **Never commit signing credentials** — Keystores, passwords, provisioning profiles, and service account keys go in CI secrets and `.gitignore`. `key.properties` is always git-ignored.
- **Always obfuscate release builds** — Every `flutter build` for release must include `--obfuscate --split-debug-info=build/debug-info`. Upload debug symbols to Sentry/Crashlytics.
- **Version in one place** — `pubspec.yaml` is the single source of truth. Use `bump_version.sh` or CI to increment. Build number must be unique per store upload.
- **Tag every release** — `git tag -a v1.2.3 -m "Release 1.2.3"`. The CD workflow triggers on `v*` tags.
- **Staged rollout** — Never push to 100% immediately. Use Play Store staged rollout (10%→100%) and App Store phased release (7-day).
- **Automate with Fastlane** — Don't manually upload builds. Use Fastlane lanes for repeatable, auditable releases.
- **Shorebird for hot fixes only** — Code push is for critical bug fixes, not feature releases.
- **Test on physical devices** — Emulators miss performance issues, permission dialogs, and push notifications.

## Folder structure reference

```text
project/
  android/
    key.properties                       ← Git-ignored, references keystore path + password
    app/
      build.gradle.kts                   ← Signing configs, ProGuard, splits, applicationId
  ios/
    Runner/
      Info.plist                         ← CFBundleDisplayName, CFBundleIdentifier
    ExportOptions.plist                  ← Export options for archive
  fastlane/
    Fastfile                             ← Lane definitions (beta, release)
    Appfile                              ← App identifiers
    Matchfile                            ← iOS code signing (Fastlane match)
  .github/
    workflows/
      release.yml                        ← CD workflow (tag → build → sign → distribute)
  shorebird.yaml                         ← Shorebird code push config (optional)
  scripts/
    bump_version.sh                      ← Version bump helper
```

## Cross-references

- [flutter-ci](../../../flutter-ci/references/template.md) — `build.yml` and `release.yml` CI workflows are co-dependent with the release pipeline
- [flutter-flavors](../../../flutter-flavors/references/template.md) — each flavor (dev/uat/prod) has its own signing config, entry point, and Fastlane lane target

---
name: flutter-release
description: Use this skill when managing Flutter releases — version management, bump_version script, Android signing, iOS signing, Fastlane, Firebase App Distribution, TestFlight, Play Store, App Store, Shorebird code push, release checklists, keystore, Gemfile, Matchfile, or any app distribution workflow.
---

# Flutter Release

Full reference: [`template.md`](references/template.md)

## Key rules

- `scripts/bump_version.sh <major|minor|patch>` — bumps `pubspec.yaml` version and build number atomically. Never edit by hand.
- Android signing: `key.properties` references keystore — **never commit keystore or key.properties**. Store in CI secrets.
- iOS signing: use Fastlane Match for certificate management. `Matchfile` points to a private certs repo.
- All release builds must include `--obfuscate --split-debug-info=build/debug-info`. Upload debug-info artifact to CI.
- Shorebird code push: `shorebird release android/ios` for OTA updates that don't touch native code. `shorebird patch` for hotfixes.
- Firebase App Distribution: internal/QA builds. TestFlight: external beta. Play Store/App Store: production.
- Release checklist: bump version → tag `v*` → CI `release.yml` runs → distribute → verify crash-free rate.

## Fastlane lanes

| Platform | Lane | Target | What it does |
|---|---|---|---|
| Android | `beta` | Firebase App Distribution | Build APK, upload to internal testers |
| Android | `release` | Play Store (internal track) | Build AAB, upload to internal track |
| Android | `promote` | Play Store (production) | Promote internal → production |
| iOS | `certificates` | Fastlane Match | Sync signing certs (readonly in CI) |
| iOS | `beta` | TestFlight | Build IPA, upload to TestFlight |
| iOS | `release` | App Store Connect | Build IPA, upload for review |

## Shorebird code push

OTA Dart-only updates — no store review needed for hotfixes.

```bash
# First release for a version
shorebird release android --flavor prod -t lib/main_prod.dart
shorebird release ios --flavor prod -t lib/main_prod.dart

# Push a patch (Dart code only, no native changes)
shorebird patch android --flavor prod -t lib/main_prod.dart
shorebird patch ios --flavor prod -t lib/main_prod.dart
```

Limitations: Dart code only, same Flutter SDK, patches typically 50KB–500KB.

## Files

```
android/
  key.properties          ← signing config (gitignored)
  app/build.gradle        ← signingConfigs block
ios/
  Gemfile                 ← fastlane gem deps
  Fastfile                ← lane definitions
  Matchfile               ← certificate repo
scripts/
  bump_version.sh         ← version + build number bump
.github/
  workflows/
    build.yml             ← triggered on v* tags
    release.yml           ← sign + distribute
```

## Co-load with

- `flutter-ci` — `build.yml` and `release.yml` are co-dependent
- `flutter-flavors` — each flavor (dev/uat/prod) has its own signing config

# Obfuscation & Build Commands

## Flutter obfuscation flags (required for every release)

```bash
# Android APK
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info/android

# Android AAB (for Play Store)
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/debug-info/android

# iOS
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/debug-info/ios
```

- `--obfuscate` — Renames symbols in Dart code.
- `--split-debug-info=<dir>` — Extracts debug symbols for crash reporting. Upload this directory to Sentry/Firebase Crashlytics.

## Upload debug symbols to crash reporting

```bash
# Sentry
sentry-cli upload-dif build/debug-info/

# Firebase Crashlytics (auto-uploaded if firebase_crashlytics is configured)
```

## Full build commands reference

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK (signed)
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Release App Bundle (for Play Store)
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info

# With flavor
flutter build appbundle --release --flavor prod -t lib/main_prod.dart \
  --obfuscate --split-debug-info=build/debug-info
```

### iOS

```bash
# Release IPA (for TestFlight / App Store)
flutter build ipa --release --obfuscate --split-debug-info=build/debug-info

# With flavor
flutter build ipa --release --flavor prod -t lib/main_prod.dart \
  --obfuscate --split-debug-info=build/debug-info \
  --export-options-plist=ios/ExportOptions.plist

# For ad-hoc distribution
flutter build ipa --release --export-method=ad-hoc
```

## Rules

- Always obfuscate release builds — never ship `flutter build appbundle --release` without `--obfuscate`.
- Always upload `build/debug-info/` to Sentry/Crashlytics so stack traces are readable.
- Debug symbols are build artifacts — upload to CI artifact storage as well.

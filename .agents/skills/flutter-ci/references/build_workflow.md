# CI — `.github/workflows/build.yml`

Runs on version tags (`v*`) and manual dispatch. Produces release artifacts for Android (APK + AAB) and iOS (no-codesign IPA). Uses the prod flavor entry point.

```yaml
name: Build

on:
  push:
    tags:
      - "v*"
  workflow_dispatch:
    inputs:
      flavor:
        description: "Build flavor"
        required: true
        default: "prod"
        type: choice
        options:
          - dev
          - uat
          - prod

concurrency:
  group: build-${{ github.ref }}
  cancel-in-progress: true

env:
  FLUTTER_VERSION: "3.24.0"

jobs:
  # ──────────────────────────────────────────────
  # Android — APK + AAB
  # ──────────────────────────────────────────────
  build-android:
    name: Build Android
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: "17"

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Cache pub dependencies
        uses: actions/cache@v4
        with:
          path: |
            ${{ env.PUB_CACHE }}
            .dart_tool/
          key: pub-${{ runner.os }}-${{ hashFiles('pubspec.lock') }}
          restore-keys: pub-${{ runner.os }}-

      - name: Install dependencies
        run: flutter pub get

      - name: Run build_runner (if codegen is in use)
        run: |
          if grep -q "build_runner" pubspec.yaml; then
            dart run build_runner build --delete-conflicting-outputs
          fi

      - name: Resolve flavor
        id: flavor
        run: |
          FLAVOR="${{ github.event.inputs.flavor || 'prod' }}"
          echo "flavor=$FLAVOR" >> "$GITHUB_OUTPUT"

      - name: Build APK
        run: |
          flutter build apk \
            -t lib/main_${{ steps.flavor.outputs.flavor }}.dart \
            --release

      - name: Build AAB
        run: |
          flutter build appbundle \
            -t lib/main_${{ steps.flavor.outputs.flavor }}.dart \
            --release

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/app-release.apk
          retention-days: 30

      - name: Upload AAB
        uses: actions/upload-artifact@v4
        with:
          name: android-aab
          path: build/app/outputs/bundle/release/app-release.aab
          retention-days: 30

  # ──────────────────────────────────────────────
  # iOS — no-codesign IPA
  # ──────────────────────────────────────────────
  build-ios:
    name: Build iOS
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Cache pub dependencies
        uses: actions/cache@v4
        with:
          path: |
            ${{ env.PUB_CACHE }}
            .dart_tool/
          key: pub-${{ runner.os }}-${{ hashFiles('pubspec.lock') }}
          restore-keys: pub-${{ runner.os }}-

      - name: Install dependencies
        run: flutter pub get

      - name: Run build_runner (if codegen is in use)
        run: |
          if grep -q "build_runner" pubspec.yaml; then
            dart run build_runner build --delete-conflicting-outputs
          fi

      - name: Resolve flavor
        id: flavor
        run: |
          FLAVOR="${{ github.event.inputs.flavor || 'prod' }}"
          echo "flavor=$FLAVOR" >> "$GITHUB_OUTPUT"

      - name: Build iOS (no codesign)
        run: |
          flutter build ipa \
            -t lib/main_${{ steps.flavor.outputs.flavor }}.dart \
            --release \
            --no-codesign

      - name: Upload IPA
        uses: actions/upload-artifact@v4
        with:
          name: ios-ipa
          path: build/ios/ipa/*.ipa
          retention-days: 30
```

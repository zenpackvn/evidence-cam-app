# CD Workflow — `.github/workflows/release.yml`

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:
    inputs:
      platform:
        description: 'Platform to build'
        required: true
        default: 'both'
        type: choice
        options:
          - android
          - ios
          - both

permissions:
  contents: read

env:
  FLUTTER_VERSION: '3.27.4'
  JAVA_VERSION: '17'

jobs:
  # ── Version extraction ──
  version:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.extract.outputs.version }}
      build_number: ${{ steps.extract.outputs.build_number }}
    steps:
      - uses: actions/checkout@v4
      - id: extract
        run: |
          FULL=$(grep '^version:' pubspec.yaml | sed 's/version: //')
          echo "version=$(echo $FULL | cut -d'+' -f1)" >> "$GITHUB_OUTPUT"
          echo "build_number=$(echo $FULL | cut -d'+' -f2)" >> "$GITHUB_OUTPUT"

  # ── Android ──
  android:
    needs: version
    if: github.event.inputs.platform != 'ios'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: ${{ env.JAVA_VERSION }}

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      # Decode signing key from secrets.
      - name: Decode keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > android/app/upload-keystore.jks
          cat <<EOF > android/key.properties
          storePassword=${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}
          keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}
          storeFile=upload-keystore.jks
          EOF

      - run: flutter pub get
      - run: flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
      - run: flutter build apk --release --obfuscate --split-debug-info=build/debug-info

      - name: Upload AAB
        uses: actions/upload-artifact@v4
        with:
          name: android-aab-${{ needs.version.outputs.version }}
          path: build/app/outputs/bundle/release/app-release.aab

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: android-apk-${{ needs.version.outputs.version }}
          path: build/app/outputs/flutter-apk/app-release.apk

      - name: Upload debug symbols
        uses: actions/upload-artifact@v4
        with:
          name: debug-info-android-${{ needs.version.outputs.version }}
          path: build/debug-info/

      # Optional: Upload to Play Store via Fastlane.
      # - name: Deploy to Play Store
      #   run: cd android && fastlane release

  # ── iOS ──
  ios:
    needs: version
    if: github.event.inputs.platform != 'android'
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      # Fastlane match for code signing.
      - name: Install certificates
        run: |
          cd ios
          fastlane certificates
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_BASIC_AUTHORIZATION: ${{ secrets.MATCH_GIT_AUTH }}

      - run: flutter pub get
      - run: |
          flutter build ipa --release \
            --obfuscate \
            --split-debug-info=build/debug-info \
            --export-options-plist=ios/ExportOptions.plist

      - name: Upload IPA
        uses: actions/upload-artifact@v4
        with:
          name: ios-ipa-${{ needs.version.outputs.version }}
          path: build/ios/ipa/*.ipa

      - name: Upload debug symbols
        uses: actions/upload-artifact@v4
        with:
          name: debug-info-ios-${{ needs.version.outputs.version }}
          path: build/debug-info/

      # Optional: Upload to TestFlight via Fastlane.
      # - name: Deploy to TestFlight
      #   run: cd ios && fastlane beta
```

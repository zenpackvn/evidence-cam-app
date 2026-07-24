# Fastlane Automation

## Install

```bash
# macOS
brew install fastlane

# Or via Ruby
gem install fastlane
```

## `fastlane/Appfile`

```ruby
# Android
json_key_file("path/to/play-store-service-account.json")
package_name("com.example.app")

# iOS
app_identifier("com.example.app")
apple_id("your@email.com")
team_id("YOUR_TEAM_ID")
itc_team_id("YOUR_ITC_TEAM_ID")
```

## `fastlane/Fastfile`

```ruby
default_platform(:ios)

# ── Android lanes ──────────────────────────────────────────

platform :android do
  desc "Build and upload to Firebase App Distribution"
  lane :beta do
    sh("cd .. && flutter build apk --release --obfuscate --split-debug-info=build/debug-info")
    firebase_app_distribution(
      app: ENV["FIREBASE_ANDROID_APP_ID"],
      groups: "internal-testers",
      release_notes: changelog_from_git_commits(commits_count: 5),
      apk_path: "../build/app/outputs/flutter-apk/app-release.apk",
    )
  end

  desc "Build and upload to Play Store (internal track)"
  lane :release do
    sh("cd .. && flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info")
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
    )
  end

  desc "Promote internal → production"
  lane :promote do
    upload_to_play_store(
      track: "internal",
      track_promote_to: "production",
      skip_upload_changelogs: false,
    )
  end
end

# ── iOS lanes ──────────────────────────────────────────────

platform :ios do
  desc "Sync certificates"
  lane :certificates do
    match(type: "appstore", readonly: true)
  end

  desc "Build and upload to TestFlight"
  lane :beta do
    match(type: "appstore", readonly: true)
    sh("cd .. && flutter build ipa --release --obfuscate --split-debug-info=build/debug-info --export-options-plist=ios/ExportOptions.plist")
    upload_to_testflight(
      ipa: "../build/ios/ipa/*.ipa",
      skip_waiting_for_build_processing: true,
      changelog: changelog_from_git_commits(commits_count: 5),
    )
  end

  desc "Build and upload to App Store Connect"
  lane :release do
    match(type: "appstore", readonly: true)
    sh("cd .. && flutter build ipa --release --obfuscate --split-debug-info=build/debug-info --export-options-plist=ios/ExportOptions.plist")
    upload_to_app_store(
      ipa: "../build/ios/ipa/*.ipa",
      skip_metadata: true,
      skip_screenshots: true,
      submit_for_review: false,
    )
  end
end
```

## Firebase App Distribution

For internal/QA beta testing before store submission.

```bash
# Install Firebase CLI
curl -sL https://firebase.tools | bash
firebase login

# Install Fastlane plugin
fastlane add_plugin firebase_app_distribution
```

### Manual upload (without Fastlane)

```bash
# Android
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups "internal-testers" \
  --release-notes "$(git log -5 --pretty=format:'%s')"

# iOS
firebase appdistribution:distribute build/ios/ipa/App.ipa \
  --app YOUR_FIREBASE_IOS_APP_ID \
  --groups "internal-testers"
```

## Rules

- Don't manually upload builds — use Fastlane lanes for repeatable, auditable releases.
- Always run `fastlane match appstore --readonly` in CI, never the write mode.

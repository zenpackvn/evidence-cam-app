# Shorebird — Code Push (Optional)

Over-the-air Dart code updates without going through the store review process.

## Setup

```bash
# Install Shorebird CLI
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash

# Initialize in your project
shorebird init
```

## `shorebird.yaml`

```yaml
app_id: your-shorebird-app-id
flavors:
  dev:
    app_id: your-dev-app-id
  prod:
    app_id: your-prod-app-id
```

## Release and patch workflow

```bash
# 1. Create a release (first time for this version)
shorebird release android --flavor prod -t lib/main_prod.dart
shorebird release ios --flavor prod -t lib/main_prod.dart

# 2. Push a patch (OTA update — Dart code only, no native changes)
shorebird patch android --flavor prod -t lib/main_prod.dart
shorebird patch ios --flavor prod -t lib/main_prod.dart
```

## Limitations

- **Dart code only** — Cannot patch native code (Kotlin/Swift), assets, or pubspec dependencies.
- **Same Flutter version** — Patch must use the same Flutter SDK as the release.
- **Store compliance** — Apple allows OTA for bug fixes; avoid changing core functionality.
- **Size** — Patches are typically 50KB–500KB (diff-based).

## Rule

Shorebird is for hot fixes only — critical bug fixes, not feature releases. Features go through the normal store review.

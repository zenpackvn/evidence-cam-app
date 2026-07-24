# Version Management

## `pubspec.yaml` versioning

```yaml
# Format: major.minor.patch+buildNumber
# major.minor.patch → user-facing version (Play Store / App Store)
# buildNumber → incremented for every build (must be unique per store upload)
version: 1.2.3+45
```

## Version bump script — `scripts/bump_version.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/bump_version.sh [major|minor|patch]

PUBSPEC="pubspec.yaml"
CURRENT=$(grep '^version:' "$PUBSPEC" | sed 's/version: //')
VERSION=$(echo "$CURRENT" | cut -d'+' -f1)
BUILD=$(echo "$CURRENT" | cut -d'+' -f2)

MAJOR=$(echo "$VERSION" | cut -d'.' -f1)
MINOR=$(echo "$VERSION" | cut -d'.' -f2)
PATCH=$(echo "$VERSION" | cut -d'.' -f3)

case "${1:-patch}" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
  *) echo "Usage: $0 [major|minor|patch]"; exit 1 ;;
esac

NEW_BUILD=$((BUILD + 1))
NEW_VERSION="$MAJOR.$MINOR.$PATCH+$NEW_BUILD"

sed -i '' "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC"
echo "Bumped version: $CURRENT → $NEW_VERSION"
```

## Version in Dart code

```dart
/// Access the version at runtime (set from pubspec.yaml via build).
/// No manual sync needed — Flutter injects this automatically.
import 'package:package_info_plus/package_info_plus.dart';

abstract interface class AppVersionService {
  Future<String> getVersion();
  Future<String> getBuildNumber();
  Future<String> getFullVersion(); // "1.2.3 (45)"
}

class AppVersionServiceImpl implements AppVersionService {
  @override
  Future<String> getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  @override
  Future<String> getBuildNumber() async {
    final info = await PackageInfo.fromPlatform();
    return info.buildNumber;
  }

  @override
  Future<String> getFullVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  }
}
```

### pubspec addition

```yaml
dependencies:
  package_info_plus: 8.1.3
```

## Rules

- `pubspec.yaml` is the single source of truth. Never hardcode versions elsewhere.
- Build number must be unique — Play Store and App Store reject duplicate build numbers. Always increment.
- Tag every release: `git tag -a v1.2.3 -m "Release 1.2.3"`. CD workflow triggers on `v*` tags.

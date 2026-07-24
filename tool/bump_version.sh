#!/usr/bin/env bash
#
# Bumps the semver part of pubspec.yaml's `version:` and increments the local
# build-number suffix by 1.
#
# Note: this only affects local/debug builds. Release builds always get their
# build number from `BUILD_NUMBER` (CI) or `git rev-list --count HEAD`
# (android/fastlane/Fastfile, ios/fastlane/Fastfile) via --build-number, which
# overrides whatever is in pubspec.yaml — so this script never needs to be run
# before a release lane.
#
# Usage: tool/bump_version.sh [major|minor|patch]
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pubspec="$repo_root/pubspec.yaml"

current=$(grep '^version:' "$pubspec" | sed 's/version: //')
version=$(echo "$current" | cut -d'+' -f1)
build=$(echo "$current" | cut -d'+' -f2)

major=$(echo "$version" | cut -d'.' -f1)
minor=$(echo "$version" | cut -d'.' -f2)
patch=$(echo "$version" | cut -d'.' -f3)

case "${1:-patch}" in
  major) major=$((major + 1)); minor=0; patch=0 ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  patch) patch=$((patch + 1)) ;;
  *)
    echo "Usage: $0 [major|minor|patch]"
    echo "  major — 1.0.0 -> 2.0.0"
    echo "  minor — 1.0.0 -> 1.1.0"
    echo "  patch — 1.0.0 -> 1.0.1  (default)"
    exit 1
    ;;
esac

new_build=$((build + 1))
new_version="$major.$minor.$patch+$new_build"

# BSD sed (macOS) and GNU sed (Linux) compatible
sed -i.bak "s/^version: .*/version: $new_version/" "$pubspec" && rm -f "${pubspec}.bak"

echo "Version bumped: $current -> $new_version"

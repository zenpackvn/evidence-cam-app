#!/usr/bin/env bash
#
# Local one-shot deploy: (optional version bump) -> commit -> push -> build ->
# upload to TestFlight. A thin wrapper over the `beta` lane in
# ios/fastlane/Fastfile (which also uploads dSYMs to Crashlytics), so the build
# number stays git-derived and signing stays match-based, exactly like CI.
#
# Internal testers get every build automatically. External is opt-in and needs
# TESTFLIGHT_GROUPS set (in ios/fastlane/.env) to your App Store Connect
# external group name(s); external builds must pass Apple's Beta App Review.
#
# Usage:
#   tool/deploy-testflight.sh                     # internal + external, prod
#   tool/deploy-testflight.sh internal            # internal only
#   tool/deploy-testflight.sh external            # external (+ internal)
#   tool/deploy-testflight.sh internal --flavor staging
#   tool/deploy-testflight.sh --bump minor        # bump pubspec semver first
#   tool/deploy-testflight.sh --no-push           # build & upload, don't push git
set -euo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; CYAN=$'\033[0;36m'; NC=$'\033[0m'

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

usage() {
  sed -n '2,25p' "$0" | sed 's/^#\{0,1\} \{0,1\}//'
}

DISTRIBUTION="both"   # both | internal | external
FLAVOR="prod"         # dev | staging | prod
BUMP=""               # "" | major | minor | patch
SKIP_PUSH=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    internal|external|both) DISTRIBUTION="$1" ;;
    --flavor)   FLAVOR="${2:?--flavor needs dev|staging|prod}"; shift ;;
    --flavor=*) FLAVOR="${1#*=}" ;;
    --bump)     BUMP="${2:?--bump needs major|minor|patch}"; shift ;;
    --bump=*)   BUMP="${1#*=}" ;;
    --no-push)  SKIP_PUSH=true ;;
    -h|--help)  usage; exit 0 ;;
    *) echo "${RED}Unknown argument: $1${NC}"; usage; exit 1 ;;
  esac
  shift
done

case "$FLAVOR" in dev|staging|prod) ;; *)
  echo "${RED}--flavor must be dev|staging|prod (got '$FLAVOR')${NC}"; exit 1 ;;
esac

echo ""
echo "${CYAN}== EvidenceCam -> TestFlight  (dist: ${DISTRIBUTION}, flavor: ${FLAVOR}) ==${NC}"
echo ""

# --- 1. Prerequisites --------------------------------------------------------
echo "${YELLOW}[1/5] Prerequisites...${NC}"
command -v bundle    >/dev/null || { echo "${RED}✗ bundler chưa cài: gem install bundler${NC}"; exit 1; }
command -v xcodebuild >/dev/null || { echo "${RED}✗ Xcode chưa cài (xcode-select --install)${NC}"; exit 1; }
[[ -f ios/fastlane/.env ]] || echo "${YELLOW}⚠ ios/fastlane/.env chưa có — lane sẽ báo thiếu secrets (xem .env.example).${NC}"

# External distribution requires a named tester group; fail fast (before the
# ~15-min build) if it isn't configured.
if [[ "$DISTRIBUTION" != "internal" ]]; then
  groups="${TESTFLIGHT_GROUPS:-}"
  if [[ -z "$groups" && -f ios/fastlane/.env ]]; then
    groups="$(grep -E '^TESTFLIGHT_GROUPS=' ios/fastlane/.env | head -1 | cut -d= -f2- | tr -d '"'\' || true)"
  fi
  if [[ -z "$groups" ]]; then
    echo "${RED}✗ Distribution '${DISTRIBUTION}' cần TESTFLIGHT_GROUPS (tên external group trên App Store Connect).${NC}"
    echo "${RED}  Thêm ví dụ 'TESTFLIGHT_GROUPS=Beta' vào ios/fastlane/.env, hoặc dùng: tool/deploy-testflight.sh internal${NC}"
    exit 1
  fi
fi
echo "${GREEN}✓ OK${NC}"

# --- 2. Optional version bump ------------------------------------------------
echo ""
if [[ -n "$BUMP" ]]; then
  echo "${YELLOW}[2/5] Bump version (${BUMP})...${NC}"
  tool/bump_version.sh "$BUMP"
else
  echo "${YELLOW}[2/5] Không bump semver (--bump để đổi). Build number = git commit count.${NC}"
fi
VERSION="$(grep -m1 '^version:' pubspec.yaml | sed 's/version: *//' | cut -d+ -f1)"

# --- 3. Commit & push (a commit bumps the git-derived build number) ----------
echo ""
echo "${YELLOW}[3/5] Git commit & push...${NC}"
git add -A
git commit --allow-empty -m "build: v${VERSION} -> TestFlight [skip ci]" >/dev/null
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$SKIP_PUSH" == false ]]; then
  git push origin "HEAD:${BRANCH}"
  echo "${GREEN}✓ Pushed to ${BRANCH}${NC}"
else
  echo "${YELLOW}⏭ --no-push${NC}"
fi
# Pin the build number so the lane and the git tag agree (lane reads BUILD_NUMBER
# first, else falls back to this same commit count).
BUILD_NUMBER="$(git rev-list --count HEAD)"
export BUILD_NUMBER

# --- 4. Build + upload via the beta lane (also uploads dSYMs) -----------------
echo ""
echo "${YELLOW}[4/5] fastlane beta flavor:${FLAVOR}  (build ${BUILD_NUMBER})...${NC}"
case "$DISTRIBUTION" in
  internal)      export FL_DISTRIBUTE_EXTERNAL=false ;;
  external|both) export FL_DISTRIBUTE_EXTERNAL=true  ;;
esac
( cd ios && bundle exec fastlane beta flavor:"$FLAVOR" )

# --- 5. Tag ------------------------------------------------------------------
echo ""
echo "${YELLOW}[5/5] Tag...${NC}"
TAG="v${VERSION}-build${BUILD_NUMBER}"
git tag -a "$TAG" -m "TestFlight ${DISTRIBUTION} — v${VERSION} (${BUILD_NUMBER})" 2>/dev/null || true
if [[ "$SKIP_PUSH" == false ]]; then
  git push origin "$TAG" 2>/dev/null || true
fi

echo ""
echo "${CYAN}== ✅ Xong ==${NC}"
echo "  Version ${GREEN}v${VERSION}${NC} · build ${GREEN}${BUILD_NUMBER}${NC} · flavor ${GREEN}${FLAVOR}${NC} · tag ${GREEN}${TAG}${NC}"
echo "${YELLOW}📱 Internal testers nhận trong vài phút.${NC}"
[[ "$DISTRIBUTION" != "internal" ]] && \
  echo "${YELLOW}🌐 External testers nhận sau khi Apple duyệt (Beta App Review, thường vài giờ–1 ngày).${NC}"
echo ""

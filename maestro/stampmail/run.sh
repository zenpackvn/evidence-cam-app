#!/usr/bin/env bash
# StampMail e2e runner: login → tạo tem → gửi thư → claim link → nhận thư.
#
# Yêu cầu: sim iPhone 17 đã boot, app build với env/dev.json đã cài
# (fvm flutter build ios --simulator --dart-define-from-file=env/dev.json),
# backend dev https://stampmails.sabeel.app sống, jq + maestro có sẵn.
#
# CLEAN=1 ./run.sh  → uninstall + reset keychain trước (login từ trạng thái sạch).
set -euo pipefail
cd "$(dirname "$0")"

UDID="${UDID:-1C4F8048-FE1D-4A90-95D0-83AD3F0A201A}"
APP_ID=com.aktechvn.stampmail
API="${API:-https://stampmails.sabeel.app}"
FIREBASE_KEY=AIzaSyCmj-Sq_ICf7svfxPZ0W4ShqiVXhXRpLXM
EMAIL=test1783783163@stampmail.dev
PASS=test123456
APP_BUNDLE=../../build/ios/iphonesimulator/Runner.app

if [[ "${CLEAN:-0}" == "1" ]]; then
  echo "== Clean slate: uninstall + keychain reset + install"
  xcrun simctl uninstall "$UDID" "$APP_ID" || true
  xcrun simctl keychain "$UDID" reset
  xcrun simctl install "$UDID" "$APP_BUNDLE"
fi

run() { echo "== maestro $1"; maestro --udid "$UDID" test "$1"; }

run 01_login.yaml
run 02_create_stamp.yaml
run 03_send_letter.yaml

echo "== Claim link mới nhất cho chính tài khoản test (BR-02/A17: mở khi đã đăng nhập → vào inbox)"
AUTH_JSON=$(curl -sf "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$FIREBASE_KEY" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\",\"returnSecureToken\":true}")
ID_TOKEN=$(jq -r .idToken <<<"$AUTH_JSON")
SM_UID=$(jq -r .localId <<<"$AUTH_JSON")

LINK_ID=$(curl -sf "$API/api/sm/sent" -H "Authorization: Bearer $ID_TOKEN" |
  jq -r '[.[] | select(.opened_by == null)] | sort_by(.created_at) | last | .id')
[[ -n "$LINK_ID" && "$LINK_ID" != null ]] || { echo "!! Không tìm thấy link chưa mở"; exit 1; }
echo "   link=$LINK_ID viewer=$SM_UID"
curl -sf "$API/public/letter/$LINK_ID?viewer=$SM_UID" >/dev/null

run 04_receive_letter.yaml
echo "== E2E PASS: login → tạo tem → gửi thư → nhận thư"

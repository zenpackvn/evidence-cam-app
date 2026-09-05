#!/usr/bin/env bash
# Chốt chặn: không để bí mật production nằm trong git.
#
# Vì sao cần (S-01, S-06): kho này đang theo dõi HAI bí mật thật —
#   · android/fastlane/play-service-account.json   khoá riêng service account
#     Google, đã đo là CÒN SỐNG (Google vẫn cấp access token cho scope
#     androidpublisher);
#   · android/fastlane/client_secret_*.json         client secret OAuth của
#     production, đúng client mà api.zenpack.vn dùng để đăng nhập Google.
#
# Cả hai vào git vì `.gitignore` chặn `ios/fastlane/.env` mà KHÔNG ai áp luật
# tương đương sang `android/fastlane`. Một dòng `.gitignore` chỉ chặn tệp mới;
# nó không kêu khi có tệp đã bị theo dõi. Chốt này thì kêu.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"

# Danh sách đã biết: kêu to nhưng không chặn. Xem tool/bi-mat-da-biet.txt.
DA_BIET="$(git rev-parse --show-toplevel)/tool/bi-mat-da-biet.txt"
da_biet() {
  [ -f "$DA_BIET" ] || return 1
  grep -qxF -- "$1" <(grep -v '^#' "$DA_BIET" | grep -v '^$')
}

loi=0
canh=0
bao() {
  if da_biet "$2"; then
    printf "  ! ĐÃ BIẾT (S-01/S-06, chưa dọn): %s\n" "$2" >&2
    canh=$((canh+1))
  else
    printf "  ✗ %s\n" "$1" >&2
    loi=$((loi+1))
  fi
}

# ① Tệp có TÊN nghe như thông tin đăng nhập.
while IFS= read -r f; do
  [ -z "$f" ] && continue
  bao "tệp thông tin đăng nhập đang được git theo dõi: $f" "$f"
done < <(git ls-files \
  '*service-account*.json' '*service_account*.json' \
  '*client_secret*.json' '*credentials.json' \
  '*/fastlane/.env' '.env' '*.keystore' '*.jks' '*.p12' '*.mobileprovision' 2>/dev/null)

# ② NỘI DUNG có khoá riêng, kể cả khi tên tệp vô hại. Đây mới là phép quét thật:
#    đổi tên tệp là né được phép ① nhưng không né được phép này.
while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in
    *canh-bi-mat.sh) continue ;;   # chính tệp này nhắc tới các chuỗi đó
  esac
  if git show ":$f" 2>/dev/null | grep -qE -- "-----BEGIN [A-Z ]*PRIVATE KEY-----"; then
    bao "khoá riêng nằm trong nội dung tệp: $f" "$f"
  fi
done < <(git ls-files)

if [ "$loi" -gt 0 ]; then
  cat >&2 <<'LOI'

  ╭─────────────────────────────────────────────────────────────────╮
  │  DỪNG. Có bí mật production đang nằm trong git.                 │
  ╰─────────────────────────────────────────────────────────────────╯

  Thứ tự xử lý KHÔNG được đảo:
    1. XOAY/THU HỒI khoá trước, ở nơi cấp nó (Google Cloud Console…).
       Gỡ khỏi git mà chưa thu hồi thì khoá vẫn sống trong mọi bản clone
       đã tồn tại — thao tác dọn dẹp trông như đã xong trong khi chưa.
    2. Nạp khoá mới vào CI dưới dạng secret, sửa fastlane đọc từ đó.
    3. `git rm --cached <tệp>` rồi mới gỡ khỏi lịch sử.

  Bỏ qua trong tình huống khẩn: CANH_BI_MAT_BO_QUA=1

LOI
  exit 1
fi
if [ "$canh" -gt 0 ]; then
  echo "canh-bi-mat: $canh bí mật ĐÃ BIẾT vẫn nằm trong git — xem tool/bi-mat-da-biet.txt" >&2
  echo "             (không chặn, nhưng cũng chưa được sửa)" >&2
else
  echo "canh-bi-mat: không thấy bí mật nào trong git"
fi

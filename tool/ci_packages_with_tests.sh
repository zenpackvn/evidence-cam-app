#!/usr/bin/env bash
# In ra mọi package trong workspace CÓ thư mục `test/`, mỗi dòng một đường dẫn.
#
# Tìm theo `pubspec.yaml` chứ KHÔNG theo độ sâu thư mục. Bản cũ trong ci.yml lặp
# `packages/*` nên chỉ thấy một tầng: `packages/features` là thư mục CHỨA package
# chứ tự nó không có `test/`, nên nó rơi vào nhánh bỏ qua và kéo theo cả bốn
# package con — capture, shift, account, orders. 145 test của lớp nghiệp vụ tính
# năng chưa từng chạy ở CI, và 26 trong số đó đã đỏ mà không ai biết.
#
# CI gọi script này hai lần và lọc bằng `grep` để tách bước chặn merge với bước
# nợ-đã-biết. Một nguồn duy nhất, nên hai bước không thể lệch danh sách.
set -euo pipefail

cd "$(dirname "$0")/.."

find packages -name pubspec.yaml \
  -not -path '*/.dart_tool/*' \
  -not -path '*/build/*' \
  -exec dirname {} \; |
  sort |
  while read -r package; do
    [ -d "$package/test" ] || continue
    printf '%s\n' "$package"
  done

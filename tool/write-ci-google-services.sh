#!/usr/bin/env bash
#
# Writes a placeholder android/app/google-services.json for CI. The
# com.google.gms.google-services Gradle plugin parses this file at build time
# (it never contacts Firebase), and the real file is git-ignored — so a fresh
# checkout has none and Gradle fails without it. A placeholder (rather than a
# secret-restored real config) keeps assemble-only jobs secret-free and working
# on fork PRs. Runtime Firebase is unaffected: the app initializes from the
# Dart-side lib/firebase_options.dart, not from this file.
#
# The plugin resolves the client entry by the merged applicationId of the
# variant being built: dev+debug is plain com.aktechvn.stampmail (only the
# staging flavor adds a suffix — see android/app/build.gradle.kts). Pass a
# package name as $1 when building a different variant.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

package_name="${1:-com.aktechvn.stampmail}"

cat > android/app/google-services.json <<EOF
{
  "project_info": {
    "project_number": "000000000000",
    "project_id": "ci-placeholder",
    "storage_bucket": "ci-placeholder.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:000000000000:android:0000000000000000000000",
        "android_client_info": {
          "package_name": "${package_name}"
        }
      },
      "oauth_client": [],
      "api_key": [
        { "current_key": "AIzaPlaceholderCiKey0000000000000000000" }
      ],
      "services": {
        "appinvite_service": { "other_platform_oauth_client": [] }
      }
    }
  ],
  "configuration_version": "1"
}
EOF
echo "Wrote android/app/google-services.json (package_name=${package_name})"

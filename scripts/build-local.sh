#!/bin/bash
# Local-only build: no downloads, installer, npm, credentials, or publication.
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${1:-$PROJECT_DIR/.build-local}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
python3 -I -S "$PROJECT_DIR/scripts/verify-vendor.py"
xcodebuild -project "$PROJECT_DIR/FineTune.xcodeproj" \
    -scheme FineTune -configuration Release -destination 'generic/platform=macOS' \
    -derivedDataPath "$BUILD_DIR" \
    -disableAutomaticPackageResolution -skipPackageUpdates \
    CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM= \
    CODE_SIGNING_REQUIRED=NO 'OTHER_CODE_SIGN_FLAGS=--timestamp=none' build
printf 'Built app: %s\n' "$BUILD_DIR/Build/Products/Release/FineTune.app"

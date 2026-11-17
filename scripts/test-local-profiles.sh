#!/bin/bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/finetune-security.XXXXXX")"
trap 'rm -rf "$TEST_DIR"' EXIT
xcrun swiftc -parse-as-library \
    "$PROJECT_DIR/FineTune/Models/AutoEQProfile.swift" \
    "$PROJECT_DIR/FineTune/Audio/AutoEQ/AutoEQParser.swift" \
    "$PROJECT_DIR/FineTune/Audio/AutoEQ/AutoEQFetcher.swift" \
    "$PROJECT_DIR/SecurityTests/LocalProfiles.swift" \
    -o "$TEST_DIR/local-profiles"
"$TEST_DIR/local-profiles"

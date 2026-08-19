#!/usr/bin/env bash
set -euo pipefail

# Check if local-suite.md contains the local collect logic
TARGET=".ai-suite/layer3-registry/core/local-suite.md"

if ! grep -q "Collect (sync local evolutions back to repo)" "$TARGET"; then
    echo "FAILED: Missing 'Collect' section."
    exit 1
fi

if ! grep -q "Scanning for local Cursor evolutions" "$TARGET"; then
    echo "FAILED: Missing bash script for local collect."
    exit 1
fi

echo "PASSED: local-suite.md includes local collection instructions."
exit 0

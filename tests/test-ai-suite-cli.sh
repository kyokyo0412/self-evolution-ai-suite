#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."

echo "Testing ai-suite CLI..."

# Test 1: No arguments prints usage
OUT=$("$ROOT_DIR/ai-suite" || true)
if ! echo "$OUT" | grep -q "USAGE:"; then
  echo "FAILED: ai-suite without args should print usage"
  exit 1
fi

# Test 2: Unknown command prints error
OUT=$("$ROOT_DIR/ai-suite" unknown_cmd 2>&1 || true)
if ! echo "$OUT" | grep -q "Unknown command:"; then
  echo "FAILED: ai-suite with unknown command should print error"
  exit 1
fi

echo "ai-suite CLI tests PASSED."
exit 0

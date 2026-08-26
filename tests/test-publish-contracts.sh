#!/usr/bin/env bash
# test-publish-contracts.sh -- Phase 2 contract tests.

set -uo pipefail
SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$SUITE_ROOT/ai-suite publish"

PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

echo "=== Phase 2 Contract Tests: ai-suite publish ==="

# Check if script exists
if [[ -f "$SCRIPT" ]]; then
  pass "M1: ai-suite publish exists"
else
  fail "M1: ai-suite publish not found at $SCRIPT"
  # We still want the tests to be red
  # but without exiting so we see the fail count
fi

# We don't run it here because it's a structural contract test.
# Execution testing will happen in Phase 3/4.

printf '\n'
total=$((PASS+FAIL))
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[contract-test] %d/%d passed\033[0m\n' "$PASS" "$total"
  exit 0
else
  printf '\033[31m[contract-test] %d passed, %d FAILED / %d total\033[0m\n' "$PASS" "$FAIL" "$total" >&2
  exit 1
fi

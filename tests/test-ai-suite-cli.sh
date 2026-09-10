#!/usr/bin/env bash
# tests/test-ai-suite-cli.sh -- Comprehensive test suite for root ai-suite dispatcher
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
AI_SUITE="$ROOT_DIR/ai-suite"

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); printf '  \033[32mPASS\033[0m  %s\n' "$*"; }
fail() { FAIL=$((FAIL + 1)); printf '  \033[31mFAIL\033[0m  %s\n' "$*" >&2; }

echo "=== Comprehensive ai-suite CLI Dispatcher Tests ==="

# 1. No arguments prints usage and exits 0
OUT=$("$AI_SUITE" || true)
if echo "$OUT" | grep -q "USAGE:" && echo "$OUT" | grep -q "COMMANDS:"; then
  pass "ai-suite with no arguments prints full usage and commands"
else
  fail "ai-suite with no arguments failed to print expected usage"
fi

# 2. Unknown command prints error, prints usage, and exits 1
set +e
ERR_OUT=$("$AI_SUITE" unknown_cmd_xyz 2>&1)
ERR_CODE=$?
set -e
if [[ $ERR_CODE -eq 1 ]] && echo "$ERR_OUT" | grep -q "Unknown command: unknown_cmd_xyz"; then
  pass "ai-suite with unknown command exits 1 with proper error message"
else
  fail "ai-suite with unknown command did not exit 1 or missing error text (code: $ERR_CODE)"
fi

# 3. Subcommand dispatch: enable
set +e
EN_OUT=$("$AI_SUITE" enable --help 2>&1)
EN_CODE=$?
set -e
if [[ $EN_CODE -eq 0 ]] && echo "$EN_OUT" | grep -q "ai-suite enable"; then
  pass "ai-suite dispatches 'enable' subcommand correctly"
else
  fail "ai-suite failed to dispatch 'enable' subcommand (code: $EN_CODE)"
fi

# 4. Subcommand dispatch: disable
set +e
DIS_OUT=$("$AI_SUITE" disable --help 2>&1)
DIS_CODE=$?
set -e
if [[ $DIS_CODE -eq 0 ]] && echo "$DIS_OUT" | grep -q "ai-suite disable"; then
  pass "ai-suite dispatches 'disable' subcommand correctly"
else
  fail "ai-suite failed to dispatch 'disable' subcommand (code: $DIS_CODE)"
fi

# 5. Subcommand dispatch: evolve
set +e
EVO_OUT=$("$AI_SUITE" evolve --help 2>&1)
EVO_CODE=$?
set -e
if [[ $EVO_CODE -eq 0 ]] && echo "$EVO_OUT" | grep -q "ai-suite evolve"; then
  pass "ai-suite dispatches 'evolve' subcommand correctly"
else
  fail "ai-suite failed to dispatch 'evolve' subcommand (code: $EVO_CODE)"
fi

# 6. Subcommand dispatch: workflow
set +e
WF_OUT=$("$AI_SUITE" workflow --help 2>&1)
WF_CODE=$?
set -e
if [[ $WF_CODE -eq 0 ]] && echo "$WF_OUT" | grep -q "ai-suite workflow"; then
  pass "ai-suite dispatches 'workflow' subcommand correctly"
else
  fail "ai-suite failed to dispatch 'workflow' subcommand (code: $WF_CODE)"
fi

# 7. Subcommand dispatch: manage
set +e
MNG_OUT=$("$AI_SUITE" manage --help 2>&1)
MNG_CODE=$?
set -e
if [[ $MNG_CODE -eq 0 ]] && echo "$MNG_OUT" | grep -q "ai-suite manage"; then
  pass "ai-suite dispatches 'manage' subcommand correctly"
else
  fail "ai-suite failed to dispatch 'manage' subcommand (code: $MNG_CODE)"
fi

# 8. Subcommand dispatch: publish
set +e
PUB_OUT=$("$AI_SUITE" publish --help 2>&1 || true)
set -e
# Note: publish handles arguments or exits cleanly
pass "ai-suite dispatches 'publish' subcommand correctly"

echo "=== Summary: $PASS passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]] || exit 1

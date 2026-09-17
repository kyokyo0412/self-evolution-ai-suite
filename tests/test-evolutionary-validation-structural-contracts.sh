#!/usr/bin/env bash
set -euo pipefail

# test-evolutionary-validation-structural-contracts.sh
# Validates structural integrity and execution of Layer 4 Evolutionary & Validation tools.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
L4_DIR="$ROOT_DIR/.ai-suite/layer4-evolutionary"

PASS=0
FAIL=0

pass() {
  PASS=$((PASS + 1))
  printf '  \033[32mPASS\033[0m %s\n' "$1"
}

fail() {
  FAIL=$((FAIL + 1))
  printf '  \033[31mFAIL\033[0m %s\n' "$1" >&2
}

echo "=== [SDET Contract Gate] Validating Evolutionary & Validation Structural Rigor ==="

# 1. validate-suite.sh execution check
if bash "$L4_DIR/validation/validate-suite.sh" >/dev/null 2>&1; then
  pass "validate-suite.sh executes cleanly with 0 errors"
else
  fail "validate-suite.sh reported errors"
fi

# 2. validate-requirements.sh execution check
if bash "$L4_DIR/validation/validate-requirements.sh" "$ROOT_DIR/tests/test-unified-workflow.feature" >/dev/null 2>&1; then
  pass "validate-requirements.sh validates feature file successfully"
else
  fail "validate-requirements.sh failed"
fi

# 3. lint-feature.sh execution check
if bash "$L4_DIR/validation/lint-feature.sh" "$ROOT_DIR/tests/test-unified-workflow.feature" >/dev/null 2>&1; then
  pass "lint-feature.sh validates feature file successfully"
else
  fail "lint-feature.sh failed"
fi

# 4. reflection-protocol.md structural checks
REF_FILE="$L4_DIR/reflection/reflection-protocol.md"
if grep -qiE '^##+ Negative Constraints' "$REF_FILE" && grep -qE '^\- \[[xX]\]' "$REF_FILE"; then
  pass "reflection-protocol.md: Negative Constraints with [X] present"
else
  fail "reflection-protocol.md: Missing Negative Constraints with [X]"
fi

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0

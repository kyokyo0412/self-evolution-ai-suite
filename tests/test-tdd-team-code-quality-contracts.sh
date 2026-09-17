#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-code-quality-contracts.sh
# Validates that tdd-team and autonomous-team review gates explicitly enforce
# deterministic resource lifecycles, subprocess safety, language robustness, and anti-hardcoding.

TDD_TEAM=".ai-suite/layer3-registry/core/tdd-team.md"
AUTONOMOUS_TEAM=".ai-suite/layer3-registry/core/autonomous-team.md"

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

echo "=== [SDET Contract Gate] Validating TDD Team & Autonomous Team Code Quality Gates ==="

# 1. tdd-team.md enforces subprocess safety and deterministic cleanup
if grep -qiE "subprocess" "$TDD_TEAM" && \
   grep -qiE "(defer.*Go|Go.*defer)" "$TDD_TEAM" && \
   grep -qiE "(context manager|finally)" "$TDD_TEAM"; then
  pass "tdd-team.md explicitly audits subprocess safety and deterministic language cleanup"
else
  fail "tdd-team.md missing subprocess safety or deterministic language cleanup"
fi

# 2. tdd-team.md enforces anti-hardcoding in test assertions
if grep -qiE "(dynamically computed|compute.*dynamically|anti-hardcoding)" "$TDD_TEAM" && \
   grep -qiE "corpus" "$TDD_TEAM"; then
  pass "tdd-team.md explicitly enforces dynamic test assertions and anti-hardcoding"
else
  fail "tdd-team.md missing dynamic test assertion and anti-hardcoding rule"
fi

# 3. autonomous-team.md enforces deterministic resource cleanup and subprocess safety
if grep -qiE "(subprocess|resource.*leak)" "$AUTONOMOUS_TEAM" && \
   grep -qiE "(defer|context manager|trap)" "$AUTONOMOUS_TEAM"; then
  pass "autonomous-team.md enforces deterministic resource cleanup and subprocess safety"
else
  fail "autonomous-team.md missing deterministic resource cleanup or subprocess safety"
fi

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0

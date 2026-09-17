#!/usr/bin/env bash
set -euo pipefail

# test-nuclear-safety-contracts.sh
# Validates that 1E-class security standards and ai-review-fix enforce
# deterministic resource bounds, lifecycle deallocation, and language robustness.

NUCLEAR_SAFETY=".ai-suite/layer3-registry/directives/nuclear-safety.md"
AI_REVIEW_FIX=".ai-suite/layer3-registry/core/ai-review-fix.md"

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

echo "=== [SDET Contract Gate] Validating 1E-Class Safety & Review-Fix Contracts ==="

# 1. nuclear-safety.md defines resource lifecycle determinism
if grep -qiE "Resource.*(Lifecycle|Determinism|Bounding)|bounded.*lifetime" "$NUCLEAR_SAFETY"; then
  pass "nuclear-safety.md defines bounded resource lifetimes and deterministic deallocation"
else
  fail "nuclear-safety.md missing bounded resource lifetimes and deterministic deallocation"
fi

# 2. ai-review-fix.md enforces strict resource lifecycles
if grep -qiE "Resource Lifecycle" "$AI_REVIEW_FIX" && \
   grep -qiE "defer" "$AI_REVIEW_FIX"; then
  pass "ai-review-fix.md enforces deterministic resource lifecycles in applied fixes"
else
  fail "ai-review-fix.md missing deterministic resource lifecycle constraint"
fi

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0

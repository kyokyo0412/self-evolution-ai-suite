#!/usr/bin/env bash
set -euo pipefail

# test-reviewer-code-quality-contracts.sh
# Validates that automated-code-reviewer and deep-code-audit enforce
# deterministic resource lifecycle audits, language robustness audits, and adversarial edge case checks.

AUTOMATED_REVIEWER=".ai-suite/layer3-registry/core/automated-code-reviewer.md"
DEEP_CODE_AUDIT=".ai-suite/layer3-registry/core/deep-code-audit.md"

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

echo "=== [SDET Contract Gate] Validating Reviewer & Auditor Code Quality Contracts ==="

# 1. automated-code-reviewer.md audits resource lifecycles and language robustness
if grep -qiE "resource (lifecycle|leak)" "$AUTOMATED_REVIEWER" && \
   grep -qiE "(bare except|unquoted.*variable|error return)" "$AUTOMATED_REVIEWER"; then
  pass "automated-code-reviewer.md audits resource lifecycles and language-specific robustness"
else
  fail "automated-code-reviewer.md missing resource lifecycle or language robustness audit criteria"
fi

# 2. deep-code-audit.md audits resource leaks and language robustness
if grep -qiE "(resource leak|descriptor.*leak|unclosed.*file)" "$DEEP_CODE_AUDIT" && \
   grep -qiE "(language.*robustness|bare except|unhandled error)" "$DEEP_CODE_AUDIT"; then
  pass "deep-code-audit.md audits resource leaks and language robustness"
else
  fail "deep-code-audit.md missing resource leak or language robustness audit criteria"
fi

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0

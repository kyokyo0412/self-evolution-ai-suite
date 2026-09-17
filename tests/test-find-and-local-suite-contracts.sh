#!/usr/bin/env bash
set -euo pipefail

# test-find-and-local-suite-contracts.sh
# Validates quality and robustness contracts for find-skill and local-suite.

FIND_SKILL=".ai-suite/layer3-registry/core/find-skill.md"
LOCAL_SUITE=".ai-suite/layer3-registry/core/local-suite.md"

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

echo "=== [SDET Contract Gate] Validating find-skill & local-suite Contracts ==="

# 1. find-skill.md quality & parallel search
if grep -qiE "(parallel tool calls|parallel.*search)" "$FIND_SKILL" && \
   grep -qiE "(validate|frontmatter)" "$FIND_SKILL"; then
  pass "find-skill.md specifies parallel searching and frontmatter validation"
else
  fail "find-skill.md missing parallel searching or frontmatter validation instruction"
fi

# 2. local-suite.md post-collection validation
if grep -qiE "(validate-suite|validation)" "$LOCAL_SUITE" && \
   grep -qiE "(deterministic|clean)" "$LOCAL_SUITE"; then
  pass "local-suite.md specifies validation and deterministic cleanup after evolution collection"
else
  fail "local-suite.md missing validation or deterministic cleanup after evolution collection"
fi

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0

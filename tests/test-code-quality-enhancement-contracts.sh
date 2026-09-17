#!/usr/bin/env bash
set -euo pipefail

# test-code-quality-enhancement-contracts.sh
# Validates enhanced code quality, resource lifecycle, language robustness, and anti-hardcoding directives.

CODE_QUALITY_FILE=".ai-suite/layer3-registry/directives/code-quality.md"
AGENT_DIRECTIVES_FILE=".ai-suite/layer3-registry/directives/agent-directives.md"

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

echo "=== [SDET Contract Gate] Validating Enhanced Code Quality & Directives ==="

# 1. Resource Lifecycle Standards in code-quality.md
if grep -qiE "resource (lifecycle|management)|leak prevention" "$CODE_QUALITY_FILE" && \
   grep -qiE "defer" "$CODE_QUALITY_FILE" && \
   grep -qiE "context manager|finally" "$CODE_QUALITY_FILE" && \
   grep -qiE "RAII" "$CODE_QUALITY_FILE" && \
   grep -qiE "trap" "$CODE_QUALITY_FILE"; then
  pass "code-quality.md defines deterministic resource lifecycle and leak prevention across languages"
else
  fail "code-quality.md missing deterministic resource lifecycle standards (defer/context manager/RAII/trap)"
fi

# 2. Language-Specific Robustness in code-quality.md
if grep -qiE "bare except" "$CODE_QUALITY_FILE" && \
   grep -qiE "(type hints|type annotations)" "$CODE_QUALITY_FILE" && \
   grep -qiE "set -euo pipefail|pipefail" "$CODE_QUALITY_FILE" && \
   grep -qiE "(quoted variable|quote.*variable)" "$CODE_QUALITY_FILE"; then
  pass "code-quality.md enforces Python and Shell language-specific robustness"
else
  fail "code-quality.md missing Python/Shell robustness rules"
fi

if grep -qiE "error wrapping|fmt.Errorf" "$CODE_QUALITY_FILE" && \
   grep -qiE "bounds check" "$CODE_QUALITY_FILE"; then
  pass "code-quality.md enforces Go and C/C++ error handling and buffer safety"
else
  fail "code-quality.md missing Go error wrapping or C/C++ bounds checking"
fi

# 3. Anti-Hardcoding in agent-directives.md
if grep -qiE "(dynamically computed|compute.*dynamically)" "$AGENT_DIRECTIVES_FILE" && \
   grep -qiE "(corpus size|static.*count|hardcode.*count)" "$AGENT_DIRECTIVES_FILE"; then
  pass "agent-directives.md mandates dynamic test assertions and forbids hardcoded corpus counts"
else
  fail "agent-directives.md missing dynamic test assertion and anti-hardcoding rules"
fi

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0

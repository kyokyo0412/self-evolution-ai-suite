#!/usr/bin/env bash
set -euo pipefail

# test-prompt-compiler-code-quality-contracts.sh
# Validates that prompt-compiler and prompt-request-brief mandate
# deterministic resource lifecycles, language robustness, and dynamic test assertions.

PROMPT_COMPILER=".ai-suite/layer2-cognitive/meta-compiler/prompt-compiler.md"
PROMPT_BRIEF=".ai-suite/layer2-cognitive/templates/prompt-request-brief.md"

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

echo "=== [SDET Contract Gate] Validating Prompt Compiler & Template Quality Contracts ==="

# 1. prompt-compiler.md mandates deterministic resource lifecycles and language robustness in generated prompts
if grep -qiE "resource (lifecycle|cleanup)|defer" "$PROMPT_COMPILER" && \
   grep -qiE "bare except|quoted shell" "$PROMPT_COMPILER" && \
   grep -qiE "(dynamically computed|anti-hardcoding)" "$PROMPT_COMPILER"; then
  pass "prompt-compiler.md embeds resource lifecycles, language robustness, and anti-hardcoding in prompt generation"
else
  fail "prompt-compiler.md missing resource lifecycles, language robustness, or anti-hardcoding instructions"
fi

# 2. prompt-request-brief.md provides guidance for resource lifecycles and anti-hardcoding
if grep -qiE "resource lifecycle" "$PROMPT_BRIEF" && \
   grep -qiE "dynamically" "$PROMPT_BRIEF"; then
  pass "prompt-request-brief.md includes resource lifecycles and dynamic assertion constraints"
else
  fail "prompt-request-brief.md missing resource lifecycle or dynamic assertion guidance"
fi

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0

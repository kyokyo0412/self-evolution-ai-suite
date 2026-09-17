#!/usr/bin/env bash
set -euo pipefail

# test-cognitive-templates-structural-contracts.sh
# Validates structural integrity of Layer 2 Cognitive templates and meta-compiler.

TEMPLATES_DIR=".ai-suite/layer2-cognitive/templates"
COMPILER_FILE=".ai-suite/layer2-cognitive/meta-compiler/prompt-compiler.md"

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

echo "=== [SDET Contract Gate] Validating Cognitive Templates Structural Rigor ==="

# 1. Template structural checks
for t in "$TEMPLATES_DIR"/*.md; do
  [[ -f "$t" ]] || continue
  base=$(basename "$t")

  if grep -q '^# Template:' "$t"; then
    pass "$base: Top-level '# Template:' header present"
  else
    fail "$base: Missing '# Template:' header"
  fi

  if grep -q '\*\*Purpose:\*\*' "$t"; then
    pass "$base: Purpose statement present"
  else
    fail "$base: Missing Purpose statement"
  fi

  if grep -q '\.cursor-suite' "$t"; then
    fail "$base: Contains deprecated '.cursor-suite' path reference"
  else
    pass "$base: Clean of deprecated '.cursor-suite' paths"
  fi
done

# 2. Meta-compiler prompt-compiler.md structural checks
if [[ -f "$COMPILER_FILE" ]]; then
  if grep -q '^name: prompt-compiler' "$COMPILER_FILE"; then
    pass "prompt-compiler.md: Frontmatter name present"
  else
    fail "prompt-compiler.md: Missing frontmatter name"
  fi

  if grep -qiE '^##+ Negative Constraints' "$COMPILER_FILE" && grep -qE '^\- \[[xX]\]' "$COMPILER_FILE"; then
    pass "prompt-compiler.md: Negative Constraints with [X] present"
  else
    fail "prompt-compiler.md: Missing Negative Constraints with [X]"
  fi

  if grep -q '\.cursor-suite' "$COMPILER_FILE"; then
    fail "prompt-compiler.md: Contains deprecated '.cursor-suite' path reference"
  else
    pass "prompt-compiler.md: Clean of deprecated '.cursor-suite' paths"
  fi
fi

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0

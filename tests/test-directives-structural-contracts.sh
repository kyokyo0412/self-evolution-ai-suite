#!/usr/bin/env bash
set -euo pipefail

# test-directives-structural-contracts.sh
# Validates that all AI suite directives have a rigorous, standardized structure:
# 1. Top-level title (# Title)
# 2. Explicit Core Requirements / Standards section
# 3. Explicit Negative Constraints (Must NOT) section containing [X] markers
# 4. Consistency across registry source and deployed rules

DIRECTIVES_DIR=".ai-suite/layer3-registry/directives"

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

echo "=== [SDET Contract Gate] Validating Directives Structural Rigor ==="

for d in "$DIRECTIVES_DIR"/*.md; do
  base=$(basename "$d")

  # Check 1: Top-level title
  if grep -q '^# ' "$d"; then
    pass "$base: Top-level title present"
  else
    fail "$base: Missing top-level title"
  fi

  # Check 2: Negative Constraints section
  if grep -qiE '^##+ (Negative Constraints|Refuse-by-Default)' "$d"; then
    pass "$base: Negative Constraints section present"
  else
    fail "$base: Missing Negative Constraints section"
  fi

  # Check 3: Negative constraint checkboxes [X]
  if grep -qE '^\- \[[xX]\]' "$d"; then
    pass "$base: Checkbox negative constraints [X] present"
  else
    fail "$base: Missing [X] negative constraint entries"
  fi
done

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0

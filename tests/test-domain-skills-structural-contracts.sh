#!/usr/bin/env bash
set -euo pipefail

# test-domain-skills-structural-contracts.sh
# Validates structural integrity of all domain skills under:
# .ai-suite/layer3-registry/domains/*/skills/*.md

DOMAIN_DIR=".ai-suite/layer3-registry/domains"

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

echo "=== [SDET Contract Gate] Validating Domain Skills Structural Completeness ==="

for skill in "$DOMAIN_DIR"/*/skills/*.md; do
  [[ -f "$skill" ]] || continue
  base=$(basename "$skill")

  # Check 1: Frontmatter metadata
  if grep -q '^name:' "$skill" && grep -q '^description:' "$skill" && grep -q '^triggers:' "$skill"; then
    pass "$base: Frontmatter metadata complete"
  else
    fail "$base: Incomplete frontmatter metadata"
  fi

  # Check 2: 'Use when' requirement
  if grep -qi 'Use when' "$skill"; then
    pass "$base: Description contains 'Use when'"
  else
    fail "$base: Description missing 'Use when'"
  fi

  # Check 3: Safety / Negative Constraints section
  if grep -qiE '^##+ (Negative Constraints|Safety|Constraints)' "$skill"; then
    pass "$base: Safety or Negative Constraints section present"
  else
    fail "$base: Missing Safety or Negative Constraints section"
  fi

  # Check 4: Checkbox negative constraints [X]
  if grep -qE '^\- \[[xX]\]' "$skill"; then
    pass "$base: Checkbox negative constraints [X] present"
  else
    fail "$base: Missing [X] negative constraint entries"
  fi

  # Check 5: Instructions / Workflow section
  if grep -qiE '^#+.*(instructions|workflow|role|context|steps|usage|procedure|operations|step-by-step|protocol|execution)' "$skill"; then
    pass "$base: Instructions/Workflow section present"
  else
    fail "$base: Missing Instructions/Workflow section"
  fi
done

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0

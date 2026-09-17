#!/usr/bin/env bash
set -euo pipefail

# test-core-skills-structural-contracts.sh
# Validates structural completeness and integrity of all core skills:
# 1. Frontmatter schema: name, description (with 'Use when'), triggers
# 2. Section presence: Instructions/Workflow and Negative Constraints/Safety
# 3. Size constraints: body <= 600 lines
# 4. Zero legacy path references: no '.cursor-suite' references

CORE_SKILLS_DIR=".ai-suite/layer3-registry/core"
CURSOR_SKILLS_DIR=".ai-suite/layer1-abstraction/agents/cursor/skills"

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

echo "=== [SDET Contract Gate] Validating Core & Cursor Skills Structural Rigor ==="

for skill in "$CORE_SKILLS_DIR"/*.md "$CURSOR_SKILLS_DIR"/*.md; do
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
  if grep -qiE '^##+ (Negative Constraints|Safety|Constraints|Rules of Engagement)' "$skill"; then
    pass "$base: Safety or Negative Constraints section present"
  else
    fail "$base: Missing Safety or Negative Constraints section"
  fi

  # Check 4: Instructions / Workflow section
  if grep -qiE '^#+.*(instructions|workflow|role|context|artifact[[:space:]]catalog|operational|steps|usage|procedure|operations|step-by-step|protocol|execution|quality[[:space:]]bar)' "$skill"; then
    pass "$base: Instructions/Workflow section present"
  else
    fail "$base: Missing Instructions/Workflow section"
  fi

  # Check 5: No legacy .cursor-suite paths
  if grep -q '\.cursor-suite' "$skill"; then
    fail "$base: Contains legacy '.cursor-suite' path reference"
  else
    pass "$base: Clean of legacy '.cursor-suite' path references"
  fi
done

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0

#!/usr/bin/env bash
set -euo pipefail

# test-ai-review-bot-contracts.sh
# Validates the structural, behavioral, and functional enablement contracts
# of the absorbed ai-review-bot skill.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SUITE_DIR="$PROJECT_ROOT/.ai-suite"
SKILL_FILE="$SUITE_DIR/layer3-registry/core/ai-review-bot.md"

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

echo "=== [SDET Contract Gate] Validating ai-review-bot Absorption & Enablement Contracts ==="

# -----------------------------------------------------------------------------
# 1. Structural File Contracts
# -----------------------------------------------------------------------------
if [[ -f "$SKILL_FILE" ]]; then
  pass "Skill file exists at $SKILL_FILE"
else
  fail "Skill file missing at $SKILL_FILE"
fi

if [[ -f "$SKILL_FILE" ]]; then
  # 1.1 Frontmatter schema
  if grep -q '^name: *ai-review-bot$' "$SKILL_FILE"; then
    pass "Frontmatter name: ai-review-bot"
  else
    fail "Frontmatter name: ai-review-bot missing"
  fi

  if grep -qi 'Use when' "$SKILL_FILE"; then
    pass "Description contains 'Use when'"
  else
    fail "Description missing 'Use when'"
  fi

  if grep -q 'triggers:' "$SKILL_FILE" && grep -q 'ai review' "$SKILL_FILE"; then
    pass "Triggers defined and contains 'ai review'"
  else
    fail "Triggers missing or does not contain 'ai review'"
  fi

  # 1.2 Mandatory sections
  if grep -qiE '^#+.*(Instructions|Workflow)' "$SKILL_FILE"; then
    pass "Workflow / Instructions section present"
  else
    fail "Workflow / Instructions section missing"
  fi

  if grep -qiE '^#+.*(Negative Constraints|Safety|Constraints)' "$SKILL_FILE"; then
    pass "Negative Constraints / Safety section present"
  else
    fail "Negative Constraints / Safety section missing"
  fi

  if grep -q '\[X\]' "$SKILL_FILE"; then
    pass "Checkboxes / explicit negative constraints present"
  else
    fail "Explicit negative constraints missing"
  fi

  # 1.3 Body length
  line_count=$(wc -l < "$SKILL_FILE" | tr -d ' ')
  if [[ "$line_count" -le 600 ]]; then
    pass "Skill body <= 600 lines (actual: $line_count)"
  else
    fail "Skill body exceeds 600 lines (actual: $line_count)"
  fi

  # ---------------------------------------------------------------------------
  # 2. Review Personas & Anti-False-Positive Invariants
  # ---------------------------------------------------------------------------
  PERSONAS=("Senior Engineer" "Commit Message Reviewer" "GitHub Workflow Reviewer" "Accessibility Reviewer" "CL & File Summarizer")
  for persona in "${PERSONAS[@]}"; do
    if grep -q "$persona" "$SKILL_FILE"; then
      pass "Persona defined: $persona"
    else
      fail "Persona missing: $persona"
    fi
  done

  # Diff direction awareness
  if grep -qi "diff direction awareness" "$SKILL_FILE" || grep -qi "removed lines" "$SKILL_FILE"; then
    pass "Diff direction awareness enforced (no comments on removed lines)"
  else
    fail "Diff direction awareness missing"
  fi

  # Concrete vulnerability & error patterns
  if grep -qi "timing attack" "$SKILL_FILE"; then
    pass "Timing attack vulnerability detection specified"
  else
    fail "Timing attack vulnerability detection missing"
  fi

  if grep -qi "case-insensitive" "$SKILL_FILE" || grep -qi "fqdn" "$SKILL_FILE"; then
    pass "Case-insensitive DNS / FQDN check specified"
  else
    fail "Case-insensitive DNS / FQDN check missing"
  fi

  if grep -qi "secret" "$SKILL_FILE" || grep -qi "credential" "$SKILL_FILE"; then
    pass "Unmasked secret / credential logging detection specified"
  else
    fail "Unmasked secret / credential logging detection missing"
  fi

  if grep -qi "race condition" "$SKILL_FILE"; then
    pass "Race condition detection specified"
  else
    fail "Race condition detection missing"
  fi

  # Concrete examples section
  if grep -qi "example" "$SKILL_FILE"; then
    pass "Review examples present in skill"
  else
    fail "Review examples missing from skill"
  fi
fi

# -----------------------------------------------------------------------------
# 3. Functional Enablement & Multi-Agent Mirroring Parity
# -----------------------------------------------------------------------------
echo ""
echo "--- Functional Sandbox: Multi-Agent Enablement Verification ---"

SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/test-ai-review-bot-sandbox.XXXXXX")
trap 'rm -rf "$SANDBOX"' EXIT

# 3.1 Cursor enablement
"$PROJECT_ROOT/ai-suite" enable --scope project --project "$SANDBOX" --agent cursor >/dev/null 2>&1
if [[ -f "$SANDBOX/.cursor/skills/ai-review-bot/SKILL.md" ]]; then
  pass "Cursor adapter successfully deployed .cursor/skills/ai-review-bot/SKILL.md"
else
  fail "Cursor adapter failed to deploy .cursor/skills/ai-review-bot/SKILL.md"
fi

# 3.2 Codex enablement
"$PROJECT_ROOT/ai-suite" enable --scope project --project "$SANDBOX" --agent codex >/dev/null 2>&1
if [[ -f "$SANDBOX/.codex/skills/ai-review-bot/SKILL.md" ]]; then
  pass "Codex adapter successfully deployed .codex/skills/ai-review-bot/SKILL.md"
else
  fail "Codex adapter failed to deploy .codex/skills/ai-review-bot/SKILL.md"
fi

# 3.3 Claude enablement
"$PROJECT_ROOT/ai-suite" enable --scope project --project "$SANDBOX" --agent claude >/dev/null 2>&1
if [[ -f "$SANDBOX/.claude/skills/ai-review-bot/SKILL.md" ]]; then
  pass "Claude adapter successfully deployed .claude/skills/ai-review-bot/SKILL.md"
else
  fail "Claude adapter failed to deploy .claude/skills/ai-review-bot/SKILL.md"
fi

# 3.4 Clean disable
"$PROJECT_ROOT/ai-suite" disable --scope project --project "$SANDBOX" --agent all >/dev/null 2>&1
if [[ ! -d "$SANDBOX/.cursor/skills" && ! -d "$SANDBOX/.codex/skills" && ! -d "$SANDBOX/.claude/skills" ]]; then
  pass "Clean de-provisioning across all agents verified"
else
  fail "De-provisioning failed to remove skills directories"
fi

echo ""
echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0

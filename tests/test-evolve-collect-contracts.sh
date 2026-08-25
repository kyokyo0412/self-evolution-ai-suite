#!/usr/bin/env bash
# test-evolve-collect-contracts.sh - Phase 2 contract tests for
# .ai-suite/layer4-evolutionary/merging/evolve-collect.md
#
# Verifies the interface contracts in evolve-collect-contracts.md.
# Run from the workspace root:
#   bash tests/test-evolve-collect-contracts.sh

set -uo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$SUITE_ROOT/.ai-suite/layer4-evolutionary/merging/evolve-collect.md"
VALIDATOR="$SUITE_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh"

# -- helpers -------------------------------------------------------------------
PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

skill_contains() {
  local label="$1" needle="$2"
  if grep -qF -- "$needle" "$SKILL" 2>/dev/null; then
    pass "$label"
  else
    fail "$label - skill does not contain: $needle"
  fi
}
skill_contains_pattern() {
  local label="$1" pattern="$2"
  if grep -qE -- "$pattern" "$SKILL" 2>/dev/null; then
    pass "$label"
  else
    fail "$label - skill does not match pattern: $pattern"
  fi
}

echo "=== Phase 2 Contract Tests: evolve-collect.md ==="

# -- S1: File exists -----------------------------------------------------------
if [[ -f "$SKILL" ]]; then
  pass "S1: skill file exists at $SKILL"
else
  fail "S1: skill file not found at $SKILL"
fi

# -- S2: name field = evolve-collect ------------------------------------------
skill_contains "S2: frontmatter name: evolve-collect" "name: evolve-collect"

# -- S3: description contains 'Use when' --------------------------------------
skill_contains "S3: description contains 'Use when'" "Use when"

# -- S4: description mentions collect + remote + evolution/reflection ----------
skill_contains_pattern "S4a: description mentions 'collect'" "[Cc]ollect"
skill_contains_pattern "S4b: description mentions 'remote'" "[Rr]emote"
skill_contains_pattern "S4c: description mentions 'evolution' or 'reflection'" "(evolution|reflection|Evolution|Reflection)"

# -- S5: trigger phrases -------------------------------------------------------
skill_contains "S5a: trigger 'collect evolution'" "collect evolution"
skill_contains "S5b: trigger 'sync reflection'" "sync reflection"
skill_contains "S5c: trigger 'pull suite changes'" "pull suite changes"
skill_contains "S5d: trigger 'evolve collect'" "evolve collect"
skill_contains "S5e: trigger 'collect remote'" "collect remote"
skill_contains "S5f: trigger 'push evolution'" "push evolution"

# -- S6: validate-suite.sh passes ---------------------------------------------
if [[ -x "$VALIDATOR" ]]; then
  validator_out=$("$VALIDATOR" "$SKILL" 2>&1)
  validator_exit=$?
  if [[ "$validator_exit" -eq 0 ]]; then
    pass "S6: validate-suite.sh passes (0 errors)"
  else
    fail "S6: validate-suite.sh FAILED:"
    echo "$validator_out" | while IFS= read -r line; do printf '    %s\n' "$line"; done >&2
  fi
else
  fail "S6: validator not found at $VALIDATOR"
fi

# -- B1: Contains a workflow/instructions section ------------------------------
skill_contains_pattern "B1: has a Workflow or Instructions section" "^#+ *(Workflow|Instructions|Usage|Steps)"

# -- B3: References ai-suite evolve in the body -------------------------------
skill_contains "B3: references ai-suite evolve" "ai-suite evolve"

# -- B4: Safety - no auto-commit constraint ------------------------------------
skill_contains_pattern "B4a: mentions 'auto-commit' or 'auto commit'" "auto.commit"
skill_contains_pattern "B4b: mentions '--host is required' or 'ask for host'" "(ask|--host|HOST)"

# -- B5: Negative constraints section -----------------------------------------
skill_contains_pattern "B5: has Negative Constraints or Must NOT section" "^#+ *(Negative|Must NOT|Constraints|NEVER)"

# -- BC3: Dry-run keyword coverage --------------------------------------------
skill_contains_pattern "BC3: mentions dry-run keywords" "(preview|dry.run|dry_run)"

# -- BC4: Push keyword coverage -----------------------------------------------
skill_contains_pattern "BC4: mentions push sub-command" "push"

# -- BC6: Instructs AI to present evolution report ----------------------------
skill_contains_pattern "BC6: instructs to present report or diff" "(report|diff|evolution report)"

# -- V3: body <= 600 lines (validate-suite enforces, but also spot-check) ------
if [[ -f "$SKILL" ]]; then
  line_count=$(wc -l < "$SKILL" | tr -d ' ')
  if [[ "$line_count" -le 600 ]]; then
    pass "V3: skill body <= 600 lines (actual: $line_count)"
  else
    fail "V3: skill is $line_count lines - exceeds 600-line limit"
  fi
fi

# -- Summary -------------------------------------------------------------------
printf '\n'
total=$((PASS+FAIL))
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[contract-test] %d/%d passed\033[0m\n' "$PASS" "$total"
  exit 0
else
  printf '\033[31m[contract-test] %d passed, %d FAILED / %d total\033[0m\n' \
    "$PASS" "$FAIL" "$total" >&2
  exit 1
fi

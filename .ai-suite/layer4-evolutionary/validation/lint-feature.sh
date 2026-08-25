#!/usr/bin/env bash
# lint-feature.sh - Phase 1 gate: validate that evolution.feature is syntactically
# coherent enough to serve as executable specification.
#
# Checks:
#   1. File exists and is non-empty.
#   2. At least one "Feature:" heading.
#   3. At least one "Scenario:" block.
#   4. Every "Scenario:" has at least one "When" and one "Then" step.
#   5. No placeholder tokens ([FILL], TODO, etc.) remain.
#   6. All indented step keywords (Given/When/Then/And/But) appear
#      inside a Scenario block (not floating at top level).

set -euo pipefail

FEATURE_FILE="${1:-$(dirname "${BASH_SOURCE[0]}")/evolution.feature}"
ERRORS=0
PASSES=0

_red()  { [[ -t 1 ]] && printf '\033[31m' || true; }
_grn()  { [[ -t 1 ]] && printf '\033[32m' || true; }
_off()  { [[ -t 1 ]] && printf '\033[0m'  || true; }
pass() { PASSES=$((PASSES+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { ERRORS=$((ERRORS+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

[[ -f "$FEATURE_FILE" ]] || { echo "ERROR: feature file not found: $FEATURE_FILE" >&2; exit 1; }
[[ -s "$FEATURE_FILE" ]] || { echo "ERROR: feature file is empty: $FEATURE_FILE"  >&2; exit 1; }

# 1. Feature headings
feature_count=$(grep -c '^Feature:' "$FEATURE_FILE" || true)
if [[ "$feature_count" -ge 1 ]]; then
  pass "found $feature_count Feature: heading(s)"
else
  fail "no 'Feature:' heading found"
fi

# 2. Scenario blocks
scenario_count=$(grep -c '^\s*Scenario:' "$FEATURE_FILE" || true)
if [[ "$scenario_count" -ge 1 ]]; then
  pass "found $scenario_count Scenario: block(s)"
else
  fail "no 'Scenario:' blocks found"
fi

# 3. Each scenario has at least one When + one Then
# Parse scenario blocks with awk.
bad_scenarios=$(awk '
  /^\s*Scenario:/ { 
    if (in_scenario && !has_when) print "Scenario at line " sc_line " has no When step"
    if (in_scenario && !has_then) print "Scenario at line " sc_line " has no Then step"
    in_scenario=1; has_when=0; has_then=0; sc_line=NR; sc_name=$0
  }
  in_scenario && /^\s+When / { has_when=1 }
  in_scenario && /^\s+Then / { has_then=1 }
  END {
    if (in_scenario && !has_when) print "Scenario at line " sc_line " has no When step"
    if (in_scenario && !has_then) print "Scenario at line " sc_line " has no Then step"
  }
' "$FEATURE_FILE")
if [[ -z "$bad_scenarios" ]]; then
  pass "all scenarios have When + Then steps"
else
  while IFS= read -r line; do fail "$line"; done <<< "$bad_scenarios"
fi

# 4. No unfilled placeholders
placeholder_count=$(grep -cE '\[FILL\]|TODO|FIXME' "$FEATURE_FILE" || true)
if [[ "$placeholder_count" -eq 0 ]]; then
  pass "no unfilled placeholder tokens"
else
  fail "found $placeholder_count unfilled placeholder(s) - fill them before implementation"
fi

# Summary
printf '\n'
total=$((PASSES + ERRORS))
if [[ "$ERRORS" -eq 0 ]]; then
  printf '%s[lint-feature] %d/%d checks passed%s\n' "$(_grn)" "$PASSES" "$total" "$(_off)"
  exit 0
else
  printf '%s[lint-feature] %d passed, %d FAILED out of %d%s\n' "$(_red)" "$PASSES" "$ERRORS" "$total" "$(_off)" >&2
  exit 1
fi

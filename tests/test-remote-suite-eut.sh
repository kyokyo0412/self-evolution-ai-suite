#!/usr/bin/env bash
# test-remote-suite-eut.sh -- EUT for remote-suite.md skill.
# Verifies: intent mapping table, command examples, safety constraints,
# multiple-host coverage, missing-host rule, and cross-skill consistency.
#
# Run from workspace root: bash tests/test-remote-suite-eut.sh

set -uo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$SUITE_ROOT/.ai-suite/layer4-evolutionary/merging/remote-suite.md"
EVOLVE_COLLECT="$SUITE_ROOT/.ai-suite/layer4-evolutionary/merging/evolve-collect.md"

PASS=0; FAIL=0; TOTAL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); TOTAL=$((TOTAL+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); TOTAL=$((TOTAL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

has()  { grep -qF  -- "$2" "$SKILL" 2>/dev/null; }
hasp() { grep -qE  -- "$2" "$SKILL" 2>/dev/null; }

echo "=== EUT: remote-suite.md ==="
echo ""

# -- E1: All five operations documented ---------------------------------------
echo "--- E1: five operations ---"
for op in install collect push status remove; do
  if hasp "E1: $op operation covered" \
     "^### [0-9]*\. .*($(printf '%s' "$op" | sed 's/./[&]/g'))"; then
    pass "E1: operation '$op' has a ## section header"
  elif grep -qiF "$op" "$SKILL" 2>/dev/null; then
    pass "E1: operation '$op' mentioned in skill"
  else
    fail "E1: operation '$op' not found in skill"
  fi
done

# -- E2: All five scripts referenced correctly ---------------------------------
echo ""
echo "--- E2: script references ---"
for cmd in "ai-suite enable --scope remote" \
           "ai-suite evolve collect" \
           "ai-suite evolve push" \
           "ai-suite disable --scope remote"; do
  if has "E2" "$cmd"; then pass "E2: '$cmd' in skill"
  else fail "E2: '$cmd' missing from skill"; fi
done

# -- E3: Agent flag examples ---------------------------------------------------
echo ""
echo "--- E3: agent flag examples ---"
for agent in cursor claude all; do
  if has "E3" "--agent $agent"; then pass "E3: --agent $agent covered"
  else fail "E3: --agent $agent missing"; fi
done


# -- E5: Multiple --host covered -----------------------------------------------
echo ""
echo "--- E5: multiple hosts ---"
host_count=$(grep -c -- "--host" "$SKILL" 2>/dev/null || echo 0)
if [[ "$host_count" -ge 4 ]]; then
  pass "E5: --host appears $host_count times (covers multiple-host scenarios)"
else
  fail "E5: --host only appears $host_count times (expected >=4)"
fi

# -- E6: Missing-host question phrase -----------------------------------------
echo ""
echo "--- E6: missing-host rule ---"
if hasp "E6a" "(ask|Which remote host|user@hostname)"; then
  pass "E6a: missing-host question phrase present"
else fail "E6a: missing-host question phrase not found"; fi

if grep -qF "Do NOT proceed" "$SKILL" 2>/dev/null || \
   grep -qF "do not proceed" "$SKILL" 2>/dev/null || \
   grep -qiF "ask before" "$SKILL" 2>/dev/null || \
   grep -qiF "ask if none" "$SKILL" 2>/dev/null; then
  pass "E6b: skill says to ask before proceeding without host"
else fail "E6b: skill does not say to block on missing host"; fi

# -- E7: Production safety warning ---------------------------------------------
echo ""
echo "--- E7: production safety ---"
for prod_kw in prod; do
  if grep -qiF "$prod_kw" "$SKILL" 2>/dev/null; then
    pass "E7: production keyword '$prod_kw' in safety section"
  else fail "E7: '$prod_kw' not mentioned in skill"; fi
done

# -- E8: No auto-commit rule ---------------------------------------------------
echo ""
echo "--- E8: no auto-commit ---"
if hasp "E8a" "(auto.commit|never.*commit|Do not auto-commit|do not.*commit)"; then
  pass "E8a: auto-commit prohibition present"
else fail "E8a: no auto-commit prohibition found"; fi

if grep -qiF "git commands" "$SKILL" 2>/dev/null || \
   grep -qiF "copy-paste" "$SKILL" 2>/dev/null || \
   grep -qiF "copy.*paste" "$SKILL" 2>/dev/null; then
  pass "E8b: copy-paste git commands instruction present"
else fail "E8b: no copy-paste git commands instruction"; fi

# -- E9: dry-run handling ------------------------------------------------------
echo ""
echo "--- E9: dry-run ---"
if hasp "E9" "(dry.run|--dry-run|preview)"; then
  pass "E9: dry-run / preview mentioned in skill"
else fail "E9: dry-run not mentioned"; fi

# -- E10: Script preflight check ----------------------------------------------
echo ""
echo "--- E10: preflight ---"
if hasp "E10" "(Script check|preflight|missing.*script|script.*missing|not found.*script|check.*exist)"; then
  pass "E10: script preflight check documented"
else fail "E10: script preflight check not found"; fi

# -- E11: Examples section has all five operations -----------------------------
echo ""
echo "--- E11: examples coverage ---"
for op_kw in "install" "collect" "push" "status" "remove"; do
  example_line=$(grep -ni "## Examples" "$SKILL" 2>/dev/null | head -1 | cut -d: -f1)
  if [[ -z "$example_line" ]]; then
    fail "E11: no '## Examples' section found"; break
  fi
  if awk "NR>$example_line" "$SKILL" | grep -qiF "$op_kw"; then
    pass "E11: '$op_kw' example present after '## Examples'"
  else
    fail "E11: '$op_kw' example missing from '## Examples' section"
  fi
done

# -- E12: Negative constraints section ----------------------------------------
echo ""
echo "--- E12: negative constraints ---"
for nc in "auto-commit" "prod" "host" "dry-run"; do
  neg_line=$(grep -ni "Negative Constraints\|Must NOT\|NEVER" "$SKILL" 2>/dev/null | head -1 | cut -d: -f1)
  if [[ -z "$neg_line" ]]; then
    fail "E12: no Negative Constraints section"; break
  fi
  if awk "NR>$neg_line" "$SKILL" | grep -qiF "$nc"; then
    pass "E12: negative constraint for '$nc' present"
  else
    fail "E12: '$nc' not in negative constraints"
  fi
done

# -- E13: Relationship to evolve-collect.md (co-existence) --------------------
echo ""
echo "--- E13: co-existence with evolve-collect ---"
if [[ -f "$EVOLVE_COLLECT" ]]; then
  pass "E13a: evolve-collect.md still exists (not replaced)"
else fail "E13a: evolve-collect.md was accidentally deleted"; fi

# Both skills should reference ai-suite evolve
if grep -qF "ai-suite evolve" "$SKILL" 2>/dev/null && \
   grep -qF "ai-suite evolve" "$EVOLVE_COLLECT" 2>/dev/null; then
  pass "E13b: both skills reference ai-suite evolve (consistent commands)"
else fail "E13b: command inconsistency between remote-suite and evolve-collect"; fi

# -- E14: validate-suite.sh final gate ----------------------------------------
echo ""
echo "--- E14: full validator gate ---"
val_out=$(bash "$SUITE_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" 2>&1)
val_exit=$?
if [[ "$val_exit" -eq 0 ]]; then pass "E14a: validate-suite.sh passes on all tiers"
else fail "E14a: validate-suite.sh failed: $val_out"; fi

pass_count=$(printf '%s' "$val_out" | grep -c "^  PASS" || true)
if [[ "$pass_count" -ge 27 ]]; then pass "E14b: >=27 checks"
else fail "E14b: expected >=27 checks, got $pass_count"; fi

# -- Summary -------------------------------------------------------------------
printf '\n'
if [[ "$FAIL" -eq 0 ]]; then
  printf '%s[EUT] %d/%d passed -- PHASE 4 GATE: PASSED%s\n' \
    "$(_grn)" "$PASS" "$TOTAL" "$(_off)"
  exit 0
else
  printf '%s[EUT] %d passed, %d FAILED / %d total%s\n' \
    "$(_red)" "$PASS" "$FAIL" "$TOTAL" "$(_off)" >&2
  exit 1
fi

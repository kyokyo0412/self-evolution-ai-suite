#!/usr/bin/env bash
# test-evolve-collect-eut.sh -- Phase 4 EUT for the evolve-collect skill.
#
# Tests:
#   E1  Trigger phrase coverage -- all 12 frontmatter triggers present
#   E2  Validate-suite gate -- full validator pass
#   E3  Command examples in skill body are syntactically valid bash
#   E4  Safety: no git commit/push commands appear in the skill body instructions
#   E5  All Gherkin scenarios are addressed by the skill
#   E6  Skill correctly references both collect and push sub-commands
#   E7  Skill body references all flag types (--host, --remote-path, --remote-scope, --dry-run)
#   E8  Integration: ai-suite evolve --help mentions collect and push (skill can invoke it)
#   E9  Skill file is stable across two validator runs (idempotency)
#   E10 Trigger table in skill is consistent with frontmatter triggers list

set -uo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$SUITE_ROOT/.ai-suite/layer4-evolutionary/merging/evolve-collect.md"
VALIDATOR="$SUITE_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh"
EVOLVE="$SUITE_ROOT/ai-suite"

PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

skill_has() {
  local label="$1" needle="$2"
  if grep -qF -- "$needle" "$SKILL" 2>/dev/null; then pass "$label"
  else fail "$label -- not found: $needle"; fi
}
skill_has_pat() {
  local label="$1" pat="$2"
  if grep -qE -- "$pat" "$SKILL" 2>/dev/null; then pass "$label"
  else fail "$label -- pattern not matched: $pat"; fi
}

echo "=== Phase 4 EUT: evolve-collect skill ==="
echo ""

# -- E1: All 12 frontmatter trigger phrases present in skill ------------------
echo "--- E1: trigger phrase coverage ---"
triggers=(
  "collect evolution"
  "sync reflection"
  "pull suite changes"
  "evolve collect"
  "collect remote"
  "push evolution"
  "sync remote reflection"
  "gather remote updates"
  "deploy evolution"
  "update remote with suite"
  "collect cursor suite"
  "fetch remote reflection"
)
for t in "${triggers[@]}"; do
  skill_has "E1: trigger '$t'" "$t"
done

# -- E2: Full validate-suite.sh pass ------------------------------------------
echo ""
echo "--- E2: validate-suite gate ---"
if bash "$VALIDATOR" "$SKILL" >/dev/null 2>&1; then
  pass "E2: validate-suite.sh passes on evolve-collect.md"
else
  fail "E2: validate-suite.sh FAILED"
  bash "$VALIDATOR" "$SKILL" 2>&1 | while IFS= read -r line; do printf '    %s\n' "$line"; done >&2
fi

# -- E3: Command examples in skill are syntactically valid bash ---------------
echo ""
echo "--- E3: command examples are valid bash ---"
# Extract all bash code fences from the skill and test each with bash -n
tmpfile=$(mktemp "${TMPDIR:-/tmp}/skill-bash-check.XXXXXX")
in_bash_fence=false
bad_blocks=0
block_num=0
block_buf=""

while IFS= read -r line; do
  if [[ "$line" == '```bash' ]]; then
    in_bash_fence=true
    block_buf=""
    block_num=$((block_num+1))
    continue
  fi
  if [[ "$line" == '```' ]] && $in_bash_fence; then
    in_bash_fence=false
    printf '%s\n' "$block_buf" > "$tmpfile"
    if ! bash -n "$tmpfile" 2>/dev/null; then
      bad_blocks=$((bad_blocks+1))
      fail "E3: bash code block #$block_num has syntax errors"
    fi
    block_buf=""
    continue
  fi
  if $in_bash_fence; then
    block_buf="${block_buf}${line}
"
  fi
done < "$SKILL"
rm -f "$tmpfile"

if [[ "$bad_blocks" -eq 0 ]]; then
  pass "E3: all $block_num bash code block(s) pass bash -n"
fi

# -- E4: Safety -- no bare git commit/push in the prescriptive body -------------
echo ""
echo "--- E4: no auto-commit instructions ---"
# The skill DISCUSSES git commands (to show them to the user) but must not
# instruct the AI to run them without user confirmation.
# Check that "auto-commit" or "never auto-commit" appears (the prohibition).
skill_has_pat "E4a: auto-commit prohibition present" "(never auto-commit|Never auto-commit|do not auto-commit|Do not auto-commit)"

# Check that if "git commit" appears, it is always in a code block (copy-paste)
# not in a directive like "run git commit".
run_commit_count=$(grep -cE '^\s*(Run|Execute|run|execute) git commit' "$SKILL" 2>/dev/null || true)
if [[ "$run_commit_count" -eq 0 ]]; then
  pass "E4b: no 'run git commit' directives (commands shown only as copy-paste)"
else
  fail "E4b: found $run_commit_count 'run/execute git commit' directive(s)"
fi

# -- E5: Gherkin scenario keywords all addressed -------------------------------
echo ""
echo "--- E5: Gherkin scenario coverage ---"
skill_has_pat "E5a: collect from single host covered" "(--host.*USER@HOST|--host.*alice)"
multi_host_count=$(grep -c -- '--host' "$SKILL" 2>/dev/null || true)
if [[ "$multi_host_count" -ge 4 ]]; then
  pass "E5b: multiple --host scenario covered ($multi_host_count occurrences)"
else
  fail "E5b: multiple --host not well covered (only $multi_host_count --host occurrences)"
fi
skill_has_pat "E5c: dry-run scenario covered" "(--dry-run|dry.run)"
skill_has_pat "E5d: --remote-path scenario covered" "--remote-path"
skill_has_pat "E5e: push scenario covered" "ai-suite evolve push"
skill_has_pat "E5f: ask-for-host scenario covered" "(ask|provide.*host|HOST.*format)"

# -- E6: Both sub-commands referenced -----------------------------------------
echo ""
echo "--- E6: collect and push sub-commands ---"
skill_has "E6a: collect sub-command present" "ai-suite evolve collect"
skill_has "E6b: push sub-command present" "ai-suite evolve push"

# -- E7: All four flags referenced --------------------------------------------
echo ""
echo "--- E7: all flags documented ---"
skill_has "E7a: --host flag referenced" "--host"
skill_has "E7b: --remote-path flag referenced" "--remote-path"
skill_has "E7c: --remote-scope flag referenced" "--remote-scope"
skill_has "E7d: --dry-run flag referenced" "--dry-run"

# -- E8: Integration -- ai-suite evolve is present and invocable ---------------
echo ""
echo "--- E8: ai-suite evolve integration ---"
if [[ -x "$EVOLVE" ]]; then
  pass "E8a: ai-suite evolve is executable"
else
  fail "E8a: ai-suite evolve not found or not executable"
fi

evolve_help=$("$EVOLVE" evolve --help 2>&1 || true)
if printf '%s' "$evolve_help" | grep -q "collect"; then
  pass "E8b: ai-suite evolve --help mentions 'collect'"
else
  fail "E8b: ai-suite evolve --help does not mention 'collect'"
fi
if printf '%s' "$evolve_help" | grep -q "push"; then
  pass "E8c: ai-suite evolve --help mentions 'push'"
else
  fail "E8c: ai-suite evolve --help does not mention 'push'"
fi

# -- E9: Idempotency -- validator passes twice consecutively -------------------
echo ""
echo "--- E9: idempotency ---"
if bash "$VALIDATOR" "$SKILL" >/dev/null 2>&1 && \
   bash "$VALIDATOR" "$SKILL" >/dev/null 2>&1; then
  pass "E9: validator passes on two consecutive runs (idempotent)"
else
  fail "E9: validator result differs between runs"
fi

# -- E10: Trigger table in body consistent with frontmatter triggers -----------
echo ""
echo "--- E10: frontmatter vs body trigger consistency ---"
# Every frontmatter trigger should appear somewhere in the body too
# (either in the trigger recognition table or in examples).
frontmatter_triggers=()
in_triggers=false
while IFS= read -r line; do
  if [[ "$line" == "triggers:" ]]; then in_triggers=true; continue; fi
  if $in_triggers; then
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+(.*) ]]; then
      frontmatter_triggers+=("${BASH_REMATCH[1]}")
    else
      in_triggers=false
    fi
  fi
done < "$SKILL"

e10_fail=0
for t in "${frontmatter_triggers[@]}"; do
  if ! grep -qF -- "$t" "$SKILL" 2>/dev/null; then
    fail "E10: trigger '$t' in frontmatter but not found in skill body"
    e10_fail=$((e10_fail+1))
  fi
done
if [[ "$e10_fail" -eq 0 ]]; then
  pass "E10: all ${#frontmatter_triggers[@]} frontmatter triggers appear in skill body"
fi

# -- Summary -------------------------------------------------------------------
printf '\n'
total=$((PASS+FAIL))
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[EUT] %d/%d passed -- PHASE 4 GATE: PASSED\033[0m\n' "$PASS" "$total"
  exit 0
else
  printf '\033[31m[EUT] %d passed, %d FAILED / %d total\033[0m\n' "$PASS" "$FAIL" "$total" >&2
  exit 1
fi

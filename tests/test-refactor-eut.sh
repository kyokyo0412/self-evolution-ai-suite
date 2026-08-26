#!/usr/bin/env bash
# test-refactor-eut.sh -- End-to-end sandbox tests for the .ai-suite/ refactoring.
#
# Tests the full enable/disable lifecycle for both Cursor and Claude agents,
# domain pack loading, idempotency, and backward compatibility.
#
# Run from workspace root: bash tests/test-refactor-eut.sh
# All tests run in isolated sandbox directories; no host files are modified.

# shellcheck disable=SC2030,SC2031  # intentional HOME override in subshells

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/.." && pwd)"
AI_SUITE="$WORKSPACE/.ai-suite"
ENABLE="$WORKSPACE/ai-suite"
DISABLE="$WORKSPACE/ai-suite"

PASS=0; FAIL=0; TOTAL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }

pass() { PASS=$((PASS+1)); TOTAL=$((TOTAL+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); TOTAL=$((TOTAL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

# Create a fresh sandbox for each test group
make_sandbox() {
  mktemp -d "${TMPDIR:-/tmp}/eut-refactor.XXXXXX"
}

# shellcheck disable=SC2329  # called via trap
cleanup() {
  [[ -n "${SANDBOX:-}" ]] && rm -rf "$SANDBOX"
  [[ -n "${SANDBOX2:-}" ]] && rm -rf "$SANDBOX2"
}
trap cleanup EXIT

echo "=== EUT: .ai-suite/ refactor end-to-end tests ==="
echo ""

# -- T1: Directory structure integrity ----------------------------------------
echo "--- T1: directory structure ---"
for d in layer3-registry/core layer2-cognitive/templates layer1-abstraction/agents/cursor/skills layer1-abstraction/agents/cursor \
          layer1-abstraction/agents/claude layer4-evolutionary/validation; do
  if [[ -d "$AI_SUITE/$d" ]]; then pass "T1: .ai-suite/$d exists"
  else fail "T1: .ai-suite/$d missing"; fi
done

# -- T2: Cursor agent project install (sandbox) -------------------------------
echo ""
echo "--- T2: cursor agent project install ---"
SANDBOX=$(make_sandbox)
SANDBOX2=$(make_sandbox)

# Simulate a fake HOME so ~/.cursor/ writes go into the sandbox
(
  export HOME="$SANDBOX2"
  bash "$ENABLE" enable --agent cursor --scope project --project "$SANDBOX" 2>/dev/null
)
install_exit=$?

if [[ "$install_exit" -eq 0 ]]; then pass "T2a: cursor project install exits 0"
else fail "T2a: cursor project install exited $install_exit"; fi

if [[ -f "$SANDBOX/.cursorrules" ]]; then pass "T2b: .cursorrules created"
else fail "T2b: .cursorrules not created"; fi

if grep -qF "AI Suite" "$SANDBOX/.cursorrules" 2>/dev/null; then
  pass "T2c: .cursorrules contains ai-suite block"
else fail "T2c: .cursorrules missing ai-suite block"; fi

safety_rule="$SANDBOX/.cursor/rules/cursor-suite-production-safety.mdc"
if [[ -f "$safety_rule" ]]; then pass "T2d: production-safety rule deployed"
else fail "T2d: production-safety rule not deployed"; fi

rm -rf "$SANDBOX" "$SANDBOX2"

# -- T3: Cursor idempotency ----------------------------------------------------
echo ""
echo "--- T3: cursor project idempotency ---"
SANDBOX=$(make_sandbox); SANDBOX2=$(make_sandbox)

(
  export HOME="$SANDBOX2"
  bash "$ENABLE" enable --agent cursor --scope project --project "$SANDBOX" 2>/dev/null
  bash "$ENABLE" enable --agent cursor --scope project --project "$SANDBOX" 2>/dev/null
)

block_count=$(grep -c "AI Suite" "$SANDBOX/.cursorrules" 2>/dev/null || true)
if [[ "$block_count" -le 2 ]]; then pass "T3: idempotent (block_count=$block_count, expected <=2)"
else fail "T3: block duplicated (count=$block_count)"; fi

rm -rf "$SANDBOX" "$SANDBOX2"

# -- T4: Cursor project disable -----------------------------------------------
echo ""
echo "--- T4: cursor project disable ---"
SANDBOX=$(make_sandbox); SANDBOX2=$(make_sandbox)

(
  export HOME="$SANDBOX2"
  bash "$ENABLE" enable  --agent cursor --scope project --project "$SANDBOX" 2>/dev/null
  bash "$DISABLE" disable --agent cursor --scope project --project "$SANDBOX" 2>/dev/null
)

if ! grep -qF "AI Suite" "$SANDBOX/.cursorrules" 2>/dev/null; then
  pass "T4a: ai-suite block removed from .cursorrules"
else fail "T4a: ai-suite block still present in .cursorrules"; fi

if [[ ! -f "$SANDBOX/.cursor/rules/cursor-suite-production-safety.mdc" ]]; then
  pass "T4b: production-safety rule removed"
else fail "T4b: production-safety rule still present"; fi

rm -rf "$SANDBOX" "$SANDBOX2"

# -- T5: Claude agent project install -----------------------------------------
echo ""
echo "--- T5: claude agent project install ---"
SANDBOX=$(make_sandbox)

(
  export HOME="$SANDBOX"
  bash "$ENABLE" enable --agent claude --scope project --project "$SANDBOX" 2>/dev/null
)
claude_exit=$?

if [[ "$claude_exit" -eq 0 ]]; then pass "T5a: claude project install exits 0"
else fail "T5a: claude project install exited $claude_exit"; fi

if [[ -f "$SANDBOX/CLAUDE.md" ]]; then pass "T5b: CLAUDE.md created"
else fail "T5b: CLAUDE.md not created"; fi

if grep -qF "AI Suite Skills" "$SANDBOX/CLAUDE.md" 2>/dev/null; then
  pass "T5c: CLAUDE.md contains skill section"
else fail "T5c: CLAUDE.md missing skill section"; fi

if grep -qF "Run Reflection" "$SANDBOX/CLAUDE.md" 2>/dev/null; then
  pass "T5d: CLAUDE.md contains reflection trigger"
else fail "T5d: CLAUDE.md missing reflection trigger"; fi

# Check skills are listed
if grep -qF "tdd-team" "$SANDBOX/CLAUDE.md" 2>/dev/null; then
  pass "T5e: CLAUDE.md lists tdd-team skill"
else fail "T5e: CLAUDE.md missing tdd-team skill"; fi

if grep -qF "codebase-deepdoc" "$SANDBOX/CLAUDE.md" 2>/dev/null; then
  pass "T5f: CLAUDE.md lists codebase-deepdoc skill"
else fail "T5f: CLAUDE.md missing codebase-deepdoc"; fi

# Cursor files NOT created
if [[ ! -f "$SANDBOX/.cursorrules" ]]; then
  pass "T5g: .cursorrules NOT created for claude agent"
else fail "T5g: .cursorrules should not exist for claude-only install"; fi

rm -rf "$SANDBOX"

# -- T6: Claude idempotency ----------------------------------------------------
echo ""
echo "--- T6: claude idempotency ---"
SANDBOX=$(make_sandbox)

(
  export HOME="$SANDBOX"
  bash "$ENABLE" enable --agent claude --scope project --project "$SANDBOX" 2>/dev/null
  bash "$ENABLE" enable --agent claude --scope project --project "$SANDBOX" 2>/dev/null
)

sentinel_count=$(grep -c "ai-suite:start" "$SANDBOX/CLAUDE.md" 2>/dev/null || echo 0)
if [[ "$sentinel_count" -eq 1 ]]; then pass "T6: claude install is idempotent (sentinel_count=1)"
else fail "T6: claude install not idempotent (sentinel_count=$sentinel_count)"; fi

rm -rf "$SANDBOX"

# -- T7: Claude project disable ------------------------------------------------
echo ""
echo "--- T7: claude project disable ---"
SANDBOX=$(make_sandbox)
# Pre-populate CLAUDE.md with content OUTSIDE the sentinel block
printf 'Existing content\n' > "$SANDBOX/CLAUDE.md"

(
  export HOME="$SANDBOX"
  bash "$ENABLE" enable  --agent claude --scope project --project "$SANDBOX" 2>/dev/null
  bash "$DISABLE" disable --agent claude --scope project --project "$SANDBOX" 2>/dev/null
)

if grep -qF "Existing content" "$SANDBOX/CLAUDE.md" 2>/dev/null; then
  pass "T7a: existing CLAUDE.md content preserved after disable"
else fail "T7a: disable destroyed content outside sentinel block"; fi

if ! grep -qF "ai-suite:start" "$SANDBOX/CLAUDE.md" 2>/dev/null; then
  pass "T7b: sentinel block removed by disable"
else fail "T7b: sentinel block still present after disable"; fi

rm -rf "$SANDBOX"

# -- T8: --agent all installs both cursor and claude --------------------------
echo ""
echo "--- T8: --agent all ---"
SANDBOX=$(make_sandbox); SANDBOX2=$(make_sandbox)

(
  export HOME="$SANDBOX2"
  bash "$ENABLE" enable --agent all --scope project --project "$SANDBOX" 2>/dev/null
)

if [[ -f "$SANDBOX/.cursorrules" ]]; then pass "T8a: .cursorrules created for 'all'"
else fail "T8a: .cursorrules missing for 'all'"; fi

if [[ -f "$SANDBOX/CLAUDE.md" ]]; then pass "T8b: CLAUDE.md created for 'all'"
else fail "T8b: CLAUDE.md missing for 'all'"; fi

rm -rf "$SANDBOX" "$SANDBOX2"
SANDBOX2=""

# -- T9: --agent unknownagent exits non-zero with helpful message --------------
echo ""
echo "--- T9: unknown agent rejection ---"
bad_exit=0
bad_msg=$(bash "$ENABLE" enable --agent unknownagent --scope project 2>&1 || true)
# get exit code separately since 'bad_msg=$(...)' swallows it
bash "$ENABLE" enable --agent unknownagent --scope project 2>/dev/null; bad_exit=$? || true
# Force exit code retrieval
{ bash "$ENABLE" enable --agent unknownagent --scope project 2>/dev/null; bad_exit=$?; } || bad_exit=$?

if [[ "$bad_exit" -ne 0 ]]; then pass "T9a: --agent unknownagent exits non-zero"
else fail "T9a: expected non-zero exit for unknown agent"; fi

if printf '%s' "$bad_msg" | grep -iqF "unsupported"; then
  pass "T9b: error message includes 'unsupported'"
else fail "T9b: error message does not say 'unsupported' (got: $bad_msg)"; fi

# -- T10: Cursor global install (sandbox ~/.cursor/) ---------------------------
echo ""
echo "--- T10: cursor global install ---"
SANDBOX=$(make_sandbox)

(
  export HOME="$SANDBOX"
  bash "$ENABLE" enable --agent cursor --scope global 2>/dev/null
)
global_exit=$?

if [[ "$global_exit" -eq 0 ]]; then pass "T10a: cursor global install exits 0"
else fail "T10a: cursor global install exited $global_exit"; fi

if [[ -d "$SANDBOX/.cursor/skills" ]]; then pass "T10b: ~/.cursor/skills/ created"
else fail "T10b: ~/.cursor/skills/ not created"; fi

# At least one core skill mirrored
skill_count=$(find "$SANDBOX/.cursor/skills" -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' ')
if [[ "$skill_count" -ge 7 ]]; then
  pass "T10c: $skill_count skills mirrored (>=7 core+cursor)"
else fail "T10c: only $skill_count skills mirrored (expected >=7)"; fi


rm -rf "$SANDBOX"


# -- T12: Claude global install ------------------------------------------------
echo ""
echo "--- T12: claude global install ---"
SANDBOX=$(make_sandbox)

(
  export HOME="$SANDBOX"
  bash "$ENABLE" enable --agent claude --scope global 2>/dev/null
)
global_claude_exit=$?

if [[ "$global_claude_exit" -eq 0 ]]; then pass "T12a: claude global install exits 0"
else fail "T12a: claude global install exited $global_claude_exit"; fi

if [[ -f "$SANDBOX/.claude/CLAUDE.md" ]]; then pass "T12b: ~/.claude/CLAUDE.md created"
else fail "T12b: ~/.claude/CLAUDE.md not created"; fi

if grep -qF "AI Suite Skills" "$SANDBOX/.claude/CLAUDE.md" 2>/dev/null; then
  pass "T12c: global CLAUDE.md contains skill section"
else fail "T12c: global CLAUDE.md missing skill section"; fi

rm -rf "$SANDBOX"

# -- T13: validate-suite.sh scans all three tiers -----------------------------
echo ""
echo "--- T13: validate-suite.sh multi-tier ---"
val_out=$(bash "$AI_SUITE/layer4-evolutionary/validation/validate-suite.sh" 2>&1)
val_exit=$?

if [[ "$val_exit" -eq 0 ]]; then pass "T13a: validator exits 0"
else fail "T13a: validator failed"; fi

pass_count=$(printf '%s' "$val_out" | grep -c "^  PASS" || true)
expected_check_count=$(printf '%s' "$val_out" | grep -oE "[0-9]+ checks passed" | grep -oE "^[0-9]+" || echo "0")
if [[ "$pass_count" -eq "$expected_check_count" && "$pass_count" -gt 0 ]]; then
  pass "T13b: ${pass_count}/${expected_check_count} skill checks passed"
else fail "T13b: expected $expected_check_count checks, got $pass_count"; fi

# -- T14: dry-run makes no changes --------------------------------------------
echo ""
echo "--- T14: dry-run no-op ---"
SANDBOX=$(make_sandbox)

(
  export HOME="$SANDBOX"
  bash "$ENABLE" enable --agent all --scope project --project "$SANDBOX" --dry-run 2>/dev/null
)

if [[ ! -f "$SANDBOX/.cursorrules" ]]; then pass "T14a: dry-run created no .cursorrules"
else fail "T14a: dry-run created .cursorrules (should be no-op)"; fi

if [[ ! -f "$SANDBOX/CLAUDE.md" ]]; then pass "T14b: dry-run created no CLAUDE.md"
else fail "T14b: dry-run created CLAUDE.md (should be no-op)"; fi

rm -rf "$SANDBOX"

# -- Summary -------------------------------------------------------------------
printf '\n'
if [[ "$FAIL" -eq 0 ]]; then
  printf '%s[eut-refactor] %d/%d passed%s\n' "$(_grn)" "$PASS" "$TOTAL" "$(_off)"
  exit 0
else
  printf '%s[eut-refactor] %d passed, %d FAILED / %d total%s\n' \
    "$(_red)" "$PASS" "$FAIL" "$TOTAL" "$(_off)" >&2
  exit 1
fi

#!/usr/bin/env bash
# test-global-cursorrules-eut.sh -- Phase 4 EUT: global ~/.cursorrules fix
# End-to-end sandbox tests for the full global install/uninstall cycle,
# verifying ~/.cursorrules, domain skills, idempotency, and isolation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENABLE="$PROJECT_ROOT/ai-suite"
DISABLE="$PROJECT_ROOT/ai-suite"
SUITE_DIR="$PROJECT_ROOT/.ai-suite"

PASS=0; FAIL=0

pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; FAIL=$((FAIL+1)); }

make_sandbox() { mktemp -d "${TMPDIR:-/tmp}/eut-global-cr.XXXXXX"; }

# -- E1: global install writes ~/.cursorrules ---------------------------------
echo ""
echo "=== E1: Global install writes ~/.cursorrules ==="

SB=$(make_sandbox); trap 'rm -rf "$SB"' EXIT
(
  export HOME="$SB"
  bash "$ENABLE" enable --agent cursor --scope global 2>/dev/null
)
CR="$SB/.cursorrules"

if [[ -f "$CR" ]]; then pass "E1a ~/.cursorrules created"
else fail "E1a ~/.cursorrules created"; fi

if grep -q '>>>>> cursor-ai-suite >>>>>' "$CR"; then
  pass "E1b AI Suite block start marker in ~/.cursorrules"
else fail "E1b AI Suite block start marker in ~/.cursorrules"; fi

if grep -q 'reflection-protocol.md' "$CR"; then
  pass "E1c reflection-protocol.md referenced in ~/.cursorrules"
else fail "E1c reflection-protocol.md referenced in ~/.cursorrules"; fi

if grep -q '\.cursor/skills\|cursor/skills' "$CR"; then
  pass "E1d skills location referenced in ~/.cursorrules"
else fail "E1d skills location referenced in ~/.cursorrules"; fi

if grep -q 'Run Reflection\|Run Reflection' "$CR"; then
  pass "E1e reflection trigger instruction present in ~/.cursorrules"
else fail "E1e reflection trigger instruction present in ~/.cursorrules"; fi

# -- E2: global install without domain -- 9 skills -----------------------------
echo ""
echo "=== E2: Global install -- skill count ==="

skill_count=$(find "$SB/.cursor/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
expected_base=$(find \
  "$SUITE_DIR/layer3-registry/core" \
  "$SUITE_DIR/layer1-abstraction/agents/cursor/skills" \
  "$SUITE_DIR/layer4-evolutionary/merging" \
  "$SUITE_DIR/layer2-cognitive/meta-compiler" \
  "$SUITE_DIR/layer3-registry/domains"/*/skills \
  -maxdepth 1 -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')
if [[ "$skill_count" -eq "$expected_base" ]]; then
  pass "E2a without --domain: $skill_count/$expected_base skills"
else fail "E2a without --domain: expected $expected_base, got $skill_count"; fi

for domain_skill in bugzilla-debug bugzilla-rest-api; do
  if [[ -d "$SB/.cursor/skills/$domain_skill" ]]; then
    pass "E2b domain skill present with flag: $domain_skill"
  else fail "E2b domain skill present with flag: $domain_skill"; fi
done


# -- E4: idempotency -----------------------------------------------------------
echo ""
echo "=== E4: Idempotency ==="

(
  export HOME="$SB"
  bash "$ENABLE" enable --agent cursor --scope global 2>/dev/null
)
block_count=$(grep -c '>>>>> cursor-ai-suite >>>>>' "$CR" || true)
if [[ "$block_count" -eq 1 ]]; then
  pass "E4a exactly 1 block after 2 global installs"
else fail "E4a expected 1 block, got $block_count"; fi

# -- E5: uninstall removes block + preserves other content --------------------
echo ""
echo "=== E5: Global uninstall ==="

printf '\n# user custom alias\nalias gs="git status"\n' >> "$CR"
(
  export HOME="$SB"
  bash "$DISABLE" disable --agent cursor --scope global 2>/dev/null
)

if ! grep -q '>>>>> cursor-ai-suite >>>>>' "$CR" 2>/dev/null; then
  pass "E5a AI Suite block removed by global uninstall"
else fail "E5a AI Suite block removed by global uninstall"; fi

if grep -q 'user custom alias' "$CR" 2>/dev/null; then
  pass "E5b non-suite content preserved after global uninstall"
else fail "E5b non-suite content preserved after global uninstall"; fi

if [[ ! -d "$SB/.cursor/skills/tdd-team" ]]; then
  pass "E5c skill dirs removed by global uninstall"
else fail "E5c skill dirs removed by global uninstall"; fi

# -- E6: project install does NOT touch ~/.cursorrules -------------------------
echo ""
echo "=== E6: Project install isolation ==="

SB6=$(make_sandbox); trap 'rm -rf "$SB6"' EXIT
PROJ6="$SB6/myproject"; mkdir -p "$PROJ6"
(
  export HOME="$SB6"
  bash "$ENABLE" enable --agent cursor --scope project --project "$PROJ6" 2>/dev/null
)
if [[ ! -f "$SB6/.cursorrules" ]]; then
  pass "E6a project install does NOT create ~/.cursorrules"
else fail "E6a project install does NOT create ~/.cursorrules"; fi

if [[ -f "$PROJ6/.cursorrules" ]]; then
  pass "E6b project .cursorrules is written in project dir"
else fail "E6b project .cursorrules is written in project dir"; fi

if grep -q '>>>>> cursor-ai-suite >>>>>' "$PROJ6/.cursorrules" 2>/dev/null; then
  pass "E6c project .cursorrules contains AI Suite block"
else fail "E6c project .cursorrules contains AI Suite block"; fi

# -- E7: dry-run global install produces no files ------------------------------
echo ""
echo "=== E7: Dry-run global install ==="

SB7=$(make_sandbox); trap 'rm -rf "$SB7"' EXIT
(
  export HOME="$SB7"
  bash "$ENABLE" enable --agent cursor --scope global --dry-run 2>/dev/null
)
if [[ ! -f "$SB7/.cursorrules" ]]; then
  pass "E7a dry-run does NOT create ~/.cursorrules"
else fail "E7a dry-run does NOT create ~/.cursorrules"; fi

# -- E8: Full acceptance test regression ---------------------------------------
echo ""
echo "=== E8: Acceptance test regression ==="

acc_out=$(bash "$PROJECT_ROOT/.ai-suite/layer4-evolutionary/validation/run-acceptance-tests.sh" 2>&1) || true
if echo "$acc_out" | grep -qE "[0-9]+ passed.*0 FAILED|0 failures"; then
  pass "E8 acceptance tests all pass"
else
  final_line=$(echo "$acc_out" | tail -3)
  fail "E8 acceptance tests -- some failures: $final_line"
fi

# -----------------------------------------------------------------------------
echo ""
TOTAL=$((PASS+FAIL))
printf '=== %d passed, %d FAILED out of %d ===\n' "$PASS" "$FAIL" "$TOTAL"
echo ""
[[ $FAIL -eq 0 ]]

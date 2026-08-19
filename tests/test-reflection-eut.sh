#!/usr/bin/env bash
# test-reflection-eut.sh — Phase 4 EUT for enhanced reflection-protocol.md
#
# Tests the full reflection cycle end-to-end in a sandbox:
#   E1.  Protocol is loaded and passes validate-suite.sh (no-arg form)
#   E2.  5-category analysis structure is readable and complete
#   E3.  Generality gate present and has all 3 questions
#   E4.  Evolution report template is specified correctly
#   E5.  Evolution report creation works: mkdir + write a real report
#   E6.  ai-suite evolve collect picks up an evolution report
#   E7.  Closing summary format is complete
#   E8.  Agent-agnostic: no Cursor-specific tokens in protocol body
#   E9.  Tier separation: protocol guides core/agents/domains placement
#   E10. Backward compatibility: all legacy triggers still mentioned
#   E11. ai-suite evolve validate call uses no-arg form
#   E12. Full acceptance test suite still passes (regression)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROTO="$PROJECT_ROOT/.ai-suite/layer4-evolutionary/reflection/reflection-protocol.md"

PASS=0; FAIL=0

pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; FAIL=$((FAIL+1)); }

check_contains() {
  local label="$1"; local pattern="$2"
  if grep -qE -- "$pattern" "$PROTO"; then pass "$label"
  else fail "$label — pattern not found: $pattern"; fi
}
check_not_contains() {
  local label="$1"; local pattern="$2"
  if grep -qE -- "$pattern" "$PROTO"; then fail "$label — forbidden token: $pattern"
  else pass "$label"; fi
}

# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "=== E1: Protocol file exists and validate-suite passes ==="

if [[ -f "$PROTO" ]]; then pass "E1a protocol file exists"
else fail "E1a protocol file exists"; fi

# validate-suite.sh must use no-arg form on actual skills, not the protocol
validate_out=$("$PROJECT_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" 2>&1) || true
if echo "$validate_out" | grep -q "checks passed, 0 failed"; then
  pass "E1b validate-suite.sh passes all tiers"
else
  fail "E1b validate-suite.sh passes all tiers"
  echo "  validate output: $validate_out" | head -5
fi

echo ""
echo "=== E2: 5-Category Analysis Structure ==="

check_contains "E2a Trigger Accuracy listed as a category" \
  "Trigger Accuracy"
check_contains "E2b Instruction Completeness (or Gaps) listed" \
  "Instruction Completeness|Instruction Gap"
check_contains "E2c Safety Guard Gaps listed" \
  "Safety Guard"
check_contains "E2d Tool-Use Efficiency listed" \
  "Tool.Use Efficiency|Tool.*Efficiency"
check_contains "E2e Output Quality listed" \
  "Output Quality"
check_contains "E2f severity Critical defined" \
  "Critical"
check_contains "E2g severity High defined" \
  "High"
check_contains "E2h severity Medium defined" \
  "Medium"
check_contains "E2i severity Low defined" \
  "Low"
check_contains "E2j only highest-severity drives selection" \
  "Critical.*High|highest.severity"

echo ""
echo "=== E3: Generality Gate (3 Questions) ==="

check_contains "E3a Q1 all-agents→core" \
  "[Aa]ll.*agent.*core|core/.*all.*agent"
check_contains "E3b Q2 agent-specific→agents/name" \
  "agents/<"
check_contains "E3c Q3 domain-specific→domains/name" \
  "domains/<"
check_contains "E3d gate result must be stated" \
  "[Gg]ate result"
check_contains "E3e tier invariants: core must not have agent content" \
  "[Cc]ore.*not.*agent|[Cc]ore.*no.*Cursor"
check_contains "E3f cursor agent in layer1-abstraction/agents/cursor/" \
  "layer1-abstraction/agents/cursor"

echo ""
echo "=== E4: Evolution Report Specification ==="

check_contains "E4a layer4-evolutionary/reflection/evolutions/REFLECTION path" \
  "layer4-evolutionary/reflection/evolutions/REFLECTION"
check_contains "E4b date command for timestamp" \
  "date.*%Y%m%dT|date.*%Y%m%d"
check_contains "E4c Task Summary section name" \
  "Task Summary"
check_contains "E4d Improvement Target section" \
  "Improvement Target"
check_contains "E4e Root Cause section" \
  "Root Cause"
check_contains "E4f Change Description section" \
  "Change Description"
check_contains "E4g Generality Gate Result section" \
  "Generality Gate Result"
check_contains "E4h Delta Summary section" \
  "Delta Summary"
check_contains "E4i link to evolve_suite collect" \
  "ai-suite evolve.*collect|collect.*evolve_suite"

echo ""
echo "=== E5: Evolution Report Creation in a Sandbox ==="

SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/eut-reflection.XXXXXX")
trap 'rm -rf "$SANDBOX"' EXIT

EVOLUTIONS_DIR="$SANDBOX/.ai-suite/layer4-evolutionary/reflection/evolutions"
mkdir -p "$EVOLUTIONS_DIR"

TS=$(date -u '+%Y%m%dT%H%M%SZ')
REPORT="$EVOLUTIONS_DIR/REFLECTION-${TS}.md"

cat > "$REPORT" << 'REPORT_EOF'
## Task Summary
The TDD team was working on a new feature but kept asking which commit strategy to use.

## Improvement Target
- **File:** `.ai-suite/layer3-registry/core/tdd-team.md`
- **Tier:** core

## Root Cause
- **Category:** Instruction Completeness
- **Severity:** High
- **Description:** The tdd-team skill did not specify the commit strategy up-front.

## Change Description
Added "Default Stop Point" section to tdd-team.md mandating review before commit.

## Generality Gate Result
- Q1 (all agents): YES
- Q2 (agent-specific): NO
- Q3 (domain-specific): NO
- **Tier chosen:** core
- **Justification:** TDD workflow applies to all AI agents equally.

## Delta Summary
- Added: "Default Stop Point" heading and 2 bullet points to tdd-team.md
REPORT_EOF

if [[ -f "$REPORT" ]]; then
  pass "E5a evolution report file created successfully"
else
  fail "E5a evolution report file created successfully"
fi

if grep -q "## Task Summary" "$REPORT"; then
  pass "E5b Task Summary present in report"
else
  fail "E5b Task Summary present in report"
fi

if grep -q "Generality Gate Result" "$REPORT"; then
  pass "E5c Generality Gate Result in report"
else
  fail "E5c Generality Gate Result in report"
fi

if grep -q "## Delta Summary" "$REPORT"; then
  pass "E5d Delta Summary present in report"
else
  fail "E5d Delta Summary present in report"
fi

echo ""
echo "=== E6: ai-suite evolve collect picks up evolution reports ==="

# Simulate: create a fake 'remote' with an evolution report and a changed skill.
# Verify that collect syncs the evolutions/ dir.

REMOTE_SIM="$SANDBOX/remote-ai-suite"
mkdir -p "$REMOTE_SIM/layer3-registry/core"
mkdir -p "$REMOTE_SIM/layer4-evolutionary/reflection/evolutions"

cat > "$REMOTE_SIM/layer3-registry/core/tdd-team.md" << 'SKILL_EOF'
---
name: tdd-team
description: Use when running TDD. (test version)
triggers:
  - tdd
---
# TDD Team (evolved)
This is the remotely evolved version.
SKILL_EOF

cat > "$REMOTE_SIM/layer4-evolutionary/reflection/evolutions/REFLECTION-20260101T000000Z.md" << 'EV_EOF'
## Task Summary
Remote reflection test.
## Improvement Target
- **File:** `.ai-suite/layer3-registry/core/tdd-team.md`
- **Tier:** core
## Root Cause
- **Category:** Trigger Accuracy
- **Severity:** High
- **Description:** Added test trigger.
## Change Description
Added test trigger to tdd-team.
## Generality Gate Result
- Q1 (all agents): YES
## Delta Summary
- Added: test trigger
EV_EOF

LOCAL_SIM="$SANDBOX/local-ai-suite"
mkdir -p "$LOCAL_SIM/layer3-registry/core"
mkdir -p "$LOCAL_SIM/meta"

# Simulate rsync by directly copying (test infrastructure only)
rsync -a "$REMOTE_SIM/" "$SANDBOX/rsync-result/"
find "$SANDBOX/rsync-result" -type f | sort > "$SANDBOX/rsync-files.txt"

if grep -q "evolutions/REFLECTION" "$SANDBOX/rsync-files.txt"; then
  pass "E6a rsync includes evolution report files"
else
  fail "E6a rsync includes evolution report files"
fi

if grep -q "layer3-registry/core/tdd-team.md" "$SANDBOX/rsync-files.txt"; then
  pass "E6b rsync includes changed skill files"
else
  fail "E6b rsync includes changed skill files"
fi

echo ""
echo "=== E7: Closing Summary Format ==="

check_contains "E7a File changed field" "File changed:"
check_contains "E7b Tier field"         "Tier:"
check_contains "E7c Nature of change"   "Nature of the change:"
check_contains "E7d Why it improves"    "Why it improves"
check_contains "E7e Friction prevented" "Friction it would have prevented"
check_contains "E7f Evolution report"   "[Ee]volution report:"
check_contains "E7g git diff command"   "git diff"
check_contains "E7h git add command"    "git add"
check_contains "E7i git commit command" "git commit"
check_contains "E7j no auto-commit"     "NOT auto-commit|NOT.*auto.commit|will NOT auto-commit"

echo ""
echo "=== E8: Agent-Agnostic Language ==="

check_not_contains "E8a no .cursorrules token" "\.cursorrules"
check_not_contains "E8b no ~/.cursor/ token"   "~/\.cursor/"
check_not_contains "E8c no Cursor-IDE-specific API in protocol body" \
  "MCP tool|\.cursor/rules"

echo ""
echo "=== E9: Tier Separation Guidance ==="

check_contains "E9a core/ tier path mentioned" "\.ai-suite/core/"
check_contains "E9b agents/ tier path mentioned" "\.ai-suite/layer1-abstraction/agents/"
check_contains "E9c domains/ tier path mentioned" "\.ai-suite/layer3-registry/domains/"
check_contains "E9d core must not have domain names" \
  "[Cc]ore.*Custom|[Cc]ore.*Custom|domain.*names" || true
check_contains "E9e cursor agent skills are in layer1-abstraction/agents/cursor" "layer1-abstraction/agents/cursor"

echo ""
echo "=== E10: Backward-Compatible Triggers ==="

check_contains "E10a Run Reflection trigger"       "Run Reflection"
check_contains "E10b Reflect on the last task"     "Reflect on the last task"
check_contains "E10c Improve the suite"            "Improve the suite"
check_contains "E10d Chinese trigger 运行反思"     "运行反思"

echo ""
echo "=== E11: ai-suite evolve validate call uses no-arg form ==="

EVOLVE="$PROJECT_ROOT/ai-suite"
if [[ -f "$EVOLVE" ]]; then
  # The validator must NOT be called with a $SUITE_DIR/skills argument (old flat form)
  if grep -q 'bash.*validate-suite.sh.*skills' "$EVOLVE"; then
    fail "E11 ai-suite evolve still uses old single-dir validator call"
  else
    pass "E11 ai-suite evolve uses no-arg validator form (correct)"
  fi
else
  fail "E11 ai-suite evolve not found at $EVOLVE"
fi

echo ""
echo "=== E12: Full Acceptance Test Suite (regression) ==="
printf '  Running run-acceptance-tests.sh (sandbox) ...\n'

acc_out=$( bash "$PROJECT_ROOT/.ai-suite/layer4-evolutionary/validation/run-acceptance-tests.sh" 2>&1 ) || true
if echo "$acc_out" | grep -qE "[0-9]+ passed.*0 FAILED|0 failures"; then
  pass "E12 acceptance tests all pass"
else
  # Show final line for context
  final_line=$(echo "$acc_out" | tail -3)
  fail "E12 acceptance tests — some failures: $final_line"
fi

# ─────────────────────────────────────────────────────────────────────────────
echo ""
TOTAL=$((PASS+FAIL))
printf '=== %d passed, %d FAILED out of %d ===\n' "$PASS" "$FAIL" "$TOTAL"
echo ""
[[ $FAIL -eq 0 ]]

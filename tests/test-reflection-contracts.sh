#!/usr/bin/env bash
# test-reflection-contracts.sh -- Phase 2 RED contract tests for enhanced reflection-protocol.md
# Verifies that reflection-protocol.md satisfies every contract in reflection-protocol-contracts.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROTO="$PROJECT_ROOT/.ai-suite/layer4-evolutionary/reflection/reflection-protocol.md"
PASS=0; FAIL=0

pass() { printf '  PASS  %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '  FAIL  %s\n' "$1"; FAIL=$((FAIL+1)); }

check_contains() {
  local label="$1"; local pattern="$2"
  if grep -qE -- "$pattern" "$PROTO"; then pass "$label"
  else fail "$label -- pattern not found: $pattern"; fi
}
check_not_contains() {
  local label="$1"; local pattern="$2"
  if grep -qE -- "$pattern" "$PROTO"; then fail "$label -- forbidden token found: $pattern"
  else pass "$label"; fi
}

echo ""
echo "=== Structural Section Contracts ==="

check_contains "S1 trigger block present"              "Run Reflection|Reflect on the last task|Improve the suite"
check_contains "S2 ABSOLUTE PRECONDITIONS present"     "ABSOLUTE PRECONDITIONS"
check_contains "S3 Step 1 present"                     "Step 1"
check_contains "S4 Step 2 present"                     "Step 2"
check_contains "S5 Step 3 present"                     "Step 3"
check_contains "S6 Step 4 present"                     "Step 4"
check_contains "S7 Step 5 present"                     "Step 5"
check_contains "S8 NON-NEGOTIABLES present"            "NON-NEGOTIABLE"
check_contains "S9 DIAGNOSTIC HEURISTICS present"      "DIAGNOSTIC HEURISTIC"

echo ""
echo "=== 5-Category Analysis Contracts ==="

check_contains "A1 Trigger Accuracy category"          "[Tt]rigger [Aa]ccuracy"
check_contains "A2 Instruction Completeness category"  "[Ii]nstruction [Cc]omplete|[Ii]nstruction [Gg]ap"
check_contains "A3 Safety Guard Gaps category"         "[Ss]afety [Gg]uard|[Ss]afety.*[Gg]ap"
check_contains "A4 Tool-Use Efficiency category"       "[Tt]ool.use [Ee]fficiency|[Tt]ool.*[Ee]fficiency"
check_contains "A5 Output Quality category"            "[Oo]utput [Qq]uality"
check_contains "A6 severity tags in protocol"          "Critical|High|Medium|Low"
check_contains "A7 severity drives selection"          "Critical.*High|highest.severity"

echo ""
echo "=== Generality Gate Contracts ==="

check_contains "G1a Q1 all-agents gate"                "[Aa]ll agent|[Aa]ll AI agent"
check_contains "G1b Q2 task process gate"              "[Tt]ask process|[Pp]rocess.*procedure|core/process"
check_contains "G1c Q3 agent-specific gate"            "[Aa]gent.specific|agents/<"
check_contains "G1d Q4 domain-specific gate"           "[Dd]omain.specific|domains/<"
check_contains "G2 gate result stated before edit"     "[Gg]ate result|[Ss]tate.*gate"
check_contains "G3 new file tier justification"        "[Tt]ier.*just|[Jj]ustif.*tier"
check_contains "G4 core must not have agent tokens"    "[Cc]ore.*not.*agent|[Cc]ore.*no.*Cursor"

echo ""
echo "=== Evolution Report Contracts ==="

check_contains "R1 evolutions directory"               "layer4-evolutionary/reflection/evolutions/REFLECTION"
check_contains "R2a Task Summary section required"     "Task Summary"
check_contains "R2b Improvement Target section"        "Improvement Target"
check_contains "R2c Root Cause section"                "Root Cause"
check_contains "R2d Change Description section"        "Change Description"
check_contains "R2e Generality Gate Result section"    "Generality Gate Result"
check_contains "R2f Delta Summary section"             "Delta Summary"
check_contains "R3 co-located with evolve reports"     "evolve_suite|evolutions"
check_contains "R4 report filename in closing summary" "[Ee]volution report"

echo ""
echo "=== Closing Summary Format Contracts ==="

check_contains "CS1 File changed field"                "File changed:"
check_contains "CS2 Nature of the change field"        "Nature of the change:"
check_contains "CS3 Why it improves field"             "Why it improves"
check_contains "CS4 Friction it would have prevented"  "Friction it would have prevented"
check_contains "CS5 Tier field in summary"             "Tier:"
check_contains "CS6 Evolution report field"            "[Ee]volution report:"
check_contains "CS7 git diff instruction"              "git diff"
check_contains "CS8 no auto-commit"                    "[Nn]ot.*auto.commit|NOT.*auto.commit|NOT auto-commit"

echo ""
echo "=== Backward Compatibility Contracts ==="

check_contains "BC1a trigger: Run Reflection"          "Run Reflection"
check_contains "BC1b trigger: Reflect on"              "Reflect on the last task"
check_contains "BC1c trigger: Run Reflection"                 "Run Reflection"
check_contains "BC2 one-per-call rule"                 "[Oo]ne improvement per|[Oo]ne.*per.*[Rr]eflection"
check_contains "BC3 no auto-commit rule"               "NOT.*commit|not.*auto.commit"
check_contains "BC4 validate-suite no-arg form"        "validate-suite.sh\b"

echo ""
echo "=== Agent-Agnostic Language Contracts ==="

check_not_contains "AG1a no .cursorrules in body"      "\.cursorrules"
check_not_contains "AG1b no ~/.cursor/ in body"        "~/\.cursor/"
check_contains     "AG2 tier-aware paths used"         "core/|agents/|domains/"
check_contains     "AG3 no flat ai-suite/skills path"  "layer3-registry/core|agents/.*/skills|domains/.*/skills"

echo ""
TOTAL=$((PASS+FAIL))
printf "=== %d passed, %d FAILED out of %d ===\n" "$PASS" "$FAIL" "$TOTAL"
echo ""
[[ $FAIL -eq 0 ]]

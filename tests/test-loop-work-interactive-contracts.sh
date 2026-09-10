#!/usr/bin/env bash
set -euo pipefail

# test-loop-work-interactive-contracts.sh
# Validates contract requirements for loop-work and interactive-workflow synergy:
# 1. loop-work requires full execution summary explicitly outputted to chat before Step 2 echo & Step 3 AskQuestion.
# 2. loop-work explicitly enforces strict 2-stage wrap-up barrier (State 2 -> State 3) and forbids bundling AskQuestion.
# 3. interactive-workflow enforces mandatory AskQuestion loop persistence after any "Other" task.
# 4. interactive-workflow strictly forbids terminating turn without Step 2 summary and Step 3 AskQuestion.
# 5. interactive-workflow guarantees strict Cursor Agent-only isolation (not deployed to Codex).
# 6. zero-cost refinement guarantee (never re-prompt Step 0 for follow-up turns).

ROOT_DIR="/Users/dc005518/gitsource/dc005518_cursor_evolution"
cd "$ROOT_DIR"

LOOP_WORK_CORE=".ai-suite/layer3-registry/core/loop-work.md"
INTERACTIVE_RULE=".ai-suite/layer1-abstraction/agents/cursor/rules/interactive-workflow.md"
CODEX_ADAPTER=".ai-suite/layer1-abstraction/agents/codex/adapter.sh"
CURSOR_ADAPTER=".ai-suite/layer1-abstraction/agents/cursor/adapter.sh"

echo "=== Running Loop-Work & Interactive Workflow Contracts Validation ==="

FAILURES=0

assert_contains() {
  local file="$1"
  local pattern="$2"
  local desc="$3"

  if ! grep -qiE "$pattern" "$file"; then
    echo "  [FAIL] $file: Missing $desc (pattern: '$pattern')"
    FAILURES=$((FAILURES + 1))
  else
    echo "  [PASS] $file: $desc"
  fi
}

assert_not_contains() {
  local file="$1"
  local pattern="$2"
  local desc="$3"

  if grep -qiE "$pattern" "$file"; then
    echo "  [FAIL] $file: Unexpected match for $desc (pattern: '$pattern')"
    FAILURES=$((FAILURES + 1))
  else
    echo "  [PASS] $file: Verified absence of $desc"
  fi
}

echo "1. Checking Loop-Work Skill Contracts ($LOOP_WORK_CORE)..."
assert_contains "$LOOP_WORK_CORE" "(full.*summary.*chat|execution summary.*chat window|output the final task summary.*chat)" "Mandatory chat summary output on loop completion"
assert_contains "$LOOP_WORK_CORE" "echo 'Interactive workflow summary rendered'" "UI sync echo tool call in Step 7"
assert_contains "$LOOP_WORK_CORE" "(DO NOT call AskQuestion until|Do NOT bundle AskQuestion|separate.*AskQuestion)" "Strict separation of summary rendering and AskQuestion tool"
assert_contains "$LOOP_WORK_CORE" "(State 2.*summary.*State 3.*AskQuestion|Step 2.*summary.*Step 3.*AskQuestion)" "Explicit 2-stage wrap-up reference (State 2 -> State 3)"
assert_contains "$LOOP_WORK_CORE" "Do NOT call (\`?)AskQuestion(\`?) before outputting the full final execution summary" "Negative constraint against calling AskQuestion prematurely"

echo "2. Checking Interactive Workflow Rule Contracts ($INTERACTIVE_RULE)..."
assert_contains "$INTERACTIVE_RULE" "(loop-work|iterative workflow|looping task)" "Explicit guidance for loop-work and multi-iteration tasks"
assert_contains "$INTERACTIVE_RULE" "Multi-Iteration & Loop-Work Invariant" "Dedicated Multi-Iteration invariant heading"
assert_contains "$INTERACTIVE_RULE" "(after each task iteration.*done.*Other.*AskQuestion|always use AskQuestion.*Other|always use AskQuestion tool after each task is done)" "Persistent AskQuestion trigger after Other task"
assert_contains "$INTERACTIVE_RULE" "(STRICTLY FORBIDDEN from ending the turn|MUST NOT end the turn).*without.*AskQuestion" "Strict negative constraint against ending turn without AskQuestion"
assert_contains "$INTERACTIVE_RULE" "strictly and ONLY for the Cursor Agent" "Cursor agent-only constraint definition"
assert_contains "$INTERACTIVE_RULE" "Must not cost any extra Cursor included request" "Zero-cost refinement guarantee"
assert_contains "$INTERACTIVE_RULE" "(skip Step 0|do not re-prompt Step 0)" "Skip Step 0 on subsequent turns"

echo "3. Checking Agent Adapter Isolation Contracts..."
assert_contains "$CURSOR_ADAPTER" "layer1-abstraction/agents/cursor/rules" "Cursor adapter deploys cursor-specific rules"
assert_not_contains "$CODEX_ADAPTER" "interactive-workflow" "Codex adapter does NOT deploy interactive workflow"

echo "=================================================================="
if [ "$FAILURES" -gt 0 ]; then
  echo "CONTRACT VALIDATION FAILED: $FAILURES assertion(s) failed."
  exit 1
fi

echo "CONTRACT VALIDATION PASSED: All loop-work & interactive workflow contracts satisfied."
exit 0

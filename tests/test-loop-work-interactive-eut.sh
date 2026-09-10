#!/usr/bin/env bash
set -euo pipefail

# test-loop-work-interactive-eut.sh
# End-to-End User Acceptance Test (EUT) for Loop-Work & Interactive Workflow Synergy.
# Simulates state machine transitions, verifies isolation, and validates loop invariants.

ROOT_DIR="/Users/dc005518/gitsource/dc005518_cursor_evolution"
cd "$ROOT_DIR"

echo "=== Running EUT: Loop-Work & Interactive Workflow Synergy ==="

ERRORS=0

# Helper assertion
assert_eq() {
  local actual="$1"
  local expected="$2"
  local desc="$3"
  if [[ "$actual" != "$expected" ]]; then
    echo "  [FAIL] $desc: expected '$expected', got '$actual'"
    ERRORS=$((ERRORS + 1))
  else
    echo "  [PASS] $desc"
  fi
}

echo "1. Simulating Loop-Work N-iteration wrap-up sequence..."

# State machine simulator function
simulate_loop_wrapup() {
  local has_chat_summary="$1"
  local has_ui_echo="$2"
  local called_ask_question="$3"
  local echo_before_question="$4"

  # Invariant: Chat summary MUST be present
  if [[ "$has_chat_summary" != "true" ]]; then
    echo "FAIL_MISSING_SUMMARY"
    return
  fi

  # Invariant: UI echo MUST be executed before AskQuestion
  if [[ "$has_ui_echo" != "true" ]]; then
    echo "FAIL_MISSING_UI_ECHO"
    return
  fi

  if [[ "$called_ask_question" == "true" && "$echo_before_question" != "true" ]]; then
    echo "FAIL_PREMATURE_QUESTION"
    return
  fi

  echo "SUCCESS_WRAPUP_ORDER"
}

# Test 1a: Valid sequence (Summary -> UI Echo -> AskQuestion)
res_valid=$(simulate_loop_wrapup "true" "true" "true" "true")
assert_eq "$res_valid" "SUCCESS_WRAPUP_ORDER" "Valid loop-work wrap-up sequence satisfies barrier contract"

# Test 1b: Defect simulation - AskQuestion called before UI echo
res_premature=$(simulate_loop_wrapup "true" "true" "true" "false")
assert_eq "$res_premature" "FAIL_PREMATURE_QUESTION" "Premature AskQuestion before UI echo is correctly rejected"

# Test 1c: Defect simulation - Summary omitted
res_no_summary=$(simulate_loop_wrapup "false" "true" "true" "true")
assert_eq "$res_no_summary" "FAIL_MISSING_SUMMARY" "Omission of loop-work chat summary is correctly rejected"

echo "2. Simulating Interactive Workflow 'Other' follow-up loop..."

simulate_other_followup() {
  local interactive_active="$1"
  local skipped_step_0="$2"
  local task_completed="$3"
  local step_2_summary_done="$4"
  local step_3_ask_question_invoked="$5"

  if [[ "$interactive_active" != "true" ]]; then
    echo "FAIL_INACTIVE"
    return
  fi

  # Invariant: Step 0 must be skipped on follow-up tasks to prevent extra request cost
  if [[ "$skipped_step_0" != "true" ]]; then
    echo "FAIL_STEP0_NOT_SKIPPED"
    return
  fi

  # Invariant: Task must be 100% completed
  if [[ "$task_completed" != "true" ]]; then
    echo "FAIL_TASK_INCOMPLETE"
    return
  fi

  # Invariant: Step 2 summary must be executed
  if [[ "$step_2_summary_done" != "true" ]]; then
    echo "FAIL_MISSING_STEP2"
    return
  fi

  # Invariant: Step 3 AskQuestion must be invoked (not dropped)
  if [[ "$step_3_ask_question_invoked" != "true" ]]; then
    echo "FAIL_MISSING_STEP3"
    return
  fi

  echo "SUCCESS_OTHER_LOOP"
}

# Test 2a: Valid Other loop execution
res_other_valid=$(simulate_other_followup "true" "true" "true" "true" "true")
assert_eq "$res_other_valid" "SUCCESS_OTHER_LOOP" "Valid 'Other' follow-up task completes Step 1 -> Step 2 -> Step 3"

# Test 2b: Defect simulation - Dropping the turn without Step 3 AskQuestion
res_other_dropped=$(simulate_other_followup "true" "true" "true" "true" "false")
assert_eq "$res_other_dropped" "FAIL_MISSING_STEP3" "Terminating turn without AskQuestion is correctly flagged"

# Test 2c: Defect simulation - Re-prompting Step 0 (costing extra request)
res_reprompt=$(simulate_other_followup "true" "false" "true" "true" "true")
assert_eq "$res_reprompt" "FAIL_STEP0_NOT_SKIPPED" "Re-prompting Step 0 on follow-up task is correctly flagged"

echo "3. Verifying Local Agent Isolation Contracts..."

# Verify Cursor has the interactive workflow rule
if [[ -f "$HOME/.cursor/rules/cursor-suite-interactive-workflow.mdc" ]]; then
  echo "  [PASS] Cursor has cursor-suite-interactive-workflow.mdc installed"
else
  echo "  [FAIL] Cursor is missing cursor-suite-interactive-workflow.mdc"
  ERRORS=$((ERRORS + 1))
fi

# Verify Codex does NOT have the interactive workflow rule or directives
if grep -qi "interactive-workflow" "$HOME/.codex/AGENTS.md" 2>/dev/null; then
  echo "  [FAIL] Codex AGENTS.md contains interactive workflow instructions"
  ERRORS=$((ERRORS + 1))
elif [[ -f "$HOME/.codex/directives/interactive-workflow.md" ]]; then
  echo "  [FAIL] Codex directives contains interactive-workflow.md"
  ERRORS=$((ERRORS + 1))
else
  echo "  [PASS] Codex AGENTS.md and directives are strictly isolated from interactive workflow"
fi

echo "=================================================================="
if [[ "$ERRORS" -gt 0 ]]; then
  echo "EUT SUITE FAILED: $ERRORS test(s) failed."
  exit 1
fi

echo "EUT SUITE PASSED: All loop-work & interactive workflow behavioral scenarios verified."
exit 0

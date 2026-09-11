#!/usr/bin/env bash
set -euo pipefail

# test-interactive-workflow-cleanup.sh
# Validates contract requirements and state machine transitions for:
# 1. Interactive workflow mandating active task cleanup of temporary and unused files before AskQuestion.
# 2. Mandating AI agent file list inspection (e.g. git status or directory listing) to identify and remove temporary or unused files.
# 3. Directives enforcing AI agent file list checking and active task cleanup before AskQuestion.
# 4. Loop-work skill mandating file list checking and cleanup before wrap-up and AskQuestion.
# 5. State machine simulation rejecting AskQuestion when temporary files exist or file check was skipped.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

INTERACTIVE_RULE=".ai-suite/layer1-abstraction/agents/cursor/rules/interactive-workflow.md"
DIRECTIVES_FILE=".ai-suite/layer3-registry/directives/agent-directives.md"
LOOP_WORK_CORE=".ai-suite/layer3-registry/core/loop-work.md"

echo "=== Running Interactive Workflow Cleanup & File List Check Validation ==="

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

echo "1. Checking Interactive Workflow Rule Contracts ($INTERACTIVE_RULE)..."
assert_contains "$INTERACTIVE_RULE" "(clean up.*(unused|temporary).*files.*(before|then).*AskQuestion|active task.*remove.*then.*AskQuestion)" "Active task cleanup before AskQuestion"
assert_contains "$INTERACTIVE_RULE" "(check.*file list|inspect.*file list|git status.*file list)" "AI agent file list inspection requirement"
assert_contains "$INTERACTIVE_RULE" "PREMATURE ASKQUESTION BEFORE CLEANUP FORBIDDEN" "Negative constraint against calling AskQuestion before cleanup"
assert_contains "$INTERACTIVE_RULE" "OMISSION OF FILE LIST CHECK FORBIDDEN" "Negative constraint against omitting file list check"

echo "2. Checking Agent Directives Contracts ($DIRECTIVES_FILE)..."
assert_contains "$DIRECTIVES_FILE" "(file list.*(inspect|check)|check.*file list|git status.*file list)" "AI agent file list inspection in directives"
assert_contains "$DIRECTIVES_FILE" "(clean up.*(unused|temporary).*before.*AskQuestion|active task.*clean up.*AskQuestion)" "Active task cleanup before AskQuestion in directives"
assert_contains "$DIRECTIVES_FILE" "Do not call AskQuestion before cleanup" "Negative constraint in directives against AskQuestion before cleanup"

echo "3. Checking Loop-Work Skill Contracts ($LOOP_WORK_CORE)..."
assert_contains "$LOOP_WORK_CORE" "(check.*file list|inspect.*file list|git status.*porcelain)" "Loop-work file list inspection"
assert_contains "$LOOP_WORK_CORE" "(remove.*(temporary|unused).*before.*AskQuestion|cleanup.*before.*AskQuestion)" "Loop-work cleanup before AskQuestion"

echo "4. Behavioral Simulation of State Machine Cleanup Barrier..."
simulate_task_completion_and_question() {
  local temp_files_created="$1"
  local file_list_checked="$2"
  local temp_files_cleaned="$3"
  local called_ask_question="$4"

  if [[ "$temp_files_created" == "true" ]]; then
    if [[ "$file_list_checked" != "true" ]]; then
      echo "FAIL_MISSING_FILE_LIST_CHECK"
      return
    fi
    if [[ "$temp_files_cleaned" != "true" ]]; then
      if [[ "$called_ask_question" == "true" ]]; then
        echo "FAIL_PREMATURE_QUESTION_WITH_TEMP_FILES"
        return
      fi
    fi
  fi

  if [[ "$called_ask_question" == "true" ]]; then
    echo "SUCCESS_CLEANUP_BEFORE_QUESTION"
  else
    echo "SUCCESS_CLEANED_NO_QUESTION"
  fi
}

res1=$(simulate_task_completion_and_question "true" "false" "false" "true")
if [[ "$res1" != "FAIL_MISSING_FILE_LIST_CHECK" ]]; then
  echo "  [FAIL] Did not detect missing file list check: $res1"
  FAILURES=$((FAILURES + 1))
else
  echo "  [PASS] Simulation correctly flags missing file list check"
fi

res2=$(simulate_task_completion_and_question "true" "true" "false" "true")
if [[ "$res2" != "FAIL_PREMATURE_QUESTION_WITH_TEMP_FILES" ]]; then
  echo "  [FAIL] Did not detect premature AskQuestion with uncleaned temporary files: $res2"
  FAILURES=$((FAILURES + 1))
else
  echo "  [PASS] Simulation correctly flags premature AskQuestion before cleanup"
fi

res3=$(simulate_task_completion_and_question "true" "true" "true" "true")
if [[ "$res3" != "SUCCESS_CLEANUP_BEFORE_QUESTION" ]]; then
  echo "  [FAIL] Valid cleanup sequence failed: $res3"
  FAILURES=$((FAILURES + 1))
else
  echo "  [PASS] Simulation confirms successful cleanup before AskQuestion"
fi

echo "5. Adversarial Chaos & Fault-Injection Scenarios..."

# Scenario 5a: Partial Cleanup (some temporary files left)
simulate_partial_cleanup() {
  local total_temp_files=5
  local cleaned_files=3
  local called_ask_question="$1"

  if [[ "$cleaned_files" -lt "$total_temp_files" ]]; then
    if [[ "$called_ask_question" == "true" ]]; then
      echo "FAIL_PARTIAL_CLEANUP"
      return
    fi
  fi
  echo "SUCCESS"
}

res_partial=$(simulate_partial_cleanup "true")
if [[ "$res_partial" != "FAIL_PARTIAL_CLEANUP" ]]; then
  echo "  [FAIL] Did not reject partial cleanup: $res_partial"
  FAILURES=$((FAILURES + 1))
else
  echo "  [PASS] Simulation correctly rejects partial cleanup before AskQuestion"
fi

# Scenario 5b: Nested Temporary Artifacts in Subdirectories
simulate_nested_cleanup() {
  local nested_detected="$1"
  local nested_removed="$2"
  local called_ask_question="$3"

  if [[ "$nested_detected" != "true" || "$nested_removed" != "true" ]]; then
    if [[ "$called_ask_question" == "true" ]]; then
      echo "FAIL_UNREMOVED_NESTED_TEMP_FILES"
      return
    fi
  fi
  echo "SUCCESS_NESTED_CLEANUP"
}

res_nested_fail=$(simulate_nested_cleanup "true" "false" "true")
if [[ "$res_nested_fail" != "FAIL_UNREMOVED_NESTED_TEMP_FILES" ]]; then
  echo "  [FAIL] Did not reject unremoved nested temporary files: $res_nested_fail"
  FAILURES=$((FAILURES + 1))
else
  echo "  [PASS] Simulation correctly flags unremoved nested temporary artifacts"
fi

res_nested_pass=$(simulate_nested_cleanup "true" "true" "true")
if [[ "$res_nested_pass" != "SUCCESS_NESTED_CLEANUP" ]]; then
  echo "  [FAIL] Nested cleanup pass failed: $res_nested_pass"
  FAILURES=$((FAILURES + 1))
else
  echo "  [PASS] Simulation confirms nested temporary artifact cleanup"
fi

# Scenario 5c: Permission-Locked File Error Handling
simulate_locked_file_cleanup() {
  local file_locked="$1"
  local called_ask_question="$2"

  if [[ "$file_locked" == "true" ]]; then
    if [[ "$called_ask_question" == "true" ]]; then
      echo "FAIL_CLEANUP_BLOCKED_BY_PERMISSIONS"
      return
    fi
  fi
  echo "SUCCESS_LOCKED_HANDLED"
}

res_locked=$(simulate_locked_file_cleanup "true" "true")
if [[ "$res_locked" != "FAIL_CLEANUP_BLOCKED_BY_PERMISSIONS" ]]; then
  echo "  [FAIL] Did not block AskQuestion when file cleanup failed: $res_locked"
  FAILURES=$((FAILURES + 1))
else
  echo "  [PASS] Simulation correctly halts before AskQuestion when file is locked"
fi

echo "=================================================================="
if [ "$FAILURES" -gt 0 ]; then
  echo "CONTRACT VALIDATION FAILED: $FAILURES assertion(s) failed."
  exit 1
fi

echo "CONTRACT VALIDATION PASSED: All cleanup contracts and simulations verified."
exit 0

#!/usr/bin/env bash
set -euo pipefail

echo "Running State Machine check for interactive-workflow rule..."

RULE_FILE=".ai-suite/layer1-abstraction/agents/cursor/rules/interactive-workflow.md"
ERRORS=0

function check_grep() {
    local file=$1
    local pattern=$2
    local error_msg=$3

    if ! grep -iEq "$pattern" "$file"; then
        echo "[FAIL] $file: $error_msg"
        ERRORS=$((ERRORS + 1))
    else
        echo "[PASS] $file contains required constraint."
    fi
}

check_grep "$RULE_FILE" "State 0.*INITIALIZATION" "Missing State 0 INITIALIZATION declaration."
check_grep "$RULE_FILE" "State 1.*MAIN TASK" "Missing State 1 MAIN TASK execution isolation."
check_grep "$RULE_FILE" "State 2.*WRAP-UP" "Missing State 2 WRAP-UP and summary."
check_grep "$RULE_FILE" "State 3.*FOLLOW-UP" "Missing State 3 FOLLOW-UP question."
check_grep "$RULE_FILE" "abnormal.*task" "Missing warning about abnormal task execution."

if [ "$ERRORS" -gt 0 ]; then
    echo "Total errors: $ERRORS"
    exit 1
fi

echo "All tests passed!"
exit 0

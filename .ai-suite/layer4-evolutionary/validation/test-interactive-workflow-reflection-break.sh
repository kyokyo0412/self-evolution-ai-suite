#!/usr/bin/env bash
set -euo pipefail

# test-interactive-workflow-reflection-break.sh
# Validates that the interactive-workflow rule correctly mandates breaking the loop for the Reflection Protocol.

echo "Running tests for interactive-workflow reflection break rule..."

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

check_grep "$RULE_FILE" "EXCEPTION for Reflection Protocol" "Missing explicit exception for Reflection Protocol."
check_grep "$RULE_FILE" "immediately break the interactive workflow loop" "Missing instruction to break the interactive workflow loop."
check_grep "$RULE_FILE" "do NOT loop back to call \`AskQuestion\`" "Missing instruction explicitly forbidding looping back to call AskQuestion."

if [ "$ERRORS" -gt 0 ]; then
    echo "Total errors: $ERRORS"
    exit 1
fi

echo "All tests passed!"
exit 0

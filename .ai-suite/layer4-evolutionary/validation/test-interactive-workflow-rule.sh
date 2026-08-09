#!/usr/bin/env bash
set -euo pipefail

# test-interactive-workflow-rule.sh
# Validates that the interactive-workflow rule correctly mandates separating text output from AskQuestion
# using a tool call (like a dummy Shell) to ensure rendering without consuming extra user requests.

echo "Running tests for interactive-workflow rule..."

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

check_grep "$RULE_FILE" "CRITICAL HARD BLOCK FOR FINAL OUTPUT" "Missing hard block for final AskQuestion output separation."
check_grep "$RULE_FILE" "call a minor tool.*render" "Missing instruction to call a minor tool to force UI rendering."
check_grep "$RULE_FILE" "bundle the final \\\`AskQuestion\\\` tool call in the same batch as the final task execution tools" "Missing negative constraint against bundling AskQuestion."
check_grep "$RULE_FILE" "Must not cost any extra Cursor included request" "Missing constraint about not costing extra requests."

if [ "$ERRORS" -gt 0 ]; then
    echo "Total errors: $ERRORS"
    exit 1
fi

echo "All tests passed!"
exit 0

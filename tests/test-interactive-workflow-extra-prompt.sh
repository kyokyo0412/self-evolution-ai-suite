#!/bin/bash

# Tests to ensure the interactive-workflow rule explicitly mandates
# that the "Other" option input is treated as a NEW TASK and executed fully.

set -e

SKILL_FILE_1="$HOME/.cursor/rules/cursor-suite-interactive-workflow.mdc"
SKILL_FILE_2=".ai-suite/layer1-abstraction/agents/cursor/rules/interactive-workflow.md"

check_skill_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "FAIL: $file not found!"
        exit 1
    fi
    
    if ! grep -q "NEW TASK" "$file"; then
        echo "FAIL: $file does not mandate treating the 'Other' input as a NEW TASK."
        exit 1
    fi
    
    if ! grep -q "execute the required actions" "$file"; then
        echo "FAIL: $file does not mandate executing the required actions for the 'Other' input."
        exit 1
    fi
    
    echo "PASS: $file mandates treating 'Other' input as a NEW TASK."
}

check_skill_file "$SKILL_FILE_1"
check_skill_file "$SKILL_FILE_2"

echo "All tests passed for interactive-workflow extra prompt requirements!"
exit 0

#!/bin/bash

# Tests to ensure the interactive-workflow rule explicitly mandates
# an execution summary before calling the AskQuestion tool.

set -e

SKILL_FILE_1="$HOME/.cursor/rules/cursor-suite-interactive-workflow.mdc"
SKILL_FILE_2=".ai-suite/layer1-abstraction/agents/cursor/rules/interactive-workflow.md"

check_skill_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "FAIL: $file not found!"
        exit 1
    fi
    
    # Check for keywords about summary
    if ! grep -qiE "detailed summary|execution summary|detailed report" "$file"; then
        echo "FAIL: $file does not mandate an execution summary before AskQuestion."
        exit 1
    fi
    
    # Check if the text explicitly couples summary with AskQuestion
    if ! grep -qiE "summary.*AskQuestion" "$file" && ! grep -qiE "AskQuestion.*summary" "$file"; then
        echo "FAIL: $file does not explicitly connect the summary output to the AskQuestion tool."
        exit 1
    fi
    
    echo "PASS: $file mandates a detailed summary."
}

check_skill_file "$SKILL_FILE_1"
check_skill_file "$SKILL_FILE_2"

echo "All tests passed for interactive-workflow summary requirements!"
exit 0

#!/bin/bash

# Tests to ensure the interactive-workflow rule explicitly mandates
# chat output before calling the AskQuestion tool.

set -e

SKILL_FILE_1="$HOME/.cursor/rules/cursor-suite-interactive-workflow.mdc"
SKILL_FILE_2=".ai-suite/layer1-abstraction/agents/cursor/rules/interactive-workflow.md"
SKILL_FILE_3=".cursor/skills/interactive-workflow/SKILL.md"

check_skill_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "FAIL: $file not found!"
        exit 1
    fi
    
    # Check for mandate to output text before AskQuestion
    if ! grep -qiE "(explicitly.*output.*chat window|must not.*askquestion.*until.*text)" "$file"; then
        echo "FAIL: $file does not explicitly forbid AskQuestion before textual output."
        exit 1
    fi
    
    echo "PASS: $file mandates chat output before AskQuestion."
}

check_skill_file "$SKILL_FILE_1"
check_skill_file "$SKILL_FILE_2"
if [ -f "$SKILL_FILE_3" ]; then check_skill_file "$SKILL_FILE_3"; fi

echo "All tests passed for interactive-workflow chat output requirements!"
exit 0

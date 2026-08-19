#!/bin/bash

# Tests to ensure the interactive-workflow rules explicitly mandate
# waiting for completion, printing output, and double confirming before AskQuestion.

set -e

# Support testing against local project rules and installed rules
SKILL_FILE_1="$HOME/.cursor/rules/cursor-suite-interactive-workflow.mdc"
SKILL_FILE_2=".ai-suite/layer1-abstraction/agents/cursor/rules/interactive-workflow.md"
SKILL_FILE_3=".cursor/skills/interactive-workflow/SKILL.md"

check_skill_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "WARNING: $file not found, skipping."
        return 0
    fi
    
    if ! grep -qi "wait.*main task.*done" "$file" && ! grep -qi "wait.*task.*complete" "$file" && ! grep -qi "wait.*task.*finish" "$file"; then
        echo "FAIL: $file does not mandate waiting for the main task to be done."
        exit 1
    fi
    
    if ! grep -qi "print all output" "$file" && ! grep -qi "print.*output.*chat" "$file"; then
        echo "FAIL: $file does not mandate printing all output in the chat window."
        exit 1
    fi

    if ! grep -qi "double confirm" "$file"; then
        echo "FAIL: $file does not mandate double confirming the task is done."
        exit 1
    fi
    
    echo "PASS: $file mandates waiting, printing output, and double confirming."
}

if [ -f "$SKILL_FILE_1" ]; then check_skill_file "$SKILL_FILE_1"; fi
if [ -f "$SKILL_FILE_2" ]; then check_skill_file "$SKILL_FILE_2"; fi
if [ -f "$SKILL_FILE_3" ]; then check_skill_file "$SKILL_FILE_3"; fi

echo "All tests passed for interactive-workflow double confirm requirements!"
exit 0
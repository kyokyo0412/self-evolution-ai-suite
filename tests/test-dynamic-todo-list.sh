#!/usr/bin/env bash
set -euo pipefail

echo "Running acceptance test for dynamic todo-list support..."

TDD_FILE=".ai-suite/layer3-registry/core/tdd-team.md"
AUTO_FILE=".ai-suite/layer3-registry/core/autonomous-team.md"

check_dynamic_todo() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "FAILED: $file does not exist."
        exit 1
    fi

    # Check for dynamic todo-list update instructions upon issues
    if ! grep -qi "dynamic.*todo" "$file" && ! grep -qi "update.*todo.*issue" "$file" && ! grep -qi "found any issues.*update the To-Do list" "$file"; then
        echo "FAILED: $file does not explicitly mention dynamic todo-list updates upon finding issues."
        exit 1
    fi

    # Check for continuing with the new todo-list
    if ! grep -qi "continue.*new.*todo" "$file" && ! grep -qi "continue running the new To-Do list" "$file"; then
        echo "FAILED: $file does not instruct to continue running the new todo-list."
        exit 1
    fi
}

check_dynamic_todo "$TDD_FILE"
check_dynamic_todo "$AUTO_FILE"

echo "PASSED: Both files support dynamic todo-lists."
exit 0

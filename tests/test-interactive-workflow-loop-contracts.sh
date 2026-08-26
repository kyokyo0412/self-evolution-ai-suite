#!/bin/bash

# Tests to ensure the interactive-workflow rule explicitly mandates:
# 1. Continuous multi-turn loop persistence across ALL task iterations.
# 2. Treating any "Other" option input as an active task following Step 1 -> Step 2 -> Step 3.
# 3. Mandating AskQuestion after every "Other" task completion.
# 4. Forbidding ending the turn after "Other" task completion without AskQuestion.
# 5. Clarifying that Step 0 is not re-prompted when already active in the loop.

set -e

SKILL_FILE_1="$HOME/.cursor/rules/cursor-suite-interactive-workflow.mdc"
SKILL_FILE_2=".ai-suite/layer1-abstraction/agents/cursor/rules/interactive-workflow.md"

check_skill_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "FAIL: $file not found!"
        exit 1
    fi
    
    # 1. Continuous loop persistence across all iterations
    if ! grep -qiE "(continuous|persistent|all task iterations|every task iteration|loop invariant)" "$file"; then
        echo "FAIL: $file does not mandate continuous loop persistence across all iterations."
        exit 1
    fi
    
    # 2. Mandate AskQuestion after each task from 'Other'
    if ! grep -qiE "(always use AskQuestion|always call AskQuestion|always.*AskQuestion.*after each task|proceed to Step 2 and.*3|Step 1 -> Step 2 -> Step 3)" "$file"; then
        echo "FAIL: $file does not mandate invoking AskQuestion after each task completed from 'Other'."
        exit 1
    fi
    
    # 3. Negative constraint: forbidden from ending turn or stopping after 'Other' without AskQuestion
    if ! grep -qiE "(MUST NOT.*stop.*without.*AskQuestion|MUST NOT.*end.*turn.*without.*AskQuestion|forbidden from ending.*turn.*after.*Other)" "$file"; then
        echo "FAIL: $file does not include strict negative constraint forbidding turn end without AskQuestion after 'Other' task."
        exit 1
    fi

    # 4. Skip Step 0 on re-entry
    if ! grep -qiE "(skip Step 0|do not re-prompt Step 0|already active|already enabled)" "$file"; then
        echo "FAIL: $file does not clarify skipping Step 0 when interactive mode is already active."
        exit 1
    fi
    
    echo "PASS: $file satisfies all interactive-workflow continuous loop contract requirements."
}

if [ -f "$SKILL_FILE_1" ]; then
    check_skill_file "$SKILL_FILE_1"
fi
check_skill_file "$SKILL_FILE_2"

echo "All tests passed for interactive-workflow continuous loop requirements!"
exit 0

#!/usr/bin/env bash
set -euo pipefail

# test-core-rules-evolution.sh
# Validates that the core rules files contain the newly enforced principles.

echo "Running tests for core-rules-evolution..."

# Define paths to the core rules files
AGENT_DIRECTIVES=".ai-suite/layer3-registry/directives/agent-directives.md"
PROD_SAFETY=".ai-suite/layer3-registry/safety/production-safety.md"
VISIBILITY=".ai-suite/layer3-registry/directives/step-action-visibility.md"

ERRORS=0

function check_grep() {
    local file=$1
    local pattern=$2
    local error_msg=$3

    if ! grep -iEq "$pattern" "$file"; then
        echo "[FAIL] $file: $error_msg"
        ERRORS=$((ERRORS + 1))
    else
        echo "[PASS] $file contains '$pattern'"
    fi
}

# 1. Deep Comprehension & VLLM-Based Reasoning
check_grep "$AGENT_DIRECTIVES" "Deep Comprehension" "Missing 'Deep Comprehension' requirement."
check_grep "$AGENT_DIRECTIVES" "extracts? intent.*refines? prior to execution" "Missing exact instructions to extract intent and refine."
check_grep "$VISIBILITY" "VLLM-Based Reasoning|chain-of-thought|Chain of Thought" "Missing 'VLLM-Based Reasoning' or deep chain-of-thought requirement."

# 2. Autonomous Resilience
check_grep "$AGENT_DIRECTIVES" "Autonomous Resilience" "Missing 'Autonomous Resilience' section."
check_grep "$AGENT_DIRECTIVES" "Do not stall or prompt the user.*obstacle" "Missing instruction to avoid stalling/prompting user on obstacles."
check_grep "$AGENT_DIRECTIVES" "alternative strategies.*autonomously" "Missing instruction to try alternative strategies autonomously."

# 3. Continuous Self-Evolution
check_grep "$AGENT_DIRECTIVES" "Self-Evolution" "Missing 'Self-Evolution' concept."
check_grep "$AGENT_DIRECTIVES" "adapt and refine.*prompt/skill suite based on task outcomes" "Missing rule to adapt/refine based on feedback."

# 4. Safety & Non-Destruction
check_grep "$PROD_SAFETY" "Never run \`git commit\`, \`git push\`, or modifying deployment environments without explicit permission" "Missing strict 'git commit/push' and deployment rule."
check_grep "$PROD_SAFETY" "Never execute destructive actions in production environments" "Missing strict production environment destruction rule."

# 5. User Visibility
check_grep "$VISIBILITY" "User Visibility" "Missing 'User Visibility' heading/requirement."
check_grep "$VISIBILITY" "Every plan, decision, architectural design, and implementation step must be logged and readable by the user" "Missing exact user logging visibility requirement."

if [ "$ERRORS" -gt 0 ]; then
    echo "Total errors: $ERRORS"
    exit 1
fi

echo "All core-rules-evolution tests passed!"
exit 0

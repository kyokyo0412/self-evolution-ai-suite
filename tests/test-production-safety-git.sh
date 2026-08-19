#!/usr/bin/env bash
set -euo pipefail

echo "Running Production Safety - Git Constraint Test..."

SAFETY_FILE=".ai-suite/layer3-registry/safety/production-safety.md"

if [[ ! -f "$SAFETY_FILE" ]]; then
    echo "FAIL: $SAFETY_FILE not found."
    exit 1
fi

if ! grep -q "\`git commit\`" "$SAFETY_FILE"; then
    echo "FAIL: Missing \`git commit\` constraint in Refuse-by-Default Patterns -> Git."
    exit 1
fi

if ! grep -q "NEVER autonomously commit changes to the repository" "$SAFETY_FILE"; then
    echo "FAIL: Missing explicit instruction to NEVER autonomously commit changes."
    exit 1
fi

echo "PASS: Production Safety Git constraints are verified."
exit 0

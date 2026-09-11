#!/bin/bash
set -euo pipefail
set -e

SKILL_FILE=".ai-suite/layer3-registry/core/feature-doc.md"

echo "Running Implementation Test..."

if [ ! -f "$SKILL_FILE" ]; then
    echo "FAIL: Skill file $SKILL_FILE does not exist."
    exit 1
fi

REQUIRED_ELEMENTS=(
    "name: feature-doc"
    "description:"
    "triggers:"
    "# Feature Documentation Generator"
    "aigen_doc"
    "Entry Points (Ingress)"
    "Control & Data Flow (The Call Chain)"
    "Component Collaboration (Inter-process Communication)"
    "State Mutations (Persistence)"
    "Error Handling"
    "Observability"
    "exhaustively"
)

for element in "${REQUIRED_ELEMENTS[@]}"; do
    if ! grep -qF "$element" "$SKILL_FILE"; then
        echo "FAIL: Missing required element: '$element'"
        exit 1
    fi
done

echo "SUCCESS: Implementation test passed."

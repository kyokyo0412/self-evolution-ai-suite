#!/bin/bash
set -euo pipefail
set -e

FEATURE_FILE=".ai-suite/tests/feature-doc/feature_doc.feature"

echo "Validating Requirements..."

if [ ! -f "$FEATURE_FILE" ]; then
    echo "ERROR: Feature file not found at $FEATURE_FILE"
    exit 1
fi

# Check for required constraints in the feature file
REQUIRED_TERMS=("feature_doc" "aigen_doc" "Entry Points" "Control & Data Flow" "Component Collaboration" "State Mutations" "without asking for user input")

for term in "${REQUIRED_TERMS[@]}"; do
    if ! grep -qi "$term" "$FEATURE_FILE"; then
        echo "ERROR: Missing required term '$term' in $FEATURE_FILE"
        exit 1
    fi
done

echo "Requirements Validation Passed."

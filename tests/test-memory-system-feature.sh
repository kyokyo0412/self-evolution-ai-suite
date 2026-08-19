#!/bin/bash
set -e

FEATURE_FILE="tests/memory-system.feature"

if [ ! -f "$FEATURE_FILE" ]; then
    echo "Error: $FEATURE_FILE does not exist."
    exit 1
fi

# Basic validation: check for required Gherkin keywords
for keyword in "Feature:" "Scenario:" "Given" "When" "Then"; do
    if ! grep -q "$keyword" "$FEATURE_FILE"; then
        echo "Error: Missing keyword '$keyword' in $FEATURE_FILE"
        exit 1
    fi
done

echo "Feature file validation passed."
exit 0

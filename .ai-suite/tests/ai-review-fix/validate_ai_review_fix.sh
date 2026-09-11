#!/bin/bash
set -euo pipefail

FILE="./.ai-suite/layer3-registry/core/ai-review-fix.md"

if [ ! -f "$FILE" ]; then
    echo "Error: $FILE not found."
    exit 1
fi

CONTENT=$(cat "$FILE")

# Check for deep code review requirement
if ! echo "$CONTENT" | grep -qi "review all related code"; then
    echo "Error: Missing requirement to review all related code."
    exit 1
fi

# Check for false issue handling
if ! echo "$CONTENT" | grep -qi "false issue"; then
    echo "Error: Missing requirement to handle false issues."
    exit 1
fi

# Check for detailed reason in records file
if ! echo "$CONTENT" | grep -qi "reason.*analysis.*reply comment"; then
    echo "Error: Missing requirement to write detailed reason/analysis in the reply comment."
    exit 1
fi

# Check for true issue handling
if ! echo "$CONTENT" | grep -qi "true issue"; then
    echo "Error: Missing requirement to handle true issues."
    exit 1
fi

echo "Validation passed: All requirements are present in the skill definition."
exit 0

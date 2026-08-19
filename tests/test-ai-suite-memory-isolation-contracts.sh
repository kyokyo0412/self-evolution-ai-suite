#!/bin/bash
set -e

CONTRACT_FILE="tests/ai-suite-memory-isolation-contracts.md"

if [ ! -f "$CONTRACT_FILE" ]; then
    echo "Error: $CONTRACT_FILE does not exist."
    exit 1
fi

for keyword in ".ai-memory" "memory.sh" "core.sh" "\.gitignore" "ai-suite enable"; do
    if ! grep -q -e "$keyword" "$CONTRACT_FILE"; then
        echo "Error: Missing expected contract detail '$keyword' in $CONTRACT_FILE"
        exit 1
    fi
done

echo "Contract validation passed."
exit 0

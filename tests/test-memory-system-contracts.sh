#!/bin/bash
set -e

CONTRACT_FILE="tests/memory-system-contracts.md"

if [ ! -f "$CONTRACT_FILE" ]; then
    echo "Error: $CONTRACT_FILE does not exist."
    exit 1
fi

# Validate that the contract defines the required components
for keyword in "Memory Storage Location" "Memory Operations" "Evolution Integration" "Isolation"; do
    if ! grep -q -e "$keyword" "$CONTRACT_FILE"; then
        echo "Error: Missing section '$keyword' in $CONTRACT_FILE"
        exit 1
    fi
done

# Validate specific paths and functions
for keyword in ".ai-memory/" "ai_memory_save_index" "ai_memory_save_task" "--exclude-memory" "ai_memory_save_important" "ai_memory_save_layer" "ai_memory_append_timeline"; do
    if ! grep -q -e "$keyword" "$CONTRACT_FILE"; then
        echo "Error: Missing expected contract detail '$keyword' in $CONTRACT_FILE"
        exit 1
    fi
done

echo "Contract validation passed."
exit 0

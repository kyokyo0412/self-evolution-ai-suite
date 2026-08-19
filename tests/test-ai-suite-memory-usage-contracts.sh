#!/bin/bash
set -e

CONTRACT_FILE="tests/ai-suite-memory-usage-contracts.md"

if [ ! -f "$CONTRACT_FILE" ]; then
    echo "Error: $CONTRACT_FILE does not exist."
    exit 1
fi

# Validate that the contract defines the required components
for keyword in "Core Library Modification" "Memory System Section Content" "Agent Prompts"; do
    if ! grep -q -e "$keyword" "$CONTRACT_FILE"; then
        echo "Error: Missing section '$keyword' in $CONTRACT_FILE"
        exit 1
    fi
done

# Validate specific paths and functions
for keyword in "generate_markdown_block" "\.ai-suite/layer2-cognitive/memory/core.sh" "### Memory System" "\$agent_name"; do
    if ! grep -q -e "$keyword" "$CONTRACT_FILE"; then
        echo "Error: Missing expected contract detail '$keyword' in $CONTRACT_FILE"
        exit 1
    fi
done

echo "Contract validation passed."
exit 0

#!/usr/bin/env bash
set -euo pipefail

# Contract test: check if the defined bash functions are declared in memory.sh
# Check if the prompt generation script includes the keywords.

MEMORY_SH=".ai-suite/layer2-cognitive/memory/memory.sh"
CORE_SH=".ai-suite/layer2-cognitive/memory/core.sh"

echo "Running contract test..."

if ! grep -q "ai_memory_summary()" "$MEMORY_SH"; then
    echo "Contract failed: ai_memory_summary() not found in $MEMORY_SH"
    exit 1
fi

if ! grep -q "ai_memory_search()" "$MEMORY_SH"; then
    echo "Contract failed: ai_memory_search() not found in $MEMORY_SH"
    exit 1
fi

if ! grep -q "ai_memory_summary" "$CORE_SH"; then
    echo "Contract failed: ai_memory_summary instruction not found in $CORE_SH"
    exit 1
fi

if ! grep -q "ai_memory_search" "$CORE_SH"; then
    echo "Contract failed: ai_memory_search instruction not found in $CORE_SH"
    exit 1
fi

echo "All contracts passed!"
exit 0

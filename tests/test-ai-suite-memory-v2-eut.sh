#!/usr/bin/env bash
set -euo pipefail

export AI_SUITE_DOMAIN=""
export SUITE_DIR="$(pwd)/.ai-suite"
export TEST_AGENT="test_memory_agent"
export PROJECT_MEMORY_DIR="$(pwd)/.ai-memory"
export GLOBAL_MEMORY_DIR="$HOME/.ai-suite/memory"

source .ai-suite/layer2-cognitive/memory/core.sh
source .ai-suite/layer2-cognitive/memory/memory.sh

echo "Setting up test data..."
ai_memory_clean "$TEST_AGENT"
ai_memory_init "$TEST_AGENT"

# Populate some memories
ai_memory_save_layer "$TEST_AGENT" "architecture" "The system uses a Postgres DB."
ai_memory_save_task "$TEST_AGENT" "123" "Migrated DB to Postgres."
ai_memory_append_timeline "$TEST_AGENT" "Started testing"
ai_memory_save_important "$TEST_AGENT" "Always test"

echo "--- Testing ai_memory_summary ---"
summary_out=$(ai_memory_summary "$TEST_AGENT")
echo "$summary_out"

if ! echo "$summary_out" | grep -q "architecture"; then
    echo "FAILED: Summary did not include layers (architecture)."
    exit 1
fi

if ! echo "$summary_out" | grep -q "123"; then
    echo "FAILED: Summary did not include tasks (123)."
    exit 1
fi

if ! echo "$summary_out" | grep -q "timeline"; then
    echo "FAILED: Summary did not indicate timeline exists."
    exit 1
fi

echo "--- Testing ai_memory_search ---"
search_out=$(ai_memory_search "$TEST_AGENT" "Postgres")
echo "$search_out"

if ! echo "$search_out" | grep -q "architecture.md"; then
    echo "FAILED: Search did not find Postgres in architecture layer."
    exit 1
fi

if ! echo "$search_out" | grep -q "123.md"; then
    echo "FAILED: Search did not find Postgres in task 123."
    exit 1
fi

echo "All tests passed!"
ai_memory_clean "$TEST_AGENT"
exit 0

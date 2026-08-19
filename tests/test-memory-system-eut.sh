#!/bin/bash
set -e

# Setup test environment
TEST_SUITE_DIR="/tmp/ai-suite-memory-test-$$"
mkdir -p "$TEST_SUITE_DIR/.ai-suite/layer2-cognitive/memory"

# Copy core lib if exists, or create dummy
if [ -f ".ai-suite/layer2-cognitive/memory/core.sh" ]; then
    cp ".ai-suite/layer2-cognitive/memory/core.sh" "$TEST_SUITE_DIR/.ai-suite/layer2-cognitive/memory/"
else
    echo "info() { echo \"\$@\"; }" > "$TEST_SUITE_DIR/.ai-suite/layer2-cognitive/memory/core.sh"
    echo "error() { echo \"\$@\" >&2; }" >> "$TEST_SUITE_DIR/.ai-suite/layer2-cognitive/memory/core.sh"
fi

# Source the memory library
cp ".ai-suite/layer2-cognitive/memory/memory.sh" "$TEST_SUITE_DIR/.ai-suite/layer2-cognitive/memory/"
MEMORY_LIB="$TEST_SUITE_DIR/.ai-suite/layer2-cognitive/memory/memory.sh"

source "$MEMORY_LIB"

# Test 1: Initialize memory
ai_memory_init "test_agent"
if [ ! -d "$TEST_SUITE_DIR/.ai-memory/test_agent/index" ]; then
    echo "Error: index directory not created."
    exit 1
fi

# Test 2: Save and load index memory
ai_memory_save_index "test_agent" "high-level" "Project overview"
INDEX_CONTENT=$(ai_memory_load_index "test_agent" "high-level")
if [ "$INDEX_CONTENT" != "Project overview" ]; then
    echo "Error: Index memory content mismatch. Got: $INDEX_CONTENT"
    exit 1
fi

# Test 3: Save and load task memory
ai_memory_save_task "test_agent" "task-123" "Task details"
# Wait 1 second to ensure different timestamp if needed, but we use task_id in filename
TASK_FILES=$(ai_memory_list_tasks "test_agent")
if [[ "$TASK_FILES" != *"task-123"* ]]; then
    echo "Error: Task not found in list."
    exit 1
fi

# Test 4: Mask memory
ai_memory_mask "test_agent" "on"
MASKED_CONTENT=$(ai_memory_load_index "test_agent" "high-level")
if [ -n "$MASKED_CONTENT" ]; then
    echo "Error: Memory should be masked (empty), but got: $MASKED_CONTENT"
    exit 1
fi
ai_memory_mask "test_agent" "off"

# Test 5: Important Memory
ai_memory_save_important "test_agent" "Always check production safety"
IMPORTANT_CONTENT=$(ai_memory_load_important "test_agent")
if [ "$IMPORTANT_CONTENT" != "Always check production safety" ]; then
    echo "Error: Important memory content mismatch. Got: $IMPORTANT_CONTENT"
    exit 1
fi

# Test 6: Layered Memory
ai_memory_save_layer "test_agent" "architecture" "System is microservices"
ai_memory_save_layer "test_agent" "components" "Auth, DB, API"
LAYERS=$(ai_memory_list_layers "test_agent")
if [[ "$LAYERS" != *"architecture"* ]] || [[ "$LAYERS" != *"components"* ]]; then
    echo "Error: Layers not found in list. Got: $LAYERS"
    exit 1
fi
LAYER_CONTENT=$(ai_memory_load_layer "test_agent" "architecture")
if [ "$LAYER_CONTENT" != "System is microservices" ]; then
    echo "Error: Layer memory content mismatch. Got: $LAYER_CONTENT"
    exit 1
fi

# Test 7: Timeline Memory
ai_memory_append_timeline "test_agent" "Started the task"
ai_memory_append_timeline "test_agent" "Analyzed the codebase"
TIMELINE_CONTENT=$(ai_memory_read_timeline "test_agent")
if [[ "$TIMELINE_CONTENT" != *"Started the task"* ]] || [[ "$TIMELINE_CONTENT" != *"Analyzed the codebase"* ]]; then
    echo "Error: Timeline memory content mismatch. Got: $TIMELINE_CONTENT"
    exit 1
fi

# Test 8: Clean memory
ai_memory_clean "test_agent"
if [ -d "$TEST_SUITE_DIR/.ai-memory/test_agent/index" ]; then
    echo "Error: Memory directory should be cleaned."
    exit 1
fi

echo "All memory tests passed."
rm -rf "$TEST_SUITE_DIR"
exit 0

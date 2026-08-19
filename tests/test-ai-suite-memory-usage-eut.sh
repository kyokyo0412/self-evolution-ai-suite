#!/bin/bash
set -e

source .ai-suite/layer2-cognitive/memory/core.sh

TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$TEST_DIR/meta"
mkdir -p "$TEST_DIR/skills"
mkdir -p "$TEST_DIR/core/lib"

# Create a dummy skill
echo "name: dummy-skill" > "$TEST_DIR/skills/dummy.md"
echo "description: A dummy skill" >> "$TEST_DIR/skills/dummy.md"

# Create dummy meta files
echo "dummy safety rule" > "$TEST_DIR/meta/production-safety.md"

# Copy memory.sh to test dir to test auto-initialization
mkdir -p "$TEST_DIR/.ai-suite/layer4-evolutionary"; cp -r .ai-suite/layer4-evolutionary/validation "$TEST_DIR/.ai-suite/layer4-evolutionary/validation"; cp .ai-suite/layer2-cognitive/memory/memory.sh "$TEST_DIR/core/lib/memory.sh"

# Mock HOME for global memory path testing
export HOME="$TEST_DIR/home"
mkdir -p "$HOME"

# Generate markdown block
output=$(generate_markdown_block "$TEST_DIR" "$TEST_DIR" "test-agent" "<!-- start -->" "<!-- end -->")

if ! echo "$output" | grep -q "### Memory System"; then
    echo "Error: '### Memory System' not found in generated output."
    echo "Output:"
    echo "$output"
    exit 1
fi

if ! echo "$output" | grep -q "\.ai-memory/test-agent/index/"; then
    echo "Error: agent-specific project memory index path not found in generated output."
    exit 1
fi

if ! echo "$output" | grep -q "\~/\.ai-suite/memory/test-agent/tasks/"; then
    echo "Error: agent-specific global memory tasks path not found in generated output."
    exit 1
fi

if ! echo "$output" | grep -q "\.ai-suite/layer2-cognitive/memory/memory.sh"; then
    echo "Error: memory.sh reference not found in generated output."
    exit 1
fi

# Test Cursor adapter
source .ai-suite/layer1-abstraction/agents/cursor/adapter.sh
CURSORRULES="$TEST_DIR/.cursorrules"
_append_cursorrules_block "$CURSORRULES" "$TEST_DIR" "$TEST_DIR"

if ! grep -q "Memory System:" "$CURSORRULES"; then
    echo "Error: 'Memory System:' not found in generated cursorrules."
    cat "$CURSORRULES"
    exit 1
fi

# Test auto-initialization via agent_install_project
export SUITE_DIR="$TEST_DIR/.ai-suite"
cp -r .ai-suite/* "$TEST_DIR/.ai-suite/"; agent_install_project "$TEST_DIR/.ai-suite" "$TEST_DIR"
if [ ! -d "$TEST_DIR/.ai-memory/cursor/index" ]; then
    echo "Error: Project memory index directory not auto-initialized by adapter."
    exit 1
fi
if [ ! -d "$HOME/.ai-suite/memory/cursor/tasks" ]; then
    echo "Error: Global memory tasks directory not auto-initialized by adapter."
    exit 1
fi


if ! grep -q "\.ai-memory/cursor/index/" "$CURSORRULES"; then
    echo "Error: project memory index path not found in generated cursorrules."
    exit 1
fi

if ! grep -q "\~/\.ai-suite/memory/cursor/tasks/" "$CURSORRULES"; then
    echo "Error: global memory tasks path not found in generated cursorrules."
    exit 1
fi

if ! grep -q "\.ai-suite/layer2-cognitive/memory/memory.sh" "$CURSORRULES"; then
    echo "Error: memory.sh reference not found in generated cursorrules."
    exit 1
fi

# Test Global Cursor adapter
GLOBAL_CURSORRULES="$HOME/.cursorrules"
_append_cursorrules_global_block "$TEST_DIR"

if ! grep -q "Memory System:" "$GLOBAL_CURSORRULES"; then
    echo "Error: 'Memory System:' not found in global cursorrules."
    exit 1
fi

# Test memory.sh auto-initialization
# Set SUITE_DIR to simulate project directory
export SUITE_DIR="$TEST_DIR/.ai-suite"
source .ai-suite/layer2-cognitive/memory/memory.sh

ai_memory_init "test-agent"

if [ ! -d "$TEST_DIR/.ai-memory/test-agent/index" ]; then
    echo "Error: Project memory index directory not auto-initialized."
    exit 1
fi

if [ ! -d "$HOME/.ai-suite/memory/test-agent/tasks" ]; then
    echo "Error: Global memory tasks directory not auto-initialized."
    exit 1
fi

echo "EUT passed."
exit 0

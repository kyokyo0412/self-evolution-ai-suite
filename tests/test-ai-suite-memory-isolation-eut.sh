#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SUITE_DIR="$ROOT_DIR/.ai-suite"
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

echo "Testing memory isolation..."

# 1. Test .gitignore
if ! grep -q ".ai-memory" "$ROOT_DIR/.gitignore"; then
    echo "Error: .ai-memory not in .gitignore"
    exit 1
fi

# 2. Test memory.sh
# We will source memory.sh and see where it initializes
TEST_SUITE_DIR="$TEST_DIR/.ai-suite"
mkdir -p "$TEST_SUITE_DIR"
cp -r "$SUITE_DIR/layer1-abstraction" "$TEST_SUITE_DIR/layer1-abstraction" || true
cp -r "$SUITE_DIR/layer2-cognitive" "$TEST_SUITE_DIR/layer2-cognitive" || true
cp -r "$SUITE_DIR/layer3-registry" "$TEST_SUITE_DIR/layer3-registry" || true

SUITE_DIR="$TEST_SUITE_DIR" source "$TEST_SUITE_DIR/layer2-cognitive/memory/memory.sh"
ai_memory_init "test_agent"

if [ -d "$TEST_SUITE_DIR/memory" ]; then
    echo "Error: Memory was created inside .ai-suite/memory"
    exit 1
fi

if [ ! -d "$TEST_DIR/.ai-memory/test_agent/index" ]; then
    echo "Error: Memory was NOT created in .ai-memory"
    exit 1
fi

# 3. Check system prompts
for file in "$SUITE_DIR"/layer1-abstraction/agents/*/adapter.sh "$SUITE_DIR"/layer2-cognitive/memory/core.sh; do
    if [ -f "$file" ]; then
        if grep -qi "memory" "$file"; then
            # If we find .ai-suite/memory, it MUST be ~/.ai-suite/memory
            if grep "\.ai-suite/memory" "$file" | grep -v "\~/\.ai-suite/memory" > /dev/null; then
                if ! echo "$file" | grep -q "memory.sh"; then
                    echo "Error: Found hardcoded .ai-suite/memory in $file"
                    exit 1
                fi
            fi
            if ! grep -q "\.ai-memory" "$file"; then
                echo "Error: $file does not instruct to use .ai-memory"
                exit 1
            fi
        fi
    fi
done

echo "Memory Isolation EUT Passed"
exit 0

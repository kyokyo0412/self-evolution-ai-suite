#!/bin/bash
set -e

echo "Running TDD Team and AI Expert Quality/Efficiency Tests..."

TDD_TEAM=".ai-suite/layer3-registry/core/tdd-team.md"
AI_EXPERT=".ai-suite/layer2-cognitive/meta-compiler/prompt-compiler.md"
if [ ! -f "$AI_EXPERT" ]; then
    AI_EXPERT=".ai-suite/layer2-cognitive/meta-compiler/ai-expert.md"
fi

if [ ! -f "$TDD_TEAM" ]; then
    echo "ERROR: $TDD_TEAM does not exist."
    exit 1
fi

if [ ! -f "$AI_EXPERT" ]; then
    echo "ERROR: $AI_EXPERT does not exist."
    exit 1
fi

echo "Checking tdd-team.md for 'Maximize parallel tool calls'..."
if ! grep -iq "Maximize parallel tool calls" "$TDD_TEAM"; then
    echo "ERROR: tdd-team.md does not enforce parallel tool calls."
    exit 1
fi

echo "Checking tdd-team.md for 'ReadLints' or 'linter checks'..."
if ! grep -iqE "ReadLints|linter checks" "$TDD_TEAM"; then
    echo "ERROR: tdd-team.md does not enforce linter checks."
    exit 1
fi

echo "Checking ai-expert.md for 'parallel tool calls'..."
if ! grep -iq "parallel tool calls" "$AI_EXPERT"; then
    echo "ERROR: ai-expert.md does not enforce parallel tool calls in optimized prompts."
    exit 1
fi

echo "Checking ai-expert.md for 'quality checks' or 'linter checks'..."
if ! grep -iqE "quality checks|linter checks" "$AI_EXPERT"; then
    echo "ERROR: ai-expert.md does not enforce quality/linter checks in optimized prompts."
    exit 1
fi

echo "SUCCESS: AI Suite Quality and Efficiency contracts verified."
exit 0

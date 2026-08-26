#!/usr/bin/env bash
set -e

echo "Running Codex Support EUT..."

# Setup a temporary project directory
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

# Copy the suite to a separate directory
SUITE_DIR=$(mktemp -d)
trap 'rm -rf "$SUITE_DIR"' EXIT
cp -r . "$SUITE_DIR/ai-suite"

cd "$TEST_DIR"

# Test 1: Enable Codex in project scope
echo "Testing enable codex..."
bash "$SUITE_DIR/ai-suite/ai-suite" enable --agent codex --scope project --project "$TEST_DIR"

if [[ ! -f "AGENTS.md" ]]; then
  echo "Error: AGENTS.md was not created."
  exit 1
fi

if [[ ! -d ".codex/skills" ]]; then
  echo "Error: .codex/skills directory was not created."
  exit 1
fi

if ! grep -q "<!-- ai-suite:start -->" "AGENTS.md"; then
  echo "Error: ai-suite block not found in AGENTS.md."
  exit 1
fi

# Test 2: Disable Codex in project scope
echo "Testing disable codex..."
bash "$SUITE_DIR/ai-suite/ai-suite" disable --agent codex --scope project --project "$TEST_DIR"

if grep -q "<!-- ai-suite:start -->" "AGENTS.md"; then
  echo "Error: ai-suite block was not removed from AGENTS.md."
  exit 1
fi

if [[ -d ".codex/skills" ]]; then
  echo "Error: .codex/skills directory was not removed."
  exit 1
fi

echo "Codex Support EUT passed."
exit 0

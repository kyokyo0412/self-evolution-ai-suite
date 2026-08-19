#!/usr/bin/env bash
set -euo pipefail

echo "[TEST] Validating Auto-Evolution Directive Contracts..."

assert_contains() {
  local file="$1"
  local text="$2"
  if ! grep -q "$text" "$file"; then
    echo "FAIL: $file is missing '$text'"
    exit 1
  fi
}

export TEST_WS=$(mktemp -d)
trap 'rm -rf "$TEST_WS"' EXIT
cd "$TEST_WS"

mkdir -p .cursor .vscode .claude
touch .cursorrules CLAUDE.md

source "$OLDPWD/.ai-suite/layer1-abstraction/_portable.sh"
source "$OLDPWD/.ai-suite/layer2-cognitive/memory/core.sh"

echo "Testing Cursor adapter..."
source "$OLDPWD/.ai-suite/layer1-abstraction/agents/cursor/adapter.sh"
agent_install_project "$OLDPWD/.ai-suite" "$TEST_WS"
assert_contains ".cursorrules" "Auto-Evolution Directive"

echo "Testing Claude adapter..."
source "$OLDPWD/.ai-suite/layer1-abstraction/agents/claude/adapter.sh"
agent_install_project "$OLDPWD/.ai-suite" "$TEST_WS"
assert_contains "CLAUDE.md" "Auto-Evolution Directive"

echo "Testing Roo-Code adapter..."
source "$OLDPWD/.ai-suite/layer1-abstraction/agents/roo-code/adapter.sh"
source "$OLDPWD/.ai-suite/layer1-abstraction/agents/codex/adapter.sh"
agent_install_project "$OLDPWD/.ai-suite" "$TEST_WS"
assert_contains ".roorules" "Auto-Evolution Directive"

echo "Testing OpenCode adapter..."
source "$OLDPWD/.ai-suite/layer1-abstraction/agents/opencode/adapter.sh"
agent_install_project "$OLDPWD/.ai-suite" "$TEST_WS"
assert_contains "CLAUDE.md" "Auto-Evolution Directive"

echo "PASS: Auto-Evolution contracts validated."

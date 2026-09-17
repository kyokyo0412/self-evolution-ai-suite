#!/usr/bin/env bash
set -euo pipefail

# test-agent-adapters-structural-contracts.sh
# Validates structural interface conformance across all agent adapters in:
# .ai-suite/layer1-abstraction/agents/*/adapter.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_DIR="$ROOT_DIR/.ai-suite/layer1-abstraction/agents"
SUITE_DIR="$ROOT_DIR/.ai-suite"

PASS=0
FAIL=0

pass() {
  PASS=$((PASS + 1))
  printf '  \033[32mPASS\033[0m %s\n' "$1"
}

fail() {
  FAIL=$((FAIL + 1))
  printf '  \033[31mFAIL\033[0m %s\n' "$1" >&2
}

echo "=== [SDET Contract Gate] Validating Agent Adapters Interface Symmetry ==="

AGENTS=("cursor" "claude" "codex" "continue" "opencode" "roo-code")

for agent in "${AGENTS[@]}"; do
  adapter="$AGENTS_DIR/$agent/adapter.sh"

  if [[ ! -f "$adapter" ]]; then
    fail "Adapter missing for agent: $agent"
    continue
  fi

  # Check 1: Mandatory adapter function definitions
  FUNCS=("agent_install_project" "agent_install_global" "agent_uninstall_project" "agent_uninstall_global")
  all_funcs=1
  for fn in "${FUNCS[@]}"; do
    if ! grep -qE "^[[:space:]]*${fn}\(\)" "$adapter"; then
      fail "$agent/adapter.sh missing function: $fn"
      all_funcs=0
    fi
  done
  if [[ $all_funcs -eq 1 ]]; then
    pass "$agent: Implements all 4 mandatory lifecycle functions"
  fi

  # Check 2: Dry-run execution test in subshell
  (
    source "$SUITE_DIR/layer1-abstraction/_portable.sh"
    source "$SUITE_DIR/layer2-cognitive/memory/core.sh"
    source "$adapter"
    TMP_DIR=$(mktemp -d)
    export AI_SUITE_DRY_RUN=1

    agent_install_project "$SUITE_DIR" "$TMP_DIR" >/dev/null 2>&1
    agent_uninstall_project "$TMP_DIR" "$SUITE_DIR" >/dev/null 2>&1
    rm -rf "$TMP_DIR"
  )
  if [[ $? -eq 0 ]]; then
    pass "$agent: Sourced and executed project lifecycle cleanly"
  else
    fail "$agent: Execution failed during project lifecycle simulation"
  fi
done

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
